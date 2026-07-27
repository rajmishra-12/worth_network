// lib/pages/dashboard/home/cubit/home_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:worth_network/core/model/home/action_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> loadFeed() async {
    emit(state.copyWith(isLoading: true));
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    final mockActions = [
      ActionModel(
        id: '1',
        userId: 'user1',
        userName: 'Sarah Johnson',
        userAvatar: 'https://i.pravatar.cc/150?img=1',
        title: 'Helped elderly neighbor with groceries',
        description: 'Carried groceries up 3 flights of stairs and helped organize pantry.',
        category: 'Support',
        proofType: 'photo',
        proofUrl: 'https://picsum.photos/400/300?random=1',
        validationStatus: ValidationStatus.confirmed,
        score: 85,
        likesCount: 24,
        commentsCount: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      ActionModel(
        id: '2',
        userId: 'user2',
        userName: 'Michael Chen',
        userAvatar: 'https://i.pravatar.cc/150?img=2',
        title: 'Completed 10km charity run',
        description: 'Raised 500 for local animal shelter.',
        category: 'Health',
        proofType: 'photo',
        proofUrl: 'https://picsum.photos/400/300?random=2',
        validationStatus: ValidationStatus.certified,
        score: 92,
        likesCount: 42,
        commentsCount: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      ActionModel(
        id: '3',
        userId: 'user3',
        userName: 'Emma Watson',
        userAvatar: 'https://i.pravatar.cc/150?img=3',
        title: 'Mentored junior developer',
        description: 'Weekly code reviews and career guidance for 2 months.',
        category: 'Work',
        proofType: 'document',
        proofUrl: null,
        validationStatus: ValidationStatus.confirmed,
        score: 78,
        likesCount: 15,
        commentsCount: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    
    emit(state.copyWith(actions: mockActions, isLoading: false));
  }

  Future<void> likeAction(String actionId) async {
    // TODO: Implement like functionality
    final updatedActions = state.actions.map((action) {
      if (action.id == actionId) {
        return action.copyWith(
          likesCount: action.likesCount + 1,
          isLikedByUser: !action.isLikedByUser,
        );
      }
      return action;
    }).toList();
    emit(state.copyWith(actions: updatedActions));
  }

  void addNewAction({
  required String title,
  required String description,
  required String category,
}) {
  final newAction = ActionModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    userId: 'currentUser',
    userName: 'You',
    userAvatar: 'https://i.pravatar.cc/150?img=10',
    title: title,
    description: description,
    category: category,
    proofType: 'text',
    proofUrl: null,
    validationStatus: ValidationStatus.confirmed,
    score: 50,
    likesCount: 0,
    commentsCount: 0,
    createdAt: DateTime.now(),
  );

  final updatedList = [newAction, ...state.actions];

  emit(state.copyWith(actions: updatedList));
}
}