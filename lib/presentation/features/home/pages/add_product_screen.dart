import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agri_marketplace/data/sources/product_service.dart';
import 'package:agri_marketplace/data/models/product_model.dart';
import 'package:agri_marketplace/presentation/features/auth/provider/auth_provider.dart';
import 'package:agri_marketplace/presentation/features/home/provider/profile_provider.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/add_product_header.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/add_product_image.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/add_product_basic_info.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/add_product_pricing_info.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/add_product_category_info.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/add_product_organic_toggle.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/add_product_submit_button.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen>
    with TickerProviderStateMixin {
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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

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
      final productService = Provider.of<ProductService>(
        context,
        listen: false,
      );
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        await profileProvider.fetchMyProfile();
      }
      final userInfo = profileProvider.profile;

      final product = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nom: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        prix: double.tryParse(_priceController.text),
        quantite: int.tryParse(_quantityController.text),
        categorieId: _selectedCategory,
        producteurId: userInfo?.id ?? 'unknown',
        imageUrl:
            'https://via.placeholder.com/300x200?text=${_nameController.text.trim()}',
        bio: _isOrganic,
        dateCreation: DateTime.now().toIso8601String(),
      );

      await productService.addProduct(product);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produit ajouté avec succès!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      String errorMessage = 'Erreur lors de l\'ajout du produit';
      if (e.toString().contains('Producteur non trouvé')) {
        errorMessage = 'Producteur non trouvé. Veuillez vérifier que votre compte est bien un compte producteur.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
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
                AddProductHeader(
                  isLoading: _isLoading,
                  onBack: () => Navigator.pop(context),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AddProductImage(),
                          const SizedBox(height: 24),
                          AddProductBasicInfo(
                            nameController: _nameController,
                            descriptionController: _descriptionController,
                          ),
                          const SizedBox(height: 24),
                          AddProductPricingInfo(
                            priceController: _priceController,
                            quantityController: _quantityController,
                          ),
                          const SizedBox(height: 24),
                          AddProductCategoryInfo(
                            selectedCategory: _selectedCategory,
                            categories: _categories,
                            onCategoryChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          AddProductOrganicToggle(
                            isOrganic: _isOrganic,
                            onChanged: (bool value) {
                              setState(() {
                                _isOrganic = value;
                              });
                            },
                          ),
                          const SizedBox(height: 32),
                          AddProductSubmitButton(
                            isLoading: _isLoading,
                            onPressed: _addProduct,
                          ),
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
}
