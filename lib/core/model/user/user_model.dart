import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String? username;
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
  final String accountStatus; // 'active', 'suspended', 'blocked'
  final String? suspensionReason;

  const UserModel({
    required this.id,
    required this.name,
    this.username,
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
    this.accountStatus = 'active',
    this.suspensionReason,
  });

  bool get isAdmin {
    final currentEmail = FirebaseAuth.instance.currentUser?.email?.toLowerCase();
    if (currentEmail == 'admin@gmail.com') return true;
    return roles.contains('admin') || accountType == 'admin';
  }
  bool get isSuspended => accountStatus == 'suspended';
  bool get isBlocked => accountStatus == 'blocked';
  bool get isActive => accountStatus == 'active';

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
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
    String? accountStatus,
    String? suspensionReason,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
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
      accountStatus: accountStatus ?? this.accountStatus,
      suspensionReason: suspensionReason ?? this.suspensionReason,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    final rolesList = (map['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return UserModel(
      id: docId,
      name: map['name'] ?? map['username'] ?? 'User',
      username: map['username'],
      avatarUrl: map['avatarUrl'],
      accountType: map['accountType'],
      roles: rolesList,
      score: map['score'] ?? 0,
      level: map['level'] ?? 1,
      category: map['category'] ?? 'General',
      location: map['location'] ?? 'Earth',
      isOnline: map['isOnline'] ?? false,
      verified: map['verified'] ?? false,
      actionsCount: map['totalActions'] ?? map['actionsCount'] ?? 0,
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      accountStatus: map['accountStatus'] ?? 'active',
      suspensionReason: map['suspensionReason'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        username,
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
        accountStatus,
        suspensionReason,
      ];
}