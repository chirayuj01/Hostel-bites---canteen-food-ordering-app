import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_ninja/src/data/services/firestore_db.dart';
import 'package:food_ninja/src/presentation/utils/app_colors.dart';
import 'package:food_ninja/src/presentation/utils/app_styles.dart';
import 'package:food_ninja/src/presentation/utils/custom_text_style.dart';
import 'package:food_ninja/src/presentation/widgets/buttons/back_button.dart';
import 'package:food_ninja/src/presentation/widgets/buttons/primary_button.dart';
import 'package:food_ninja/src/presentation/widgets/loading_indicator.dart';

class AddMenuItemScreen extends StatefulWidget {
  const AddMenuItemScreen({super.key});

  @override
  State<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  String? _selectedCategory;

  final List<Map<String, String>> _categories = [
    {'id': 'breakfast', 'name': 'Breakfast'},
    {'id': 'lunch', 'name': 'Lunch'},
    {'id': 'dinner', 'name': 'Dinner'},
    {'id': 'snacks', 'name': 'Snacks'},
    {'id': 'beverages', 'name': 'Beverages'},
    {'id': 'desserts', 'name': 'Desserts'},
  ];

  Future<void> _saveMenuItem() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.errorColor,
          content: const Text('Please select a category'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final foodData = {
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'categoryName': _categories.firstWhere((c) => c['id'] == _selectedCategory)['name'],
        'createdAt': Timestamp.now(),
        'quantity': 0,
        'available': true,
      };

      await FirestoreDatabase().addDocument('foods', foodData);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: const Text('Menu item added successfully!'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.errorColor,
            content: Text('Failed: ${e.toString()}'),
          ),
        );
      }
      debugPrint('Error: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomBackButton(),
                    const SizedBox(height: 20),
                    Text('Add New Menu Item', style: CustomTextStyle.size25Weight600Text()),
                    const SizedBox(height: 30),
                    Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors().cardColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppColors.primaryColor.withAlpha(76), width: 2),
                          boxShadow: [AppStyles.boxShadow7],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fastfood, size: 80, color: AppColors.primaryColor),
                            const SizedBox(height: 10),
                            Text('Default Icon', style: CustomTextStyle.size14Weight400Text(AppColors().secondaryTextColor)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text('Item Name', style: CustomTextStyle.size14Weight600Text()),
                    const SizedBox(height: 10),
                    Container(
                      height: AppStyles.defaultTextFieldHeight,
                      decoration: BoxDecoration(boxShadow: [AppStyles.boxShadow7]),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          fillColor: AppColors().cardColor,
                          filled: true,
                          hintText: "e.g., Chicken Biryani",
                          hintStyle: CustomTextStyle.size14Weight400Text(AppColors().secondaryTextColor),
                          enabledBorder: AppStyles().defaultEnabledBorder,
                          focusedBorder: AppStyles.defaultFocusedBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter item name' : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Price (₹)', style: CustomTextStyle.size14Weight600Text()),
                    const SizedBox(height: 10),
                    Container(
                      height: AppStyles.defaultTextFieldHeight,
                      decoration: BoxDecoration(boxShadow: [AppStyles.boxShadow7]),
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                        decoration: InputDecoration(
                          fillColor: AppColors().cardColor,
                          filled: true,
                          hintText: "e.g., 120.00",
                          hintStyle: CustomTextStyle.size14Weight400Text(AppColors().secondaryTextColor),
                          enabledBorder: AppStyles().defaultEnabledBorder,
                          focusedBorder: AppStyles.defaultFocusedBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please enter price';
                          final price = double.tryParse(v);
                          if (price == null || price <= 0) return 'Please enter valid price';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Category', style: CustomTextStyle.size14Weight600Text()),
                    const SizedBox(height: 10),
                    Container(
                      height: AppStyles.defaultTextFieldHeight,
                      decoration: BoxDecoration(boxShadow: [AppStyles.boxShadow7]),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          fillColor: AppColors().cardColor,
                          filled: true,
                          enabledBorder: AppStyles().defaultEnabledBorder,
                          focusedBorder: AppStyles.defaultFocusedBorder(),
                        ),
                        hint: Text(
                          'Select Category',
                          style: CustomTextStyle.size14Weight400Text(AppColors().secondaryTextColor),
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat['id'],
                            child: Text(cat['name']!),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val),
                        validator: (v) => v == null ? 'Please select a category' : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Description', style: CustomTextStyle.size14Weight600Text()),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(boxShadow: [AppStyles.boxShadow7]),
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          fillColor: AppColors().cardColor,
                          filled: true,
                          hintText: "Enter item description",
                          hintStyle: CustomTextStyle.size14Weight400Text(AppColors().secondaryTextColor),
                          enabledBorder: AppStyles().defaultEnabledBorder,
                          focusedBorder: AppStyles.defaultFocusedBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter description' : null,
                      ),
                    ),
                    const SizedBox(height: 30),
                    PrimaryButton(
                      text: 'Add Menu Item',
                      onTap: _saveMenuItem,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) const LoadingIndicator(),
        ],
      ),
    );
  }
}
