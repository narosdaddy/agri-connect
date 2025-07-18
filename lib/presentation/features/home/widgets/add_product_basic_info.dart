import 'package:flutter/material.dart';

class AddProductBasicInfo extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  const AddProductBasicInfo({
    super.key,
    required this.nameController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations de base',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nom du produit',
            hintText: 'Ex: Tomates bio',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.inventory),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le nom du produit est requis';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Décrivez votre produit...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La description est requise';
            }
            return null;
          },
        ),
      ],
    );
  }
}
