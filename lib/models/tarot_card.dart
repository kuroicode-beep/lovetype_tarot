/// 타로 카드 모델
class TarotCard {
  final String id; // 예: 'major_00', 'cup_01'
  final String nameKo; // 한국어 이름
  final String nameEn; // 영어 이름
  final bool isReversed; // 정방향(false) / 역방향(true)
  final String deckType; // 'default' | 'high_contrast' | 'special'

  const TarotCard({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    this.isReversed = false,
    this.deckType = 'default',
  });

  TarotCard copyWith({bool? isReversed, String? deckType}) {
    return TarotCard(
      id: id,
      nameKo: nameKo,
      nameEn: nameEn,
      isReversed: isReversed ?? this.isReversed,
      deckType: deckType ?? this.deckType,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_ko': nameKo,
        'name_en': nameEn,
        'is_reversed': isReversed,
        'deck_type': deckType,
      };

  factory TarotCard.fromJson(Map<String, dynamic> json) => TarotCard(
        id: json['id'] as String,
        nameKo: json['name_ko'] as String,
        nameEn: json['name_en'] as String,
        isReversed: json['is_reversed'] as bool? ?? false,
        deckType: json['deck_type'] as String? ?? 'default',
      );
}
