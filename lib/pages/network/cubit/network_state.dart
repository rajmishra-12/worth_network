// lib/pages/dashboard/network/cubit/network_state.dart
part of 'network_cubit.dart';



class NetworkState extends Equatable {
  final List<UserModel> filteredUsers;
  final List<UserModel> users;
  final bool isLoading;
  final String searchQuery;
  final UserFilter selectedFilter;

  const NetworkState({
    this.filteredUsers = const [],
    this.users = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedFilter = UserFilter.all,
  });

  NetworkState copyWith({
    List<UserModel>? filteredUsers,
    List<UserModel>? users,
    bool? isLoading,
    String? searchQuery,
    UserFilter? selectedFilter,
  }) {
    return NetworkState(
      filteredUsers: filteredUsers ?? this.filteredUsers,
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => [
    filteredUsers,
    users,
    isLoading,
    searchQuery,
    selectedFilter,
  ];
}