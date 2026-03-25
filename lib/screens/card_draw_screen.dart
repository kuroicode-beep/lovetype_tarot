import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/card_data.dart';
import '../models/tarot_card.dart';
import '../widgets/tarot_card_asset_image.dart';
import '../models/reading_args.dart';
import 'card_confirm_screen.dart';

class CardDrawScreen extends StatefulWidget {
  final ReadingArgs args;

  const CardDrawScreen({super.key, required this.args});

  @override
  State<CardDrawScreen> createState() => _CardDrawScreenState();
}

class _CardDrawScreenState extends State<CardDrawScreen>
    with TickerProviderStateMixin {
  static const int _displayCount = 7;

  late List<TarotCard> _deck;
  late List<AnimationController> _flipControllers;
  late List<Animation<double>> _flipAnims;

  // 선택 상태: 카드 인덱스 → 순서(1~3)
  final Map<int, int> _selectionOrder = {};
  int _nextOrder = 1;

  @override
  void initState() {
    super.initState();
    final rng = Random();

    // 78장 셔플 후 7장 선택
    final shuffled = List<TarotCard>.from(allTarotCards)..shuffle(rng);
    _deck = shuffled.take(_displayCount).toList();

    // 각 카드에 랜덤 정/역방향 적용
    _deck = _deck.map((c) {
      return rng.nextBool() ? c.copyWith(isReversed: true) : c;
    }).toList();

    // 카드별 AnimationController 초기화
    _flipControllers = List.generate(
      _displayCount,
      (_) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    _flipAnims = _flipControllers.map((c) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _flipControllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _canSelect => _selectionOrder.length < 3;

  void _onCardTap(int index) {
    if (_selectionOrder.containsKey(index)) {
      // 선택 해제
      final removedOrder = _selectionOrder[index]!;
      setState(() {
        _selectionOrder.remove(index);
        // 이후 순서 조정
        final toAdjust = _selectionOrder.entries
            .where((e) => e.value > removedOrder)
            .toList();
        for (final e in toAdjust) {
          _selectionOrder[e.key] = e.value - 1;
        }
        _nextOrder = _selectionOrder.isEmpty
            ? 1
            : _selectionOrder.values.reduce(max) + 1;
      });
      _flipControllers[index].reverse();
    } else if (_canSelect) {
      // 카드 선택
      setState(() {
        _selectionOrder[index] = _nextOrder++;
      });
      _flipControllers[index].forward();
    }
  }

  void _goToConfirm() {
    // 선택 순서대로 카드 정렬
    final sorted = _selectionOrder.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final selectedCards = sorted.map((e) => _deck[e.key]).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardConfirmScreen(
          args: widget.args.copyWith(cards: selectedCards),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectionOrder.length;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF180D2E), AppTheme.backgroundDark],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: AppTheme.textSecondary, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                      ),
                      const Spacer(),
                      // 선택 카운터
                      _SelectionCounter(selected: selectedCount),
                    ],
                  ),
                ),

                // 안내 텍스트
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '마음이 끌리는 카드를\n한 장씩 선택하세요',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 24,
                                  height: 1.35,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${3 - selectedCount}장 더 선택할 수 있어요',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 카드 가로 스크롤
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _displayCount,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return _FlippableCard(
                        card: _deck[index],
                        animation: _flipAnims[index],
                        selectionOrder: _selectionOrder[index],
                        isSelectable:
                            _selectionOrder.containsKey(index) || _canSelect,
                        onTap: () => _onCardTap(index),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),

                // 카드 확인하기 버튼
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                          selectedCount == 3 ? _goToConfirm : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selectedCount == 3 ? AppTheme.gold : AppTheme.divider,
                        foregroundColor: selectedCount == 3
                            ? AppTheme.backgroundDark
                            : AppTheme.textMuted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '카드 확인하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 카드 플립 위젯
class _FlippableCard extends StatelessWidget {
  final TarotCard card;
  final Animation<double> animation;
  final int? selectionOrder; // null = 미선택
  final bool isSelectable;
  final VoidCallback onTap;

  static const double _cardW = 130;
  static const double _cardH = 210;

  const _FlippableCard({
    required this.card,
    required this.animation,
    required this.selectionOrder,
    required this.isSelectable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSelectable ? onTap : null,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final value = animation.value;
          final isShowingFront = value >= 0.5;
          final rotateY = isShowingFront ? -(1 - value) * pi : value * pi;

          return Stack(
            alignment: Alignment.center,
            children: [
              // 카드 본체 (flip transform)
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(rotateY),
                child: Opacity(
                  opacity: isSelectable ? 1.0 : 0.4,
                  child: isShowingFront
                      ? _CardFront(card: card)
                      : const _CardBack(),
                ),
              ),

              // 선택 순서 뱃지
              if (selectionOrder != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: _OrderBadge(order: selectionOrder!),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _FlippableCard._cardW,
      height: _FlippableCard._cardH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D1B4E), Color(0xFF1A1028)],
        ),
        border: Border.all(
          color: AppTheme.lavender.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lavenderDark.withValues(alpha: 0.3),
            blurRadius: 12,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎴', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 1,
              color: AppTheme.lavender.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'Tarot',
              style: TextStyle(
                color: AppTheme.lavender.withValues(alpha: 0.5),
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  final TarotCard card;
  const _CardFront({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _FlippableCard._cardW,
      height: _FlippableCard._cardH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
          child: Transform.rotate(
            angle: card.isReversed ? pi : 0,
            child: TarotCardAssetImage(
              card: card,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _CardFrontPlaceholder(card: card),
            ),
          ),
      ),
    );
  }
}

class _CardFrontPlaceholder extends StatelessWidget {
  final TarotCard card;
  const _CardFrontPlaceholder({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundCard,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.isReversed ? '🔄' : '✨',
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              card.nameKo,
              style: const TextStyle(
                color: AppTheme.gold,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (card.isReversed)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                '역방향',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderBadge extends StatelessWidget {
  final int order;
  const _OrderBadge({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppTheme.gold,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.5),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$order',
          style: const TextStyle(
            color: AppTheme.backgroundDark,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SelectionCounter extends StatelessWidget {
  final int selected;
  const _SelectionCounter({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final filled = i < selected;
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? AppTheme.gold : Colors.transparent,
              border: Border.all(
                color: filled ? AppTheme.gold : AppTheme.divider,
                width: 1.5,
              ),
            ),
          ),
        );
      }),
    );
  }
}
