import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final String id;
  final String? email;
  final String phoneHash;
  final double trustScore;
  final String? zipCode;
  final String? displayName;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    this.email,
    required this.phoneHash,
    this.trustScore = 0.0,
    this.zipCode,
    this.displayName,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      phoneHash: json['phone_hash'] as String,
      trustScore: (json['trust_score'] as num?)?.toDouble() ?? 0.0,
      zipCode: json['zip_code'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone_hash': phoneHash,
      'trust_score': trustScore,
      'zip_code': zipCode,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? phoneHash,
    double? trustScore,
    String? zipCode,
    String? displayName,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneHash: phoneHash ?? this.phoneHash,
      trustScore: trustScore ?? this.trustScore,
      zipCode: zipCode ?? this.zipCode,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
