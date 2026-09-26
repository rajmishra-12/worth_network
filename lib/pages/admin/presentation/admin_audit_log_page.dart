import 'package:flutter/material.dart';
import 'package:worth_network/core/model/moderation/moderation_action_model.dart';
import 'package:worth_network/core/repo/moderation_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';

class AdminAuditLogPage extends StatelessWidget {
  const AdminAuditLogPage({super.key});

  Widget _buildActionTag(String actionType) {
    Color bg = AppColors.grey800;
    Color text = AppColors.white100;

    switch (actionType) {
      case 'hide_content':
        bg = AppColors.warning.withValues(alpha: 0.2);
        text = AppColors.warning;
        break;
      case 'remove_content':
        bg = AppColors.error.withValues(alpha: 0.2);
        text = AppColors.error;
        break;
      case 'restore_content':
        bg = AppColors.success.withValues(alpha: 0.2);
        text = AppColors.success;
        break;
      case 'suspend_user':
      case 'block_user':
        bg = Colors.purpleAccent.withValues(alpha: 0.2);
        text = Colors.purpleAccent;
        break;
      case 'resolve_report':
        bg = AppColors.success.withValues(alpha: 0.2);
        text = AppColors.success;
        break;
      case 'dismiss_report':
        bg = AppColors.grey700;
        text = AppColors.grey400;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppSize.radiusS)),
      child: Text(
        actionType.replaceAll('_', ' ').toUpperCase(),
        style: CustomTextStyle.size12W600(color: text),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final repo = ModerationRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.grey900,
        elevation: 0,
        title: Text('Moderation Audit Logs', style: CustomTextStyle.size18W600(color: AppColors.white100)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white100),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<ModerationActionModel>>(
        stream: repo.getModerationActionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 64, color: AppColors.grey600),
                  const SizedBox(height: AppSize.spacingM),
                  Text('No Audit Logs', style: CustomTextStyle.size18W600(color: AppColors.white100)),
                  const SizedBox(height: 4),
                  Text('Administrative moderation actions will be recorded here.', style: CustomTextStyle.size14W400(color: AppColors.grey400)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSize.paddingM),
            itemCount: logs.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSize.spacingS),
            itemBuilder: (context, index) {
              final item = logs[index];
              return Container(
                padding: const EdgeInsets.all(AppSize.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.grey900,
                  borderRadius: BorderRadius.circular(AppSize.radiusL),
                  border: Border.all(color: AppColors.grey800),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionTag(item.actionType),
                        Text(_formatDate(item.createdAt), style: CustomTextStyle.size12W400(color: AppColors.grey500)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Admin: @${item.adminName ?? item.adminId}',
                      style: CustomTextStyle.size14W600(color: AppColors.white100),
                    ),
                    if (item.targetUserName != null)
                      Text(
                        'Target User: @${item.targetUserName}',
                        style: CustomTextStyle.size12W400(color: AppColors.grey300),
                      ),
                    if (item.contentId != null)
                      Text(
                        'Target Content ID: ${item.contentId}',
                        style: CustomTextStyle.size12W400(color: AppColors.grey400),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Reason: ${item.reason}',
                      style: CustomTextStyle.size12W400(color: AppColors.grey300),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
