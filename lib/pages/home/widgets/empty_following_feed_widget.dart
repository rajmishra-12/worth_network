import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';

class EmptyFollowingFeedWidget extends StatelessWidget {
  final VoidCallback onExploreTap;

  const EmptyFollowingFeedWidget({
    super.key,
    required this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.grey900,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.grey800,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.people_outline,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSize.spacingL),
                Text(
                  loc.translate('no_following_feed_title'),
                  style: CustomTextStyle.size18W600(color: AppColors.white100),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSize.spacingS),
                Text(
                  loc.translate('no_following_feed_desc'),
                  style: CustomTextStyle.size14W400(color: AppColors.grey400),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSize.spacingXL),
                ElevatedButton.icon(
                  onPressed: onExploreTap,
                  icon: const Icon(Icons.search, size: 18, color: AppColors.black100),
                  label: Text(
                    loc.translate('explore_network_btn'),
                    style: CustomTextStyle.size14W600(color: AppColors.black100),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.paddingL,
                      vertical: AppSize.paddingM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSize.radiusM),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
