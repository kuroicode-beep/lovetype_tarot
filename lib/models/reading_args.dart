import 'tarot_card.dart';

/// 화면 간 리딩 세션 데이터 전달 모델
class ReadingArgs {
  final String topic;       // 'daily' | 'romance'
  final String topicLabel;  // '오늘의 이야기' | '연애 이야기'
  final List<String> tags;  // 선택된 키워드 태그
  final List<TarotCard> cards; // 뽑은 카드 (최대 3장)

  const ReadingArgs({
    required this.topic,
    required this.topicLabel,
    this.tags = const [],
    this.cards = const [],
  });

  ReadingArgs copyWith({
    String? topic,
    String? topicLabel,
    List<String>? tags,
    List<TarotCard>? cards,
  }) {
    return ReadingArgs(
      topic: topic ?? this.topic,
      topicLabel: topicLabel ?? this.topicLabel,
      tags: tags ?? this.tags,
      cards: cards ?? this.cards,
    );
  }
}
