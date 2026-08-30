import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/repo/action_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ActionRepository _actionRepo = ActionRepository();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
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
              loc.translate('notifications'),
              style: CustomTextStyle.size18W600(color: AppColors.white100),
            ),
            actions: [
              TextButton.icon(
                onPressed: () async {
                  await _actionRepo.markAllNotificationsAsRead();
                },
                icon: const Icon(Icons.done_all, size: 16, color: AppColors.primary),
                label: const Text(
                  'Mark all read',
                  style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _actionRepo.getUserNotificationsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final displayNotifications = snapshot.data ?? [];

              if (displayNotifications.isEmpty) {
                return _buildEmptyState(loc);
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSize.paddingM),
                itemCount: displayNotifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSize.spacingM),
                itemBuilder: (context, index) {
                  final item = displayNotifications[index];
                  return _buildNotificationCard(item, loc);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(AppLocalizations loc) {
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
            loc.translate('all_caught_up'),
            style: CustomTextStyle.size16W600(color: AppColors.white100),
          ),
          const SizedBox(height: AppSize.spacingS),
          Text(
            loc.translate('no_new_notifications'),
            style: CustomTextStyle.size13W400(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item, AppLocalizations loc) {
    final String id = item['id'] as String? ?? '';
    final type = item['type'] as String;
    final title = item['title'] as String;
    final description = item['description'] as String;
    final time = item['time'] as String;
    final bool isRead = item['isRead'] ?? false;

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

    final action = item['action'];

    return GestureDetector(
      onTap: () async {
        if (!isRead && id.isNotEmpty) {
          await _actionRepo.toggleNotificationReadStatus(id, false);
        }
        if (action != null) {
          if (type == 'validation_requested' || type == 'validation_request') {
            context.push('/validation-request', extra: action);
          } else {
            context.push('/action-details', extra: action);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isRead ? AppColors.grey900.withValues(alpha: 0.6) : AppColors.grey900,
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          border: Border.all(
            color: isRead ? AppColors.grey800 : AppColors.primary.withValues(alpha: 0.4),
            width: isRead ? 1.0 : 1.5,
          ),
          gradient: LinearGradient(
            colors: [isRead ? Colors.transparent : bgGradientColor, Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSize.paddingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
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
                  if (!isRead)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSize.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: CustomTextStyle.size14W600(
                              color: isRead ? AppColors.grey300 : AppColors.white100,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: CustomTextStyle.size11W400(color: AppColors.grey500),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            if (id.isNotEmpty) {
                              _actionRepo.toggleNotificationReadStatus(id, isRead);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Icon(
                              isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_rounded,
                              color: isRead ? AppColors.grey600 : AppColors.primary,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: CustomTextStyle.size13W400(
                        color: isRead ? AppColors.grey500 : AppColors.grey300,
                      ),
                    ),
                    if ((type == 'validation_requested' || type == 'validation_request') && action != null) ...[
                      const SizedBox(height: AppSize.spacingM),
                      ElevatedButton(
                        onPressed: () async {
                          if (!isRead && id.isNotEmpty) {
                            await _actionRepo.toggleNotificationReadStatus(id, false);
                          }
                          context.push('/validation-request', extra: action);
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
                        child: Text(loc.translate('inspect_request'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
