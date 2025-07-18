import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // BLE
import 'package:bluepair/widgets/common_appbar.dart';
import 'package:bluepair/qr/qr_confirm.dart';
import 'package:bluepair/ui/home.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'; // Classic Bluetooth

class QRScannerPage extends StatefulWidget {
  QRScannerPage({super.key});

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final RxBool isProcessing = false.obs;
  StreamSubscription<List<ScanResult>>? scanSub;  // Nullable StreamSubscription
  RxString promptMessage = ''.obs;
  RxString qrData = ''.obs;
  RxMap scannedPayload = {}.obs; // To store the decoded QR data
  MobileScannerController controller = MobileScannerController();
  FlutterBluePlus flutterBlue = FlutterBluePlus(); // Corrected initialization of FlutterBluePlus


  @override
  void initState() {
    super.initState();
  }

  // This method handles the QR scan and connects Bluetooth
  Future<void> _handleScan(BuildContext context, String rawValue) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    // Check Bluetooth permissions before proceeding
    await _checkBluetoothPermissions();

    try {
      final decoded = jsonDecode(rawValue);
      print("✅ Scanned payload: $decoded");

      qrData.value = rawValue;
      scannedPayload.value = decoded; // Store decoded payload

      final macAddress = decoded['mac'];
      if (macAddress == null || macAddress.isEmpty) {
        throw Exception("MAC address missing from QR data");
      }

      promptMessage.value = "✅ QR Code Detected. Connecting to Bluetooth...";

      // First, attempt to connect via BLE
      await _connectUsingBLE(macAddress);

      // If BLE fails or not available, fallback to Bluetooth Classic
      Future.delayed(Duration(seconds: 5), () {
        if (!isProcessing.value) {
          _connectUsingClassicBluetooth(macAddress);
        }
      });

      controller.stop();
    } catch (e) {
      print("❌ Scan failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Scan error: $e")),
      );
      isProcessing.value = false;
    }
  }

  // Check for Bluetooth permissions for Android 12 and below
  Future<void> _checkBluetoothPermissions() async {
    // Check for required Bluetooth permissions
    if (await Permission.bluetooth.isDenied || await Permission.bluetoothScan.isDenied) {
      await Permission.bluetooth.request();
      await Permission.bluetoothScan.request();
    }

    // Handle location permission for Bluetooth scanning
    if (await Permission.location.isDenied) {
      await Permission.location.request();  // Required for Bluetooth scanning
    }

    // Android 12+ requires BLUETOOTH_CONNECT permission as well
    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }
  }

  // BLE connection attempt
  Future<void> _connectUsingBLE(String macAddress) async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    scanSub = FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        // Log the devices found for debugging
        print("Scanned device: ${r.device.name}, MAC address: ${r.device.remoteId}");

        // Normalize MAC address before comparison
        String normalizedMac = macAddress.toUpperCase().replaceAll(":", "");
        if (r.device.remoteId.str.replaceAll(":", "").toUpperCase() == normalizedMac) {
          print("Found device with matching MAC address!");
          await FlutterBluePlus.stopScan();
          await scanSub?.cancel();

          try {
            await r.device.connect();
            print("✅ Successfully connected to BLE device: ${r.device.name}");
            await Future.delayed(Duration(seconds: 5));

            // Navigate to the QR confirm page after successful connection
            Get.to(() => QRConfirmPage(payload: Map<String, dynamic>.from(scannedPayload.value)));
          } catch (e) {
            print("❌ Failed to connect via BLE: $e");
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ BLE Connection failed: $e")));
          }
          break;
        }
      }
    });
  }

  // Bluetooth Classic connection attempt
  Future<void> _connectUsingClassicBluetooth(String macAddress) async {
    try {
      BluetoothConnection.toAddress(macAddress).then((connection) {
        print("✅ Connected to classic Bluetooth device: $macAddress");
        // You can use `connection` to communicate with the device over classic Bluetooth
        Get.to(() => QRConfirmPage(payload: Map<String, dynamic>.from(scannedPayload.value)));  // Pass the payload correctly
      });
    } catch (e) {
      print("❌ Failed to connect via Bluetooth Classic: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Bluetooth Classic connection failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCommonAppBar("Scan QR", "Imbas Kod QR"),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final value = barcodes.first.rawValue;
                if (value != null) {
                  _handleScan(context, value); // Handle QR scan result
                }
              }
            },
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Obx(() => isProcessing.value
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox.shrink()),
          ),
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Obx(() {
              return Center(
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    promptMessage.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }),
          ),
          Positioned(
            bottom: 140,
            left: 20,
            right: 20,
            child: Obx(() {
              return Center(
                child: Text(
                  "Scanned QR Data: ${qrData.value}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
