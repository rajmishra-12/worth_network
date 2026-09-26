import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:worth_network/core/model/home/evidence_model.dart';

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
  final List<EvidenceModel> evidences;
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
  final String moderationStatus; // 'visible', 'hidden', 'removed'
  final String? moderatedBy;
  final DateTime? moderatedAt;
  final String? moderationReason;

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
    this.evidences = const [],
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
    this.moderationStatus = 'visible',
    this.moderatedBy,
    this.moderatedAt,
    this.moderationReason,
  });

  bool get isVisible => moderationStatus == 'visible';
  bool get isHidden => moderationStatus == 'hidden';
  bool get isRemoved => moderationStatus == 'removed';

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
    List<EvidenceModel>? evidences,
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
    String? moderationStatus,
    String? moderatedBy,
    DateTime? moderatedAt,
    String? moderationReason,
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
      evidences: evidences ?? this.evidences,
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
      moderationStatus: moderationStatus ?? this.moderationStatus,
      moderatedBy: moderatedBy ?? this.moderatedBy,
      moderatedAt: moderatedAt ?? this.moderatedAt,
      moderationReason: moderationReason ?? this.moderationReason,
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
      'evidences': evidences.map((e) => e.toMap()).toList(),
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
      'moderationStatus': moderationStatus,
      'moderatedBy': moderatedBy,
      'moderatedAt': moderatedAt != null ? Timestamp.fromDate(moderatedAt!) : null,
      'moderationReason': moderationReason,
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

    DateTime? modDate;
    if (map['moderatedAt'] is Timestamp) {
      modDate = (map['moderatedAt'] as Timestamp).toDate();
    }

    // Parse evidences array or synthesize fallback from legacy fields
    List<EvidenceModel> evidenceList = [];
    if (map['evidences'] is List && (map['evidences'] as List).isNotEmpty) {
      evidenceList = (map['evidences'] as List)
          .map((e) => EvidenceModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else {
      final legacyType = map['proofType'] as String?;
      final legacyUrl = map['proofUrl'] as String?;
      final legacyText = map['textProof'] as String?;

      if (legacyType != null || (legacyText != null && legacyText.isNotEmpty)) {
        evidenceList.add(EvidenceModel(
          type: legacyType ?? 'text',
          url: legacyUrl,
          text: legacyText,
        ));
      }
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
      evidences: evidenceList,
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
      moderationStatus: map['moderationStatus'] ?? 'visible',
      moderatedBy: map['moderatedBy'],
      moderatedAt: modDate,
      moderationReason: map['moderationReason'],
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
        evidences,
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
        moderationStatus,
        moderatedBy,
        moderatedAt,
        moderationReason,
      ];
}