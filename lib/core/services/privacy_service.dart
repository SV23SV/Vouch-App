import 'dart:convert';

import 'package:crypto/crypto.dart';
import '../config/env_config.dart';

/// Thrown when raw PII (unhashed phone number) is detected in outbound data.
class SecurityException implements Exception {
  final String message;
  const SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}

/// Service responsible for all privacy-related operations.
/// Ensures no raw PII ever leaves the device.
class PrivacyService {
  final String _salt;

  // Regex to detect phone numbers (various formats)
  static final RegExp _phonePattern = RegExp(
    r'(?:\+?1[-.\s]?)?\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}',
  );

  PrivacyService({String? salt}) : _salt = salt ?? EnvConfig.phoneHashSalt;

  /// Hashes a phone number using SHA-256 with salt.
  /// Normalizes the phone number first (strips non-digits, ensures country code).
  String hashContact(String phone) {
    final normalized = _normalizePhone(phone);
    final bytes = utf8.encode('$normalized$_salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Hashes a list of phone numbers for batch contact matching.
  List<String> hashContacts(List<String> phones) {
    return phones.map(hashContact).toList();
  }

  /// Normalizes a phone number to a consistent format.
  /// Strips all non-digit characters and ensures US country code.
  String _normalizePhone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length == 10) {
      return '1$digitsOnly';
    }
    if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
      return digitsOnly;
    }
    return digitsOnly;
  }

  /// Inspects a payload for raw phone numbers and throws SecurityException
  /// if any are detected. Used as a guard before any outbound API calls.
  void inspectPayload(dynamic payload) {
    final jsonString = jsonEncode(payload);
    if (_phonePattern.hasMatch(jsonString)) {
      throw const SecurityException(
        'Raw phone number detected in outbound payload. '
        'All phone numbers must be hashed before transmission.',
      );
    }
  }

  /// Validates that a string looks like a SHA-256 hash (64 hex characters).
  bool isValidHash(String value) {
    return RegExp(r'^[a-f0-9]{64}$').hasMatch(value);
  }
}
