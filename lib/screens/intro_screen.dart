import 'package:flutter/material.dart';
import '../core/app_assets.dart';
import '../core/theme.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 배경 이미지 (placeholder → 실제 이미지 추가 시 자동 반영)
          _BackgroundImage(),
          // 어두운 오버레이
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.backgroundDark.withValues(alpha: 0.3),
                  AppTheme.backgroundDark.withValues(alpha: 0.85),
                  AppTheme.backgroundDark,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // 콘텐츠
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  // 앱 로고 + 이름
                  const Text('🎴', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    'LoveType-Tarot',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppTheme.gold,
                          letterSpacing: 1.5,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '당신의 소울이 이야기를 시작합니다',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.lavender,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 2),
                  // Google 로그인 버튼
                  _IntroButton(
                    icon: Icons.g_mobiledata,
                    label: 'Google로 시작하기',
                    isPrimary: true,
                    onTap: () =>
                        Navigator.pushNamed(context, '/info-input'),
                  ),
                  const SizedBox(height: 12),
                  // 전화번호 버튼
                  _IntroButton(
                    icon: Icons.phone_outlined,
                    label: '전화번호로 시작하기',
                    isPrimary: false,
                    onTap: () =>
                        Navigator.pushNamed(context, '/info-input'),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.bgIntro,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              Color(0xFF2D1B4E),
              Color(0xFF1A1028),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 별빛 효과 (placeholder)
            ...List.generate(20, (i) {
              final x = (i * 47 % 100) / 100.0;
              final y = (i * 31 % 80) / 100.0;
              final size = (i % 3 + 1).toDouble();
              return Positioned(
                left: MediaQuery.of(context).size.width * x,
                top: MediaQuery.of(context).size.height * y,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: AppTheme.lavender
                        .withValues(alpha: 0.3 + (i % 5) * 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _IntroButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _IntroButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 22),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
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
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 20, color: AppTheme.textSecondary),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.divider),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
    );
  }
}
