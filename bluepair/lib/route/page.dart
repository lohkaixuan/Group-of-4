import 'package:get/get.dart';

class AppRoutes {
  static const initial = '/login';

  static final routes = [
    GetPage(
      name: '/login',
      page: () => Login(),
    ),
    GetPage(
      name: '/register',
      page: () => Register(),
    ),
    // GetPage(
    //   name: '/home',
    // page:()=> CustomCalendar()
    // ),
    GetPage(
      name: '/home', // 🔥 After login, navigate here
      page: () => BottomNavApp(),
    ),
  ];
}
