// lib/models/history_item.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class HistoryItem extends Equatable {
  final String id;
  final String title;
  final String status;
  final Color statusColor;
  final DateTime date;
  final int points;

  const HistoryItem({
    required this.id,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.date,
    required this.points,
  });

  @override
  List<Object?> get props => [id, title, status, statusColor, date, points];
}