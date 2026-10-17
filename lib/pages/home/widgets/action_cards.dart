import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/repo/action_repo.dart';
import 'package:worth_network/core/repo/moderation_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/core/utils/preferences.dart';
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
              // User Info Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSize.paddingM,
                  AppSize.paddingM,
                  AppSize.paddingM,
                  AppSize.paddingS + 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: onUserTap,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.grey800,
                            backgroundImage: (action.userAvatar != null &&
                                    action.userAvatar!.isNotEmpty &&
                                    !action.userAvatar!.contains('pravatar.cc'))
                                ? NetworkImage(action.userAvatar!)
                                : null,
                            onBackgroundImageError: (action.userAvatar != null &&
                                    action.userAvatar!.isNotEmpty &&
                                    !action.userAvatar!.contains('pravatar.cc'))
                                ? (exception, stackTrace) {}
                                : null,
                            child: (action.userAvatar == null ||
                                    action.userAvatar!.isEmpty ||
                                    action.userAvatar!.contains('pravatar.cc'))
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 22,
                                    color: AppColors.grey400,
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatTimeAgo(action.createdAt, loc),
                                  style: CustomTextStyle.size12W400(
                                    color: AppColors.grey400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: AppColors.grey400, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
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
                            if (action.userId == Preferences().userId || onDeleteTap != null) ...[
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
                                ),
                            ] else ...[
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
                    const SizedBox(height: AppSize.spacingS + 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValidationBadge(status: action.validationStatus),
                        const SizedBox(width: AppSize.spacingS),
                        Flexible(
                          child: InkWell(
                            onTap: () => showScoreInfoSheet(context, action, loc),
                            borderRadius: BorderRadius.circular(AppSize.radiusM),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSize.paddingS + 2,
                                vertical: AppSize.paddingXS + 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.grey800,
                                borderRadius: BorderRadius.circular(AppSize.radiusM),
                                border: Border.all(
                                  color: getPointsColor(action).withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    action.isValidated
                                        ? Icons.star
                                        : action.validationStatus == ValidationStatus.rejected
                                            ? Icons.cancel_outlined
                                            : Icons.star_outline_rounded,
                                    color: getPointsColor(action),
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      formatPointsBadge(action, loc),
                                      style: CustomTextStyle.size11W600(
                                        color: getPointsColor(action),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 11,
                                    color: getPointsColor(action).withValues(alpha: 0.7),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
                    authorId: action.userId,
                    validatorId: action.validatorId,
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
              // Subtle Positive Impact Note (compact, non-intrusive, non-expanding)
              if (action.impact != null && action.impact!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.spa_outlined,
                        size: 13,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${loc.translate('impact_label')}: ',
                                style: CustomTextStyle.size12W500(
                                  color: AppColors.grey400,
                                ),
                              ),
                              TextSpan(
                                text: action.impact!,
                                style: CustomTextStyle.size12W400(
                                  color: AppColors.grey500,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  static String formatPointsBadge(ActionModel action, AppLocalizations loc) {
    if (action.isValidated) {
      return loc.translateFormatted('points_earned_badge', {'pts': '${action.score}'});
    } else if (action.validationStatus == ValidationStatus.rejected) {
      return loc.translate('points_rejected_badge');
    } else if (action.validationStatus == ValidationStatus.pending || action.isPendingIndependentReview) {
      return loc.translateFormatted('points_pending_badge', {'pts': '${action.score}'});
    } else {
      // Self-declared action that has not yet been submitted/validated
      return loc.translateFormatted('points_after_validation_badge', {'pts': '${action.score}'});
    }
  }

  static Color getPointsColor(ActionModel action) {
    if (action.isValidated) {
      return AppColors.accent;
    } else if (action.validationStatus == ValidationStatus.rejected) {
      return AppColors.error;
    } else {
      return AppColors.warning;
    }
  }

  static void showScoreInfoSheet(BuildContext context, ActionModel action, AppLocalizations loc) {
    final isVal = action.isValidated;
    final isRej = action.validationStatus == ValidationStatus.rejected;
    final badgeColor = isVal
        ? AppColors.accent
        : isRej
            ? AppColors.error
            : AppColors.warning;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.grey900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.radiusL)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSize.paddingL, AppSize.paddingM, AppSize.paddingL, AppSize.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSize.spacingL),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isVal
                      ? Icons.verified
                      : isRej
                          ? Icons.cancel_outlined
                          : Icons.stars_rounded,
                  color: badgeColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSize.spacingM),
              Text(
                isVal
                    ? '${loc.translate('earned_reward_label')}: +${action.score} ${loc.translate('points_label')}'
                    : isRej
                        ? loc.translate('validation_rejected_label')
                        : '${loc.translate('potential_reward_label')}: +${action.score} ${loc.translate('points_label')}',
                style: CustomTextStyle.size18W600(color: AppColors.white100),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSize.spacingS),
              Text(
                isVal
                    ? loc.translate('action_validated_reward_earned')
                    : isRej
                        ? (action.rejectionReason != null && action.rejectionReason!.isNotEmpty
                            ? '${loc.translate('rejection_reason_prefix')}: ${action.rejectionReason}'
                            : loc.translate('action_rejected_no_points'))
                        : loc.translate('points_awarded_after_validation'),
                style: CustomTextStyle.size14W400(color: AppColors.grey400),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSize.spacingXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSize.radiusM),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(
                    loc.translate('dismiss'),
                    style: CustomTextStyle.size14W600(color: AppColors.black100),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}