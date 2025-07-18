import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

/// Encrypts a plaintext string using a hardcoded RSA public key (modulus + exponent).
Future<String> encryptWithManualKey(String plaintext) async {
  // 🔹 Modulus from your certificate (copy from your dump and remove colons/spaces)
  final modulusHex = '00acbacb376dbb7e842c3d6a102fff28bba8be96bbd81211bb506d3820a4f877b49b2121ad2a0b339b76552b5a12eb2fa792eba556ce6b65846072c377939418c60d4761961f11a794498ce953e08e053ef7b2fad485d4fe0ec09cf1dd06e304795fab142dbae32e3c590ee0e0a59b0d235e0128805f64dd75a9ec133752087411f95b92ff8e9dd9aededdf3e293678781c9a2dd5a2ddcd27198b5869cf91763d95a478cb4035191272d47322f62d3e41959079e6f2b25577dca4df4758e1d1382bc51ff39ed75b29d8fcb5febf48499ffac56832c0c0abbde87fc8217c6db6bbb5f2d40f35464c3eaa4c0b38a40fd41d629032605592bd1341e469469f410789';

  // ✅ Remove leading `00` if present (often present in modulus)
  final cleanHex = modulusHex.startsWith('00') ? modulusHex.substring(2) : modulusHex;

  // ✅ Convert hex string to BigInt
  final modulus = BigInt.parse(cleanHex, radix: 16);

  // ✅ RSA exponent (from your cert: 65537 = 0x10001)
  final exponent = BigInt.from(65537);

  // ✅ Create RSAPublicKey
  final rsaPublicKey = RSAPublicKey(modulus, exponent);

  // ✅ Set up RSA with OAEP padding
  final engine = OAEPEncoding(RSAEngine())
    ..init(
      true, // true = encryption
      PublicKeyParameter<RSAPublicKey>(rsaPublicKey),
    );

  // ✅ Convert plaintext to bytes
  final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));

  // RSA key (2048 bits) can encrypt up to ~200 bytes with OAEP
  if (plaintextBytes.length > 200) {
    throw Exception('Plaintext too long for direct RSA encryption.');
  }

  // ✅ Encrypt
  final cipherBytes = engine.process(plaintextBytes);

  // ✅ Return Base64 encoded ciphertext
  return base64Encode(cipherBytes);
}
