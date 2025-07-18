import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bluepair/api/apis.dart';
import 'package:bluepair/api/models.dart';
import 'package:bluepair/storage/storage.dart';

class AuthController extends GetxController {
  final Storage storage = Storage();
  final ApiService api = ApiService();

  // ✅ Reactive user info
  RxString name = ''.obs;
  RxString email = ''.obs;
  RxString role = ''.obs;      // user / merchant
  RxString status = ''.obs;    // merchant status
  RxString token = ''.obs;     // JWT token

  // ✅ UI states
  RxBool isLoading = false.obs;
  RxBool isEmailLogin = true.obs;

  // ✅ Picked files
  File? icPhoto;
  File? ssmCertificate;

  // ✅ Init load
  @override
  void onInit() {
    super.onInit();
    loadUserFromStorage();
  }

  // 📥 Load from storage
  Future<void> loadUserFromStorage() async {
    final user = await storage.getUserDetails();
    if (user != null) {
      name.value = user['name'] ?? '';
      email.value = user['email'] ?? '';
      role.value = user['role'] ?? '';
      status.value = user['status'] ?? '';
    }
    final t = await storage.getAuthToken();
    if (t != null) token.value = t;
  }

  // 📦 Save user and token
  Future<void> saveUser(Map<String, dynamic> user, String? authToken) async {
    await storage.saveUserDetails(user);
    if (authToken != null) {
      await storage.saveAuthToken(authToken);
      token.value = authToken;
    }
    name.value = user['name'] ?? '';
    email.value = user['email'] ?? '';
    role.value = user['role'] ?? '';
    status.value = user['status'] ?? '';
  }

  // 📷 Pick IC photo
  Future<void> pickIcPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      icPhoto = File(picked.path);
      Get.snackbar('Selected', 'IC photo selected');
    } else {
      Get.snackbar('Cancelled', 'No IC photo selected');
    }
  }

  // 📄 Pick SSM certificate
  Future<void> pickSsmCertificate() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.isNotEmpty) {
      ssmCertificate = File(result.files.first.path!);
      Get.snackbar('Selected', 'SSM certificate selected');
    } else {
      Get.snackbar('Cancelled', 'No SSM file selected');
    }
  }

  // 🧑‍💻 Register User
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
          icNumber: icNumber,
          pin: pin,
          icPhoto: icPhoto!,
      );
      await saveUser(user.toJson(), null);
      Get.snackbar('Success', 'User registered');
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // 🏪 Register Merchant
  Future<void> registerMerchant({
    required String name,
    required String email,
    required String phone,
    required String icNumber,
    required String pin,
    required String businessName,
    required String businessType,
    required String categoryService,
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
        icNumber: icNumber,
        pin: pin,
        icPhoto: icPhoto!,
        ssmCertificate: ssmCertificate!,
        businessName: businessName,
        businessType: businessType,
        categoryService: categoryService,
      );
      await saveUser(user.toJson(), null);
      Get.snackbar('Success', 'Merchant registration sent for approval');
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // 🔑 Login
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
      final tokenStr = response['token'];
      final user = response['user'];
      await saveUser(user, tokenStr);
      Get.snackbar('Success', 'Login successful');
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // 🚪 Logout
  Future<void> logout() async {
    await storage.clearAll();
    name.value = '';
    email.value = '';
    role.value = '';
    status.value = '';
    token.value = '';
    Get.offAllNamed('/login');
  }

  // ✅ Check token in storage
  Future<bool> checkToken() async {
    final t = await storage.getAuthToken();
    return t != null && t.isNotEmpty;
  }
}
