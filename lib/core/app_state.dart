import 'package:flutter/foundation.dart';
import 'constants.dart';
import '../services/storage_service.dart';

/// 앱 전역 상태 (고대비 모드 등)
/// ValueNotifier 기반 — 상태관리 라이브러리 없이 사용
class AppState {
  AppState._();
  static final AppState instance = AppState._();

  final ValueNotifier<bool> highContrast = ValueNotifier(false);

  /// StorageService에서 초기값 로드
  Future<void> init() async {
    highContrast.value = StorageService.instance.isHighContrast;
  }

  Future<void> toggleHighContrast() async {
    highContrast.value = !highContrast.value;
    await StorageService.instance.setHighContrast(highContrast.value);
  }

  /// StorageService 키 (constants.dart 위임)
  static String get appId => AppConstants.appId;
}
