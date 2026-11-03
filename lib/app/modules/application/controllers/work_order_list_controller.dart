
import 'package:get/get.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/stores/stores.dart';

class WorkOrderListController extends GetxController {
  
  /// 工单数量
  final RxInt workOrderCount = 0.obs;
  /// 是否显示工单按钮
  final RxBool showTicket = false.obs;


  Future<void> getWorkOrderList() async {
    if(!UserStore.to.isLogin) return;
    try {
      workOrderCount.value = 0;
      UserWordOrderCountEntity? userWordOrderCountEntity = await AccountUtil.gtWorkOrderCount();
      if (userWordOrderCountEntity == null) return;
      workOrderCount.value = userWordOrderCountEntity.needDealtCount ?? 0;
      showTicket.value = userWordOrderCountEntity.showTicket ?? false;

    } catch (_) {}
  }


}
