import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/controller/langaugeController.dart';
import 'package:bluepair/controller/walletController.dart';
import 'package:bluepair/widgets/common_appbar.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final lang = Get.find<LanguageController>();
  final walletController = Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    // ✅ Load wallets once (won't trigger multiple times due to Get.put)
    walletController.loadWallets();

    return Obx(() {
      final role = walletController.role.value;
      final isMerchant = walletController.isMerchantWallet.value;

      final personalWallet = walletController.getWalletByType('personal');
      final merchantWallet = walletController.getWalletByType('merchant');

      final amount = isMerchant
          ? (merchantWallet?.balance ?? 0.0)
          : (personalWallet?.balance ?? 0.0);

      return Scaffold(
        appBar: buildCommonAppBar("Home", "Laman Utama"),
        body: RefreshIndicator(
          onRefresh: () async {
            // Reload wallets when user swipes down
            await walletController.loadWallets();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔹 Wallet Display Section
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

                        // ✅ Top Up Button
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                              await walletController.topUpSelectedWallet(result);
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

                    // 🔁 Wallet Switch Button (if not normal user)
                    if (role.toLowerCase() != 'user')
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton(
                          icon: const Icon(Icons.swap_horiz, color: Colors.white, size: 30),
                          onPressed: () => walletController.toggleWallet(),
                          tooltip: lang.t("Switch Wallet", "Tukar Dompet"),
                        ),
                      ),
                  ],
                ),
              ),

              // 🔹 Transactions List
              Expanded(
                child: Obx(() {
                  final txns = walletController.transactions;
                  if (txns.isEmpty) {
                    return Center(
                      child: Text(
                        lang.t("No transactions yet.", "Tiada transaksi setakat ini."),
                      ),
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
        ),
      );
    });
  }
}
