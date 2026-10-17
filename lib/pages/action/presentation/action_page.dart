// lib/pages/dashboard/action/add_action_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/pages/action/cubit/add_action_cubit.dart';
import 'package:worth_network/pages/action/widgets/category_selector.dart';
import 'package:worth_network/pages/dashboard/cubit/dashboard_cubit.dart';



import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/pages/home/widgets/proof_card.dart';

class AddActionScreen extends StatefulWidget {
  const AddActionScreen({super.key});

  @override
  State<AddActionScreen> createState() => _AddActionScreenState();
}

class _AddActionScreenState extends State<AddActionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _impactController = TextEditingController();
  final _personController = TextEditingController();
  
  late AddActionCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<AddActionCubit>();
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _titleController.dispose();
    _descriptionController.dispose();
    _impactController.dispose();
    _personController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              loc.translate('add_action_title'),
              style: CustomTextStyle.size18W600(color: AppColors.white100),
            ),
            backgroundColor: AppColors.background,
            elevation: 0,
            actions: [
              BlocBuilder<AddActionCubit, AddActionState>(
                builder: (context, state) {
                  return TextButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            FocusScope.of(context).unfocus();
                            if (_formKey.currentState!.validate()) {
                              _cubit.submitAction();
                            }
                          },
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Text(
                            loc.translate('post_btn'),
                            style: CustomTextStyle.size16W600(
                              color: AppColors.primary,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              FocusScope.of(context).unfocus();
            },
            child: BlocConsumer<AddActionCubit, AddActionState>(
              listener: (context, state) {
                if (state.isSuccess) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.translate('action_submitted_success')),
                      backgroundColor: AppColors.success,
                    ),
                  );

                  // Navigate to Home tab
                  context.read<DashboardCubit>().changeTab(0);

                  // Reset cubit state
                  _cubit.resetState();

                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                }
 else if (state.errorMessage != null) {
                final rawMsg = state.errorMessage!;
                final errorMsg = rawMsg.startsWith('err_')
                    ? loc.translate(rawMsg)
                    : rawMsg;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMsg),
                    backgroundColor: AppColors.error,
                  ),
                );
                _cubit.clearErrorMessage();
              }
            },
            builder: (context, state) {
              final isIndependentValidation = state.validationType == 'independent' || state.requestIndependentValidation;
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSize.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Impact Callout Header
                      Container(
                        margin: const EdgeInsets.only(bottom: AppSize.paddingM),
                        padding: const EdgeInsets.all(AppSize.paddingS + 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.15),
                              AppColors.grey900,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppSize.radiusM),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.spa_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppSize.spacingS),
                            Expanded(
                              child: Text(
                                loc.translate('action_impact_question'),
                                style: CustomTextStyle.size13W500(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Title Field
                      _buildLabel(loc.translate('title_label')),
                      const SizedBox(height: AppSize.spacingS),
                      TextFormField(
                        controller: _titleController,
                        style: CustomTextStyle.size15W400(color: AppColors.white100),
                        decoration: _buildInputDecoration(
                          hintText: loc.translate('title_placeholder'),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return loc.translate('err_title_required');
                          }
                          if (value.length < 5) {
                            return loc.translate('err_title_min_length');
                          }
                          return null;
                        },
                        onChanged: (value) => _cubit.updateTitle(value),
                      ),
                      const SizedBox(height: AppSize.spacingL),
                      
                      // Category Selector
                      _buildLabel(loc.translate('category_label')),
                      const SizedBox(height: AppSize.spacingS),
                      CategorySelector(
                        selectedCategory: state.category,
                        onCategorySelected: _cubit.updateCategory,
                      ),
                      const SizedBox(height: AppSize.spacingL),
                      
                      // Date Field
                      _buildLabel(loc.translate('date_label')),
                      const SizedBox(height: AppSize.spacingS),
                      DatePickerField(
                        selectedDate: state.date,
                        onDateSelected: _cubit.updateDate,
                      ),
                      const SizedBox(height: AppSize.spacingL),
                      
                      // Validation Method Selection
                      _buildLabel(loc.translate('validation_method_label')),
                      const SizedBox(height: AppSize.spacingS),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _personController.clear();
                                  _cubit.setValidationType('person');
                                  _cubit.toggleIndependentValidation(false);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: state.validationType == 'person'
                                        ? AppColors.primary.withValues(alpha: 0.15)
                                        : AppColors.grey900,
                                    borderRadius: BorderRadius.circular(AppSize.radiusM),
                                    border: Border.all(
                                      color: state.validationType == 'person'
                                          ? AppColors.primary
                                          : AppColors.grey800,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.people_alt_outlined,
                                        size: 22,
                                        color: state.validationType == 'person'
                                            ? AppColors.primary
                                            : AppColors.grey500,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        loc.translate('validation_type_person_title'),
                                        textAlign: TextAlign.center,
                                        style: CustomTextStyle.size13W600(
                                          color: state.validationType == 'person'
                                              ? AppColors.white100
                                              : AppColors.grey300,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        loc.translate('validation_type_person'),
                                        textAlign: TextAlign.center,
                                        style: CustomTextStyle.size11W400(
                                          color: state.validationType == 'person'
                                              ? AppColors.primary
                                              : AppColors.grey500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSize.spacingM),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _personController.clear();
                                  _cubit.setValidationType('independent');
                                  _cubit.toggleIndependentValidation(true);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: state.validationType == 'independent'
                                        ? AppColors.primary.withValues(alpha: 0.15)
                                        : AppColors.grey900,
                                    borderRadius: BorderRadius.circular(AppSize.radiusM),
                                    border: Border.all(
                                      color: state.validationType == 'independent'
                                          ? AppColors.primary
                                          : AppColors.grey800,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.verified_outlined,
                                        size: 22,
                                        color: state.validationType == 'independent'
                                            ? AppColors.primary
                                            : AppColors.grey500,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        loc.translate('validation_type_independent_title'),
                                        textAlign: TextAlign.center,
                                        style: CustomTextStyle.size13W600(
                                          color: state.validationType == 'independent'
                                              ? AppColors.white100
                                              : AppColors.grey300,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        loc.translate('validation_type_independent'),
                                        textAlign: TextAlign.center,
                                        style: CustomTextStyle.size11W400(
                                          color: state.validationType == 'independent'
                                              ? AppColors.primary
                                              : AppColors.grey500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSize.spacingM),

                      // Validation Details based on type
                      if (state.validationType == 'person') ...[
                        _buildLabel(loc.translate('request_validation_label')),
                        const SizedBox(height: AppSize.spacingS),
                        PersonField(
                          controller: _personController,
                          cubit: _cubit,
                          state: state,
                        ),
                      ] else ...[
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
                                  const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      loc.translate('request_independent_validation'),
                                      style: CustomTextStyle.size14W600(color: AppColors.white100),
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: state.requestIndependentValidation,
                                    activeTrackColor: AppColors.primary,
                                    onChanged: (val) {
                                      _cubit.toggleIndependentValidation(val);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                loc.translate('request_independent_validation_desc'),
                                style: CustomTextStyle.size12W400(color: AppColors.grey400),
                              ),
                              if (state.requestIndependentValidation) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppSize.radiusS),
                                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star_outline, size: 16, color: AppColors.warning),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${loc.translate('potential_reward_label')}: +50 ${loc.translate('points_label')} • ${loc.translate('points_awarded_after_validation')}',
                                          style: CustomTextStyle.size11W500(color: AppColors.warning),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSize.spacingL),

                      
                      // Positive Impact Question Card & Field
                      Container(
                        padding: const EdgeInsets.all(AppSize.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppSize.radiusM),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.volunteer_activism_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSize.spacingS),
                                Expanded(
                                  child: Text(
                                    loc.translate('action_impact_question'),
                                    style: CustomTextStyle.size14W600(
                                      color: AppColors.white100,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSize.spacingM),
                            TextFormField(
                              controller: _impactController,
                              style: CustomTextStyle.size15W400(color: AppColors.white100),
                              maxLines: 4,
                              decoration: _buildInputDecoration(
                                hintText: loc.translate('action_impact_placeholder'),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                final desc = _descriptionController.text.trim();
                                if (text.isEmpty && desc.isEmpty) {
                                  return loc.translate('err_desc_required');
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _cubit.updateImpact(value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSize.spacingL),

                      // Description Field (Optional details)
                      _buildLabel('${loc.translate('description_label')} (${loc.translate('optional')})'),
                      const SizedBox(height: AppSize.spacingS),
                      TextFormField(
                        controller: _descriptionController,
                        style: CustomTextStyle.size15W400(color: AppColors.white100),
                        maxLines: 3,
                        decoration: _buildInputDecoration(
                          hintText: loc.translate('describe_placeholder'),
                        ),
                        onChanged: (value) => _cubit.updateDescription(value),
                      ),
                      const SizedBox(height: AppSize.spacingL),
                      
                      // Evidence System Title
                      Row(
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            color: isIndependentValidation ? AppColors.accent : AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSize.spacingS),
                          Expanded(
                            child: Text(
                              isIndependentValidation
                                  ? loc.translate('evidence_required_for_worth')
                                  : loc.translate('add_proof_title'),
                              style: CustomTextStyle.size16W600(
                                color: isIndependentValidation ? AppColors.accent : AppColors.white100,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSize.spacingS),
                      if (isIndependentValidation) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSize.paddingS + 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSize.radiusS),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  loc.translate('evidence_required_for_worth_banner'),
                                  style: CustomTextStyle.size12W400(color: AppColors.grey300),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Text(
                          loc.translate('add_proof_desc'),
                          style: CustomTextStyle.size12W400(color: AppColors.grey400),
                        ),
                      ],
                      const SizedBox(height: AppSize.spacingM),
                      
                      // Evidence Type Selector
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.grey900,
                          borderRadius: BorderRadius.circular(AppSize.radiusM),
                          border: Border.all(color: AppColors.grey800),
                        ),
                        child: Column(
                          children: [
                            _buildEvidenceOption(
                              icon: Icons.photo_camera_outlined,
                              label: loc.translate('proof_photo'),
                              description: loc.translate('proof_photo_desc'),
                              isSelected: state.evidenceType == EvidenceType.photo,
                              onTap: () => _pickImage(context, loc),
                            ),
                            _buildDivider(),
                            _buildEvidenceOption(
                              icon: Icons.description_outlined,
                              label: loc.translate('proof_document'),
                              description: loc.translate('proof_document_desc'),
                              isSelected: state.evidenceType == EvidenceType.document,
                              onTap: () => _pickDocument(context, loc),
                            ),
                            _buildDivider(),
                            _buildEvidenceOption(
                              icon: Icons.mic_none_outlined,
                              label: loc.translate('proof_audio'),
                              description: loc.translate('proof_audio_desc'),
                              isSelected: state.evidenceType == EvidenceType.audio,
                              onTap: () => _showAudioRecorderDialog(context, loc),
                            ),
                            _buildDivider(),
                            _buildEvidenceOption(
                              icon: Icons.text_fields,
                              label: loc.translate('proof_text'),
                              description: loc.translate('proof_text_desc'),
                              isSelected: state.evidenceType == EvidenceType.text,
                              onTap: () => _showTextProofDialog(context, loc),
                            ),
                            _buildDivider(),
                            _buildEvidenceOption(
                              icon: Icons.link_rounded,
                              label: loc.translate('link_web_url_label'),
                              description: loc.translate('link_web_url_desc'),
                              isSelected: state.evidenceType == EvidenceType.link,
                              onTap: () => _showLinkProofDialog(context, loc),
                            ),
                          ],
                        ),
                      ),
                      
                      // Evidence Previews List (Multi-Evidence Support with Carousel)
                      if (state.evidences.isNotEmpty) ...[
                        const SizedBox(height: AppSize.spacingM),
                        Text(
                          '${loc.translate('attached_evidence_count')} (${state.evidences.length})',
                          style: CustomTextStyle.size14W600(color: AppColors.white100),
                        ),
                        const SizedBox(height: AppSize.spacingS),
                        ProofCard(
                          evidences: state.evidences,
                          onRemoveAtIndex: (index) => _cubit.removeEvidenceAt(index),
                        ),
                        // Evidence Visibility Options
                        Container(
                          margin: const EdgeInsets.only(top: AppSize.paddingM),
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
                                  const Icon(Icons.shield_outlined, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    loc.translate('evidence_privacy_title'),
                                    style: CustomTextStyle.size14W600(color: AppColors.white100),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                loc.translate('evidence_private_desc'),
                                style: CustomTextStyle.size12W400(color: AppColors.grey400),
                              ),
                              const SizedBox(height: AppSize.spacingM),
                              ...state.evidences.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final ev = entry.value;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.grey800,
                                    borderRadius: BorderRadius.circular(AppSize.radiusS),
                                    border: Border.all(color: AppColors.grey700),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        ev.type == 'photo'
                                            ? Icons.image_outlined
                                            : ev.type == 'document'
                                                ? Icons.description_outlined
                                                : ev.type == 'audio'
                                                    ? Icons.mic_none_outlined
                                                    : ev.type == 'link'
                                                        ? Icons.link_rounded
                                                        : Icons.format_quote,
                                        size: 16,
                                        color: AppColors.grey300,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${loc.translate('step_proof')} #${idx + 1} (${ev.type.toUpperCase()})',
                                          style: CustomTextStyle.size12W500(color: AppColors.grey300),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => _cubit.toggleEvidenceVisibility(idx, !ev.isPublic),
                                        borderRadius: BorderRadius.circular(AppSize.radiusS),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: ev.isPublic
                                                ? AppColors.primary.withValues(alpha: 0.15)
                                                : AppColors.grey800,
                                            borderRadius: BorderRadius.circular(AppSize.radiusS),
                                            border: Border.all(
                                              color: ev.isPublic ? AppColors.primary : AppColors.grey700,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                ev.isPublic ? Icons.public : Icons.lock_outline,
                                                size: 12,
                                                color: ev.isPublic ? AppColors.primary : AppColors.grey400,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                ev.isPublic
                                                    ? loc.translate('evidence_public_label')
                                                    : loc.translate('evidence_private_label'),
                                                style: CustomTextStyle.size11W600(
                                                  color: ev.isPublic ? AppColors.primary : AppColors.grey400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),

                        // Mandatory warning & consent checkbox when any evidence is public
                        if (state.evidences.any((e) => e.isPublic)) ...[
                          const SizedBox(height: AppSize.spacingM),
                          Container(
                            padding: const EdgeInsets.all(AppSize.paddingM),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(AppSize.radiusM),
                              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        loc.translate('evidence_public_warning'),
                                        style: CustomTextStyle.size12W500(color: AppColors.warning),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSize.spacingM),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: state.publicEvidenceConsent,
                                        onChanged: (val) => _cubit.updatePublicConsent(val ?? false),
                                        activeColor: AppColors.primary,
                                        checkColor: AppColors.black100,
                                        side: const BorderSide(color: AppColors.grey600),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _cubit.updatePublicConsent(!state.publicEvidenceConsent),
                                        child: Text(
                                          loc.translate('evidence_public_consent'),
                                          style: CustomTextStyle.size12W500(color: AppColors.white100),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ] else if (state.evidenceFile != null || state.textProof != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSize.paddingM),
                          child: EvidencePreview(
                            evidenceType: state.evidenceType,
                            evidenceFile: state.evidenceFile,
                            textProof: state.textProof,
                            onRemove: _cubit.removeEvidence,
                          ),
                        ),
                      
                      const SizedBox(height: AppSize.spacingXL),
                      
                      // Validation Info
                      Container(
                        padding: const EdgeInsets.all(AppSize.paddingM),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppSize.radiusM),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: AppSize.spacingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.translate('validation_required_title'),
                                    style: CustomTextStyle.size14W600(
                                      color: AppColors.white100,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    loc.translate('validation_required_desc'),
                                    style: CustomTextStyle.size12W400(
                                      color: AppColors.grey400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSize.paddingXL),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: CustomTextStyle.size14W600(color: AppColors.white100),
    );
  }

  InputDecoration _buildInputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: CustomTextStyle.size15W400(color: AppColors.grey500),
      filled: true,
      fillColor: AppColors.grey900,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.radiusM),
        borderSide: BorderSide(color: AppColors.grey800),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.radiusM),
        borderSide: BorderSide(color: AppColors.grey800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.radiusM),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.radiusM),
        borderSide: BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSize.paddingM,
        vertical: AppSize.paddingM,
      ),
    );
  }

  Widget _buildEvidenceOption({
    required IconData icon,
    required String label,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSize.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppSize.paddingM),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSize.paddingS),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.grey800,
                  borderRadius: BorderRadius.circular(AppSize.radiusM),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.primary : AppColors.grey400,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSize.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: CustomTextStyle.size14W600(
                        color: isSelected ? AppColors.primary : AppColors.white100,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: CustomTextStyle.size12W400(color: AppColors.grey400),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: AppColors.grey800,
    );
  }

  Future<void> _pickImage(BuildContext context, AppLocalizations loc) async {
    final picker = ImagePicker();
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.grey900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.radiusL)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text(
                loc.translate('take_photo'),
                style: CustomTextStyle.size15W500(color: AppColors.white100),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: Text(
                loc.translate('choose_from_gallery'),
                style: CustomTextStyle.size15W500(color: AppColors.white100),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    
    if (result != null) {
      final pickedFile = await picker.pickImage(
        source: result,
        imageQuality: 70, // Reduces image file size by ~60-70%
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await file.length();
        // Validation: max 10MB limit
        if (bytes > 10 * 1024 * 1024) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.translate('err_image_size_limit')),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
        _cubit.addEvidence(EvidenceType.photo, file);
      }
    }
  }

  Future<void> _pickDocument(BuildContext context, AppLocalizations loc) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.length();
      if (bytes > 10 * 1024 * 1024) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.translate('err_doc_size_limit')),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
      _cubit.addEvidence(EvidenceType.document, file);
    }
  }

  void _showAudioRecorderDialog(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => const AudioRecorderDialog(),
    ).then((recordedFile) async {
      if (recordedFile != null) {
        final bytes = await recordedFile.length();
        if (bytes > 10 * 1024 * 1024) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.translate('err_audio_size_limit')),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
        _cubit.addEvidence(EvidenceType.audio, recordedFile);
      }
    });
  }

  void _showTextProofDialog(BuildContext context, AppLocalizations loc) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.grey900,
        title: Text(
          loc.translate('add_text_proof_title'),
          style: CustomTextStyle.size18W600(color: AppColors.white100),
        ),
        content: TextField(
          controller: controller,
          maxLines: 5,
          style: CustomTextStyle.size14W400(color: AppColors.white100),
          decoration: _buildInputDecoration(
            hintText: loc.translate('add_text_proof_hint'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              loc.translate('cancel'),
              style: CustomTextStyle.size14W500(color: AppColors.grey400),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.pop();
                _cubit.addTextProof(controller.text);
              }
            },
            child: Text(
              loc.translate('add_btn'),
              style: CustomTextStyle.size14W600(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showLinkProofDialog(BuildContext context, AppLocalizations loc) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.grey900,
        title: Text(
          loc.translate('add_link_proof_title'),
          style: CustomTextStyle.size18W600(color: AppColors.white100),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('add_link_proof_desc'),
              style: CustomTextStyle.size12W400(color: AppColors.grey400),
            ),
            const SizedBox(height: AppSize.spacingM),
            TextField(
              controller: controller,
              style: CustomTextStyle.size14W400(color: AppColors.white100),
              decoration: _buildInputDecoration(
                hintText: 'https://example.com/article',
              ),
              keyboardType: TextInputType.url,
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
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(dialogContext);
                _cubit.addLinkEvidence(text);
              }
            },
            child: Text(
              loc.translate('fetch_and_add_btn'),
              style: CustomTextStyle.size14W600(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// Audio Recorder Dialog
class AudioRecorderDialog extends StatefulWidget {
  const AudioRecorderDialog({super.key});

  @override
  State<AudioRecorderDialog> createState() => _AudioRecorderDialogState();
}

class _AudioRecorderDialogState extends State<AudioRecorderDialog> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;
    
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
    
    await _recorder.start(
      RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        
      ),
      path: path,
    );
    
    setState(() {
      _isRecording = true;
      _recordingPath = path;
      _recordingDuration = Duration.zero;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration += const Duration(seconds: 1);
      });
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    _timer?.cancel();
    setState(() {
      _isRecording = false;
    });
    
    if (path != null && mounted) {
      Navigator.pop(context, File(path));
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return AlertDialog(
          backgroundColor: AppColors.grey900,
          title: Text(
            loc.translate('record_audio_proof_title'),
            style: CustomTextStyle.size18W600(color: AppColors.white100),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.grey800,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    size: 40,
                    color: _isRecording ? AppColors.error : AppColors.primary,
                  ),
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                ),
              ),
              const SizedBox(height: AppSize.spacingM),
              if (_isRecording)
                Text(
                  _formatDuration(_recordingDuration),
                  style: CustomTextStyle.size20W600(color: AppColors.white100),
                ),
              if (_isRecording)
                const SizedBox(height: AppSize.spacingS),
              Text(
                _isRecording ? loc.translate('recording_status') : loc.translate('tap_to_start_recording'),
                style: CustomTextStyle.size14W400(color: AppColors.grey400),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                loc.translate('cancel'),
                style: CustomTextStyle.size14W500(color: AppColors.grey400),
              ),
            ),
          ],
        );
      },
    );
  }
}