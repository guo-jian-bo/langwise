import 'package:get/get.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';

class DreamBuildingTeamController extends GetxController {
  
  final RxList<DreamBuildingTeamEntity> dataList = <DreamBuildingTeamEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    getListData();
  }

  Future<void> getListData() async{
    try {
      ToastUtils.showLoading();
      List<DreamBuildingTeamEntity>? list = await UserRequest.getDreamBuildingTeamList();
      if(list == null) return;
      dataList.value = list;
    } finally {
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
