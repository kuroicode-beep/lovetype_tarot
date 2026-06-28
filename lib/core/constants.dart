/// LoveType-Tarot 앱 전역 상수
class AppConstants {
  AppConstants._();

  // ── 앱 식별자 ──────────────────────────────────────────────
  static const String appId = 'lovetype-tarot';
  static const String appVersion = '0.1.0';

  // ── API ───────────────────────────────────────────────────
  static const String baseUrl = 'https://lovetype-api.railway.app';
  static const String apiVersion = '/api/v1';

  /// 백엔드 노출 API (Railway lovetype-api)
  /// 1. POST /api/v1/tarot/history — [tarotHistoryEndpoint]
  /// 2. GET  /api/v1/payment/balance
  /// 3. POST /api/v1/payment/use
  /// 4. POST /api/v1/auth/google
  /// 5. POST /api/v1/payment/charge
  /// 6. POST /api/v1/push/register
  /// 7. GET  /api/v1/tarot/cooltime
  /// 8. GET  /api/v1/tarot/history
  /// 9. POST /api/v1/push/send
  /// 10. 어드민 페이지 — [adminPortalUrl] (웹, 앱 외부)
  static const String tarotEndpoint = '$apiVersion/tarot';
  static const String tarotHistoryEndpoint = '$apiVersion/tarot/history';
  static const String tarotCooltimeEndpoint = '$apiVersion/tarot/cooltime';
  static const String authGoogleEndpoint = '$apiVersion/auth/google';
  static const String paymentBalanceEndpoint = '$apiVersion/payment/balance';
  static const String paymentUseEndpoint = '$apiVersion/payment/use';
  static const String paymentChargeEndpoint = '$apiVersion/payment/charge';
  static const String pushRegisterEndpoint = '$apiVersion/push/register';
  static const String pushSendEndpoint = '$apiVersion/push/send';

  /// 웹 어드민 (호스트·경로는 배포 환경에 맞게 수정)
  static const String adminPortalUrl = '$baseUrl/admin';

  static const String compatEndpoint = '$apiVersion/compat';
  static const String userEndpoint = '$apiVersion/user';

  // ── 로컬 저장 키 ──────────────────────────────────────────
  static const String keyNickname = 'nickname';
  static const String keyGender = 'gender';
  static const String keyMbti = 'mbti';
  static const String keyBirthdate = 'birthdate';
  static const String keySoulCardNumber = 'soul_card_number';
  static const String keyHighContrast = 'high_contrast';
  static const String keyMockCash = 'mock_cash';
  static const String keyPointBalance = 'point_balance';
  static const String keyIsSubscribed = 'is_subscribed';
  static const String keySubscriptionExpiresAt = 'subscription_expires_at';
  static const String keyPushEnabled = 'push_enabled';

  /// 마지막으로 서버에 등록한 FCM 토큰 (중복 등록 최소화)
  static const String keyLastRegisteredFcmToken = 'last_registered_fcm_token';

  /// Google 계정 UID (OAuth 연동 시 저장, 히스토리 API `user_id`용)
  static const String keyGoogleUserId = 'google_user_id';

  /// v4.0: 서버 전송 실패 시 임시 큐 (JSON 배열)
  static const String keyHistoryPending = 'history_pending';

  // ── mock 데이터 ───────────────────────────────────────────
  static const int mockCashAmount = 0;
  static const int mockDailyReadings = 3;

  // ── 카드 덱 ───────────────────────────────────────────────
  static const int majorArcanaCount = 22;
  static const int minorArcanaCount = 56;
  static const int totalCardCount = 78;
}
