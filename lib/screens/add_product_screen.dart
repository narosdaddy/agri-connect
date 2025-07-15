import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _categoryController = TextEditingController();
  
  String _selectedCategory = 'Légumes';
  bool _isOrganic = false;
  bool _isLoading = false;
  
  final List<String> _categories = [
    'Légumes',
    'Fruits',
    'Céréales',
    'Légumineuses',
    'Herbes aromatiques',
    'Produits laitiers',
    'Viandes',
    'Œufs',
    'Miel',
    'Autres',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final productService = Provider.of<ProductService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final userInfo = await authService.getUserInfo();
      
      final product = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'quantity': int.parse(_quantityController.text),
        'category': _selectedCategory,
        'isOrganic': _isOrganic,
        'producer': userInfo?['name'] ?? 'Producteur',
        'producerId': userInfo?['email'] ?? 'unknown',
        'image': 'https://via.placeholder.com/300x200?text=${_nameController.text.trim()}',
        'rating': 0.0,
        'reviews': 0,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await productService.addProduct(product);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produit ajouté avec succès!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProductImage(),
                          const SizedBox(height: 24),
                          _buildBasicInfo(),
                          const SizedBox(height: 24),
                          _buildPricingInfo(),
                          const SizedBox(height: 24),
                          _buildCategoryInfo(),
                          const SizedBox(height: 24),
                          _buildOrganicToggle(),
                          const SizedBox(height: 32),
                          _buildSubmitButton(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          const Text(
            'Ajouter un produit',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Ajouter une photo',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cliquez pour sélectionner une image',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
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
          controller: _nameController,
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
          controller: _descriptionController,
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

  Widget _buildPricingInfo() {
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
                controller: _priceController,
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
                controller: _quantityController,
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

  Widget _buildCategoryInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Sélectionner une catégorie',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildOrganicToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.eco,
            color: Colors.green[600],
            size: 24,
          ),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isOrganic,
            onChanged: (bool value) {
              setState(() {
                _isOrganic = value;
              });
            },
            activeColor: Colors.green[600],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _addProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Ajout en cours...'),
                ],
              )
            : const Text(
                'Ajouter le produit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
} 