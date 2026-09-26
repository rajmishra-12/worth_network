import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/model/moderation/report_model.dart';
import 'package:worth_network/core/repo/moderation_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final ModerationRepository _repo = ModerationRepository();

  void _showReportDetailDialog(ReportModel report, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.grey900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.radiusL),
          side: const BorderSide(color: AppColors.grey800),
        ),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              '${loc.translate('reports_queue')} #${report.id.substring(0, 6)}',
              style: CustomTextStyle.size18W600(color: AppColors.white100),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(loc.translate('reported_by'), '@${report.reporterName ?? report.reporterId}'),
              _buildDetailRow(loc.translate('reported_user'), '@${report.reportedUserName ?? report.reportedUserId}'),
              _buildDetailRow(loc.translate('content_type_label'), report.contentType.toUpperCase()),
              _buildDetailRow(loc.translate('reason_label'), report.reason),
              if (report.contentPreview != null) ...[
                const SizedBox(height: 8),
                Text(loc.translate('content_preview_label'), style: CustomTextStyle.size12W600(color: AppColors.grey400)),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.grey800,
                    borderRadius: BorderRadius.circular(AppSize.radiusS),
                  ),
                  child: Text(
                    report.contentPreview!,
                    style: CustomTextStyle.size14W400(color: AppColors.white100),
                  ),
                ),
              ],
              if (report.description != null && report.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(loc.translate('user_description_label'), style: CustomTextStyle.size12W600(color: AppColors.grey400)),
                Text(report.description!, style: CustomTextStyle.size14W400(color: AppColors.grey300)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.translate('close_btn'), style: CustomTextStyle.size14W500(color: AppColors.grey400)),
          ),
          if (report.contentId != null && report.contentId!.isNotEmpty)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _repo.updateContentModerationStatus(
                  contentId: report.contentId!,
                  contentType: report.contentType,
                  status: 'hidden',
                  reason: 'Moderated via report #${report.id}',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.translate('content_hidden_success')), backgroundColor: AppColors.success),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
              child: Text(loc.translate('hide_content'), style: CustomTextStyle.size14W600(color: AppColors.white100)),
            ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _repo.updateReportStatus(reportId: report.id, status: ReportStatus.resolved);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.translate('report_resolved_success')), backgroundColor: AppColors.success),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: Text(loc.translate('resolve_btn'), style: CustomTextStyle.size14W600(color: AppColors.white100)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: CustomTextStyle.size14W400(color: AppColors.grey400)),
          Text(value, style: CustomTextStyle.size14W600(color: AppColors.white100)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);

        return FutureBuilder<bool>(
          future: _repo.isCurrentUserAdmin(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.background,
                body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              );
            }

            final isAdmin = snapshot.data ?? false;
            if (!isAdmin) {
              return Scaffold(
                backgroundColor: AppColors.background,
                appBar: AppBar(
                  backgroundColor: AppColors.grey900,
                  elevation: 0,
                  title: Text(loc.translate('access_denied'), style: CustomTextStyle.size18W600(color: AppColors.error)),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.white100),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSize.paddingXL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.security, size: 72, color: AppColors.error),
                        const SizedBox(height: AppSize.spacingM),
                        Text(
                          loc.translate('admin_privileges_required'),
                          style: CustomTextStyle.size20W600(color: AppColors.white100),
                        ),
                        const SizedBox(height: AppSize.spacingS),
                        Text(
                          loc.translate('admin_privileges_desc'),
                          style: CustomTextStyle.size14W400(color: AppColors.grey400),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSize.spacingXL),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: Text(loc.translate('go_back'), style: CustomTextStyle.size14W600(color: AppColors.black100)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.grey900,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.translate('worth_admin'), style: CustomTextStyle.size18W600(color: AppColors.white100)),
                    Text(loc.translate('moderation_console'), style: CustomTextStyle.size12W400(color: AppColors.primary)),
                  ],
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.white100),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.white100),
                    onPressed: () => setState(() {}),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSize.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashboard Header Overview
                    StreamBuilder<Map<String, int>>(
                      stream: _repo.getDashboardStatsStream(),
                      builder: (context, snapshot) {
                        final stats = snapshot.data ?? {
                          'pendingReports': 0,
                          'underReviewReports': 0,
                          'resolvedReports': 0,
                          'reportedContent': 0,
                          'reportedUsers': 0,
                          'suspendedUsers': 0,
                        };

                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: AppSize.spacingM,
                          mainAxisSpacing: AppSize.spacingM,
                          childAspectRatio: 1.5,
                          children: [
                            _buildStatCard(
                              title: loc.translate('pending_reports'),
                              count: stats['pendingReports'] ?? 0,
                              icon: Icons.pending_actions,
                              color: AppColors.warning,
                              onTap: () => context.push('/admin/reports'),
                            ),
                            _buildStatCard(
                              title: loc.translate('reported_content'),
                              count: stats['reportedContent'] ?? 0,
                              icon: Icons.article_outlined,
                              color: AppColors.info,
                              onTap: () => context.push('/admin/content'),
                            ),
                            _buildStatCard(
                              title: loc.translate('reported_users'),
                              count: stats['reportedUsers'] ?? 0,
                              icon: Icons.person_off_outlined,
                              color: AppColors.error,
                              onTap: () => context.push('/admin/users'),
                            ),
                            _buildStatCard(
                              title: loc.translate('suspended_users'),
                              count: stats['suspendedUsers'] ?? 0,
                              icon: Icons.lock_outline,
                              color: Colors.purpleAccent,
                              onTap: () => context.push('/admin/users'),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: AppSize.spacingL),

                    // Quick Nav Sections
                    Text(
                      loc.translate('moderation_tools'),
                      style: CustomTextStyle.size16W600(color: AppColors.white100),
                    ),
                    const SizedBox(height: AppSize.spacingM),

                    Row(
                      children: [
                        Expanded(
                          child: _buildToolButton(
                            context,
                            title: loc.translate('reports_queue'),
                            subtitle: loc.translate('review_resolve_sub'),
                            icon: Icons.flag,
                            route: '/admin/reports',
                          ),
                        ),
                        const SizedBox(width: AppSize.spacingM),
                        Expanded(
                          child: _buildToolButton(
                            context,
                            title: loc.translate('word_filter'),
                            subtitle: loc.translate('prohibited_words_sub'),
                            icon: Icons.spellcheck,
                            route: '/admin/word-filter',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSize.spacingM),
                    Row(
                      children: [
                        Expanded(
                          child: _buildToolButton(
                            context,
                            title: loc.translate('users_list'),
                            subtitle: loc.translate('suspend_block_sub'),
                            icon: Icons.people_outline,
                            route: '/admin/users',
                          ),
                        ),
                        const SizedBox(width: AppSize.spacingM),
                        Expanded(
                          child: _buildToolButton(
                            context,
                            title: loc.translate('audit_logs'),
                            subtitle: loc.translate('moderation_history_sub'),
                            icon: Icons.history,
                            route: '/admin/audit-log',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSize.spacingL),

                    // Recent Pending Reports Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.translate('recent_reports'),
                          style: CustomTextStyle.size16W600(color: AppColors.white100),
                        ),
                        TextButton(
                          onPressed: () => context.push('/admin/reports'),
                          child: Text(
                            loc.translate('view_all'),
                            style: CustomTextStyle.size14W500(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSize.spacingS),

                    StreamBuilder<List<ReportModel>>(
                      stream: _repo.getReportsStream(statusFilter: 'pending'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                        }

                        final reports = snapshot.data ?? [];
                        if (reports.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(AppSize.paddingL),
                            decoration: BoxDecoration(
                              color: AppColors.grey900,
                              borderRadius: BorderRadius.circular(AppSize.radiusL),
                              border: Border.all(color: AppColors.grey800),
                            ),
                            child: Center(
                              child: Text(
                                loc.translate('no_pending_reports_clear'),
                                style: CustomTextStyle.size14W400(color: AppColors.grey400),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reports.length.clamp(0, 5),
                          separatorBuilder: (context, index) => const SizedBox(height: AppSize.spacingS),
                          itemBuilder: (context, index) {
                            final report = reports[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.grey900,
                                borderRadius: BorderRadius.circular(AppSize.radiusL),
                                border: Border.all(color: AppColors.grey800),
                              ),
                              child: ListTile(
                                onTap: () => _showReportDetailDialog(report, loc),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.grey800,
                                  child: Icon(
                                    report.contentType == 'user'
                                        ? Icons.person
                                        : (report.contentType == 'comment' ? Icons.comment : Icons.article),
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  '${report.contentType.toUpperCase()}: ${report.reason}',
                                  style: CustomTextStyle.size14W600(color: AppColors.white100),
                                ),
                                subtitle: Text(
                                  '${loc.translate('reported_by')} @${report.reporterName ?? loc.translate('default_user_name')}',
                                  style: CustomTextStyle.size12W400(color: AppColors.grey400),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppSize.radiusS),
                                  ),
                                  child: Text(
                                    loc.translate('status_pending'),
                                    style: CustomTextStyle.size12W600(color: AppColors.warning),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
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

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSize.radiusL),
      child: Container(
        padding: const EdgeInsets.all(AppSize.paddingM),
        decoration: BoxDecoration(
          color: AppColors.grey900,
          borderRadius: BorderRadius.circular(AppSize.radiusL),
          border: Border.all(color: AppColors.grey800),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 22),
                Text(
                  '$count',
                  style: CustomTextStyle.size20W600(color: AppColors.white100),
                ),
              ],
            ),
            Text(
              title,
              style: CustomTextStyle.size12W500(color: AppColors.grey400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
  }) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(AppSize.radiusL),
      child: Container(
        padding: const EdgeInsets.all(AppSize.paddingM),
        decoration: BoxDecoration(
          color: AppColors.grey900,
          borderRadius: BorderRadius.circular(AppSize.radiusL),
          border: Border.all(color: AppColors.grey800),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSize.radiusM),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSize.spacingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: CustomTextStyle.size14W600(color: AppColors.white100)),
                  Text(subtitle, style: CustomTextStyle.size12W400(color: AppColors.grey400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
