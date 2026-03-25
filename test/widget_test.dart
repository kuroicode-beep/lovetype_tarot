import 'package:flutter_test/flutter_test.dart';
import 'package:lovetype_tarot/core/soul_card.dart';

void main() {
  group('calcSoulCard', () {
    test('19790624 → 2 (여사제)', () {
      // 1+9+7+9+6+2+4 = 38 → 3+8 = 11 → 1+1 = 2
      expect(calcSoulCard('19790624'), 2);
    });

    test('19900101 → 3 (여황제)', () {
      // 1+9+9+0+0+1+0+1 = 21 → 2+1 = 3
      expect(calcSoulCard('19900101'), 3);
    });

    test('20000101 → 4 (황제)', () {
      // 2+0+0+0+0+1+0+1 = 4
      expect(calcSoulCard('20000101'), 4);
    });

    test('19991231 → 7 (전차)', () {
      // 1+9+9+9+1+2+3+1 = 35 → 3+5 = 8 — wait let me recalculate
      // 1+9+9+9+1+2+3+1 = 35 → 3+5 = 8
      expect(calcSoulCard('19991231'), 8);
    });

    test('19800815 → 5 (교황)', () {
      // 1+9+8+0+0+8+1+5 = 32 → 3+2 = 5
      expect(calcSoulCard('19800815'), 5);
    });

    test('결과는 항상 1~9 사이', () {
      final testDates = [
        '19700101', '19851225', '20010901',
        '19990909', '20101010', '19650630',
      ];
      for (final date in testDates) {
        final result = calcSoulCard(date);
        expect(result, inInclusiveRange(1, 9),
            reason: '$date → $result 범위 초과');
      }
    });

    test('구분자 포함 형식도 처리', () {
      // '1979-06-24' → 2
      expect(calcSoulCard('1979-06-24'), 2);
    });

    test('잘못된 입력 시 ArgumentError', () {
      expect(() => calcSoulCard(''), throwsArgumentError);
    });
  });

  group('soulCardNames', () {
    test('1~9 모두 이름 존재', () {
      for (int i = 1; i <= 9; i++) {
        expect(soulCardNames.containsKey(i), true, reason: '$i번 없음');
        expect(soulCardNames[i], isNotEmpty);
      }
    });

    test('2번은 여사제', () {
      expect(soulCardNames[2], '여사제');
    });
  });

  group('soulCardImagePath', () {
    test('풀샷 에셋 경로 반환', () {
      expect(
        soulCardImagePath(1),
        'asset/soul_cards/soul_01_magician.png',
      );
      expect(
        soulCardImagePath(9),
        'asset/soul_cards/soul_09_hermit.png',
      );
    });

    test('아바타 에셋 경로 반환', () {
      expect(
        soulCardAvatarPath(1),
        'asset/soul_cards/avatar_01_magician.png',
      );
      expect(
        soulCardAvatarPath(9),
        'asset/soul_cards/avatar_09_hermit.png',
      );
    });
  });
}
