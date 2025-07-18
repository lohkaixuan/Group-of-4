import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluepair/controller/langaugeController.dart';

PreferredSizeWidget buildCommonAppBar(String enTitle, String bmTitle) {
  final lang = Get.find<LanguageController>();
  return AppBar(
    centerTitle: true,
    // ✅ Make the title reactive
    title: Obx(() => Text(
          lang.t(enTitle, bmTitle),
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
    actions: [
      IconButton(
        icon: const Icon(Icons.language),
        tooltip: lang.t("Switch Language", "Tukar Bahasa"),
        onPressed: () {
          lang.toggleLanguage();
        },
      ),
    ],
  );
}
