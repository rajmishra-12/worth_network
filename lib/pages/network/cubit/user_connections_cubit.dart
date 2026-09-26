import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:worth_network/core/model/user/user_model.dart';
import 'package:worth_network/core/repo/follow_repo.dart';

class UserConnectionsState extends Equatable {
  final bool isLoading;
  final List<UserModel> followers;
  final List<UserModel> following;
  final List<UserModel> filteredFollowers;
  final List<UserModel> filteredFollowing;
  final String searchQuery;
  final String? errorMessage;

  const UserConnectionsState({
    this.isLoading = true,
    this.followers = const [],
    this.following = const [],
    this.filteredFollowers = const [],
    this.filteredFollowing = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  UserConnectionsState copyWith({
    bool? isLoading,
    List<UserModel>? followers,
    List<UserModel>? following,
    List<UserModel>? filteredFollowers,
    List<UserModel>? filteredFollowing,
    String? searchQuery,
    String? errorMessage,
  }) {
    return UserConnectionsState(
      isLoading: isLoading ?? this.isLoading,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      filteredFollowers: filteredFollowers ?? this.filteredFollowers,
      filteredFollowing: filteredFollowing ?? this.filteredFollowing,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    followers,
    following,
    filteredFollowers,
    filteredFollowing,
    searchQuery,
    errorMessage,
  ];
}

class UserConnectionsCubit extends Cubit<UserConnectionsState> {
  final FollowRepository _followRepo;

  UserConnectionsCubit({FollowRepository? followRepo})
    : _followRepo = followRepo ?? FollowRepository(),
      super(const UserConnectionsState());

  Future<void> loadConnections(String userId) async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try { 
      final results = await Future.wait([
        _followRepo.getFollowers(userId).catchError((e) {
          print('Error in getFollowers: $e');
          return <UserModel>[];
        }),
        _followRepo.getFollowing(userId).catchError((e) {
          print('Error in getFollowing: $e');
          return <UserModel>[];
        }),
      ]);

      if (isClosed) return;

      final followersList = results[0];
      final followingList = results[1];

      emit(
        state.copyWith(
          isLoading: false,
          followers: followersList,
          following: followingList,
          filteredFollowers: _filterList(followersList, state.searchQuery),
          filteredFollowing: _filterList(followingList, state.searchQuery),
        ),
      );
    } catch (e, stack) {
      print('Failed to load user connections: $e\n$stack');
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load user connections: $e',
        ),
      );
    } finally {
      if (!isClosed && state.isLoading) {
        emit(state.copyWith(isLoading: false));
      }
    }
  }

  void search(String query) {
    if (isClosed) return;
    emit(
      state.copyWith(
        searchQuery: query,
        filteredFollowers: _filterList(state.followers, query),
        filteredFollowing: _filterList(state.following, query),
      ),
    );
  }

  List<UserModel> _filterList(List<UserModel> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.trim().toLowerCase();
    return list.where((user) {
      final nameMatch = user.name.toLowerCase().contains(q);
      final categoryMatch = user.category.toLowerCase().contains(q);
      return nameMatch || categoryMatch;
    }).toList();
  }
}
