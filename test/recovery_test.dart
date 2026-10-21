// test/recovery_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lovetype_tarot/services/purchase_recovery.dart';
import 'package:lovetype_tarot/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('실패·재시작 뒤 영수증을 복구하고 승인 전에는 완료하지 않는다', () async {
    String? persisted;
    var available = false;
    var completed = 0;
    PurchaseRecovery recovery() => PurchaseRecovery(
      read: () async => persisted,
      write: (value) async => persisted = value,
      send: (_) async {
        if (!available) throw StateError('offline');
        return {'success': true};
      },
    );
    final body = {
      'user_id': 'alice',
      'platform': 'android',
      'receipt': 'receipt-1',
    };
    expect(
      await recovery().process(
        body,
        complete: () async {
          completed++;
        },
      ),
      false,
    );
    expect(completed, 0);
    expect(jsonDecode(persisted!) as List, hasLength(1));
    available = true;
    await recovery().retry('bob');
    expect(jsonDecode(persisted!) as List, hasLength(1));
    await recovery().retry('alice');
    expect(jsonDecode(persisted!) as List, isEmpty);
  });
  test('스토어 완료가 실패하면 서버 승인 영수증도 보존한다', () async {
    String? persisted;
    final recovery = PurchaseRecovery(
      read: () async => persisted,
      write: (value) async => persisted = value,
      send: (_) async => {'success': true},
    );
    expect(
      await recovery.process(
        {'platform': 'android', 'receipt': 'r', 'user_id': 'alice'},
        complete: () async {
          throw StateError('store offline');
        },
      ),
      false,
    );
    expect(jsonDecode(persisted!) as List, hasLength(1));
  });
  test('동시 영수증·중복 이벤트가 대기 항목을 덮어쓰지 않는다', () async {
    String? persisted;
    final recovery = PurchaseRecovery(
      read: () async => persisted,
      write: (value) async => persisted = value,
      send: (_) async => throw StateError('offline'),
    );
    await Future.wait([
      for (final token in ['a', 'b', 'a'])
        recovery.process({
          'platform': 'android',
          'receipt': token,
          'user_id': 'alice',
        }),
    ]);
    expect(jsonDecode(persisted!) as List, hasLength(2));
  });
  test('히스토리 동시 적재와 전송 완료가 새 항목을 지우지 않는다', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService.instance;
    await storage.init();
    final old = {'client_reading_id': 'old', 'user_id': 'alice'};
    final fresh = {'client_reading_id': 'new', 'user_id': 'alice'};
    await storage.enqueuePendingHistory(old);
    await Future.wait([
      storage.removePendingHistory(old),
      storage.enqueuePendingHistory(fresh),
      storage.enqueuePendingHistory(fresh),
    ]);
    expect(storage.getPendingHistoryEntries(), [fresh]);
  });
}
