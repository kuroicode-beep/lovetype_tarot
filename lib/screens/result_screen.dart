import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../core/app_assets.dart';
import '../core/theme.dart';
import '../core/soul_card.dart';
import '../models/reading_args.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/history_sync_service.dart';
import '../services/notification_service.dart';
import '../services/payment_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../widgets/bottom_bar.dart';

class ResultScreen extends StatefulWidget {
  final ReadingArgs args;

  const ResultScreen({super.key, required this.args});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  String? _resultText;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSpeaking = false;
  bool _isSaved = false;
  bool _pointUsed = false;

  late AnimationController _loadingController;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _user = StorageService.instance.loadUser();
    _fetchResult();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _fetchResult() async {
    if (_user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = '사용자 정보를 불러올 수 없습니다.';
      });
      return;
    }

    try {
      final text = await ApiService.instance.tarotReading(
        user: _user!,
        topic: widget.args.topic,
        topicLabel: widget.args.topicLabel,
        tags: widget.args.tags,
        cards: widget.args.cards,
      );
      if (mounted) {
        setState(() {
          _resultText = text;
          _isLoading = false;
        });
        // v4.0: 결과 로딩 완료 후 서버 저장 (실패 시 history_pending)
        final synced = await HistorySyncService.instance.uploadReading(
          user: _user!,
          args: widget.args,
          story: text,
        );
        if (mounted) {
          setState(() => _isSaved = synced);
        }
        await _usePointsIfNeeded();
        await NotificationService.instance.scheduleCooldownUnlock(
          topic: widget.args.topic,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '이야기를 불러오는 중 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요.';
        });
      }
    }
  }

  Future<void> _usePointsIfNeeded() async {
    if (_pointUsed || _user == null) return;
    final amount = PaymentService.instance.requiredPointsForTopic(widget.args.topic);
    if (amount <= 0) {
      _pointUsed = true;
      return;
    }
    final ok = await PaymentService.instance.usePoints(
      user: _user!,
      amount: amount,
      reason: widget.args.topicLabel,
    );
    if (!mounted) return;
    _pointUsed = ok;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('포인트 차감에 실패했습니다. 잠시 후 다시 시도해 주세요.'),
          backgroundColor: AppTheme.backgroundCard,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggleTts() async {
    if (_resultText == null) return;
    if (_isSpeaking) {
      await TtsService.instance.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await TtsService.instance.init();
      await TtsService.instance.speak(_resultText!);
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  Future<void> _share() async {
    if (_resultText == null) return;
    final cardNames = widget.args.cards.map((c) => c.nameKo).join(', ');
    final shareText =
        '🎴 LoveType-Tarot\n\n${widget.args.topicLabel} · ${widget.args.tags.join(' ')}\n카드: $cardNames\n\n$_resultText';
    await Share.share(shareText);
  }

  Future<void> _save() async {
    if (_resultText == null || _user == null) return;
    if (_isSaved) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미 저장되었습니다'),
          backgroundColor: AppTheme.backgroundCard,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final ok = await HistorySyncService.instance.uploadReading(
      user: _user!,
      args: widget.args,
      story: _resultText!,
    );
    if (!mounted) return;
    setState(() => _isSaved = ok);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? '저장되었습니다' : '오프라인에 보관했습니다. 연결 시 자동으로 전송돼요.',
        ),
        backgroundColor: AppTheme.backgroundCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final soulNum = _user?.soulCardNumber ?? 1;
    final cardName = soulCardNames[soulNum] ?? '';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 배경
          _ResultBackground(),
          // 내용
          SafeArea(
            child: Column(
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
                      Text(
                        widget.args.topicLabel,
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // 소울카드 아바타
                _SoulAvatar(number: soulNum, name: cardName),
                const SizedBox(height: 16),

                // 결과 본문
                Expanded(
                  child: _isLoading
                      ? _LoadingView(controller: _loadingController)
                      : _errorMessage != null
                          ? _ErrorView(
                              message: _errorMessage!,
                              onRetry: () {
                                setState(() {
                                  _isLoading = true;
                                  _errorMessage = null;
                                });
                                _fetchResult();
                              },
                            )
                          : _ResultText(text: _resultText!),
                ),

                // 하단 액션 버튼 4개
                if (!_isLoading && _errorMessage == null)
                  _ActionBar(
                    isSpeaking: _isSpeaking,
                    isSaved: _isSaved,
                    onTts: _toggleTts,
                    onSave: _save,
                    onShare: _share,
                    onRestart: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/main',
                      (route) => false,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomBar(),
    );
  }
}

// ── 서브 위젯들 ────────────────────────────────────────────────

class _ResultBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.bgResult,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [Color(0xFF2A1040), AppTheme.backgroundDark],
          ),
        ),
      ),
    );
  }
}

class _SoulAvatar extends StatelessWidget {
  final int number;
  final String name;

  const _SoulAvatar({required this.number, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.gold, width: 2),
            boxShadow: AppTheme.goldGlow,
          ),
          child: ClipOval(
            child: Image.asset(
              soulCardAvatarPath(number),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppTheme.backgroundCard,
                child: Center(
                  child: Text(
                    '✨',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$name의 이야기',
          style: const TextStyle(
            color: AppTheme.gold,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  final AnimationController controller;
  const _LoadingView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: controller,
            child: const Text('🎴', style: TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 24),
          const Text(
            '카드가 이야기를 읽고 있어요...',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 8),
          const Text(
            '잠시만 기다려 주세요',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😔', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.gold),
                foregroundColor: AppTheme.gold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultText extends StatelessWidget {
  final String text;
  const _ResultText({required this.text});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.gold.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            height: 1.8,
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final bool isSpeaking;
  final bool isSaved;
  final VoidCallback onTts;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onRestart;

  const _ActionBar({
    required this.isSpeaking,
    required this.isSaved,
    required this.onTts,
    required this.onSave,
    required this.onShare,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard.withValues(alpha: 0.9),
        border: const Border(
          top: BorderSide(color: AppTheme.divider),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionBtn(
            icon: isSpeaking ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
            label: isSpeaking ? '멈추기' : '듣기',
            onTap: onTts,
            isActive: isSpeaking,
          ),
          _ActionBtn(
            icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
            label: '저장',
            onTap: onSave,
            isActive: isSaved,
          ),
          _ActionBtn(
            icon: Icons.ios_share_outlined,
            label: '공유',
            onTap: onShare,
          ),
          _ActionBtn(
            icon: Icons.refresh,
            label: '다른 이야기',
            onTap: onRestart,
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.gold : AppTheme.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.gold : AppTheme.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
