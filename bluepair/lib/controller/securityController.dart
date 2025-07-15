import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart';

Future<String> encryptWithClientCert(String plaintext) async {
  // Load PEM certificate string
  String pemCert = await rootBundle.loadString('assets/client1.crt');

  // Parse certificate
  final certData = X509Utils.x509CertificateFromPem(pemCert);

  // Get modulus as hex string → convert to BigInt
  final modulusHex = certData.subjectPublicKeyInfo?.modulus;
  final exponentStr = certData.subjectPublicKeyInfo?.exponent;

  if (modulusHex == null || exponentStr == null) {
    throw Exception("Certificate does not contain public key info.");
  }

  // Remove any colons from modulus
  final cleanModulus = modulusHex.replaceAll(':', '');

  // Convert hex to BigInt
  final modulus = BigInt.parse(cleanModulus, radix: 16);

  // Convert exponent to BigInt
  final exponent = BigInt.parse(exponentStr);

  // Create the RSAPublicKey
  final publicKey = RSAPublicKey(modulus, exponent);

  // Create RSA engine with OAEP padding
  final encryptor = OAEPEncoding(RSAEngine())
    ..init(
      true, // true = encryption
      PublicKeyParameter<RSAPublicKey>(publicKey),
    );

  // Encrypt plaintext
  final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));
  final cipherBytes = encryptor.process(plaintextBytes);

  return base64Encode(cipherBytes);
}