import '../core/constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// v5.0 푸시 API 연동용 최소 서비스.
/// FCM 토큰 발급(firebase_messaging) 이후 registerToken()을 호출하면 된다.
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  String _userId(UserModel user) =>
      StorageService.instance.effectiveUserIdForHistory(user);

  Future<void> registerToken({
    required UserModel user,
    required String fcmToken,
  }) async {
    await ApiService.instance.postPushRegister({
      'user_id': _userId(user),
      'fcm_token': fcmToken,
      'app_id': AppConstants.appId,
    });
  }
}
