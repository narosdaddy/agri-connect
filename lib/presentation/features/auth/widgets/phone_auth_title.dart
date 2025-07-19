import 'package:flutter/material.dart';

class PhoneAuthTitle extends StatelessWidget {
  final String title;
  const PhoneAuthTitle({super.key, required this.title});

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
