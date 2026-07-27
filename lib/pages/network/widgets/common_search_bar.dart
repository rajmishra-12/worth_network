// lib/pages/dashboard/network/widgets/search_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSearch;
  final VoidCallback onClear;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSize.paddingM,
        AppSize.paddingM,
        AppSize.paddingM,
        AppSize.paddingS,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.grey900,
          borderRadius: BorderRadius.circular(AppSize.radiusL),
          border: Border.all(
            color: AppColors.grey800,
            width: 1,
          ),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          style: CustomTextStyle.size16W500(color: AppColors.white100),
          decoration: InputDecoration(
            hintText: 'Search users...',
            hintStyle: CustomTextStyle.size16W400(color: AppColors.grey500),
            prefixIcon: Icon(
              Icons.search_outlined,
              color: focusNode.hasFocus ? AppColors.primary : AppColors.grey500,
              size: 22,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.grey500,
                      size: 20,
                    ),
                    onPressed: () {
                      controller.clear();
                      onClear();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.radiusL),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSize.paddingM,
              vertical: AppSize.paddingM,
            ),
          ),
          onChanged: (value) {
            if (value.isEmpty) {
              onClear();
            } else {
              onSearch(value);
            }
          },
          inputFormatters: [
            LengthLimitingTextInputFormatter(50),
          ],
        ),
      ),
    );
  }
}