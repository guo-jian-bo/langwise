import 'package:api/entities/entities.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../utils/utils.dart';

class CourseUnitGrammarDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  CourseUnitGrammarDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.COURSE_UNIT_GRAMMAR_DETAILS;

  @override
  String get breadcrumbTitle => "语法";

  // 传进来的参数
  int? unitId;
  int? targetUid;
  bool isManagement = false;


  final Rx<ManageUnitGrammarTargetDetailEntity> targetDetail = ManageUnitGrammarTargetDetailEntity().obs;
  final RxList<CourseUnitTargetSentenceGrammarGroupEntity> dataList = <CourseUnitTargetSentenceGrammarGroupEntity>[].obs;
  /// 是否加载中
  final RxBool isLoading = false.obs;


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      unitId = Get.arguments['unitId'];
      targetUid = Get.arguments['targetUid'];
      isManagement = Get.arguments['isManagement'] ?? false;
    }
    refreshList();
  }

  /// 刷新列表
  Future<void> refreshList() async{
    await Future.wait([
      gettargetDetails(),
      getListData(),
    ]);
  }

  /// 获取target详情
  Future<void> gettargetDetails() async{
    try {
      ResponseEntity<ManageUnitGrammarTargetDetailEntity?>? responseEntity = await UnitUtil.unitGrammarTargetDetail(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          parameters: {
            'targetUid': targetUid,
            'isManagement': isManagement,
          },
        ),
      );
      if(responseEntity == null) return;
      ManageUnitGrammarTargetDetailEntity? entity = responseEntity.data;
      if(entity == null) return;
      targetDetail.value = entity;

    } catch (_) {}
  }

  /// 获取语法详情页底部签发组列表。
  Future<void> getListData() async{
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      if (unitId == null || targetUid == null) {
        dataList.clear();
        return;
      }

      List<CourseUnitTargetSentenceGrammarGroupEntity>? entity;
      if (isManagement) {
        entity = await CourseConsoleRequest.getCourseUnitGrammarDetailsGroupList(
          unitId: unitId!,
          params: {
            "targetUid": targetUid,
          },
        );
      } else {
        entity = await CourseAppUtil.getCourseUnitGrammarDetailsGroupList(
          unitId: unitId!,
          targetUid: targetUid!,
        );
      }
      if (entity == null) return;
      dataList.value = entity;
    } finally{
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }
}
