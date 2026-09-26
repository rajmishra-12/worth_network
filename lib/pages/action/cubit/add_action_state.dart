part of 'add_action_cubit.dart';

class AddActionState extends Equatable {
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final String? personInvolved;
  final Map<String, dynamic>? selectedValidator;
  final List<Map<String, dynamic>> searchResults;
  final bool isSearchingUsers;
  final EvidenceType evidenceType;
  final File? evidenceFile;
  final String? textProof;
  final List<EvidenceModel> evidences;
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
    this.selectedValidator,
    this.searchResults = const [],
    this.isSearchingUsers = false,
    this.evidenceType = EvidenceType.none,
    this.evidenceFile,
    this.textProof,
    this.evidences = const [],
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
    Map<String, dynamic>? selectedValidator,
    bool clearValidator = false,
    List<Map<String, dynamic>>? searchResults,
    bool? isSearchingUsers,
    EvidenceType? evidenceType,
    File? evidenceFile,
    String? textProof,
    List<EvidenceModel>? evidences,
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
      selectedValidator: clearValidator
          ? null
          : (selectedValidator ?? this.selectedValidator),
      searchResults: searchResults ?? this.searchResults,
      isSearchingUsers: isSearchingUsers ?? this.isSearchingUsers,
      evidenceType: evidenceType ?? this.evidenceType,
      evidenceFile: evidenceFile ?? this.evidenceFile,
      textProof: textProof ?? this.textProof,
      evidences: evidences ?? this.evidences,
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
    selectedValidator,
    searchResults,
    isSearchingUsers,
    evidenceType,
    evidenceFile,
    textProof,
    evidences,
    isSubmitting,
    isSuccess,
    errorMessage,
    shouldRefreshHome,
  ];
}
