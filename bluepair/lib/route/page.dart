import 'package:bluepair/ui/myaccount.dart';
import 'package:get/get.dart';

// 🔹 Existing pages
import 'package:bluepair/ui/splashcreen.dart';
import 'package:bluepair/ui/loginPage.dart';
import 'package:bluepair/ui/registerUser.dart';
import 'package:bluepair/ui/registerMerchant.dart';
import 'package:bluepair/bottom_nav/bottom_nav_view.dart';

// 🔹 QR-related pages
import 'package:bluepair/qr/qr_menu.dart';
import 'package:bluepair/qr/qr_generator.dart' as qrGenerator;
import 'package:bluepair/qr/qr_sanner.dart' as qrScanner;


// 🟢 QR-related pages

class AppRoutes {
  /// 📌 initial route
  static const initial = '/splash';

  /// 📌 all routes
  static final routes = [
    // 🟢 Splash Screen
    GetPage(
      name: '/splash',
      page: () => SplashScreen(),
    ),

    // 🟢 Login Page
    GetPage(
      name: '/login',
      page: () => LoginPage(),
    ),

    // 🟢 Register User
    GetPage(
      name: '/register',
      page: () => RegisterUserPage(),
    ),

    // 🟢 Register Merchant
    GetPage(
      name: '/register_merchant',
      page: () => RegisterMerchantPage(),
    ),

    // 🏠 Home (Bottom Navigation)
    GetPage(
      name: '/home',
      page: () => BottomNavApp(),
    ),

    // 🔵 QR Menu
    GetPage(
      name: '/qr_menu',
      page: () => QRMenuPage(),
    ),

    // 🔵 QR Generator
    GetPage(
      name: '/qr_generator',
      page: () => qrGenerator.QRGeneratorPage(
        walletType: Get.arguments['walletType'] ?? '',
      ),
    ),

    // 🔵 QR Scanner
    GetPage(
      name: '/qr_scanner',
      page: () => qrScanner.QRScannerPage(),
    ),

    // User Account Page
    GetPage(
      name: '/myaccount',
      page: () => MyAccountPage(),
    ),
  ];
}
