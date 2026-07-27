import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/model/profile/history_model.dart';
import 'package:worth_network/core/model/profile/profile_model.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/utils/preferences.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true));

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // 1. Fetch user profile from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          
          // Map badges from Firestore list
          final List<BadgeModel> badgesList = [];
          if (data['badges'] != null) {
            final list = data['badges'] as List;
            for (var b in list) {
              if (b is Map) {
                badgesList.add(BadgeModel(
                  name: b['name'] ?? '',
                  description: b['description'] ?? '',
                  isEarned: b['isEarned'] ?? false,
                ));
              }
            }
          }

          // Fallback to defaults if badges are empty
          if (badgesList.isEmpty) {
            badgesList.addAll([
              const BadgeModel(name: 'First Action', description: 'Completed first action', isEarned: true),
              const BadgeModel(name: '5 Actions', description: 'Completed 5 actions', isEarned: false),
              const BadgeModel(name: 'Consistency', description: '7-day streak', isEarned: false),
            ]);
          }

          final avatarUrlVal = data['avatarUrl'] as String?;
          final profile = ProfileModel(
            id: currentUser.uid,
            name: data['name'] ?? currentUser.displayName ?? 'User',
            avatarUrl: (avatarUrlVal != null && avatarUrlVal.isNotEmpty)
                ? avatarUrlVal
                : 'https://i.pravatar.cc/150?img=10',
            bio: data['bio'] ?? 'Building worth through real actions.',
            score: data['score'] ?? 0,
            level: data['level'] ?? 1,
            xp: data['xp'] ?? 0,
            nextLevelXp: data['nextLevelXp'] ?? 100,
            totalActions: data['totalActions'] ?? 0,
            validatedPercentage: (data['validatedPercentage'] as num?)?.toDouble() ?? 0.0,
            badges: badgesList,
          );

          // 2. Fetch user's actions from Firestore
          final List<ActionModel> myActions = [];
          try {
            final actionsSnapshot = await FirebaseFirestore.instance
                .collection('actions')
                .where('userId', isEqualTo: currentUser.uid)
                .get();

            for (var doc in actionsSnapshot.docs) {
              final actionData = doc.data();
              // Parse ValidationStatus
              ValidationStatus status = ValidationStatus.declared;
              final statusStr = actionData['validationStatus'] ?? 'declared';
              if (statusStr == 'confirmed') status = ValidationStatus.confirmed;
              if (statusStr == 'certified') status = ValidationStatus.certified;

              myActions.add(ActionModel(
                id: doc.id,
                userId: currentUser.uid,
                userName: profile.name,
                title: actionData['title'] ?? '',
                description: actionData['description'] ?? '',
                category: actionData['category'] ?? 'Support',
                validationStatus: status,
                score: actionData['score'] ?? 0,
                likesCount: actionData['likesCount'] ?? 0,
                commentsCount: actionData['commentsCount'] ?? 0,
                createdAt: (actionData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                isLikedByUser: false,
              ));
            }
          } catch (e, stack) {
            print("Failed to fetch user actions: $e");
            print(stack);
          }

          // Fallback to default action if list is empty
          if (myActions.isEmpty) {
            myActions.add(ActionModel(
              id: 'first_action_id',
              userId: currentUser.uid,
              userName: profile.name,
              title: 'Joined Worth Network',
              description: 'Created account and started credibility building!',
              category: 'General',
              validationStatus: ValidationStatus.certified,
              score: 10,
              likesCount: 1,
              commentsCount: 0,
              createdAt: DateTime.now(),
              isLikedByUser: false,
            ));
          }

          // 3. Populate action history matching actions status
          final List<HistoryItem> actionHistory = [];
          for (var action in myActions) {
            Color statusColor = AppColors.info;
            String statusText = 'Declared';
            if (action.validationStatus == ValidationStatus.confirmed) {
              statusColor = AppColors.warning;
              statusText = 'Confirmed';
            } else if (action.validationStatus == ValidationStatus.certified) {
              statusColor = AppColors.success;
              statusText = 'Certified';
            }

            actionHistory.add(HistoryItem(
              id: action.id,
              title: action.title,
              status: statusText,
              statusColor: statusColor,
              date: action.createdAt,
              points: action.score,
            ));
          }

          // 4. Update Shared Preferences locally to persist cached user data
          final prefs = Preferences();
          prefs.name = profile.name;
          prefs.username = data['username'] ?? '';

          emit(state.copyWith(
            isLoading: false,
            profile: profile,
            myActions: myActions,
            actionHistory: actionHistory,
          ));
          return;
        }
      }
    } catch (e, stack) {
      print("Profile loading failed error: $e");
      print(stack);
      // Fallback below
    }

    // Fallback if user document doesn't exist or loading fails
    final prefs = Preferences();
    final profile = ProfileModel(
      id: prefs.userId.isNotEmpty ? prefs.userId : '1',
      name: prefs.name.isNotEmpty ? prefs.name : 'Guest User',
      avatarUrl: 'https://i.pravatar.cc/150?img=10',
      bio: 'Building worth through real actions.',
      score: 0,
      level: 1,
      xp: 0,
      nextLevelXp: 100,
      totalActions: 0,
      validatedPercentage: 0.0,
      badges: const [
        BadgeModel(name: 'First Action', description: 'Completed first action', isEarned: true),
      ],
    );

    emit(state.copyWith(
      isLoading: false,
      profile: profile,
      myActions: const [],
      actionHistory: const [],
    ));
  }
}