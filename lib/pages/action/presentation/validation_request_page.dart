import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/repo/action_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';


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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitValidation() async {
    setState(() => _isSubmitting = true);

    try {
      String decision = 'confirmed';
      if (_selectedDecision == 0) {
        decision = _confidenceScore >= 9.0 ? 'certified' : 'confirmed';
      } else if (_selectedDecision == 1) {
        decision = 'confirmed';
      } else {
        decision = 'rejected';
      }

      final repo = ActionRepository();
      await repo.submitValidation(
        actionId: widget.action.id,
        decision: decision,
        confidence: _confidenceScore,
        comment: _commentController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              decision == 'rejected'
                  ? 'Action marked as rejected.'
                  : 'Validation submitted successfully! Reputation scores updated.',
            ),
            backgroundColor: decision == 'rejected' ? AppColors.error : AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit validation: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final action = widget.action;
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
          'Validate Action',
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
                        backgroundImage: action.userAvatar != null
                            ? NetworkImage(action.userAvatar!)
                            : null,
                        child: action.userAvatar == null
                            ? Text(action.userName[0], style: const TextStyle(color: AppColors.white100, fontSize: 12))
                            : null,
                      ),
                      const SizedBox(width: AppSize.spacingS),
                      Text(
                        '${action.userName} requests validation',
                        style: CustomTextStyle.size13W500(color: AppColors.grey400),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSize.spacingM),
                  Text(
                    action.title,
                    style: CustomTextStyle.size16W600(color: AppColors.white100),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    action.description,
                    style: CustomTextStyle.size13W400(color: AppColors.grey300),
                  ),
                  const SizedBox(height: AppSize.spacingM),
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
                          action.category,
                          style: CustomTextStyle.size12W500(color: AppColors.primary),
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(action.createdAt),
                        style: CustomTextStyle.size12W400(color: AppColors.grey500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSize.spacingXL),

            // Proof Visualizer
            Text(
              'Submitted Proof / Evidence',
              style: CustomTextStyle.size15W600(color: AppColors.white100),
            ),
            const SizedBox(height: AppSize.spacingS),
            _buildProofSection(action),
            const SizedBox(height: AppSize.spacingXL),

            // Validation Decisions: Yes, Partially, No
            Text(
              'Your Assessment',
              style: CustomTextStyle.size15W600(color: AppColors.white100),
            ),
            const SizedBox(height: AppSize.spacingS),
            Row(
              children: [
                Expanded(
                  child: _buildDecisionButton(
                    index: 0,
                    label: 'Yes',
                    icon: Icons.check_circle_outline,
                    activeColor: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSize.spacingS),
                Expanded(
                  child: _buildDecisionButton(
                    index: 1,
                    label: 'Partially',
                    icon: Icons.hourglass_bottom_outlined,
                    activeColor: AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppSize.spacingS),
                Expanded(
                  child: _buildDecisionButton(
                    index: 2,
                    label: 'No',
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
                  'Impact Weight',
                  style: CustomTextStyle.size15W600(color: AppColors.white100),
                ),
                Text(
                  '${_confidenceScore.toInt()} / 10',
                  style: CustomTextStyle.size15W600(color: AppColors.primary),
                ),
              ],
            ),
            Text(
              'Assess the significance and confidence of this action',
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
              'Validator Notes / Feedback',
              style: CustomTextStyle.size15W600(color: AppColors.white100),
            ),
            const SizedBox(height: AppSize.spacingS),
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              style: CustomTextStyle.size14W400(color: AppColors.white100),
              decoration: InputDecoration(
                hintText: 'Enter details about your validation check (optional)',
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

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitValidation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.black100,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSize.radiusM),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: AppColors.black100, strokeWidth: 2.5),
                    )
                  : Text(
                      'Submit Validation',
                      style: CustomTextStyle.size16W600(color: AppColors.black100),
                    ),
            ),
            const SizedBox(height: AppSize.paddingXL),
          ],
        ),
      ),
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
