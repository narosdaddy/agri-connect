import 'package:flutter/material.dart';

class ForgotPasswordTitle extends StatelessWidget {
  final String title;
  const ForgotPasswordTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4CAF50),
      ),
      textAlign: TextAlign.center,
    );
  }
}
