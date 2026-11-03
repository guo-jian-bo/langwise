import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';

class CourseLevelSelectUnitController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  CourseLevelSelectUnitController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.COURSE_LEVEL_SELECT_UNIT;

  @override
  String get breadcrumbTitle => "选择单元";

  int? courseId;
  int? levelId;
  int? moduleId;
  String? subTitle;
  int fromType = 0;


  final RxList<CourseLevelModuleUnitEntityUnits> unitList = <CourseLevelModuleUnitEntityUnits>[].obs;

  final RxInt selectId = (-1).obs;


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      courseId = Get.arguments["courseId"];
      levelId = Get.arguments["levelId"];
      moduleId = Get.arguments["moduleId"];
      fromType = Get.arguments["fromType"]??0;
      subTitle = Get.arguments["subTitle"];
    }
    getUnitList();
  }

  Future<void> getUnitList() async{
    if(courseId == null || levelId == null || moduleId == null) return;
    try {
      ToastUtils.showLoading();
      CourseLevelModuleUnitEntity? entity = await OfficialCourseDetailsLevelRequest.getCourseLevelModuleUnitList(
        courseId!, 
        levelId!, 
        moduleId!,
      );
      if(entity == null) return;
      if(entity.units == null) return;
      List<CourseLevelModuleUnitEntityUnits?> list = entity.units??[];
      unitList.clear();
      for(int i = 0; i < list.length; i++){
        if(list[i] == null) continue;
        unitList.add(list[i]!);
      }
    } finally{
      ToastUtils.hideLoading();
    }
    
  }

  /// 选择单元
  void selectUnit(int? id){
    if(id == null) return;
    selectId.value = id;
  }

  /// 确定选择
  void submit(){
    if(selectId.value == -1) {
      ToastUtils.showToast(text: "请选择单元");
      return;
    }
    // if(fromType == 4){
      // offNamed(Routes.NEW_CREATE_STUDY_PLAN,arguments: {"unitId": selectId.value,"moduleId": moduleId,"levelId": levelId,"courseId": courseId});
    // }else{
      Get.back(result: unitList.firstWhere((element) => element.unitId == selectId.value));
    // }
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
