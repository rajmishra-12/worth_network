// lib/pages/dashboard/action/cubit/add_action_state.dart
part of 'add_action_cubit.dart';

class AddActionState extends Equatable {
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final String? personInvolved;
  final EvidenceType evidenceType;
  final File? evidenceFile;
  final String? textProof;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
  final bool shouldRefreshHome;

 
  AddActionState({
    this.title = '',
    this.description = '',
    this.category = '',
    DateTime? date,
    this.personInvolved,
    this.evidenceType = EvidenceType.none,
    this.evidenceFile,
    this.textProof,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
    this.shouldRefreshHome = false,
  }) : date = date ?? DateTime.now();  

  AddActionState copyWith({
    String? title,
    String? description,
    String? category,
    DateTime? date,
    String? personInvolved,
    EvidenceType? evidenceType,
    File? evidenceFile,
    String? textProof,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    bool? shouldRefreshHome,
  }) {
    return AddActionState(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      personInvolved: personInvolved ?? this.personInvolved,
      evidenceType: evidenceType ?? this.evidenceType,
      evidenceFile: evidenceFile ?? this.evidenceFile,
      textProof: textProof ?? this.textProof,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      shouldRefreshHome: shouldRefreshHome ?? this.shouldRefreshHome,
    );
  }

  @override
  List<Object?> get props => [
    title,
    description,
    category,
    date,
    personInvolved,
    evidenceType,
    evidenceFile,
    textProof,
    isSubmitting,
    isSuccess,
    errorMessage,
  ];
}