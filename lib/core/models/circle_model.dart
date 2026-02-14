import 'package:flutter/foundation.dart';

@immutable
class CircleModel {
  final String id;
  final String userAId;
  final String userBId;
  final String status;
  final DateTime createdAt;

  // Joined fields
  final String? friendName;
  final String? friendAvatarUrl;
  final int? friendVouchCount;

  const CircleModel({
    required this.id,
    required this.userAId,
    required this.userBId,
    this.status = 'pending',
    required this.createdAt,
    this.friendName,
    this.friendAvatarUrl,
    this.friendVouchCount,
  });

  factory CircleModel.fromJson(Map<String, dynamic> json) {
    return CircleModel(
      id: json['id'] as String,
      userAId: json['user_a_id'] as String,
      userBId: json['user_b_id'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      friendName: json['friend_name'] as String?,
      friendAvatarUrl: json['friend_avatar_url'] as String?,
      friendVouchCount: json['friend_vouch_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_a_id': userAId,
      'user_b_id': userBId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CircleModel copyWith({
    String? id,
    String? userAId,
    String? userBId,
    String? status,
    DateTime? createdAt,
    String? friendName,
    String? friendAvatarUrl,
    int? friendVouchCount,
  }) {
    return CircleModel(
      id: id ?? this.id,
      userAId: userAId ?? this.userAId,
      userBId: userBId ?? this.userBId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      friendName: friendName ?? this.friendName,
      friendAvatarUrl: friendAvatarUrl ?? this.friendAvatarUrl,
      friendVouchCount: friendVouchCount ?? this.friendVouchCount,
    );
  }
}
