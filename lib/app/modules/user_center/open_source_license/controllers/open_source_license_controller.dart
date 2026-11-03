import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';

class OpenSourceLicenseController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  OpenSourceLicenseController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.OPEN_SOURCE_LICENSE;

  @override
  String get breadcrumbTitle => "致谢与开源许可";

  final RxString openSourceLicense = "".obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
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
