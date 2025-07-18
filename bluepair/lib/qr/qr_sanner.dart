import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:bluepair/widgets/common_appbar.dart';
import 'package:bluepair/controller/langaugeController.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isConnecting = false;

  final lang = Get.find<LanguageController>();

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController qrController) {
    controller = qrController;
    controller!.resumeCamera(); // ensure camera is active
    controller!.scannedDataStream.listen((scanData) {
      final code = scanData.code;
      if (code != null) {
        controller!.pauseCamera();
        _handleScannedData(code);
      }
    });
  }

  Future<void> _handleScannedData(String data) async {
    try {
      final decoded = jsonDecode(data);
      final btName = decoded['btName']; // 🔹 expecting merchant device name

      if (btName == null || btName.isEmpty) {
        Get.snackbar(lang.t("Error", "Ralat"), lang.t("Invalid QR data", "Data QR tidak sah"));
        controller?.resumeCamera();
        return;
      }

      setState(() => isConnecting = true);

      // 🔹 Enable Bluetooth
      await FlutterBluetoothSerial.instance.requestEnable();

      // 🔹 Find paired devices
      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      final target = devices.firstWhereOrNull((d) => d.name == btName);

      if (target == null) {
        Get.snackbar(lang.t("Error", "Ralat"), lang.t("Device not paired", "Peranti belum dipadankan"));
        setState(() => isConnecting = false);
        controller?.resumeCamera();
        return;
      }

      // 🔹 Connect to the device
      BluetoothConnection.toAddress(target.address).then((connection) {
        Get.snackbar(lang.t("Success", "Berjaya"),
            "${lang.t("Connected to", "Disambungkan ke")} $btName");

        // Example: send payment info
        final payload = jsonEncode({"amount": decoded['amount'] ?? 0.0});
        connection.output.add(Uint8List.fromList(utf8.encode(payload)));
        connection.output.allSent;
      }).catchError((e) {
        Get.snackbar(lang.t("Error", "Ralat"),
            "${lang.t("Failed to connect", "Gagal sambung")}: $e");
      }).whenComplete(() {
        setState(() => isConnecting = false);
        controller?.resumeCamera();
      });
    } catch (e) {
      Get.snackbar(lang.t("Error", "Ralat"),
          lang.t("Invalid QR format", "Format QR tidak sah"));
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: buildCommonAppBar(
          lang.t("Scan QR", "Imbas QR"),
          lang.t("Scan QR", "Imbas QR"),
        ),
        body: Column(
          children: [
            // 🔹 Camera view
            Expanded(
              flex: 4,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),

            // 🔹 Status area
            Expanded(
              flex: 1,
              child: Center(
                child: isConnecting
                    ? const CircularProgressIndicator()
                    : Text(
                        lang.t("Scan a QR to connect", "Imbas QR untuk sambung"),
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
