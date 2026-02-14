import 'package:flutter/foundation.dart';

@immutable
class ProModel {
  final String id;
  final String businessName;
  final String category;
  final double avgVouchScore;
  final String? phoneHash;
  final bool isClaimed;
  final String? licensePhotoUrl;
  final String? description;
  final String? zipCode;
  final List<String> photoGallery;
  final DateTime createdAt;

  const ProModel({
    required this.id,
    required this.businessName,
    required this.category,
    this.avgVouchScore = 0.0,
    this.phoneHash,
    this.isClaimed = false,
    this.licensePhotoUrl,
    this.description,
    this.zipCode,
    this.photoGallery = const [],
    required this.createdAt,
  });

  factory ProModel.fromJson(Map<String, dynamic> json) {
    return ProModel(
      id: json['id'] as String,
      businessName: json['business_name'] as String,
      category: json['category'] as String,
      avgVouchScore: (json['avg_vouch_score'] as num?)?.toDouble() ?? 0.0,
      phoneHash: json['phone_hash'] as String?,
      isClaimed: json['is_claimed'] as bool? ?? false,
      licensePhotoUrl: json['license_photo_url'] as String?,
      description: json['description'] as String?,
      zipCode: json['zip_code'] as String?,
      photoGallery: (json['photo_gallery'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'category': category,
      'avg_vouch_score': avgVouchScore,
      'phone_hash': phoneHash,
      'is_claimed': isClaimed,
      'license_photo_url': licensePhotoUrl,
      'description': description,
      'zip_code': zipCode,
      'photo_gallery': photoGallery,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ProModel copyWith({
    String? id,
    String? businessName,
    String? category,
    double? avgVouchScore,
    String? phoneHash,
    bool? isClaimed,
    String? licensePhotoUrl,
    String? description,
    String? zipCode,
    List<String>? photoGallery,
    DateTime? createdAt,
  }) {
    return ProModel(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      category: category ?? this.category,
      avgVouchScore: avgVouchScore ?? this.avgVouchScore,
      phoneHash: phoneHash ?? this.phoneHash,
      isClaimed: isClaimed ?? this.isClaimed,
      licensePhotoUrl: licensePhotoUrl ?? this.licensePhotoUrl,
      description: description ?? this.description,
      zipCode: zipCode ?? this.zipCode,
      photoGallery: photoGallery ?? this.photoGallery,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
