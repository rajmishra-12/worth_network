// lib/pages/dashboard/network/widgets/filter_chips.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/pages/network/cubit/network_cubit.dart';


class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, state) {
        return Container(
          height: 50,
          margin: const EdgeInsets.only(bottom: AppSize.paddingS),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
            children: [
              _buildFilterChip(
                context: context,
                label: 'All',
                isSelected: state.selectedFilter == UserFilter.all,
                onSelected: () {
                  context.read<NetworkCubit>().setFilter(UserFilter.all);
                },
              ),
              const SizedBox(width: AppSize.spacingS),
              _buildFilterChip(
                context: context,
                label: 'Near You',
                isSelected: state.selectedFilter == UserFilter.local,
                onSelected: () {
                  context.read<NetworkCubit>().setFilter(UserFilter.local);
                },
              ),
              const SizedBox(width: AppSize.spacingS),
              _buildFilterChip(
                context: context,
                label: 'Support',
                isSelected: state.selectedFilter == UserFilter.support,
                onSelected: () {
                  context.read<NetworkCubit>().setFilter(UserFilter.support);
                },
              ),
              const SizedBox(width: AppSize.spacingS),
              _buildFilterChip(
                context: context,
                label: 'Work',
                isSelected: state.selectedFilter == UserFilter.work,
                onSelected: () {
                  context.read<NetworkCubit>().setFilter(UserFilter.work);
                },
              ),
              const SizedBox(width: AppSize.spacingS),
              _buildFilterChip(
                context: context,
                label: 'Health',
                isSelected: state.selectedFilter == UserFilter.health,
                onSelected: () {
                  context.read<NetworkCubit>().setFilter(UserFilter.health);
                },
              ),
              const SizedBox(width: AppSize.spacingS),
              _buildFilterChip(
                context: context,
                label: 'Top Rated',
                isSelected: state.selectedFilter == UserFilter.topRated,
                onSelected: () {
                  context.read<NetworkCubit>().setFilter(UserFilter.topRated);
                },
              ),
            ],
          ),
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
    return FilterChip(
      label: Text(
        label,
        style: CustomTextStyle.size13W500(
          color: isSelected ? AppColors.black100 : AppColors.grey400,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: AppColors.grey900,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.black100,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.paddingM,
        vertical: AppSize.paddingS,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? Colors.transparent : AppColors.grey800,
          width: 1,
        ),
      ),
    );
  }
}