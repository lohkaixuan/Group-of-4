import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  final _storage = const FlutterSecureStorage();

  // 🔑 Token
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // 👤 User details (also save id separately for convenience)
  Future<void> saveUserDetails(Map<String, dynamic> userJson) async {
    await _storage.write(key: 'user_details', value: jsonEncode(userJson));

    // ✅ also store user id for quick lookup
    if (userJson['id'] != null) {
      await _storage.write(key: 'user_id', value: userJson['id'].toString());
    }

    // ✅ if wallet IDs are in user JSON, store them as well
    if (userJson['personal_wallet_id'] != null) {
      await _storage.write(
          key: 'personal_wallet_id', value: userJson['personal_wallet_id'].toString());
    }
    if (userJson['merchant_wallet_id'] != null) {
      await _storage.write(
          key: 'merchant_wallet_id', value: userJson['merchant_wallet_id'].toString());
    }
  }

  Future<Map<String, dynamic>?> getUserDetails() async {
    final jsonStr = await _storage.read(key: 'user_details');
    if (jsonStr == null) return null;
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  Future<String?> getPersonalWalletId() async {
    return await _storage.read(key: 'personal_wallet_id');
  }

  Future<String?> getMerchantWalletId() async {
    return await _storage.read(key: 'merchant_wallet_id');
  }

  // ✅ Save wallet info separately for personal and merchant
  Future<void> saveWalletInfo(Map<String, dynamic> walletJson, String type) async {
    // type should be 'personal' or 'merchant'
    await _storage.write(key: 'wallet_info_$type', value: jsonEncode(walletJson));

    // ✅ also store wallet_id separately
    if (walletJson['id'] != null) {
      await _storage.write(
        key: '${type}_wallet_id',
        value: walletJson['id'].toString(),
      );
    }
  }

  Future<Map<String, dynamic>?> getWalletInfo(String type) async {
    final jsonStr = await _storage.read(key: 'wallet_info_$type');
    if (jsonStr == null) return null;
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  // 💾 Save transactions
  Future<void> saveTransactions(List<Map<String, dynamic>> txList) async {
    await _storage.write(key: 'transactions', value: jsonEncode(txList));
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final jsonStr = await _storage.read(key: 'transactions');
    if (jsonStr == null) return [];
    final decoded = jsonDecode(jsonStr);
    return List<Map<String, dynamic>>.from(decoded);
  }

  // 🧹 Clear all
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ✅ Update specific wallet balance
  Future<void> updateWalletBalance(String type, double change) async {
    final wallet = await getWalletInfo(type);
    if (wallet == null) return;

    double currentBalance = (wallet['balance'] as num).toDouble();
    double newBalance = currentBalance + change;
    wallet['balance'] = newBalance;

    await saveWalletInfo(wallet, type);
  }
}
