import 'package:flutter/material.dart';
import '../core/soul_card.dart';
import '../core/theme.dart';

/// 하단 바에 표시되는 소울카드 SD 캐릭터 아이콘
class SoulCardAvatar extends StatelessWidget {
  final int soulCardNumber;
  final double size;

  const SoulCardAvatar({
    super.key,
    required this.soulCardNumber,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = soulCardAvatarPath(soulCardNumber);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.gold, width: 1.5),
        boxShadow: AppTheme.goldGlow,
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppTheme.backgroundCard,
            child: Center(
              child: Text(
                '$soulCardNumber',
                style: const TextStyle(
                  color: AppTheme.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
