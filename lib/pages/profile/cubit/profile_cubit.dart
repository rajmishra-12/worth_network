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
          
          // 2. Fetch user's published actions & validations performed for others
          final List<ActionModel> myActions = [];
          int validatedForOthersCount = 0;
          bool hasCertifiedAction = false;

          try {
            final actionsSnapshot = await FirebaseFirestore.instance
                .collection('actions')
                .where('userId', isEqualTo: currentUser.uid)
                .get();

            for (var doc in actionsSnapshot.docs) {
              final actionData = doc.data();
              ValidationStatus status = ValidationStatus.declared;
              final statusStr = actionData['validationStatus'] ?? 'declared';
              if (statusStr == 'confirmed') status = ValidationStatus.confirmed;
              if (statusStr == 'certified') {
                status = ValidationStatus.certified;
                hasCertifiedAction = true;
              }
              if (statusStr == 'rejected') status = ValidationStatus.rejected;

              myActions.add(ActionModel(
                id: doc.id,
                userId: currentUser.uid,
                userName: data['name'] ?? currentUser.displayName ?? 'User',
                userAvatar: data['avatarUrl'],
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

            // Fetch validations completed for others
            final validationsSnapshot = await FirebaseFirestore.instance
                .collection('actions')
                .where('validatorId', isEqualTo: currentUser.uid)
                .get();

            validatedForOthersCount = validationsSnapshot.docs.where((d) {
              final st = d.data()['validationStatus'];
              return st == 'confirmed' || st == 'certified' || st == 'rejected';
            }).length;

          } catch (e, stack) {
            print("Failed to fetch user actions or validations: $e");
            print(stack);
          }

          final userScore = data['score'] ?? 0;
          final userLevel = data['level'] ?? 1;
          final totalActionsCount = myActions.length;

          // 3. Dynamically evaluate all 8 badges
          final List<BadgeModel> dynamicBadges = [
            BadgeModel(
              name: 'First Action',
              description: 'Published your first real action on Worth Network',
              isEarned: totalActionsCount >= 1,
            ),
            BadgeModel(
              name: 'Rising Star',
              description: 'Earned 50+ Worth Score through validated actions',
              isEarned: userScore >= 50,
            ),
            BadgeModel(
              name: 'Trusted Validator',
              description: 'Evaluated and validated proof evidence for peer actions',
              isEarned: validatedForOthersCount >= 1,
            ),
            BadgeModel(
              name: 'Certified Impact',
              description: 'Achieved top-tier Certified status with strong evidence',
              isEarned: hasCertifiedAction,
            ),
            BadgeModel(
              name: 'Community Contributor',
              description: 'Successfully posted 5 or more real actions',
              isEarned: totalActionsCount >= 5,
            ),
            BadgeModel(
              name: 'Consistency Champion',
              description: 'Reached Level 2+ by consistently completing actions',
              isEarned: userLevel >= 2 || userScore >= 150,
            ),
            BadgeModel(
              name: 'Reputation Pioneer',
              description: 'Built a high credibility profile with 300+ Worth Score',
              isEarned: userScore >= 300 || userLevel >= 3,
            ),
            BadgeModel(
              name: 'Master Validator',
              description: 'Verified 5 or more proof submissions for community members',
              isEarned: validatedForOthersCount >= 5,
            ),
          ];

          final avatarUrlVal = data['avatarUrl'] as String?;
          final profile = ProfileModel(
            id: currentUser.uid,
            name: data['name'] ?? currentUser.displayName ?? 'User',
            avatarUrl: (avatarUrlVal != null && avatarUrlVal.isNotEmpty)
                ? avatarUrlVal
                : 'https://i.pravatar.cc/150?img=10',
            bio: data['bio'] ?? 'Building worth through real actions.',
            accountType: data['accountType'] as String?,
            roles: (data['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
            score: userScore,
            level: userLevel,
            xp: data['xp'] ?? 0,
            nextLevelXp: data['nextLevelXp'] ?? 100,
            totalActions: totalActionsCount,
            validatedPercentage: (data['validatedPercentage'] as num?)?.toDouble() ?? 0.0,
            badges: dynamicBadges,
          );


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