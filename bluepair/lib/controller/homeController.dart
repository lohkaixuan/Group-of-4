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

  // Transactions (simple string list for now)
  RxList<String> transactions = <String>[].obs;

  // User role
  RxString role = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadWallets();
  }

  /// 🔄 Load wallets from API based on logged-in user
Future<void> loadWallets() async {
  final user = await storage.getUserDetails();
  if (user == null || user['id'] == null) {
    print('⚠️ No user found in storage.');
    return;
  }

  role.value = (user['role'] ?? '').toString();
  final userId = user['id'];

  try {
    final wallets = await api.getWallets(userId);

    double personal = 0.0;
    double merchant = 0.0;
    String pId = '';
    String mId = '';

    for (var w in wallets) {
      if (w.type.toLowerCase() == 'personal') {
        personal = w.balance;
        pId = w.id;
      } else if (w.type.toLowerCase() == 'merchant') {
        merchant = w.balance;
        mId = w.id;
      }
    }

    // Update reactive fields
    personalWalletAmount.value = personal;
    personalWalletId.value = pId;
    merchantWalletAmount.value = merchant;
    merchantWalletId.value = mId;

    // ✅ Save each wallet separately in secure storage
    await storage.saveWalletInfo({'id': pId, 'balance': personal}, 'personal');
    await storage.saveWalletInfo({'id': mId, 'balance': merchant}, 'merchant');

    print('✅ Wallets loaded & saved to storage.');
    // If needed, load transactions afterward
    // await loadTransactions();

  } catch (e) {
    print('❌ Failed to load wallets: $e');
  }
}


  // /// 🔄 Load transactions from API
  // Future<void> loadTransactions() async {
  //   final user = await storage.getUserDetails();
  //   if (user == null || user['id'] == null) {
  //     transactions.clear();
  //     return;
  //   }

  //   final userId = user['id'];
  //   try {
  //     final txnList = await api.getTransactions(userId);
  //     transactions.value = txnList.map((t) {
  //       return "${t.id} • ${t.status} • RM${t.amount.toStringAsFixed(2)}";
  //     }).toList();

  //     // Optionally save to storage if you want offline support
  //     await storage.saveTransactions(transactions.toList());

  //     print('✅ Transactions loaded successfully.');
  //   } catch (e) {
  //     print('❌ Failed to load transactions: $e');
  //     transactions.clear();
  //   }
  // }

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
      await api.topUpWallet(walletId, amount);
      print('✅ Top-up successful.');
      await loadWallets(); // Refresh wallets and transactions
    } catch (e) {
      print('❌ Top-up failed: $e');
    }
  }
}
