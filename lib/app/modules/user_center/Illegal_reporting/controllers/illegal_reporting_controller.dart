import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';

class IllegalReportingController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  IllegalReportingController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ILLEGAL_REPORTING;

  @override
  String get breadcrumbTitle => "违法不良信息举报";

  final RxString email = "".obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    getEmail();
  }

  Future<void> getEmail() async {
    try {
      ToastUtils.showLoading();
      CustomerInfoEntity? customerInfoEntity = await UserRequest.getCustomerInfo();
      if(customerInfoEntity == null) return;
      email.value = customerInfoEntity.email ?? "";
    } finally{
      ToastUtils.hideLoading();
    }
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
