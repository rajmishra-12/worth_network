import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      final List<UserModel> fetchedUsers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        fetchedUsers.add(UserModel(
          id: doc.id,
          name: data['name'] ?? 'User',
          avatarUrl: data['avatarUrl'] ?? 'https://i.pravatar.cc/150?img=1',
          score: data['score'] ?? 0,
          level: data['level'] ?? 1,
          category: data['category'] ?? 'Support',
          location: data['location'] ?? 'Worldwide',
          isOnline: true,
          verified: (data['score'] ?? 0) > 100,
          actionsCount: data['totalActions'] ?? 0,
        ));
      }

      if (fetchedUsers.isNotEmpty) {
        allUsers = fetchedUsers;
      } else {
        allUsers = _getFallbackUsers();
      }
    } catch (e) {
      print("Failed to fetch users from Firestore: $e");
      allUsers = _getFallbackUsers();
    }

    _applyFilters();
  }

  List<UserModel> _getFallbackUsers() {
    return const [
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
    ];
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