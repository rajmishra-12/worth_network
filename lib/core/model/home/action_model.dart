// lib/models/action_model.dart
import 'package:equatable/equatable.dart';

enum ValidationStatus {
  declared,
  confirmed,
  certified,
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
  final ValidationStatus validationStatus;
  final int score;
  final int likesCount;
  final int commentsCount;
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
    required this.validationStatus,
    required this.score,
    required this.likesCount,
    required this.commentsCount,
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
    ValidationStatus? validationStatus,
    int? score,
    int? likesCount,
    int? commentsCount,
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
      validationStatus: validationStatus ?? this.validationStatus,
      score: score ?? this.score,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
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
        validationStatus,
        score,
        likesCount,
        commentsCount,
        createdAt,
        isLikedByUser,
      ];
}