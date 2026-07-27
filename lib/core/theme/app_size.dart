import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// lib/core/theme/app_size.dart
class AppSize {
  // Padding values
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Spacing values
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  // Border radius values
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  
  // Icon sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  
  // Font sizes
  static const double fontXS = 10.0;
  static const double fontS = 12.0;
  static const double fontM = 14.0;
  static const double fontL = 16.0;
  static const double fontXL = 18.0;
  static const double fontXXL = 20.0;
  static const double fontXXXL = 24.0;
}
class AppScreenUtil {
  static late double screenWidth;
  static late double screenHeight;
  static late double textMultiplier;
  static late double imageSizeMultiplier;
  static late double heightMultiplier;
  static late double widthMultiplier;
  static late double radiusMultiplier;
  static bool isPortrait = true;
  static bool isMobilePortrait = false;
  void init(BoxConstraints constraints, Orientation orientation) {
    if (orientation == Orientation.portrait) {
      screenWidth = constraints.maxWidth;
      screenHeight = constraints.maxHeight;
      isPortrait = true;
      if (screenWidth < 600) {
        isMobilePortrait = true;
      }
    } else {
      screenWidth = constraints.maxHeight;
      screenHeight = constraints.maxWidth;
      isPortrait = false;
      isMobilePortrait = false;
    }

    textMultiplier = kIsWeb ? 1.1.sp : 1.sp;
    imageSizeMultiplier = 1;
    heightMultiplier = 1.h;
    widthMultiplier = 1.w;
    radiusMultiplier = 1.r;
  }
}

extension SizeExtension on num {
  double get widthMultiplier => this * AppScreenUtil.widthMultiplier;
  double get heightMultiplier => this * AppScreenUtil.heightMultiplier;
  double get imageSizeMultiplier => this * AppScreenUtil.imageSizeMultiplier;
  double get textMultiplier => this * AppScreenUtil.textMultiplier;
  double get radiusMultiplier => this * AppScreenUtil.radiusMultiplier;
  SizedBox get verticalSpace =>
      SizedBox(height: this * AppScreenUtil.heightMultiplier);
  SizedBox get horizontalSpace =>
      SizedBox(width: this * AppScreenUtil.widthMultiplier);
}
