import 'dart:async';

import 'package:flutter/material.dart';
import 'app.dart';
import 'core/app_state.dart';
import 'services/history_sync_service.dart';
import 'services/iap_service.dart';
import 'services/notification_service.dart';
import 'services/payment_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  PaymentService.instance.loadFromCache();
  await AppState.instance.init();
  await NotificationService.instance.init();
  await IapService.instance.init();
  unawaited(HistorySyncService.instance.flushPending());
  runApp(const LoveTypeTarotApp());
}
