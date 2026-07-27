// lib/pages/dashboard/home/cubit/home_state.dart
part of 'home_cubit.dart';

class HomeState extends Equatable {
  final List<ActionModel> actions;
  final bool isLoading;
  final int unreadCount;

  const HomeState({
    this.actions = const [],
    this.isLoading = false,
    this.unreadCount = 3,
  });

  HomeState copyWith({
    List<ActionModel>? actions,
    bool? isLoading,
    int? unreadCount,
  }) {
    return HomeState(
      actions: actions ?? this.actions,
      isLoading: isLoading ?? this.isLoading,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [actions, isLoading, unreadCount];
}