import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/model/home/evidence_model.dart';
import 'package:worth_network/core/utils/preferences.dart';
import 'package:worth_network/core/services/notification_service.dart';
import 'package:worth_network/core/services/moderation_text_service.dart';
import 'package:worth_network/core/repo/moderation_repo.dart';

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String text;
  final DateTime createdAt;
  final String moderationStatus;
  final String? moderatedBy;
  final DateTime? moderatedAt;
  final String? moderationReason;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.text,
    required this.createdAt,
    this.moderationStatus = 'visible',
    this.moderatedBy,
    this.moderatedAt,
    this.moderationReason,
  });

  bool get isVisible => moderationStatus == 'visible';

  factory CommentModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime createdDate = DateTime.now();
    if (map['createdAt'] is Timestamp) {
      createdDate = (map['createdAt'] as Timestamp).toDate();
    }
    DateTime? modDate;
    if (map['moderatedAt'] is Timestamp) {
      modDate = (map['moderatedAt'] as Timestamp).toDate();
    }
    return CommentModel(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      userAvatar: map['userAvatar'],
      text: map['text'] ?? '',
      createdAt: createdDate,
      moderationStatus: map['moderationStatus'] ?? 'visible',
      moderatedBy: map['moderatedBy'],
      moderatedAt: modDate,
      moderationReason: map['moderationReason'],
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
    List<EvidenceModel>? evidences,
    Map<String, dynamic>? selectedValidator,
  }) async {
    final user = _auth.currentUser;
    final prefs = Preferences();
    final uid = user?.uid ?? prefs.userId;

    if (uid.isEmpty) throw Exception('User not authenticated. Please sign in.');

    // Abusive text check
    final textService = ModerationTextService();
    final titleError = await textService.checkText(title);
    if (titleError != null) throw Exception(titleError);

    final descError = await textService.checkText(description);
    if (descError != null) throw Exception(descError);

    if (textProof != null && textProof.isNotEmpty) {
      final proofError = await textService.checkText(textProof);
      if (proofError != null) throw Exception(proofError);
    }

    String userName = user?.displayName ?? prefs.name;
    if (userName.isEmpty) userName = 'User';
    String? userAvatar;

    try {
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() ?? {};
          final accountStatus = userData['accountStatus'] as String? ?? 'active';
          if (accountStatus == 'suspended' || accountStatus == 'blocked') {
            final reason = userData['suspensionReason'] as String?;
            final reasonMsg = reason != null && reason.isNotEmpty ? ' Reason: $reason' : '';
            throw Exception('Your account is $accountStatus by an administrator and cannot publish actions.$reasonMsg');
          }
          userName = userData['name'] ?? userName;
          userAvatar = userData['avatarUrl'];
        }
      }
    } catch (e) {
      if (e.toString().contains('cannot publish actions')) rethrow;
      print('User details fetch warning: $e');
    }

    final docRef = _firestore.collection('actions').doc();
    final actionId = docRef.id;

    // Process multi-evidence list if provided
    final List<EvidenceModel> processedEvidences = [];
    if (evidences != null && evidences.isNotEmpty) {
      for (final item in evidences) {
        if (item.localFile != null) {
          final uploadedUrl = await uploadProofFile(item.localFile!, actionId);
          processedEvidences.add(item.copyWith(url: uploadedUrl));
        } else {
          processedEvidences.add(item);
        }
      }
    } else {
      // Legacy single proof fallback
      String? proofUrl;
      if (proofFile != null) {
        proofUrl = await uploadProofFile(proofFile, actionId);
      }
      if (proofType != null || proofUrl != null || (textProof != null && textProof.isNotEmpty)) {
        processedEvidences.add(EvidenceModel(
          type: proofType ?? 'text',
          url: proofUrl,
          text: textProof,
        ));
      }
    }

    final hasValidator = selectedValidator != null && selectedValidator['uid'] != null;
    final firstEvidence = processedEvidences.isNotEmpty ? processedEvidences.first : null;

    final actionData = <String, dynamic>{
      'id': actionId,
      'userId': uid,
      'userName': userName,
      'userAvatar': userAvatar,
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'proofType': firstEvidence?.type ?? proofType,
      'proofUrl': firstEvidence?.url ?? proofFile?.path,
      'textProof': firstEvidence?.text ?? textProof,
      'evidences': processedEvidences.map((e) => e.toMap()).toList(),
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
        await NotificationService().sendNotification(
          targetUserId: validatorId,
          title: 'Validation Request',
          body: '$userName requested validation for "$title"',
          type: 'validation_request',
          actionId: actionId,
          extraData: {
            'requesterName': userName,
            'actionTitle': title,
          },
        );
      } catch (e) {
        print('Notification dispatch warning: $e');
      }
    }

    return ActionModel.fromMap(actionData, actionId, currentUserId: uid);
  }



  /// Real-time discovery stream for For You feed (all eligible community actions, chronological order)
  Stream<List<ActionModel>> getForYouFeedStream() {
    return getFeedStream().map((actions) {
      // Deduplicate actions by ID while preserving chronological ordering
      final Set<String> seenIds = {};
      final List<ActionModel> dedupedActions = [];

      for (final action in actions) {
        if (!seenIds.contains(action.id)) {
          seenIds.add(action.id);
          dedupedActions.add(action);
        }
      }

      return dedupedActions;
    });
  }

  /// Paginated fetch for For You feed (10 items per page)
  Future<Map<String, dynamic>> getForYouFeedPage({
    int limit = 10,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      Query query = _firestore
          .collection('actions')
          .orderBy('createdAt', descending: true);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snap = await query.limit(limit).get();
      if (snap.docs.isEmpty) {
        return {
          'actions': <ActionModel>[],
          'lastDoc': null,
          'hasMore': false,
        };
      }

      final uids = snap.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['userId'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet();

      final Map<String, Map<String, dynamic>> userProfiles = {};
      for (final uid in uids) {
        try {
          final userDoc = await _firestore.collection('users').doc(uid).get();
          if (userDoc.exists && userDoc.data() != null) {
            userProfiles[uid] = userDoc.data()!;
          }
        } catch (_) {}
      }

      final blockedUserIds = await ModerationRepository().getBlockedUserIds();
      final reportedContentIds = await ModerationRepository().getReportedContentIds();

      final actions = snap.docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
            final uid = data['userId'] as String?;
            final userProfile = uid != null ? userProfiles[uid] : null;

            if (userProfile != null) {
              final liveAvatar = userProfile['avatarUrl'] as String?;
              final liveName = userProfile['name'] as String?;
              if (liveAvatar != null && liveAvatar.isNotEmpty) data['userAvatar'] = liveAvatar;
              if (liveName != null && liveName.isNotEmpty) data['userName'] = liveName;
            }

            return ActionModel.fromMap(data, doc.id, currentUserId: currentUserId);
          })
          .where((action) {
            final authorProfile = userProfiles[action.userId];
            final accStatus = (authorProfile?['accountStatus'] as String?) ?? 'active';
            final isSuspendedOrBlocked = accStatus == 'suspended' || accStatus == 'blocked';
            final isReportedByMe = reportedContentIds.contains(action.id);
            final isAuthorBlockedByMe = blockedUserIds.contains(action.userId);

            return action.isVisible && !isSuspendedOrBlocked && !isReportedByMe && !isAuthorBlockedByMe;
          })
          .toList();

      return {
        'actions': actions,
        'lastDoc': snap.docs.last,
        'hasMore': snap.docs.length >= limit,
      };
    } catch (e) {
      print('Error getting For You feed page: $e');
      rethrow;
    }
  }

  /// Paginated fetch for Following feed (10 items per page)
  Future<Map<String, dynamic>> getFollowingFeedPage({
    int limit = 10,
    DocumentSnapshot? lastDoc,
  }) async {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) {
      return {
        'actions': <ActionModel>[],
        'lastDoc': null,
        'hasMore': false,
        'isFollowingNobody': true,
      };
    }

    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        return {
          'actions': <ActionModel>[],
          'lastDoc': null,
          'hasMore': false,
          'isFollowingNobody': true,
        };
      }

      final followingIds = (userDoc.data()?['following'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((id) => id.isNotEmpty)
              .toList() ??
          [];

      if (followingIds.isEmpty) {
        return {
          'actions': <ActionModel>[],
          'lastDoc': null,
          'hasMore': false,
          'isFollowingNobody': true,
        };
      }

      Query query = _firestore
          .collection('actions')
          .orderBy('createdAt', descending: true);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snap = await query.limit(limit * 3).get();
      if (snap.docs.isEmpty) {
        return {
          'actions': <ActionModel>[],
          'lastDoc': null,
          'hasMore': false,
          'isFollowingNobody': false,
        };
      }

      final filteredDocs = snap.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final authorId = data['userId'] as String?;
        return authorId != null && followingIds.contains(authorId);
      }).take(limit).toList();

      if (filteredDocs.isEmpty) {
        return {
          'actions': <ActionModel>[],
          'lastDoc': snap.docs.last,
          'hasMore': snap.docs.length >= (limit * 3),
          'isFollowingNobody': false,
        };
      }

      final authorIds = filteredDocs
          .map((doc) => (doc.data() as Map<String, dynamic>)['userId'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet();

      final Map<String, Map<String, dynamic>> userProfiles = {};
      for (final authorId in authorIds) {
        try {
          final uDoc = await _firestore.collection('users').doc(authorId).get();
          if (uDoc.exists && uDoc.data() != null) {
            userProfiles[authorId] = uDoc.data()!;
          }
        } catch (_) {}
      }

      final blockedUserIds = await ModerationRepository().getBlockedUserIds();
      final reportedContentIds = await ModerationRepository().getReportedContentIds();

      final actions = filteredDocs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
        final authorId = data['userId'] as String?;
        final uProfile = authorId != null ? userProfiles[authorId] : null;

        if (uProfile != null) {
          final liveAvatar = uProfile['avatarUrl'] as String?;
          final liveName = uProfile['name'] as String?;
          if (liveAvatar != null && liveAvatar.isNotEmpty) data['userAvatar'] = liveAvatar;
          if (liveName != null && liveName.isNotEmpty) data['userName'] = liveName;
        }

        return ActionModel.fromMap(data, doc.id, currentUserId: uid);
      }).where((action) {
        final authorProfile = userProfiles[action.userId];
        final accStatus = (authorProfile?['accountStatus'] as String?) ?? 'active';
        final isSuspendedOrBlocked = accStatus == 'suspended' || accStatus == 'blocked';
        final isReportedByMe = reportedContentIds.contains(action.id);
        final isAuthorBlockedByMe = blockedUserIds.contains(action.userId);

        return action.isVisible && !isSuspendedOrBlocked && !isReportedByMe && !isAuthorBlockedByMe;
      }).toList();

      return {
        'actions': actions,
        'lastDoc': filteredDocs.last,
        'hasMore': snap.docs.length >= (limit * 3),
        'isFollowingNobody': false,
      };
    } catch (e) {
      print('Error getting Following feed page: $e');
      rethrow;
    }
  }

  /// Real-time stream of all public actions for Home Feed with dynamic live user profile data
  Stream<List<ActionModel>> getFeedStream() {
    return _firestore
        .collection('actions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      // 1. Collect unique author IDs from actions
      final uids = snapshot.docs
          .map((doc) => doc.data()['userId'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet();

      // 2. Fetch live user profile docs from 'users' collection
      final Map<String, Map<String, dynamic>> userProfiles = {};
      for (final uid in uids) {
        try {
          final userDoc = await _firestore.collection('users').doc(uid).get();
          if (userDoc.exists && userDoc.data() != null) {
            userProfiles[uid] = userDoc.data()!;
          }
        } catch (e) {
          print('Warning: Failed to fetch user profile for $uid in feed stream: $e');
        }
      }

      final blockedUserIds = await ModerationRepository().getBlockedUserIds();
      final reportedContentIds = await ModerationRepository().getReportedContentIds();

      // 3. Construct actions with live user avatar & name
      return snapshot.docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            final uid = data['userId'] as String?;
            final userProfile = uid != null ? userProfiles[uid] : null;

            if (userProfile != null) {
              final liveAvatar = userProfile['avatarUrl'] as String?;
              final liveName = userProfile['name'] as String?;
              if (liveAvatar != null && liveAvatar.isNotEmpty) {
                data['userAvatar'] = liveAvatar;
              }
              if (liveName != null && liveName.isNotEmpty) {
                data['userName'] = liveName;
              }
            }

            return ActionModel.fromMap(data, doc.id, currentUserId: currentUserId);
          })
          .where((action) {
            final authorProfile = userProfiles[action.userId];
            final accStatus = (authorProfile?['accountStatus'] as String?) ?? 'active';
            final isSuspendedOrBlocked = accStatus == 'suspended' || accStatus == 'blocked';
            final isReportedByMe = reportedContentIds.contains(action.id);
            final isAuthorBlockedByMe = blockedUserIds.contains(action.userId);

            return action.isVisible && !isSuspendedOrBlocked && !isReportedByMe && !isAuthorBlockedByMe;
          })
          .toList();
    });
  }

  /// Real-time stream of actions from followed users only with dynamic live profile updates
  Stream<List<ActionModel>> getFollowingFeedStream() {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .asyncExpand((userSnap) {
      if (!userSnap.exists) return Stream.value(<ActionModel>[]);

      final followingIds = (userSnap.data()?['following'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((id) => id.isNotEmpty)
              .toList() ??
          [];

      if (followingIds.isEmpty) {
        return Stream.value(<ActionModel>[]);
      }

      return _firestore
          .collection('actions')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .asyncMap((actionsSnap) async {
        final filteredDocs = actionsSnap.docs.where((doc) {
          final authorId = doc.data()['userId'] as String?;
          return authorId != null && followingIds.contains(authorId);
        }).toList();

        if (filteredDocs.isEmpty) return <ActionModel>[];

        final authorIds = filteredDocs
            .map((doc) => doc.data()['userId'] as String?)
            .where((id) => id != null && id.isNotEmpty)
            .cast<String>()
            .toSet();

        final Map<String, Map<String, dynamic>> userProfiles = {};
        for (final authorId in authorIds) {
          try {
            final uDoc = await _firestore.collection('users').doc(authorId).get();
            if (uDoc.exists && uDoc.data() != null) {
              userProfiles[authorId] = uDoc.data()!;
            }
          } catch (e) {
            print('Warning: Failed to fetch user profile for $authorId: $e');
          }
        }

        final blockedUserIds = await ModerationRepository().getBlockedUserIds();
        final reportedContentIds = await ModerationRepository().getReportedContentIds();

        return filteredDocs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          final authorId = data['userId'] as String?;
          final uProfile = authorId != null ? userProfiles[authorId] : null;

          if (uProfile != null) {
            final liveAvatar = uProfile['avatarUrl'] as String?;
            final liveName = uProfile['name'] as String?;
            if (liveAvatar != null && liveAvatar.isNotEmpty) data['userAvatar'] = liveAvatar;
            if (liveName != null && liveName.isNotEmpty) data['userName'] = liveName;
          }

          return ActionModel.fromMap(data, doc.id, currentUserId: uid);
        }).where((action) {
          final authorProfile = userProfiles[action.userId];
          final accStatus = (authorProfile?['accountStatus'] as String?) ?? 'active';
          final isSuspendedOrBlocked = accStatus == 'suspended' || accStatus == 'blocked';
          final isReportedByMe = reportedContentIds.contains(action.id);
          final isAuthorBlockedByMe = blockedUserIds.contains(action.userId);

          return action.isVisible && !isSuspendedOrBlocked && !isReportedByMe && !isAuthorBlockedByMe;
        }).toList();
      });
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

  /// Real-time stream of a single action document with live user profile data
  Stream<ActionModel?> getActionStream(String actionId) {
    return _firestore
        .collection('actions')
        .doc(actionId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (!snapshot.exists || snapshot.data() == null) return null;
      final data = Map<String, dynamic>.from(snapshot.data()!);
      final uid = data['userId'] as String?;

      if (uid != null && uid.isNotEmpty) {
        try {
          final userDoc = await _firestore.collection('users').doc(uid).get();
          if (userDoc.exists && userDoc.data() != null) {
            final uData = userDoc.data()!;
            final liveAvatar = uData['avatarUrl'] as String?;
            final liveName = uData['name'] as String?;
            if (liveAvatar != null && liveAvatar.isNotEmpty) data['userAvatar'] = liveAvatar;
            if (liveName != null && liveName.isNotEmpty) data['userName'] = liveName;
          }
        } catch (e) {
          print('Warning: Failed to fetch user profile for action details stream: $e');
        }
      }

      return ActionModel.fromMap(data, snapshot.id, currentUserId: currentUserId);
    });
  }

  /// Real-time stream of actions where current user is validator with live user profile data
  Stream<List<ActionModel>> getPendingValidationsStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('actions')
        .where('validatorId', isEqualTo: uid)
        .snapshots()
        .asyncMap((snapshot) async {
      final uids = snapshot.docs
          .map((doc) => doc.data()['userId'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet();

      final Map<String, Map<String, dynamic>> userProfiles = {};
      for (final id in uids) {
        try {
          final uDoc = await _firestore.collection('users').doc(id).get();
          if (uDoc.exists && uDoc.data() != null) {
            userProfiles[id] = uDoc.data()!;
          }
        } catch (_) {}
      }

      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        final publisherId = data['userId'] as String?;
        final uProfile = publisherId != null ? userProfiles[publisherId] : null;

        if (uProfile != null) {
          final liveAvatar = uProfile['avatarUrl'] as String?;
          final liveName = uProfile['name'] as String?;
          if (liveAvatar != null && liveAvatar.isNotEmpty) data['userAvatar'] = liveAvatar;
          if (liveName != null && liveName.isNotEmpty) data['userName'] = liveName;
        }

        return ActionModel.fromMap(data, doc.id, currentUserId: uid);
      }).where((action) => action.validationStatus == ValidationStatus.pending).toList();
    });
  }

  /// Real-time stream of notifications for the logged in user
  Stream<List<Map<String, dynamic>>> getUserNotificationsStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('notifications')
        .where('targetUserId', isEqualTo: uid)
        .snapshots()
        .asyncMap((notifSnap) async {
      final List<Map<String, dynamic>> notifications = [];
      final Set<String> seenIds = {};

      for (var doc in notifSnap.docs) {
        final data = doc.data();
        final id = doc.id;
        seenIds.add(id);

        DateTime createdAt = DateTime.now();
        if (data['createdAt'] is Timestamp) {
          createdAt = (data['createdAt'] as Timestamp).toDate();
        }

        ActionModel? action;
        final actionId = data['actionId'] as String?;
        if (actionId != null && actionId.isNotEmpty) {
          seenIds.add('val_req_$actionId');
          seenIds.add('approved_$actionId');
          seenIds.add('rejected_$actionId');
          try {
            final actionDoc = await _firestore.collection('actions').doc(actionId).get();
            if (actionDoc.exists && actionDoc.data() != null) {
              action = ActionModel.fromMap(actionDoc.data()!, actionDoc.id, currentUserId: uid);
            }
          } catch (e) {
            print('Action fetch warning for notification: $e');
          }
        }

        String type = data['type'] ?? 'info';
        String title = data['title'] ?? 'Notification';
        String description = data['description'] ?? data['body'] ?? '';

        // If this was a validation request but action is already validated/confirmed/rejected
        if ((type == 'validation_request' || type == 'validation_requested') && action != null) {
          if (action.validationStatus == ValidationStatus.confirmed ||
              action.validationStatus == ValidationStatus.certified) {
            type = 'approved';
            title = 'Validation Completed';
            description = 'You confirmed "${action.title}"';
          } else if (action.validationStatus == ValidationStatus.rejected) {
            type = 'rejected';
            title = 'Validation Completed';
            description = 'You rejected "${action.title}"';
          }
        }

        notifications.add({
          'id': id,
          'type': type,
          'title': title,
          'description': description,
          'time': _formatNotificationTime(createdAt),
          'createdAt': createdAt,
          'action': action,
          'isRead': data['isRead'] ?? false,
        });
      }

      // 2. Fetch user profile stats for Level Up and Badge Unlocked notifications
      try {
        final userDoc = await _firestore.collection('users').doc(uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() ?? {};
          final userLevel = (userData['level'] ?? 1) as int;
          final userScore = (userData['score'] ?? 0) as int;
          final List<dynamic> badges = List.from(userData['badges'] ?? []);

          if (userLevel > 1) {
            final id = 'level_up_$userLevel';
            if (!seenIds.contains(id)) {
              seenIds.add(id);
              notifications.add({
                'id': id,
                'type': 'level_up',
                'title': 'Level Up!',
                'description': 'You have advanced to Level $userLevel. Keep building your reputation!',
                'time': 'Level $userLevel',
                'createdAt': DateTime.now().subtract(const Duration(minutes: 5)),
                'isRead': true,
              });
            }
          }

          if (badges.isNotEmpty) {
            for (var badge in badges) {
              final badgeName = badge is Map ? (badge['title'] ?? badge['name'] ?? 'Badge') : badge.toString();
              final id = 'badge_${badgeName.replaceAll(' ', '_').toLowerCase()}';
              if (!seenIds.contains(id)) {
                seenIds.add(id);
                notifications.add({
                  'id': id,
                  'type': 'badge_unlocked',
                  'title': 'Badge Unlocked',
                  'description': 'Congratulations! You unlocked the "$badgeName" badge.',
                  'time': 'Unlocked',
                  'createdAt': DateTime.now().subtract(const Duration(minutes: 10)),
                  'isRead': true,
                });
              }
            }
          } else if (userScore >= 50) {
            const id = 'badge_early_contributor';
            if (!seenIds.contains(id)) {
              seenIds.add(id);
              notifications.add({
                'id': id,
                'type': 'badge_unlocked',
                'title': 'Badge Unlocked',
                'description': 'Congratulations! You unlocked the "Early Contributor" badge.',
                'time': 'Unlocked',
                'createdAt': DateTime.now().subtract(const Duration(minutes: 10)),
                'isRead': true,
              });
            }
          }
        }
      } catch (e) {
        print('User profile fetch warning for notifications: $e');
      }

      // 3. Fetch dynamic actions for fallback notifications if not already seen
      try {
        final actionsSnapshot = await _firestore.collection('actions').get();
        for (var doc in actionsSnapshot.docs) {
          final data = doc.data();
          final action = ActionModel.fromMap(data, doc.id, currentUserId: uid);

          // ROLE A: VALIDATOR (Only show if pending and not seen)
          if (action.validatorId == uid && action.validationStatus == ValidationStatus.pending) {
            final notifId = 'val_req_${action.id}';
            if (!seenIds.contains(notifId)) {
              seenIds.add(notifId);
              notifications.add({
                'id': notifId,
                'type': 'validation_requested',
                'title': 'Validation Request',
                'description': '${action.userName} requested validation for "${action.title}"',
                'time': _formatNotificationTime(action.createdAt),
                'createdAt': action.createdAt,
                'action': action,
              });
            }
          }

          // ROLE B: PUBLISHER (Only show if not seen)
          if (action.userId == uid) {
            final notifId = 'approved_${action.id}';
            if (!seenIds.contains(notifId)) {
              if (action.validationStatus == ValidationStatus.confirmed ||
                  action.validationStatus == ValidationStatus.certified) {
                seenIds.add(notifId);
                final isCert = action.validationStatus == ValidationStatus.certified;
                final scoreReward = isCert ? 100 : 50;
                final validatorName = action.validatorName ?? 'Validator';
                notifications.add({
                  'id': notifId,
                  'type': 'approved',
                  'title': isCert ? 'Action Certified!' : 'Action Confirmed!',
                  'description': 'Your action "${action.title}" has been confirmed by $validatorName (+$scoreReward Worth Score)',
                  'time': _formatNotificationTime(action.createdAt),
                  'createdAt': action.createdAt,
                  'action': action,
                });
              } else if (action.validationStatus == ValidationStatus.rejected && !seenIds.contains('rejected_${action.id}')) {
                seenIds.add('rejected_${action.id}');
                notifications.add({
                  'id': 'rejected_${action.id}',
                  'type': 'rejected',
                  'title': 'Validation Rejected',
                  'description': 'Your action "${action.title}" was marked as rejected by validator.',
                  'time': _formatNotificationTime(action.createdAt),
                  'createdAt': action.createdAt,
                  'action': action,
                });
              }
            }
          }
        }
      } catch (e) {
        print('Error fetching fallback actions for notifications: $e');
      }

      notifications.sort((a, b) {
        final dateA = a['createdAt'] as DateTime? ?? DateTime.now();
        final dateB = b['createdAt'] as DateTime? ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      return notifications;
    });
  }

  String _formatNotificationTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  /// Toggle read/unread status for a specific notification document
  Future<void> toggleNotificationReadStatus(String notificationId, bool currentIsRead) async {
    final uid = currentUserId;
    if (uid == null) return;

    try {
      final docRef = _firestore.collection('notifications').doc(notificationId);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        await docRef.update({'isRead': !currentIsRead});
      } else {
        await docRef.set({
          'targetUserId': uid,
          'isRead': !currentIsRead,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error toggling notification read status: $e');
    }
  }

  /// Mark all notifications for current user as read
  Future<void> markAllNotificationsAsRead() async {
    final uid = currentUserId;
    if (uid == null) return;

    try {
      final unreadSnap = await _firestore
          .collection('notifications')
          .where('targetUserId', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in unreadSnap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Submit validation decision (confirm / certify / reject)
  Future<void> submitValidationDecision({
    required String actionId,
    required String decision,
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

    // Update any pending validation_request notification docs for this validator & action in Firestore
    try {
      final valNotifSnap = await _firestore
          .collection('notifications')
          .where('actionId', isEqualTo: actionId)
          .where('targetUserId', isEqualTo: validatorId)
          .get();

      for (var doc in valNotifSnap.docs) {
        await doc.reference.update({
          'type': decision == 'rejected' ? 'rejected' : 'approved',
          'title': 'Validation Completed',
          'description': decision == 'rejected'
              ? 'You marked "${actionData['title']}" as rejected.'
              : 'You confirmed "${actionData['title']}".',
          'isRead': true,
        });
      }
    } catch (e) {
      print('Error updating validator notification: $e');
    }

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

    // 3. Send notification & FCM push to Publisher
    try {
      final actionTitle = (actionData['title'] ?? 'Action') as String;
      final validatorDoc = await _firestore.collection('users').doc(validatorId).get();
      final validatorName = validatorDoc.data()?['name'] ?? 'Validator';

      final isCert = decision == 'certified';
      final isRej = decision == 'rejected';
      final title = isRej
          ? 'Validation Rejected'
          : (isCert ? 'Action Certified!' : 'Action Confirmed!');
      final scoreReward = isCert ? 100 : 50;
      final body = isRej
          ? 'Your action "$actionTitle" was rejected by $validatorName.'
          : 'Your action "$actionTitle" was confirmed by $validatorName (+$scoreReward Worth Score)';

      await NotificationService().sendNotification(
        targetUserId: publisherId,
        title: title,
        body: body,
        type: isRej ? 'rejected' : 'approved',
        actionId: actionId,
      );
    } catch (e) {
      print('Error sending validation decision notification: $e');
    }
  }

  /// Alias for submitValidationDecision
  Future<void> submitValidation({
    required String actionId,
    required String decision,
    required double confidence,
    required String comment,
  }) => submitValidationDecision(
        actionId: actionId,
        decision: decision,
        confidence: confidence,
        comment: comment,
      );

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

    // Abusive text check
    final textError = await ModerationTextService().checkText(commentText);
    if (textError != null) throw Exception(textError);

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};
    final accountStatus = userData['accountStatus'] as String? ?? 'active';
    if (accountStatus == 'suspended' || accountStatus == 'blocked') {
      final reason = userData['suspensionReason'] as String?;
      final reasonMsg = reason != null && reason.isNotEmpty ? ' Reason: $reason' : '';
      throw Exception('Your account is $accountStatus by an administrator and cannot post comments.$reasonMsg');
    }
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
      'moderationStatus': 'visible',
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
      return snapshot.docs
          .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
          .where((comment) => comment.isVisible)
          .toList();
    });
  }
}

