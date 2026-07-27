// lib/models/user_model.dart
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final int score;
  final int level;
  final String category;
  final String location;
  final bool isOnline;
  final bool verified;
  final int actionsCount;

  const UserModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.score,
    required this.level,
    required this.category,
    required this.location,
    required this.isOnline,
    required this.verified,
    required this.actionsCount,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    int? score,
    int? level,
    String? category,
    String? location,
    bool? isOnline,
    bool? verified,
    int? actionsCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      score: score ?? this.score,
      level: level ?? this.level,
      category: category ?? this.category,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      verified: verified ?? this.verified,
      actionsCount: actionsCount ?? this.actionsCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    score,
    level,
    category,
    location,
    isOnline,
    verified,
    actionsCount,
  ];
}