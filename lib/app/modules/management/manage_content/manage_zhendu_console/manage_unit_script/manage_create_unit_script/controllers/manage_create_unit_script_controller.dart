
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/enum/enum.dart';
import '../../../../../../../../common/https/https.dart';
import '../../../../../../../routes/routes.dart';
import '../../../../../dialog/select_clmu_dialog.dart';
import '../../../../../utils/utils.dart';
import '../../../common/manage_select_persona_variants_dialog.dart';

class ManageCreateUnitScriptController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageCreateUnitScriptController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_CREATE_UNIT_SCRIPT;

  @override
  String get breadcrumbTitle => '新建单元剧本';

  /// 选择的课程/等级/模块/单元
  final Rx<SelectCLMUReslut> selectCLMUData = SelectCLMUReslut().obs;

  /// 单元列表
  final RxList<NewUnitResponseEntity> unitList = <NewUnitResponseEntity>[].obs;

  /// 单元知识点列表
  final RxList<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = <UnitKnowledgePointsEntityKnowledgeList>[].obs;

  /// 选择的单元知识点ids
  final RxSet<int> selectknowledgeIds = <int>{}.obs;

  /// 剧本题材列表
  final RxList<ManageScriptGenreEntity> scriptGenreList = <ManageScriptGenreEntity>[].obs;

  /// 选择题材nids
  final RxSet<String> selectGenreNids = <String>{}.obs;

  /// 选择的故事场景
  final Rx<LanguageCode?> selectSceneArea = Rx(null);

  /// 选择的角色变体
  final RxList<ManageSelectPersonaVariantsReslut> selectPersonaVariant = <ManageSelectPersonaVariantsReslut>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    getScriptGenre();
  }

  /// 选择课程等级模块单元
  Future<void> selectCLMU(BuildContext context) async{
    SelectCLMUReslut? res = await SelectCLMUDialog.show(
      context: context,
      initData: selectCLMUData.value,
    );
    if(res == null) return;

    if(res.courseId == selectCLMUData.value.courseId 
      && res.levelId == selectCLMUData.value.levelId
      && res.moduleId == selectCLMUData.value.moduleId
      && res.unitId == selectCLMUData.value.unitId){
        return;
    }

    selectCLMUData.value = res;

    unitList.value = res.units??[];

    getUnitKnowledge();
  }

  /// 选择单元
  Future<void> selectUnit(NewUnitResponseEntity data) async{
    selectCLMUData.value.unitId = data.uid;
    selectCLMUData.value.unitName = data.name;
    selectCLMUData.refresh();
    getUnitKnowledge();
  }

  /// 查询单元知识点列表
  Future<void> getUnitKnowledge() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "contentTypes": [
          ElementsCardType.word.value,
          ElementsCardType.phrase.value,
        ],
      };
      UnitKnowledgePointsEntity? entity = await OfficialCourseDetailsRequest.getAdminUnitTarget(
        selectCLMUData.value.unitId!,
        data: reqData,
      );
      
      if(entity == null) return;

      List<UnitKnowledgePointsEntityKnowledgeList?> list = entity.knowledgeList??[];
      knowledgeList.clear();
      for (var item in list) {
        if(item == null) continue;
        knowledgeList.add(item);
      }

    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 选择单元知识点
  void selectUnitKnowledge(UnitKnowledgePointsEntityKnowledgeList data){
    if(data.uid == null) return;
    if(selectknowledgeIds.contains(data.uid)){
      selectknowledgeIds.remove(data.uid);
    }else{
      selectknowledgeIds.add(data.uid!);
    }
  }


  /// 查询剧本题材
  Future<void> getScriptGenre() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "order": "-created",
      };
      List<ManageScriptGenreEntity>? res = await LanguageConsoleDramaRequest.getScriptGenreList(parameters: parameters);
      if(res == null) return;
      for(ManageScriptGenreEntity item in res){
        scriptGenreList.add(item);
      }
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 选择题材
  void selectGenre(ManageScriptGenreEntity data){
    if(data.nid == null) return;
    if(selectGenreNids.contains(data.nid)){
      selectGenreNids.remove(data.nid);
    }else{
      selectGenreNids.add(data.nid!);
    }
  }

  /// 选择故事场景
  void selectSceneAreaFun(LanguageCode code){
    selectSceneArea.value = code;
  }
  

  /// 指定角色变体
  Future<void> showVariants(BuildContext context) async{
    ManageSelectPersonaVariantsReslut? res = await ManageSelectPersonaVariantsDialog.show(context: context);
    if(res == null) return;
    selectPersonaVariant.add(res);
  }

  /// 移除角色变体
  void removeVariant(int index) {
    selectPersonaVariant.removeAt(index);
  }




  /// 创建剧本
  Future<void> createScript() async{
    if(selectCLMUData.value.unitId == null) return ToastUtils.showToast(text: "请选择单元");
    if(selectknowledgeIds.isEmpty) return ToastUtils.showToast(text: "请选择单元知识点");
    if(selectGenreNids.isEmpty) return ToastUtils.showToast(text: "请选择剧本题材");
    if(selectSceneArea.value == null) return ToastUtils.showToast(text: "请选择故事场景地区");
    // if(selectPersonaVariant.isEmpty) return ToastUtils.showToast(text: "请指定角色变体");

    try {
      ToastUtils.showLoading();

      List<Map<String, dynamic>> usedKnowledgePoints = [];

      for(var item in knowledgeList){
        if(selectknowledgeIds.contains(item.uid)){
          usedKnowledgePoints.add({
            "contentId": item.contentId,
            "contentType": item.contentType,
            "semanticId": item.semanticId,
          });
        }
      }

      List<String> mustIncludePersonaVariantsNids = [];

      for (var element in selectPersonaVariant) {
        if(element.variant.nid == null) continue;
        mustIncludePersonaVariantsNids.add(element.variant.nid!);
      }

      Map<String, dynamic> reqData = {
        "moduleId": selectCLMUData.value.moduleId,
        "unitId": selectCLMUData.value.unitId,
        "used_knowledge_points": usedKnowledgePoints,
        "genres": selectGenreNids.toList(),
        "lang": selectSceneArea.value?.value,
        "mustIncludePersonaVariants": mustIncludePersonaVariantsNids,
      };

      String? res = await LanguageConsoleDramaRequest.createUnitScript(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      Get.back(result: true);

    } finally{
      ToastUtils.hideLoading();
    }
  }


  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
