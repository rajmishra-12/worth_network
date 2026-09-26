import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/repo/follow_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/pages/network/cubit/follow_cubit.dart';

class FollowButton extends StatelessWidget {
  final String targetUserId;
  final VoidCallback? onFollowChanged;

  const FollowButton({
    super.key,
    required this.targetUserId,
    this.onFollowChanged,
  });

  @override
  Widget build(BuildContext context) {
    final followRepo = FollowRepository();
    final currentUid = followRepo.currentUserId;

    // Do not show follow button for self
    if (currentUid != null && currentUid == targetUserId) {
      return const SizedBox.shrink();
    }

    return BlocProvider(
      create: (context) => FollowCubit(followRepo: followRepo)..init(targetUserId),
      child: BlocConsumer<FollowCubit, FollowState>(
        listenWhen: (previous, current) {
          return (previous.isToggling && !current.isToggling && current.errorMessage == null) ||
                 (current.errorMessage != null);
        },
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (onFollowChanged != null) {
            onFollowChanged!();
          }
        },
        builder: (context, state) {
          return BlocBuilder<LocaleCubit, String>(
            builder: (context, localeCode) {
              final loc = AppLocalizations(localeCode);

              if (state.isToggling) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.grey800,
                    borderRadius: BorderRadius.circular(AppSize.radiusM),
                  ),
                  child: const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }

              if (state.isFollowing) {
                return OutlinedButton.icon(
                  onPressed: () {
                    context.read<FollowCubit>().toggleFollow(targetUserId);
                  },
                  icon: const Icon(Icons.check, size: 14, color: AppColors.primary),
                  label: Text(
                    loc.translate('btn_following'),
                    style: CustomTextStyle.size12W600(color: AppColors.white100),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    backgroundColor: AppColors.grey900,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSize.radiusM),
                    ),
                  ),
                );
              }

              return ElevatedButton.icon(
                onPressed: () {
                  context.read<FollowCubit>().toggleFollow(targetUserId);
                },
                icon: const Icon(Icons.person_add_outlined, size: 14, color: AppColors.black100),
                label: Text(
                  loc.translate('btn_follow'),
                  style: CustomTextStyle.size12W600(color: AppColors.black100),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.black100,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSize.radiusM),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
