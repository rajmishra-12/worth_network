import 'package:flutter/material.dart';
import 'package:worth_network/components/common/clickable_button.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';


class CustomButton extends StatelessWidget {
  final double? width;
  final double? height;
  final double? radius;
  final Color? backgroundColor;
  final Color? loadingColor;
  final Color? borderColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final String? text;
  final BoxDecoration? boxDecoration;
  final Function() onTap;
  final List<Color>? textGradientColors;
  final List<Color>? borderGradientColors;
  final bool isLoading;
  final Widget? child;
  final EdgeInsets? padding;
  final double? borderWidth;

  const CustomButton({
    super.key,
    this.text,
    this.child,
    required this.onTap,
    this.width,
    this.height,
    this.backgroundColor,
    this.boxDecoration,
    this.borderColor,
    this.loadingColor,
    this.textColor,
    this.textStyle,
    this.isLoading = false,
    this.radius,
    this.padding,
    this.textGradientColors,
    this.borderGradientColors,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonContent =
        isLoading
            ? SizedBox(
              height: 10.heightMultiplier,
              width: 10.widthMultiplier,
              child: Center(
                child: CircularProgressIndicator(
                  color: loadingColor ?? AppColors.white100,
                ),
              ),
            )
            : child ??
                Center(
                  child:
                      textGradientColors != null
                          ? ShaderMask(
                            // NEW: gradient text shader
                            shaderCallback:
                                (bounds) => LinearGradient(
                                  colors: textGradientColors!,
                                ).createShader(bounds),
                            child: Text(
                              text ?? '',
                              style: (textStyle ?? CustomTextStyle.size18W600())
                                  .copyWith(color: Colors.white),
                            ),
                          )
                          : Text(
                            text ?? '',
                            style: (textStyle ?? CustomTextStyle.size18W600())
                                .copyWith(color: textColor),
                          ),
                );

    Widget container = Container(
      padding: padding,
      width: width ?? double.infinity,
      height: height ?? 50.heightMultiplier,
      clipBehavior: Clip.hardEdge,
      decoration:
          boxDecoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? 12.radiusMultiplier),
            border: Border.all(
              color:
                  borderGradientColors == null
                      ? (borderColor ?? Colors.transparent)
                      : Colors.transparent,
              width: borderWidth ?? 1.widthMultiplier,
            ),
            color: backgroundColor ?? AppColors.primary,
            // gradient:
            //     backgroundColor == null
            //         ? LinearGradient(colors: AppColors.buttonGradient)
            //         : null,
          ),
      child: buttonContent,
    );

    if (borderGradientColors != null) {
      container = Container(
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.all(borderWidth ?? 1.widthMultiplier),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: borderGradientColors!), // NEW
          borderRadius: BorderRadius.circular(radius ?? 12.radiusMultiplier),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius ?? 12.radiusMultiplier),
          child: container,
        ),
      );
    }

    return ClickableButton(onTap: onTap, child: container);
  }
}
