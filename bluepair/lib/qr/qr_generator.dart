import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/storage/storage.dart';
import 'package:bluepair/widgets/common_appbar.dart';
import 'package:bluepair/controller/langaugeController.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGeneratorPage extends StatelessWidget {
  final String walletType; // 👈 personal or merchant
  QRGeneratorPage({super.key, required this.walletType});

  final lang = Get.find<LanguageController>();
  final storage = Storage();
  final amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 🔥 Wrap the whole page with Obx so when language toggles, texts rebuild
    return Obx(() {
      return FutureBuilder<Map<String, dynamic>?>(
        future: storage.getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Scaffold(
              appBar: buildCommonAppBar(
                lang.t("Generate QR", "Jana QR"),
                lang.t("Generate QR", "Jana QR"),
              ),
              body: Center(
                child: Text(
                  lang.t("No user data", "Tiada data pengguna"),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          final user = snapshot.data!;
          final userId = user['id'] ?? '';
          String? qrData; // generated after button press

          return StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                appBar: buildCommonAppBar(
                  lang.t("Generate QR", "Jana QR"),
                  lang.t("Generate QR", "Jana QR"),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🔹 Enter amount
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: lang.t("Enter amount", "Masukkan amaun"),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Generate button
                      ElevatedButton.icon(
                        onPressed: () {
                          final amount = amountController.text.trim();
                          if (amount.isEmpty) {
                            Get.snackbar(
                              lang.t("Error", "Ralat"),
                              lang.t("Please enter amount", "Sila masukkan amaun"),
                            );
                            return;
                          }

                          // Build payload for QR
                          final data = {
                            "wallet_type": walletType,
                            "user_id": userId,
                            "amount": amount,
                            "session_id": DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                          };

                          setState(() {
                            qrData = jsonEncode(data);
                          });
                        },
                        icon: const Icon(Icons.qr_code),
                        label: Text(lang.t("Generate QR", "Jana QR")),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 🔹 Show QR if generated
                      if (qrData != null) ...[
                        QrImageView(
                          data: qrData!,
                          size: 250,
                          version: QrVersions.auto,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          lang.t(
                            "Show this QR to buyer",
                            "Tunjuk QR ini kepada pembeli",
                          ),
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }
}
