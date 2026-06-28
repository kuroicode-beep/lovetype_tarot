import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../core/constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'payment_service.dart';
import 'storage_service.dart';

/// v5.2: 스토어 실결제 → 영수증을 Railway `POST /payment/charge`로 전달
class IapService {
  IapService._();
  static final IapService instance = IapService._();

  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool _initialized = false;
  bool storeAvailable = false;

  /// 진행 중 구매에 대응할 사용자 (단일 플로우)
  UserModel? _pendingUser;
  String? _pendingProductId;
  Future<void> Function()? _onSuccess;
  Future<void> Function(String message)? _onError;

  static const Map<String, IapProductConfig> products = {
    'tarot_10p': IapProductConfig.consumable(
      id: 'tarot_10p',
      title: '10P 충전',
      credits: 10,
      displayPrice: '1,000원',
    ),
    'tarot_1': IapProductConfig.consumable(
      id: 'tarot_1',
      title: '1P 충전',
      credits: 1,
      displayPrice: '100원',
    ),
    'tarot_6': IapProductConfig.consumable(
      id: 'tarot_6',
      title: '6P 충전',
      credits: 6,
      displayPrice: '600원',
    ),
    'tarot_13': IapProductConfig.consumable(
      id: 'tarot_13',
      title: '13P 충전',
      credits: 13,
      displayPrice: '1,300원',
    ),
    'tarot_40': IapProductConfig.consumable(
      id: 'tarot_40',
      title: '40P 충전',
      credits: 40,
      displayPrice: '4,000원',
    ),
    'tarot_sub': IapProductConfig.subscription(
      id: 'tarot_sub',
      title: '월 구독',
      displayPrice: '4,900원',
    ),
  };

  static Set<String> get productIds => products.keys.toSet();

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    storeAvailable = await InAppPurchase.instance.isAvailable();
    if (!storeAvailable) {
      debugPrint('[IapService] 스토어 사용 불가(에뮬레이터 등)');
      return;
    }
    _sub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object e, StackTrace st) =>
          debugPrint('[IapService] stream $e'),
    );
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<List<ProductDetails>> loadProducts() async {
    if (!storeAvailable) return [];
    final response = await InAppPurchase.instance.queryProductDetails(
      productIds,
    );
    if (response.error != null) {
      debugPrint('[IapService] query: ${response.error}');
    }
    return response.productDetails;
  }

  /// 소모품(10P) / 구독(tarot_sub) 구매 시작
  /// [onSuccess]: 서버 반영·잔액 갱신 후 호출 (예: 다이얼로그 닫기)
  Future<bool> buy(
    String productId,
    UserModel user, {
    Future<void> Function()? onSuccess,
    Future<void> Function(String message)? onError,
  }) async {
    if (!storeAvailable) return false;
    _pendingUser = user;
    _pendingProductId = productId;
    _onSuccess = onSuccess;
    _onError = onError;
    final response = await InAppPurchase.instance.queryProductDetails({
      productId,
    });
    if (response.productDetails.isEmpty) {
      debugPrint('[IapService] 상품 없음: $productId');
      await _notifyFailure('스토어에서 상품을 찾지 못했습니다.');
      _clearPending();
      return false;
    }
    final product = response.productDetails.first;
    final param = PurchaseParam(productDetails: product);
    try {
      if (productId == 'tarot_sub') {
        return await InAppPurchase.instance.buyNonConsumable(
          purchaseParam: param,
        );
      }
      return await InAppPurchase.instance.buyConsumable(purchaseParam: param);
    } catch (e) {
      debugPrint('[IapService] buy error: $e');
      await _notifyFailure('결제 시작에 실패했습니다. 잠시 후 다시 시도해 주세요.');
      _clearPending();
      return false;
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    final user = _pendingUser;
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) continue;

      if (purchase.status == PurchaseStatus.error) {
        debugPrint('[IapService] ${purchase.error}');
        await _notifyFailure('결제 처리 중 오류가 발생했습니다.');
        _clearPending();
        continue;
      }

      if (purchase.status == PurchaseStatus.canceled) {
        _clearPending();
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.restored) {
        // 복원은 구독만 의미 있음 — 서버 중복 충전 방지 위해 구독만 처리
        if (purchase.productID == 'tarot_sub' && user != null) {
          await _sendReceiptToBackend(purchase, user, notifySuccess: false);
        }
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased && user != null) {
        await _sendReceiptToBackend(purchase, user, notifySuccess: true);
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
      }

      _clearPending();
    }
  }

  Future<void> _sendReceiptToBackend(
    PurchaseDetails purchase,
    UserModel user, {
    bool notifySuccess = true,
  }) async {
    final receipt = purchase.verificationData.serverVerificationData;
    if (receipt.isEmpty) {
      debugPrint('[IapService] serverVerificationData 비어 있음');
    }
    try {
      final config =
          products[purchase.productID] ?? products[_pendingProductId];
      await ApiService.instance.postPaymentCharge({
        'app_id': AppConstants.appId,
        'user_id': StorageService.instance.effectiveUserIdForHistory(user),
        'product_id': purchase.productID,
        'receipt': receipt,
        'amount': config?.credits ?? 0,
        'product_type': config?.type.name ?? 'unknown',
        'platform': defaultTargetPlatform.name,
        'transaction_id': purchase.purchaseID,
        'source': 'in_app_purchase',
      });
      await PaymentService.instance.refreshBalance(user);
      if (notifySuccess) {
        final cb = _onSuccess;
        _onSuccess = null;
        if (cb != null) await cb();
      }
    } catch (e) {
      debugPrint('[IapService] charge API 실패: $e');
      await _notifyFailure('결제 검증에 실패했습니다. 잠시 후 다시 시도해 주세요.');
    }
  }

  Future<void> restorePurchases(UserModel user) async {
    _pendingUser = user;
    _pendingProductId = 'tarot_sub';
    await InAppPurchase.instance.restorePurchases();
  }

  void _clearPending() {
    _pendingUser = null;
    _pendingProductId = null;
    _onSuccess = null;
    _onError = null;
  }

  Future<void> _notifyFailure(String message) async {
    final cb = _onError;
    if (cb != null) {
      await cb(message);
    }
  }
}

enum IapProductType { consumable, subscription }

class IapProductConfig {
  final String id;
  final String title;
  final int credits;
  final String displayPrice;
  final IapProductType type;

  const IapProductConfig._({
    required this.id,
    required this.title,
    required this.credits,
    required this.displayPrice,
    required this.type,
  });

  const IapProductConfig.consumable({
    required String id,
    required String title,
    required int credits,
    required String displayPrice,
  }) : this._(
         id: id,
         title: title,
         credits: credits,
         displayPrice: displayPrice,
         type: IapProductType.consumable,
       );

  const IapProductConfig.subscription({
    required String id,
    required String title,
    required String displayPrice,
  }) : this._(
         id: id,
         title: title,
         credits: 0,
         displayPrice: displayPrice,
         type: IapProductType.subscription,
       );
}
