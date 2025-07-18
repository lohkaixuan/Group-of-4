import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  // 🔑 Save auth token
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // 🔑 Get auth token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 👤 Save user details (id, name, email, phone, role)
  Future<void> saveUserDetails(Map<String, dynamic> userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_details', jsonEncode(userJson));
  }

  // 👤 Get user details
  Future<Map<String, dynamic>?> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('user_details');
    if (jsonStr == null) return null;
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  // 👛 Save wallet info (id, type, balance)
  Future<void> saveWalletInfo(Map<String, dynamic> walletJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallet_info', jsonEncode(walletJson));
  }

  // 👛 Get wallet info
  Future<Map<String, dynamic>?> getWalletInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('wallet_info');
    if (jsonStr == null) return null;
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  // 🧹 Clear all storage (e.g., on logout)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
