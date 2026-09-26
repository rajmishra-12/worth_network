// lib/models/user_model.dart
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? accountType;
  final List<String> roles;
  final int score;
  final int level;
  final String category;
  final String location;
  final bool isOnline;
  final bool verified;
  final int actionsCount;
  final int followersCount;
  final int followingCount;

  const UserModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.accountType,
    this.roles = const [],
    required this.score,
    required this.level,
    required this.category,
    required this.location,
    required this.isOnline,
    required this.verified,
    required this.actionsCount,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? accountType,
    List<String>? roles,
    int? score,
    int? level,
    String? category,
    String? location,
    bool? isOnline,
    bool? verified,
    int? actionsCount,
    int? followersCount,
    int? followingCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      accountType: accountType ?? this.accountType,
      roles: roles ?? this.roles,
      score: score ?? this.score,
      level: level ?? this.level,
      category: category ?? this.category,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      verified: verified ?? this.verified,
      actionsCount: actionsCount ?? this.actionsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    accountType,
    roles,
    score,
    level,
    category,
    location,
    isOnline,
    verified,
    actionsCount,
    followersCount,
    followingCount,
  ];
}