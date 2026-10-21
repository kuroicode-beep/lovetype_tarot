import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';
import '../services/iap_service.dart';
import '../core/app_state.dart';
import '../services/notification_service.dart';
import '../services/payment_service.dart';
import '../services/storage_service.dart';
import 'soul_card_avatar.dart';

/// 앱 하단 고정 바
///
/// 구성 (좌 → 우):
/// [SD 아바타 아이콘] [닉네임] [💎 캐시] [⚙️ 설정] [🌗 고대비]
class AppBottomBar extends StatefulWidget {
  const AppBottomBar({super.key});

  @override
  State<AppBottomBar> createState() => _AppBottomBarState();
}

class _AppBottomBarState extends State<AppBottomBar> {
  bool _pushEnabled = true;

  @override
  void initState() {
    super.initState();
    _pushEnabled = StorageService.instance.pushEnabled;
    PaymentService.instance.loadFromCache();
    final user = StorageService.instance.loadUser();
    if (user != null) {
      PaymentService.instance.refreshBalance(user).catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = StorageService.instance.loadUser();
    final soulCardNumber = user?.soulCardNumber ?? 1;
    final nickname = user?.nickname ?? '타로유저';
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        border: const Border(
          top: BorderSide(color: AppTheme.divider, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // SD 아바타 (소울카드 번호로 자동 매핑)
            SoulCardAvatar(soulCardNumber: soulCardNumber),
            const SizedBox(width: 10),

            // 닉네임
            Text(
              '$nickname · v${AppConstants.appVersion}',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            // 💎 캐시
            ValueListenableBuilder<int>(
              valueListenable: PaymentService.instance.balanceNotifier,
              builder: (context, balance, _) {
                return _BottomBarButton(
                  label: '💎 $balance',
                  onTap: () async {
                    final currentUser = StorageService.instance.loadUser();
                    if (currentUser == null) return;
                    await PaymentService.instance.openChargeDialog(
                      context,
                      user: currentUser,
                    );
                  },
                );
              },
            ),
            const SizedBox(width: 4),

            // ⚙️ 설정
            _BottomBarIconButton(
              icon: Icons.settings_outlined,
              tooltip: '설정',
              onTap: _showSettingsDialog,
            ),
            const SizedBox(width: 4),

            // 🌗 고대비 토글 (앱 레벨 연동)
            _HighContrastToggle(),
          ],
        ),
      ),
    );
  }

  Future<void> _showSettingsDialog() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) {
        bool localPushEnabled = _pushEnabled;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.backgroundCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                '설정',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      value: localPushEnabled,
                      onChanged: (v) => setState(() => localPushEnabled = v),
                      title: const Text(
                        '알림 받기',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      subtitle: const Text(
                        '오늘의 타로/쿨타임 알림',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      activeThumbColor: AppTheme.gold,
                    ),
                    TextButton(
                      onPressed: () async {
                        final user = StorageService.instance.loadUser();
                        if (user == null) return;
                        await IapService.instance.restorePurchases(user);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('구매 내역 확인을 요청했어요.')),
                          );
                        }
                      },
                      child: const Text('구매 복원'),
                    ),
                    TextButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('업데이트 히스토리'),
                          content: Text(
                            AppConstants.versionHistory
                                .map((v) => 'v${v.$1} · ${v.$2}\n${v.$3}')
                                .join('\n\n'),
                          ),
                        ),
                      ),
                      child: const Text('업데이트 히스토리'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await AuthService.instance.signOut();
                        PaymentService.instance.loadFromCache();
                        if (context.mounted) {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/', (_) => false);
                        }
                      },
                      child: const Text('로그아웃'),
                    ),
                    TextButton(
                      onPressed: () => showLicensePage(
                        context: context,
                        applicationName: 'LoveType Tarot',
                        applicationVersion: AppConstants.appVersion,
                      ),
                      child: const Text('오픈소스 라이선스'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    '취소',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await StorageService.instance.setPushEnabled(
                      localPushEnabled,
                    );
                    await NotificationService.instance.onPushPreferenceChanged(
                      localPushEnabled,
                      StorageService.instance.loadUser(),
                    );
                    if (context.mounted) Navigator.pop(context, true);
                  },
                  child: const Text(
                    '저장',
                    style: TextStyle(color: AppTheme.gold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    if (changed == true && mounted) {
      setState(() {
        _pushEnabled = StorageService.instance.pushEnabled;
      });
    }
  }
}

class _BottomBarButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _BottomBarButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.gold,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _BottomBarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _BottomBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: AppTheme.textSecondary, size: 22),
        onPressed: onTap,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }
}

/// 고대비 토글 — AppState.instance.highContrast 와 연동
class _HighContrastToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppState.instance.highContrast,
      builder: (context, isHighContrast, child) {
        return Tooltip(
          message: isHighContrast ? '일반 모드' : '고대비 모드',
          child: IconButton(
            icon: Icon(
              isHighContrast
                  ? Icons.contrast
                  : Icons.brightness_medium_outlined,
              color: isHighContrast
                  ? AppTheme.goldLight
                  : AppTheme.textSecondary,
              size: 22,
            ),
            onPressed: () => AppState.instance.toggleHighContrast(),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        );
      },
    );
  }
}
