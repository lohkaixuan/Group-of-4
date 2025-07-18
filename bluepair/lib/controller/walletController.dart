import 'package:get/get.dart';
import 'package:bluepair/api/apis.dart';
import 'package:bluepair/api/models.dart';
import 'package:bluepair/storage/storage.dart';

class WalletController extends GetxController {
  final ApiService api = ApiService();
  final Storage storage = Storage();

  /// Wallets and roles
  RxList<Wallet> wallets = <Wallet>[].obs;
  RxBool isLoading = false.obs;
  RxString role = ''.obs;

  /// Wallet view state
  RxBool isMerchantWallet = false.obs;
  RxDouble personalWalletAmount = 0.0.obs;
  RxString personalWalletId = ''.obs;
  RxDouble merchantWalletAmount = 0.0.obs;
  RxString merchantWalletId = ''.obs;

  /// Top-up history and transactions
  RxList<Map<String, dynamic>> topUpHistory = <Map<String, dynamic>>[].obs;
  RxList<String> transactions = <String>[].obs;

  /// Last created transaction
  Rx<Transaction?> currentTransaction = Rx<Transaction?>(null);

  /// Load wallets
  Future<void> loadWallets() async {
    isLoading.value = true;
    try {
      final user = await storage.getUserDetails();
      if (user == null || user['id'] == null) {
        wallets.clear();
        return;
      }

      final userId = user['id'];
      role.value = user['role'] ?? '';
      final data = await api.getWallets(userId);
      wallets.assignAll(data);

      for (var w in wallets) {
        if (w.type.toLowerCase() == 'personal') {
          personalWalletAmount.value = w.balance;
          personalWalletId.value = w.id;
          await storage.saveWalletInfo({'id': w.id, 'balance': w.balance}, 'personal');
        } else if (w.type.toLowerCase() == 'merchant') {
          merchantWalletAmount.value = w.balance;
          merchantWalletId.value = w.id;
          await storage.saveWalletInfo({'id': w.id, 'balance': w.balance}, 'merchant');
        }
      }

      print('✅ Wallets loaded and saved.');
    } catch (e) {
      print('❌ Failed to load wallets: $e');
      wallets.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle view between personal/merchant wallet
  void toggleWallet() {
    isMerchantWallet.value = !isMerchantWallet.value;
  }

  /// Top-up the selected wallet
  Future<void> topUpSelectedWallet(double amount) async {
    final user = await storage.getUserDetails();
    if (user == null || user['id'] == null) return;

    final userId = user['id'];
    final walletId = isMerchantWallet.value
        ? merchantWalletId.value
        : personalWalletId.value;

    if (walletId.isEmpty) return;

    try {
      final result = await api.topUpWallet(userId, walletId, amount);
      await loadWallets(); // Refresh wallet
      transactions.insert(0, "Top-up • RM${amount.toStringAsFixed(2)}");
    } catch (e) {
      print("❌ Top-up failed: $e");
    }
  }

  /// Load top-up history
  Future<void> loadTopUpHistory() async {
    final user = await storage.getUserDetails();
    if (user == null || user['id'] == null) {
      topUpHistory.clear();
      return;
    }

    final userId = user['id'];
    try {
      final data = await api.getTopUpHistory(userId);
      topUpHistory.assignAll(data);
      print('✅ Top-up history loaded.');
    } catch (e) {
      print('❌ Failed to load top-up history: $e');
      topUpHistory.clear();
    }
  }

  /// Get wallet by type
  Wallet? getWalletByType(String type) {
    try {
      return wallets.firstWhere((w) => w.type.toLowerCase() == type.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  /// Create a new transaction
  Future<void> createTransaction(String buyerId, String sellerId, double amount) async {
    try {
      final txn = await api.createTransaction(buyerId, sellerId, amount);
      currentTransaction.value = txn;
      transactions.insert(0, "Created txn • ${txn.id} • RM${txn.amount}");
      print('✅ Transaction created: ${txn.id}');
    } catch (e) {
      print('❌ Failed to create transaction: $e');
    }
  }

  /// Confirm an existing transaction
  Future<void> confirmTransaction(String transactionId) async {
    try {
      final txn = await api.confirmTransaction(transactionId);
      currentTransaction.value = txn;
      transactions.insert(0, "Confirmed txn • ${txn.id} • RM${txn.amount}");
      print('✅ Transaction confirmed: ${txn.id}');
      await loadWallets(); // Update balances
    } catch (e) {
      print('❌ Failed to confirm transaction: $e');
    }
  }
}
