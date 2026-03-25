import '../models/tarot_card.dart';

// 타로 78장 전체 카드 데이터

const _minorRanksKo = [
  '에이스', '2', '3', '4', '5', '6', '7',
  '8', '9', '10', '시종', '기사', '여왕', '왕',
];
const _minorRanksEn = [
  'Ace', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven',
  'Eight', 'Nine', 'Ten', 'Page', 'Knight', 'Queen', 'King',
];

List<TarotCard> _minor(String id, String koName, String enName) {
  return List.generate(14, (i) {
    final num = (i + 1).toString().padLeft(2, '0');
    return TarotCard(
      id: '${id}_$num',
      nameKo: '$koName ${_minorRanksKo[i]}',
      nameEn: '${_minorRanksEn[i]} of $enName',
    );
  });
}

/// 전체 78장 카드 리스트
final List<TarotCard> allTarotCards = [
  // ── 메이저 아르카나 (22장) ────────────────────────────────
  const TarotCard(id: 'major_00', nameKo: '바보', nameEn: 'The Fool'),
  const TarotCard(id: 'major_01', nameKo: '마법사', nameEn: 'The Magician'),
  const TarotCard(id: 'major_02', nameKo: '여사제', nameEn: 'The High Priestess'),
  const TarotCard(id: 'major_03', nameKo: '여황제', nameEn: 'The Empress'),
  const TarotCard(id: 'major_04', nameKo: '황제', nameEn: 'The Emperor'),
  const TarotCard(id: 'major_05', nameKo: '교황', nameEn: 'The Hierophant'),
  const TarotCard(id: 'major_06', nameKo: '연인', nameEn: 'The Lovers'),
  const TarotCard(id: 'major_07', nameKo: '전차', nameEn: 'The Chariot'),
  const TarotCard(id: 'major_08', nameKo: '힘', nameEn: 'Strength'),
  const TarotCard(id: 'major_09', nameKo: '은둔자', nameEn: 'The Hermit'),
  const TarotCard(id: 'major_10', nameKo: '운명의 수레바퀴', nameEn: 'Wheel of Fortune'),
  const TarotCard(id: 'major_11', nameKo: '정의', nameEn: 'Justice'),
  const TarotCard(id: 'major_12', nameKo: '매달린 남자', nameEn: 'The Hanged Man'),
  const TarotCard(id: 'major_13', nameKo: '죽음', nameEn: 'Death'),
  const TarotCard(id: 'major_14', nameKo: '절제', nameEn: 'Temperance'),
  const TarotCard(id: 'major_15', nameKo: '악마', nameEn: 'The Devil'),
  const TarotCard(id: 'major_16', nameKo: '탑', nameEn: 'The Tower'),
  const TarotCard(id: 'major_17', nameKo: '별', nameEn: 'The Star'),
  const TarotCard(id: 'major_18', nameKo: '달', nameEn: 'The Moon'),
  const TarotCard(id: 'major_19', nameKo: '태양', nameEn: 'The Sun'),
  const TarotCard(id: 'major_20', nameKo: '심판', nameEn: 'Judgement'),
  const TarotCard(id: 'major_21', nameKo: '세계', nameEn: 'The World'),

  // ── 마이너 아르카나 ────────────────────────────────────────
  ..._minor('cup', '컵', 'Cups'),
  ..._minor('wand', '완드', 'Wands'),
  ..._minor('sword', '검', 'Swords'),
  ..._minor('pentacle', '펜타클', 'Pentacles'),
];

/// 78장 덱 기준 1~78번 (메이저→컵→완드→검→펜타클). 알 수 없으면 0.
int tarotCardDeckNumber(TarotCard card) {
  final i = allTarotCards.indexWhere((c) => c.id == card.id);
  return i >= 0 ? i + 1 : 0;
}

// ── `asset/basic_deck` 등 실제 PNG 파일명과 카드 id 연결 ───────────────

/// 표시용 덱 (폴더: basic_deck / low_vision_deck / webtoon_deck)
enum TarotDeckVisual {
  basic,
  lowVision,
  webtoon,
}

String _tarotDeckVisualFolder(TarotDeckVisual deck) => switch (deck) {
      TarotDeckVisual.basic => 'basic_deck',
      TarotDeckVisual.lowVision => 'low_vision_deck',
      TarotDeckVisual.webtoon => 'webtoon_deck',
    };

/// 고대비 ON → 저시력 덱, 구독 중이면 웹툰 덱, 아니면 기본 덱.
TarotDeckVisual resolveTarotDeckVisual({
  required bool highContrast,
  required bool subscribed,
}) {
  if (highContrast) return TarotDeckVisual.lowVision;
  if (subscribed) return TarotDeckVisual.webtoon;
  return TarotDeckVisual.basic;
}

const _majorAssetPrefixes = [
  '00_The_Fool',
  '01_The_Magician',
  '02_The_High_Priestess',
  '03_The_Empress',
  '04_The_Emperor',
  '05_The_Hierophant',
  '06_The_Lovers',
  '07_The_Chariot',
  '08_Strength',
  '09_The_Hermit',
  '10_Wheel_of_Fortune',
  '11_Justice',
  '12_The_Hanged_Man',
  '13_Death',
  '14_Temperance',
  '15_The_Devil',
  '16_The_Tower',
  '17_The_Star',
  '18_The_Moon',
  '19_The_Sun',
  '20_Judgement',
  '21_The_World',
];

/// `major_00` … `pentacle_14` → `00_The_Fool_00001_.png` 형식 파일명
String tarotCardImageFileName(String id) {
  if (id.startsWith('major_')) {
    final idx = int.parse(id.substring(6));
    return '${_majorAssetPrefixes[idx]}_00001_.png';
  }
  final u = id.indexOf('_');
  if (u <= 0) {
    throw ArgumentError.value(id, 'id', 'expected major_NN or suit_NN');
  }
  final suit = id.substring(0, u);
  final num = id.substring(u + 1);
  final suitCap = switch (suit) {
    'cup' => 'Cup',
    'wand' => 'Wand',
    'sword' => 'Sword',
    'pentacle' => 'Pentacle',
    _ => throw ArgumentError.value(id, 'id', 'unknown suit'),
  };
  final n = int.parse(num);
  final rank = _minorRanksEn[n - 1];
  return '${suitCap}_${num}_${rank}_00001_.png';
}

String tarotCardImagePath(String id, TarotDeckVisual deck) {
  final dir = _tarotDeckVisualFolder(deck);
  final file = tarotCardImageFileName(id);
  return 'asset/$dir/$file';
}
