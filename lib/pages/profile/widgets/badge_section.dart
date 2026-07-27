// lib/pages/dashboard/profile/widgets/badges_section.dart
import 'package:flutter/material.dart';
import 'package:worth_network/core/model/profile/profile_model.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';


class BadgesSection extends StatelessWidget {
  final List<BadgeModel> badges;

  const BadgesSection({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    final earnedBadges = badges.where((b) => b.isEarned).toList();
    final lockedBadges = badges.where((b) => !b.isEarned).toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSize.paddingM),
      padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Badges',
                style: CustomTextStyle.size16W600(color: AppColors.white100),
              ),
              Text(
                '${earnedBadges.length}/${badges.length}',
                style: CustomTextStyle.size14W500(color: AppColors.grey400),
              ),
            ],
          ),
          const SizedBox(height: AppSize.spacingM),
          SizedBox(
            height: 80,
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: badge.isEarned
                  ? AppColors.primaryGradient
                  : null,
              color: badge.isEarned ? null : AppColors.grey800,
              shape: BoxShape.circle,
              border: Border.all(
                color: badge.isEarned ? Colors.transparent : AppColors.grey700,
                width: 2,
              ),
            ),
            child: Icon(
              _getBadgeIcon(badge.name),
              size: 28,
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
    switch (badgeName.toLowerCase()) {
      case 'first action':
        return Icons.rocket_launch;
      case '5 actions':
        return Icons.five_k;
      case '10 actions':
        return Icons.ten_k;
      case 'consistency':
        return Icons.calendar_today;
      case 'helper':
        return Icons.favorite;
      case 'leader':
        return Icons.emoji_events;
      default:
        return Icons.emoji_events;
    }
  }
}