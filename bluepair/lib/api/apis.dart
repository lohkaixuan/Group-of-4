// lib/services/apis.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'models.dart';

class ApiService {
  final Dio _dio = DioClient().dio; // ✅ Create an instance and access dio

  // ---------------- AUTH ----------------

  Future<User> registerUser({
    required String name,
    required String email,
    required String phone,
    required String pin,
    required String icNumber,
    required File icPhoto,
  }) async {
    FormData formData = FormData.fromMap({
      'name': name,
      'email': email,
      'phone': phone,
      'pin': pin,
      'ic_number': icNumber,
      'ic_photo': await MultipartFile.fromFile(icPhoto.path),
    });

    final response = await _dio.post('/auth/register', data: formData);
    return User.fromJson(response.data['user']);
  }

  Future<User> registerMerchant({
    required String name,
    required String email,
    required String phone,
    required String pin,
    required String icNumber,
    required File icPhoto,
    required File ssmCertificate,
    required String businessName,
    required String businessType, // ✅ new
    required String categoryService, // ✅ new
  }) async {
    FormData formData = FormData.fromMap({
      'name': name,
      'email': email,
      'phone': phone,
      'pin': pin,
      'ic_number': icNumber,
      'ic_photo': await MultipartFile.fromFile(icPhoto.path),
      'ssm_certificate': await MultipartFile.fromFile(ssmCertificate.path),
      'business_name': businessName,
      'business_type': businessType, // ✅ added
      'category_service': categoryService, // ✅ added
    });

    final response = await _dio.post('/auth/register-merchant', data: formData);
    return User.fromJson(response.data['user']);
  }

  Future<Map<String, dynamic>> login(
      {String? email, String? phone, required String pin}) async {
    final data = {
      'pin': pin,
    };

    if (email != null && email.isNotEmpty) {
      data['email'] = email;
    } else if (phone != null && phone.isNotEmpty) {
      data['phone'] = phone;
    }

    final response = await _dio.post('/auth/login', data: data);
    return response.data; // includes token and user info
  }

  // ---------------- WALLET ----------------

  Future<List<Wallet>> getWallets(String userId) async {
    final response =
        await _dio.get('/wallet/', queryParameters: {'userId': userId});
    List wallets = response.data;
    return wallets.map((e) => Wallet.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> topUpWallet(
      String userId, String walletId, double amount) async {
    final response = await _dio.post('/wallet/topup', data: {
      'userId': userId,
      'walletId': walletId,
      'amount': amount,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getTopUpHistory(String userId) async {
    final response = await _dio.get('/wallet/history', queryParameters: {
      'userId': userId,
    });
    List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ---------------- TRANSACTION ----------------

  Future<Transaction> createTransaction(
      String buyerId, String sellerId, double amount) async {
    final response = await _dio.post('/transaction', data: {
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'amount': amount,
    });
    return Transaction.fromJson(response.data['transaction']);
  }

  Future<Transaction> confirmTransaction(String transactionId) async {
    final response = await _dio.post('/transaction/confirm', data: {
      'transaction_id': transactionId,
    });
    return Transaction.fromJson(response.data['transaction']);
  }

  // ---------------- ADMIN ----------------

  Future<Map<String, dynamic>> approveMerchant(String merchantId) async {
    final response = await _dio.post('/admin/approve-merchant', data: {
      'merchantId': merchantId,
    });
    return response.data;
  }
}
