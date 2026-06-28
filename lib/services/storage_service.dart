import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/user_model.dart';

/// 로컬 저장소 서비스 (SharedPreferences 래퍼)
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    assert(_prefs != null, 'StorageService.init() 먼저 호출하세요');
    return _prefs!;
  }

  // ── 사용자 정보 ───────────────────────────────────────────
  Future<void> saveUser(UserModel user) async {
    await _p.setString(AppConstants.keyNickname, user.nickname);
    await _p.setString(AppConstants.keyGender, user.gender);
    await _p.setString(AppConstants.keyMbti, user.mbti);
    await _p.setString(AppConstants.keyBirthdate, user.birthdate);
    await _p.setInt(AppConstants.keySoulCardNumber, user.soulCardNumber);
  }

  UserModel? loadUser() {
    final nickname = _p.getString(AppConstants.keyNickname);
    if (nickname == null) return null;

    return UserModel(
      nickname: nickname,
      gender: _p.getString(AppConstants.keyGender) ?? '',
      mbti: _p.getString(AppConstants.keyMbti) ?? '',
      birthdate: _p.getString(AppConstants.keyBirthdate) ?? '',
      soulCardNumber: _p.getInt(AppConstants.keySoulCardNumber) ?? 1,
    );
  }

  // ── 테마 ─────────────────────────────────────────────────
  bool get isHighContrast => _p.getBool(AppConstants.keyHighContrast) ?? false;

  Future<void> setHighContrast(bool value) =>
      _p.setBool(AppConstants.keyHighContrast, value);

  // ── mock 캐시 ─────────────────────────────────────────────
  int get mockCash =>
      _p.getInt(AppConstants.keyMockCash) ?? AppConstants.mockCashAmount;

  Future<void> setMockCash(int value) =>
      _p.setInt(AppConstants.keyMockCash, value);

  // ── 포인트 / 구독 ──────────────────────────────────────────
  int get pointBalance => _p.getInt(AppConstants.keyPointBalance) ?? 0;

  Future<void> setPointBalance(int value) =>
      _p.setInt(AppConstants.keyPointBalance, value);

  bool get isSubscribed => _p.getBool(AppConstants.keyIsSubscribed) ?? false;

  Future<void> setIsSubscribed(bool value) =>
      _p.setBool(AppConstants.keyIsSubscribed, value);

  DateTime? get subscriptionExpiresAt {
    final raw = _p.getString(AppConstants.keySubscriptionExpiresAt);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setSubscriptionExpiresAt(DateTime? value) async {
    if (value == null) {
      await _p.remove(AppConstants.keySubscriptionExpiresAt);
    } else {
      await _p.setString(
        AppConstants.keySubscriptionExpiresAt,
        value.toIso8601String(),
      );
    }
  }

  bool get pushEnabled => _p.getBool(AppConstants.keyPushEnabled) ?? true;

  Future<void> setPushEnabled(bool value) =>
      _p.setBool(AppConstants.keyPushEnabled, value);

  String? get lastRegisteredFcmToken =>
      _p.getString(AppConstants.keyLastRegisteredFcmToken);

  Future<void> setLastRegisteredFcmToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _p.remove(AppConstants.keyLastRegisteredFcmToken);
    } else {
      await _p.setString(AppConstants.keyLastRegisteredFcmToken, token);
    }
  }

  // ── Google UID (히스토리 API) ─────────────────────────────
  String? get googleUserId => _p.getString(AppConstants.keyGoogleUserId);

  Future<void> setGoogleUserId(String? id) async {
    if (id == null || id.isEmpty) {
      await _p.remove(AppConstants.keyGoogleUserId);
    } else {
      await _p.setString(AppConstants.keyGoogleUserId, id);
    }
  }

  /// `user_id` — OAuth 미연동 시 로컬 식별자
  String effectiveUserIdForHistory(UserModel user) =>
      googleUserId ?? 'local_${user.nickname}';

  // ── 히스토리 전송 대기 큐 (v4.0 history_pending) ─────────
  List<Map<String, dynamic>> getPendingHistoryEntries() {
    final raw = _p.getString(AppConstants.keyHistoryPending);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> setPendingHistoryEntries(
    List<Map<String, dynamic>> entries,
  ) async {
    if (entries.isEmpty) {
      await _p.remove(AppConstants.keyHistoryPending);
    } else {
      await _p.setString(AppConstants.keyHistoryPending, jsonEncode(entries));
    }
  }

  Future<void> enqueuePendingHistory(Map<String, dynamic> body) async {
    final q = getPendingHistoryEntries()..add(body);
    await setPendingHistoryEntries(q);
  }

  // ── 초기화 ────────────────────────────────────────────────
  Future<void> clearAll() => _p.clear();
}
