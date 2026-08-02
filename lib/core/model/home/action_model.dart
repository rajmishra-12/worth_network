import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ValidationStatus {
  declared,
  pending,
  confirmed,
  certified,
  rejected,
}

class ActionModel extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String title;
  final String description;
  final String category;
  final String? proofType;
  final String? proofUrl;
  final String? textProof;
  final ValidationStatus validationStatus;
  final String? validatorId;
  final String? validatorUsername;
  final String? validatorName;
  final String? validatorAvatar;
  final int score;
  final int likesCount;
  final int commentsCount;
  final List<String> likedBy;
  final DateTime createdAt;
  final bool isLikedByUser;

  const ActionModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.title,
    required this.description,
    required this.category,
    this.proofType,
    this.proofUrl,
    this.textProof,
    required this.validationStatus,
    this.validatorId,
    this.validatorUsername,
    this.validatorName,
    this.validatorAvatar,
    required this.score,
    required this.likesCount,
    required this.commentsCount,
    this.likedBy = const [],
    required this.createdAt,
    this.isLikedByUser = false,
  });

  ActionModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? title,
    String? description,
    String? category,
    String? proofType,
    String? proofUrl,
    String? textProof,
    ValidationStatus? validationStatus,
    String? validatorId,
    String? validatorUsername,
    String? validatorName,
    String? validatorAvatar,
    int? score,
    int? likesCount,
    int? commentsCount,
    List<String>? likedBy,
    DateTime? createdAt,
    bool? isLikedByUser,
  }) {
    return ActionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      proofType: proofType ?? this.proofType,
      proofUrl: proofUrl ?? this.proofUrl,
      textProof: textProof ?? this.textProof,
      validationStatus: validationStatus ?? this.validationStatus,
      validatorId: validatorId ?? this.validatorId,
      validatorUsername: validatorUsername ?? this.validatorUsername,
      validatorName: validatorName ?? this.validatorName,
      validatorAvatar: validatorAvatar ?? this.validatorAvatar,
      score: score ?? this.score,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'title': title,
      'description': description,
      'category': category,
      'proofType': proofType,
      'proofUrl': proofUrl,
      'textProof': textProof,
      'validationStatus': validationStatus.name,
      'validatorId': validatorId,
      'validatorUsername': validatorUsername,
      'validatorName': validatorName,
      'validatorAvatar': validatorAvatar,
      'score': score,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'likedBy': likedBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory ActionModel.fromMap(Map<String, dynamic> map, String docId, {String? currentUserId}) {
    ValidationStatus status = ValidationStatus.declared;
    final statusStr = map['validationStatus'] as String? ?? 'declared';
    switch (statusStr) {
      case 'pending':
        status = ValidationStatus.pending;
        break;
      case 'confirmed':
        status = ValidationStatus.confirmed;
        break;
      case 'certified':
        status = ValidationStatus.certified;
        break;
      case 'rejected':
        status = ValidationStatus.rejected;
        break;
      default:
        status = ValidationStatus.declared;
    }

    final likedByList = (map['likedBy'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final isLiked = currentUserId != null ? likedByList.contains(currentUserId) : false;

    DateTime createdDate = DateTime.now();
    if (map['createdAt'] is Timestamp) {
      createdDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      createdDate = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    }

    return ActionModel(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      userAvatar: map['userAvatar'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
      proofType: map['proofType'],
      proofUrl: map['proofUrl'],
      textProof: map['textProof'],
      validationStatus: status,
      validatorId: map['validatorId'],
      validatorUsername: map['validatorUsername'],
      validatorName: map['validatorName'],
      validatorAvatar: map['validatorAvatar'],
      score: map['score'] ?? 0,
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      likedBy: likedByList,
      createdAt: createdDate,
      isLikedByUser: isLiked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userAvatar,
        title,
        description,
        category,
        proofType,
        proofUrl,
        textProof,
        validationStatus,
        validatorId,
        validatorUsername,
        validatorName,
        validatorAvatar,
        score,
        likesCount,
        commentsCount,
        likedBy,
        createdAt,
        isLikedByUser,
      ];
}