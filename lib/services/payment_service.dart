import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'iap_service.dart';
import 'storage_service.dart';

class PaymentService {
  PaymentService._();
  static final PaymentService instance = PaymentService._();

  final ValueNotifier<int> balanceNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> isSubscribedNotifier = ValueNotifier<bool>(false);

  void loadFromCache() {
    balanceNotifier.value = StorageService.instance.pointBalance;
    isSubscribedNotifier.value = StorageService.instance.isSubscribed;
  }

  String _userId(UserModel user) =>
      StorageService.instance.effectiveUserIdForHistory(user);

  int requiredPointsForTopic(String topic) {
    if (topic == 'romance') return 10;
    return 0;
  }

  Future<void> refreshBalance(UserModel user) async {
    final res = await ApiService.instance.get(
      AppConstants.paymentBalanceEndpoint,
      query: {'user_id': _userId(user), 'app_id': AppConstants.appId},
    );

    final data = (res['data'] is Map<String, dynamic>)
        ? res['data'] as Map<String, dynamic>
        : res;
    final balance = (data['balance'] as num?)?.toInt() ?? 0;
    final subscribed = data['is_subscribed'] as bool? ?? false;
    final expiresRaw = data['sub_expires']?.toString();
    final expiresAt = expiresRaw == null ? null : DateTime.tryParse(expiresRaw);

    balanceNotifier.value = balance;
    isSubscribedNotifier.value = subscribed;
    await StorageService.instance.setPointBalance(balance);
    await StorageService.instance.setIsSubscribed(subscribed);
    await StorageService.instance.setSubscriptionExpiresAt(expiresAt);
  }

  Future<void> charge(UserModel user, {required String productId}) async {
    final amount = productId == 'tarot_sub' ? 80 : 10;
    await ApiService.instance.postPaymentCharge({
      'app_id': AppConstants.appId,
      'user_id': _userId(user),
      'amount': amount,
      'product_id': productId,
    });
    await refreshBalance(user);
  }

  Future<bool> usePoints({
    required UserModel user,
    required int amount,
    required String reason,
  }) async {
    if (amount <= 0) return true;
    try {
      await ApiService.instance.postPaymentUse({
        'app_id': AppConstants.appId,
        'user_id': _userId(user),
        'amount': amount,
        'reason': reason,
      });
      await refreshBalance(user);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> ensureEnoughPoints(
    BuildContext context, {
    required UserModel user,
    required int requiredPoints,
  }) async {
    if (requiredPoints <= 0) return true;
    try {
      await refreshBalance(user);
    } catch (_) {
      loadFromCache();
    }
    if (balanceNotifier.value >= requiredPoints) return true;
    if (!context.mounted) return false;

    final purchased = await openChargeDialog(context, user: user);
    if (!purchased) return false;
    await refreshBalance(user);
    return balanceNotifier.value >= requiredPoints;
  }

  Future<bool> openChargeDialog(
    BuildContext context, {
    required UserModel user,
  }) async {
    final purchased =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.backgroundCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              '포인트가 부족해요',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            content: const Text(
              '이 기능은 10P가 필요합니다.\n충전 후 바로 계속할 수 있어요.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  '나중에',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await IapService.instance.init();
                  if (IapService.instance.storeAvailable) {
                    await IapService.instance.buy(
                      'tarot_10p',
                      user,
                      onSuccess: () async {
                        if (context.mounted) Navigator.pop(context, true);
                      },
                      onError: (message) async {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(message)));
                      },
                    );
                  } else {
                    await charge(user, productId: 'tarot_10p');
                    if (context.mounted) Navigator.pop(context, true);
                  }
                },
                child: const Text(
                  '1,000원 충전',
                  style: TextStyle(color: AppTheme.gold),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await IapService.instance.init();
                  if (IapService.instance.storeAvailable) {
                    await IapService.instance.buy(
                      'tarot_sub',
                      user,
                      onSuccess: () async {
                        if (context.mounted) Navigator.pop(context, true);
                      },
                      onError: (message) async {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(message)));
                      },
                    );
                  } else {
                    await charge(user, productId: 'tarot_sub');
                    if (context.mounted) Navigator.pop(context, true);
                  }
                },
                child: const Text(
                  '월 구독 4,900원',
                  style: TextStyle(color: AppTheme.gold),
                ),
              ),
            ],
          ),
        ) ??
        false;

    return purchased;
  }
}
