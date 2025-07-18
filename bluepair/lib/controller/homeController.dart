import 'package:bluepair/api/apis.dart';
import 'package:bluepair/storage/storage.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final ApiService api = ApiService();
  final Storage storage = Storage();

  // Wallet balances and IDs
  RxDouble personalWalletAmount = 0.0.obs;
  RxString personalWalletId = ''.obs;

  RxDouble merchantWalletAmount = 0.0.obs;
  RxString merchantWalletId = ''.obs;

  // Whether currently viewing merchant wallet or personal wallet
  RxBool isMerchantWallet = false.obs;

  // Transactions (you can change to List<Transaction> if you prefer)
  RxList<String> transactions = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadWallets();
    loadTransactions();
  }

  /// 🔄 Load wallets from API based on logged-in user
  Future<void> loadWallets() async {
    final user = await storage.getUserDetails();
    if (user == null || user['id'] == null) {
      print('⚠️ No user found in storage.');
      return;
    }

    final userId = user['id'];
    try {
      final wallets = await api.getWallets(userId);
      for (var w in wallets) {
        if (w.type.toLowerCase() == 'personal') {
          personalWalletAmount.value = w.balance;
          personalWalletId.value = w.id;
        } else if (w.type.toLowerCase() == 'merchant') {
          merchantWalletAmount.value = w.balance;
          merchantWalletId.value = w.id;
        }
      }
      print('✅ Wallets loaded successfully.');
    } catch (e) {
      print('❌ Failed to load wallets: $e');
    }
  }

  /// 🔄 Load transactions from API for this user
  Future<void> loadTransactions() async {
    final user = await storage.getUserDetails();
    if (user == null || user['id'] == null) {
      print('⚠️ No user found in storage.');
      transactions.clear();
      return;
    }

    //final userId = user['id'];
    // try {
    //   // You need to implement getTransactions in ApiService
    //   final txnList = await api.getTransactions(userId);
    //   transactions.value = txnList.map((t) {
    //     // Format as you like, here is an example
    //     return "${t.id} • ${t.status} • RM${t.amount.toStringAsFixed(2)}";
    //   }).toList();
    //   print('✅ Transactions loaded successfully.');
    // } catch (e) {
    //   print('❌ Failed to load transactions: $e');
    //   transactions.clear();
    // }
  }

  /// 🔁 Toggle between merchant wallet and personal wallet
  void toggleWallet() {
    isMerchantWallet.value = !isMerchantWallet.value;
  }

  /// ➕ Top up wallet using API
  Future<void> addAmount(double amount) async {
    final walletId =
        isMerchantWallet.value ? merchantWalletId.value : personalWalletId.value;
    if (walletId.isEmpty) {
      print('⚠️ No wallet ID found.');
      return;
    }

    try {
      final wallet = await api.topUpWallet(walletId, amount);
      if (wallet.type.toLowerCase() == 'personal') {
        personalWalletAmount.value = wallet.balance;
      } else {
        merchantWalletAmount.value = wallet.balance;
      }
      print('✅ Top-up successful.');
      // Reload transactions after top-up if needed
      loadTransactions();
    } catch (e) {
      print('❌ Top-up failed: $e');
    }
  }
}
