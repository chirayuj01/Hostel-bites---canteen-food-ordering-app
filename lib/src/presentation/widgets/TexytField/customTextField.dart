import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../../utils/custom_text_style.dart';

class Customtextfield extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final VoidCallback onTap;


  const Customtextfield({super.key, required this.hintText, required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppStyles.defaultTextFieldHeight,
      decoration: BoxDecoration(
        boxShadow: [AppStyles.boxShadow7],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          fillColor: AppColors().cardColor,
          filled: true,
          hintText: hintText,
          hintStyle: CustomTextStyle.size14Weight400Text(
            AppColors().secondaryTextColor,
          ),
          enabledBorder: AppStyles().defaultEnabledBorder,
          focusedBorder: AppStyles.defaultFocusedBorder(),
        ),
      ),
    );
  }
}
