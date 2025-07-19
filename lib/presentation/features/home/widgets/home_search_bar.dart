import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  const HomeSearchBar({super.key, this.onSubmitted, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Rechercher des produits...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.filter_list, color: Color(0xFF4CAF50)),
              onPressed: onFilterTap,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }
}
