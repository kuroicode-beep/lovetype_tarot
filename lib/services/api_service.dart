import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../core/soul_card.dart';
import '../models/tarot_card.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

/// Railway `lovetype-api` 호출 (경로·번호는 [AppConstants] 주석 참고)
///
/// 1. [saveTarotHistory] · 2. [getPaymentBalance] · 3. [postPaymentUse]
/// 4. [authGoogle] · 5. [postPaymentCharge] · 6. [postPushRegister]
/// 7. [getTarotCooltime] · 8. [getTarotHistory] · 9. [postPushSend]
/// 10. 어드민 — [AppConstants.adminPortalUrl] (웹)
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final http.Client _client = http.Client();

  String? _bearerToken;

  /// 로그인 후 서버에서 받은 access_token 설정 (보호 API용)
  void setBearerToken(String? token) => _bearerToken = token;

  Map<String, String> get _headers {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'X-App-Id': AppConstants.appId,
    };
    final t = _bearerToken;
    if (t != null && t.isNotEmpty) {
      h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final base = Uri.parse('${AppConstants.baseUrl}$path');
    final uri = query == null || query.isEmpty
        ? base
        : base.replace(queryParameters: query);
    final response = await _client.get(uri, headers: _headers);
    return _parse(response);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _parse(response);
  }

  // ── 4. 인증 ────────────────────────────────────────────────

  /// POST /api/v1/auth/google
  Future<Map<String, dynamic>> authGoogle({required String idToken}) async {
    return post(AppConstants.authGoogleEndpoint, {'id_token': idToken});
  }

  // ── 결제 ───────────────────────────────────────────────────

  /// GET /api/v1/payment/balance
  Future<Map<String, dynamic>> getPaymentBalance() async {
    return get(AppConstants.paymentBalanceEndpoint);
  }

  /// POST /api/v1/payment/use — 본문은 백엔드 스펙에 맞게 전달
  Future<Map<String, dynamic>> postPaymentUse(Map<String, dynamic> body) async {
    return post(AppConstants.paymentUseEndpoint, body);
  }

  /// POST /api/v1/payment/charge
  Future<Map<String, dynamic>> postPaymentCharge(
    Map<String, dynamic> body,
  ) async {
    return post(AppConstants.paymentChargeEndpoint, body);
  }

  // ── 푸시 ───────────────────────────────────────────────────

  /// POST /api/v1/push/register
  Future<Map<String, dynamic>> postPushRegister(
    Map<String, dynamic> body,
  ) async {
    return post(AppConstants.pushRegisterEndpoint, body);
  }

  /// POST /api/v1/push/send
  Future<Map<String, dynamic>> postPushSend(Map<String, dynamic> body) async {
    return post(AppConstants.pushSendEndpoint, body);
  }

  // ── 타로 ───────────────────────────────────────────────────

  /// GET /api/v1/tarot/cooltime
  Future<Map<String, dynamic>> getTarotCooltime({
    Map<String, String>? query,
  }) async {
    return get(AppConstants.tarotCooltimeEndpoint, query: query);
  }

  Future<TarotCooltimeStatus> getReadingCooltime({
    required UserModel user,
    required String topic,
  }) async {
    final categoryKey = topic == 'romance' ? 'love' : 'today';
    final result = await getTarotCooltime(
      query: {
        'app_id': AppConstants.appId,
        'user_id': _effectiveUserId(user),
        'topic': topic,
        'category_key': categoryKey,
      },
    );
    final status = TarotCooltimeStatus.fromJson(result);
    if (kDebugMode) {
      final data = result['data'];
      final keys = data is Map<String, dynamic> ? data.keys : result.keys;
      debugPrint(
        '[cooltime] topic=$topic keys=${keys.join(',')} '
        'available=${status.isAvailable} '
        'next=${status.nextAvailableAt?.toIso8601String()} '
        'remaining=${status.remaining()?.inSeconds}',
      );
    }
    return status;
  }

  /// GET /api/v1/tarot/history
  Future<Map<String, dynamic>> getTarotHistory({
    Map<String, String>? query,
  }) async {
    return get(AppConstants.tarotHistoryEndpoint, query: query);
  }

  /// 타로 리딩 API 호출 → DeepSeek 프롬프트 조합 후 결과 텍스트 반환
  Future<String> tarotReading({
    required UserModel user,
    required String topic,
    required String topicLabel,
    required List<String> tags,
    required List<TarotCard> cards,
  }) async {
    final cardLines = cards
        .asMap()
        .entries
        .map((e) {
          final pos = ['과거', '현재', '미래'][e.key];
          final dir = e.value.isReversed ? '역방향' : '정방향';
          return '${e.key + 1}번 카드 $dir (${e.value.nameKo}): $pos의 이야기';
        })
        .join('\n');

    final genderLabel = user.gender == 'female' ? '여성' : '남성';
    final soulDesc = soulCardDescriptions[user.soulCardNumber] ?? '';
    final tagStr = tags.map((t) => '#$t').join(' ');

    final prompt =
        '''
소울카드인 "$genderLabel" 주인공의 "$topicLabel" 이야기야.
"$tagStr"을 기본 주제로 소설 톤의 짧은 이야기를 써줘.

$cardLines

주인공의 성격은 $soulDesc
MBTI는 ${user.mbti}야.
위 구조를 기본으로, 정형적이지 않게 자유롭고 자연스러운 글을 써줘.
한국어로 출력해줘.
''';

    final result = await post(AppConstants.tarotEndpoint, {
      'app_id': AppConstants.appId,
      'topic': topic,
      'prompt': prompt,
      'user_mbti': user.mbti,
      'soul_card': user.soulCardNumber,
    });

    return result['result'] as String? ??
        result['text'] as String? ??
        result['content'] as String? ??
        '이야기를 불러오는 데 실패했습니다.';
  }

  /// v4.0: 리딩 결과 서버 저장 — 성공 시 서버가 부여한 id (있으면)
  Future<String?> saveTarotHistory(Map<String, dynamic> body) async {
    final result = await post(AppConstants.tarotHistoryEndpoint, body);
    return _extractHistoryId(result);
  }

  String? _extractHistoryId(Map<String, dynamic> result) {
    final data = result['data'];
    if (data is Map<String, dynamic>) {
      final id = data['id'] ?? data['history_id'];
      if (id != null) return id.toString();
    }
    final top = result['id'];
    if (top != null) return top.toString();
    return null;
  }

  String _effectiveUserId(UserModel user) {
    return StorageService.instance.effectiveUserIdForHistory(user);
  }

  Map<String, dynamic> _parse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException(statusCode: response.statusCode, message: response.body);
  }
}

class TarotCooltimeStatus {
  final bool isAvailable;
  final DateTime? nextAvailableAt;
  final String? message;

  const TarotCooltimeStatus({
    required this.isAvailable,
    this.nextAvailableAt,
    this.message,
  });

  Duration? remaining([DateTime? now]) {
    final next = nextAvailableAt;
    if (next == null) return null;
    final diff = next.toLocal().difference(now ?? DateTime.now());
    return diff.isNegative || diff == Duration.zero ? null : diff;
  }

  factory TarotCooltimeStatus.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final remainingSeconds =
        _numValue(data, const ['remaining_seconds', 'remainingSeconds']) ??
        _numValue(data, const ['cooldown_seconds', 'cooldownSeconds']) ??
        _numValue(data, const ['remaining']);
    final nextAvailableAt =
        _dateValue(data, const [
          'next_available_at',
          'nextAvailableAt',
          'available_at',
          'availableAt',
          'unlock_at',
          'unlockAt',
        ]) ??
        (remainingSeconds == null
            ? null
            : DateTime.now().add(Duration(seconds: remainingSeconds.ceil())));

    final explicitAvailable = _boolValue(data, const [
      'is_available',
      'isAvailable',
      'available',
      'can_read',
      'canRead',
    ]);
    final isAvailable =
        explicitAvailable ??
        nextAvailableAt == null || nextAvailableAt.isBefore(DateTime.now());

    return TarotCooltimeStatus(
      isAvailable: isAvailable,
      nextAvailableAt: isAvailable ? null : nextAvailableAt,
      message: _stringValue(data, const [
        'message',
        'reason',
        'reason_message',
      ]),
    );
  }

  static bool? _boolValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is bool) return value;
      if (value is String) {
        final normalized = value.toLowerCase();
        if (normalized == 'true') return true;
        if (normalized == 'false') return false;
      }
    }
    return null;
  }

  static num? _numValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is num) return value;
      if (value is String) {
        final parsed = num.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static DateTime? _dateValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key]?.toString();
      if (value == null || value.isEmpty) continue;
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  static String? _stringValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key]?.toString();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
