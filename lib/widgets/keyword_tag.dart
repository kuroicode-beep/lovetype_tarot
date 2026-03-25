import 'package:flutter/material.dart';
import '../core/theme.dart';

/// 키워드 선택 칩 위젯
class KeywordTag extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const KeywordTag({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.gold.withValues(alpha: 0.2)
              : AppTheme.backgroundCard,
          border: Border.all(
            color: isSelected ? AppTheme.gold : AppTheme.divider,
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? AppTheme.goldGlow : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.gold : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
