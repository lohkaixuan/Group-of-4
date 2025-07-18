import 'package:get/get.dart';

class LanguageController extends GetxController {
  // true = English, false = BM
  RxBool isEnglish = true.obs;

  void toggleLanguage() {
    isEnglish.value = !isEnglish.value;
  }

  String t(String en, String bm) {
    return isEnglish.value ? en : bm;
  }
}