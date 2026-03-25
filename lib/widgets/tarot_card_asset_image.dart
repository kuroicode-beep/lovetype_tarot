import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/card_data.dart';
import '../models/tarot_card.dart';
import '../services/payment_service.dart';

/// 고대비·구독 상태에 맞는 `asset/*_deck/` 이미지를 로드한다.
class TarotCardAssetImage extends StatelessWidget {
  final TarotCard card;
  final BoxFit fit;
  final ImageErrorWidgetBuilder? errorBuilder;

  const TarotCardAssetImage({
    super.key,
    required this.card,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppState.instance.highContrast,
      builder: (context, highContrast, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: PaymentService.instance.isSubscribedNotifier,
          builder: (context, subscribed, _) {
            final deck = resolveTarotDeckVisual(
              highContrast: highContrast,
              subscribed: subscribed,
            );
            final path = tarotCardImagePath(card.id, deck);
            return Image.asset(
              path,
              fit: fit,
              errorBuilder: errorBuilder,
            );
          },
        );
      },
    );
  }
}
