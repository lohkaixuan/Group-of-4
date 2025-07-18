import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/controller/authController.dart';
import 'package:bluepair/controller/langaugeController.dart';
import 'package:bluepair/widgets/common_appbar.dart'; // ✅ your common app bar

class RegisterUserPage extends StatelessWidget {
  RegisterUserPage({Key? key}) : super(key: key);

  final auth = Get.find<AuthController>();
  final lang = Get.find<LanguageController>();

  // ✅ fields with both English and BM labels
  final List<Map<String, dynamic>> fields = [
    {'labelEn': 'Name', 'labelBm': 'Nama', 'icon': Icons.person, 'keyboard': TextInputType.text, 'controller': TextEditingController()},
    {'labelEn': 'Email', 'labelBm': 'Emel', 'icon': Icons.email, 'keyboard': TextInputType.emailAddress, 'controller': TextEditingController()},
    {'labelEn': 'Phone', 'labelBm': 'Telefon', 'icon': Icons.phone, 'keyboard': TextInputType.phone, 'controller': TextEditingController()},
    {'labelEn': 'IC Number', 'labelBm': 'Nombor IC', 'icon': Icons.badge, 'keyboard': TextInputType.text, 'controller': TextEditingController()},
    {'labelEn': '6-Digit PIN', 'labelBm': 'PIN 6-Digit', 'icon': Icons.lock, 'keyboard': TextInputType.number, 'controller': TextEditingController(), 'maxLength': 6, 'obscure': true},
  ];

  void _handleRegister() {
    final name = fields[0]['controller'].text.trim();
    final email = fields[1]['controller'].text.trim();
    final phone = fields[2]['controller'].text.trim();
    final ic = fields[3]['controller'].text.trim();
    final pin = fields[4]['controller'].text.trim();

    if ([name, email, phone, ic, pin].any((e) => e.isEmpty)) {
      Get.snackbar(lang.t('Error', 'Ralat'), lang.t('All fields are required', 'Semua medan diperlukan'));
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      Get.snackbar(lang.t('Error', 'Ralat'), lang.t('Invalid email', 'Emel tidak sah'));
      return;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      Get.snackbar(lang.t('Error', 'Ralat'), lang.t('Phone must be digits only', 'Telefon mesti nombor sahaja'));
      return;
    }
    if (pin.length != 6 || int.tryParse(pin) == null) {
      Get.snackbar(lang.t('Error', 'Ralat'), lang.t('PIN must be exactly 6 digits', 'PIN mestilah 6 digit'));
      return;
    }

    auth.registerUser(
      name: name,
      email: email,
      phone: phone,
      icNumber: ic,
      pin: pin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCommonAppBar("Register User", "Daftar Pengguna"),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔹 dynamically build all fields
              ...fields.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: f['controller'] as TextEditingController,
                    keyboardType: f['keyboard'] as TextInputType,
                    obscureText: (f['obscure'] as bool?) ?? false,
                    maxLength: (f['maxLength'] as int?) ?? null,
                    decoration: InputDecoration(
                      labelText: lang.t(f['labelEn'] as String, f['labelBm'] as String),
                      prefixIcon: Icon(f['icon'] as IconData),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      counterText: "",
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: auth.pickIcPhoto,
                child: Text(lang.t('Pick IC Photo', 'Pilih Gambar IC')),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: auth.isLoading.value ? null : _handleRegister,
                child: auth.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(lang.t('Register User', 'Daftar Pengguna')),
              ),
            ],
          ),
        );
      }),
    );
  }
}
