import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:worth_network/core/repo/follow_repo.dart';

class FollowState extends Equatable {
  final bool isFollowing;
  final bool isToggling;
  final String? errorMessage;

  const FollowState({
    this.isFollowing = false,
    this.isToggling = false,
    this.errorMessage,
  });

  FollowState copyWith({
    bool? isFollowing,
    bool? isToggling,
    String? errorMessage,
  }) {
    return FollowState(
      isFollowing: isFollowing ?? this.isFollowing,
      isToggling: isToggling ?? this.isToggling,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isFollowing, isToggling, errorMessage];
}

class FollowCubit extends Cubit<FollowState> {
  final FollowRepository _followRepo;
  StreamSubscription<bool>? _subscription;

  FollowCubit({FollowRepository? followRepo})
      : _followRepo = followRepo ?? FollowRepository(),
        super(const FollowState());

  void init(String targetUserId) {
    _subscription?.cancel();
    if (targetUserId.isEmpty) return;
    _subscription = _followRepo.isFollowingStream(targetUserId).listen(
      (isFollowing) {
        if (!isClosed) {
          emit(state.copyWith(isFollowing: isFollowing, isToggling: false));
        }
      },
      onError: (error) {
        print('FollowCubit stream error: $error');
        if (!isClosed) {
          emit(state.copyWith(isToggling: false));
        }
      },
    );
  }

  Future<void> toggleFollow(String targetUserId) async {
    if (state.isToggling) return;

    final isCurrentlyFollowing = state.isFollowing;
    emit(state.copyWith(isToggling: true, errorMessage: null));

    try {
      if (isCurrentlyFollowing) {
        await _followRepo.unfollowUser(targetUserId);
      } else {
        await _followRepo.followUser(targetUserId);
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          isToggling: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
