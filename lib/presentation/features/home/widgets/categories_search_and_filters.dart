import 'package:flutter/material.dart';

class CategoriesSearchAndFilters extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final bool showOnlyOrganic;
  final VoidCallback onClearSearch;
  const CategoriesSearchAndFilters({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.showOnlyOrganic,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  searchQuery.isNotEmpty
                      ? IconButton(
                        onPressed: onClearSearch,
                        icon: const Icon(Icons.clear),
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          if (showOnlyOrganic)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco, color: Colors.green[700], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Produits bio uniquement',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
