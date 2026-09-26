import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:worth_network/core/model/user/user_model.dart';

class FollowRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FollowRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if current user is following [targetUserId]
  Future<bool> isFollowing(String targetUserId) async {
    final uid = currentUserId;
    if (uid == null || uid == targetUserId || targetUserId.isEmpty) return false;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return false;
      final following = (doc.data()?['following'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      return following.contains(targetUserId);
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  /// Real-time stream of follow status for a given target user
  Stream<bool> isFollowingStream(String targetUserId) {
    final uid = currentUserId;
    if (uid == null || uid == targetUserId || targetUserId.isEmpty) {
      return Stream.value(false);
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) {
          if (!snap.exists) return false;
          final following = (snap.data()?['following'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          return following.contains(targetUserId);
        })
        .handleError((error) {
          print('Handled error in isFollowingStream: $error');
          return false;
        });
  }

  /// Follow user (Updates following array on current user document)
  Future<void> followUser(String targetUserId) async {
    final uid = currentUserId;
    if (uid == null || uid == targetUserId || targetUserId.isEmpty) return;

    try {
      await _firestore.collection('users').doc(uid).set({
        'following': FieldValue.arrayUnion([targetUserId]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Follow user failed: $e');
      rethrow;
    }
  }

  /// Unfollow user (Removes targetUserId from following array on current user document)
  Future<void> unfollowUser(String targetUserId) async {
    final uid = currentUserId;
    if (uid == null || uid == targetUserId || targetUserId.isEmpty) return;

    try {
      await _firestore.collection('users').doc(uid).set({
        'following': FieldValue.arrayRemove([targetUserId]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Unfollow user failed: $e');
      rethrow;
    }
  }

  UserModel _parseUserModel(String docId, Map<String, dynamic> data) {
    final rawName = data['name'] as String?;
    final rawUsername = data['username'] as String?;
    final name = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : ((rawUsername != null && rawUsername.trim().isNotEmpty)
            ? rawUsername.trim()
            : 'User');

    final scoreRaw = data['score'];
    final score = scoreRaw is int ? scoreRaw : (scoreRaw is num ? scoreRaw.toInt() : 0);

    final levelRaw = data['level'];
    final level = levelRaw is int ? levelRaw : (levelRaw is num ? levelRaw.toInt() : 1);

    final actionsCountRaw = data['totalActions'];
    final actionsCount = actionsCountRaw is int ? actionsCountRaw : (actionsCountRaw is num ? actionsCountRaw.toInt() : 0);

    final userFollowingRaw = data['following'];
    final userFollowingList = (userFollowingRaw is List)
        ? userFollowingRaw.map((e) => e.toString()).toList()
        : <String>[];

    return UserModel(
      id: docId,
      name: name,
      avatarUrl: (data['avatarUrl'] as String?) ?? '',
      score: score,
      level: level,
      category: (data['category'] as String?) ?? 'Support',
      location: (data['location'] as String?) ?? 'Worldwide',
      isOnline: true,
      verified: score > 100,
      actionsCount: actionsCount,
      followersCount: 0,
      followingCount: userFollowingList.length,
    );
  }

  /// Fetch list of follower user profiles for [userId] (Users who follow [userId])
  Future<List<UserModel>> getFollowers(String userId) async {
    if (userId.trim().isEmpty) return [];
    try {
      final snap = await _firestore
          .collection('users')
          .where('following', arrayContains: userId)
          .get();

      if (snap.docs.isEmpty) return [];

      return snap.docs
          .map((doc) => _parseUserModel(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error getting followers: $e');
      return [];
    }
  }

  /// Fetch list of following user profiles for [userId] (Users that [userId] follows)
  Future<List<UserModel>> getFollowing(String userId) async {
    if (userId.trim().isEmpty) return [];
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists || userDoc.data() == null) return [];

      final followingRaw = userDoc.data()?['following'];
      final followingIds = (followingRaw is List)
          ? followingRaw.map((e) => e.toString()).where((id) => id.isNotEmpty).toList()
          : <String>[];

      if (followingIds.isEmpty) return [];

      final userDocFutures = followingIds.map((id) async {
        try {
          final doc = await _firestore.collection('users').doc(id).get();
          if (doc.exists && doc.data() != null) {
            return _parseUserModel(doc.id, doc.data()!);
          }
        } catch (e) {
          print('Warning: Failed to fetch single following doc $id: $e');
        }
        return null;
      });

      final results = await Future.wait(userDocFutures);
      return results.whereType<UserModel>().toList();
    } catch (e) {
      print('Error getting following list: $e');
      return [];
    }
  }

  /// Stream user metrics (followersCount, followingCount)
  Stream<Map<String, int>> getUserMetricsStream(String userId) {
    if (userId.isEmpty) {
      return Stream.value({'followers': 0, 'following': 0});
    }

    // Stream user doc for following count and query followers count
    return _firestore.collection('users').doc(userId).snapshots().asyncMap((userSnap) async {
      final followingCount = (userSnap.data()?['following'] as List<dynamic>?)?.length ?? 0;
      
      int followersCount = 0;
      try {
        final followersSnap = await _firestore
            .collection('users')
            .where('following', arrayContains: userId)
            .get();
        followersCount = followersSnap.docs.length;
      } catch (e) {
        print('Handled followers query error in getUserMetricsStream: $e');
      }

      return {
        'followers': followersCount,
        'following': followingCount,
      };
    }).handleError((error) {
      print('Handled error in getUserMetricsStream: $error');
      return {'followers': 0, 'following': 0};
    });
  }
}
