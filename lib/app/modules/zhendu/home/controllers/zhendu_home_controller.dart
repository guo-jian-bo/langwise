import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/toast_utils.dart';

class ZhenduHomeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxInt loadStatus = (-1).obs;

  final RxString description = ''.obs;
  final RxString footer = ''.obs;

  final RxList<ZhenduTheaterEntity> theaters = <ZhenduTheaterEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    initPage();
  }

  Future<void> initPage() async {
    isLoading.value = true;
    loadStatus.value = -1;
    try {
      // load
      ToastUtils.showLoading();
      final resp = await ZhenduRequest.getCategoryList();
      if (resp == null) {
        loadStatus.value = 1;
        return;
      }
      description.value = resp.description ?? '';
      footer.value = resp.footer ?? '';
      theaters.assignAll(resp.items);
      loadStatus.value = theaters.isEmpty ? 4 : 0;
    } finally {
      ToastUtils.hideLoading();
      isLoading.value = false;
    }
  }
}

