import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/repo/action_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/pages/home/widgets/action_cards.dart';
import 'package:worth_network/pages/home/widgets/empty_feed_widget.dart';
import 'package:worth_network/pages/home/widgets/proof_card.dart';

class ActionDetailsScreen extends StatefulWidget {
  final ActionModel action;

  const ActionDetailsScreen({super.key, required this.action});

  @override
  State<ActionDetailsScreen> createState() => _ActionDetailsScreenState();
}

class _ActionDetailsScreenState extends State<ActionDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ActionRepository _actionRepo = ActionRepository();
  bool _isSubmittingComment = false;

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmittingComment) return;

    setState(() => _isSubmittingComment = true);
    try {
      await _actionRepo.addComment(widget.action.id, text);
      _commentController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    } catch (e) {
      if (mounted) {
        final localeCode = context.read<LocaleCubit>().state;
        final loc = AppLocalizations(localeCode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('failed_to_add_comment')}$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingComment = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return StreamBuilder<ActionModel?>(
          stream: _actionRepo.getActionStream(widget.action.id),
          builder: (context, snapshot) {
            final action = snapshot.data ?? widget.action;
            final isOwner = action.userId == _actionRepo.currentUserId || action.userId == 'currentUser';
            final isValidator = action.validatorId != null &&
                action.validatorId == _actionRepo.currentUserId;


            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.white100),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  loc.translate('action_details_title'),
                  style: CustomTextStyle.size18W600(color: AppColors.white100),
                ),
                actions: [
                  if (isOwner)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () {
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
                                onPressed: () async {
                                  Navigator.pop(dialogContext);
                                  await _actionRepo.deleteAction(action.id);
                                  if (context.mounted) {
                                    context.pop();
                                  }
                                },
                                child: Text(
                                  loc.translate('delete_btn'),
                                  style: CustomTextStyle.size14W600(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),

          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSize.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Validator banner if assigned validator and status is pending
                      if (isValidator && action.validationStatus == ValidationStatus.pending) ...[

                    Container(
                      padding: const EdgeInsets.all(AppSize.paddingM),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.2),
                            AppColors.grey900,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppSize.radiusM),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_outlined, color: AppColors.primary, size: 28),
                          const SizedBox(width: AppSize.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.translate('validation_requested_title'),
                                  style: CustomTextStyle.size15W600(color: AppColors.white100),
                                ),
                                Text(
                                  loc.translate('validation_requested_subtitle'),
                                  style: CustomTextStyle.size12W400(color: AppColors.grey400),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSize.radiusS),
                              ),
                            ),
                            onPressed: () {
                              context.push('/validation-request', extra: action);
                            },
                            child: Text(
                              loc.translate('validate_btn'),
                              style: CustomTextStyle.size13W600(color: AppColors.black100),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSize.spacingL),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            context.push('/user-detail', extra: {
                              'userId': action.userId,
                              'userName': action.userName,
                              'userAvatar': action.userAvatar,
                            });
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.grey800,
                                backgroundImage: action.userAvatar != null && action.userAvatar!.isNotEmpty
                                    ? NetworkImage(action.userAvatar!)
                                    : null,
                                child: action.userAvatar == null || action.userAvatar!.isEmpty
                                    ? Text(action.userName.isNotEmpty ? action.userName[0].toUpperCase() : 'U',
                                        style: const TextStyle(color: AppColors.white100))
                                    : null,
                              ),
                              const SizedBox(width: AppSize.spacingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      action.userName,
                                      style: CustomTextStyle.size15W600(color: AppColors.white100),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormat.yMMMMd(localeCode).format(action.createdAt),
                                      style: CustomTextStyle.size12W400(color: AppColors.grey500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSize.spacingS),
                      Flexible(
                        child: InkWell(
                          onTap: () => ActionCard.showScoreInfoSheet(context, action, loc),
                          borderRadius: BorderRadius.circular(AppSize.radiusM),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.grey900,
                              borderRadius: BorderRadius.circular(AppSize.radiusM),
                              border: Border.all(
                                color: ActionCard.getPointsColor(action).withValues(alpha: 0.4),
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
                                  color: ActionCard.getPointsColor(action),
                                  size: 15,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    ActionCard.formatPointsBadge(action, loc),
                                    style: CustomTextStyle.size13W600(
                                      color: ActionCard.getPointsColor(action),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 13,
                                  color: ActionCard.getPointsColor(action).withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSize.spacingL),

                  // Action Title
                  Text(
                    action.title,
                    style: CustomTextStyle.size20W600(color: AppColors.white100),
                  ),
                  const SizedBox(height: AppSize.spacingM),

                  // Category & Status Chips
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSize.radiusM),
                        ),
                        child: Text(
                          loc.translateCategory(action.category),
                          style: CustomTextStyle.size13W500(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: AppSize.spacingS),
                      ValidationBadge(status: action.validationStatus),
                    ],
                  ),
                  const SizedBox(height: AppSize.spacingM),

                  // Dedicated Potential / Earned / Rejected Reward Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSize.paddingM),
                    decoration: BoxDecoration(
                      color: action.isValidated
                          ? AppColors.accent.withValues(alpha: 0.1)
                          : action.validationStatus == ValidationStatus.rejected
                              ? AppColors.error.withValues(alpha: 0.1)
                              : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSize.radiusM),
                      border: Border.all(
                        color: action.isValidated
                            ? AppColors.accent.withValues(alpha: 0.3)
                            : action.validationStatus == ValidationStatus.rejected
                                ? AppColors.error.withValues(alpha: 0.3)
                                : AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          action.isValidated
                              ? Icons.verified
                              : action.validationStatus == ValidationStatus.rejected
                                  ? Icons.cancel_outlined
                                  : Icons.stars_rounded,
                          color: action.isValidated
                              ? AppColors.accent
                              : action.validationStatus == ValidationStatus.rejected
                                  ? AppColors.error
                                  : AppColors.warning,
                          size: 24,
                        ),
                        const SizedBox(width: AppSize.spacingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                action.isValidated
                                    ? '${loc.translate('earned_reward_label')}: +${action.score} ${loc.translate('points_label')}'
                                    : action.validationStatus == ValidationStatus.rejected
                                        ? loc.translate('validation_rejected_label')
                                        : '${loc.translate('potential_reward_label')}: +${action.score} ${loc.translate('points_label')}',
                                style: CustomTextStyle.size15W600(
                                  color: action.isValidated
                                      ? AppColors.accent
                                      : action.validationStatus == ValidationStatus.rejected
                                          ? AppColors.error
                                          : AppColors.warning,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                action.isValidated
                                    ? loc.translate('action_validated_reward_earned')
                                    : action.validationStatus == ValidationStatus.rejected
                                        ? (action.rejectionReason != null && action.rejectionReason!.isNotEmpty
                                            ? '${loc.translate('rejection_reason_prefix')}: ${action.rejectionReason}'
                                            : loc.translate('action_rejected_no_points'))
                                        : loc.translate('points_awarded_after_validation'),
                                style: CustomTextStyle.size12W400(
                                  color: AppColors.grey300,
                                ),
                              ),
                              if (action.isIndependent && action.isPendingIndependentReview) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.grey900,
                                    borderRadius: BorderRadius.circular(AppSize.radiusS),
                                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.shield_outlined, size: 12, color: AppColors.warning),
                                      const SizedBox(width: 4),
                                      Text(
                                        loc.translate('independent_review_pending_badge'),
                                        style: CustomTextStyle.size11W500(color: AppColors.warning),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSize.spacingL),

                  // Validator Info
                  if (action.validatorName != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSize.paddingS),
                      decoration: BoxDecoration(
                        color: AppColors.grey900,
                        borderRadius: BorderRadius.circular(AppSize.radiusS),
                        border: Border.all(color: AppColors.grey800),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person_search_outlined, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${loc.translate('requested_validator_prefix')}: ${action.validatorName} (@${action.validatorUsername ?? ''})',
                            style: CustomTextStyle.size12W400(color: AppColors.grey400),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSize.spacingL),
                  ],

                  // Interactive Like & Engagement Bar
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          _actionRepo.toggleLike(action.id, isCurrentlyLiked: action.isLikedByUser);
                        },
                        borderRadius: BorderRadius.circular(AppSize.radiusM),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: action.isLikedByUser
                                ? AppColors.error.withValues(alpha: 0.15)
                                : AppColors.grey900,
                            borderRadius: BorderRadius.circular(AppSize.radiusM),
                            border: Border.all(
                              color: action.isLikedByUser ? AppColors.error : AppColors.grey800,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                action.isLikedByUser ? Icons.favorite : Icons.favorite_border_outlined,
                                color: action.isLikedByUser ? AppColors.error : AppColors.grey400,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${action.likesCount} ${action.likesCount == 1 ? loc.translate('like_count_singular') : loc.translate('likes_count')}',
                                style: CustomTextStyle.size13W600(
                                  color: action.isLikedByUser ? AppColors.error : AppColors.white100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSize.spacingM),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.grey900,
                          borderRadius: BorderRadius.circular(AppSize.radiusM),
                          border: Border.all(color: AppColors.grey800),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: AppColors.grey400,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${action.commentsCount} ${loc.translate('comments_label')}',
                              style: CustomTextStyle.size13W600(color: AppColors.white100),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSize.spacingL),

                  // Description
                  Text(
                    loc.translate('description_label'),
                    style: CustomTextStyle.size15W600(color: AppColors.white100),
                  ),
                  const SizedBox(height: AppSize.spacingS),
                  Text(
                    action.description,
                    style: CustomTextStyle.size14W400(color: AppColors.grey300),
                  ),
                  const SizedBox(height: AppSize.spacingXL),

                  // Positive Impact Section
                  if (action.impact != null && action.impact!.trim().isNotEmpty) ...[
                    Text(
                      loc.translate('action_impact_title'),
                      style: CustomTextStyle.size15W600(color: AppColors.white100),
                    ),
                    const SizedBox(height: AppSize.spacingS),
                    Text(
                      action.impact!,
                      style: CustomTextStyle.size14W400(color: AppColors.grey300),
                    ),
                    const SizedBox(height: AppSize.spacingXL),
                  ],

                  // Evidence / Proof Section
                  Text(
                    loc.translate('uploaded_proof_label'),
                    style: CustomTextStyle.size15W600(color: AppColors.white100),
                  ),
                  const SizedBox(height: AppSize.spacingS),
                  _buildEvidencePreview(action),
                  const SizedBox(height: AppSize.spacingXL),

                  // Real-Time Comments Stream Header & List
                  StreamBuilder<List<CommentModel>>(
                    stream: _actionRepo.getCommentsStream(action.id),
                    builder: (context, snapshot) {
                      final comments = snapshot.data ?? [];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                loc.translate('comments_label'),
                                style: CustomTextStyle.size15W600(color: AppColors.white100),
                              ),
                              const SizedBox(width: AppSize.spacingS),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.grey800,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${comments.length}',
                                  style: CustomTextStyle.size11W600(color: AppColors.white100),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSize.spacingM),
                          if (comments.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSize.paddingM),
                              child: Text(
                                loc.translate('no_comments_yet'),
                                style: CustomTextStyle.size13W400(color: AppColors.grey500),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(color: AppColors.grey900, height: 24),
                              itemBuilder: (context, index) {
                                final c = comments[index];
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.grey800,
                                      backgroundImage: c.userAvatar != null && c.userAvatar!.isNotEmpty
                                          ? NetworkImage(c.userAvatar!)
                                          : null,
                                      child: c.userAvatar == null || c.userAvatar!.isEmpty
                                          ? Text(c.userName[0].toUpperCase(),
                                              style: const TextStyle(color: AppColors.white100, fontSize: 12))
                                          : null,
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
                                                c.userName,
                                                style: CustomTextStyle.size13W600(color: AppColors.white100),
                                              ),
                                              Text(
                                                DateFormat.MMMd(localeCode).add_Hm().format(c.createdAt),
                                                style: CustomTextStyle.size11W400(color: AppColors.grey500),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            c.text,
                                            style: CustomTextStyle.size13W400(color: AppColors.grey300),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSize.spacingXL),
                ],
              ),
            ),
          ),

          // Add Comment Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM, vertical: AppSize.paddingS),
            decoration: const BoxDecoration(
              color: AppColors.grey900,
              border: Border(
                top: BorderSide(color: AppColors.grey800, width: 1),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppSize.radiusL),
                        border: Border.all(color: AppColors.grey800),
                      ),
                      child: TextField(
                        controller: _commentController,
                        style: CustomTextStyle.size14W400(color: AppColors.white100),
                        decoration: InputDecoration(
                          hintText: loc.translate('write_comment_hint'),
                          hintStyle: CustomTextStyle.size14W400(color: AppColors.grey500),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSize.spacingS),
                  IconButton(
                    icon: _isSubmittingComment
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          )
                        : const Icon(Icons.send_rounded, color: AppColors.primary),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  },
);
      },
    );
  }


  Widget _buildEvidencePreview(ActionModel action) {
    return ProofCard(
      evidences: action.evidences.isNotEmpty ? action.evidences : null,
      proofType: action.proofType,
      proofUrl: action.proofUrl,
      textProof: action.textProof,
    );
  }
}

