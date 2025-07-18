import 'package:get/get.dart';

class BottomNavController extends GetxController {
  // current selected index (0 = Home, 1 = Profile)
  RxInt selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}
