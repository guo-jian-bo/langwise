import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';

class ZhenxieController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  ZhenxieController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE;

  @override
  String get breadcrumbTitle => "甄写";

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
