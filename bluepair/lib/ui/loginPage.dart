import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/controller/authController.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final auth = Get.find<AuthController>();

  // ✅ All fields with embedded controllers
  final List<Map<String, dynamic>> fields = [
    {'label': 'Email', 'icon': Icons.email, 'keyboard': TextInputType.emailAddress, 'controller': TextEditingController()},
    {'label': 'Phone Number', 'icon': Icons.phone, 'keyboard': TextInputType.phone, 'controller': TextEditingController()},
    {'label': '6-Digit PIN', 'icon': Icons.lock, 'keyboard': TextInputType.number, 'controller': TextEditingController(), 'maxLength': 6, 'obscure': true},
  ];

  void _handleLogin() {
    final email = fields[0]['controller'].text.trim();
    final phone = fields[1]['controller'].text.trim();
    final pin = fields[2]['controller'].text.trim();

    if (auth.isEmailLogin.value) {
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        Get.snackbar('Error', 'Please enter a valid email');
        return;
      }
    } else {
      if (!RegExp(r'^[0-9]+$').hasMatch(phone) || phone.isEmpty) {
        Get.snackbar('Error', 'Phone number must contain digits only');
        return;
      }
    }

    if (pin.length != 6 || int.tryParse(pin) == null) {
      Get.snackbar('Error', 'PIN must be exactly 6 digits');
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
                      const Text(
                        'Login',
                        style: TextStyle(
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
                            label: const Text('Email'),
                            selected: auth.isEmailLogin.value,
                            onSelected: (_) => auth.isEmailLogin.value = true,
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Phone'),
                            selected: !auth.isEmailLogin.value,
                            onSelected: (_) => auth.isEmailLogin.value = false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 📋 Build fields dynamically
                      // Show email field if isEmailLogin, else show phone field
                      ...(auth.isEmailLogin.value
                              ? [fields[0]]
                              : [fields[1]])
                          .map((f) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextField(
                            controller: f['controller'] as TextEditingController,
                            keyboardType: f['keyboard'] as TextInputType,
                            decoration: InputDecoration(
                              labelText: f['label'] as String,
                              prefixIcon: Icon(f['icon'] as IconData),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        );
                      }).toList(),

                      // PIN field (always visible)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TextField(
                          controller: fields[2]['controller'] as TextEditingController,
                          keyboardType: fields[2]['keyboard'] as TextInputType,
                          obscureText: fields[2]['obscure'] as bool,
                          maxLength: fields[2]['maxLength'] as int,
                          decoration: InputDecoration(
                            labelText: fields[2]['label'] as String,
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
                              : const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🌐 Register navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () => Get.toNamed('/register'),
                            child: const Text(
                              'Register User',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed('/register_merchant'),
                            child: const Text(
                              'Register Merchant',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
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
