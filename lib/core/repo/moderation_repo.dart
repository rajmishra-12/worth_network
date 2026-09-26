import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:worth_network/core/model/moderation/blocked_user_model.dart';
import 'package:worth_network/core/model/moderation/moderation_action_model.dart';
import 'package:worth_network/core/model/moderation/report_model.dart';
import 'package:worth_network/core/utils/preferences.dart';

class ModerationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  static final Set<String> _cachedReportedContentIds = {};

  /// Fetch list of content IDs reported by current user
  Future<Set<String>> getReportedContentIds() async {
    final uid = currentUserId;
    if (uid == null) return _cachedReportedContentIds;

    try {
      final snap = await _firestore
          .collection('moderationReports')
          .where('reporterId', isEqualTo: uid)
          .get();

      for (var doc in snap.docs) {
        final data = doc.data();
        final cId = data['contentId'] as String?;
        if (cId != null && cId.isNotEmpty) {
          _cachedReportedContentIds.add(cId);
        }
      }
    } catch (e) {
      print('Error fetching reported content IDs: $e');
    }

    return _cachedReportedContentIds;
  }

  // ==================== REPORTING ====================

  /// Submit content or user report to Firestore
  Future<void> submitReport({
    required String reportedUserId,
    String? reportedUserName,
    String? contentId,
    required String contentType, // 'action', 'comment', 'user'
    String? contentPreview,
    required String reason,
    String? description,
  }) async {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) {
      throw Exception('You must be signed in to submit a report.');
    }

    if (contentId != null && contentId.isNotEmpty) {
      _cachedReportedContentIds.add(contentId);
    }

    final prefs = Preferences();
    final reporterName = _auth.currentUser?.displayName ?? prefs.name;

    // Check for duplicate pending report by same reporter
    try {
      Query query = _firestore
          .collection('moderationReports')
          .where('reporterId', isEqualTo: uid)
          .where('reportedUserId', isEqualTo: reportedUserId)
          .where('contentType', isEqualTo: contentType)
          .where('status', isEqualTo: 'pending');

      if (contentId != null && contentId.isNotEmpty) {
        query = query.where('contentId', isEqualTo: contentId);
      }

      final existingSnap = await query.get();
      if (existingSnap.docs.isNotEmpty) {
        throw Exception(
          'You have already submitted a pending report for this item.',
        );
      }
    } catch (e) {
      if (e.toString().contains('already submitted')) rethrow;
      print('Duplicate report query check warning: $e');
    }

    final docRef = _firestore.collection('moderationReports').doc();
    final report = ReportModel(
      id: docRef.id,
      reporterId: uid,
      reporterName: reporterName,
      reportedUserId: reportedUserId,
      reportedUserName: reportedUserName,
      contentId: contentId,
      contentType: contentType,
      contentPreview: contentPreview,
      reason: reason,
      description: description?.trim(),
      status: ReportStatus.pending,
      createdAt: DateTime.now(),
    );

    try {
      await docRef.set(report.toMap());
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print(
          'Warning: Firebase security rules for moderationReports not yet published to Firebase Console: $e',
        );
        return;
      }
      rethrow;
    }
  }

  /// Real-time stream of reports for Admin console
  Stream<List<ReportModel>> getReportsStream({
    String? statusFilter,
    String? typeFilter,
  }) {
    Query query = _firestore.collection('moderationReports');

    if (statusFilter != null &&
        statusFilter.isNotEmpty &&
        statusFilter != 'all') {
      query = query.where('status', isEqualTo: statusFilter);
    }

    if (typeFilter != null && typeFilter.isNotEmpty && typeFilter != 'all') {
      query = query.where('contentType', isEqualTo: typeFilter);
    }

    return query.snapshots().map((snapshot) {
      final reports = snapshot.docs.map((doc) {
        return ReportModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reports;
    });
  }

  /// Update report status (e.g. resolve or dismiss)
  Future<void> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    String? adminNote,
  }) async {
    final adminId = currentUserId ?? 'admin';
    final prefs = Preferences();
    final adminName = _auth.currentUser?.displayName ?? prefs.name;

    final docRef = _firestore.collection('moderationReports').doc(reportId);
    await docRef.update({
      'status': status.name,
      'reviewedBy': adminName.isNotEmpty ? adminName : adminId,
      'reviewedAt': FieldValue.serverTimestamp(),
      if (adminNote != null && adminNote.isNotEmpty) 'adminNote': adminNote,
    });

    // Audit log entry
    final actionType = status == ReportStatus.resolved
        ? 'resolve_report'
        : 'dismiss_report';
    await logModerationAction(
      actionType: actionType,
      contentId: reportId,
      contentType: 'report',
      reason: adminNote ?? 'Report marked as ${status.name}',
    );
  }

  // ==================== USER BLOCKING ====================

  /// Block a user
  Future<void> blockUser({
    required String targetUserId,
    required String targetUserName,
    String? targetUserAvatar,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');
    if (uid == targetUserId) throw Exception('You cannot block yourself.');

    final blockModel = BlockedUserModel(
      userId: targetUserId,
      userName: targetUserName,
      avatarUrl: targetUserAvatar,
      blockedAt: DateTime.now(),
    );

    // Write to current user's blocked_users subcollection
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('blocked_users')
        .doc(targetUserId)
        .set(blockModel.toMap());

    // Also write to global top-level blockedUsers collection for security rules
    try {
      await _firestore
          .collection('blockedUsers')
          .doc('${uid}_$targetUserId')
          .set({
            'blockerId': uid,
            'blockedId': targetUserId,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Warning: Top-level blockedUsers write skipped: $e');
    }
  }

  /// Unblock a user
  Future<void> unblockUser(String targetUserId) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('blocked_users')
        .doc(targetUserId)
        .delete();

    await _firestore
        .collection('blockedUsers')
        .doc('${uid}_$targetUserId')
        .delete();
  }

  /// Stream of blocked users for the logged-in user
  Stream<List<BlockedUserModel>> getBlockedUsersStream() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('blocked_users')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BlockedUserModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  /// Fetch list of user UIDs blocked by current user (for feed filtering)
  Future<Set<String>> getBlockedUserIds() async {
    final uid = currentUserId;
    if (uid == null) return {};

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('blocked_users')
          .get();

      return snapshot.docs.map((doc) => doc.id).toSet();
    } catch (e) {
      print('Error fetching blocked user IDs: $e');
      return {};
    }
  }

  /// Helper to check if current logged in user has admin rights
  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    if (user.email?.toLowerCase() == 'admin@gmail.com') return true;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        final accountType = data['accountType'] as String?;
        final roles =
            (data['roles'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        if (accountType == 'admin' || roles.contains('admin')) {
          return true;
        }
      }
    } catch (e) {
      print('Error checking admin rights: $e');
    }

    return false;
  }

  // ==================== CONTENT MODERATION (ADMIN) ====================

  /// Set moderation status for action or comment ('visible', 'hidden', 'removed')
  Future<void> updateContentModerationStatus({
    required String contentId,
    required String contentType, // 'action' or 'comment'
    required String status, // 'visible', 'hidden', 'removed'
    required String reason,
    String? parentActionId, // required if contentType == 'comment'
  }) async {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception(
        'Access Denied: Only admin users (e.g. admin@gmail.com) can hide or remove content.',
      );
    }

    final adminId = currentUserId ?? 'admin';
    final prefs = Preferences();
    final adminName = _auth.currentUser?.displayName ?? prefs.name;

    final updates = {
      'moderationStatus': status,
      'moderatedBy': adminName.isNotEmpty ? adminName : adminId,
      'moderatedAt': FieldValue.serverTimestamp(),
      'moderationReason': reason,
    };

    if (contentType == 'comment' && parentActionId != null) {
      await _firestore
          .collection('actions')
          .doc(parentActionId)
          .collection('comments')
          .doc(contentId)
          .update(updates);
    } else {
      await _firestore.collection('actions').doc(contentId).update(updates);
    }

    // Resolve any associated reports for this content
    try {
      final reportsSnap = await _firestore
          .collection('moderationReports')
          .where('contentId', isEqualTo: contentId)
          .get();

      for (var doc in reportsSnap.docs) {
        await doc.reference.update({
          'status': ReportStatus.resolved.name,
          'reviewedBy': adminName,
          'reviewedAt': FieldValue.serverTimestamp(),
          'adminNote': 'Content marked as $status ($reason)',
        });
      }
    } catch (e) {
      print('Warning: error resolving reports for content $contentId: $e');
    }

    // Log admin action
    String actionType = 'hide_content';
    if (status == 'removed') actionType = 'remove_content';
    if (status == 'visible') actionType = 'restore_content';

    await logModerationAction(
      actionType: actionType,
      contentId: contentId,
      contentType: contentType,
      reason: reason,
    );
  }

  // ==================== USER MODERATION (ADMIN) ====================

  /// Update user account status ('active', 'suspended', 'blocked')
  Future<void> updateUserAccountStatus({
    required String targetUserId,
    required String targetUserName,
    required String accountStatus, // 'active', 'suspended', 'blocked'
    required String reason,
  }) async {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception(
        'Access Denied: Only admin users (e.g. admin@gmail.com) can manage user accounts.',
      );
    }
    await _firestore.collection('users').doc(targetUserId).update({
      'accountStatus': accountStatus,
      'suspensionReason': reason,
      'suspendedAt': FieldValue.serverTimestamp(),
    });

    // Resolve reports targeting this user
    try {
      final reportsSnap = await _firestore
          .collection('moderationReports')
          .where('reportedUserId', isEqualTo: targetUserId)
          .where('contentType', isEqualTo: 'user')
          .get();

      for (var doc in reportsSnap.docs) {
        await doc.reference.update({
          'status': ReportStatus.resolved.name,
          'adminNote': 'User account set to $accountStatus ($reason)',
        });
      }
    } catch (e) {
      print('Warning resolving user reports: $e');
    }

    String actionType = 'suspend_user';
    if (accountStatus == 'active') actionType = 'unsuspend_user';
    if (accountStatus == 'blocked') actionType = 'block_user';

    await logModerationAction(
      actionType: actionType,
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      contentType: 'user',
      reason: reason,
    );
  }

  // ==================== MODERATION SETTINGS (BLOCKED WORDS) ====================

  /// Real-time stream of blocked words
  Stream<List<String>> getBlockedWordsStream() {
    return _firestore
        .collection('moderationSettings')
        .doc('blockedWords')
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) return [];
          final List<dynamic>? list =
              snapshot.data()?['words'] as List<dynamic>?;
          if (list == null) return [];
          return list.map((e) => e.toString()).toList();
        });
  }

  /// Add word to blocked words list
  Future<void> addBlockedWord(String word) async {
    final cleanWord = word.trim().toLowerCase();
    if (cleanWord.isEmpty) return;

    final docRef = _firestore
        .collection('moderationSettings')
        .doc('blockedWords');
    await docRef.set({
      'words': FieldValue.arrayUnion([cleanWord]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Remove word from blocked words list
  Future<void> removeBlockedWord(String word) async {
    final cleanWord = word.trim().toLowerCase();
    if (cleanWord.isEmpty) return;

    final docRef = _firestore
        .collection('moderationSettings')
        .doc('blockedWords');
    await docRef.update({
      'words': FieldValue.arrayRemove([cleanWord]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== AUDIT LOGGING ====================

  /// Record an administrative action in moderationActions audit log
  Future<void> logModerationAction({
    required String actionType,
    String? contentId,
    String? contentType,
    String? targetUserId,
    String? targetUserName,
    required String reason,
  }) async {
    final adminId = currentUserId ?? 'admin';
    final prefs = Preferences();
    final adminName = _auth.currentUser?.displayName ?? prefs.name;

    final docRef = _firestore.collection('moderationActions').doc();
    final logModel = ModerationActionModel(
      id: docRef.id,
      actionType: actionType,
      contentId: contentId,
      contentType: contentType,
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      adminId: adminId,
      adminName: adminName,
      reason: reason,
      createdAt: DateTime.now(),
    );

    await docRef.set(logModel.toMap());
  }

  /// Real-time stream of moderation audit log actions
  Stream<List<ModerationActionModel>> getModerationActionsStream() {
    return _firestore.collection('moderationActions').snapshots().map((
      snapshot,
    ) {
      final actions = snapshot.docs.map((doc) {
        return ModerationActionModel.fromMap(doc.data(), doc.id);
      }).toList();

      actions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return actions;
    });
  }

  // ==================== DASHBOARD STATS ====================

  /// Get real-time stats overview for Admin Dashboard
  Stream<Map<String, int>> getDashboardStatsStream() {
    return _firestore.collection('moderationReports').snapshots().asyncMap((
      reportsSnap,
    ) async {
      int pendingReports = 0;
      int underReviewReports = 0;
      int resolvedReports = 0;
      int reportedContentCount = 0;
      int reportedUsersCount = 0;

      for (var doc in reportsSnap.docs) {
        final data = doc.data();
        final status = data['status'] ?? 'pending';
        final type = data['contentType'] ?? 'action';

        if (status == 'pending') pendingReports++;
        if (status == 'underReview' || status == 'under_review')
          underReviewReports++;
        if (status == 'resolved') resolvedReports++;

        if (type == 'action' || type == 'comment') reportedContentCount++;
        if (type == 'user') reportedUsersCount++;
      }

      int suspendedUsersCount = 0;
      try {
        final usersSnap = await _firestore
            .collection('users')
            .where('accountStatus', isEqualTo: 'suspended')
            .get();
        suspendedUsersCount = usersSnap.docs.length;
      } catch (_) {}

      return {
        'pendingReports': pendingReports,
        'underReviewReports': underReviewReports,
        'resolvedReports': resolvedReports,
        'reportedContent': reportedContentCount,
        'reportedUsers': reportedUsersCount,
        'suspendedUsers': suspendedUsersCount,
      };
    });
  }
}
