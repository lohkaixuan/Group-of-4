import 'package:bluepair/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/controller/homeController.dart';
import 'package:bluepair/controller/langaugeController.dart';
import 'package:bluepair/controller/walletController.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final homeController = Get.find<HomeController>();
  final lang = Get.find<LanguageController>();
  final walletController = Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    // ✅ Ensure wallets are loaded on startup
    walletController.loadWallets();

    return Obx(() {
      final isMerchant = homeController.isMerchantWallet.value;
      final role = homeController.role.value;

      // ✅ Get balances from WalletController (which internally reads from storage)
      final personalWallet = walletController.getWalletByType('personal');
      final merchantWallet = walletController.getWalletByType('merchant');
      final amount = isMerchant
          ? (merchantWallet?.balance ?? 0.0)
          : (personalWallet?.balance ?? 0.0);

      return Scaffold(
        appBar: buildCommonAppBar("Home", "Laman Utama"),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 Wallet Section
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.blueAccent,
              child: Stack(
                children: [
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
                              // ✅ Reactive amount always loaded from WalletController
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

                      // ✅ Top-up button
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          final controller = TextEditingController();
                          final result = await showDialog<double>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(lang.t("Top Up Wallet", "Tambah Nilai Dompet")),
                                content: TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: lang.t("Enter amount", "Masukkan amaun"),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(lang.t("Cancel", "Batal")),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      final amt = double.tryParse(controller.text.trim());
                                      if (amt != null && amt > 0) {
                                        Navigator.pop(context, amt);
                                      }
                                    },
                                    child: Text(lang.t("Confirm", "Sahkan")),
                                  ),
                                ],
                              );
                            },
                          );

                          if (result != null) {
                            // ✅ Get the correct wallet id
                            final walletId = isMerchant
                                ? (merchantWallet?.id ?? '')
                                : (personalWallet?.id ?? '');
                            if (walletId.isNotEmpty) {
                              // ✅ Top-up and then reload
                              await walletController.topUpWallet(walletId, result);
                              await walletController.loadWallets(); // refresh after top-up
                            }
                          }
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

                  // 👉 Toggle between merchant & personal
                  if (role != 'user')
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(Icons.swap_horiz,
                            color: Colors.white, size: 30),
                        onPressed: () async {
                          homeController.toggleWallet();
                          // ✅ Reload wallets after switching wallet type
                          await walletController.loadWallets();
                        },
                        tooltip: lang.t("Switch Wallet", "Tukar Dompet"),
                      ),
                    ),
                ],
              ),
            ),

            // 🔹 Transactions List
            Expanded(
              child: Obx(() {
                final txns = homeController.transactions;
                if (txns.isEmpty) {
                  return Center(
                    child: Text(lang.t(
                        "No transactions yet.", "Tiada transaksi setakat ini.")),
                  );
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
