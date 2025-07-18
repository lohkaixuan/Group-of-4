import 'package:bluepair/bottom_nav/bottom_nav_controller.dart';
import 'package:bluepair/qr/qr_scanner.dart';
import 'package:bluepair/ui/home.dart';
import 'package:bluepair/ui/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavApp extends StatelessWidget {
  BottomNavApp({super.key});

  final BottomNavController navController = Get.find();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      // We only have two actual pages
      List<Widget> pages = [
        Home(),
        Profile(),
      ];

      // Build nav items with a central QR action
      final navItems = [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: theme.iconTheme.color),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue, // background highlight for QR
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
          ),
          label: "Scan",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: theme.iconTheme.color),
          label: "Profile",
        ),
      ];

      return Scaffold(
        body: pages[
            navController.selectedIndex.value == 0
                ? 0
                : 1], // Map to Home(0) or Profile(1)
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: navController.selectedIndex.value,
          onTap: (index) {
            if (index == 1) {
              // middle button pressed → open QR scanner instead of switching
              Get.to(() => QRScannerPage());
              return;
            }
            // adjust index: if pressed 0 = home, if pressed 2 = profile
            navController.changeIndex(index == 0 ? 0 : 1);
          },
          items: navItems,
          backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
          selectedLabelStyle: theme.textTheme.labelLarge,
          unselectedLabelStyle: theme.textTheme.labelLarge
              ?.copyWith(color: theme.bottomNavigationBarTheme.unselectedItemColor),
        ),
      );
    });
  }
}