import 'dart:convert';
import 'dart:async';
import 'package:bluepair/qr/qr_confirm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:bluepair/widgets/common_appbar.dart';
import 'package:bluepair/storage/storage.dart';
import 'package:bluepair/controller/authController.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // For BLE
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'; // For Bluetooth Classic

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
  String? qrData;
  String macAddress = '98:0D:51:A5:9A:2C'; // Hardcoded MAC address for demo
  String walletId = '';
  FlutterBluePlus flutterBlue = FlutterBluePlus(); // Corrected initialization of FlutterBluePlus

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final details = await storage.getUserDetails();
    final wallet = await storage.getWalletInfo(widget.walletType);
    setState(() {
      userDetails = details ?? {};
      walletId = wallet?['id'] ?? 'WalletBroadcast';
    });
  }

  // Request Bluetooth permissions for Android 12+ and below
  Future<void> _requestPermissions() async {
    if (await Permission.bluetooth.isDenied) {
      await Permission.bluetooth.request();
    }
    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }
    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();  // For Android 12+
    }
  }

  // Start Bluetooth and set the device to discoverable
  Future<void> _enableBluetooth() async {
    bool isAvailable = await FlutterBluePlus.isAvailable;
    if (isAvailable) {
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 5)); // Start scanning for BLE devices
    }

    // Advertise the device using Bluetooth Classic (since FlutterBluePlus doesn't support advertising)
    try {
      BluetoothConnection.toAddress(macAddress).then((connection) {
        print("✅ Connected to classic Bluetooth device: $macAddress");
        // You can use `connection` to communicate with the device over classic Bluetooth
      });
    } catch (e) {
      print("❌ Failed to start Bluetooth advertising: $e");
    }
  }

  // Attempt BLE connection first, then fallback to Bluetooth Classic
  Future<void> _connectToDevice(String macAddress) async {
    try {
      // Try BLE first
      await _connectUsingBLE(macAddress);
    } catch (e) {
      // If BLE fails, fallback to Bluetooth Classic
      print("❌ BLE connection failed, trying Bluetooth Classic...");
      await _connectUsingClassicBluetooth(macAddress);
    }
  }

  // Try to connect using BLE
  Future<void> _connectUsingBLE(String macAddress) async {
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
    StreamSubscription<List<ScanResult>>? scanSub; // Made it nullable to avoid issues

    scanSub = FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.remoteId.str == macAddress) {
          await FlutterBluePlus.stopScan();
          await scanSub?.cancel();

          try {
            await r.device.connect();
            print("✅ Successfully connected to: ${r.device.name}");
            await Future.delayed(Duration(seconds: 5));
            Get.to(() => QRConfirmPage(payload: {'mac': macAddress})); // Ensured map structure
          } catch (e) {
            throw Exception("Failed to connect via BLE: $e");
          }
          break;
        }
      }
    });
  }

  // Fallback to Bluetooth Classic
  Future<void> _connectUsingClassicBluetooth(String macAddress) async {
    try {
      BluetoothConnection.toAddress(macAddress).then((connection) {
        print("✅ Connected to classic Bluetooth device: $macAddress");
        // You can use `connection` to communicate with the device over classic Bluetooth
        Get.to(() => QRConfirmPage(payload: {'mac': macAddress})); // Ensured map structure
      });
    } catch (e) {
      print("❌ Failed to connect via Bluetooth Classic: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Connection failed: $e")));
    }
  }

  // Generate the QR code with dynamic data (no encryption)
  Future<void> _generateQR() async {
    // Ensure necessary permissions are granted
    await _requestPermissions();

    final now = DateTime.now();
    final timestamp = now.toIso8601String();
    final expiresAt = now.add(const Duration(minutes: 10)).toIso8601String();
    final refId = const Uuid().v4();

    final role = auth.role.value;
    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;

    final payload = {
      'mac': macAddress, // Bluetooth MAC address
      'amount': amount,
      'ref_id': refId,
      'timestamp': timestamp,
      'expires_at': expiresAt,
      'wallet_id': walletId,
      if (role == 'user')
        ...{
          'role': 'user',
          'user_id': userDetails?['id'] ?? ''
        }
      else
        ...{
          'role': 'merchant',
          'merchant_id': userDetails?['id'] ?? '',
          'business_name': userDetails?['business_name'] ?? ''
        }
    };

    // Convert the payload to a string (no encryption here)
    final jsonStr = jsonEncode(payload);

    setState(() {
      qrData = jsonStr; // Use plain data for QR code
    });

    // Enable Bluetooth and start connecting
    _enableBluetooth();
    _connectToDevice(macAddress);  // Try connecting to the device
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCommonAppBar("Generate QR", "Jana Kod QR"),
      body: userDetails == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _generateQR,
                    child: const Text("Generate QR"),
                  ),
                  const SizedBox(height: 16),
                  if (qrData != null)
                    QrImageView(
                      data: qrData!,  // Use the plain data directly
                      size: 240,
                      version: QrVersions.auto,
                    )
                ],
              ),
            ),
    );
  }
}
