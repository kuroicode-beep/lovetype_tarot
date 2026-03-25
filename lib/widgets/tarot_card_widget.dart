import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/tarot_card.dart';
import 'tarot_card_asset_image.dart';

/// 타로 카드 위젯 (앞/뒤면, 정/역방향 표시)
class TarotCardWidget extends StatelessWidget {
  final TarotCard card;
  final bool showFront;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const TarotCardWidget({
    super.key,
    required this.card,
    this.showFront = true,
    this.width = 100,
    this.height = 160,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: (showFront && card.isReversed) ? 3.14159 : 0,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: AppTheme.cardShadow,
            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: showFront
                ? TarotCardAssetImage(
                    card: card,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _CardBack(
                      label: card.nameKo,
                    ),
                  )
                : const _CardBack(),
          ),
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final String? label;
  const _CardBack({this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundCard,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎴', style: TextStyle(fontSize: 32)),
            if (label != null) ...[
              const SizedBox(height: 8),
              Text(
                label!,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
