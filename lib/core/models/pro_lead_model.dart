import 'package:flutter/foundation.dart';

@immutable
class ProLeadModel {
  final String id;
  final String proId;
  final String seekerId;
  final String status;
  final DateTime createdAt;

  // Joined fields
  final String? seekerName;

  const ProLeadModel({
    required this.id,
    required this.proId,
    required this.seekerId,
    this.status = 'new',
    required this.createdAt,
    this.seekerName,
  });

  factory ProLeadModel.fromJson(Map<String, dynamic> json) {
    return ProLeadModel(
      id: json['id'] as String,
      proId: json['pro_id'] as String,
      seekerId: json['seeker_id'] as String,
      status: json['status'] as String? ?? 'new',
      createdAt: DateTime.parse(json['created_at'] as String),
      seekerName: json['seeker_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pro_id': proId,
      'seeker_id': seekerId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
