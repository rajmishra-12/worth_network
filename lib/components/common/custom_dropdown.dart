import 'package:flutter/material.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';


class CustomDropdownField extends StatelessWidget {
  final int? value;
  final String hintText;
  final void Function(int?)? onChanged;
  final double? borderRadius;
  final Color? borderColor;
  final TextStyle? textStyle;
  final TextStyle? hintTextStyle;

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.hintText,
    this.onChanged,
    this.borderRadius,
    this.borderColor,
    this.textStyle,
    this.hintTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.widthMultiplier),
      decoration: BoxDecoration(
        color: AppColors.white100,
        borderRadius: BorderRadius.circular(borderRadius ?? 12.radiusMultiplier),
        border: Border.all(color: borderColor ?? AppColors.primary, width: 1.5),
      ),
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: hintTextStyle ?? CustomTextStyle.size14W400(color: AppColors.black100),
        ),
        style: textStyle ?? CustomTextStyle.size14W500(color: AppColors.black100),
        items: List.generate(7, (index) => index + 1)
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.toString()),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
