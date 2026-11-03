import 'package:get/get.dart';
import 'package:langwise/common/https/https.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';

class MissionTestResultController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  MissionTestResultController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MISSION_TEST_RESULT;

  @override
  String get breadcrumbTitle => "单元测试结果";

  /// 单元测试单次记录id
  int? unitTestRecordId;
  /// 单元测试记录id
  int? targetId;


  final Rx<MissionTestResultEntity> resultDetail = MissionTestResultEntity().obs;
 
  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      unitTestRecordId = Get.arguments["unitTestRecordId"];
      targetId = Get.arguments["targetId"];

      if(unitTestRecordId != null){
        getMissionTestResult();
      }else{
        getMissionTestRecord();
      }
    }
  }

  /// 获取单元测试单次记录详情
  Future<void> getMissionTestResult() async {
    if(unitTestRecordId == null) return;
    try {
      ToastUtils.showLoading();
      MissionTestResultEntity? res = await MissionRequest.getTestMissionResult(unitTestRecordId!);
      if(res == null) return;
      resultDetail.value = res;
    }  finally {
      ToastUtils.hideLoading();
    }
  }

  /// 获取单元测试记录详情
  Future<void> getMissionTestRecord() async {
    if(targetId == null) return;
    try {
      ToastUtils.showLoading();
      MissionTestResultEntity? res = await MissionRequest.getTestMissionRecord(targetId!);
      if(res == null) return;
      resultDetail.value = res;
    }  finally {
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
