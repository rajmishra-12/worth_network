import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/model/moderation/blocked_user_model.dart';
import 'package:worth_network/core/repo/moderation_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  void _confirmUnblock(BuildContext context, BlockedUserModel user, ModerationRepository repo, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.grey900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.radiusL),
          side: const BorderSide(color: AppColors.grey800),
        ),
        title: Text(
          loc.translate('unblock_user_dialog_title'),
          style: CustomTextStyle.size18W600(color: AppColors.white100),
        ),
        content: Text(
          loc.translate('unblock_user_dialog_desc').replaceFirst('{username}', user.userName),
          style: CustomTextStyle.size14W400(color: AppColors.grey300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              loc.translate('cancel'),
              style: CustomTextStyle.size14W500(color: AppColors.grey400),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await repo.unblockUser(user.userId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.translate('unblocked_user_success').replaceFirst('{username}', user.userName)),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceFirst('Exception: ', '')),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.radiusM),
              ),
            ),
            child: Text(
              loc.translate('unblock_user_btn'),
              style: CustomTextStyle.size14W600(color: AppColors.white100),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ModerationRepository();

    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.grey900,
            elevation: 0,
            title: Text(
              loc.translate('blocked_users_title'),
              style: CustomTextStyle.size18W600(color: AppColors.white100),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white100),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: StreamBuilder<List<BlockedUserModel>>(
            stream: repo.getBlockedUsersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final blockedUsers = snapshot.data ?? [];

              if (blockedUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.block, size: 64, color: AppColors.grey600),
                      const SizedBox(height: AppSize.spacingM),
                      Text(
                        loc.translate('no_blocked_users_title'),
                        style: CustomTextStyle.size18W600(color: AppColors.white100),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.translate('no_blocked_users_desc'),
                        style: CustomTextStyle.size14W400(color: AppColors.grey400),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSize.paddingM),
                itemCount: blockedUsers.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSize.spacingS),
                itemBuilder: (context, index) {
                  final user = blockedUsers[index];
                  return Container(
                    padding: const EdgeInsets.all(AppSize.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.grey900,
                      borderRadius: BorderRadius.circular(AppSize.radiusL),
                      border: Border.all(color: AppColors.grey800),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.grey800,
                          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                          child: user.avatarUrl == null
                              ? Text(
                                  user.userName.isNotEmpty ? user.userName[0].toUpperCase() : 'U',
                                  style: CustomTextStyle.size16W600(color: AppColors.white100),
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSize.spacingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.userName,
                                style: CustomTextStyle.size14W600(color: AppColors.white100),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                loc.translate('user_blocked_badge'),
                                style: CustomTextStyle.size12W400(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => _confirmUnblock(context, user, repo, loc),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.grey700),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSize.radiusM),
                            ),
                          ),
                          child: Text(
                            loc.translate('unblock_user_btn'),
                            style: CustomTextStyle.size12W600(color: AppColors.white100),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
