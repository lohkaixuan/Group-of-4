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
      page: () => Login(),
    ),

    // 🟢 Register User
    GetPage(
      name: '/register',
      page: () => Register(),
    ),

    // 🟢 Register Merchant (after user login or choose merchant)
    GetPage(
      name: '/register_merchant',
      page: () => RegisterMerchant(),
    ),

    // 🏠 Home (Bottom Navigation)
    GetPage(
      name: '/home',
      page: () => BottomNavApp(),
    ),
  ];
}
