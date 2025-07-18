import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:bluepair/widgets/crytohelpher.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;

  BluetoothConnection? btConnection;
  String logText = 'Scan a QR code to connect';
  Map<String, dynamic>? decodedPayload;

  @override
  void dispose() {
    qrController?.dispose();
    btConnection?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        qrController?.pauseCamera();
        _handleScan(scanData.code!);
      }
    });
  }

  Future<void> _handleScan(String encrypted) async {
    try {
      final decrypted = CryptoHelper.decryptData(encrypted);
      final Map<String, dynamic> data = jsonDecode(decrypted);

      setState(() {
        decodedPayload = data;
        logText = '✅ Data decoded. Connecting...';
      });

      final walletId = data['wallet_id'];
      if (walletId != null && walletId.isNotEmpty) {
        _connectToBluetoothByName(walletId);
      } else {
        setState(() => logText = '⚠️ Wallet ID not found in payload.');
      }
    } catch (e) {
      setState(() => logText = '❌ Failed to decode: $e');
    }
  }

  Future<void> _connectToBluetoothByName(String walletId) async {
    try {
      setState(() => logText = '🔍 Scanning for device named: $walletId');

      FlutterBluetoothSerial.instance.startDiscovery().listen((r) async {
        if (r.device.name == walletId) {
          FlutterBluetoothSerial.instance.cancelDiscovery(); // stop once found
          setState(() => logText = '🔗 Found $walletId, connecting...');

          try {
            final conn = await BluetoothConnection.toAddress(r.device.address);
            setState(() {
              btConnection = conn;
              logText = '✅ Connected to $walletId (${r.device.address})';
            });

            conn.input?.listen((Uint8List data) {
              setState(() => logText = '📥 Received: ${ascii.decode(data)}');
            }).onDone(() {
              setState(() {
                logText = '❌ Disconnected';
                btConnection = null;
              });
            });
          } catch (e) {
            setState(() => logText = '❌ Connection failed: $e');
          }
        }
      });
    } catch (e) {
      setState(() => logText = '⚠️ Bluetooth scan failed: $e');
    }
  }

  void _sendTestMessage() {
    if (btConnection != null && btConnection!.isConnected) {
      const msg = 'Hello from scanner!';
      btConnection!.output.add(Uint8List.fromList(utf8.encode(msg + '\r\n')));
      btConnection!.output.allSent.then((_) {
        setState(() => logText = '📤 Sent: $msg');
      });
    } else {
      setState(() => logText = '⚠️ Not connected to any device.');
    }
  }

  Widget _buildPayloadView() {
    if (decodedPayload == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey.shade200,
      child: Text(const JsonEncoder.withIndent('  ').convert(decodedPayload!),
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR & Connect')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(logText),
                  _buildPayloadView(),
                  const SizedBox(height: 10),
                  if (btConnection != null && btConnection!.isConnected)
                    ElevatedButton.icon(
                      onPressed: _sendTestMessage,
                      icon: const Icon(Icons.send),
                      label: const Text('Send Test Message'),
                    ),
                  ElevatedButton.icon(
                    onPressed: () {
                      qrController?.resumeCamera();
                      setState(() {
                        decodedPayload = null;
                        logText = 'Scan a QR code to connect';
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Scan Again'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
