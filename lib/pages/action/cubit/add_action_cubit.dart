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

  void updateTitle(String title) {
    emit(state.copyWith(title: title));
  }

  void updateDescription(String description) {
    emit(state.copyWith(description: description));
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
    ));
  }

  Future<void> submitAction() async {
    if (state.title.trim().isEmpty ||
        state.description.trim().isEmpty ||
        state.category.trim().isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Please fill all required fields (title, description, category)',
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
        description: state.description,
        category: state.category,
        proofType: proofType,
        proofFile: state.evidenceFile,
        textProof: state.textProof,
        evidences: state.evidences,
        selectedValidator: state.selectedValidator,
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