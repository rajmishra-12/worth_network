import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/repo/action_repo.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ActionRepository _repository;
  StreamSubscription<List<ActionModel>>? _feedSubscription;
  StreamSubscription<List<ActionModel>>? _followingFeedSubscription;

  HomeCubit({ActionRepository? repository})
      : _repository = repository ?? ActionRepository(),
        super(const HomeState()) {
    subscribeToFeed();
    subscribeToFollowingFeed();
  }

  void changeTab(HomeFeedTab tab) {
    emit(state.copyWith(currentTab: tab));
  }

  void subscribeToFeed() {
    emit(state.copyWith(isLoading: true));
    _feedSubscription?.cancel();
    _feedSubscription = _repository.getForYouFeedStream().listen(
      (actions) {
        emit(state.copyWith(actions: actions, isLoading: false));
      },
      onError: (error) {
        print('For You Feed stream error: $error');
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  void subscribeToFollowingFeed() {
    emit(state.copyWith(isFollowingLoading: true, followingError: null));
    _followingFeedSubscription?.cancel();
    _followingFeedSubscription = _repository.getFollowingFeedStream().listen(
      (actions) {
        emit(state.copyWith(
          followingActions: actions,
          isFollowingLoading: false,
          isFollowingNobody: actions.isEmpty,
        ));
      },
      onError: (error) {
        print('Following feed stream error: $error');
        emit(state.copyWith(
          isFollowingLoading: false,
          followingError: error.toString(),
        ));
      },
    );
  }

  Future<void> loadForYouFeed({bool isRefresh = false}) async {
    if (isRefresh) {
      emit(state.copyWith(
        isLoading: true,
        forYouError: null,
        forYouLastDoc: null,
        hasMoreForYou: true,
      ));
    } else {
      emit(state.copyWith(isLoading: true, forYouError: null));
    }

    try {
      final res = await _repository.getForYouFeedPage(
        limit: 10,
        lastDoc: isRefresh ? null : state.forYouLastDoc,
      );

      final List<ActionModel> newActions = res['actions'] as List<ActionModel>;
      final DocumentSnapshot? lastDoc = res['lastDoc'] as DocumentSnapshot?;
      final bool hasMore = res['hasMore'] as bool;

      emit(state.copyWith(
        actions: isRefresh ? newActions : [...state.actions, ...newActions],
        forYouLastDoc: lastDoc,
        hasMoreForYou: hasMore,
        isLoading: false,
      ));
    } catch (e) {
      print('Error loading For You feed page: $e');
      emit(state.copyWith(isLoading: false, forYouError: e.toString()));
    }
  }

  Future<void> loadMoreForYouFeed() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMoreForYou || state.forYouLastDoc == null) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    try {
      final res = await _repository.getForYouFeedPage(
        limit: 10,
        lastDoc: state.forYouLastDoc,
      );

      final List<ActionModel> newActions = res['actions'] as List<ActionModel>;
      final DocumentSnapshot? lastDoc = res['lastDoc'] as DocumentSnapshot?;
      final bool hasMore = res['hasMore'] as bool;

      final existingIds = state.actions.map((a) => a.id).toSet();
      final filteredNewActions = newActions.where((a) => !existingIds.contains(a.id)).toList();

      emit(state.copyWith(
        actions: [...state.actions, ...filteredNewActions],
        forYouLastDoc: lastDoc ?? state.forYouLastDoc,
        hasMoreForYou: hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      print('Error loading more For You feed: $e');
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> loadFollowingFeed({bool isRefresh = false}) async {
    if (isRefresh) {
      emit(state.copyWith(
        isFollowingLoading: true,
        followingError: null,
        followingLastDoc: null,
        hasMoreFollowing: true,
      ));
    } else {
      emit(state.copyWith(isFollowingLoading: true, followingError: null));
    }

    try {
      final res = await _repository.getFollowingFeedPage(
        limit: 10,
        lastDoc: isRefresh ? null : state.followingLastDoc,
      );

      final List<ActionModel> newActions = res['actions'] as List<ActionModel>;
      final DocumentSnapshot? lastDoc = res['lastDoc'] as DocumentSnapshot?;
      final bool hasMore = res['hasMore'] as bool;
      final bool isNobody = res['isFollowingNobody'] as bool? ?? false;

      emit(state.copyWith(
        followingActions: isRefresh ? newActions : [...state.followingActions, ...newActions],
        followingLastDoc: lastDoc,
        hasMoreFollowing: hasMore,
        isFollowingNobody: isNobody,
        isFollowingLoading: false,
      ));
    } catch (e) {
      print('Error loading Following feed page: $e');
      emit(state.copyWith(isFollowingLoading: false, followingError: e.toString()));
    }
  }

  Future<void> loadMoreFollowingFeed() async {
    if (state.isFollowingLoading || state.isFollowingLoadingMore || !state.hasMoreFollowing || state.followingLastDoc == null) {
      return;
    }

    emit(state.copyWith(isFollowingLoadingMore: true));

    try {
      final res = await _repository.getFollowingFeedPage(
        limit: 10,
        lastDoc: state.followingLastDoc,
      );

      final List<ActionModel> newActions = res['actions'] as List<ActionModel>;
      final DocumentSnapshot? lastDoc = res['lastDoc'] as DocumentSnapshot?;
      final bool hasMore = res['hasMore'] as bool;

      final existingIds = state.followingActions.map((a) => a.id).toSet();
      final filteredNewActions = newActions.where((a) => !existingIds.contains(a.id)).toList();

      emit(state.copyWith(
        followingActions: [...state.followingActions, ...filteredNewActions],
        followingLastDoc: lastDoc ?? state.followingLastDoc,
        hasMoreFollowing: hasMore,
        isFollowingLoadingMore: false,
      ));
    } catch (e) {
      print('Error loading more Following feed: $e');
      emit(state.copyWith(isFollowingLoadingMore: false));
    }
  }

  Future<void> loadFeed() async {
    await Future.wait([
      loadForYouFeed(isRefresh: true),
      loadFollowingFeed(isRefresh: true),
    ]);
  }

  Future<void> likeAction(String actionId) async {
    // Optimistic update for All feed
    final currentActions = List<ActionModel>.from(state.actions);
    final index = currentActions.indexWhere((a) => a.id == actionId);
    
    // Optimistic update for Following feed
    final currentFollowingActions = List<ActionModel>.from(state.followingActions);
    final followingIndex = currentFollowingActions.indexWhere((a) => a.id == actionId);

    if (index == -1 && followingIndex == -1) return;

    final targetAction = index != -1 ? currentActions[index] : currentFollowingActions[followingIndex];
    final wasLiked = targetAction.isLikedByUser;
    final newIsLiked = !wasLiked;
    final newLikesCount = (wasLiked ? targetAction.likesCount - 1 : targetAction.likesCount + 1).clamp(0, 999999);

    final updatedAction = targetAction.copyWith(
      isLikedByUser: newIsLiked,
      likesCount: newLikesCount,
    );

    if (index != -1) {
      currentActions[index] = updatedAction;
    }
    if (followingIndex != -1) {
      currentFollowingActions[followingIndex] = updatedAction;
    }

    emit(state.copyWith(
      actions: currentActions,
      followingActions: currentFollowingActions,
    ));

    try {
      await _repository.toggleLike(actionId, isCurrentlyLiked: wasLiked);
    } catch (e) {
      print('Error toggling like in background: $e');
      // Revert local state if background update fails
      if (index != -1) {
        currentActions[index] = targetAction;
      }
      if (followingIndex != -1) {
        currentFollowingActions[followingIndex] = targetAction;
      }
      emit(state.copyWith(
        actions: currentActions,
        followingActions: currentFollowingActions,
      ));
    }
  }

  Future<void> deleteAction(String actionId) async {
    try {
      await _repository.deleteAction(actionId);
    } catch (e) {
      print('Error deleting action: $e');
    }
  }

  void removeActionsByBlockedUser(String blockedUserId) {
    final filteredActions = state.actions.where((a) => a.userId != blockedUserId).toList();
    final filteredFollowingActions = state.followingActions.where((a) => a.userId != blockedUserId).toList();

    emit(state.copyWith(
      actions: filteredActions,
      followingActions: filteredFollowingActions,
    ));

    // Re-subscribe to feed streams to ensure background listeners reflect block rules
    subscribeToFeed();
    subscribeToFollowingFeed();
  }

  @override
  Future<void> close() {
    _feedSubscription?.cancel();
    _followingFeedSubscription?.cancel();
    return super.close();
  }
}