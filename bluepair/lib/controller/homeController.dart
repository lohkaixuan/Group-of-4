import 'package:get/get.dart';

class HomeController extends GetxController {
  // observable wallet amount
  RxDouble walletAmount = 0.0.obs;

  // you can call this when you fetch from API or after a transaction
  void setAmount(double amount) {
    walletAmount.value = amount;
  }

  // simulate adding money
  void addAmount(double add) {
    walletAmount.value += add;
  }
}
