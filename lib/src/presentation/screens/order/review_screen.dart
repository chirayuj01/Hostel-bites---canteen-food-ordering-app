import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_ninja/src/data/models/order.dart';
import 'package:food_ninja/src/data/services/firestore_db.dart';
import 'package:food_ninja/src/presentation/utils/app_colors.dart';
import 'package:food_ninja/src/presentation/utils/app_styles.dart';
import 'package:food_ninja/src/presentation/utils/custom_text_style.dart';
import 'package:food_ninja/src/presentation/widgets/buttons/primary_button.dart';
import 'package:food_ninja/src/presentation/widgets/buttons/secondary_button.dart';

class ReviewScreen extends StatefulWidget {
  final Order order;
  const ReviewScreen({super.key, required this.order});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  final FirestoreDatabase _db = FirestoreDatabase();
  double _rating = 3.0;
  int _selectedFoodIndex = 0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      body: Stack(
        children: [
          // Background Pattern
          Positioned(
            top: 0,
            right: 0,
            child: SvgPicture.asset(
              "assets/svg/pattern-small.svg",
              width: 150,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios),
                        color: AppColors.kMain,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Leave a Review",
                        style: CustomTextStyle.size25Weight600Text(),
                      ),
                    ],
                  ),
                ),
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          "How was your order?",
                          style: CustomTextStyle.size16Weight400Text(
                            AppColors().secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Food Items Selector
                        Text(
                          "Select item to review:",
                          style: CustomTextStyle.size14Weight600Text(),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.order.cart.length,
                            itemBuilder: (context, index) {
                              final item = widget.order.cart[index];
                              final isSelected = _selectedFoodIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedFoodIndex = index;
                                  });
                                },
                                child: Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: AppStyles.largeBorderRadius,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : Colors.grey.withAlpha(50),
                                      width: isSelected ? 3 : 1,
                                    ),
                                    color: AppColors().cardColor,
                                    boxShadow: isSelected
                                        ? [
                                      BoxShadow(
                                        color: AppColors.primaryColor.withAlpha(
                                            50),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      )
                                    ]
                                        : [],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              10),
                                          color: AppColors.primaryColor
                                              .withAlpha(30),
                                        ),
                                        child: Icon(
                                          Icons.fastfood,
                                          size: 30,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Text(
                                          item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: CustomTextStyle
                                              .size14Weight400Text(
                                            isSelected
                                                ? AppColors.primaryColor
                                                : null,
                                          ).copyWith(
                                            fontWeight: isSelected ? FontWeight
                                                .bold : FontWeight.normal,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Rating Section
                        Center(
                          child: Column(
                            children: [
                              Text(
                                "Rate your experience",
                                style: CustomTextStyle.size16Weight600Text(),
                              ),
                              const SizedBox(height: 15),
                              RatingBar.builder(
                                initialRating: _rating,
                                minRating: 1,
                                direction: Axis.horizontal,
                                itemCount: 5,
                                allowHalfRating: true,
                                itemSize: 40,
                                itemPadding: const EdgeInsets.symmetric(
                                    horizontal: 4.0),
                                itemBuilder: (context, _) =>
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  setState(() {
                                    _rating = rating;
                                  });
                                },
                                glow: true,
                                glowColor: Colors.amber.withAlpha(50),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _getRatingText(_rating),
                                style: CustomTextStyle.size14Weight400Text(
                                  AppColors().secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Review Text Field
                        Text(
                          "Write your review",
                          style: CustomTextStyle.size16Weight600Text(),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [AppStyles.boxShadow7],
                            borderRadius: AppStyles.defaultBorderRadius,
                          ),
                          child: TextField(
                            controller: _reviewController,
                            maxLines: 5,
                            maxLength: 500,
                            decoration: InputDecoration(
                              fillColor: AppColors().cardColor,
                              filled: true,
                              hintText: "Share your experience about ${widget
                                  .order.cart[_selectedFoodIndex].name}...",
                              hintStyle: CustomTextStyle.size14Weight400Text(
                                AppColors().secondaryTextColor,
                              ),
                              enabledBorder: AppStyles().defaultEnabledBorder,
                              focusedBorder: AppStyles.defaultFocusedBorder(),
                              counterStyle: CustomTextStyle.size16Weight400Text(
                                AppColors().secondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Submit Button
                        PrimaryButton(
                          text: _isSubmitting
                              ? "Submitting..."
                              : "Submit Review",
                          onTap: _isSubmitting ? () {} : _submitReview,
                        ),
                        const SizedBox(height: 15),

                        // Skip Button
                        SecondaryButton(
                          text: "Skip",
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating <= 1.5) return "Poor";
    if (rating <= 2.5) return "Fair";
    if (rating <= 3.5) return "Good";
    if (rating <= 4.5) return "Very Good";
    return "Excellent";
  }

  Future<void> _submitReview() async {
    // Validate review text
    if (_reviewController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please write a review before submitting'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (_reviewController.text
        .trim()
        .length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Review must be at least 10 characters long'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Get selected food item
      final selectedFood = widget.order.cart[_selectedFoodIndex];

      // Create food reference
      DocumentReference foodRef = FirebaseFirestore.instance
          .collection('foods')
          .doc(selectedFood.id);

      // Create user reference
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid);

      // Prepare testimonial data
      Map<String, dynamic> testimonialData = {
        'review': _reviewController.text.trim(),
        'rating': _rating,
        'target': foodRef,
        'user': userRef,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Submit to Firestore
      await _db.addDocument('testimonials', testimonialData);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Thank you for your review!',
                    style: CustomTextStyle.size14Weight400Text(Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Wait a bit for the user to see the success message
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate back
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Failed to submit review: ${e.toString()}',
                    style: CustomTextStyle.size14Weight400Text(Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }


}
