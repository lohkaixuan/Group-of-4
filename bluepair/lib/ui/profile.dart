import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/controller/authController.dart';
import 'package:bluepair/controller/langaugeController.dart';
import 'package:bluepair/widgets/common_appbar.dart';

class Profile extends StatelessWidget {
  Profile({super.key});

  final auth = Get.find<AuthController>();
  final lang = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCommonAppBar("Profile", "Profil"),
      body: Obx(() {
        final user = auth.userDetails.value;

        if (user == null) {
          return Center(
            child: Text(lang.t("No user data found.", "Tiada data pengguna.")),
          );
        }

        // Build fields with translated labels
        final fields = <Map<String, dynamic>>[
          {
            'label': lang.t("User Name", "Nama Pengguna"),
            'value': user['name'] ?? 'Unknown',
            'icon': Icons.person,
          },
          {
            'label': lang.t("Email", "Emel"),
            'value': user['email'] ?? 'Unknown',
            'icon': Icons.email,
          },
          {
            'label': lang.t("Phone Number", "Nombor Telefon"),
            'value': user['phone'] ?? 'Unknown',
            'icon': Icons.phone,
          },
          {
            'label': lang.t("IC Number", "Nombor Kad Pengenalan"),
            'value': user['ic_number'] ?? 'N/A',
            'icon': Icons.badge,
          },
        ];

        if (user['role'] == 'merchant') {
          fields.addAll([
            {
              'label': lang.t("Business Name", "Nama Perniagaan"),
              'value': user['business_name'] ?? 'N/A',
              'icon': Icons.store,
            },
            {
              'label': lang.t("Business Type", "Jenis Perniagaan"),
              'value': user['business_type'] ?? 'N/A',
              'icon': Icons.category,
            },
            {
              'label': lang.t("Category Service", "Kategori Perkhidmatan"),
              'value': user['category_service'] ?? 'N/A',
              'icon': Icons.build,
            },
          ]);
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: fields.length,
                  itemBuilder: (context, index) {
                    final field = fields[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(field['icon'] as IconData,
                              size: 28, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  field['label'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  field['value'] as String,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await auth.logout();
                },
                icon: const Icon(Icons.logout),
                label: Text(lang.t("Logout", "Log Keluar")),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
