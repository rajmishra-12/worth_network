import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/pages/network/cubit/network_cubit.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return BlocBuilder<NetworkCubit, NetworkState>(
          builder: (context, state) {
            return Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: AppSize.paddingS),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.paddingM,
                ),
                children: [
                  _buildFilterChip(
                    context: context,
                    label: loc.translate('filter_all'),
                    isSelected: state.selectedFilter == UserFilter.all,
                    onSelected: () {
                      context.read<NetworkCubit>().setFilter(UserFilter.all);
                    },
                  ),
                  const SizedBox(width: AppSize.spacingS),
                  _buildFilterChip(
                    context: context,
                    label: loc.translate('category_support'),
                    isSelected: state.selectedFilter == UserFilter.support,
                    onSelected: () {
                      context.read<NetworkCubit>().setFilter(
                        UserFilter.support,
                      );
                    },
                  ),
                  const SizedBox(width: AppSize.spacingS),
                  _buildFilterChip(
                    context: context,
                    label: loc.translate('category_work'),
                    isSelected: state.selectedFilter == UserFilter.work,
                    onSelected: () {
                      context.read<NetworkCubit>().setFilter(UserFilter.work);
                    },
                  ),
                  const SizedBox(width: AppSize.spacingS),
                  _buildFilterChip(
                    context: context,
                    label: loc.translate('category_health'),
                    isSelected: state.selectedFilter == UserFilter.health,
                    onSelected: () {
                      context.read<NetworkCubit>().setFilter(UserFilter.health);
                    },
                  ),
                  const SizedBox(width: AppSize.spacingS),
                  _buildFilterChip(
                    context: context,
                    label: loc.translate('category_community'),
                    isSelected: state.selectedFilter == UserFilter.community,
                    onSelected: () {
                      context.read<NetworkCubit>().setFilter(
                        UserFilter.community,
                      );
                    },
                  ),
                  const SizedBox(width: AppSize.spacingS),
                  _buildFilterChip(
                    context: context,
                    label: loc.translate('category_education'),
                    isSelected: state.selectedFilter == UserFilter.education,
                    onSelected: () {
                      context.read<NetworkCubit>().setFilter(
                        UserFilter.education,
                      );
                    },
                  ),
                  const SizedBox(width: AppSize.spacingS),
                  _buildFilterChip(
                    context: context,
                    label: loc.translate('category_environment'),
                    isSelected: state.selectedFilter == UserFilter.environment,
                    onSelected: () {
                      context.read<NetworkCubit>().setFilter(
                        UserFilter.environment,
                      );
                    },
                  ),
                  const SizedBox(width: AppSize.spacingS),
                  _buildFilterChip(
                    context: context,
                    label: loc.translate('category_other'),
                    isSelected: state.selectedFilter == UserFilter.other,
                    onSelected: () {
                      context.read<NetworkCubit>().setFilter(UserFilter.other);
                    },
                  ),
                  const SizedBox(width: AppSize.spacingS),
                  _buildFilterChip(
                    context: context,
                    label: loc.translate('filter_top_rated'),
                    isSelected: state.selectedFilter == UserFilter.topRated,
                    onSelected: () {
                      context.read<NetworkCubit>().setFilter(
                        UserFilter.topRated,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSize.paddingM,
          vertical: AppSize.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey900,
          borderRadius: BorderRadius.circular(AppSize.radiusXL),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey800,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: CustomTextStyle.size13W600(
              color: isSelected ? AppColors.black100 : AppColors.grey400,
            ),
          ),
        ),
      ),
    );
  }
}
