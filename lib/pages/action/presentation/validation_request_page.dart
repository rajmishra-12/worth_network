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


class ValidationRequestScreen extends StatefulWidget {
  final ActionModel action;

  const ValidationRequestScreen({super.key, required this.action});

  @override
  State<ValidationRequestScreen> createState() => _ValidationRequestScreenState();
}

class _ValidationRequestScreenState extends State<ValidationRequestScreen> {
  int _selectedDecision = 0; // 0 = Yes, 1 = Partially, 2 = No
  double _confidenceScore = 7.0; // Slider value 1-10
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  final ActionRepository _actionRepo = ActionRepository();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitValidation(AppLocalizations loc) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      String decision = 'confirmed';
      if (_selectedDecision == 0) {
        decision = _confidenceScore >= 8.0 ? 'certified' : 'confirmed';
      } else if (_selectedDecision == 1) {
        decision = 'confirmed';
      } else {
        decision = 'rejected';
      }

      await _actionRepo.submitValidationDecision(
        actionId: widget.action.id,
        decision: decision,
        confidence: _confidenceScore,
        comment: _commentController.text.trim(),
      );

      if (mounted) {
        context.pop();
        final isApproved = decision != 'rejected';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isApproved
                  ? loc.translate('val_submitted_success_score')
                  : loc.translate('val_submitted_rejected'),
            ),
            backgroundColor: isApproved ? AppColors.success : AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.translate('failed_to_submit_val')}$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.white100),
              onPressed: () => context.pop(),
            ),
            title: Text(
              loc.translate('validate_action_title'),
              style: CustomTextStyle.size18W600(color: AppColors.white100),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSize.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Request Header Information
                Container(
                  padding: const EdgeInsets.all(AppSize.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.grey900,
                    borderRadius: BorderRadius.circular(AppSize.radiusM),
                    border: Border.all(color: AppColors.grey800),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.grey800,
                            backgroundImage: action.userAvatar != null && action.userAvatar!.isNotEmpty
                                ? NetworkImage(action.userAvatar!)
                                : null,
                            child: action.userAvatar == null || action.userAvatar!.isEmpty
                                ? Text(
                                    action.userName.isNotEmpty ? action.userName[0].toUpperCase() : 'U',
                                    style: const TextStyle(color: AppColors.white100),
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSize.spacingS),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  action.userName,
                                  style: CustomTextStyle.size14W600(color: AppColors.white100),
                                ),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(action.createdAt),
                                  style: CustomTextStyle.size12W400(color: AppColors.grey400),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppSize.radiusS),
                            ),
                            child: Text(
                              action.category,
                              style: CustomTextStyle.size12W500(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSize.spacingM),
                      Text(
                        action.title,
                        style: CustomTextStyle.size16W600(color: AppColors.white100),
                      ),
                      const SizedBox(height: AppSize.spacingS),
                      Text(
                        action.description,
                        style: CustomTextStyle.size14W400(color: AppColors.grey300),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSize.spacingL),

                // Proof Visualizer
                Text(
                  loc.translate('submitted_proof_title'),
                  style: CustomTextStyle.size15W600(color: AppColors.white100),
                ),
                const SizedBox(height: AppSize.spacingS),
                _buildProofSection(action),
                const SizedBox(height: AppSize.spacingXL),

                // Validation Decisions: Yes, Partially, No
                Text(
                  loc.translate('your_assessment_title'),
                  style: CustomTextStyle.size15W600(color: AppColors.white100),
                ),
                const SizedBox(height: AppSize.spacingS),
                Row(
                  children: [
                    Expanded(
                      child: _buildDecisionButton(
                        index: 0,
                        label: loc.translate('assessment_yes'),
                        icon: Icons.check_circle_outline,
                        activeColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSize.spacingS),
                    Expanded(
                      child: _buildDecisionButton(
                        index: 1,
                        label: loc.translate('assessment_partially'),
                        icon: Icons.hourglass_bottom_outlined,
                        activeColor: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: AppSize.spacingS),
                    Expanded(
                      child: _buildDecisionButton(
                        index: 2,
                        label: loc.translate('assessment_no'),
                        icon: Icons.cancel_outlined,
                        activeColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSize.spacingXL),

                // Impact / Confidence Level Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.translate('impact_weight_title'),
                      style: CustomTextStyle.size15W600(color: AppColors.white100),
                    ),
                    Text(
                      '${_confidenceScore.toInt()} / 10',
                      style: CustomTextStyle.size15W600(color: AppColors.primary),
                    ),
                  ],
                ),
                Text(
                  loc.translate('impact_weight_desc'),
                  style: CustomTextStyle.size12W400(color: AppColors.grey400),
                ),
                const SizedBox(height: AppSize.spacingS),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.grey800,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.2),
                    valueIndicatorColor: AppColors.grey900,
                    valueIndicatorTextStyle: const TextStyle(color: AppColors.primary),
                  ),
                  child: Slider(
                    value: _confidenceScore,
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    label: _confidenceScore.toInt().toString(),
                    onChanged: (val) {
                      setState(() {
                        _confidenceScore = val;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppSize.spacingL),

                // Comments
                Text(
                  loc.translate('validator_notes_title'),
                  style: CustomTextStyle.size15W600(color: AppColors.white100),
                ),
                const SizedBox(height: AppSize.spacingS),
                TextFormField(
                  controller: _commentController,
                  maxLines: 4,
                  style: CustomTextStyle.size14W400(color: AppColors.white100),
                  decoration: InputDecoration(
                    hintText: loc.translate('validator_notes_hint'),
                    hintStyle: CustomTextStyle.size14W400(color: AppColors.grey500),
                    filled: true,
                    fillColor: AppColors.grey900,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.radiusM),
                      borderSide: const BorderSide(color: AppColors.grey800),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.radiusM),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.all(AppSize.paddingM),
                  ),
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitValidation(loc),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.7),
                    foregroundColor: AppColors.black100,
                    disabledForegroundColor: AppColors.black100,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSize.radiusM),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.black100,
                                strokeWidth: 2.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              loc.translate('submitting_text'),
                              style: CustomTextStyle.size16W600(color: AppColors.black100),
                            ),
                          ],
                        )
                      : Text(
                          loc.translate('submit_action'),
                          style: CustomTextStyle.size16W600(color: AppColors.black100),
                        ),
                ),
                const SizedBox(height: AppSize.spacingXL),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDecisionButton({
    required int index,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _selectedDecision == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDecision = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSize.paddingM),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : AppColors.grey900,
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.grey800,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : AppColors.grey500,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: CustomTextStyle.size14W600(
                color: isSelected ? activeColor : AppColors.grey300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProofSection(ActionModel action) {
    final proofType = action.proofType ?? 'text';
    final proofUrl = action.proofUrl;

    if (proofType == 'photo' && proofUrl != null) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          border: Border.all(color: AppColors.grey800),
          image: DecorationImage(
            image: NetworkImage(proofUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (proofType == 'document') {
      return Container(
        padding: const EdgeInsets.all(AppSize.paddingM),
        decoration: BoxDecoration(
          color: AppColors.grey900,
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          border: Border.all(color: AppColors.grey800),
        ),
        child: Row(
          children: [
            Icon(Icons.picture_as_pdf, color: AppColors.error, size: 32),
            const SizedBox(width: AppSize.spacingM),
            Expanded(
              child: Text(
                'Signed_Verification_Document.pdf',
                style: CustomTextStyle.size14W500(color: AppColors.white100),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.open_in_new, color: AppColors.primary, size: 18),
          ],
        ),
      );
    }

    if (proofType == 'audio') {
      return Container(
        padding: const EdgeInsets.all(AppSize.paddingM),
        decoration: BoxDecoration(
          color: AppColors.grey900,
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          border: Border.all(color: AppColors.grey800),
        ),
        child: Row(
          children: [
            Icon(Icons.play_circle_fill, color: AppColors.primary, size: 36),
            const SizedBox(width: AppSize.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recorded Voice Note Proof',
                    style: CustomTextStyle.size14W500(color: AppColors.white100),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Duration: 0:12',
                    style: CustomTextStyle.size11W400(color: AppColors.grey500),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSize.paddingM),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(AppSize.radiusM),
        border: Border.all(color: AppColors.grey800),
      ),
      child: Text(
        'Text Description: "Declared with verification note by Sarah Johnson regarding groceries support."',
        style: CustomTextStyle.size14W400(color: AppColors.grey300),
      ),
    );
  }
}
