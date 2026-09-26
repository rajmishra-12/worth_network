import 'package:flutter/material.dart';
import 'package:worth_network/core/model/moderation/report_model.dart';
import 'package:worth_network/core/repo/moderation_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  final ModerationRepository _repo = ModerationRepository();

  String _statusFilter = 'all'; // all, pending, underReview, resolved, dismissed
  String _typeFilter = 'all'; // all, action, comment, user
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _openReportDetailModal(ReportModel report) {
    _noteController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.grey900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.radiusXL)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: AppSize.paddingL,
                left: AppSize.paddingL,
                right: AppSize.paddingL,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSize.paddingL,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.grey700,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSize.spacingM),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'REPORT DETAILS #${report.id.substring(0, 6)}',
                          style: CustomTextStyle.size16W600(color: AppColors.white100),
                        ),
                        _buildStatusTag(report.status),
                      ],
                    ),
                    const Divider(color: AppColors.grey800, height: 24),

                    _buildInfoTile('Reported By', '@${report.reporterName ?? report.reporterId}'),
                    _buildInfoTile('Reported User', '@${report.reportedUserName ?? report.reportedUserId}'),
                    _buildInfoTile('Category / Reason', report.reason.toUpperCase()),
                    _buildInfoTile('Content Type', report.contentType.toUpperCase()),

                    if (report.contentPreview != null && report.contentPreview!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Content Snippet:', style: CustomTextStyle.size12W600(color: AppColors.grey400)),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(AppSize.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.grey800,
                          borderRadius: BorderRadius.circular(AppSize.radiusM),
                          border: Border.all(color: AppColors.grey700),
                        ),
                        child: Text(
                          report.contentPreview!,
                          style: CustomTextStyle.size14W400(color: AppColors.white100),
                        ),
                      ),
                    ],

                    if (report.description != null && report.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Reporter Description:', style: CustomTextStyle.size12W600(color: AppColors.grey400)),
                      Text(report.description!, style: CustomTextStyle.size14W400(color: AppColors.grey300)),
                    ],

                    const SizedBox(height: AppSize.spacingM),
                    Text('Internal Moderation Note:', style: CustomTextStyle.size12W600(color: AppColors.grey400)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _noteController,
                      style: CustomTextStyle.size14W400(color: AppColors.white100),
                      decoration: InputDecoration(
                        hintText: 'Add note for moderation record...',
                        hintStyle: CustomTextStyle.size14W400(color: AppColors.grey500),
                        filled: true,
                        fillColor: AppColors.grey800,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSize.radiusM),
                          borderSide: const BorderSide(color: AppColors.grey700),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSize.spacingL),

                    Text('Content Actions:', style: CustomTextStyle.size14W600(color: AppColors.white100)),
                    const SizedBox(height: AppSize.spacingS),
                    Row(
                      children: [
                        if (report.contentId != null && report.contentId!.isNotEmpty) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                Navigator.pop(modalContext);
                                await _repo.updateContentModerationStatus(
                                  contentId: report.contentId!,
                                  contentType: report.contentType,
                                  status: 'hidden',
                                  reason: _noteController.text.isEmpty
                                      ? 'Temporarily hidden via admin report'
                                      : _noteController.text,
                                );
                                _showToast('Content temporarily hidden');
                              },
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.warning)),
                              child: Text('Hide Content', style: CustomTextStyle.size12W600(color: AppColors.warning)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                Navigator.pop(modalContext);
                                await _repo.updateContentModerationStatus(
                                  contentId: report.contentId!,
                                  contentType: report.contentType,
                                  status: 'removed',
                                  reason: _noteController.text.isEmpty
                                      ? 'Removed for policy violation'
                                      : _noteController.text,
                                );
                                _showToast('Content removed from public feeds');
                              },
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                              child: Text('Remove Content', style: CustomTextStyle.size12W600(color: AppColors.error)),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: AppSize.spacingM),
                    Text('User Actions:', style: CustomTextStyle.size14W600(color: AppColors.white100)),
                    const SizedBox(height: AppSize.spacingS),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              Navigator.pop(modalContext);
                              await _repo.updateUserAccountStatus(
                                targetUserId: report.reportedUserId,
                                targetUserName: report.reportedUserName ?? 'User',
                                accountStatus: 'suspended',
                                reason: _noteController.text.isEmpty ? 'Account suspended via report' : _noteController.text,
                              );
                              _showToast('User account suspended');
                            },
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.purpleAccent)),
                            child: Text('Suspend User', style: CustomTextStyle.size12W600(color: Colors.purpleAccent)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              Navigator.pop(modalContext);
                              await _repo.updateUserAccountStatus(
                                targetUserId: report.reportedUserId,
                                targetUserName: report.reportedUserName ?? 'User',
                                accountStatus: 'blocked',
                                reason: _noteController.text.isEmpty ? 'Blocked by admin moderation' : _noteController.text,
                              );
                              _showToast('User blocked by admin');
                            },
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                            child: Text('Block User', style: CustomTextStyle.size12W600(color: AppColors.error)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSize.spacingM),
                    Text('Report Status:', style: CustomTextStyle.size14W600(color: AppColors.white100)),
                    const SizedBox(height: AppSize.spacingS),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(modalContext);
                              await _repo.updateReportStatus(
                                reportId: report.id,
                                status: ReportStatus.dismissed,
                                adminNote: _noteController.text,
                              );
                              _showToast('Report dismissed');
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.grey800),
                            child: Text('Dismiss', style: CustomTextStyle.size14W600(color: AppColors.grey300)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(modalContext);
                              await _repo.updateReportStatus(
                                reportId: report.id,
                                status: ReportStatus.resolved,
                                adminNote: _noteController.text,
                              );
                              _showToast('Report resolved');
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                            child: Text('Mark Resolved', style: CustomTextStyle.size14W600(color: AppColors.white100)),
                          ),
                        ),
                      ],
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

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  Widget _buildInfoTile(String label, String value) {
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

  Widget _buildStatusTag(ReportStatus status) {
    Color bg = AppColors.warning.withValues(alpha: 0.2);
    Color text = AppColors.warning;
    String label = 'Pending';

    switch (status) {
      case ReportStatus.underReview:
        bg = AppColors.info.withValues(alpha: 0.2);
        text = AppColors.info;
        label = 'Under Review';
        break;
      case ReportStatus.resolved:
        bg = AppColors.success.withValues(alpha: 0.2);
        text = AppColors.success;
        label = 'Resolved';
        break;
      case ReportStatus.dismissed:
        bg = AppColors.grey700;
        text = AppColors.grey400;
        label = 'Dismissed';
        break;
      case ReportStatus.pending:
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppSize.radiusS)),
      child: Text(label, style: CustomTextStyle.size12W600(color: text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.grey900,
        elevation: 0,
        title: Text('Reports Queue', style: CustomTextStyle.size18W600(color: AppColors.white100)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white100),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Container
          Container(
            padding: const EdgeInsets.all(AppSize.paddingM),
            color: AppColors.grey900,
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  style: CustomTextStyle.size14W400(color: AppColors.white100),
                  decoration: InputDecoration(
                    hintText: 'Search by user, reason, or report ID...',
                    hintStyle: CustomTextStyle.size14W400(color: AppColors.grey500),
                    prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
                    filled: true,
                    fillColor: AppColors.grey800,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.radiusM),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.spacingS),

                // Status filter row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip('All Statuses', 'all', _statusFilter, (val) => setState(() => _statusFilter = val)),
                      _buildChip('Pending', 'pending', _statusFilter, (val) => setState(() => _statusFilter = val)),
                      _buildChip('Under Review', 'underReview', _statusFilter, (val) => setState(() => _statusFilter = val)),
                      _buildChip('Resolved', 'resolved', _statusFilter, (val) => setState(() => _statusFilter = val)),
                      _buildChip('Dismissed', 'dismissed', _statusFilter, (val) => setState(() => _statusFilter = val)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // Type filter row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip('All Types', 'all', _typeFilter, (val) => setState(() => _typeFilter = val)),
                      _buildChip('Actions', 'action', _typeFilter, (val) => setState(() => _typeFilter = val)),
                      _buildChip('Comments', 'comment', _typeFilter, (val) => setState(() => _typeFilter = val)),
                      _buildChip('Users', 'user', _typeFilter, (val) => setState(() => _typeFilter = val)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Reports Stream List
          Expanded(
            child: StreamBuilder<List<ReportModel>>(
              stream: _repo.getReportsStream(
                statusFilter: _statusFilter,
                typeFilter: _typeFilter,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                var reports = snapshot.data ?? [];

                if (_searchQuery.isNotEmpty) {
                  reports = reports.where((r) {
                    final reporter = (r.reporterName ?? '').toLowerCase();
                    final reported = (r.reportedUserName ?? '').toLowerCase();
                    final reason = r.reason.toLowerCase();
                    final id = r.id.toLowerCase();
                    return reporter.contains(_searchQuery) ||
                        reported.contains(_searchQuery) ||
                        reason.contains(_searchQuery) ||
                        id.contains(_searchQuery);
                  }).toList();
                }

                if (reports.isEmpty) {
                  return Center(
                    child: Text(
                      'No reports match the selected filters.',
                      style: CustomTextStyle.size14W400(color: AppColors.grey400),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSize.paddingM),
                  itemCount: reports.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSize.spacingS),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return Card(
                      color: AppColors.grey900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSize.radiusL),
                        side: const BorderSide(color: AppColors.grey800),
                      ),
                      child: ListTile(
                        onTap: () => _openReportDetailModal(report),
                        title: Row(
                          children: [
                            Text(
                              '${report.contentType.toUpperCase()}: ${report.reason}',
                              style: CustomTextStyle.size14W600(color: AppColors.white100),
                            ),
                            const Spacer(),
                            _buildStatusTag(report.status),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reported User: @${report.reportedUserName ?? report.reportedUserId}',
                                style: CustomTextStyle.size12W500(color: AppColors.grey300),
                              ),
                              Text(
                                'Reporter: @${report.reporterName ?? report.reporterId}',
                                style: CustomTextStyle.size12W400(color: AppColors.grey400),
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.grey500),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value, String currentSelection, ValueChanged<String> onSelected) {
    final isSelected = currentSelection == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) onSelected(value);
        },
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.grey800,
        checkmarkColor: AppColors.black100,
        labelStyle: CustomTextStyle.size12W600(
          color: isSelected ? AppColors.black100 : AppColors.grey400,
        ),
      ),
    );
  }
}
