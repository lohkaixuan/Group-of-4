import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:bluepair/widgets/crytohelpher.dart';
import 'package:bluepair/controller/authController.dart';
import 'package:bluepair/storage/storage.dart';
import 'package:bluepair/widgets/common_appbar.dart';

class QRGeneratorPage extends StatefulWidget {
  final String walletType;
  const QRGeneratorPage({super.key, required this.walletType});

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage> {
  final auth = Get.find<AuthController>();
  final storage = Storage();
  final TextEditingController amountController = TextEditingController();

  Map<String, dynamic>? userDetails;
  String? encryptedData;
  String macAddress = 'UNKNOWN';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _getBluetoothMac().then((_) => _setBluetoothName());
  }

  Future<void> _loadUserDetails() async {
    final details = await storage.getUserDetails();
    setState(() {
      userDetails = details ?? {};
    });
  }

  Future<void> _getBluetoothMac() async {
    try {
      final mac = await FlutterBluetoothSerial.instance.address;
      setState(() {
        macAddress = mac ?? 'UNKNOWN';
      });
    } catch (e) {
      setState(() {
        macAddress = 'UNKNOWN';
      });
    }
  }

  Future<void> _setBluetoothName() async {
    try {
      final walletId = userDetails?['wallet_id'] ?? 'BluePairWallet';
      await FlutterBluetoothSerial.instance.setName(walletId);
      print("🔵 Bluetooth name set to: $walletId");
    } catch (e) {
      print("⚠️ Failed to set Bluetooth name: $e");
    }
  }

  Future<void> _generateQR() async {
    final now = DateTime.now();
    final timestamp = now.toIso8601String();
    final expiresAt = now.add(const Duration(minutes: 10)).toIso8601String();
    final refId = const Uuid().v4();

    String walletId = '';
    if (widget.walletType.toLowerCase() == 'personal') {
      final p = await storage.getWalletInfo('personal');
      walletId = p?['id'] ?? '';
    } else if (widget.walletType.toLowerCase() == 'merchant') {
      final m = await storage.getWalletInfo('merchant');
      walletId = m?['id'] ?? '';
    }

    final role = auth.role.value;
    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;

    final Map<String, dynamic> payload = {
      'mac': macAddress,
      'amount': amount,
      'ref_id': refId,
      'timestamp': timestamp,
      'expires_at': expiresAt,
      'wallet_id': walletId,
    };

    if (role == 'user') {
      payload['role'] = 'user';
      payload['user_id'] = userDetails?['id'] ?? '';
    } else {
      payload['role'] = 'merchant';
      payload['merchant_id'] = userDetails?['id'] ?? '';
      payload['business_name'] = userDetails?['business_name'] ?? '';
    }

    final jsonStr = jsonEncode(payload);
    final encrypted = CryptoHelper.encryptData(jsonStr);

    setState(() {
      encryptedData = encrypted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCommonAppBar(
        "Generate QR (${widget.walletType})",
        "Jana Kod QR (${widget.walletType})",
      ),
      body: userDetails == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Role: ${auth.role.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Using Wallet Type: ${widget.walletType}'),
                  const SizedBox(height: 8),
                  Text('Bluetooth MAC: $macAddress'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _generateQR,
                    child: const Text('Generate QR'),
                  ),
                  const SizedBox(height: 20),
                  if (encryptedData != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✅ Encrypted QR Data:'),
                        const SizedBox(height: 8),
                        QrImageView(
                          data: encryptedData!,
                          size: 250,
                          version: QrVersions.auto,
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          encryptedData!,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
