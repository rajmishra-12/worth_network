import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/repo/moderation_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/pages/home/cubit/home_cubit.dart';
import 'package:worth_network/pages/home/widgets/empty_feed_widget.dart';
import 'package:worth_network/pages/home/widgets/proof_card.dart';
import 'package:worth_network/pages/moderation/widgets/report_dialog.dart';

class ActionCard extends StatelessWidget {
  final ActionModel action;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onUserTap;
  final VoidCallback? onDeleteTap;

  const ActionCard({
    super.key,
    required this.action,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onUserTap,
    this.onDeleteTap,
  });

  void _showDeleteConfirmation(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.grey900,
        title: Text(
          loc.translate('delete_action_title'),
          style: CustomTextStyle.size18W600(color: AppColors.white100),
        ),
        content: Text(
          loc.translate('delete_action_desc'),
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
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (onDeleteTap != null) onDeleteTap!();
            },
            child: Text(
              loc.translate('delete_btn'),
              style: CustomTextStyle.size14W600(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBlockUser(BuildContext context, String userId, String userName, String? userAvatar, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.grey900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.radiusL),
          side: const BorderSide(color: AppColors.grey800),
        ),
        title: Text(loc.translate('block_user_dialog_title'), style: CustomTextStyle.size18W600(color: AppColors.white100)),
        content: Text(
          loc.translate('block_user_dialog_desc'),
          style: CustomTextStyle.size14W400(color: AppColors.grey300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.translate('cancel'), style: CustomTextStyle.size14W500(color: AppColors.grey400)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ModerationRepository().blockUser(
                  targetUserId: userId,
                  targetUserName: userName,
                  targetUserAvatar: userAvatar,
                );
                if (context.mounted) {
                  try {
                    context.read<HomeCubit>().removeActionsByBlockedUser(userId);
                  } catch (_) {}
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.translate('block_user_success')), backgroundColor: AppColors.success),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(loc.translate('block_user'), style: CustomTextStyle.size14W600(color: AppColors.white100)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        final localizedCategory = loc.translate('category_${action.category.toLowerCase()}');
        final categoryDisplay = localizedCategory.startsWith('category_') ? action.category : localizedCategory;

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSize.paddingM,
            vertical: AppSize.paddingS,
          ),
          decoration: BoxDecoration(
            color: AppColors.grey900,
            borderRadius: BorderRadius.circular(AppSize.radiusL),
            border: Border.all(
              color: AppColors.grey800,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Row
              Padding(
                padding: const EdgeInsets.all(AppSize.paddingM),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onUserTap,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.grey800,
                        backgroundImage: action.userAvatar != null
                            ? NetworkImage(action.userAvatar!)
                            : null,
                        child: action.userAvatar == null
                            ? Text(
                                action.userName.isNotEmpty ? action.userName[0] : 'U',
                                style: CustomTextStyle.size14W500(
                                  color: AppColors.white100,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppSize.spacingM),
                    Expanded(
                      child: GestureDetector(
                        onTap: onUserTap,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action.userName,
                              style: CustomTextStyle.size14W600(
                                color: AppColors.white100,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  _formatTimeAgo(action.createdAt, loc),
                                  style: CustomTextStyle.size12W400(
                                    color: AppColors.grey400,
                                  ),
                                ),
                                const SizedBox(width: AppSize.spacingS),
                                Flexible(
                                  child: ValidationBadge(status: action.validationStatus),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSize.paddingS,
                        vertical: AppSize.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey800,
                        borderRadius: BorderRadius.circular(AppSize.radiusM),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.accent,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${action.score}',
                            style: CustomTextStyle.size14W500(
                              color: AppColors.white100,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppColors.grey400, size: 20),
                      color: AppColors.grey900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSize.radiusS),
                        side: const BorderSide(color: AppColors.grey800),
                      ),
                      onSelected: (value) async {
                        if (value == 'delete') {
                          _showDeleteConfirmation(context, loc);
                        } else if (value == 'report') {
                          ReportDialog.show(
                            context,
                            reportedUserId: action.userId,
                            reportedUserName: action.userName,
                            contentId: action.id,
                            contentType: 'action',
                            contentPreview: '${action.title}\n${action.description}',
                          );
                        } else if (value == 'block') {
                          _confirmBlockUser(context, action.userId, action.userName, action.userAvatar, loc);
                        }
                      },
                      itemBuilder: (context) => [
                        if (onDeleteTap != null)
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                const SizedBox(width: 8),
                                Text(loc.translate('delete_btn'), style: CustomTextStyle.size14W500(color: AppColors.error)),
                              ],
                            ),
                          )
                        else ...[
                          PopupMenuItem(
                            value: 'report',
                            child: Row(
                              children: [
                                const Icon(Icons.flag_outlined, color: AppColors.warning, size: 18),
                                const SizedBox(width: 8),
                                Text(loc.translate('report_action'), style: CustomTextStyle.size14W500(color: AppColors.white100)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'block',
                            child: Row(
                              children: [
                                const Icon(Icons.block_outlined, color: AppColors.error, size: 18),
                                const SizedBox(width: 8),
                                Text(loc.translate('block_user'), style: CustomTextStyle.size14W500(color: AppColors.error)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
                child: Text(
                  action.title,
                  style: CustomTextStyle.size14W500(
                    color: AppColors.white100,
                  ),
                ),
              ),
              // Category Chip
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSize.paddingM,
                  top: AppSize.paddingS,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.paddingS,
                    vertical: AppSize.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(action.category).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSize.radiusM),
                  ),
                  child: Text(
                    categoryDisplay,
                    style: CustomTextStyle.size14W500(
                      color: _getCategoryColor(action.category),
                    ),
                  ),
                ),
              ),
              // Dynamic Proof Preview (Photo, Document, Audio, Text Note, Link)
              if (action.evidences.isNotEmpty ||
                  (action.proofUrl != null && action.proofUrl!.isNotEmpty) ||
                  (action.textProof != null && action.textProof!.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
                  child: ProofCard(
                    evidences: action.evidences.isNotEmpty ? action.evidences : null,
                    proofType: action.proofType,
                    proofUrl: action.proofUrl,
                    textProof: action.textProof,
                  ),
                ),
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
                child: Text(
                  action.description,
                  style: CustomTextStyle.size14W600(
                    color: AppColors.grey300,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSize.paddingS,
                  AppSize.paddingM,
                  AppSize.paddingS,
                  AppSize.paddingS,
                ),
                child: Row(
                  children: [
                    _buildActionButton(
                      icon: action.isLikedByUser
                          ? Icons.favorite
                          : Icons.favorite_border_outlined,
                      label: '${action.likesCount}',
                      onTap: onLikeTap,
                      isActive: action.isLikedByUser,
                    ),
                    const SizedBox(width: AppSize.spacingM),
                    _buildActionButton(
                      icon: Icons.comment_outlined,
                      label: '${action.commentsCount}',
                      onTap: onCommentTap,
                      isActive: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive ? AppColors.primary : AppColors.grey500,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: CustomTextStyle.size14W600(
              color: isActive ? AppColors.primary : AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime, AppLocalizations loc) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7}w';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return loc.translate('just_now');
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'support':
        return AppColors.success;
      case 'health':
        return AppColors.info;
      case 'work':
        return AppColors.primary;
      default:
        return AppColors.grey400;
    }
  }
}