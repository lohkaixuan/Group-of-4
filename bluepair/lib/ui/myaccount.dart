import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/controller/authController.dart';
import 'package:bluepair/widgets/common_appbar.dart';

class MyAccountPage extends StatelessWidget {
  MyAccountPage({super.key});

  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: buildCommonAppBar("My Account", "Akaun Saya"),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 Profile header
              Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.name.value.isEmpty ? "No Name" : auth.name.value,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.email.value.isEmpty ? "-" : auth.email.value,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),

              // ℹ️ Account details
              _buildInfoTile("Role", auth.role.value),
              const Divider(),
              _buildInfoTile("Status", auth.status.value.isEmpty ? "-" : auth.status.value),
              const Divider(),

              // If merchant, show extra fields
              if (auth.role.value == 'merchant') ...[
                const SizedBox(height: 20),
                Text(
                  "Merchant Details",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                _buildInfoTile("Merchant Status",
                    auth.status.value == 'approved' ? "✅ Approved" : "⏳ Pending"),
                const Divider(),
                // You can add more merchant-specific info if saved
              ],

              const SizedBox(height: 40),

              // 🚪 Logout
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    auth.logout();
                    Get.offAllNamed('/login');
                  },
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
