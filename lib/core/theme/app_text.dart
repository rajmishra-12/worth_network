import 'package:flutter/material.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';

class _AppTextStyles {
  static TextStyle bold = TextStyle(
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
    color: AppColors.black100,
  );
  static TextStyle semiBold = TextStyle(
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: AppColors.black100,
  );
  static TextStyle medium = TextStyle(
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: AppColors.black100,
  );
  static TextStyle regular = TextStyle(
    fontWeight: FontWeight.w400,
    color: AppColors.black100,
    fontFamily: 'Poppins',
  );
  static TextStyle light = TextStyle(
    fontWeight: FontWeight.w300,
    fontFamily: 'Poppins',
    color: AppColors.black100,
  );
}

class CustomTextStyle {
  static TextStyle size17w600({Color? color}) => _AppTextStyles.semiBold
      .copyWith(fontSize: 17.textMultiplier, color: color);

  static TextStyle size12W500({Color? color}) =>
      _AppTextStyles.medium.copyWith(fontSize: 12.textMultiplier, color: color);

  static TextStyle size13W500({Color? color}) =>
      _AppTextStyles.medium.copyWith(fontSize: 13.textMultiplier, color: color);

  static TextStyle size15W600({Color? color}) => _AppTextStyles.semiBold
      .copyWith(fontSize: 15.textMultiplier, color: color);

  static TextStyle size15W500({Color? color}) =>
      _AppTextStyles.medium.copyWith(fontSize: 15.textMultiplier, color: color);

  static TextStyle size15W400({Color? color}) => _AppTextStyles.regular
      .copyWith(fontSize: 15.textMultiplier, color: color);

  static TextStyle size14W400({Color? color}) => _AppTextStyles.regular
      .copyWith(fontSize: 14.textMultiplier, color: color);

  static TextStyle size14W700({Color? color}) =>
      _AppTextStyles.bold.copyWith(fontSize: 14.textMultiplier, color: color);

  static TextStyle size16W500({Color? color}) =>
      _AppTextStyles.medium.copyWith(fontSize: 16.textMultiplier, color: color);

  static TextStyle size18W500({Color? color}) =>
      _AppTextStyles.medium.copyWith(fontSize: 18.textMultiplier, color: color);

  static TextStyle size14W500({Color? color, TextDecoration? textDecoration}) =>
      _AppTextStyles.medium.copyWith(
        fontSize: 14.textMultiplier,
        color: color,
        decoration: textDecoration,
      );

  static TextStyle size20W600({Color? color}) => _AppTextStyles.semiBold
      .copyWith(fontSize: 22.textMultiplier, color: color);

  static TextStyle size30W600({Color? color}) => _AppTextStyles.semiBold
      .copyWith(fontSize: 35.textMultiplier, color: color);

  static TextStyle size18W600({Color? color}) => _AppTextStyles.semiBold
      .copyWith(fontSize: 18.textMultiplier, color: color);

  static TextStyle size16W600({Color? color}) => _AppTextStyles.semiBold
      .copyWith(fontSize: 16.textMultiplier, color: color);

  static TextStyle size11W400({Color? color}) => _AppTextStyles.regular
      .copyWith(fontSize: 11.textMultiplier, color: color);

  static TextStyle size11W500({Color? color}) => _AppTextStyles.semiBold
      .copyWith(fontSize: 11.textMultiplier, color: color);

  static TextStyle size11W600({Color? color}) => _AppTextStyles.semiBold
      .copyWith(fontSize: 11.textMultiplier, color: color);

  static TextStyle size14W600({Color? color}) => _AppTextStyles.semiBold
      .copyWith(fontSize: 14.textMultiplier, color: color);

  static TextStyle size10W600({Color? color}) => _AppTextStyles.semiBold
      .copyWith(fontSize: 10.textMultiplier, color: color);

  static TextStyle size10W500({Color? color}) =>
      _AppTextStyles.medium.copyWith(fontSize: 10.textMultiplier, color: color);

  static TextStyle size8W500({Color? color}) =>
      _AppTextStyles.medium.copyWith(fontSize: 8.textMultiplier, color: color);

  static TextStyle size20W500({Color? color}) =>
      _AppTextStyles.medium.copyWith(fontSize: 20.textMultiplier, color: color);

  static TextStyle size22W500({Color? color}) => _AppTextStyles.regular
      .copyWith(fontSize: 22.textMultiplier, color: color);

  static TextStyle size28W500({Color? color}) =>
      _AppTextStyles.medium.copyWith(fontSize: 28.textMultiplier, color: color);

  static TextStyle size12W600({Color? color}) => _AppTextStyles.semiBold
      .copyWith(fontSize: 12.textMultiplier, color: color);

  static TextStyle size16W400({Color? color, TextDecoration? textDecoration}) =>
      _AppTextStyles.regular.copyWith(
        fontSize: 16.textMultiplier,
        color: color,
        decoration: textDecoration,
      );

  static TextStyle size12W400({Color? color, TextDecoration? textDecoration}) =>
      _AppTextStyles.regular.copyWith(
        fontSize: 12.textMultiplier,
        color: color,
        decoration: textDecoration,
      );

  static TextStyle size10W400({Color? color}) => _AppTextStyles.regular
      .copyWith(fontSize: 10.textMultiplier, color: color);

  static TextStyle size8W300({Color? color}) =>
      _AppTextStyles.light.copyWith(fontSize: 10.textMultiplier, color: color);

  static TextStyle customW600({Color? color, double? fontSize}) =>
      _AppTextStyles.semiBold.copyWith(
        fontSize: fontSize?.textMultiplier,
        color: color,
      );

  static TextStyle customW700({Color? color, double? fontSize}) =>
      _AppTextStyles.bold.copyWith(
        fontSize: fontSize?.textMultiplier,
        color: color,
      );

  static TextStyle customW500({Color? color, double? fontSize}) =>
      _AppTextStyles.medium.copyWith(
        fontSize: fontSize?.textMultiplier,
        color: color,
      );

  static TextStyle customW400({Color? color, double? fontSize}) =>
      _AppTextStyles.regular.copyWith(
        fontSize: fontSize?.textMultiplier,
        color: color,
      );

  static TextStyle size13W600({Color? color}) => _AppTextStyles.semiBold
      .copyWith(fontSize: 13.textMultiplier, color: color);

  static TextStyle size13W400({Color? color}) => _AppTextStyles.regular
      .copyWith(fontSize: 13.textMultiplier, color: color);

  static TextStyle size24W600({Color? color}) => _AppTextStyles.semiBold
      .copyWith(fontSize: 24.textMultiplier, color: color);
}
