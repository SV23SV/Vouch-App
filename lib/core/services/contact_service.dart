import 'package:flutter_contacts/flutter_contacts.dart';
import 'privacy_service.dart';

/// Service for reading device contacts and hashing phone numbers.
class ContactService {
  final PrivacyService _privacyService;

  ContactService({PrivacyService? privacyService})
      : _privacyService = privacyService ?? PrivacyService();

  /// Requests contact permission and returns true if granted.
  Future<bool> requestPermission() async {
    return await FlutterContacts.requestPermission();
  }

  /// Reads all contacts and returns a map of hashed phone numbers to names.
  Future<Map<String, String>> getHashedContacts() async {
    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    final hashedContacts = <String, String>{};

    for (final contact in contacts) {
      for (final phone in contact.phones) {
        final hash = _privacyService.hashContact(phone.number);
        final name = contact.displayName.isNotEmpty
            ? contact.displayName
            : 'Unknown';
        hashedContacts[hash] = name;
      }
    }

    return hashedContacts;
  }

  /// Returns just the list of hashed phone numbers for matching.
  Future<List<String>> getHashedPhoneNumbers() async {
    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    final hashes = <String>[];
    for (final contact in contacts) {
      for (final phone in contact.phones) {
        hashes.add(_privacyService.hashContact(phone.number));
      }
    }

    return hashes;
  }
}
