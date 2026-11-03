import 'package:get/get.dart';
import 'package:flutter/services.dart';

class OpenSourceLicenseController extends GetxController {
  final RxString openSourceLicense = "".obs;

  @override
  void onInit() {
    super.onInit();
    readOpenSourceLicense();
  }

  Future<void> readOpenSourceLicense() async {
    openSourceLicense.value = await rootBundle.loadString('assets/txt/source_license.txt');
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
