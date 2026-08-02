// lib/pages/dashboard/profile/widgets/stats_card.dart
import 'package:flutter/material.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';

class StatsCard extends StatelessWidget {
  final int totalActions;
  final double validatedPercentage;
  final int score;
  final int level;
  final int xp;
  final int nextLevelXp;

  const StatsCard({
    super.key,
    required this.totalActions,
    required this.validatedPercentage,
    required this.score,
    required this.level,
    required this.xp,
    required this.nextLevelXp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSize.paddingM,
        vertical: AppSize.paddingS,
      ),
      padding: const EdgeInsets.all(AppSize.paddingM),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(AppSize.radiusL),
        border: Border.all(color: AppColors.grey800),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                value: '$totalActions',
                label: 'Actions',
                icon: Icons.assignment_turned_in_outlined,
              ),
              Container(width: 1, height: 36, color: AppColors.grey800),
              _StatItem(
                value: '${validatedPercentage.toInt()}%',
                label: 'Validated',
                icon: Icons.verified_outlined,
              ),
              Container(width: 1, height: 36, color: AppColors.grey800),
              _StatItem(
                value: '$score',
                label: 'Worth',
                icon: Icons.star_outline,
                iconColor: AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: AppSize.spacingM),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSize.radiusS),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, size: 16, color: AppColors.black100),
                    const SizedBox(width: 4),
                    Text(
                      'LVL $level',
                      style: CustomTextStyle.size12W600(
                        color: AppColors.black100,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSize.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'XP Progress',
                          style: CustomTextStyle.size12W400(
                            color: AppColors.grey400,
                          ),
                        ),
                        Text(
                          '$xp / $nextLevelXp',
                          style: CustomTextStyle.size12W600(
                            color: AppColors.white100,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSize.radiusS),
                      child: LinearProgressIndicator(
                        value: (xp / (nextLevelXp > 0 ? nextLevelXp : 1)).clamp(
                          0.0,
                          1.0,
                        ),
                        backgroundColor: AppColors.grey800,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? iconColor;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor ?? AppColors.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: CustomTextStyle.size16W600(color: AppColors.white100),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: CustomTextStyle.size12W400(color: AppColors.grey400),
        ),
      ],
    );
  }
}
