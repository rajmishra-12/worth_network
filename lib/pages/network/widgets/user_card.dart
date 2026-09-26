// lib/pages/dashboard/network/widgets/user_card.dart
import 'package:flutter/material.dart';
import 'package:worth_network/core/model/user/user_model.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';

import 'package:worth_network/pages/network/widgets/follow_button.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final VoidCallback? onFollowChanged;

  const UserCard({
    super.key,
    required this.user,
    required this.onTap,
    this.onFollowChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSize.paddingM,
          vertical: AppSize.paddingS,
        ),
        padding: const EdgeInsets.all(AppSize.paddingM),
        decoration: BoxDecoration(
          color: AppColors.grey900,
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          border: Border.all(color: AppColors.grey800, width: 1),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.grey800,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.name[0].toUpperCase(),
                          style: CustomTextStyle.size18W600(
                            color: AppColors.white100,
                          ),
                        )
                      : null,
                ),
                if (user.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.grey900, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSize.spacingM),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: CustomTextStyle.size16W600(
                            color: AppColors.white100,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.verified)
                        Container(
                          margin: const EdgeInsets.only(
                            left: AppSize.spacingXS,
                          ),
                          child: Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSize.spacingXS),
                  Row(
                    children: [
                      // Level (Future-ready)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSize.paddingS,
                          vertical: AppSize.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grey800,
                          borderRadius: BorderRadius.circular(AppSize.radiusS),
                        ),
                        child: Text(
                          'Level ${user.level}',
                          style: CustomTextStyle.size10W600(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSize.spacingS),
                      // Score
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text(
                            '${user.score}',
                            style: CustomTextStyle.size12W500(
                              color: AppColors.grey400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FollowButton(
              targetUserId: user.id,
              onFollowChanged: onFollowChanged,
            ),
          ],
        ),
      ),
    );
  }
}
