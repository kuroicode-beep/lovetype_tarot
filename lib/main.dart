import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/app_state.dart';
import 'services/iap_service.dart';
import 'services/notification_service.dart';
import 'services/payment_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'LINE Seed KR',
    ], await rootBundle.loadString('assets/fonts/LINESeedKR_라이선스.txt'));
  });
  await StorageService.instance.init();
  PaymentService.instance.loadFromCache();
  await AppState.instance.init();
  runApp(const LoveTypeTarotApp());
  unawaited(NotificationService.instance.init().catchError((Object _) {}));
  unawaited(IapService.instance.init().catchError((Object _) {}));
}
