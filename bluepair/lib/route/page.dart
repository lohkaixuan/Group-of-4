import 'package:bluepair/bottom_nav/bottom_nav_view.dart';
import 'package:bluepair/ui/loginPage.dart';
import 'package:bluepair/ui/registerMerchant.dart';
import 'package:bluepair/ui/registerUser.dart';
import 'package:bluepair/ui/splashcreen.dart';
import 'package:get/get.dart';

class AppRoutes {
  // start at splash screen
  static const initial = '/splash';

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

    // 🟢 Register Merchant (after user login or choose merchant)
    GetPage(
      name: '/register_merchant',
      page: () => RegisterMerchantPage(),
    ),

    // 🏠 Home (Bottom Navigation)
    GetPage(
      name: '/home',
      page: () => BottomNavApp(),
    ),
  ];
}
