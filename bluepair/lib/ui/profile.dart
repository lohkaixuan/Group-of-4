import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/storage/storage.dart';
import '../controller/authController.dart';

class Profile extends StatelessWidget {
  Profile({super.key});

  final auth = Get.find<AuthController>();
  final Storage storage = Storage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: storage.getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found.'));
          }

          final user = snapshot.data!;
          // build a dynamic list of fields
          final List<Map<String, dynamic>> fields = [
            {
              'label': 'User Name',
              'value': user['name'] ?? 'Unknown',
              'icon': Icons.person,
            },
            {
              'label': 'Email',
              'value': user['email'] ?? 'Unknown',
              'icon': Icons.email,
            },
            {
              'label': 'Phone Number',
              'value': user['phone'] ?? 'Unknown',
              'icon': Icons.phone,
            },
            {
              'label': 'IC Number',
              'value': user['ic_number'] ?? 'N/A',
              'icon': Icons.badge,
            },
          ];

          // If merchant data exists in user details, add them
          if (user['role'] == 'merchant') {
            fields.addAll([
              {
                'label': 'Business Name',
                'value': user['business_name'] ?? 'N/A',
                'icon': Icons.store,
              },
              {
                'label': 'Business Type',
                'value': user['business_type'] ?? 'N/A',
                'icon': Icons.category,
              },
              {
                'label': 'Category Service',
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
                // Dynamically list fields
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

                // Logout button
                ElevatedButton.icon(
                  onPressed: () async {
                    await auth.logout();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
