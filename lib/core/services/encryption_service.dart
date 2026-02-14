import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AES-256 encryption service for sensitive data (e.g., price_paid).
/// Keys are stored in the device keychain via Flutter Secure Storage.
class EncryptionService {
  static const String _keyStorageKey = 'vouch_encryption_key';
  static const String _ivStorageKey = 'vouch_encryption_iv';

  final FlutterSecureStorage _secureStorage;
  encrypt_lib.Key? _key;
  encrypt_lib.IV? _iv;

  EncryptionService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Initializes the encryption service, generating or retrieving keys.
  Future<void> initialize() async {
    final storedKey = await _secureStorage.read(key: _keyStorageKey);
    final storedIv = await _secureStorage.read(key: _ivStorageKey);

    if (storedKey != null && storedIv != null) {
      _key = encrypt_lib.Key.fromBase64(storedKey);
      _iv = encrypt_lib.IV.fromBase64(storedIv);
    } else {
      _key = encrypt_lib.Key.fromSecureRandom(32);
      _iv = encrypt_lib.IV.fromSecureRandom(16);
      await _secureStorage.write(
        key: _keyStorageKey,
        value: _key!.base64,
      );
      await _secureStorage.write(
        key: _ivStorageKey,
        value: _iv!.base64,
      );
    }
  }

  /// Encrypts a plaintext string using AES-256-CBC.
  String encryptData(String plaintext) {
    _ensureInitialized();
    final encrypter = encrypt_lib.Encrypter(
      encrypt_lib.AES(_key!, mode: encrypt_lib.AESMode.cbc),
    );
    final encrypted = encrypter.encrypt(plaintext, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypts an AES-256-CBC encrypted string.
  String decryptData(String encryptedBase64) {
    _ensureInitialized();
    final encrypter = encrypt_lib.Encrypter(
      encrypt_lib.AES(_key!, mode: encrypt_lib.AESMode.cbc),
    );
    final decrypted = encrypter.decrypt64(encryptedBase64, iv: _iv);
    return decrypted;
  }

  /// Encrypts a price value for storage.
  String encryptPrice(double price) {
    return encryptData(price.toStringAsFixed(2));
  }

  /// Decrypts a price value. Returns null if decryption fails.
  double? decryptPrice(String encryptedPrice) {
    try {
      final decrypted = decryptData(encryptedPrice);
      return double.tryParse(decrypted);
    } catch (_) {
      return null;
    }
  }

  void _ensureInitialized() {
    if (_key == null || _iv == null) {
      throw StateError(
        'EncryptionService not initialized. Call initialize() first.',
      );
    }
  }
}
