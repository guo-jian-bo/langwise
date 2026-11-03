
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:wise_http/wise_http.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/enum/enum.dart';
import '../../../../../../../../common/https/https.dart';
import '../../../../../../../routes/routes.dart';
import '../../../../../dialog/select_clmu_dialog.dart';
import '../../../../../utils/utils.dart';
import '../../../common/manage_select_persona_variants_dialog.dart';
import '../models/manage_create_unit_patha_model.dart';
import '../models/manage_create_unit_pathb_model.dart';
import '../views/manage_create_unit_script_handwritten_creativity_dialog.dart';

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

  /// 选择的故事场景
  final Rx<LanguageCode> selectSceneArea = LanguageCode.zh.obs;

  /// 选择的生产路径 0=路径 A：先生成创意再生成 1=路径 B：选题材写创意 2=路径 C：只选题材
  final RxInt selectProductionPath = 0.obs;

  /// 剧本题材列表
  final RxList<ManageScriptGenreEntity> scriptGenreList = <ManageScriptGenreEntity>[].obs;

  /// 选择的角色变体
  final RxList<ManageSelectPersonaVariantsReslut> selectPersonaVariant = <ManageSelectPersonaVariantsReslut>[].obs;


  // ======================== 路径A ========================
  /// 路径A 创意候选数量
  final TextEditingController pathACandidateCountController = TextEditingController(text: "1");
  /// 创意列表
  final RxList<ManageCreateUnitPathAModel> pathAList = <ManageCreateUnitPathAModel>[].obs;
  /// 创意列表取消token
  CancelToken pathACancelToken = CancelToken();
  /// 创意列表请求状态 0=未请求 1=请求中 2=请求成功 3=无数据
  final RxInt pathARequestStatus = 0.obs;

  // ======================== 路径B ========================

  /// 路径B 题材列表
  final RxList<ManageCreateUnitPathBModel> pathBList = <ManageCreateUnitPathBModel>[].obs;

  // ======================== 路径C ========================
  /// 选择题材nids
  final RxSet<String> selectGenreNids = <String>{}.obs;



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
    getScriptGenre();
  }

  /// 选择单元
  Future<void> selectUnit(NewUnitResponseEntity data) async{
    selectCLMUData.value.unitId = data.uid;
    selectCLMUData.value.unitName = data.name;
    selectCLMUData.refresh();
    getUnitKnowledge();
    getScriptGenre();
  }

  /// 查询单元知识点列表
  Future<void> getUnitKnowledge() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "contentTypes": [
          ElementsCardType.word.value,
          ElementsCardType.phrase.value,
          ElementsCardType.sentence.value,
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

  /// 选择故事场景
  void selectSceneAreaFun(LanguageCode code){
    selectSceneArea.value = code;
  }


  /// 查询剧本题材
  Future<void> getScriptGenre() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "unitId": selectCLMUData.value.unitId,
      };
      List<ManageScriptGenreEntity>? res = await LanguageConsoleDramaRequest.getScriptGenreList(data: reqData);
      if(res == null) return;
      scriptGenreList.clear();
      pathBList.clear();
      for(ManageScriptGenreEntity item in res){
        scriptGenreList.add(item);
        pathBList.add(ManageCreateUnitPathBModel(
          genre: item,
          sceneCountController: TextEditingController(text: "3"),
          storyCreativityController: TextEditingController(),
        ));
      }
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 选择生产路径
  void selectProductionPathFun(int type){
    selectProductionPath.value = type;
  }

  /// 查询创意列表
  Future<void> getPathAList() async{
    if(selectCLMUData.value.unitId == null) return ToastUtils.showToast(text: "请先选择单元");
    if(pathACandidateCountController.text.isEmpty) return ToastUtils.showToast(text: "请输入创意候选数量");

    try {
      pathAList.clear();
      pathARequestStatus.value = 1;
      Map<String, dynamic> reqData = {
        "moduleId": selectCLMUData.value.moduleId,
        "unitId": selectCLMUData.value.unitId,
        "lang": "en",
        "locale": selectSceneArea.value.local,
        "numberOfIdeas": pathACandidateCountController.text,
      };
      List<ManageUnitCreativityEntity>? res = await LanguageConsoleDramaRequest.getUnitCreativityList(
        data: reqData,
        cancelToken: pathACancelToken,
      );
      if(res == null) {
        pathARequestStatus.value = 3;
        return;
      }
      pathAList.clear();
      for(ManageUnitCreativityEntity item in res){
        pathAList.add(ManageCreateUnitPathAModel(
          data: item,
          sceneCountController: TextEditingController(text: item.sceneNumber?.toString()??"3"),
          storyCreativityController: TextEditingController(text: item.synopsis),
          genreNid: item.genre,
        ));
      }
      if(pathAList.isEmpty){
        pathARequestStatus.value = 3;
        return;
      }
      pathARequestStatus.value = 2;
    } finally{}
  }

  /// 根据创意内的题材nid查询题材数据
  ManageScriptGenreEntity? getGenreDetail(String? genre){
    if(genre == null) return null;
    for(var item in scriptGenreList){
      if(item.nid == genre){
        return item;
      }
    }
    return null;
  }

  /// 选择创意
  void selectPathA(ManageCreateUnitPathAModel item){
    item.isSelected = !item.isSelected;
    pathAList.refresh();
  }


  /// 编辑手写创意
  Future<void> editHandwrittenCreativity(BuildContext context, ManageCreateUnitPathBModel item) async{
    int? sceneCount = int.tryParse(item.sceneCountController.text);
    String? storyCreativity = item.storyCreativityController.text;

    ManageCreateUnitScriptHandwrittenCreativityResult? res = await ManageCreateUnitScriptHandwrittenCreativityDialog.show(
      context: context,
      genre: item.genre,
      sceneCount: sceneCount,
      story: storyCreativity,
    );
    if(res == null) return;
    item.sceneCountController.text = res.sceneCount.toString();
    item.storyCreativityController.text = res.story??"";
    item.isSelected = true;
    pathBList.refresh();
  }

  /// 取消选择手写创意
  void cancelSelectHandwrittenCreativity(ManageCreateUnitPathBModel item){
    item.isSelected = false;
    item.sceneCountController.text = "3";
    item.storyCreativityController.text = "";
    pathBList.refresh();
  }

  /// 路径C 选择题材
  void selectGenre(ManageScriptGenreEntity data){
    if(data.nid == null) return;
    if(selectGenreNids.contains(data.nid)){
      selectGenreNids.remove(data.nid);
    }else{
      selectGenreNids.add(data.nid!);
    }
  }


  

  /// 指定角色变体
  Future<void> showVariants(BuildContext context) async{
    ManageSelectPersonaVariantsReslut? res = await ManageSelectPersonaVariantsDialog.show(
      context: context,
      languageCode: selectSceneArea.value,
    );
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
        "lang": "en",
        "locale": selectSceneArea.value.local,
        "mustIncludePersonaVariants": mustIncludePersonaVariantsNids,
      };

      if(selectProductionPath.value == 0){
        List<Map<String, dynamic>> ideas = [];
        for(var item in pathAList){
          if(!item.isSelected) continue;
          ideas.add({
            "genre": item.genreNid,
            "scene_number": item.sceneCountController.text,
            "synopsis": item.storyCreativityController.text,
          });
        }
        if(ideas.isEmpty) return ToastUtils.showToast(text: "请先选择至少一个创意候选");
        reqData["ideas"] = ideas;
      }else if(selectProductionPath.value == 1){
        List<Map<String, dynamic>> ideas = [];
        for(var item in pathBList){
          if(!item.isSelected) continue;
          ideas.add({
            "genre": item.genre.nid,
            "scene_number": item.sceneCountController.text,
            "synopsis": item.storyCreativityController.text,
          });
        }
        if(ideas.isEmpty) return ToastUtils.showToast(text: "请先至少添加一个题材到生成计划");
        reqData["ideas"] = ideas;
      }else if(selectProductionPath.value == 2){
        reqData['genres'] = selectGenreNids.toList();
      }

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
    pathACancelToken.cancel();
    super.onClose();
  }
}
