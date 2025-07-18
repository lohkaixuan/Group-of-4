import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/controller/authController.dart';
import 'package:bluepair/controller/langaugeController.dart';
import 'package:bluepair/widgets/common_appbar.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final auth = Get.find<AuthController>();
  final lang = Get.find<LanguageController>();

  // ✅ All fields with embedded controllers
  final List<Map<String, dynamic>> fields = [
    {
      'label_en': 'Email',
      'label_bm': 'Emel',
      'icon': Icons.email,
      'keyboard': TextInputType.emailAddress,
      'controller': TextEditingController()
    },
    {
      'label_en': 'Phone Number',
      'label_bm': 'Nombor Telefon',
      'icon': Icons.phone,
      'keyboard': TextInputType.number,
      'controller': TextEditingController()
    },
    {
      'label_en': '6-Digit PIN',
      'label_bm': 'PIN 6-Digit',
      'icon': Icons.lock,
      'keyboard': TextInputType.number,
      'controller': TextEditingController(),
      'maxLength': 6,
      'obscure': true
    },
  ];

  void _handleLogin() {
    final email = fields[0]['controller'].text.trim();
    final phone = fields[1]['controller'].text.trim();
    final pin = fields[2]['controller'].text.trim();

    if (auth.isEmailLogin.value) {
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        Get.snackbar('Error', lang.t("Please enter a valid email", "Sila masukkan emel yang sah"));
        return;
      }
    } else {
      if (!RegExp(r'^[0-9]+$').hasMatch(phone) || phone.isEmpty) {
        Get.snackbar('Error', lang.t("Phone number must contain digits only", "Nombor telefon mesti angka sahaja"));
        return;
      }
    }

    if (pin.length != 6 || int.tryParse(pin) == null) {
      Get.snackbar('Error', lang.t("PIN must be exactly 6 digits", "PIN mesti tepat 6 digit"));
      return;
    }

    auth.login(
      email: auth.isEmailLogin.value ? email : null,
      phone: auth.isEmailLogin.value ? null : phone,
      pin: pin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  buildCommonAppBar("Login", "Log Masuk"),
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Obx(() {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lang.t("BluePair", "BluePair"),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 🔄 Toggle between email and phone
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: Text(lang.t("Email", "Emel")),
                            selected: auth.isEmailLogin.value,
                            onSelected: (_) => auth.isEmailLogin.value = true,
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text(lang.t("Phone", "Telefon")),
                            selected: !auth.isEmailLogin.value,
                            onSelected: (_) => auth.isEmailLogin.value = false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 📋 Build fields dynamically
                      ...(auth.isEmailLogin.value ? [fields[0]] : [fields[1]]).map((f) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextField(
                            key: UniqueKey(), // ✅ Force rebuild on toggle
                            controller: f['controller'] as TextEditingController,
                            keyboardType: f['keyboard'] as TextInputType,
                            decoration: InputDecoration(
                              labelText: lang.t(f['label_en'], f['label_bm']),
                              prefixIcon: Icon(f['icon'] as IconData),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        );
                      }).toList(),

                      // PIN field
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TextField(
                          controller: fields[2]['controller'] as TextEditingController,
                          keyboardType: fields[2]['keyboard'] as TextInputType,
                          obscureText: fields[2]['obscure'] as bool,
                          maxLength: fields[2]['maxLength'] as int,
                          decoration: InputDecoration(
                            labelText: lang.t(fields[2]['label_en'], fields[2]['label_bm']),
                            prefixIcon: Icon(fields[2]['icon'] as IconData),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            counterText: "",
                          ),
                        ),
                      ),

                      // 🔑 Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: auth.isLoading.value ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: auth.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  lang.t("Login", "Log Masuk"),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🌐 Register navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () => Get.toNamed('/register'),
                            child: Text(
                              lang.t("Register User", "Daftar Pengguna"),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed('/register_merchant'),
                            child: Text(
                              lang.t("Register Merchant", "Daftar Peniaga"),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
