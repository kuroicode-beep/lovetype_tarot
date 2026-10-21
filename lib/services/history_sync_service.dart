import '../core/card_data.dart';
import '../core/constants.dart';
import '../models/reading_args.dart';
import '../models/tarot_card.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// v4.0: `POST /api/v1/tarot/history` + 실패 시 `history_pending` 재시도
class HistorySyncService {
  HistorySyncService._();
  static final HistorySyncService instance = HistorySyncService._();
  Future<void>? _flushing;

  /// 태그에서 `#` 제거
  static List<String> normalizeTags(List<String> tags) {
    return tags
        .map((t) => t.replaceAll('#', '').trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> buildHistoryBody({
    required UserModel user,
    required ReadingArgs args,
    required String story,
    String? readingId,
  }) {
    final tags = normalizeTags(args.tags);
    final today = _formatDate(DateTime.now());
    final body = <String, dynamic>{
      'app_id': AppConstants.appId,
      'user_id': StorageService.instance.effectiveUserIdForHistory(user),
      'date': today,
      'theme': args.topicLabel,
      'tags': tags,
      'cards': args.cards.map((c) => _cardPayload(c)).toList(),
      'story': story,
      'soul_card': user.soulCardNumber,
      'mbti': user.mbti,
    };
    if (readingId != null) body['reading_id'] = readingId;
    body['client_reading_id'] = StorageService.historyKey(body);
    return body;
  }

  Map<String, dynamic> _cardPayload(TarotCard c) {
    final n = tarotCardDeckNumber(c);
    return {
      'id': n,
      'name': c.nameKo,
      'direction': c.isReversed ? 'reversed' : 'upright',
    };
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// 업로드 성공 true, 대기 큐 적재 시 false
  Future<bool> uploadReading({
    required UserModel user,
    required ReadingArgs args,
    required String story,
    String? readingId,
  }) async {
    final body = buildHistoryBody(
      user: user,
      args: args,
      story: story,
      readingId: readingId,
    );
    try {
      await ApiService.instance.saveTarotHistory(body);
      await StorageService.instance.removePendingHistory(body);
      return true;
    } catch (_) {
      await StorageService.instance.enqueuePendingHistory(body);
      return false;
    }
  }

  /// 앱 기동 시 — 대기 중인 페이로드를 순서대로 재전송
  Future<void> flushPending() =>
      _flushing ??= _flush().whenComplete(() => _flushing = null);

  Future<void> _flush() async {
    await StorageService.instance.init();
    final pending = StorageService.instance.getPendingHistoryEntries();
    if (pending.isEmpty) return;

    for (final body in pending) {
      if (body['user_id'] != StorageService.instance.googleUserId) continue;
      try {
        body['client_reading_id'] ??= StorageService.historyKey(body);
        await ApiService.instance.saveTarotHistory(body);
        await StorageService.instance.removePendingHistory(body);
      } catch (_) {
        /* 미전송 항목은 기존 큐에 그대로 남긴다. */
      }
    }
  }
}
