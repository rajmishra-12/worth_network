
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final AutovalidateMode? autovalidateMode;
  final Widget? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? hintTextStyle;
  final double? borderRadius;
  final Color? borderColor;
  final bool? readOnly;
  final double? height;
  final Color? backgroundColor;
  final void Function()? onTap;
  final TextStyle? textStyle;
  final bool? useLabelText;
  final int? maxlines;
  final int? maxLength;
  final Color? cursorColor;
  final double? cursorHeight;
  final double? cursorWidth;
  final bool? textCapitalization;
  final String? errorText;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? prefixIconPadding;
  final EdgeInsetsGeometry? suffixIconPadding;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.autovalidateMode,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.hintTextStyle,
    this.borderRadius,
    this.borderColor,
    this.readOnly,
    this.height,
    this.backgroundColor,
    this.onTap,
    this.textStyle,
    this.useLabelText = true,
    this.maxlines,
    this.maxLength,
    this.cursorColor,
    this.cursorHeight,
    this.cursorWidth,
    this.textCapitalization,
    this.errorText,
    this.suffixIcon,
    this.prefixIconConstraints,
    this.prefixIconPadding,
    this.suffixIconPadding,
    this.suffixIconConstraints,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(
              borderRadius ?? 8.radiusMultiplier,
            ),
          ),
          child: Center(
            child: TextFormField(
              maxLength: maxLength,
              cursorColor: cursorColor ?? AppColors.primary,
              textCapitalization:
                  textCapitalization == true
                      ? TextCapitalization.sentences
                      : TextCapitalization.none,
              cursorHeight: cursorHeight,
              cursorWidth: cursorWidth ?? 2.0,
           maxLines: obscureText ? 1 : (maxlines ?? 1),
              readOnly: readOnly ?? false,
              autovalidateMode: autovalidateMode,
              inputFormatters: inputFormatters,
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              validator: validator,
              onChanged: onChanged,
              onTap: onTap,
              style:
                  textStyle ??
                  CustomTextStyle.size14W500(color: AppColors.black100),

              decoration: InputDecoration(
                counterText: '',
                prefixIconConstraints:
                    prefixIconConstraints ??
                    BoxConstraints(
                      maxHeight: 40.heightMultiplier,
                      maxWidth: 40.widthMultiplier,
                    ),
                prefixIcon:
                    prefixIcon != null
                        ? Padding(
                          padding:
                              prefixIconPadding ??
                              EdgeInsets.only(left: 8.widthMultiplier),
                          child: prefixIcon,
                        )
                        : null,
                hoverColor: Colors.transparent,
                suffixIconConstraints:
                    suffixIconConstraints ??
                    BoxConstraints(
                      maxHeight: 40.heightMultiplier,
                      maxWidth: 40.widthMultiplier,
                    ),

                suffixIcon:
                    suffixIcon != null
                        ? Padding(
                          padding:
                              suffixIconPadding ??
                              EdgeInsets.only(right: 12.widthMultiplier),
                          child: IconTheme(
                            data: IconThemeData(color: AppColors.grey),
                            child: suffixIcon!,
                          ),
                        )
                        : null,
                filled: true,
                fillColor: backgroundColor ?? Colors.transparent,
                // prefixIcon: prefixIcon,
                labelText: useLabelText == true ? hintText : null,
                hintText: useLabelText == true ? null : hintText,
                labelStyle:
                    hintTextStyle ??
                    CustomTextStyle.size16W500(color: AppColors.white60),
                hintStyle:
                    hintTextStyle ??
                    CustomTextStyle.size14W400(color: AppColors.primaryLight),
                border: border(),
                focusedBorder: border(),
                enabledBorder: border(),
                disabledBorder: border(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16.heightMultiplier,
                  horizontal: 12.widthMultiplier,
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            color: AppColors.white100,
            child: Text(
              errorText!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  OutlineInputBorder border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius ?? 16.radiusMultiplier),
      borderSide: BorderSide(color: borderColor ?? AppColors.black200),
    );
  }
}

class FieldState<T> {
  final T value;
  final bool isActive;
  final String error;
  final String? selectedUnit;

  FieldState({
    required this.value,
    this.isActive = false,
    required this.error,
    this.selectedUnit,
  });

  FieldState.initial({required T value, bool? isActive, String? unit})
    : this(
        value: value,
        isActive: isActive ?? true,
        error: '',
        selectedUnit: unit,
      );

  FieldState<T> copyWith({
    T? value,
    bool? isActive,
    String? error,
    String? selectedUnit,
  }) {
    return FieldState(
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
      error: error ?? this.error,
      selectedUnit: selectedUnit ?? this.selectedUnit,
    );
  }
}
