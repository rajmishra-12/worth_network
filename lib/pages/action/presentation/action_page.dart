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
  final _personController = TextEditingController();
  
  late AddActionCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<AddActionCubit>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
          body: BlocConsumer<AddActionCubit, AddActionState>(
            listener: (context, state) {
              if (state.isSuccess) {
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
              } else if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: AppColors.error,
                  ),
                );
                _cubit.clearErrorMessage();
              }
            },
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSize.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      
                      // Request Validation from Person Involved
                      _buildLabel(loc.translate('request_validation_label')),
                      const SizedBox(height: AppSize.spacingS),
                      PersonField(
                        controller: _personController,
                        cubit: _cubit,
                        state: state,
                      ),
                      const SizedBox(height: AppSize.spacingL),

                      
                      // Description Field
                      _buildLabel(loc.translate('description_label')),
                      const SizedBox(height: AppSize.spacingS),
                      TextFormField(
                        controller: _descriptionController,
                        style: CustomTextStyle.size15W400(color: AppColors.white100),
                        maxLines: 4,
                        decoration: _buildInputDecoration(
                          hintText: loc.translate('describe_placeholder'),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return loc.translate('err_desc_required');
                          }
                          if (value.length < 10) {
                            return loc.translate('err_desc_min_length');
                          }
                          return null;
                        },
                        onChanged: (value) => _cubit.updateDescription(value),
                      ),
                      const SizedBox(height: AppSize.spacingL),
                      
                      // Evidence System Title
                      Row(
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSize.spacingS),
                          Text(
                            loc.translate('add_proof_title'),
                            style: CustomTextStyle.size16W600(
                              color: AppColors.white100,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSize.spacingS),
                      Text(
                        loc.translate('add_proof_desc'),
                        style: CustomTextStyle.size12W400(color: AppColors.grey400),
                      ),
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