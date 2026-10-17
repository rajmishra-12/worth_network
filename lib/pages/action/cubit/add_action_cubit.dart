import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:worth_network/core/model/home/evidence_model.dart';
import 'package:worth_network/core/repo/action_repo.dart';

part 'add_action_state.dart';

enum EvidenceType { photo, document, audio, text, link, none }

class AddActionCubit extends Cubit<AddActionState> {
  final ActionRepository _repository;

  AddActionCubit({ActionRepository? repository})
      : _repository = repository ?? ActionRepository(),
        super(AddActionState());

  void clearErrorMessage() {
    emit(state.copyWith(clearErrorMessage: true));
  }

  void updateTitle(String title) {
    emit(state.copyWith(title: title, clearErrorMessage: true));
  }

  void updateDescription(String description) {
    emit(state.copyWith(description: description, clearErrorMessage: true));
  }

  void updateImpact(String impact) {
    emit(state.copyWith(
      impact: impact,
      clearErrorMessage: true,
    ));
  }

  void updateCategory(String category) {
    emit(state.copyWith(category: category));
  }

  void updateDate(DateTime date) {
    emit(state.copyWith(date: date));
  }

  void updatePersonInvolved(String? person) {
    emit(state.copyWith(personInvolved: person));
  }

  void searchUsers(String query) async {
    if (query.trim().isEmpty) {
      emit(state.copyWith(searchResults: [], isSearchingUsers: false));
      return;
    }
    emit(state.copyWith(isSearchingUsers: true));
    final results = await _repository.searchUsers(query);
    emit(state.copyWith(searchResults: results, isSearchingUsers: false));
  }

  void selectValidator(Map<String, dynamic> user) {
    emit(state.copyWith(
      selectedValidator: user,
      personInvolved: user['name'],
      searchResults: [],
    ));
  }

  void removeValidator() {
    emit(state.copyWith(
      clearValidator: true,
      personInvolved: null,
    ));
  }

  void setValidationType(String type) {
    if (type == 'independent') {
      emit(state.copyWith(
        validationType: 'independent',
        clearValidator: true,
        personInvolved: null,
      ));
    } else {
      emit(state.copyWith(
        validationType: 'person',
        requestIndependentValidation: false,
      ));
    }
  }

  void toggleIndependentValidation(bool request) {
    emit(state.copyWith(
      requestIndependentValidation: request,
      validationType: request ? 'independent' : 'person',
      clearValidator: request,
      personInvolved: request ? null : state.personInvolved,
    ));
  }

  void addEvidence(EvidenceType type, File file) {
    String typeStr = 'photo';
    if (type == EvidenceType.document) typeStr = 'document';
    if (type == EvidenceType.audio) typeStr = 'audio';

    final newItem = EvidenceModel(
      type: typeStr,
      localFile: file,
    );

    final updated = List<EvidenceModel>.from(state.evidences)..add(newItem);
    emit(state.copyWith(
      evidenceType: type,
      evidenceFile: file,
      evidences: updated,
    ));
  }

  void addTextProof(String text) {
    if (text.trim().isEmpty) return;
    final newItem = EvidenceModel(
      type: 'text',
      text: text.trim(),
    );
    final updated = List<EvidenceModel>.from(state.evidences)..add(newItem);
    emit(state.copyWith(
      evidenceType: EvidenceType.text,
      textProof: text,
      evidences: updated,
    ));
  }

  Future<void> addLinkEvidence(String linkUrl) async {
    final cleanUrl = linkUrl.trim();
    if (cleanUrl.isEmpty) return;
    String formattedUrl = cleanUrl;
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      formattedUrl = 'https://$cleanUrl';
    }

    String? title;
    String? imageUrl;
    String? description;

    try {
      final metadata = await MetadataFetch.extract(formattedUrl);
      if (metadata != null) {
        title = metadata.title;
        imageUrl = metadata.image;
        description = metadata.description;
      }
    } catch (e) {
      print('Warning: Metadata fetch error for link $formattedUrl: $e');
    }

    final newItem = EvidenceModel(
      type: 'link',
      url: formattedUrl,
      title: title ?? formattedUrl,
      imageUrl: imageUrl,
      description: description,
    );

    final updated = List<EvidenceModel>.from(state.evidences)..add(newItem);
    emit(state.copyWith(
      evidenceType: EvidenceType.link,
      evidences: updated,
    ));
  }

  void toggleEvidenceVisibility(int index, bool isPublic) {
    if (index < 0 || index >= state.evidences.length) return;
    final updated = List<EvidenceModel>.from(state.evidences);
    updated[index] = updated[index].copyWith(isPublic: isPublic);
    emit(state.copyWith(evidences: updated));
  }

  void updatePublicConsent(bool consent) {
    emit(state.copyWith(publicEvidenceConsent: consent));
  }

  void removeEvidenceAt(int index) {
    if (index < 0 || index >= state.evidences.length) return;
    final updated = List<EvidenceModel>.from(state.evidences)..removeAt(index);
    emit(state.copyWith(
      evidences: updated,
      evidenceType: updated.isEmpty ? EvidenceType.none : state.evidenceType,
    ));
  }

  void removeEvidence() {
    emit(state.copyWith(
      evidenceType: EvidenceType.none,
      evidenceFile: null,
      textProof: null,
      evidences: const [],
      publicEvidenceConsent: false,
    ));
  }

  Future<void> submitAction() async {
    final effectiveDesc = state.description.trim().isNotEmpty
        ? state.description.trim()
        : state.impact.trim();
    final effectiveImpact = state.impact.trim().isNotEmpty
        ? state.impact.trim()
        : null;

    if (state.title.trim().isEmpty ||
        effectiveDesc.isEmpty ||
        state.category.trim().isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Please fill all required fields (title, description, category)',
      ));
      return;
    }

    final isIndependent = state.validationType == 'independent' || state.requestIndependentValidation;

    // Requirement: Supporting evidence (photo, document, audio, link) is strictly required for WORTH team validation
    if (isIndependent) {
      final hasSupportingEvidence = state.evidences.any(
        (e) => e.type == 'photo' || e.type == 'document' || e.type == 'audio' || e.type == 'link',
      ) || (state.evidenceFile != null && state.evidenceType != EvidenceType.text && state.evidenceType != EvidenceType.none);

      if (!hasSupportingEvidence) {
        emit(state.copyWith(
          errorMessage: 'err_independent_evidence_required',
        ));
        return;
      }
    }

    // Requirement: If any evidence is public, user must give mandatory consent
    final hasPublicEvidence = state.evidences.any((e) => e.isPublic);
    if (hasPublicEvidence && !state.publicEvidenceConsent) {
      emit(state.copyWith(
        errorMessage: 'evidence_consent_required',
      ));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      String? proofType;
      switch (state.evidenceType) {
        case EvidenceType.photo:
          proofType = 'photo';
          break;
        case EvidenceType.document:
          proofType = 'document';
          break;
        case EvidenceType.audio:
          proofType = 'audio';
          break;
        case EvidenceType.text:
          proofType = 'text';
          break;
        case EvidenceType.link:
          proofType = 'link';
          break;
        case EvidenceType.none:
          proofType = null;
          break;
      }

      await _repository.publishAction(
        title: state.title,
        description: effectiveDesc,
        category: state.category,
        impact: effectiveImpact,
        proofType: proofType,
        proofFile: state.evidenceFile,
        textProof: state.textProof,
        evidences: state.evidences,
        selectedValidator: isIndependent ? null : state.selectedValidator,
        validationType: isIndependent ? 'independent' : 'person',
        requestIndependentValidation: isIndependent,
      );

      emit(state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        shouldRefreshHome: true,
      ));
    } catch (e) {
      print('Submit action error: $e');
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit action: ${e.toString()}',
      ));
    }
  }

  void resetState() {
    emit(AddActionState());
  }
}