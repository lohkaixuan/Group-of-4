import 'package:bluepair/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/controller/homeController.dart';
import 'package:bluepair/controller/langaugeController.dart';
class Home extends StatelessWidget {
  Home({super.key});

  final homeController = Get.find<HomeController>();
  final lang = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: buildCommonAppBar("Home", "Laman Utama"),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 Wallet Section
            Obx(() {
              final isMerchant = homeController.isMerchantWallet.value;
              final amount = isMerchant
                  ? homeController.merchantWalletAmount.value
                  : homeController.personalWalletAmount.value;

              return Container(
                padding: const EdgeInsets.all(20),
                color: Colors.blueAccent,
                child: Stack(
                  children: [
                    // Main wallet info
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.account_balance_wallet,
                                size: 60, color: Colors.white),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMerchant
                                      ? lang.t("Merchant Wallet", "Dompet Peniaga")
                                      : lang.t("Personal Wallet", "Dompet Peribadi"),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "RM ${amount.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Top Up button with plus icon
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            // Example: add RM10
                            homeController.addAmount(10.0);
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: Text(
                            lang.t("Top Up", "Tambah Nilai"),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 🔄 Toggle Wallet button
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(Icons.swap_horiz,
                            color: Colors.white, size: 30),
                        onPressed: () {
                          homeController.toggleWallet();
                        },
                        tooltip: lang.t("Switch Wallet", "Tukar Dompet"),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // 🔹 Transactions List
            Expanded(
              child: Obx(() {
                final txns = homeController.transactions;
                if (txns.isEmpty) {
                  return Center(
                      child: Text(lang.t(
                          "No transactions yet.", "Tiada transaksi setakat ini.")));
                }
                return ListView.builder(
                  itemCount: txns.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.receipt),
                      title: Text(txns[index]),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}
