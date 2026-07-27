// lib/pages/dashboard/action/widgets/category_selector.dart
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/pages/action/cubit/add_action_cubit.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<String> categories = const [
    'Support',
    'Work',
    'Health',
    'Education',
    'Environment',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSize.spacingS,
      runSpacing: AppSize.spacingS,
      children: categories.map((category) {
        final isSelected = selectedCategory == category;
        return GestureDetector(
          onTap: () => onCategorySelected(category),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSize.paddingM,
              vertical: AppSize.paddingS,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? AppColors.primaryGradient
                  : null,
              color: isSelected ? null : AppColors.grey900,
              borderRadius: BorderRadius.circular(AppSize.radiusM),
              border: Border.all(
                color: isSelected ? Colors.transparent : AppColors.grey800,
              ),
            ),
            child: Text(
              category,
              style: CustomTextStyle.size14W500(
                color: isSelected ? AppColors.black100 : AppColors.grey400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}



class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primary,
                  onPrimary: AppColors.black100,
                  surface: AppColors.grey900,
                  onSurface: AppColors.white100,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null && picked != selectedDate) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSize.paddingM),
        decoration: BoxDecoration(
          color: AppColors.grey900,
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          border: Border.all(color: AppColors.grey800),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMMM dd, yyyy').format(selectedDate),
              style: CustomTextStyle.size15W400(color: AppColors.white100),
            ),
            Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}



class PersonField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String?) onPersonSelected;

  const PersonField({
    super.key,
    required this.controller,
    required this.onPersonSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: CustomTextStyle.size15W400(color: AppColors.white100),
      decoration: InputDecoration(
        hintText: 'Enter name or email',
        hintStyle: CustomTextStyle.size15W400(color: AppColors.grey500),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.people_outline,
            color: AppColors.primary,
            size: 22,
          ),
          onPressed: () {
            // TODO: Implement user search and selection
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User search coming soon!'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        filled: true,
        fillColor: AppColors.grey900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          borderSide: BorderSide(color: AppColors.grey800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          borderSide: BorderSide(color: AppColors.grey800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSize.paddingM,
          vertical: AppSize.paddingM,
        ),
      ),
      onChanged: onPersonSelected,
    );
  }
}


class EvidencePreview extends StatelessWidget {
  final EvidenceType evidenceType;
  final File? evidenceFile;
  final String? textProof;
  final VoidCallback onRemove;

  const EvidencePreview({
    super.key,
    required this.evidenceType,
    this.evidenceFile,
    this.textProof,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSize.paddingM),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(AppSize.radiusM),
        border: Border.all(color: AppColors.grey800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _getIcon(),
                  const SizedBox(width: AppSize.spacingS),
                  Text(
                    _getTitle(),
                    style: CustomTextStyle.size14W600(color: AppColors.white100),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close, color: AppColors.grey400, size: 20),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: AppSize.spacingS),
          _buildPreview(),
        ],
      ),
    );
  }

  Widget _getIcon() {
    IconData icon;
    Color color;
    
    switch (evidenceType) {
      case EvidenceType.photo:
        icon = Icons.image;
        color = AppColors.primary;
        break;
      case EvidenceType.document:
        icon = Icons.description;
        color = AppColors.info;
        break;
      case EvidenceType.audio:
        icon = Icons.audiotrack;
        color = AppColors.success;
        break;
      case EvidenceType.text:
        icon = Icons.text_snippet;
        color = AppColors.accent;
        break;
      default:
        icon = Icons.attach_file;
        color = AppColors.grey400;
    }
    
    return Icon(icon, color: color, size: 24);
  }

  String _getTitle() {
    switch (evidenceType) {
      case EvidenceType.photo:
        return 'Photo Evidence';
      case EvidenceType.document:
        return 'Document';
      case EvidenceType.audio:
        return 'Audio Recording';
      case EvidenceType.text:
        return 'Text Note';
      default:
        return 'Evidence';
    }
  }

  Widget _buildPreview() {
    switch (evidenceType) {
      case EvidenceType.photo:
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          child: Image.file(
            evidenceFile!,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      case EvidenceType.document:
        return Container(
          padding: const EdgeInsets.all(AppSize.paddingM),
          decoration: BoxDecoration(
            color: AppColors.grey800,
            borderRadius: BorderRadius.circular(AppSize.radiusM),
          ),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: AppColors.error, size: 40),
              const SizedBox(width: AppSize.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evidenceFile!.path.split('/').last,
                      style: CustomTextStyle.size13W500(color: AppColors.white100),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(evidenceFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                      style: CustomTextStyle.size11W400(color: AppColors.grey400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case EvidenceType.audio:
        return Container(
          padding: const EdgeInsets.all(AppSize.paddingM),
          decoration: BoxDecoration(
            color: AppColors.grey800,
            borderRadius: BorderRadius.circular(AppSize.radiusM),
          ),
          child: Row(
            children: [
              Icon(Icons.play_circle_filled, color: AppColors.primary, size: 40),
              const SizedBox(width: AppSize.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio Recording',
                      style: CustomTextStyle.size13W500(color: AppColors.white100),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to play',
                      style: CustomTextStyle.size11W400(color: AppColors.grey400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case EvidenceType.text:
        return Container(
          padding: const EdgeInsets.all(AppSize.paddingM),
          decoration: BoxDecoration(
            color: AppColors.grey800,
            borderRadius: BorderRadius.circular(AppSize.radiusM),
          ),
          child: Text(
            textProof!,
            style: CustomTextStyle.size14W400(color: AppColors.grey300),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}