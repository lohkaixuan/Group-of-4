import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/controller/authController.dart';
import 'package:bluepair/controller/langaugeController.dart';
import 'package:bluepair/widgets/common_appbar.dart';

class RegisterMerchantPage extends StatelessWidget {
  RegisterMerchantPage({super.key});

  final auth = Get.find<AuthController>();
  final lang = Get.find<LanguageController>();

  // ✅ Text fields
  final List<Map<String, dynamic>> fields = [
    {
      'labelEn': 'Name',
      'labelBm': 'Nama',
      'icon': Icons.person,
      'keyboard': TextInputType.text,
      'controller': TextEditingController()
    },
    {
      'labelEn': 'Email',
      'labelBm': 'Emel',
      'icon': Icons.email,
      'keyboard': TextInputType.emailAddress,
      'controller': TextEditingController()
    },
    {
      'labelEn': 'Phone',
      'labelBm': 'Telefon',
      'icon': Icons.phone,
      'keyboard': TextInputType.phone,
      'controller': TextEditingController()
    },
    {
      'labelEn': 'IC Number',
      'labelBm': 'Nombor IC',
      'icon': Icons.badge,
      'keyboard': TextInputType.text,
      'controller': TextEditingController()
    },
    {
      'labelEn': '6-Digit PIN',
      'labelBm': 'PIN 6-Digit',
      'icon': Icons.lock,
      'keyboard': TextInputType.number,
      'controller': TextEditingController(),
      'maxLength': 6,
      'obscure': true
    },
    {
      'labelEn': 'Business Name',
      'labelBm': 'Nama Perniagaan',
      'icon': Icons.store_mall_directory,
      'keyboard': TextInputType.text,
      'controller': TextEditingController()
    },
  ];

  final List<Map<String, String>> businessTypes = [
    {'en': 'Micro', 'bm': 'Mikro'},
    {'en': 'Small', 'bm': 'Kecil'},
    {'en': 'Medium', 'bm': 'Sederhana'},
    {'en': 'Personal', 'bm': 'Peribadi'},
  ];

  final List<Map<String, String>> categoryServices = [
    {'en': 'F&B', 'bm': 'Makanan & Minuman'},
    {'en': 'Retail', 'bm': 'Runcit'},
    {'en': 'Logistics', 'bm': 'Logistik'},
    {'en': 'Medical', 'bm': 'Perubatan'},
    {'en': 'Entertainment', 'bm': 'Hiburan'},
  ];

  // obs for dropdowns
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
      Get.snackbar(lang.t('Error', 'Ralat'),
          lang.t('All fields are required', 'Semua medan diperlukan'));
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      Get.snackbar(lang.t('Error', 'Ralat'),
          lang.t('Invalid email', 'Emel tidak sah'));
      return;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      Get.snackbar(lang.t('Error', 'Ralat'),
          lang.t('Phone must be digits only', 'Nombor telefon mesti nombor sahaja'));
      return;
    }
    if (pin.length != 6 || int.tryParse(pin) == null) {
      Get.snackbar(lang.t('Error', 'Ralat'),
          lang.t('PIN must be exactly 6 digits', 'PIN mestilah 6 digit'));
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
      appBar: buildCommonAppBar("Register Merchant", "Daftar Peniaga"),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔹 text fields
              ...fields.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: f['controller'] as TextEditingController,
                    keyboardType: f['keyboard'] as TextInputType,
                    obscureText: (f['obscure'] as bool?) ?? false,
                    maxLength: (f['maxLength'] as int?) ?? null,
                    decoration: InputDecoration(
                      labelText: lang.t(f['labelEn'], f['labelBm']),
                      prefixIcon: Icon(f['icon'] as IconData),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: "",
                    ),
                  ),
                );
              }).toList(),

              // 🔹 Dropdown Business Type
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Obx(() {
                  return DropdownButtonFormField<String>(
                    value: selectedBusinessType.value,
                    decoration: InputDecoration(
                      labelText: lang.t('Business Type', 'Jenis Perniagaan'),
                      prefixIcon: const Icon(Icons.store),
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: businessTypes.map((type) {
                      return DropdownMenuItem(
                        value: type['en'],
                        child: Text(lang.t(type['en']!, type['bm']!)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) selectedBusinessType.value = value;
                    },
                  );
                }),
              ),

              // 🔹 Dropdown Category Service
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Obx(() {
                  return DropdownButtonFormField<String>(
                    value: selectedCategoryService.value,
                    decoration: InputDecoration(
                      labelText: lang.t('Category Service', 'Kategori Perkhidmatan'),
                      prefixIcon: const Icon(Icons.category),
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: categoryServices.map((service) {
                      return DropdownMenuItem(
                        value: service['en'],
                        child: Text(lang.t(service['en']!, service['bm']!)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) selectedCategoryService.value = value;
                    },
                  );
                }),
              ),

              // 🔹 IC Photo Button
              ElevatedButton(
                onPressed: auth.pickIcPhoto,
                child: Text(lang.t("Pick IC Photo", "Pilih Gambar IC")),
              ),

              // 🔹 IC Photo Preview
              if (auth.icPhoto != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.file(
                    auth.icPhoto!,
                    fit: BoxFit.cover,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // 🔹 SSM Certificate Button
              ElevatedButton(
                onPressed: auth.pickSsmCertificate,
                child: Text(lang.t(
                    "Pick SSM Certificate (PDF)", "Pilih Sijil SSM (PDF)")),
              ),

              // 🔹 SSM Certificate Preview (show file name)
              if (auth.ssmCertificate != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          auth.ssmCertificate!.path.split('/').last,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: auth.isLoading.value ? null : _handleRegister,
                child: auth.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(lang.t("Register Merchant", "Daftar Peniaga")),
              ),
            ],
          ),
        );
      }),
    );
  }
}
