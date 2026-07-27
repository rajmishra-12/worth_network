// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary colors (Black + Gold theme)
  static const Color primary = Color(0xFFFFD700); // Gold
  static const Color primaryDark = Color(0xFFFFC107);
  static const Color primaryLight = Color(0xFFFFE44D);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Background colors
  static const Color background = Color(0xFF0A0A0A); // Dark black
  static const Color surface = Color(0xFF1A1A1A);
  static const Color card = Color(0xFF1E1E1E);
  
  // Black shades (as used in your code)
  static const Color black100 = Color(0xFF000000);
  static const Color black200 = Color(0xFF1A1A1A);
  static const Color black300 = Color(0xFF2A2A2A);
  
  // Grey shades
  static const Color grey900 = Color(0xFF121212);
  static const Color grey800 = Color(0xFF1E1E1E);
  static const Color grey700 = Color(0xFF2C2C2C);
  static const Color grey600 = Color(0xFF3A3A3A);
  static const Color grey500 = Color(0xFF6B6B6B);
  static const Color grey400 = Color(0xFF9E9E9E);
  static const Color grey300 = Color(0xFFBDBDBD);
  static const Color grey200 = Color(0xFFE0E0E0);
  static const Color grey100 = Color(0xFFF5F5F5);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color accent = Color(0xFFFFD700); // Same as primary
  
  // White shades
  static const Color white100 = Color(0xFFFFFFFF);
  static const Color white80 = Color(0xCCFFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white40 = Color(0x66FFFFFF);
  
  // Semantic colors (matching your existing code)
  static const Color primaryColor = primary;
  static const Color grey = grey500;
  static const Color grey700Color = grey700;
  static const Color blackColor = black100;
  static const Color whiteColor = white100;
  static const Color accentColor = accent;
  static const Color errorColor = error;
  static const Color successColor = success;
  static const Color infoColor = info;
}