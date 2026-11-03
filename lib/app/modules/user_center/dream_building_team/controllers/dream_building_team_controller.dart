import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';

class DreamBuildingTeamController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  DreamBuildingTeamController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.DREAM_BUILDING_TEAM;

  @override
  String get breadcrumbTitle => "特别鸣谢";
  
  final RxList<DreamBuildingTeamEntity> dataList = <DreamBuildingTeamEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
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
