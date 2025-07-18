import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/authController.dart';

class RegisterMerchantPage extends StatelessWidget {
  RegisterMerchantPage({super.key});

  final auth = Get.find<AuthController>();

  // ✅ All text fields with their own controller in the same map
  final List<Map<String, dynamic>> fields = [
    {'label': 'Name', 'icon': Icons.person, 'keyboard': TextInputType.text, 'controller': TextEditingController()},
    {'label': 'Email', 'icon': Icons.email, 'keyboard': TextInputType.emailAddress, 'controller': TextEditingController()},
    {'label': 'Phone', 'icon': Icons.phone, 'keyboard': TextInputType.phone, 'controller': TextEditingController()},
    {'label': 'IC Number', 'icon': Icons.badge, 'keyboard': TextInputType.text, 'controller': TextEditingController()},
    {'label': '6-Digit PIN', 'icon': Icons.lock, 'keyboard': TextInputType.number, 'controller': TextEditingController(), 'maxLength': 6, 'obscure': true},
    {'label': 'Business Name', 'icon': Icons.store_mall_directory, 'keyboard': TextInputType.text, 'controller': TextEditingController()},
  ];

  final List<String> businessTypes = ['Micro', 'Small', 'Medium', 'Personal'];
  final List<String> categoryServices = ['F&B', 'Retail', 'Logistics', 'Medical', 'Entertainment'];

  // ✅ obs for dropdowns
  final RxString selectedBusinessType = 'Micro'.obs;
  final RxString selectedCategoryService = 'F&B'.obs;

  void _handleRegister() {
    final name = fields[0]['controller'].text.trim();
    final email = fields[1]['controller'].text.trim();
    final phone = fields[2]['controller'].text.trim();
    final ic = fields[3]['controller'].text.trim();
    final pin = fields[4]['controller'].text.trim();
    final businessName = fields[5]['controller'].text.trim();

    if ([name, email, phone, ic, pin, businessName].any((e) => e.isEmpty)) {
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

    auth.registerMerchant(
      name: name,
      email: email,
      phone: phone,
      icNumber: ic,
      pin: pin,
      businessName: businessName,
      businessType: selectedBusinessType.value,
      categoryService: selectedCategoryService.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Merchant")),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // build text fields dynamically
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: "",
                    ),
                  ),
                );
              }).toList(),

              // ✅ Dropdown for Business Type
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Obx(() {
                  return DropdownButtonFormField<String>(
                    value: selectedBusinessType.value,
                    decoration: InputDecoration(
                      labelText: 'Business Type',
                      prefixIcon: const Icon(Icons.store),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: businessTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) selectedBusinessType.value = value;
                    },
                  );
                }),
              ),

              // ✅ Dropdown for Category Service
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Obx(() {
                  return DropdownButtonFormField<String>(
                    value: selectedCategoryService.value,
                    decoration: InputDecoration(
                      labelText: 'Category Service',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: categoryServices.map((service) {
                      return DropdownMenuItem(value: service, child: Text(service));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) selectedCategoryService.value = value;
                    },
                  );
                }),
              ),

              ElevatedButton(
                onPressed: auth.pickIcPhoto,
                child: const Text("Pick IC Photo"),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: auth.pickSsmCertificate,
                child: const Text("Pick SSM Certificate (PDF)"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: auth.isLoading.value ? null : _handleRegister,
                child: auth.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Register Merchant"),
              ),
            ],
          ),
        );
      }),
    );
  }
}
