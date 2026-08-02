import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:worth_network/core/repo/action_repo.dart';

part 'add_action_state.dart';

enum EvidenceType { photo, document, audio, text, none }

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
    emit(state.copyWith(
      evidenceType: type,
      evidenceFile: file,
      textProof: null,
    ));
  }

  void addTextProof(String text) {
    emit(state.copyWith(
      evidenceType: EvidenceType.text,
      textProof: text,
      evidenceFile: null,
    ));
  }

  void removeEvidence() {
    emit(state.copyWith(
      evidenceType: EvidenceType.none,
      evidenceFile: null,
      textProof: null,
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