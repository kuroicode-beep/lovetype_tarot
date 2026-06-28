import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/user_model.dart';
import '../models/reading_args.dart';
import '../services/api_service.dart';
import '../services/payment_service.dart';
import '../services/storage_service.dart';
import '../widgets/bottom_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  UserModel? _user;
  Timer? _timer;
  // 쿨타임 남은 시간 (null = 가능)
  Duration? _dailyCooldown;
  Duration? _romanceCooldown;
  DateTime? _dailyNextAvailableAt;
  DateTime? _romanceNextAvailableAt;
  bool _cooldownLoading = false;
  String? _cooldownErrorMessage;

  @override
  void initState() {
    super.initState();
    _user = StorageService.instance.loadUser();
    PaymentService.instance.loadFromCache();
    if (_user != null) {
      PaymentService.instance.refreshBalance(_user!).catchError((_) {});
    }
    unawaited(_loadServerCooldowns());
    // 1초마다 카운터 갱신
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickCooldowns();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadServerCooldowns() async {
    final user = _user;
    if (user == null) return;
    if (mounted) {
      setState(() {
        _cooldownLoading = true;
        _cooldownErrorMessage = null;
      });
    }
    try {
      final results = await Future.wait([
        ApiService.instance.getReadingCooltime(user: user, topic: 'daily'),
        ApiService.instance.getReadingCooltime(user: user, topic: 'romance'),
      ]);
      if (!mounted) return;
      setState(() {
        _dailyNextAvailableAt = results[0].nextAvailableAt;
        _romanceNextAvailableAt = results[1].nextAvailableAt;
        _cooldownLoading = false;
        _cooldownErrorMessage = null;
      });
      _tickCooldowns();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cooldownLoading = false;
        _cooldownErrorMessage = '서버 쿨타임을 확인할 수 없습니다.';
        _dailyCooldown = null;
        _romanceCooldown = null;
      });
    }
  }

  void _tickCooldowns() {
    final daily = _remainingUntil(_dailyNextAvailableAt);
    final romance = _remainingUntil(_romanceNextAvailableAt);
    if (mounted) {
      setState(() {
        _dailyCooldown = daily;
        _romanceCooldown = romance;
        if (daily == null) _dailyNextAvailableAt = null;
        if (romance == null) _romanceNextAvailableAt = null;
      });
    }
  }

  Duration? _remainingUntil(DateTime? nextAvailableAt) {
    if (nextAvailableAt == null) return null;
    final remaining = nextAvailableAt.toLocal().difference(DateTime.now());
    return remaining.isNegative || remaining == Duration.zero
        ? null
        : remaining;
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  Future<void> _onReadingTap(String topic, String route) async {
    final user = _user;
    if (user == null) return;

    final canRead = await _refreshTopicCooldown(topic, showDialogOnLock: true);
    if (!mounted || !canRead) return;

    if (_cooldownErrorMessage != null) {
      _showCooldownCheckFailedDialog();
      return;
    }

    final isDaily = topic == 'daily';
    final requiredPoints = PaymentService.instance.requiredPointsForTopic(
      topic,
    );
    final canProceed = await PaymentService.instance.ensureEnoughPoints(
      context,
      user: user,
      requiredPoints: requiredPoints,
    );
    if (!mounted) return;
    if (!canProceed) return;

    await Navigator.pushNamed(
      context,
      route,
      arguments: ReadingArgs(
        topic: topic,
        topicLabel: isDaily ? '오늘의 이야기' : '연애 이야기',
      ),
    );
    if (mounted) unawaited(_loadServerCooldowns());
  }

  Future<bool> _refreshTopicCooldown(
    String topic, {
    required bool showDialogOnLock,
  }) async {
    final user = _user;
    if (user == null) return false;
    setState(() {
      _cooldownLoading = true;
      _cooldownErrorMessage = null;
    });
    try {
      final status = await ApiService.instance.getReadingCooltime(
        user: user,
        topic: topic,
      );
      if (!mounted) return false;
      setState(() {
        if (topic == 'romance') {
          _romanceNextAvailableAt = status.nextAvailableAt;
        } else {
          _dailyNextAvailableAt = status.nextAvailableAt;
        }
        _cooldownLoading = false;
      });
      _tickCooldowns();
      if (!status.isAvailable) {
        if (showDialogOnLock) {
          _showCooldownLockedDialog(status.message);
        }
        return false;
      }
      return true;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _cooldownLoading = false;
        _cooldownErrorMessage = '서버 쿨타임을 확인할 수 없습니다.';
      });
      _showCooldownCheckFailedDialog();
      return false;
    }
  }

  void _showCooldownLockedDialog(String? message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '잠깐만요',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          message ?? '타로 카드의 특성상 연속해서 볼 경우\n정확하지 않은 결과가 나올 수 있습니다.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('알겠어요', style: TextStyle(color: AppTheme.gold)),
          ),
        ],
      ),
    );
  }

  void _showCooldownCheckFailedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '확인이 필요해요',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          '서버 쿨타임을 확인하지 못했습니다.\n잠시 후 다시 시도해 주세요.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('알겠어요', style: TextStyle(color: AppTheme.gold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nickname = _user?.nickname ?? '타로유저';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 배경 그라디언트
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
                  const SizedBox(height: 32),
                  // 인사 텍스트
                  Text(
                    '안녕하세요, $nickname님 👋',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '오늘은 어떤 이야기가\n궁금하세요?',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 오늘의 이야기 버튼
                  _ReadingButton(
                    emoji: '🌙',
                    title: '오늘의 이야기',
                    cooldown: _dailyCooldown,
                    isChecking: _cooldownLoading,
                    statusError: _cooldownErrorMessage,
                    onTap: () => _onReadingTap('daily', '/keyword'),
                    formatDuration: _formatDuration,
                  ),
                  const SizedBox(height: 16),

                  // 연애 이야기 버튼
                  _ReadingButton(
                    emoji: '💕',
                    title: '연애 이야기',
                    cooldown: _romanceCooldown,
                    isChecking: _cooldownLoading,
                    statusError: _cooldownErrorMessage,
                    onTap: () => _onReadingTap('romance', '/keyword'),
                    formatDuration: _formatDuration,
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomBar(),
    );
  }
}

class _ReadingButton extends StatelessWidget {
  final String emoji;
  final String title;
  final Duration? cooldown;
  final bool isChecking;
  final String? statusError;
  final VoidCallback onTap;
  final String Function(Duration) formatDuration;

  const _ReadingButton({
    required this.emoji,
    required this.title,
    required this.cooldown,
    required this.isChecking,
    required this.statusError,
    required this.onTap,
    required this.formatDuration,
  });

  bool get _isActive => cooldown == null && statusError == null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isActive
              ? AppTheme.backgroundCard
              : AppTheme.backgroundCard.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isActive
                ? AppTheme.gold.withValues(alpha: 0.6)
                : AppTheme.divider,
            width: _isActive ? 1.5 : 1.0,
          ),
          boxShadow: _isActive
              ? [
                  BoxShadow(
                    color: AppTheme.gold.withValues(alpha: 0.12),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _isActive
                          ? AppTheme.textPrimary
                          : AppTheme.textMuted,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  isChecking
                      ? const Text(
                          '서버 상태 확인 중...',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        )
                      : statusError != null
                      ? Text(
                          statusError!,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        )
                      : _isActive
                      ? const Text(
                          '카드를 뽑을 수 있어요',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        )
                      : Row(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${formatDuration(cooldown!)} 후 가능',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            Icon(
              _isActive ? Icons.arrow_forward_ios : Icons.lock_outline,
              color: _isActive ? AppTheme.gold : AppTheme.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
