import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/soul_card.dart';
import '../models/user_model.dart';

class SoulCardScreen extends StatefulWidget {
  final UserModel user;

  const SoulCardScreen({super.key, required this.user});

  @override
  State<SoulCardScreen> createState() => _SoulCardScreenState();
}

class _SoulCardScreenState extends State<SoulCardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );
    _slideAnim = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // 약간의 딜레이 후 애니메이션 시작
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToMain() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final cardName = soulCardNames[user.soulCardNumber] ?? '';
    final description = soulCardDescriptions[user.soulCardNumber] ?? '';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 배경 그라디언트
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.0,
                colors: [Color(0xFF2D1B4E), AppTheme.backgroundDark],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // 소울카드 캐릭터 (fade + scale 애니메이션)
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: _SoulCardImage(number: user.soulCardNumber),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // 텍스트 (slide-up + fade 애니메이션)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnim.value,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnim.value),
                          child: Column(
                            children: [
                              // 닉네임 호칭
                              Text(
                                '${user.nickname}님,',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              // 소울카드 이름
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(fontSize: 26),
                                  children: [
                                    const TextSpan(text: '당신은 '),
                                    TextSpan(
                                      text: cardName,
                                      style: const TextStyle(
                                        color: AppTheme.gold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: '의\n소울과 함께합니다.'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // 설명
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundCard
                                      .withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color:
                                        AppTheme.gold.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  description,
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 2),

                  // 하단 버튼
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _goToMain,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.gold,
                          foregroundColor: AppTheme.backgroundDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '타로를 시작할게요',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoulCardImage extends StatelessWidget {
  final int number;
  const _SoulCardImage({required this.number});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      soulCardImagePath(number),
      height: 260,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 260,
        width: 200,
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.gold.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '✨',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              soulCardNames[number] ?? '',
              style: const TextStyle(
                color: AppTheme.gold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No.$number',
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
