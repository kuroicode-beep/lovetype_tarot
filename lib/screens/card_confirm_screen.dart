import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/reading_args.dart';
import '../models/tarot_card.dart';
import '../widgets/tarot_card_asset_image.dart';
import 'result_screen.dart';

class CardConfirmScreen extends StatelessWidget {
  final ReadingArgs args;

  const CardConfirmScreen({super.key, required this.args});

  static const _positions = ['과거', '현재', '미래'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A0F2E), AppTheme.backgroundDark],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // 헤더
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: AppTheme.textSecondary, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                      ),
                      Text(
                        args.topicLabel,
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    '뽑은 카드',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 24,
                        ),
                  ),
                  const SizedBox(height: 28),

                  // 카드 3장 가로 배열
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(args.cards.length, (i) {
                      final card = args.cards[i];
                      return _CardPreview(
                        card: card,
                        position: _positions[i],
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // 요약 정보
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummaryRow(
                          label: '주제',
                          value: args.topicLabel,
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: '키워드',
                          value: args.tags.map((t) => t).join('  '),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 이야기 보기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultScreen(args: args),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        foregroundColor: AppTheme.backgroundDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '이야기 보기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardPreview extends StatelessWidget {
  final TarotCard card;
  final String position;

  const _CardPreview({required this.card, required this.position});

  @override
  Widget build(BuildContext context) {
    final isReversed = card.isReversed;
    return Column(
      children: [
        // 카드 이미지
        Container(
          width: 88,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.gold.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: AppTheme.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Transform.rotate(
              angle: isReversed ? 3.14159 : 0,
              child: TarotCardAssetImage(
                card: card,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppTheme.backgroundCard,
                  child: Center(
                    child: Text(
                      card.nameKo,
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // 포지션 라벨
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            position,
            style: const TextStyle(
              color: AppTheme.gold,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // 카드 이름
        SizedBox(
          width: 90,
          child: Text(
            card.nameKo,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 2),
        // 정/역방향
        Text(
          isReversed ? '역방향' : '정방향',
          style: TextStyle(
            color: isReversed
                ? AppTheme.error.withValues(alpha: 0.8)
                : AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
