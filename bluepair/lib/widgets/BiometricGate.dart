import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class AuthGate extends StatefulWidget {
  final Future<void> Function()? onSuccess; // callback after success
  final String reasonText; // what to show in biometric prompt

  const AuthGate({
    super.key,
    required this.onSuccess,
    this.reasonText = 'Please authenticate to proceed',
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _checking = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  // Future<void> _authenticate() async {
  //   try {
  //     bool canCheckBiometrics = await auth.canCheckBiometrics;
  //     bool isDeviceSupported = await auth.isDeviceSupported();

  //     bool didAuthenticate = false;

  //     // First try biometrics
  //     if (canCheckBiometrics && isDeviceSupported) {
  //       didAuthenticate = await auth.authenticate(
  //         localizedReason: widget.reasonText,
  //         options: const AuthenticationOptions(
  //           biometricOnly: true,
  //           stickyAuth: true,
  //         ),
  //       );
  //     }

  //     // If not authenticated by biometrics, fallback to PIN
  //     if (!didAuthenticate) {
  //       didAuthenticate = await _pinDialog();
  //     }

  //     if (didAuthenticate) {
  //       if (mounted) {
  //         // ✅ Call back to whatever the caller wants to do
  //         if (widget.onSuccess != null) {
  //           await widget.onSuccess!();
  //         }
  //         // Then pop this page
  //         if (mounted) Navigator.of(context).pop();
  //       }
  //     } else {
  //       setState(() {
  //         _checking = false;
  //         _error = 'Authentication failed or cancelled';
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _checking = false;
  //       _error = 'Error: $e';
  //     });
  //   }
  // }
  Future<void> _authenticate() async {
    await Future.delayed(const Duration(seconds: 1)); // simulate short delay

    if (widget.onSuccess != null) {
      await widget.onSuccess!();
    }

    if (mounted) Navigator.of(context).pop(); // Close AuthGate
  }


  Future<bool> _pinDialog() async {
    String pin = '';
    bool success = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Enter PIN'),
          content: TextField(
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            onChanged: (value) => pin = value,
            decoration: const InputDecoration(hintText: 'Your PIN'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (pin == "123456") { // TODO: replace with real PIN logic
                  success = true;
                  Navigator.of(ctx).pop();
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Invalid PIN')),
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return success;
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _authenticate,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
