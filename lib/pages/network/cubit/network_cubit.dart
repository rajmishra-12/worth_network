// lib/pages/dashboard/network/cubit/network_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:equatable/equatable.dart';
import 'package:worth_network/core/model/user/user_model.dart';

part 'network_state.dart';

enum UserFilter {
  all,
  local,
  support,
  work,
  health,
  topRated,
}

class NetworkCubit extends Cubit<NetworkState> {
  NetworkCubit() : super(const NetworkState());

  List<UserModel> allUsers = [];

  Future<void> loadUsers() async {
    emit(state.copyWith(isLoading: true));
    
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    allUsers = [
      UserModel(
        id: '1',
        name: 'Sarah Johnson',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        score: 2450,
        level: 7,
        category: 'Support',
        location: 'New York, NY',
        isOnline: true,
        verified: true,
        actionsCount: 42,
      ),
      UserModel(
        id: '2',
        name: 'Michael Chen',
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
        score: 1890,
        level: 5,
        category: 'Work',
        location: 'San Francisco, CA',
        isOnline: false,
        verified: true,
        actionsCount: 28,
      ),
      UserModel(
        id: '3',
        name: 'Emma Watson',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        score: 3120,
        level: 9,
        category: 'Health',
        location: 'Los Angeles, CA',
        isOnline: true,
        verified: true,
        actionsCount: 67,
      ),
      UserModel(
        id: '4',
        name: 'James Rodriguez',
        avatarUrl: 'https://i.pravatar.cc/150?img=4',
        score: 920,
        level: 3,
        category: 'Support',
        location: 'Miami, FL',
        isOnline: false,
        verified: false,
        actionsCount: 15,
      ),
      UserModel(
        id: '5',
        name: 'Olivia Martinez',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        score: 2780,
        level: 8,
        category: 'Work',
        location: 'Austin, TX',
        isOnline: true,
        verified: true,
        actionsCount: 53,
      ),
      UserModel(
        id: '6',
        name: 'Liam Thompson',
        avatarUrl: 'https://i.pravatar.cc/150?img=6',
        score: 450,
        level: 2,
        category: 'Health',
        location: 'Seattle, WA',
        isOnline: false,
        verified: false,
        actionsCount: 8,
      ),
    ];
    
    _applyFilters();
  }

  void searchUsers(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilters();
  }

  void clearSearch() {
    emit(state.copyWith(searchQuery: ''));
    _applyFilters();
  }

  void setFilter(UserFilter filter) {
    emit(state.copyWith(selectedFilter: filter));
    _applyFilters();
  }

  void _applyFilters() {
    List<UserModel> filtered = List.from(allUsers);
    
    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(
          state.searchQuery.toLowerCase(),
        );
      }).toList();
    }
    
    // Apply category filter
    switch (state.selectedFilter) {
      case UserFilter.local:
        // TODO: Implement location-based filtering
        break;
      case UserFilter.support:
        filtered = filtered.where((user) => user.category == 'Support').toList();
        break;
      case UserFilter.work:
        filtered = filtered.where((user) => user.category == 'Work').toList();
        break;
      case UserFilter.health:
        filtered = filtered.where((user) => user.category == 'Health').toList();
        break;
      case UserFilter.topRated:
        filtered.sort((a, b) => b.score.compareTo(a.score));
        filtered = filtered.take(5).toList();
        break;
      case UserFilter.all:
        break;
    }
    
    emit(state.copyWith(
      filteredUsers: filtered,
      isLoading: false,
    ));
  }
}