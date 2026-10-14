import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/repo/action_repo.dart';
import 'package:worth_network/core/repo/moderation_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/pages/home/widgets/proof_card.dart';

class AdminIndependentValidationsPage extends StatefulWidget {
  const AdminIndependentValidationsPage({super.key});

  @override
  State<AdminIndependentValidationsPage> createState() =>
      _AdminIndependentValidationsPageState();
}

class _AdminIndependentValidationsPageState
    extends State<AdminIndependentValidationsPage>
    with SingleTickerProviderStateMixin {
  final ActionRepository _actionRepo = ActionRepository();
  final ModerationRepository _moderationRepo = ModerationRepository();
  late TabController _tabController;

  final List<String> _filterKeys = ['pending', 'approved', 'rejected', 'all'];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filterKeys.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showApproveConfirmation(
    BuildContext context,
    ActionModel action,
    AppLocalizations loc,
  ) {
    final noteController = TextEditingController();

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
            const Icon(Icons.check_circle_outline, color: AppColors.success),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                loc.translate('approve_action_dialog_title'),
                style: CustomTextStyle.size18W600(color: AppColors.white100),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('approve_action_dialog_desc'),
              style: CustomTextStyle.size14W400(color: AppColors.grey300),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.grey800,
                borderRadius: BorderRadius.circular(AppSize.radiusS),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: CustomTextStyle.size14W600(color: AppColors.white100),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${action.userName} • +${action.score} Worth Score',
                    style: CustomTextStyle.size12W500(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              style: CustomTextStyle.size14W400(color: AppColors.white100),
              decoration: InputDecoration(
                hintText: loc.translate('admin_note_optional_hint'),
                hintStyle: CustomTextStyle.size13W400(color: AppColors.grey500),
                filled: true,
                fillColor: AppColors.grey800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.radiusS),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              loc.translate('cancel'),
              style: CustomTextStyle.size14W500(color: AppColors.grey400),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(dialogContext);
              setState(() => _isProcessing = true);
              try {
                await _actionRepo.approveIndependentValidation(
                  actionId: action.id,
                  adminNote: noteController.text.trim(),
                );
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        loc.translate('independent_action_approved_success'),
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().replaceFirst('Exception: ', ''),
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } finally {
                if (mounted) setState(() => _isProcessing = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: Text(
              loc.translate('approve_btn'),
              style: CustomTextStyle.size14W600(color: AppColors.white100),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectConfirmation(
    BuildContext context,
    ActionModel action,
    AppLocalizations loc,
  ) {
    final reasonController = TextEditingController();

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
            const Icon(Icons.cancel_outlined, color: AppColors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                loc.translate('reject_action_dialog_title'),
                style: CustomTextStyle.size18W600(color: AppColors.white100),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('reject_action_dialog_desc'),
              style: CustomTextStyle.size14W400(color: AppColors.grey300),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: CustomTextStyle.size14W400(color: AppColors.white100),
              decoration: InputDecoration(
                hintText: loc.translate('rejection_reason_hint'),
                hintStyle: CustomTextStyle.size13W400(color: AppColors.grey500),
                filled: true,
                fillColor: AppColors.grey800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.radiusS),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              loc.translate('cancel'),
              style: CustomTextStyle.size14W500(color: AppColors.grey400),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(dialogContext);
              setState(() => _isProcessing = true);
              try {
                await _actionRepo.rejectIndependentValidation(
                  actionId: action.id,
                  reason: reasonController.text.trim(),
                );
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        loc.translate('independent_action_rejected_success'),
                      ),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().replaceFirst('Exception: ', ''),
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } finally {
                if (mounted) setState(() => _isProcessing = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(
              loc.translate('reject_btn'),
              style: CustomTextStyle.size14W600(color: AppColors.white100),
            ),
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

        return FutureBuilder<bool>(
          future: _moderationRepo.isCurrentUserAdmin(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.background,
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            final isAdmin = snapshot.data ?? false;
            if (!isAdmin) {
              return Scaffold(
                backgroundColor: AppColors.background,
                appBar: AppBar(
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.white100),
                    onPressed: () => context.pop(),
                  ),
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSize.paddingXL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppSize.spacingL),
                        Text(
                          loc.translate('admin_privileges_required'),
                          style: CustomTextStyle.size20W600(color: AppColors.white100),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSize.spacingS),
                        Text(
                          loc.translate('admin_privileges_desc'),
                          style: CustomTextStyle.size14W400(color: AppColors.grey400),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final currentAdminUid = _actionRepo.currentUserId;

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
                  loc.translate('independent_validations_admin_title'),
                  style: CustomTextStyle.size18W600(color: AppColors.white100),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.grey400,
                  tabs: [
                    Tab(text: loc.translate('pending_review')),
                    Tab(text: loc.translate('approved_status')),
                    Tab(text: loc.translate('rejected_status')),
                    Tab(text: loc.translate('all_filter')),
                  ],
                ),
              ),
              body: Stack(
                children: [
                  TabBarView(
                    controller: _tabController,
                    children: _filterKeys.map((filter) {
                      return _buildRequestsList(filter, loc, currentAdminUid);
                    }).toList(),
                  ),
                  if (_isProcessing)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestsList(
    String filter,
    AppLocalizations loc,
    String? currentAdminUid,
  ) {
    return StreamBuilder<List<ActionModel>>(
      stream: _actionRepo.getIndependentValidationRequestsStream(
        statusFilter: filter == 'all' ? null : filter,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSize.paddingL),
              child: Text(
                '${loc.translate('error_loading_data')}: ${snapshot.error}',
                style: CustomTextStyle.size14W400(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSize.paddingXL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fact_check_outlined,
                    size: 64,
                    color: AppColors.grey600,
                  ),
                  const SizedBox(height: AppSize.spacingM),
                  Text(
                    filter == 'pending'
                        ? loc.translate('no_independent_requests_pending')
                        : loc.translate('no_independent_requests_found'),
                    style: CustomTextStyle.size16W600(color: AppColors.grey400),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSize.paddingM),
          itemCount: requests.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSize.spacingM),
          itemBuilder: (context, index) {
            final action = requests[index];
            return _buildRequestCard(action, loc, currentAdminUid);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(
    ActionModel action,
    AppLocalizations loc,
    String? currentAdminUid,
  ) {
    final isCreator = action.userId == currentAdminUid;
    final reviewStatus = action.independentReviewStatus ?? 'pending';
    final isPending = reviewStatus == 'pending';
    final isApproved = reviewStatus == 'approved';
    final isRejected = reviewStatus == 'rejected';

    final submittedDate = action.independentSubmittedAt ?? action.createdAt;
    final dateStr = DateFormat.yMMMd(loc.localeCode).add_jm().format(submittedDate);

    Color statusColor = AppColors.warning;
    String statusText = loc.translate('pending_review');
    IconData statusIcon = Icons.hourglass_top_outlined;

    if (isApproved) {
      statusColor = AppColors.success;
      statusText = loc.translate('approved_status');
      statusIcon = Icons.check_circle_outline;
    } else if (isRejected) {
      statusColor = AppColors.error;
      statusText = loc.translate('rejected_status');
      statusIcon = Icons.cancel_outlined;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(AppSize.radiusL),
        border: Border.all(
          color: isPending ? AppColors.warning.withValues(alpha: 0.3) : AppColors.grey800,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Creator Info & Status Badge
          Padding(
            padding: const EdgeInsets.all(AppSize.paddingM),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.grey800,
                  backgroundImage: action.userAvatar != null && action.userAvatar!.isNotEmpty
                      ? NetworkImage(action.userAvatar!)
                      : null,
                  child: action.userAvatar == null || action.userAvatar!.isEmpty
                      ? Text(
                          action.userName.isNotEmpty ? action.userName[0].toUpperCase() : 'U',
                          style: CustomTextStyle.size14W600(color: AppColors.white100),
                        )
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
                      ),
                      Text(
                        dateStr,
                        style: CustomTextStyle.size11W400(color: AppColors.grey500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSize.radiusM),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: CustomTextStyle.size11W600(color: statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.grey800, height: 1),

          // Action Content: Category, Title, Description
          Padding(
            padding: const EdgeInsets.all(AppSize.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSize.radiusS),
                      ),
                      child: Text(
                        loc.translateCategory(action.category),
                        style: CustomTextStyle.size12W600(color: AppColors.primary),
                      ),
                    ),
                    Text(
                      '${loc.translate(isApproved ? 'earned_reward_label' : 'potential_reward_label')}: +${action.score} pts',
                      style: CustomTextStyle.size12W600(
                        color: isApproved ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  action.title,
                  style: CustomTextStyle.size16W600(color: AppColors.white100),
                ),
                const SizedBox(height: 6),
                Text(
                  action.description,
                  style: CustomTextStyle.size14W400(color: AppColors.grey300),
                ),
              ],
            ),
          ),

          // Submitted Evidence Previews
          if (action.evidences.isNotEmpty ||
              action.proofUrl != null ||
              action.textProof != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.attachment, size: 16, color: AppColors.grey400),
                      const SizedBox(width: 4),
                      Text(
                        '${loc.translate('submitted_evidence_label')} (${action.evidences.length})',
                        style: CustomTextStyle.size13W600(color: AppColors.grey300),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ProofCard(evidences: action.evidences),
                  const SizedBox(height: 8),
                  // Direct button for external link evidence if available
                  ...action.evidences.where((e) => e.type == 'link' && e.url != null).map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.open_in_new, size: 16, color: AppColors.primary),
                        label: Text(
                          '${loc.translate('open_link_btn')}: ${e.url}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CustomTextStyle.size12W500(color: AppColors.primary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: () async {
                          final uri = Uri.tryParse(e.url!);
                          if (uri != null) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          // Review Information / Decision Banner
          if (isApproved && action.reviewedByAdminName != null) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(AppSize.paddingM),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSize.radiusS),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Text(
                '${loc.translate('approved_by_admin')}: @${action.reviewedByAdminName}',
                style: CustomTextStyle.size12W500(color: AppColors.success),
              ),
            ),
          ] else if (isRejected) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(AppSize.paddingM),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSize.radiusS),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${loc.translate('rejected_by_admin')}: @${action.reviewedByAdminName ?? 'Admin'}',
                    style: CustomTextStyle.size12W600(color: AppColors.error),
                  ),
                  if (action.rejectionReason != null && action.rejectionReason!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${loc.translate('reason_label')}: ${action.rejectionReason}',
                      style: CustomTextStyle.size12W400(color: AppColors.grey300),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Action Buttons for Pending Requests
          if (isPending) ...[
            const Divider(color: AppColors.grey800, height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSize.paddingM),
              child: isCreator
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSize.radiusS),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warning),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              loc.translate('cannot_validate_own_action'),
                              style: CustomTextStyle.size12W500(color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                            label: Text(
                              loc.translate('reject_btn'),
                              style: CustomTextStyle.size14W600(color: AppColors.error),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSize.radiusM),
                              ),
                            ),
                            onPressed: () => _showRejectConfirmation(context, action, loc),
                          ),
                        ),
                        const SizedBox(width: AppSize.spacingM),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check, size: 16, color: AppColors.black100),
                            label: Text(
                              loc.translate('approve_btn'),
                              style: CustomTextStyle.size14W600(color: AppColors.black100),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSize.radiusM),
                              ),
                            ),
                            onPressed: () => _showApproveConfirmation(context, action, loc),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
