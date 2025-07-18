import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;

class CryptoHelper {
  // ✅ 32-char AES key (must be kept secret!)
  static const _keyString = '12345678901234567890123456789012'; // Replace with your own secure key
  static final _key = enc.Key.fromUtf8(_keyString);
  static final _iv = enc.IV.fromLength(16);

  /// 🔐 Encrypt data with AES
  static String encryptData(String plainText) {
    final encrypter = enc.Encrypter(enc.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// 🔓 Decrypt AES data
  static String decryptData(String encryptedText) {
    final encrypter = enc.Encrypter(enc.AES(_key));
    return encrypter.decrypt(enc.Encrypted.fromBase64(encryptedText), iv: _iv);
  }

  /// ✍️ Simulated signing
  static String signData(String data) {
    // For production, use RSA private key
    return base64Encode(utf8.encode("signed:$data"));
  }

  /// #️⃣ Simulated hashing
  static String hashData(String data) {
    // For production, use SHA256 or similar
    return base64Encode(utf8.encode("hashed:$data"));
  }
}
