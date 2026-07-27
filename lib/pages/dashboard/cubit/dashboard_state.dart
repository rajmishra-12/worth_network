// lib/pages/dashboard/cubit/dashboard_state.dart
part of 'dashboard_cubit.dart';

class DashboardState extends Equatable {
  final int currentIndex;
  final List<Widget> pages;

  const DashboardState({
    this.currentIndex = 0,
    this.pages = const [],
  });

  DashboardState copyWith({
    int? currentIndex,
    List<Widget>? pages,
  }) {
    return DashboardState(
      currentIndex: currentIndex ?? this.currentIndex,
      pages: pages ?? this.pages,
    );
  }

  @override
  List<Object?> get props => [currentIndex, pages];
}