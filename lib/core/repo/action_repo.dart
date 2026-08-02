import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/utils/preferences.dart';



class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime createdDate = DateTime.now();
    if (map['createdAt'] is Timestamp) {
      createdDate = (map['createdAt'] as Timestamp).toDate();
    }
    return CommentModel(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      userAvatar: map['userAvatar'],
      text: map['text'] ?? '',
      createdAt: createdDate,
    );
  }
}

class ActionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Search users in Firestore by username or name
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final queryTrimmed = query.trim().toLowerCase();
    if (queryTrimmed.isEmpty) return [];

    try {
      final snapshot = await _firestore.collection('users').get();
      final List<Map<String, dynamic>> results = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final username = (data['username'] ?? '').toString().toLowerCase();
        final name = (data['name'] ?? '').toString().toLowerCase();
        final uid = doc.id;

        // Don't show current user in validator search
        if (uid == currentUserId) continue;

        if (username.contains(queryTrimmed) || name.contains(queryTrimmed)) {
          results.add({
            'uid': uid,
            'name': data['name'] ?? 'User',
            'username': data['username'] ?? '',
            'avatarUrl': data['avatarUrl'],
            'score': data['score'] ?? 0,
            'level': data['level'] ?? 1,
          });
        }
      }
      return results;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Upload proof media file to Firebase Storage
  Future<String?> uploadProofFile(File file, String actionId) async {
    try {
      final ext = file.path.split('.').last.toLowerCase();
      String contentType = 'image/jpeg';
      if (ext == 'png') contentType = 'image/png';
      if (ext == 'pdf') contentType = 'application/pdf';
      if (ext == 'm4a' || ext == 'mp3') contentType = 'audio/mp4';

      final fileName = '${actionId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final ref = _storage.ref().child('action_proofs').child(fileName);
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: contentType),
      );
      final url = await uploadTask.ref.getDownloadURL();
      print('Proof uploaded successfully: $url');
      return url;
    } catch (e, stack) {
      print('Error uploading proof file to Firebase Storage: $e');
      print(stack);
      return null;
    }
  }


  /// Publish action to Firestore and create notification for validator
  Future<ActionModel> publishAction({
    required String title,
    required String description,
    required String category,
    String? proofType,
    File? proofFile,
    String? textProof,
    Map<String, dynamic>? selectedValidator,
  }) async {
    final user = _auth.currentUser;
    final prefs = Preferences();
    final uid = user?.uid ?? prefs.userId;

    if (uid.isEmpty) throw Exception('User not authenticated. Please sign in.');

    String userName = user?.displayName ?? prefs.name;
    if (userName.isEmpty) userName = 'User';
    String? userAvatar;

    try {
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() ?? {};
          userName = userData['name'] ?? userName;
          userAvatar = userData['avatarUrl'];
        }
      }
    } catch (e) {
      print('User details fetch warning: $e');
    }

    final docRef = _firestore.collection('actions').doc();
    final actionId = docRef.id;

    String? proofUrl;
    if (proofFile != null) {
      proofUrl = await uploadProofFile(proofFile, actionId);
    }

    final hasValidator = selectedValidator != null && selectedValidator['uid'] != null;

    final actionData = <String, dynamic>{
      'id': actionId,
      'userId': uid,
      'userName': userName,
      'userAvatar': userAvatar,
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'proofType': proofType,
      'proofUrl': proofUrl,
      'textProof': textProof,
      'validationStatus': hasValidator ? 'pending' : 'declared',
      'validatorId': selectedValidator?['uid'],
      'validatorUsername': selectedValidator?['username'],
      'validatorName': selectedValidator?['name'],
      'validatorAvatar': selectedValidator?['avatarUrl'],
      'score': 50,
      'likesCount': 0,
      'commentsCount': 0,
      'likedBy': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await docRef.set(actionData);
    } catch (e) {
      print('Primary action write warning: $e');
      // If serverTimestamp or strict type triggers permission error, try fallback write
      actionData['createdAt'] = DateTime.now().toIso8601String();
      await docRef.set(actionData);
    }

    // Send notification/request to validator if chosen
    if (hasValidator) {
      final validatorId = selectedValidator['uid'];
      try {
        await _firestore.collection('notifications').add({
          'type': 'validation_request',
          'actionId': actionId,
          'targetUserId': validatorId,
          'requesterId': uid,
          'requesterName': userName,
          'title': title,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      } catch (e) {
        print('Notification write warning: $e');
      }
    }

    return ActionModel.fromMap(actionData, actionId, currentUserId: uid);
  }



  /// Real-time stream of all public actions for Home Feed
  Stream<List<ActionModel>> getFeedStream() {
    return _firestore
        .collection('actions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ActionModel.fromMap(doc.data(), doc.id, currentUserId: currentUserId);
      }).toList();
    });
  }

  /// Delete action document from Firestore if caller is owner
  Future<void> deleteAction(String actionId) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    final docRef = _firestore.collection('actions').doc(actionId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    if (data['userId'] != uid) {
      throw Exception('Only the post owner can delete this action.');
    }

    await docRef.delete();
  }

  /// Real-time stream of a single action document

  Stream<ActionModel?> getActionStream(String actionId) {
    return _firestore
        .collection('actions')
        .doc(actionId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return ActionModel.fromMap(snapshot.data()!, snapshot.id, currentUserId: currentUserId);
    });
  }

  /// Real-time stream of actions where current user is validator
  Stream<List<ActionModel>> getPendingValidationsStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('actions')
        .where('validatorId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ActionModel.fromMap(doc.data(), doc.id, currentUserId: uid))
          .where((action) => action.validationStatus == ValidationStatus.pending)
          .toList();
    });
  }

  /// Real-time stream of notifications for the logged in user
  Stream<List<Map<String, dynamic>>> getUserNotificationsStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();

    return _firestore.collection('actions').snapshots().asyncMap((snapshot) async {
      final List<Map<String, dynamic>> notifications = [];

      // Fetch user profile stats for Level Up and Badge Unlocked notifications
      int userLevel = 1;
      int userScore = 0;
      try {
        final userDoc = await _firestore.collection('users').doc(uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() ?? {};
          userLevel = userData['level'] ?? 1;
          userScore = userData['score'] ?? 0;
        }
      } catch (e) {
        print('User profile fetch warning for notifications: $e');
      }

      // 1. Dynamic Level Up Notification
      if (userLevel > 1) {
        notifications.add({
          'id': 'level_up_$userLevel',
          'type': 'level_up',
          'title': 'Level Up!',
          'description': 'You have advanced to Level $userLevel. Keep building your reputation!',
          'time': 'Level $userLevel',
          'createdAt': DateTime.now().subtract(const Duration(minutes: 5)),
        });
      }

      // 2. Dynamic Badge Unlocked Notifications
      if (userScore >= 50) {
        notifications.add({
          'id': 'badge_early_contributor',
          'type': 'badge_unlocked',
          'title': 'Badge Unlocked',
          'description': 'Congratulations! You unlocked the "Early Contributor" badge.',
          'time': 'Unlocked',
          'createdAt': DateTime.now().subtract(const Duration(minutes: 10)),
        });
      }
      if (userScore >= 150) {
        notifications.add({
          'id': 'badge_reputation_pioneer',
          'type': 'badge_unlocked',
          'title': 'Badge Unlocked',
          'description': 'Congratulations! You unlocked the "Reputation Pioneer" badge.',
          'time': 'Unlocked',
          'createdAt': DateTime.now().subtract(const Duration(minutes: 15)),
        });
      }

      // 3. Dynamic Action Notifications (Validator vs Publisher roles)
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final action = ActionModel.fromMap(data, doc.id, currentUserId: uid);

        // ROLE A: VALIDATOR (User assigned to validate)
        if (action.validatorId == uid) {
          if (action.validationStatus == ValidationStatus.pending) {
            notifications.add({
              'id': 'val_req_${action.id}',
              'type': 'validation_requested',
              'title': 'Validation Request',
              'description': '${action.userName} requested validation for "${action.title}"',
              'time': 'Action Needed',
              'createdAt': action.createdAt,
              'action': action,
            });
          } else {
            // Validator completed validation history
            final isCert = action.validationStatus == ValidationStatus.certified;
            final isRej = action.validationStatus == ValidationStatus.rejected;
            final statusStr = isRej ? 'rejected' : (isCert ? 'certified' : 'confirmed');
            notifications.add({
              'id': 'val_done_${action.id}',
              'type': isRej ? 'rejected' : 'approved',
              'title': 'Validation Completed',
              'description': 'You $statusStr "${action.title}" for ${action.userName} (+10 Worth Score reward)',
              'time': 'Validated',
              'createdAt': action.createdAt,
              'action': action,
            });
          }
        }

        // ROLE B: PUBLISHER (User who posted the action)
        if (action.userId == uid) {
          if (action.validationStatus == ValidationStatus.confirmed ||
              action.validationStatus == ValidationStatus.certified) {
            final isCert = action.validationStatus == ValidationStatus.certified;
            final scoreReward = isCert ? 100 : 50;
            final validatorName = action.validatorName ?? 'Validator';
            notifications.add({
              'id': 'approved_${action.id}',
              'type': 'approved',
              'title': isCert ? 'Action Certified!' : 'Action Confirmed!',
              'description': 'Your action "${action.title}" has been confirmed by $validatorName (+$scoreReward Worth Score)',
              'time': 'Confirmed',
              'createdAt': action.createdAt,
              'action': action,
            });
          } else if (action.validationStatus == ValidationStatus.rejected) {
            notifications.add({
              'id': 'rejected_${action.id}',
              'type': 'rejected',
              'title': 'Validation Rejected',
              'description': 'Your action "${action.title}" was marked as rejected by validator.',
              'time': 'Rejected',
              'createdAt': action.createdAt,
              'action': action,
            });
          }
        }
      }

      notifications.sort((a, b) {
        final dateA = a['createdAt'] as DateTime? ?? DateTime.now();
        final dateB = b['createdAt'] as DateTime? ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      return notifications;
    });
  }



  /// Toggle like status for an action atomically
  Future<void> toggleLike(String actionId, {bool? isCurrentlyLiked}) async {
    final uid = currentUserId;
    if (uid == null) return;

    final docRef = _firestore.collection('actions').doc(actionId);

    // If preference is passed, update directly without extra fetch
    if (isCurrentlyLiked != null) {
      if (isCurrentlyLiked) {
        await docRef.update({
          'likedBy': FieldValue.arrayRemove([uid]),
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        await docRef.update({
          'likedBy': FieldValue.arrayUnion([uid]),
          'likesCount': FieldValue.increment(1),
        });
      }
      return;
    }

    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final List<dynamic> likedBy = List.from(data['likedBy'] ?? []);
    final isLiked = likedBy.contains(uid);

    if (isLiked) {
      await docRef.update({
        'likedBy': FieldValue.arrayRemove([uid]),
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await docRef.update({
        'likedBy': FieldValue.arrayUnion([uid]),
        'likesCount': FieldValue.increment(1),
      });
    }
  }


  /// Add comment to action subcollection & increment comment counter
  Future<void> addComment(String actionId, String commentText) async {
    final user = _auth.currentUser;
    if (user == null || commentText.trim().isEmpty) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};
    final userName = userData['name'] ?? user.displayName ?? 'User';
    final userAvatar = userData['avatarUrl'];

    final actionRef = _firestore.collection('actions').doc(actionId);
    final commentRef = actionRef.collection('comments').doc();

    await commentRef.set({
      'userId': user.uid,
      'userName': userName,
      'userAvatar': userAvatar,
      'text': commentText.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await actionRef.update({
      'commentsCount': FieldValue.increment(1),
    });
  }

  /// Stream of comments for an action
  Stream<List<CommentModel>> getCommentsStream(String actionId) {
    return _firestore
        .collection('actions')
        .doc(actionId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CommentModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Submit validation response by validator & update reputation score
  Future<void> submitValidation({
    required String actionId,
    required String decision, // 'confirmed', 'certified', 'rejected'
    required double confidence,
    required String comment,
  }) async {
    final validatorId = currentUserId;
    if (validatorId == null) throw Exception('Not authenticated');

    final actionRef = _firestore.collection('actions').doc(actionId);
    final actionDoc = await actionRef.get();
    if (!actionDoc.exists) throw Exception('Action not found');

    final actionData = actionDoc.data()!;
    final publisherId = actionData['userId'] as String;

    // Update action status
    await actionRef.update({
      'validationStatus': decision,
      'validationComment': comment.trim(),
      'confidenceScore': confidence,
      'validatedAt': FieldValue.serverTimestamp(),
    });

    // Evolution of Reputation & Stats
    if (decision == 'confirmed' || decision == 'certified') {
      final rewardScore = decision == 'certified' ? 100 : 50;

      // 1. Update Publisher Profile
      try {
        final publisherRef = _firestore.collection('users').doc(publisherId);
        await _firestore.runTransaction((transaction) async {
          final pubSnap = await transaction.get(publisherRef);
          if (pubSnap.exists) {
            final pData = pubSnap.data()!;
            final currentScore = (pData['score'] ?? 0) as int;
            final currentXp = (pData['xp'] ?? 0) as int;
            final currentTotalActions = (pData['totalActions'] ?? 0) as int;

            final newScore = currentScore + rewardScore;
            final newXp = currentXp + rewardScore;
            final newLevel = (newXp / 100).floor() + 1;
            final newTotalActions = currentTotalActions + 1;

            final userActionsSnap = await _firestore
                .collection('actions')
                .where('userId', isEqualTo: publisherId)
                .get();

            int validatedCount = 0;
            for (var doc in userActionsSnap.docs) {
              final st = doc.data()['validationStatus'];
              if (st == 'confirmed' || st == 'certified') {
                validatedCount++;
              }
            }
            final percentage = (validatedCount / (userActionsSnap.docs.length.clamp(1, 999999))) * 100;

            transaction.update(publisherRef, {
              'score': newScore,
              'xp': newXp,
              'level': newLevel,
              'totalActions': newTotalActions,
              'validatedPercentage': percentage.clamp(0.0, 100.0),
            });
          }
        });
      } catch (e) {
        print('Publisher profile update error: $e');
      }

      // 2. Reward Validator Profile (10 XP reward for validating)
      try {
        final validatorRef = _firestore.collection('users').doc(validatorId);
        await _firestore.runTransaction((transaction) async {
          final valSnap = await transaction.get(validatorRef);
          if (valSnap.exists) {
            final vData = valSnap.data()!;
            final currentScore = (vData['score'] ?? 0) as int;
            final currentXp = (vData['xp'] ?? 0) as int;

            final newScore = currentScore + 10;
            final newXp = currentXp + 10;
            final newLevel = (newXp / 100).floor() + 1;

            transaction.update(validatorRef, {
              'score': newScore,
              'xp': newXp,
              'level': newLevel,
            });
          }
        });
      } catch (e) {
        print('Validator profile update error: $e');
      }
    }
  }
}

