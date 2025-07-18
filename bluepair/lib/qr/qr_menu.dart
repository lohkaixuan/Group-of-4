import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/storage/storage.dart';
import 'package:bluepair/widgets/common_appbar.dart';
import 'package:bluepair/controller/langaugeController.dart';
import 'package:device_info_plus/device_info_plus.dart';

class QRMenuPage extends StatefulWidget {
  const QRMenuPage({super.key});

  @override
  State<QRMenuPage> createState() => _QRMenuPageState();
}

class _QRMenuPageState extends State<QRMenuPage> {
  final lang = Get.find<LanguageController>();
  final storage = Storage();

  String? role;
  Map<String, dynamic>? user;
  String? personalWalletId;
  String? merchantWalletId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await storage.getUserDetails();
    final personal = await storage.getWalletInfo('personal');
    final merchant = await storage.getWalletInfo('merchant');

    setState(() {
      user = userData;
      role = userData?['role'];
      personalWalletId = personal?['id'];
      merchantWalletId = merchant?['id'];
      loading = false;
    });
  }

  Future<String> _getMacAddress() async {
    final info = await DeviceInfoPlugin().androidInfo;
    return info.id ?? 'unknown_device';
  }

  String _generateRefId() {
    final rand = Random().nextInt(999999);
    return 'TXN${DateTime.now().millisecondsSinceEpoch}_$rand';
  }

  @override
  Widget build(BuildContext context) {
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
            if (isMerchant) ...[
              ElevatedButton.icon(
                onPressed: () async {
                  final amount = 100.0; // Static or dynamic amount as required.
                  final macAddress = await _getMacAddress();
                  final now = DateTime.now();
                  final expiresAt = now.add(const Duration(minutes: 5));
                  final refId = _generateRefId();

                  Get.toNamed('/qr_generator', arguments: {
                    'walletType': 'merchant',
                    'walletId': merchantWalletId ?? '',
                    'amount': amount,
                    'macAddress': macAddress,
                    'refId': refId,
                    'timestamp': now.toIso8601String(),
                    'expiresAt': expiresAt.toIso8601String(),
                    'userDetails': user ?? {},
                    'role': 'merchant',
                  });
                },
                icon: const Icon(Icons.qr_code_2),
                label: Text(lang.t("Generate QR (Merchant)", "Jana QR (Peniaga)")),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
              const SizedBox(height: 24),
            ],
            ElevatedButton.icon(
              onPressed: () async {
                final amount = 100.0; // Static or dynamic amount as required.
                final macAddress = await _getMacAddress();
                final now = DateTime.now();
                final expiresAt = now.add(const Duration(minutes: 5));
                final refId = _generateRefId();

                Get.toNamed('/qr_generator', arguments: {
                  'walletType': 'personal',
                  'walletId': personalWalletId ?? '',
                  'amount': amount,
                  'macAddress': macAddress,
                  'refId': refId,
                  'timestamp': now.toIso8601String(),
                  'expiresAt': expiresAt.toIso8601String(),
                  'userDetails': user ?? {},
                  'role': 'user',
                });
              },
              icon: const Icon(Icons.send),
              label: Text(lang.t("Direct Transfer", "Pemindahan Terus")),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Get.toNamed('/qr_scanner');
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(lang.t("Scan QR (Buyer)", "Imbas QR (Pembeli)")),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
