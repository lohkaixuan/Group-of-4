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
      // Pages for Home and Profile
      final List<Widget> pages = [
        Home(),
        Profile(),
      ];

      // Build nav items with translated labels
      final navItems = [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: theme.iconTheme.color),
          label: lang.t("Home", "Laman Utama"),
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
          ),
          label: lang.t("Scan", "Imbas"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: theme.iconTheme.color),
          label: lang.t("Profile", "Profil"),
        ),
      ];

      return Scaffold(
        // Switch page between Home (0) or Profile (1)
        body: pages[
          navController.selectedIndex.value == 0 ? 0 : 1
        ],
        bottomNavigationBar: Obx(() {
          return BottomNavigationBar(
            currentIndex: navController.selectedIndex.value,
            onTap: (index) {
              if (index == 1) {
                // Middle button (Scan) → open QR Scanner
                Get.to(() => const QRMenuPage());
                return;
              }
              // 0 = home, 2 = profile
              navController.changeIndex(index == 0 ? 0 : 1);
            },
            items: navItems,
            backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
            selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
            unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
            selectedLabelStyle: theme.textTheme.labelLarge,
            unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
              color: theme.bottomNavigationBarTheme.unselectedItemColor,
            ),
          );
        }),
      );
    });
  }
}
