import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/model/profile/profile_model.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';

class BadgesSection extends StatelessWidget {
  final List<BadgeModel> badges;

  const BadgesSection({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    final earnedBadges = badges.where((b) => b.isEarned).toList();

    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSize.paddingM, vertical: AppSize.paddingS),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate('badges_title'),
                    style: CustomTextStyle.size15W600(color: AppColors.white100),
                  ),
                  Text(
                    '${earnedBadges.length}/${badges.length}',
                    style: CustomTextStyle.size13W500(color: AppColors.grey400),
                  ),
                ],
              ),
              const SizedBox(height: AppSize.spacingS),
              SizedBox(
                height: 75,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: badges.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSize.spacingM),
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    return _BadgeItem(badge: badge);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final BadgeModel badge;

  const _BadgeItem({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${badge.name}\n${badge.description}',
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: badge.isEarned ? AppColors.primaryGradient : null,
              color: badge.isEarned ? null : AppColors.grey800,
              shape: BoxShape.circle,
              border: Border.all(
                color: badge.isEarned ? Colors.transparent : AppColors.grey700,
                width: 2,
              ),
            ),
            child: Icon(
              _getBadgeIcon(badge.name),
              size: 24,
              color: badge.isEarned ? AppColors.black100 : AppColors.grey600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.name,
            style: CustomTextStyle.size10W500(
              color: badge.isEarned ? AppColors.primary : AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }



  IconData _getBadgeIcon(String badgeName) {
    final nameLower = badgeName.toLowerCase();
    if (nameLower.contains('first action')) return Icons.rocket_launch;
    if (nameLower.contains('rising star')) return Icons.star_rounded;
    if (nameLower.contains('trusted validator')) return Icons.verified_user_outlined;
    if (nameLower.contains('certified impact')) return Icons.diamond_outlined;
    if (nameLower.contains('community contributor') || nameLower.contains('5 actions')) return Icons.groups_outlined;
    if (nameLower.contains('consistency champion') || nameLower.contains('consistency')) return Icons.bolt;
    if (nameLower.contains('reputation pioneer')) return Icons.workspace_premium;
    if (nameLower.contains('master validator')) return Icons.shield;

    return Icons.military_tech_rounded;
  }
}