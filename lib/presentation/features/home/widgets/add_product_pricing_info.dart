import 'package:flutter/material.dart';

class AddProductPricingInfo extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController quantityController;
  const AddProductPricingInfo({
    super.key,
    required this.priceController,
    required this.quantityController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prix et quantité',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Prix (€/kg)',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.euro),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le prix est requis';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Prix invalide';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Le prix doit être positif';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantité (kg)',
                  hintText: '0',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La quantité est requise';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Quantité invalide';
                  }
                  if (int.parse(value) <= 0) {
                    return 'La quantité doit être positive';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
