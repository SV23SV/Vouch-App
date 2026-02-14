import 'package:flutter/foundation.dart';

@immutable
class AlertModel {
  final String id;
  final String reportedBy;
  final String proId;
  final String alertType;
  final String description;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  // Joined fields
  final String? proName;
  final String? reporterName;
  final int? reportCount;

  const AlertModel({
    required this.id,
    required this.reportedBy,
    required this.proId,
    required this.alertType,
    required this.description,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.proName,
    this.reporterName,
    this.reportCount,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      reportedBy: json['reported_by'] as String,
      proId: json['pro_id'] as String,
      alertType: json['alert_type'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      proName: json['pro_name'] as String?,
      reporterName: json['reporter_name'] as String?,
      reportCount: json['report_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reported_by': reportedBy,
      'pro_id': proId,
      'alert_type': alertType,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
