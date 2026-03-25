import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/app_state.dart';
import 'screens/intro_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/info_input_screen.dart';
import 'screens/soul_card_screen.dart';
import 'screens/main_screen.dart';
import 'screens/keyword_screen.dart';

/// LoveType-Tarot 앱 루트 위젯
///
/// card-draw / card-confirm / result 는 생성자 인자가 필요하므로
/// Navigator.push(MaterialPageRoute) 방식으로 각 화면에서 직접 이동함.
class LoveTypeTarotApp extends StatelessWidget {
  const LoveTypeTarotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppState.instance.highContrast,
      builder: (context, isHighContrast, child) {
        return MaterialApp(
          title: 'LoveType Tarot',
          debugShowCheckedModeBanner: false,
          theme: isHighContrast
              ? AppTheme.highContrastTheme
              : AppTheme.darkTheme,
          initialRoute: '/',
          routes: {
            '/': (_) => const IntroScreen(),
            '/signup': (_) => const SignupScreen(),
            '/info-input': (_) => const InfoInputScreen(),
            '/main': (_) => const MainScreen(),
            '/keyword': (_) => const KeywordScreen(),
          },
          // SoulCardScreen은 UserModel 인자가 필요 → onGenerateRoute 처리
          onGenerateRoute: (settings) {
            if (settings.name == '/soul-card') {
              return MaterialPageRoute(
                builder: (_) =>
                    SoulCardScreen(user: settings.arguments as dynamic),
                settings: settings,
              );
            }
            return null;
          },
        );
      },
    );
  }
}
