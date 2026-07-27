// lib/pages/dashboard/action/cubit/add_action_cubit.dart
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_action_state.dart';

enum EvidenceType { photo, document, audio, text, none }

class AddActionCubit extends Cubit<AddActionState> {
  AddActionCubit() : super( AddActionState());

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
    if (state.title.isEmpty ||
        state.description.isEmpty ||
        state.category.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Please fill all required fields',
      ));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      // TODO: Implement API call to submit action
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate successful submission
     emit(state.copyWith(
  isSubmitting: false,
  isSuccess: true,
  shouldRefreshHome: true,
));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit action. Please try again.',
      ));
    }
  }
}