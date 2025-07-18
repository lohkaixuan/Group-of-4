import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/storage/storage.dart';
import 'package:bluepair/widgets/common_appbar.dart';
import 'package:bluepair/controller/langaugeController.dart';
import 'package:bluepair/qr/qr_generator.dart'; // 👈 import your generator page

class QRMenuPage extends StatefulWidget {
  const QRMenuPage({super.key});

  @override
  State<QRMenuPage> createState() => _QRMenuPageState();
}

class _QRMenuPageState extends State<QRMenuPage> {
  final lang = Get.find<LanguageController>();
  final storage = Storage();

  String? role;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = await storage.getUserDetails();
    setState(() {
      role = user?['role'];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (loading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final isMerchant = (role == 'merchant');

      return Scaffold(
        appBar: buildCommonAppBar(
          lang.t("QR Menu", "Menu QR"),
          lang.t("QR Menu", "Menu QR"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Merchant-only QR
              if (isMerchant) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => QRGeneratorPage(walletType: 'merchant'));
                  },
                  icon: const Icon(Icons.qr_code_2),
                  label: Text(
                    lang.t("Generate QR (Merchant)", "Jana QR (Peniaga)"),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ✅ Direct Transfer (personal wallet QR)
              ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => QRGeneratorPage(walletType: 'personal'));
                },
                icon: const Icon(Icons.send),
                label: Text(lang.t("Direct Transfer", "Pemindahan Terus")),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 24),

              // ✅ QR Scanner (buyer mode)
              ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed('/qr_scanner');
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(lang.t("Scan QR (Buyer)", "Imbas QR (Pembeli)")),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
