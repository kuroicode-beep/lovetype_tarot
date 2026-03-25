import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/reading_args.dart';
import '../widgets/bottom_bar.dart';
import 'card_draw_screen.dart';

class KeywordScreen extends StatefulWidget {
  const KeywordScreen({super.key});

  @override
  State<KeywordScreen> createState() => _KeywordScreenState();
}

class _KeywordScreenState extends State<KeywordScreen> {
  static const _allTags = [
    '#재회', '#만남', '#이별', '#썸', '#짝사랑', '#현재연애',
    '#고백', '#권태기', '#외로움', '#새출발',
  ];

  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ReadingArgs?;
    final topicLabel = args?.topicLabel ?? '타로 이야기';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E0F35), AppTheme.backgroundDark],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // 헤더
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: AppTheme.textSecondary, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        topicLabel,
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '어떤 이야기가\n궁금하세요?',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 26,
                          height: 1.3,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '관련된 키워드를 선택해 주세요',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 태그 Wrap
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _allTags.map((tag) {
                      final isSelected = _selected.contains(tag);
                      return _TagChip(
                        label: tag,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selected.remove(tag);
                            } else {
                              _selected.add(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const Spacer(),

                  // 선택 상태 안내
                  if (_selected.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '${_selected.length}개 선택됨',
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontSize: 13,
                        ),
                      ),
                    ),

                  // 카드 뽑으러 가기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _selected.isEmpty
                          ? null
                          : () => _goToCardDraw(context, args),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selected.isEmpty
                            ? AppTheme.divider
                            : AppTheme.gold,
                        foregroundColor: _selected.isEmpty
                            ? AppTheme.textMuted
                            : AppTheme.backgroundDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '카드 뽑으러 가기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomBar(),
    );
  }

  void _goToCardDraw(BuildContext context, ReadingArgs? args) {
    final nextArgs = (args ?? const ReadingArgs(topic: 'daily', topicLabel: '타로 이야기'))
        .copyWith(tags: _selected.toList());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardDrawScreen(args: nextArgs),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.gold.withValues(alpha: 0.18)
              : AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppTheme.gold : AppTheme.divider,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.gold.withValues(alpha: 0.2),
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.gold : AppTheme.textSecondary,
            fontSize: 14,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
