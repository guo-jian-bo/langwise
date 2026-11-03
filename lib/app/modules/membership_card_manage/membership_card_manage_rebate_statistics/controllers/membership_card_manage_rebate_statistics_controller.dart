import 'package:api/entities/response.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/membership_card_manage.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../models/membership_card_manage_rebate_statistics_model.dart';

class MembershipCardManageRebateStatisticsController extends GetxController {
  RxInt selectedIndex = 0.obs;

  final RxMap<String, bool> _expandStates = <String, bool>{
    'MONTH_current': false,
    'MONTH_last': false,
    'QUARTER_current': false,
    'QUARTER_last': false,
    'YOUR_current': false,
    'YOUR_last': false,
  }.obs;

  Rx<MembershipCardManageRebateStatisticsEntity> statisticsEntity =
      MembershipCardManageRebateStatisticsEntity().obs;

  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
  );
  bool isRequesting = false;

  String _expandKey(String? periodType, bool isCurrent) {
    final type = (periodType == null || periodType.isEmpty) ? 'UNKNOWN' : periodType;
    return '${type}_${isCurrent ? 'current' : 'last'}';
  }

  bool isExpanded(String? periodType, {required bool isCurrent}) {
    return _expandStates[_expandKey(periodType, isCurrent)] ?? false;
  }

  void toggleExpanded(String? periodType, {required bool isCurrent}) {
    final key = _expandKey(periodType, isCurrent);
    _expandStates[key] = !(_expandStates[key] ?? false);
  }

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  @override
  dispose() {
    refreshController.dispose();
    super.dispose();
  }

  initData() async {
    try {
      if (isRequesting) return;
      isRequesting = true;
      ToastUtils.showLoading();
      ResponseEntity<MembershipCardManageRebateStatisticsEntity>?
          responseEntity = await MembershipCardManageApi.rebateStatistics();
      if (responseEntity?.data == null) return;
      statisticsEntity.value = responseEntity!.data!;
    } finally {
      isRequesting = false;
      refreshController.finishRefresh();
      ToastUtils.hideLoading();
    }
  }

  String convertNumberToChinese(int number) {
    const Map<int, String> numberMap = {
      0: '零',
      1: '一',
      2: '二',
      3: '三',
      4: '四',
      5: '五',
      6: '六',
      7: '七',
      8: '八',
      9: '九',
    };

    return number.toString().split('').map((digit) {
      return numberMap[int.parse(digit)] ?? '';
    }).join('');
  }
}
