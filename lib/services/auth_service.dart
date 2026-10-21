// lib/services/auth_service.dart
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'history_sync_service.dart';
import 'iap_service.dart';

/// Google 인증과 서버 사용자 확인을 모두 마친 뒤 세션을 공개한다.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();
  static const clientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  final GoogleSignIn _google = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: clientId.isEmpty ? null : clientId,
  );
  bool _authenticated = false;
  Future<String?>? _refreshing;
  bool get isSignedIn => _authenticated;

  /// 앱 재시작·명시적 로그인 시 Google 토큰을 서버에서 다시 검증한다.
  Future<bool> signIn({bool silently = false}) async {
    _authenticated = false;
    try {
      final account = silently
          ? await _google.signInSilently(reAuthenticate: true)
          : await _google.signIn();
      if (account == null) return false;
      final token = (await account.authentication).idToken;
      if (token == null) throw StateError('Google 인증 토큰을 받지 못했어요.');
      final result = await ApiService.instance.authGoogle(idToken: token);
      final id = result['user_id'] as String?;
      if (result['success'] != true || id != account.id) {
        throw StateError('로그인 사용자 확인에 실패했어요.');
      }
      final storage = StorageService.instance;
      if (storage.googleUserId != null && storage.googleUserId != id) {
        await storage.clearAccountCache();
      }
      await storage.setGoogleUserId(id);
      ApiService.instance.setBearerToken(token);
      ApiService.instance.refreshToken = refreshToken;
      _authenticated = true;
      unawaited(
        HistorySyncService.instance.flushPending().catchError((Object _) {}),
      );
      unawaited(IapService.instance.retryPending().catchError((Object _) {}));
      return true;
    } catch (_) {
      _authenticated = false;
      ApiService.instance.setBearerToken(null);
      if (silently) return false;
      rethrow;
    }
  }

  /// 만료 응답이 겹쳐도 Google 토큰 갱신은 한 번만 진행한다.
  Future<String?> refreshToken() =>
      _refreshing ??= _refresh().whenComplete(() => _refreshing = null);
  Future<String?> _refresh() async {
    final account = await _google.signInSilently(reAuthenticate: true);
    if (account?.id != StorageService.instance.googleUserId) return null;
    return (await account?.authentication)?.idToken;
  }

  /// 계정 전환 전 인증과 계정별 표시 캐시를 해제한다. 재전송 큐는 보존한다.
  Future<void> signOut() async {
    _authenticated = false;
    ApiService.instance.setBearerToken(null);
    await StorageService.instance.clearAccountCache();
    await _google.signOut();
  }
}
