import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BlockedUserModel extends Equatable {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final DateTime blockedAt;

  const BlockedUserModel({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.blockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'blockedAt': FieldValue.serverTimestamp(),
    };
  }

  factory BlockedUserModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime blockedDate = DateTime.now();
    if (map['blockedAt'] is Timestamp) {
      blockedDate = (map['blockedAt'] as Timestamp).toDate();
    }

    return BlockedUserModel(
      userId: map['userId'] ?? docId,
      userName: map['userName'] ?? map['name'] ?? 'User',
      avatarUrl: map['avatarUrl'],
      blockedAt: blockedDate,
    );
  }

  @override
  List<Object?> get props => [userId, userName, avatarUrl, blockedAt];
}
