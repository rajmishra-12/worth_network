// lib/pages/dashboard/profile/cubit/profile_state.dart
part of 'profile_cubit.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final ProfileModel? profile;
  final List<ActionModel> myActions;
  final List<HistoryItem> actionHistory;

  const ProfileState({
    this.isLoading = false,
    this.profile,
    this.myActions = const [],
    this.actionHistory = const [],
  });

  ProfileState copyWith({
    bool? isLoading,
    ProfileModel? profile,
    List<ActionModel>? myActions,
    List<HistoryItem>? actionHistory,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      myActions: myActions ?? this.myActions,
      actionHistory: actionHistory ?? this.actionHistory,
    );
  }

  @override
  List<Object?> get props => [isLoading, profile, myActions, actionHistory];
}