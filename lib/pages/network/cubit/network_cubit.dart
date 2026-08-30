import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:worth_network/core/model/user/user_model.dart';

part 'network_state.dart';

enum UserFilter {
  all,
  support,
  work,
  health,
  community,
  education,
  environment,
  other,
  topRated,
}

class NetworkCubit extends Cubit<NetworkState> {
  NetworkCubit() : super(const NetworkState());

  List<UserModel> allUsers = [];

  Future<void> loadUsers() async {
    emit(state.copyWith(isLoading: true));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      final List<UserModel> fetchedUsers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        fetchedUsers.add(
          UserModel(
            id: doc.id,
            name: data['name'] ?? 'User',
            avatarUrl: data['avatarUrl'] ?? '',
            score: data['score'] ?? 0,
            level: data['level'] ?? 1,
            category: data['category'] ?? 'Support',
            location: data['location'] ?? 'Worldwide',
            isOnline: true,
            verified: (data['score'] ?? 0) > 100,
            actionsCount: data['totalActions'] ?? 0,
          ),
        );
      }

      allUsers = fetchedUsers;
    } catch (e) {
      print("Failed to fetch users from Firestore: $e");
      allUsers = [];
    }

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

    // Apply search filter (dynamic multi-field match)
    if (state.searchQuery.trim().isNotEmpty) {
      final query = state.searchQuery.trim().toLowerCase();
      filtered = filtered.where((user) {
        final matchesName = user.name.toLowerCase().contains(query);
        final matchesLocation = user.location.toLowerCase().contains(query);
        final matchesCategory = user.category.toLowerCase().contains(query);
        return matchesName || matchesLocation || matchesCategory;
      }).toList();
    }

    // Apply category filter
    switch (state.selectedFilter) {
      case UserFilter.support:
        filtered = filtered
            .where((user) => user.category.toLowerCase() == 'support')
            .toList();
        break;
      case UserFilter.work:
        filtered = filtered
            .where((user) => user.category.toLowerCase() == 'work')
            .toList();
        break;
      case UserFilter.health:
        filtered = filtered
            .where((user) => user.category.toLowerCase() == 'health')
            .toList();
        break;
      case UserFilter.community:
        filtered = filtered
            .where((user) => user.category.toLowerCase() == 'community')
            .toList();
        break;
      case UserFilter.education:
        filtered = filtered
            .where((user) => user.category.toLowerCase() == 'education')
            .toList();
        break;
      case UserFilter.environment:
        filtered = filtered
            .where((user) => user.category.toLowerCase() == 'environment')
            .toList();
        break;
      case UserFilter.other:
        filtered = filtered
            .where((user) => user.category.toLowerCase() == 'other')
            .toList();
        break;
      case UserFilter.topRated:
        filtered.sort((a, b) => b.score.compareTo(a.score));
        filtered = filtered.take(10).toList();
        break;
      case UserFilter.all:
        break;
    }

    emit(state.copyWith(filteredUsers: filtered, isLoading: false));
  }
}
