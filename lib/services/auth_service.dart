import 'package:google_sign_in/google_sign_in.dart';

/// Google OAuth 인증 서비스
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
  bool get isSignedIn => currentUser != null;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() => _googleSignIn.signOut();
}
