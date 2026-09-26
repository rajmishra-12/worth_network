import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/repo/moderation_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/pages/home/cubit/home_cubit.dart';

class ReportDialog extends StatefulWidget {
  final String reportedUserId;
  final String? reportedUserName;
  final String? contentId;
  final String contentType; // 'action', 'comment', 'user'
  final String? contentPreview;

  const ReportDialog({
    super.key,
    required this.reportedUserId,
    this.reportedUserName,
    this.contentId,
    required this.contentType,
    this.contentPreview,
  });

  static Future<void> show(
    BuildContext context, {
    required String reportedUserId,
    String? reportedUserName,
    String? contentId,
    required String contentType,
    String? contentPreview,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ReportDialog(
        reportedUserId: reportedUserId,
        reportedUserName: reportedUserName,
        contentId: contentId,
        contentType: contentType,
        contentPreview: contentPreview,
      ),
    );
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final ModerationRepository _repo = ModerationRepository();
  final TextEditingController _descController = TextEditingController();

  String _selectedReason = 'harassment';
  bool _isSubmitting = false;

  final List<String> _reasonKeys = [
    'harassment',
    'hate_speech',
    'inappropriate',
    'spam',
    'false_info',
    'other',
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitReport(AppLocalizations loc) async {
    setState(() => _isSubmitting = true);
    try {
      await _repo.submitReport(
        reportedUserId: widget.reportedUserId,
        reportedUserName: widget.reportedUserName,
        contentId: widget.contentId,
        contentType: widget.contentType,
        contentPreview: widget.contentPreview,
        reason: _selectedReason,
        description: _descController.text,
      );

      if (!mounted) return;
      try {
        if (widget.contentType == 'action' && widget.contentId != null) {
          context.read<HomeCubit>().loadFeed();
        }
      } catch (_) {}

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('report_submitted_success')),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        final titleType = widget.contentType == 'user'
            ? loc.translate('report_user')
            : (widget.contentType == 'comment' ? loc.translate('report_comment') : loc.translate('report_action'));

        return AlertDialog(
          backgroundColor: AppColors.grey900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.radiusL),
            side: const BorderSide(color: AppColors.grey800),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag_outlined, color: AppColors.error, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    titleType,
                    style: CustomTextStyle.size18W600(color: AppColors.white100),
                  ),
                ],
              ),
              if (widget.reportedUserName != null) ...[
                const SizedBox(height: 4),
                Text(
                  'User: @${widget.reportedUserName}',
                  style: CustomTextStyle.size12W400(color: AppColors.grey400),
                ),
              ],
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('select_report_reason'),
                  style: CustomTextStyle.size14W500(color: AppColors.grey300),
                ),
                const SizedBox(height: AppSize.spacingS),
                ..._reasonKeys.map((reasonKey) {
                  final isSelected = _selectedReason == reasonKey;
                  final label = loc.translate('reason_$reasonKey');
                  return InkWell(
                    onTap: () => setState(() => _selectedReason = reasonKey),
                    borderRadius: BorderRadius.circular(AppSize.radiusM),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: reasonKey,
                            groupValue: _selectedReason,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedReason = val);
                            },
                            activeColor: AppColors.primary,
                          ),
                          Expanded(
                            child: Text(
                              label,
                              style: CustomTextStyle.size14W400(
                                color: isSelected ? AppColors.white100 : AppColors.grey300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: AppSize.spacingM),
                Text(
                  loc.translate('additional_details_optional'),
                  style: CustomTextStyle.size14W500(color: AppColors.grey300),
                ),
                const SizedBox(height: AppSize.spacingS),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  style: CustomTextStyle.size14W400(color: AppColors.white100),
                  decoration: InputDecoration(
                    hintText: loc.translate('report_hint_text'),
                    hintStyle: CustomTextStyle.size14W400(color: AppColors.grey500),
                    filled: true,
                    fillColor: AppColors.grey800,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.radiusM),
                      borderSide: const BorderSide(color: AppColors.grey700),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.radiusM),
                      borderSide: const BorderSide(color: AppColors.grey700),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.radiusM),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              child: Text(
                loc.translate('cancel'),
                style: CustomTextStyle.size14W500(color: AppColors.grey400),
              ),
            ),
            ElevatedButton(
              onPressed: _isSubmitting ? null : () => _submitReport(loc),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSize.radiusM),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white100,
                      ),
                    )
                  : Text(
                      loc.translate('submit_report_btn'),
                      style: CustomTextStyle.size14W600(color: AppColors.white100),
                    ),
            ),
          ],
        );
      },
    );
  }
}

