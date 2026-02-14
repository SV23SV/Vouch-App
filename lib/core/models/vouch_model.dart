import 'package:flutter/foundation.dart';

@immutable
class VouchModel {
  final String id;
  final String userId;
  final String proId;
  final String? pricePaidEncrypted;
  final String? note;
  final int safetyRating;
  final String visibilityLevel;
  final DateTime createdAt;

  // Joined fields (populated from queries)
  final String? voucherName;
  final String? proName;
  final String? proCategory;

  const VouchModel({
    required this.id,
    required this.userId,
    required this.proId,
    this.pricePaidEncrypted,
    this.note,
    this.safetyRating = 5,
    this.visibilityLevel = 'circle',
    required this.createdAt,
    this.voucherName,
    this.proName,
    this.proCategory,
  });

  factory VouchModel.fromJson(Map<String, dynamic> json) {
    return VouchModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      proId: json['pro_id'] as String,
      pricePaidEncrypted: json['price_paid_encrypted'] as String?,
      note: json['note'] as String?,
      safetyRating: json['safety_rating'] as int? ?? 5,
      visibilityLevel: json['visibility_level'] as String? ?? 'circle',
      createdAt: DateTime.parse(json['created_at'] as String),
      voucherName: json['voucher_name'] as String?,
      proName: json['pro_name'] as String?,
      proCategory: json['pro_category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pro_id': proId,
      'price_paid_encrypted': pricePaidEncrypted,
      'note': note,
      'safety_rating': safetyRating,
      'visibility_level': visibilityLevel,
      'created_at': createdAt.toIso8601String(),
    };
  }

  VouchModel copyWith({
    String? id,
    String? userId,
    String? proId,
    String? pricePaidEncrypted,
    String? note,
    int? safetyRating,
    String? visibilityLevel,
    DateTime? createdAt,
    String? voucherName,
    String? proName,
    String? proCategory,
  }) {
    return VouchModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      proId: proId ?? this.proId,
      pricePaidEncrypted: pricePaidEncrypted ?? this.pricePaidEncrypted,
      note: note ?? this.note,
      safetyRating: safetyRating ?? this.safetyRating,
      visibilityLevel: visibilityLevel ?? this.visibilityLevel,
      createdAt: createdAt ?? this.createdAt,
      voucherName: voucherName ?? this.voucherName,
      proName: proName ?? this.proName,
      proCategory: proCategory ?? this.proCategory,
    );
  }
}
