import 'package:bluepair/controller/homeController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🔹 Wallet Amount on top
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blueAccent,
            child: Obx(() {
              return Column(
                children: [
                  const Text(
                    "Your Wallet Amount",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "RM ${homeController.walletAmount.value.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            }),
          ),

          // 🔹 Rest of the page
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // example: add RM10
                  homeController.addAmount(10.0);
                },
                child: const Text("Add RM10"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
