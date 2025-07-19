import 'package:flutter/material.dart';

class AddProductOrganicToggle extends StatelessWidget {
  final bool isOrganic;
  final ValueChanged<bool> onChanged;
  const AddProductOrganicToggle({
    super.key,
    required this.isOrganic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.eco, color: Colors.green[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produit bio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
                Text(
                  'Cochez si votre produit est certifié bio',
                  style: TextStyle(fontSize: 12, color: Colors.green[700]),
                ),
              ],
            ),
          ),
          Switch(
            value: isOrganic,
            onChanged: onChanged,
            activeColor: Colors.green[600],
          ),
        ],
      ),
    );
  }
}
