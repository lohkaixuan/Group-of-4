import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/controller/authController.dart';
import 'package:bluepair/controller/langaugeController.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  final auth = Get.find<AuthController>();
  final lang = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    // Delay navigation
    Future.delayed(const Duration(seconds: 2), () async {
      final hasToken = await auth.checkToken();
      if (hasToken) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/login');
      }
    });

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Obx(() {
          return Text(
            lang.t("Loading...", "Memuatkan..."),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          );
        }),
      ),
    );
  }
}
