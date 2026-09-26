import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ModerationActionModel extends Equatable {
  final String id;
  final String actionType; // 'hide_content', 'remove_content', 'restore_content', 'suspend_user', 'unsuspend_user', 'block_user', 'unblock_user', 'dismiss_report', 'resolve_report'
  final String? contentId;
  final String? contentType; // 'action', 'comment', 'user'
  final String? targetUserId;
  final String? targetUserName;
  final String adminId;
  final String? adminName;
  final String reason;
  final DateTime createdAt;

  const ModerationActionModel({
    required this.id,
    required this.actionType,
    this.contentId,
    this.contentType,
    this.targetUserId,
    this.targetUserName,
    required this.adminId,
    this.adminName,
    required this.reason,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'actionType': actionType,
      'contentId': contentId,
      'contentType': contentType,
      'targetUserId': targetUserId,
      'targetUserName': targetUserName,
      'adminId': adminId,
      'adminName': adminName,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory ModerationActionModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime createdDate = DateTime.now();
    if (map['createdAt'] is Timestamp) {
      createdDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      createdDate = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    }

    return ModerationActionModel(
      id: docId,
      actionType: map['actionType'] ?? 'other',
      contentId: map['contentId'],
      contentType: map['contentType'],
      targetUserId: map['targetUserId'],
      targetUserName: map['targetUserName'],
      adminId: map['adminId'] ?? '',
      adminName: map['adminName'],
      reason: map['reason'] ?? '',
      createdAt: createdDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        actionType,
        contentId,
        contentType,
        targetUserId,
        targetUserName,
        adminId,
        adminName,
        reason,
        createdAt,
      ];
}
