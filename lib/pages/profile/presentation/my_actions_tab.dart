import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/pages/dashboard/cubit/dashboard_cubit.dart';
import 'package:worth_network/pages/profile/cubit/profile_cubit.dart';
import 'package:worth_network/pages/profile/widgets/action_small_card.dart';

class MyActionsTab extends StatelessWidget {
  const MyActionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.myActions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: AppColors.grey700,
                    ),
                    const SizedBox(height: AppSize.spacingM),
                    Text(
                      loc.translate('no_actions_yet'),
                      style: CustomTextStyle.size16W500(color: AppColors.grey500),
                    ),
                    const SizedBox(height: AppSize.spacingS),
                    Text(
                      loc.translate('no_actions_desc'),
                      style: CustomTextStyle.size14W400(color: AppColors.grey600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSize.spacingL),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DashboardCubit>().changeTab(1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.black100,
                      ),
                      child: Text(loc.translate('add_first_action_btn')),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSize.paddingM),
              itemCount: state.myActions.length,
              itemBuilder: (context, index) {
                final action = state.myActions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSize.paddingM),
                  child: ActionCardSmall(action: action),
                );
              },
            );
          },
        );
      },
    );
  }
}