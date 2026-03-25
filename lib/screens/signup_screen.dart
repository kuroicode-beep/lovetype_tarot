import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('시작하기')),
      body: const Center(
        child: Text('SignupScreen — Google OAuth 연동 예정'),
      ),
    );
  }
}
