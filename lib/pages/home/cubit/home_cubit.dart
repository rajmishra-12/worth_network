import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/repo/action_repo.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ActionRepository _repository;
  StreamSubscription<List<ActionModel>>? _feedSubscription;

  HomeCubit({ActionRepository? repository})
      : _repository = repository ?? ActionRepository(),
        super(const HomeState()) {
    subscribeToFeed();
  }

  void subscribeToFeed() {
    emit(state.copyWith(isLoading: true));
    _feedSubscription?.cancel();
    _feedSubscription = _repository.getFeedStream().listen((actions) {
      emit(state.copyWith(actions: actions, isLoading: false));
    }, onError: (error) {
      print('Feed stream error: $error');
      emit(state.copyWith(isLoading: false));
    });
  }

  Future<void> loadFeed() async {
    subscribeToFeed();
  }

  Future<void> likeAction(String actionId) async {
    final currentActions = List<ActionModel>.from(state.actions);
    final index = currentActions.indexWhere((a) => a.id == actionId);
    if (index == -1) return;

    final oldAction = currentActions[index];
    final wasLiked = oldAction.isLikedByUser;
    final newIsLiked = !wasLiked;
    final newLikesCount = (wasLiked ? oldAction.likesCount - 1 : oldAction.likesCount + 1).clamp(0, 999999);

    final updatedAction = oldAction.copyWith(
      isLikedByUser: newIsLiked,
      likesCount: newLikesCount,
    );

    // 1. Instant 0-ms local optimistic state update (UI heart flips immediately!)
    currentActions[index] = updatedAction;
    emit(state.copyWith(actions: currentActions));

    // 2. Fire background network payload without blocking UI thread
    try {
      await _repository.toggleLike(actionId, isCurrentlyLiked: wasLiked);
    } catch (e) {
      print('Error toggling like in background: $e');
      // Revert local state if background update fails
      final rollbackActions = List<ActionModel>.from(state.actions);
      final rbIndex = rollbackActions.indexWhere((a) => a.id == actionId);
      if (rbIndex != -1) {
        rollbackActions[rbIndex] = oldAction;
        emit(state.copyWith(actions: rollbackActions));
      }
    }
  }


  Future<void> deleteAction(String actionId) async {
    try {
      await _repository.deleteAction(actionId);
    } catch (e) {
      print('Error deleting action: $e');
    }
  }

  @override
  Future<void> close() {

    _feedSubscription?.cancel();
    return super.close();
  }
}