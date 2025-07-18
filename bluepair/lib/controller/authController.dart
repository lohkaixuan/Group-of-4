import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../api/apis.dart';
import '../storage/storage.dart';
import '../api/models.dart';

class AuthController extends GetxController {
  final Storage storage = Storage();
  final ApiService api = ApiService();

  var isLoading = false.obs;
  var isEmailLogin = true.obs;

  File? icPhoto;
  File? ssmCertificate;

  /// 📷 Pick IC photo (images only)
  Future<void> pickIcPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      icPhoto = File(picked.path);
      update();
      Get.snackbar('Selected', 'IC photo selected');
    } else {
      Get.snackbar('Cancelled', 'No IC photo selected');
    }
  }

  /// 📄 Pick SSM certificate (PDF only)
  Future<void> pickSsmCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      ssmCertificate = File(result.files.first.path!);
      update();
      Get.snackbar('Selected', 'SSM certificate selected');
    } else {
      Get.snackbar('Cancelled', 'No SSM file selected');
    }
  }

  /// 👤 Register user
  Future<void> registerUser({
    required String name,
    required String email,
    required String phone,
    required String icNumber,
    required String pin,
  }) async {
    if (icPhoto == null) {
      Get.snackbar("Error", "IC photo is required");
      return;
    }

    isLoading.value = true;
    try {
      await storage.clearAll();

      User user = await api.registerUser(
        name: name,
        email: email,
        phone: phone,
        pin: pin,
        icNumber: icNumber,
        icPhoto: icPhoto!,
      );

      await storage.saveUserDetails(user.toJson());
      Get.snackbar('Success', 'User registered');
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🏪 Register merchant
  Future<void> registerMerchant({
    required String name,
    required String email,
    required String phone,
    required String icNumber,
    required String pin,
    required String businessName, // ✅ added
    required String businessType, // ✅ added
    required String categoryService, // ✅ added
  }) async {
    if (icPhoto == null) {
      Get.snackbar("Error", "IC photo is required");
      return;
    }
    if (ssmCertificate == null) {
      Get.snackbar("Error", "SSM certificate is required");
      return;
    }

    isLoading.value = true;
    try {
      User user = await api.registerMerchant(
        name: name,
        email: email,
        phone: phone,
        pin: pin,
        icNumber: icNumber,
        icPhoto: icPhoto!,
        ssmCertificate: ssmCertificate!,
        businessName: businessName, // ✅ pass business name
        businessType: businessType, // ✅ pass business type
        categoryService: categoryService, // ✅ pass category service
      );

      await storage.saveUserDetails(user.toJson());
      Get.snackbar('Success', 'Merchant registration sent for approval');
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔑 Login
  Future<void> login({
    String? email,
    String? phone,
    required String pin,
  }) async {
    isLoading.value = true;
    try {
      await storage.clearAll();

      final response = await api.login(
        email: isEmailLogin.value ? email : null,
        phone: isEmailLogin.value ? null : phone,
        pin: pin,
      );

      final token = response['token'];
      final user = response['user'];

      await storage.saveAuthToken(token);
      await storage.saveUserDetails(user);

      Get.snackbar('Success', 'Login successful');
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🚪 Logout
  Future<void> logout() async {
    await storage.clearAll();
    Get.offAllNamed('/login');
  }

  /// ✅ Check token existence (used in SplashScreen)
  Future<bool> checkToken() async {
    try {
      final token = await storage.getAuthToken();
      // You can add extra logic here like validating expiry if needed
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
