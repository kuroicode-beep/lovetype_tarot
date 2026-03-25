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
  }) {
    final tags = normalizeTags(args.tags);
    final today = _formatDate(DateTime.now());
    return {
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
  }) async {
    final body = buildHistoryBody(user: user, args: args, story: story);
    try {
      await ApiService.instance.saveTarotHistory(body);
      return true;
    } catch (_) {
      await StorageService.instance.enqueuePendingHistory(body);
      return false;
    }
  }

  /// 앱 기동 시 — 대기 중인 페이로드를 순서대로 재전송
  Future<void> flushPending() async {
    await StorageService.instance.init();
    var pending = StorageService.instance.getPendingHistoryEntries();
    if (pending.isEmpty) return;

    final remaining = <Map<String, dynamic>>[];
    for (final body in pending) {
      try {
        await ApiService.instance.saveTarotHistory(body);
      } catch (_) {
        remaining.add(body);
      }
    }
    await StorageService.instance.setPendingHistoryEntries(remaining);
  }
}
