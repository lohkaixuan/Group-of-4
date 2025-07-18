import 'dart:convert';
import 'package:bluepair/widgets/BiometricGate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/widgets/common_appbar.dart';
import 'package:bluepair/widgets/crytohelpher.dart';
import 'package:bluepair/controller/langaugeController.dart';

class QRConfirmPage extends StatelessWidget {
  final Map<String, dynamic> payload;
  final lang = Get.find<LanguageController>();

  QRConfirmPage({super.key, required this.payload});

  Future<void> _confirmWithAuthGate() async {
    Get.to(() => AuthGate(
          reasonText: lang.t('Authenticate to proceed', 'Sahkan untuk meneruskan'),
          onSuccess: () async {
            // 🔐 1. Sign the payload
            final String signed = CryptoHelper.signData(jsonEncode(payload));

            // 🔐 2. Encrypt for server (simulated with shared key)
            final String encryptedForServer = CryptoHelper.encryptData(jsonEncode({
              'payload': payload,
              'signature': signed,
            }));

            // 🔐 3. Hash for seller verification
            final String hashForSeller = CryptoHelper.hashData(jsonEncode(payload));

            // 📤 Send to server & seller (Bluetooth/API/etc.)
            print("📤 Encrypted for Server: $encryptedForServer");
            print("🔐 Hash for Seller: $hashForSeller");

            Get.snackbar(
              lang.t("Success", "Berjaya"),
              lang.t("Payment sent securely", "Pembayaran dihantar dengan selamat"),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.shade100,
            );

            Get.offAndToNamed('/myaccount');
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCommonAppBar(
        lang.t("Confirm Payment", "Sahkan Pembayaran"),
        lang.t("Confirm Payment", "Sahkan Pembayaran"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.t("🔐 Confirm Details", "🔐 Sahkan Butiran"),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _info(lang.t("Business Name", "Nama Perniagaan"), payload['business_name'] ?? '-'),
            _info(lang.t("Amount", "Jumlah"), "RM ${payload['amount']}"),
            _info(lang.t("Reference ID", "ID Rujukan"), payload['ref_id']),
            _info(lang.t("Expires At", "Tamat Pada"), payload['expires_at']),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _confirmWithAuthGate,
              icon: const Icon(Icons.fingerprint),
              label: Text(lang.t("Confirm & Pay", "Sahkan & Bayar")),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
