// lib/models/profile_model.dart
import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? bio;
  final String? accountType;
  final List<String> roles;
  final int score;
  final int level;
  final int xp;
  final int nextLevelXp;
  final int totalActions;
  final double validatedPercentage;
  final int followersCount;
  final int followingCount;
  final List<BadgeModel> badges;

  const ProfileModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.accountType,
    this.roles = const [],
    required this.score,
    required this.level,
    required this.xp,
    required this.nextLevelXp,
    required this.totalActions,
    required this.validatedPercentage,
    this.followersCount = 0,
    this.followingCount = 0,
    required this.badges,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    bio,
    accountType,
    roles,
    score,
    level,
    xp,
    nextLevelXp,
    totalActions,
    validatedPercentage,
    followersCount,
    followingCount,
    badges,
  ];
}


class BadgeModel extends Equatable {
  final String name;
  final String description;
  final bool isEarned;

  const BadgeModel({
    required this.name,
    required this.description,
    required this.isEarned,
  });

  @override
  List<Object?> get props => [name, description, isEarned];
}