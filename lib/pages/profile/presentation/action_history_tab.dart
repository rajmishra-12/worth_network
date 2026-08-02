import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/pages/profile/cubit/profile_cubit.dart';
import 'package:worth_network/pages/profile/widgets/action_small_card.dart';

class ActionHistoryTab extends StatelessWidget {
  const ActionHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.actionHistory.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_outlined,
                      size: 64,
                      color: AppColors.grey700,
                    ),
                    const SizedBox(height: AppSize.spacingM),
                    Text(
                      loc.translate('no_history_yet'),
                      style: CustomTextStyle.size16W500(color: AppColors.grey500),
                    ),
                    const SizedBox(height: AppSize.spacingS),
                    Text(
                      loc.translate('action_history'),
                      style: CustomTextStyle.size14W400(color: AppColors.grey600),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSize.paddingM),
              itemCount: state.actionHistory.length,
              itemBuilder: (context, index) {
                final history = state.actionHistory[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSize.paddingM),
                  child: HistoryCard(history: history),
                );
              },
            );
          },
        );
      },
    );
  }
}