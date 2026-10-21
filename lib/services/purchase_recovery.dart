// lib/services/purchase_recovery.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// 암호화 저장소에 미완료 영수증을 먼저 보존하고 서버 승인 뒤에만 완료한다.
class PurchaseRecovery {
  PurchaseRecovery({
    required this.read,
    required this.write,
    required this.send,
  });
  final Future<String?> Function() read;
  final Future<void> Function(String value) write;
  final Future<Map<String, dynamic>> Function(Map<String, dynamic>) send;
  Future<void> _tail = Future<void>.value();

  Future<List<Map<String, dynamic>>> _entries() async {
    final raw = await read();
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static String _key(Map<String, dynamic> body) => sha256
      .convert(utf8.encode('${body['platform']}:${body['receipt']}'))
      .toString();

  /// 동시 구매 이벤트도 한 큐에서 처리해 서로의 대기 항목을 덮어쓰지 않는다.
  Future<bool> process(
    Map<String, dynamic> body, {
    Future<void> Function()? complete,
  }) {
    final result = _tail.then((_) async {
      final entries = await _entries();
      final key = _key(body);
      if (!entries.any((e) => _key(e) == key)) entries.add(body);
      await write(jsonEncode(entries));
      try {
        final response = await send(body);
        if (response['success'] != true) return false;
        await complete?.call();
        entries.removeWhere((e) => _key(e) == key);
        await write(jsonEncode(entries));
        return true;
      } catch (_) {
        return false;
      }
    });
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  /// 로그인한 계정의 영수증만 재시도한다. 다른 계정의 대기 항목은 보존한다.
  Future<void> retry(String userId) async {
    await _tail;
    final entries = await _entries();
    for (final body in entries.where((e) => e['user_id'] == userId)) {
      await process(body);
    }
  }
}
