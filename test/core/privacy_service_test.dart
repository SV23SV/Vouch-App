import 'package:flutter_test/flutter_test.dart';
import 'package:vouch_app/core/services/privacy_service.dart';

void main() {
  late PrivacyService privacyService;

  setUp(() {
    privacyService = PrivacyService(salt: 'test-salt-12345');
  });

  group('PrivacyService', () {
    group('hashContact', () {
      test('should produce consistent hashes for the same phone number', () {
        const phone = '+15551234567';
        final hash1 = privacyService.hashContact(phone);
        final hash2 = privacyService.hashContact(phone);
        expect(hash1, equals(hash2));
      });

      test('should produce a 64-character hex string (SHA-256)', () {
        final hash = privacyService.hashContact('+15551234567');
        expect(hash.length, equals(64));
        expect(RegExp(r'^[a-f0-9]{64}$').hasMatch(hash), isTrue);
      });

      test('should produce different hashes for different phone numbers', () {
        final hash1 = privacyService.hashContact('+15551234567');
        final hash2 = privacyService.hashContact('+15559876543');
        expect(hash1, isNot(equals(hash2)));
      });

      test('should normalize phone number formats to same hash', () {
        final hash1 = privacyService.hashContact('+15551234567');
        final hash2 = privacyService.hashContact('(555) 123-4567');
        final hash3 = privacyService.hashContact('555-123-4567');
        final hash4 = privacyService.hashContact('5551234567');

        expect(hash1, equals(hash2));
        expect(hash2, equals(hash3));
        expect(hash3, equals(hash4));
      });

      test('should handle phone numbers with country code', () {
        final hash1 = privacyService.hashContact('15551234567');
        final hash2 = privacyService.hashContact('+15551234567');

        expect(hash1, equals(hash2));
      });
    });

    group('hashContacts', () {
      test('should hash a list of phone numbers', () {
        final hashes = privacyService.hashContacts([
          '+15551234567',
          '+15559876543',
        ]);

        expect(hashes.length, equals(2));
        expect(hashes[0], isNot(equals(hashes[1])));
        expect(hashes[0].length, equals(64));
        expect(hashes[1].length, equals(64));
      });

      test('should return empty list for empty input', () {
        final hashes = privacyService.hashContacts([]);
        expect(hashes, isEmpty);
      });
    });

    group('inspectPayload', () {
      test('should throw SecurityException when raw phone number is detected',
          () {
        final payload = {
          'name': 'John',
          'phone': '555-123-4567',
        };

        expect(
          () => privacyService.inspectPayload(payload),
          throwsA(isA<SecurityException>()),
        );
      });

      test('should throw SecurityException for phone with parentheses format',
          () {
        final payload = {
          'contact': '(555) 123-4567',
        };

        expect(
          () => privacyService.inspectPayload(payload),
          throwsA(isA<SecurityException>()),
        );
      });

      test('should not throw for hashed data', () {
        final hash = privacyService.hashContact('+15551234567');
        final payload = {
          'phone_hash': hash,
          'name': 'John',
        };

        expect(
          () => privacyService.inspectPayload(payload),
          returnsNormally,
        );
      });

      test('should not throw for normal data without phone numbers', () {
        final payload = {
          'name': 'John Doe',
          'category': 'Plumber',
          'rating': 5,
        };

        expect(
          () => privacyService.inspectPayload(payload),
          returnsNormally,
        );
      });
    });

    group('isValidHash', () {
      test('should return true for valid SHA-256 hash', () {
        final hash = privacyService.hashContact('+15551234567');
        expect(privacyService.isValidHash(hash), isTrue);
      });

      test('should return false for non-hash strings', () {
        expect(privacyService.isValidHash('not-a-hash'), isFalse);
        expect(privacyService.isValidHash('12345'), isFalse);
        expect(privacyService.isValidHash(''), isFalse);
      });

      test('should return false for uppercase hex', () {
        expect(
          privacyService.isValidHash('A' * 64),
          isFalse,
        );
      });
    });

    group('different salts produce different hashes', () {
      test('same phone with different salts should produce different hashes',
          () {
        final service1 = PrivacyService(salt: 'salt-one');
        final service2 = PrivacyService(salt: 'salt-two');

        final hash1 = service1.hashContact('+15551234567');
        final hash2 = service2.hashContact('+15551234567');

        expect(hash1, isNot(equals(hash2)));
      });
    });
  });
}
