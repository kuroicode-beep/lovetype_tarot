import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../firebase_options.dart';
import '../models/user_model.dart';
import 'fcm_background.dart';
import 'push_service.dart';
import 'storage_service.dart';

/// v5.1: 매일 오전 9시(서울) 로컬 알림 + 쿨타임 1시간 후 알림 + FCM 등록
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const int _idDailyMorning = 1001;
  static const int _idCooldownDaily = 1002;
  static const int _idCooldownRomance = 1003;
  static const int _idFcmForeground = 1004;

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _firebaseMessagingReady = false;
  StreamSubscription<String>? _tokenRefreshSub;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _ensureAndroidChannel();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();
    }

    _initialized = true;

    if (DefaultFirebaseOptions.isConfigured) {
      try {
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        await _setupForegroundFcm();
        _listenFcmTokenRefresh();
        _firebaseMessagingReady = true;
      } catch (e, st) {
        debugPrint('[NotificationService] Firebase init skipped: $e\n$st');
      }
    } else {
      debugPrint(
        '[NotificationService] Firebase 미설정 — FCM 비활성. flutterfire configure 권장.',
      );
    }

    await applyFromStorage();
  }

  Future<void> _ensureAndroidChannel() async {
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'lovetype_tarot_main',
        'LoveType Tarot',
        description: '오늘의 타로·쿨타임 알림',
        importance: Importance.defaultImportance,
      ),
    );
  }

  Future<void> _setupForegroundFcm() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage m) async {
      final title = m.notification?.title ?? 'LoveType-Tarot';
      final body = m.notification?.body ?? '';
      await _local.show(
        id: _idFcmForeground,
        title: title,
        body: body,
        notificationDetails: _details(),
      );
    });
  }

  void _listenFcmTokenRefresh() {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
      token,
    ) async {
      if (!StorageService.instance.pushEnabled) return;
      final user = StorageService.instance.loadUser();
      if (user == null || token.isEmpty) return;
      await _registerFcmToken(user: user, token: token);
    });
  }

  void _onNotificationTap(NotificationResponse response) {
    // 필요 시 딥링크/화면 이동
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'lovetype_tarot_main',
        'LoveType Tarot',
        channelDescription: '오늘의 타로·쿨타임 알림',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  /// SharedPreferences 기준으로 스케줄·FCM 동기화
  Future<void> applyFromStorage() async {
    final user = StorageService.instance.loadUser();
    final enabled = StorageService.instance.pushEnabled;
    if (!enabled) {
      await cancelAllSchedules();
      return;
    }
    await scheduleDailyMorningReminder();
    await _registerFcmIfPossible(user);
  }

  /// 설정 토글 저장 후 호출
  Future<void> onPushPreferenceChanged(bool enabled, UserModel? user) async {
    if (!enabled) {
      await cancelAllSchedules();
      return;
    }
    await scheduleDailyMorningReminder();
    await _registerFcmIfPossible(user);
  }

  Future<void> cancelAllSchedules() async {
    await _local.cancel(id: _idDailyMorning);
    await _local.cancel(id: _idCooldownDaily);
    await _local.cancel(id: _idCooldownRomance);
  }

  /// 매일 09:00 (Asia/Seoul) 반복
  Future<void> scheduleDailyMorningReminder() async {
    if (!StorageService.instance.pushEnabled) return;

    final location = tz.getLocation('Asia/Seoul');
    final now = tz.TZDateTime.now(location);
    var next = tz.TZDateTime(location, now.year, now.month, now.day, 9);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }

    await _local.zonedSchedule(
      id: _idDailyMorning,
      scheduledDate: next,
      notificationDetails: _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: '오늘의 타로',
      body: '오늘의 무료 타로가 기다리고 있어요 🔮',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 리딩 완료 후 1시간 뒤 쿨타임 해제 알림 (v5.0)
  Future<void> scheduleCooldownUnlock({required String topic}) async {
    if (!StorageService.instance.pushEnabled) return;

    final id = topic == 'romance' ? _idCooldownRomance : _idCooldownDaily;
    await _local.cancel(id: id);

    final location = tz.getLocation('Asia/Seoul');
    final when = tz.TZDateTime.now(location).add(const Duration(hours: 1));

    await _local.zonedSchedule(
      id: id,
      scheduledDate: when,
      notificationDetails: _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: '다시 볼 수 있어요',
      body: '타로를 확인해보세요 ✨',
    );
  }

  Future<void> _registerFcmIfPossible(UserModel? user) async {
    if (!_firebaseMessagingReady || user == null) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _registerFcmToken(user: user, token: token);
      }
    } catch (e) {
      debugPrint('[NotificationService] FCM token: $e');
    }
  }

  Future<void> _registerFcmToken({
    required UserModel user,
    required String token,
  }) async {
    final saved = StorageService.instance.lastRegisteredFcmToken;
    if (saved == token) return;
    await PushService.instance.registerToken(user: user, fcmToken: token);
    await StorageService.instance.setLastRegisteredFcmToken(token);
  }
}
