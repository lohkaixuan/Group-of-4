import 'package:bluepair/bottom_nav/bottom_nav_controller.dart';
import 'package:bluepair/controller/langaugeController.dart';
import 'package:bluepair/qr/qr_menu.dart';
import 'package:bluepair/ui/home.dart';
import 'package:bluepair/ui/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavApp extends StatelessWidget {
  BottomNavApp({super.key});

  final BottomNavController navController = Get.find<BottomNavController>();
  final lang = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      /// ✅ Now we have 3 pages: Home, Scan, Profile
      final List<Widget> pages = [
        Home(),
        QRMenuPage(), // 👈 new page for Scan
        Profile(),
      ];

      final navItems = [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: theme.iconTheme.color),
          label: lang.t("Home", "Laman Utama"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner, color: theme.iconTheme.color),
          label: lang.t("Scan", "Imbas"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: theme.iconTheme.color),
          label: lang.t("Profile", "Profil"),
        ),
      ];

      return Scaffold(
        body: pages[navController.selectedIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: navController.selectedIndex.value,
          onTap: (index) {
            /// Simply change index directly
            navController.changeIndex(index);
          },
          items: navItems,
          backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
          selectedLabelStyle: theme.textTheme.labelLarge,
          unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
            color: theme.bottomNavigationBarTheme.unselectedItemColor,
          ),
        ),
      );
    });
  }
}
