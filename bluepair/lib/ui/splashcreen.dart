import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/controller/authController.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () async {
      final hasToken = await auth.checkToken();
      if (hasToken) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/login');
      }
    });

    return const Scaffold(
      body: Center(
        child: Text(
          'Loading...',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
