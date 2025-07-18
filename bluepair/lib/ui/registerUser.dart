import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepaor/controller/authController.dart';

class RegisterUserPage extends StatelessWidget {
  RegisterUserPage({Key? key}) : super(key: key);

  final auth = Get.find<AuthController>();

  // ✅ All fields with their own controller in the same map
  final List<Map<String, dynamic>> fields = [
    {'label': 'Name', 'icon': Icons.person, 'keyboard': TextInputType.text, 'controller': TextEditingController()},
    {'label': 'Email', 'icon': Icons.email, 'keyboard': TextInputType.emailAddress, 'controller': TextEditingController()},
    {'label': 'Phone', 'icon': Icons.phone, 'keyboard': TextInputType.phone, 'controller': TextEditingController()},
    {'label': 'IC Number', 'icon': Icons.badge, 'keyboard': TextInputType.text, 'controller': TextEditingController()},
    {'label': '6-Digit PIN', 'icon': Icons.lock, 'keyboard': TextInputType.number, 'controller': TextEditingController(), 'maxLength': 6, 'obscure': true},
  ];

  void _handleRegister() {
    final name = fields[0]['controller'].text.trim();
    final email = fields[1]['controller'].text.trim();
    final phone = fields[2]['controller'].text.trim();
    final ic = fields[3]['controller'].text.trim();
    final pin = fields[4]['controller'].text.trim();

    if ([name, email, phone, ic, pin].any((e) => e.isEmpty)) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      Get.snackbar('Error', 'Invalid email');
      return;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      Get.snackbar('Error', 'Phone must be digits only');
      return;
    }
    if (pin.length != 6 || int.tryParse(pin) == null) {
      Get.snackbar('Error', 'PIN must be exactly 6 digits');
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
      appBar: AppBar(title: const Text('Register User')),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...fields.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: f['controller'] as TextEditingController,
                    keyboardType: f['keyboard'] as TextInputType,
                    obscureText: (f['obscure'] as bool?) ?? false,
                    maxLength: (f['maxLength'] as int?) ?? null,
                    decoration: InputDecoration(
                      labelText: f['label'] as String,
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
                child: const Text('Pick IC Photo'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: auth.isLoading.value ? null : _handleRegister,
                child: auth.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Register User'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
