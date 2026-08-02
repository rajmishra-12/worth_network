import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/model/profile/history_model.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/pages/home/widgets/empty_feed_widget.dart';


class ActionCardSmall extends StatelessWidget {
  final ActionModel action;

  const ActionCardSmall({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSize.paddingM),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(AppSize.radiusM),
        border: Border.all(color: AppColors.grey800),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSize.radiusM),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.black100,
              size: 30,
            ),
          ),
          const SizedBox(width: AppSize.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  style: CustomTextStyle.size14W600(color: AppColors.white100),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  action.category,
                  style: CustomTextStyle.size11W400(color: AppColors.grey400),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ValidationBadge(status: action.validationStatus),
                    const SizedBox(width: AppSize.spacingS),
                    Text(
                      '${action.score} pts',
                      style: CustomTextStyle.size11W500(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.grey500,
          ),
        ],
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final HistoryItem history;

  const HistoryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        final statusKey = 'status_${history.status.toLowerCase()}';
        final translatedStatus = loc.translate(statusKey);
        final displayStatus = translatedStatus.startsWith('status_') ? history.status : translatedStatus;

        return Container(
          padding: const EdgeInsets.all(AppSize.paddingM),
          decoration: BoxDecoration(
            color: AppColors.grey900,
            borderRadius: BorderRadius.circular(AppSize.radiusM),
            border: Border.all(color: AppColors.grey800),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: history.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSize.radiusM),
                ),
                child: Icon(
                  _getStatusIcon(history.status),
                  color: history.statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSize.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.title,
                      style: CustomTextStyle.size14W600(color: AppColors.white100),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(history.date),
                      style: CustomTextStyle.size11W400(color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.paddingS,
                      vertical: AppSize.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: history.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSize.radiusS),
                    ),
                    child: Text(
                      displayStatus,
                      style: CustomTextStyle.size10W500(
                        color: history.statusColor,
                      ),
                    ),
                  ),
                  if (history.points > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${history.points} pts',
                        style: CustomTextStyle.size11W500(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'validated':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_empty;
      case 'partially validated':
        return Icons.pending_actions;
      default:
        return Icons.error_outline;
    }
  }
}