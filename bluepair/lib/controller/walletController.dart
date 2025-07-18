import 'package:get/get.dart';
import 'package:bluepair/api/models.dart';
import 'package:bluepair/api/apis.dart';
import 'package:bluepair/storage/storage.dart';

class WalletController extends GetxController {
  final ApiService api = ApiService();
  final Storage storage = Storage();

  /// Reactive states
  RxList<Wallet> wallets = <Wallet>[].obs;
  RxBool isLoading = false.obs;

  /// Load wallets for current logged-in user
  Future<void> loadWallets() async {
    isLoading.value = true;
    try {
      final user = await storage.getUserDetails();
      if (user == null || user['id'] == null) {
        wallets.clear();
        return;
      }
      final userId = user['id'];
      final data = await api.getWallets(userId);
      wallets.assignAll(data);
      print('✅ Wallets loaded: ${wallets.length}');
    } catch (e) {
      print('❌ Failed to load wallets: $e');
      wallets.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Top up a wallet
  Future<void> topUpWallet(String walletId, double amount) async {
    isLoading.value = true;
    try {
      final updatedWallet = await api.topUpWallet(walletId, amount);
      // Replace old wallet in the list
      final index = wallets.indexWhere((w) => w.id == walletId);
      if (index != -1) {
        wallets[index] = updatedWallet;
        wallets.refresh();
      }
      print('✅ Top-up successful. New balance: ${updatedWallet.balance}');
    } catch (e) {
      print('❌ Top-up failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get a wallet by type easily (personal or merchant)
  Wallet? getWalletByType(String type) {
    try {
      return wallets.firstWhere((w) => w.type.toLowerCase() == type.toLowerCase());
    } catch (_) {
      return null;
    }
  }
}
