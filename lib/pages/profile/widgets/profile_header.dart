// lib/pages/dashboard/profile/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:worth_network/core/model/profile/profile_model.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';


class ProfileHeader extends StatelessWidget {
  final ProfileModel profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSize.paddingL),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.grey800,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: profile.avatarUrl == null
                      ? Text(
                          profile.name[0].toUpperCase(),
                          style: CustomTextStyle.size30W600(
                            color: AppColors.white100,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.grey900,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSize.spacingM),
          
          // Name
          Text(
            profile.name,
            style: CustomTextStyle.size20W600(color: AppColors.white100),
          ),
          const SizedBox(height: AppSize.spacingXS),
          
          // Bio
          if (profile.bio != null && profile.bio!.isNotEmpty)
            Text(
              profile.bio!,
              style: CustomTextStyle.size14W400(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: AppSize.spacingM),
          
          // Edit Profile Button
          OutlinedButton(
            onPressed: () {
              // Navigate to edit profile
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.grey700),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.radiusM),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSize.paddingL,
                vertical: AppSize.paddingS,
              ),
            ),
            child: Text(
              'Edit Profile',
              style: CustomTextStyle.size14W500(color: AppColors.white100),
            ),
          ),
        ],
      ),
    );
  }
}