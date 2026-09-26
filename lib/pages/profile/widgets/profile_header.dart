import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/constants/profile_constants.dart';
import 'package:worth_network/core/model/profile/profile_model.dart';
import 'package:worth_network/core/repo/follow_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileModel profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.paddingM,
        vertical: AppSize.paddingS,
      ),
      child: Column(
        children: [
          // Avatar with gradient border & edit button
          GestureDetector(
            onTap: () => context.push('/edit-profile'),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.grey900,
                    backgroundImage: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child: profile.avatarUrl == null || profile.avatarUrl!.isEmpty
                        ? Text(
                            profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                            style: CustomTextStyle.size24W600(color: AppColors.white100),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.black100,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: const Icon(Icons.edit_outlined, size: 13, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSize.spacingS),

          // Name & Verified Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                profile.name,
                style: CustomTextStyle.size18W600(color: AppColors.white100),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.verified, size: 16, color: AppColors.primary),
            ],
          ),

          // Bio
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              profile.bio!,
              style: CustomTextStyle.size13W400(color: AppColors.grey400),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Account Type Badge
          if (profile.accountType != null && profile.accountType!.isNotEmpty) ...[
            const SizedBox(height: 8),
            BlocBuilder<LocaleCubit, String>(
              builder: (context, localeCode) {
                final loc = AppLocalizations(localeCode);
                final accType = ProfileConstants.getAccountType(profile.accountType);
                if (accType == null) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSize.radiusM),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(accType.icon, size: 13, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Text(
                        accType.getLocalizedLabel(loc),
                        style: CustomTextStyle.size12W500(color: AppColors.primary),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],

          // Roles & Domains Tags
          if (profile.roles.isNotEmpty) ...[
            const SizedBox(height: 8),
            BlocBuilder<LocaleCubit, String>(
              builder: (context, localeCode) {
                final loc = AppLocalizations(localeCode);
                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: profile.roles.map((rKey) {
                    final rOption = ProfileConstants.getRole(rKey);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.grey800,
                        borderRadius: BorderRadius.circular(AppSize.radiusS),
                        border: Border.all(color: AppColors.grey700),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(rOption.icon, size: 12, color: AppColors.white100),
                          const SizedBox(width: 4),
                          Text(
                            rOption.getLocalizedLabel(loc),
                            style: CustomTextStyle.size11W400(color: AppColors.white100),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
          const SizedBox(height: AppSize.spacingM),

          // Followers & Following Metrics Row
          StreamBuilder<Map<String, int>>(
            stream: FollowRepository().getUserMetricsStream(profile.id),
            builder: (context, snapshot) {
              final metrics = snapshot.data;
              final followersCount = metrics?['followers'] ?? profile.followersCount;
              final followingCount = metrics?['following'] ?? profile.followingCount;

              return BlocBuilder<LocaleCubit, String>(
                builder: (context, localeCode) {
                  final loc = AppLocalizations(localeCode);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.push('/user-connections', extra: {
                            'userId': profile.id,
                            'userName': profile.name,
                            'initialTabIndex': 0,
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              '$followersCount',
                              style: CustomTextStyle.size16W600(color: AppColors.white100),
                            ),
                            Text(
                              loc.translate('followers_count'),
                              style: CustomTextStyle.size12W400(color: AppColors.grey400),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSize.spacingXL),
                      Container(
                        height: 24,
                        width: 1,
                        color: AppColors.grey800,
                      ),
                      const SizedBox(width: AppSize.spacingXL),
                      GestureDetector(
                        onTap: () {
                          context.push('/user-connections', extra: {
                            'userId': profile.id,
                            'userName': profile.name,
                            'initialTabIndex': 1,
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              '$followingCount',
                              style: CustomTextStyle.size16W600(color: AppColors.white100),
                            ),
                            Text(
                              loc.translate('following_count'),
                              style: CustomTextStyle.size12W400(color: AppColors.grey400),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: AppSize.spacingM),

          // Edit Profile Button
          BlocBuilder<LocaleCubit, String>(
            builder: (context, localeCode) {
              final loc = AppLocalizations(localeCode);
              return OutlinedButton.icon(
                onPressed: () => context.push('/edit-profile'),
                icon: const Icon(Icons.tune_rounded, size: 15, color: AppColors.white100),
                label: Text(
                  loc.translate('edit_profile_title'),
                  style: CustomTextStyle.size13W500(color: AppColors.white100),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.grey800),
                  backgroundColor: AppColors.grey900.withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSize.radiusL),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}