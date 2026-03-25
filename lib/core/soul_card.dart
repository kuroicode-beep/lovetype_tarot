// 소울카드 수비학 계산 로직
//
// 생년월일 각 자리를 합산 → 두 자리 이상이면 다시 합산 → 1~9 수렴
// 예: 19790624 → 1+9+7+9+6+2+4 = 38 → 3+8 = 11 → 1+1 = 2 → 2번: 여사제

/// 소울카드 번호 계산 (1~9)
///
/// [birthdate] 형식: 'YYYYMMDD' (예: '19790624')
int calcSoulCard(String birthdate) {
  // 숫자만 추출
  final digits = birthdate.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) throw ArgumentError('생년월일 형식 오류: $birthdate');

  int sum = digits.codeUnits
      .where((c) => c >= 48 && c <= 57) // '0'~'9'
      .fold(0, (acc, c) => acc + (c - 48));

  // 두 자리 이상이면 각 자리 합산 반복
  while (sum >= 10) {
    sum = sum
        .toString()
        .codeUnits
        .fold(0, (acc, c) => acc + (c - 48));
  }

  return sum == 0 ? 9 : sum; // 0이 나오는 경우 방어 처리 (실제론 불가)
}

/// 소울카드 번호 → 타로 카드 이름 매핑 (메이저 아르카나 1~9번)
const Map<int, String> soulCardNames = {
  1: '마법사',
  2: '여사제',
  3: '여황제',
  4: '황제',
  5: '교황',
  6: '연인',
  7: '전차',
  8: '힘',
  9: '은둔자',
};

/// 소울카드 번호 → `asset/soul_cards/soul_NN_<slug>.png` 파일 접미사
const Map<int, String> soulCardAssetSlug = {
  1: 'magician',
  2: 'high_priestess',
  3: 'empress',
  4: 'emperor',
  5: 'hierophant',
  6: 'lovers',
  7: 'chariot',
  8: 'strength',
  9: 'hermit',
};

/// 소울카드 번호 → 풀샷 카드 이미지 에셋 경로 (소울카드 등장 화면용)
String soulCardImagePath(int number) {
  final slug = soulCardAssetSlug[number];
  if (slug == null) {
    throw ArgumentError.value(number, 'number', 'expected 1~9');
  }
  final nn = number.toString().padLeft(2, '0');
  return 'asset/soul_cards/soul_${nn}_$slug.png';
}

/// 소울카드 번호 → 원형 아바타 이미지 에셋 경로 (하단 바용)
String soulCardAvatarPath(int number) {
  final slug = soulCardAssetSlug[number];
  if (slug == null) {
    throw ArgumentError.value(number, 'number', 'expected 1~9');
  }
  final nn = number.toString().padLeft(2, '0');
  return 'asset/soul_cards/avatar_${nn}_$slug.png';
}

/// 소울카드 번호 → 성격 설명 (소울카드 등장 화면 / AI 프롬프트용)
const Map<int, String> soulCardDescriptions = {
  1: '목표를 향한 의지가 강하고, 어떤 상황도 자신의 것으로 만드는 힘이 있어요.',
  2: '직관이 예리하고, 말하지 않아도 많은 것을 느끼는 깊은 내면을 가졌어요.',
  3: '따뜻하고 풍요로운 에너지로 주변을 편안하게 만드는 존재예요.',
  4: '안정감과 신뢰를 주는 단단한 기반을 가진 사람이에요.',
  5: '지혜롭고 진실을 중요하게 여기며, 관계에서 신뢰를 쌓아가는 타입이에요.',
  6: '감수성이 풍부하고 관계에서 진심을 다하는 로맨틱한 영혼이에요.',
  7: '추진력이 강하고 한번 마음먹으면 끝까지 밀고 나가는 에너지가 있어요.',
  8: '겉으로는 부드럽지만 내면에 단단한 힘을 가진, 진정한 강인함의 소유자예요.',
  9: '깊은 사색과 통찰력으로 남들이 보지 못하는 것을 꿰뚫어 보는 지혜가 있어요.',
};

