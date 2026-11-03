import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';

class IllegalReportingController extends GetxController {

  final RxString email = "".obs;

  @override
  void onInit() {
    super.onInit();
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
