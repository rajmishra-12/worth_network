import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ReportStatus {
  pending,
  underReview,
  resolved,
  dismissed,
}

enum ReportType {
  action,
  comment,
  user,
}

class ReportModel extends Equatable {
  final String id;
  final String reporterId;
  final String? reporterName;
  final String reportedUserId;
  final String? reportedUserName;
  final String? contentId;
  final String contentType; // 'action', 'comment', 'user'
  final String? contentPreview;
  final String reason; // 'harassment', 'hate_speech', 'inappropriate', 'spam', 'misleading', 'other'
  final String? description;
  final ReportStatus status;
  final DateTime createdAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? adminNote;

  const ReportModel({
    required this.id,
    required this.reporterId,
    this.reporterName,
    required this.reportedUserId,
    this.reportedUserName,
    this.contentId,
    required this.contentType,
    this.contentPreview,
    required this.reason,
    this.description,
    required this.status,
    required this.createdAt,
    this.reviewedBy,
    this.reviewedAt,
    this.adminNote,
  });

  ReportModel copyWith({
    String? id,
    String? reporterId,
    String? reporterName,
    String? reportedUserId,
    String? reportedUserName,
    String? contentId,
    String? contentType,
    String? contentPreview,
    String? reason,
    String? description,
    ReportStatus? status,
    DateTime? createdAt,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? adminNote,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      reportedUserId: reportedUserId ?? this.reportedUserId,
      reportedUserName: reportedUserName ?? this.reportedUserName,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      contentPreview: contentPreview ?? this.contentPreview,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      adminNote: adminNote ?? this.adminNote,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reportedUserId': reportedUserId,
      'reportedUserName': reportedUserName,
      'contentId': contentId,
      'contentType': contentType,
      'contentPreview': contentPreview,
      'reason': reason,
      'description': description,
      'status': status.name,
      'createdAt': FieldValue.serverTimestamp(),
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'adminNote': adminNote,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map, String docId) {
    ReportStatus status = ReportStatus.pending;
    final statusStr = map['status'] as String? ?? 'pending';
    switch (statusStr) {
      case 'underReview':
      case 'under_review':
        status = ReportStatus.underReview;
        break;
      case 'resolved':
        status = ReportStatus.resolved;
        break;
      case 'dismissed':
        status = ReportStatus.dismissed;
        break;
      default:
        status = ReportStatus.pending;
    }

    DateTime createdDate = DateTime.now();
    if (map['createdAt'] is Timestamp) {
      createdDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      createdDate = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    }

    DateTime? revDate;
    if (map['reviewedAt'] is Timestamp) {
      revDate = (map['reviewedAt'] as Timestamp).toDate();
    }

    return ReportModel(
      id: docId,
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'],
      reportedUserId: map['reportedUserId'] ?? '',
      reportedUserName: map['reportedUserName'],
      contentId: map['contentId'],
      contentType: map['contentType'] ?? 'action',
      contentPreview: map['contentPreview'],
      reason: map['reason'] ?? 'other',
      description: map['description'],
      status: status,
      createdAt: createdDate,
      reviewedBy: map['reviewedBy'],
      reviewedAt: revDate,
      adminNote: map['adminNote'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        reporterId,
        reporterName,
        reportedUserId,
        reportedUserName,
        contentId,
        contentType,
        contentPreview,
        reason,
        description,
        status,
        createdAt,
        reviewedBy,
        reviewedAt,
        adminNote,
      ];
}
