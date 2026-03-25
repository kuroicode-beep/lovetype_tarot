import 'tarot_card.dart';

/// 타로 리딩 결과 모델 (카드 3장 + 주제 + 태그 + AI 해석)
class ReadingResult {
  final String id;
  final List<TarotCard> cards; // 정확히 3장
  final String topic; // 리딩 주제 (예: '연애', '직장', '일상')
  final List<String> tags; // 선택한 키워드 태그
  final String aiInterpretation; // DeepSeek AI 해석 텍스트
  final DateTime createdAt;

  const ReadingResult({
    required this.id,
    required this.cards,
    required this.topic,
    required this.tags,
    required this.aiInterpretation,
    required this.createdAt,
  });

  /// 과거 / 현재 / 미래 포지션별 카드
  TarotCard? get pastCard => cards.isNotEmpty ? cards[0] : null;
  TarotCard? get presentCard => cards.length > 1 ? cards[1] : null;
  TarotCard? get futureCard => cards.length > 2 ? cards[2] : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'cards': cards.map((c) => c.toJson()).toList(),
        'topic': topic,
        'tags': tags,
        'ai_interpretation': aiInterpretation,
        'created_at': createdAt.toIso8601String(),
      };

  factory ReadingResult.fromJson(Map<String, dynamic> json) => ReadingResult(
        id: json['id'] as String,
        cards: (json['cards'] as List)
            .map((c) => TarotCard.fromJson(c as Map<String, dynamic>))
            .toList(),
        topic: json['topic'] as String,
        tags: List<String>.from(json['tags'] as List),
        aiInterpretation: json['ai_interpretation'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
