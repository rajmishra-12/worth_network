import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/pages/action/cubit/add_action_cubit.dart';
import 'package:worth_network/pages/home/widgets/proof_card.dart';

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
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return Wrap(
          spacing: AppSize.spacingS,
          runSpacing: AppSize.spacingS,
          children: categories.map((category) {
            final isSelected = selectedCategory == category;
            final localized = loc.translate('category_${category.toLowerCase()}');
            final displayCategory = localized.startsWith('category_') ? category : localized;

            return GestureDetector(
              onTap: () => onCategorySelected(category),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.paddingM,
                  vertical: AppSize.paddingS,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : AppColors.grey900,
                  borderRadius: BorderRadius.circular(AppSize.radiusM),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.grey800,
                  ),
                ),
                child: Text(
                  displayCategory,
                  style: CustomTextStyle.size14W500(
                    color: isSelected ? AppColors.black100 : AppColors.grey400,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
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
            Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class PersonField extends StatelessWidget {
  final TextEditingController controller;
  final AddActionCubit cubit;
  final AddActionState state;

  const PersonField({
    super.key,
    required this.controller,
    required this.cubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);

        // If a validator is already selected, display selected validator card
        if (state.selectedValidator != null) {
          final validator = state.selectedValidator!;
          final avatarUrl = validator['avatarUrl'] as String?;
          final name = validator['name'] ?? 'User';
          final username = validator['username'] ?? '';

          return Container(
            padding: const EdgeInsets.all(AppSize.paddingM),
            decoration: BoxDecoration(
              color: AppColors.grey900,
              borderRadius: BorderRadius.circular(AppSize.radiusM),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.grey800,
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null || avatarUrl.isEmpty
                      ? Text(
                          name[0].toUpperCase(),
                          style: CustomTextStyle.size14W600(
                            color: AppColors.white100,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppSize.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: CustomTextStyle.size15W600(
                          color: AppColors.white100,
                        ),
                      ),
                      if (username.isNotEmpty)
                        Text(
                          '@$username',
                          style: CustomTextStyle.size13W400(
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    onPressed: () {
                      controller.clear();
                      cubit.removeValidator();
                    },
                  ),
                ),
              ],
            ),
          );
        }

        // Otherwise render real-time search field
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: controller,
              style: CustomTextStyle.size15W400(color: AppColors.white100),
              decoration: InputDecoration(
                hintText: loc.translate('search_validator_hint'),
                hintStyle: CustomTextStyle.size14W400(color: AppColors.grey500),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                  size: 20,
                ),
                suffixIcon: state.isSearchingUsers
                    ? const UnconstrainedBox(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : (controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.grey400,
                                size: 18,
                              ),
                              onPressed: () {
                                controller.clear();
                                cubit.searchUsers('');
                              },
                            )
                          : null),
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
              onChanged: (val) {
                cubit.searchUsers(val);
              },
            ),
            if (state.searchResults.isNotEmpty) ...[
              const SizedBox(height: AppSize.spacingS),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: AppColors.grey900,
                  borderRadius: BorderRadius.circular(AppSize.radiusM),
                  border: Border.all(color: AppColors.grey800),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: state.searchResults.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: AppColors.grey800),
                  itemBuilder: (context, index) {
                    final user = state.searchResults[index];
                    final avatarUrl = user['avatarUrl'] as String?;
                    final name = user['name'] ?? 'User';
                    final username = user['username'] ?? '';

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.grey800,
                        backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                            ? NetworkImage(avatarUrl)
                            : null,
                        child: avatarUrl == null || avatarUrl.isEmpty
                            ? Text(
                                name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.white100,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        name,
                        style: CustomTextStyle.size14W600(
                          color: AppColors.white100,
                        ),
                      ),
                      subtitle: Text(
                        '@$username',
                        style: CustomTextStyle.size12W400(color: AppColors.grey400),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          loc.translate('select_btn'),
                          style: CustomTextStyle.size12W600(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      onTap: () {
                        cubit.selectValidator(user);
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
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
    return ProofCard(
      proofType: evidenceType.name,
      localFile: evidenceFile,
      textProof: textProof,
      onRemove: onRemove,
    );
  }
}
