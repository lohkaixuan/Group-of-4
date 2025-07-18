import 'package:bluepair/bottom_nav/bottom_nav_controller.dart';
import 'package:bluepair/controller/langaugeController.dart';
import 'package:bluepair/controller/walletController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/authController.dart';
import 'route/page.dart'; // <-- import your AppRoutes file

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(LanguageController());
  Get.put(AuthController()); // register controller
  Get.put(BottomNavController()); 
  Get.put(WalletController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BluePair',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // ✅ use initialRoute instead of home
      initialRoute: AppRoutes.initial, // e.g. '/splash'
      getPages: AppRoutes.routes,      // your route list with Splash/Login/etc
    );
  }
}