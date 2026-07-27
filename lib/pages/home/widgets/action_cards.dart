// lib/pages/dashboard/home/widgets/action_card.dart
import 'package:flutter/material.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/pages/home/widgets/empty_feed_widget.dart';


class ActionCard extends StatelessWidget {
  final ActionModel action;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onUserTap;

  const ActionCard({
    super.key,
    required this.action,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
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
                            action.userName[0],
                            style:CustomTextStyle.size14W500(
                               color: AppColors.white100,
                            )
                            
                           
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
                           style:CustomTextStyle.size14W600(
                               color: AppColors.white100,
                            )
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _formatTimeAgo(action.createdAt),
                             style:CustomTextStyle.size14W500(
                               color: AppColors.white100,
                            )
                            ),
                            const SizedBox(width: AppSize.spacingS),
                            ValidationBadge(status: action.validationStatus),
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
                        style:CustomTextStyle.size14W500(
                               color: AppColors.white100,
                            )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
            child: Text(
              action.title,
              style:CustomTextStyle.size14W500(
                               color: AppColors.white100,
                            )
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
                action.category,
                style:CustomTextStyle.size14W500(
                              color: _getCategoryColor(action.category),
                            )
              
              ),
            ),
          ),
          // Proof Preview
          if (action.proofUrl != null && action.proofType == 'photo')
            Padding(
              padding: const EdgeInsets.all(AppSize.paddingM),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSize.radiusM),
                child: Image.network(
                  action.proofUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: AppColors.grey800,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.grey500,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
            child: Text(
              action.description,
              style:CustomTextStyle.size14W600(
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
             style:CustomTextStyle.size14W600(
                              color: isActive ? AppColors.primary : AppColors.grey500,
                            )
          
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
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
      return 'just now';
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