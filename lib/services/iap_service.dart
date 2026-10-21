import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../core/constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'payment_service.dart';
import 'storage_service.dart';
import 'purchase_recovery.dart';

/// v5.2: 스토어 실결제 → 영수증을 Railway `POST /payment/charge`로 전달
class IapService {
  IapService._();
  static final IapService instance = IapService._();

  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool _initialized = false;
  Future<void>? _initializing;
  bool storeAvailable = false;

  /// 진행 중 구매에 대응할 사용자 (단일 플로우)
  bool _buying = false;
  String? _pendingProductId;
  Future<void> Function()? _onSuccess;
  Future<void> Function(String message)? _onError;
  static const _secure = FlutterSecureStorage();
  late final PurchaseRecovery _recovery = PurchaseRecovery(
    read: () => _secure.read(key: 'pending_store_receipts'),
    write: (value) =>
        _secure.write(key: 'pending_store_receipts', value: value),
    send: ApiService.instance.postPaymentCharge,
  );

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

  Future<void> init() =>
      _initializing ??= _init().whenComplete(() => _initializing = null);

  Future<void> _init() async {
    if (_initialized) return;
    await _sub?.cancel();
    _sub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object e, StackTrace st) =>
          debugPrint('[IapService] stream $e'),
    );
    storeAvailable = await InAppPurchase.instance.isAvailable();
    _initialized = true;
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    _initialized = false;
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
    if (!storeAvailable || _buying) return false;
    _buying = true;
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
    final uid = StorageService.instance.effectiveUserIdForHistory(user);
    final param = PurchaseParam(
      productDetails: product,
      applicationUserName: sha256.convert(utf8.encode(uid)).toString(),
    );
    try {
      if (productId == 'tarot_sub') {
        final started = await InAppPurchase.instance.buyNonConsumable(
          purchaseParam: param,
        );
        if (!started) _clearPending();
        return started;
      }
      final started = await InAppPurchase.instance.buyConsumable(
        purchaseParam: param,
        autoConsume: false,
      );
      if (!started) _clearPending();
      return started;
    } catch (e) {
      debugPrint('[IapService] buy error: $e');
      await _notifyFailure('결제 시작에 실패했습니다. 잠시 후 다시 시도해 주세요.');
      _clearPending();
      return false;
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    final user = StorageService.instance.loadUser();
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
        if (purchase.pendingCompletePurchase &&
            defaultTargetPlatform != TargetPlatform.android) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.restored) {
        // 복원 거래도 서버의 영수증 고유 키로 중복 지급 없이 처리한다.
        if (user != null && StorageService.instance.googleUserId != null) {
          await _sendReceiptToBackend(purchase, user, notifySuccess: false);
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased &&
          user != null &&
          StorageService.instance.googleUserId != null) {
        await _sendReceiptToBackend(purchase, user, notifySuccess: true);
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
      final granted = await _recovery.process(
        {
          'app_id': AppConstants.appId,
          'user_id': StorageService.instance.effectiveUserIdForHistory(user),
          'product_id': purchase.productID,
          'receipt': receipt,
          'amount': config?.credits ?? 0,
          'product_type': config?.type.name ?? 'unknown',
          'platform': defaultTargetPlatform.name,
          'transaction_id': purchase.purchaseID,
          'source': 'in_app_purchase',
        },
        complete: () async {
          if (purchase.pendingCompletePurchase &&
              defaultTargetPlatform != TargetPlatform.android) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
        },
      );
      if (!granted) {
        await _notifyFailure('결제 확인을 기다리고 있어요. 영수증은 보관되며 다시 로그인하면 재시도해요.');
        return;
      }
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
    await init();
    _pendingProductId = 'tarot_sub';
    await InAppPurchase.instance.restorePurchases(
      applicationUserName: sha256
          .convert(
            utf8.encode(
              StorageService.instance.effectiveUserIdForHistory(user),
            ),
          )
          .toString(),
    );
  }

  /// 서버가 승인한 뒤 스토어도 처리하므로 재시작 후 영수증만으로 복구할 수 있다.
  Future<void> retryPending() async {
    final uid = StorageService.instance.googleUserId;
    if (uid != null) await _recovery.retry(uid);
  }

  void _clearPending() {
    _buying = false;
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
