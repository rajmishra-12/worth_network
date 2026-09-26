// lib/pages/dashboard/home/widgets/empty_feed_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';

class EmptyFeedWidget extends StatelessWidget {
  final VoidCallback onActionTap;

  const EmptyFeedWidget({super.key, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSize.paddingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt_outlined,
                    size: 60,
                    color: AppColors.black100,
                  ),
                ),
                const SizedBox(height: AppSize.spacingXL),
                Text(
                  loc.translate('no_actions_yet'),
                  style: CustomTextStyle.size14W500(
                    color: AppColors.white100,
                  )
                ),
                const SizedBox(height: AppSize.spacingM),
                Text(
                  loc.translate('no_actions_desc'),
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.size14W500(
                    color: AppColors.white100,
                  )
                ),
                const SizedBox(height: AppSize.spacingXL),
                ElevatedButton(
                  onPressed: onActionTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.black100,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.paddingXL,
                      vertical: AppSize.paddingM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSize.radiusM),
                    ),
                  ),
                  child: Text(
                    loc.translate('add_first_action_btn'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
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


class FeedShimmer extends StatelessWidget {
  const FeedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey800,
      highlightColor: AppColors.grey700,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSize.paddingM),
            decoration: BoxDecoration(
              color: AppColors.grey900,
              borderRadius: BorderRadius.circular(AppSize.radiusL),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSize.paddingM),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.grey800,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSize.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 14,
                              color: AppColors.grey800,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 80,
                              height: 10,
                              color: AppColors.grey800,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
                  child: Container(
                    width: double.infinity,
                    height: 16,
                    color: AppColors.grey800,
                  ),
                ),
                const SizedBox(height: AppSize.spacingM),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: AppColors.grey800,
                  ),
                ),
                const SizedBox(height: AppSize.spacingM),
              ],
            ),
          );
        },
      ),
    );
  }
}



class ValidationBadge extends StatelessWidget {
  final ValidationStatus status;

  const ValidationBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        final (color, labelKey, icon) = _getStatusDetails();

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSize.radiusM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  loc.translate(labelKey),
                  style: CustomTextStyle.size11W600(
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  (Color, String, IconData) _getStatusDetails() {
    switch (status) {
      case ValidationStatus.certified:
        return (AppColors.accent, 'status_certified', Icons.verified);
      case ValidationStatus.confirmed:
        return (AppColors.primary, 'status_confirmed', Icons.check_circle_outline);
      case ValidationStatus.pending:
        return (AppColors.warning, 'status_pending', Icons.timer_outlined);
      case ValidationStatus.rejected:
        return (AppColors.error, 'status_rejected', Icons.cancel_outlined);
      case ValidationStatus.declared:
        return (AppColors.grey500, 'status_declared', Icons.hourglass_empty);
    }
  }
}