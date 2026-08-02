import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/repo/action_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ActionRepository _actionRepo = ActionRepository();

  final List<Map<String, dynamic>> _defaultNotifications = [
    {
      'id': '2',
      'type': 'approved',
      'title': 'Action Approved',
      'description': 'Your action "Mentored junior developer" has been confirmed by Michael Chen (+78 Worth Score)',
      'time': '2h ago',
    },
    {
      'id': '3',
      'type': 'badge_unlocked',
      'title': 'Badge Unlocked',
      'description': 'Congratulations! You unlocked the "Consistency" badge.',
      'time': '1d ago',
    },
    {
      'id': '4',
      'type': 'level_up',
      'title': 'Level Up!',
      'description': 'You have advanced to Level 7. Keep building your reputation!',
      'time': '3d ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
          'Notifications',
          style: CustomTextStyle.size18W600(color: AppColors.white100),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _actionRepo.getUserNotificationsStream(),
        builder: (context, snapshot) {
          final liveNotifications = snapshot.data ?? [];

          final List<Map<String, dynamic>> displayNotifications = List.from(liveNotifications);

          // If no live notifications exist, show clean empty state or default items
          if (displayNotifications.isEmpty) {
            displayNotifications.addAll(_defaultNotifications);
          }

          if (displayNotifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSize.paddingM),
            itemCount: displayNotifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSize.spacingM),
            itemBuilder: (context, index) {
              final item = displayNotifications[index];
              return _buildNotificationCard(item);
            },
          );
        },
      ),
    );
  }



  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.grey900,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.grey800),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: AppSize.spacingL),
          Text(
            'All caught up!',
            style: CustomTextStyle.size16W600(color: AppColors.white100),
          ),
          const SizedBox(height: AppSize.spacingS),
          Text(
            'No new updates at the moment.',
            style: CustomTextStyle.size13W400(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    final type = item['type'] as String;
    final title = item['title'] as String;
    final description = item['description'] as String;
    final time = item['time'] as String;

    IconData icon;
    Color iconColor;
    Color bgGradientColor;

    switch (type) {
      case 'validation_requested':
        icon = Icons.shield_outlined;
        iconColor = AppColors.primary;
        bgGradientColor = AppColors.primary.withValues(alpha: 0.1);
        break;
      case 'approved':
        icon = Icons.check_circle_outline;
        iconColor = AppColors.success;
        bgGradientColor = AppColors.success.withValues(alpha: 0.1);
        break;
      case 'rejected':
        icon = Icons.cancel_outlined;
        iconColor = AppColors.error;
        bgGradientColor = AppColors.error.withValues(alpha: 0.1);
        break;
      case 'badge_unlocked':
        icon = Icons.stars_rounded;
        iconColor = AppColors.primary;
        bgGradientColor = AppColors.primary.withValues(alpha: 0.1);
        break;
      case 'level_up':
        icon = Icons.bolt;
        iconColor = AppColors.primary;
        bgGradientColor = AppColors.primary.withValues(alpha: 0.15);
        break;
      default:
        icon = Icons.info_outline;
        iconColor = AppColors.grey400;
        bgGradientColor = AppColors.grey900;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(AppSize.radiusM),
        border: Border.all(color: AppColors.grey800),
        gradient: LinearGradient(
          colors: [bgGradientColor, Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSize.paddingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.grey800),
              ),
              child: Icon(icon, color: iconColor, size: 22),
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
                        title,
                        style: CustomTextStyle.size14W600(color: AppColors.white100),
                      ),
                      Text(
                        time,
                        style: CustomTextStyle.size11W400(color: AppColors.grey500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: CustomTextStyle.size13W400(color: AppColors.grey300),
                  ),
                  if (type == 'validation_requested') ...[
                    const SizedBox(height: AppSize.spacingM),
                    ElevatedButton(
                      onPressed: () {
                        context.push('/validation-request', extra: item['action']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.black100,
                        minimumSize: const Size(100, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSize.radiusS),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Inspect Request', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
