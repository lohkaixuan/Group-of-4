import 'package:bluepair/controller/authController.dart';
import 'package:bluepair/widgets/BiometricGate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/widgets/common_appbar.dart';

class Profile extends StatelessWidget {
  Profile({super.key});

  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: buildCommonAppBar("Profile", "Profil"),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 Basic Info at the very top
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.name.value,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.email.value,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 🆔 My Account button just below basic info
              ElevatedButton.icon(
                icon: const Icon(Icons.account_circle),
                label: const Text(
                  'My Account',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // ✅ Wrap My Account navigation inside AuthGate
                  Get.to(() => AuthGate(
                    reasonText: 'Authenticate to proceed',
                    onSuccess: () async {
                      // ✅ Navigate to your MyAccountPage after auth success
                      Get.offAndToNamed('/myaccount');
                    },
                  ));
                },
              ),


              const SizedBox(height: 30),

              // 🔥 Role-based status
              if (auth.role.value == 'merchant') ...[
                Text(
                  auth.status.value == 'approved'
                      ? '✅ Verified Merchant'
                      : '⏳ Unverified Merchant',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: auth.status.value == 'approved'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ] else ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.store),
                  label: const Text('Register as Merchant'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // 👉 Navigate to your register merchant screen
                    // Get.to(() => RegisterMerchantPage());
                  },
                ),
              ],

              const Spacer(),

              // 🚪 Logout
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    auth.logout();
                    // 👉 Navigate to login page
                    // Get.offAll(() => LoginPage());
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
