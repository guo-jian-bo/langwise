import 'package:get/get.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';

class SelectLearningModuleController extends GetxController {
  final String tagText;
  SelectLearningModuleController({required this.tagText});
  
  int? courseId;
  List<String>? initDirections;
  final RxString appbarTitle = "".obs;

  final RxList<LessonTypeEntityList> moduleList = <LessonTypeEntityList>[].obs;
  final RxList<LessonTypeEntityChoices> choicesList = <LessonTypeEntityChoices>[].obs;

  final RxList<String> selectDirections = <String>[].obs;
  final RxInt selectTipsIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if(Get.arguments != null){
      courseId = Get.arguments["courseId"];
      initDirections = Get.arguments["initDirections"];
      appbarTitle.value = Get.arguments["title"]??"";

      if(initDirections != null){
        selectDirections.addAll(initDirections!);
      }
    }
    getModuleList();
  }

  Future<void> getModuleList() async{
    if(courseId == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> params = {
        "courseId": courseId,
      };
      LessonTypeEntity? entity = await StudyPlanRequest.getLessonTypeList(params);
      if(entity == null) return;
      List<LessonTypeEntityList?> list = entity.list??[];
      List<LessonTypeEntityChoices?> choices = entity.choices??[];
      for(var item in list){
        if(item == null) continue;
        moduleList.add(item);
      }
      for(var item in choices){
        if(item == null) continue;
        choicesList.add(item);
      }
      checkSelectTipsIndex();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 选择推荐
  void selectTips(int index){
    selectTipsIndex.value = index;

    selectDirections.clear();
    for(String? item in choicesList[index].directions??[]){
      if(item == null) continue;
      selectDirections.add(item);
    }
  }

  /// 判断用户选择的是哪个推荐
  void checkSelectTipsIndex(){
    // 默认设置为-1（表示没有匹配的推荐）
    selectTipsIndex.value = -1;
    
    // 遍历所有推荐选项
    for(int i = 0; i < choicesList.length; i++){
      // 获取当前推荐选项的方向列表
      List<String> directions = [];
      for(String? item in choicesList[i].directions ?? []){
        if(item == null) continue;
        directions.add(item);
      }
      
      // 检查当前选择的方向列表是否与推荐选项完全匹配
      if(directions.length == selectDirections.length && 
         directions.every((element) => selectDirections.contains(element)) &&
         selectDirections.every((element) => directions.contains(element))){
        // 找到匹配项，设置索引并退出循环
        selectTipsIndex.value = i;
        break;
      }
    }
  }

  void selectModule(LessonTypeEntityList item){
    if(item.direction == null) return;
    if(item.forceSelect) {
      if(!selectDirections.contains(item.direction)){
        selectDirections.add(item.direction!);
      }
      return;
    }
    if(selectDirections.contains(item.direction)){
      selectDirections.remove(item.direction);
    } else {
      selectDirections.add(item.direction!);
    }
    checkSelectTipsIndex();
  }

  void confirm(){
    if(selectDirections.isEmpty){
      ToastUtils.showToast(text: "请选择课时类型");
      return;
    }
    List<LessonTypeEntityList> list = [];
    for(var item in moduleList){
      if(selectDirections.contains(item.direction)){
        list.add(item);
      }
    }
    Get.back(result: list);
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
