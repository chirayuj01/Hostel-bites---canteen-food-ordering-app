import 'package:flutter/material.dart';
import 'package:food_ninja/src/presentation/utils/app_colors.dart';

class AppTheme {
  ThemeData lightThemeData = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.kMain,
    scaffoldBackgroundColor: Colors.white,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors().backgroundColor,
      indicatorColor: AppColors.kMain.withValues(alpha: 0.1),
      surfaceTintColor: Colors.transparent,
    ),
    // change text button style
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondaryDarkColor,
      ),
    ),
    // change checkbox style
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all(
        AppColors.secondaryLightColor.withValues(alpha: 0.1),
      ),
      checkColor: WidgetStateProperty.all(
        AppColors.secondaryDarkColor,
      ),
    ),
    // change app bar surface tint color
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.transparent,
    ),
    // change cursor color
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.kMain,
    ),
    // change dialog surface tint color
    dialogTheme: const DialogThemeData(
      surfaceTintColor: Colors.transparent,
    ),
  );

  ThemeData darkThemeData = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors().backgroundColor,
    primaryColor: AppColors.primaryColor,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors().backgroundColor,
      indicatorColor: AppColors.primaryColor.withValues(alpha: 0.1),
      surfaceTintColor: Colors.transparent,
    ),
    // change text button style
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondaryDarkColor,
      ),
    ),
    // change checkbox style
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all(
        AppColors.secondaryLightColor.withValues(alpha: 0.1),
      ),
      checkColor: WidgetStateProperty.all(
        AppColors.secondaryDarkColor,
      ),
    ),
    // change app bar surface tint color
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.transparent,
    ),
    // change cursor color
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primaryColor,
    ),
    // change dialog surface tint color
    dialogTheme: const DialogThemeData(
      surfaceTintColor: Colors.transparent,
    ),
  );
}
