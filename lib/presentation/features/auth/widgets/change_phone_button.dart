import 'package:flutter/material.dart';

class ChangePhoneButton extends StatelessWidget {
  final VoidCallback onPressed;
  const ChangePhoneButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: const Text(
        'Changer de numéro',
        style: TextStyle(color: Color(0xFF4CAF50)),
      ),
    );
  }
}
