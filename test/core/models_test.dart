import 'package:flutter_test/flutter_test.dart';
import 'package:vouch_app/core/models/user_model.dart';
import 'package:vouch_app/core/models/pro_model.dart';
import 'package:vouch_app/core/models/vouch_model.dart';
import 'package:vouch_app/core/models/circle_model.dart';
import 'package:vouch_app/core/models/alert_model.dart';
import 'package:vouch_app/core/models/pro_lead_model.dart';

void main() {
  group('UserModel', () {
    test('should create from JSON', () {
      final json = {
        'id': '123',
        'email': 'test@test.com',
        'phone_hash': 'a' * 64,
        'trust_score': 4.5,
        'zip_code': '90210',
        'display_name': 'John',
        'avatar_url': null,
        'created_at': '2025-01-01T00:00:00.000Z',
        'updated_at': '2025-01-01T00:00:00.000Z',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, '123');
      expect(user.email, 'test@test.com');
      expect(user.trustScore, 4.5);
      expect(user.zipCode, '90210');
      expect(user.displayName, 'John');
    });

    test('should serialize to JSON', () {
      final user = UserModel(
        id: '123',
        phoneHash: 'hash123',
        trustScore: 3.0,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final json = user.toJson();
      expect(json['id'], '123');
      expect(json['phone_hash'], 'hash123');
      expect(json['trust_score'], 3.0);
    });

    test('copyWith should create a new instance with updated fields', () {
      final user = UserModel(
        id: '123',
        phoneHash: 'hash123',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final updated = user.copyWith(displayName: 'Jane', trustScore: 5.0);
      expect(updated.displayName, 'Jane');
      expect(updated.trustScore, 5.0);
      expect(updated.id, '123');
    });
  });

  group('ProModel', () {
    test('should create from JSON', () {
      final json = {
        'id': 'pro-1',
        'business_name': 'Joe\'s Plumbing',
        'category': 'Plumber',
        'avg_vouch_score': 4.8,
        'is_claimed': true,
        'created_at': '2025-01-01T00:00:00.000Z',
      };

      final pro = ProModel.fromJson(json);
      expect(pro.businessName, 'Joe\'s Plumbing');
      expect(pro.category, 'Plumber');
      expect(pro.avgVouchScore, 4.8);
      expect(pro.isClaimed, true);
    });

    test('should handle defaults', () {
      final json = {
        'id': 'pro-1',
        'business_name': 'Test',
        'category': 'Other',
        'created_at': '2025-01-01T00:00:00.000Z',
      };

      final pro = ProModel.fromJson(json);
      expect(pro.avgVouchScore, 0.0);
      expect(pro.isClaimed, false);
      expect(pro.photoGallery, isEmpty);
    });
  });

  group('VouchModel', () {
    test('should create from JSON', () {
      final json = {
        'id': 'vouch-1',
        'user_id': 'user-1',
        'pro_id': 'pro-1',
        'safety_rating': 4,
        'visibility_level': 'circle',
        'note': 'Great service',
        'created_at': '2025-01-01T00:00:00.000Z',
      };

      final vouch = VouchModel.fromJson(json);
      expect(vouch.safetyRating, 4);
      expect(vouch.visibilityLevel, 'circle');
      expect(vouch.note, 'Great service');
    });
  });

  group('CircleModel', () {
    test('should create from JSON', () {
      final json = {
        'id': 'circle-1',
        'user_a_id': 'user-1',
        'user_b_id': 'user-2',
        'status': 'active',
        'created_at': '2025-01-01T00:00:00.000Z',
      };

      final circle = CircleModel.fromJson(json);
      expect(circle.status, 'active');
      expect(circle.userAId, 'user-1');
      expect(circle.userBId, 'user-2');
    });
  });

  group('AlertModel', () {
    test('should create from JSON', () {
      final json = {
        'id': 'alert-1',
        'reported_by': 'user-1',
        'pro_id': 'pro-1',
        'alert_type': 'scam',
        'description': 'Overcharged by 200%',
        'latitude': 34.0522,
        'longitude': -118.2437,
        'created_at': '2025-01-01T00:00:00.000Z',
      };

      final alert = AlertModel.fromJson(json);
      expect(alert.alertType, 'scam');
      expect(alert.latitude, 34.0522);
    });
  });

  group('ProLeadModel', () {
    test('should create from JSON', () {
      final json = {
        'id': 'lead-1',
        'pro_id': 'pro-1',
        'seeker_id': 'user-1',
        'status': 'new',
        'created_at': '2025-01-01T00:00:00.000Z',
      };

      final lead = ProLeadModel.fromJson(json);
      expect(lead.status, 'new');
      expect(lead.proId, 'pro-1');
    });
  });
}
