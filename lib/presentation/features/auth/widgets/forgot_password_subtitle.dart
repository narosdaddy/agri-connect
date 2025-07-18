import 'package:flutter/material.dart';

class ForgotPasswordSubtitle extends StatelessWidget {
  final String subtitle;
  const ForgotPasswordSubtitle({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Text(
      subtitle,
      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      textAlign: TextAlign.center,
    );
  }
}
