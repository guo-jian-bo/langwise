import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/prize.dart';
import 'package:langwise/common/https/prize.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../utils/manage_breadcrumb_utils.dart';

class ManagePrizeController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManagePrizeController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_PRIZE;

  @override
  String get breadcrumbTitle => '奖励管理';

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<PrizeItem> prizeList = <PrizeItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    fetchPrizeList();
  }

  Future<void> fetchPrizeList() async {
    isLoading.value = true;
    var res = await PrizeRequest.getPrizeList();
    if (res == null) {
      errorMessage.value = '获取奖励列表失败';
      isLoading.value = false;
      return;
    }
    prizeList.value = res.list;
    isLoading.value = false;
  }


  Future<void> createPrize({required String name, required String description, required String type, required int value, required int duration, required String durationType}) async {
    bool res = await PrizeRequest.createPrize(name: name, description: description, type: type, value: value, duration: duration, durationType: durationType);
    if (res) {
      await fetchPrizeList();
    }else{
      ToastUtils.showToast(text: '创建失败');
    }
  }
}
