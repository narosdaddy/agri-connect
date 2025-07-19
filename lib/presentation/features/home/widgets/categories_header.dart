import 'package:flutter/material.dart';

class CategoriesHeader extends StatelessWidget {
  final VoidCallback onSort;
  final bool showOnlyOrganic;
  final VoidCallback onToggleOrganic;
  const CategoriesHeader({
    super.key,
    required this.onSort,
    required this.showOnlyOrganic,
    required this.onToggleOrganic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            const Text(
              'Produits',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(onPressed: onSort, icon: const Icon(Icons.sort)),
            IconButton(
              onPressed: onToggleOrganic,
              icon: Icon(
                Icons.eco,
                color: showOnlyOrganic ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
