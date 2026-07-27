import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'validation_requested',
      'title': 'Validation Request',
      'description': 'Sarah Johnson requested validation for "Helped elderly neighbor with groceries"',
      'time': '10m ago',
      'action': ActionModel(
        id: '1',
        userId: 'user1',
        userName: 'Sarah Johnson',
        userAvatar: 'https://i.pravatar.cc/150?img=1',
        title: 'Helped elderly neighbor with groceries',
        description: 'Carried groceries up 3 flights of stairs and helped organize pantry.',
        category: 'Support',
        proofType: 'photo',
        proofUrl: 'https://picsum.photos/400/300?random=1',
        validationStatus: ValidationStatus.declared,
        score: 85,
        likesCount: 24,
        commentsCount: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    },
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
    {
      'id': '5',
      'type': 'rejected',
      'title': 'Validation Rejected',
      'description': 'Your action "Completed 10km charity run" was rejected due to lack of proof.',
      'time': '5d ago',
    },
  ];

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
  }

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
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: Text(
                'Clear All',
                style: CustomTextStyle.size14W600(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(AppSize.paddingM),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSize.spacingM),
              itemBuilder: (context, index) {
                final item = _notifications[index];
                return _buildNotificationCard(item);
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
