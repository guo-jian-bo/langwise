import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wise_http/wise_http.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/enum/enum.dart';
import '../../../../../../../../common/https/https.dart';
import '../../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../../utils/utils.dart';
import '../../../../../../../routes/routes.dart';
import '../../../../../utils/utils.dart';
import '../../../common/manage_select_persona_variants_dialog.dart';
import '../../../../../common/manage_select_semantic_dialog.dart';
import '../../../enums/manage_script_mode_enum.dart';
import '../models/manage_create_vocabulary_patha_model.dart';
import '../models/manage_create_vocabulary_pathb_model.dart';
import '../views/manage_create_vocabulary_script_handwritten_creativity_dialog.dart';

class ManageCreateVocabularyScriptController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageCreateVocabularyScriptController({required this.tag});

  /// 面包屑路由标识
  @override
  String get breadcrumbRoute => Routes.MANAGE_CREATE_VOCABULARY_SCRIPT;

  /// 面包屑标题
  @override
  String get breadcrumbTitle => '新建词汇剧本';

  int limit = 20;
  int offset = 0;
  int total = 0;
  bool isLoading = true;
  final RxList<EnKnowledgeEntity> knowledgeList = <EnKnowledgeEntity>[].obs;

  /// 选择的知识点
  final RxList<EnKnowledgeEntity> selectKnowledgeList = <EnKnowledgeEntity>[].obs;

  /// 知识点列表滚动控制器
  final ScrollController knowledgeScrollController = ScrollController();

  /// 知识点类型
  final List<KnowledgeTypeEnum> knowledgeTypeList = [KnowledgeTypeEnum.EN_WORD, KnowledgeTypeEnum.EN_PHRASE];

  /// 当前知识点类型
  final Rx<KnowledgeTypeEnum> currentKnowledgeType = KnowledgeTypeEnum.EN_WORD.obs;

  /// 知识点搜索输入框 uid
  final TextEditingController uidSearchInput = TextEditingController();

  /// 知识点搜索输入框 content
  final TextEditingController contentSearchInput = TextEditingController();

  /// 知识点搜索输入框 content 精确匹配
  final TextEditingController contentSearchInputExact = TextEditingController();

  /// 知识点搜索输入框 音标
  final TextEditingController pronunciationSearchInput = TextEditingController();

  /// 剧本题材列表
  final RxList<ManageScriptGenreEntity> scriptGenreList = <ManageScriptGenreEntity>[].obs;

  /// 选择的故事场景
  final Rx<LanguageCode> selectSceneArea = LanguageCode.zh.obs;

  /// 选择的角色变体
  final RxList<ManageSelectPersonaVariantsReslut> selectPersonaVariant = <ManageSelectPersonaVariantsReslut>[].obs;

  /// 选择的生产路径 0=路径 A：先生成创意再生成 1=路径 B：选题材写创意 2=路径 C：只选题材
  final RxInt selectProductionPath = 0.obs;

  // ======================== 路径A ========================
  /// 路径A 创意候选数量
  final TextEditingController pathACandidateCountController = TextEditingController(text: "1");
  /// 创意列表
  final RxList<ManageCreateVocabularyPathAModel> pathAList = <ManageCreateVocabularyPathAModel>[].obs;
  /// 创意列表取消token
  CancelToken pathACancelToken = CancelToken();
  /// 创意列表请求状态 0=未请求 1=请求中 2=请求成功 3=无数据
  final RxInt pathARequestStatus = 0.obs;

  // ======================== 路径B ========================

  /// 路径B 题材列表
  final RxList<ManageCreateVocabularyPathBModel> pathBList = <ManageCreateVocabularyPathBModel>[].obs;

  // ======================== 路径C ========================
  /// 选择题材nids
  final RxSet<String> selectGenreNids = <String>{}.obs;



  /// 初始化页面数据
  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    listenScroll();
    initData();
  }

  /// 并行初始化词汇与题材数据
  Future<void> initData() async{
    try {
      ToastUtils.showLoading();
      await getKnowledgeList(showLoading: false);
      await getScriptGenre(showLoading: false);
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 监听列表滚动进行分页加载
  void listenScroll(){
    knowledgeScrollController.addListener(() {
      if(knowledgeScrollController.position.pixels >= knowledgeScrollController.position.maxScrollExtent - 200 && !knowledgeScrollController.position.outOfRange){
        if(!isLoading && knowledgeList.length < total){
          offset += limit;
          getKnowledgeList();
        }
      }
    });
  }

  /// 切换知识点类型
  Future<void> switchKnowledgeType(KnowledgeTypeEnum type) async{
    currentKnowledgeType.value = type;
    uidSearchInput.clear();
    contentSearchInput.clear();
    contentSearchInputExact.clear();
    pronunciationSearchInput.clear();
    selectKnowledgeList.clear();

    total = 0;
    offset = 0;
    knowledgeList.clear();
    getKnowledgeList();
  }

  /// 获取单词列表
  Future<void> getKnowledgeList({bool showLoading = true}) async{
    isLoading = true;

    try {
      if(showLoading) ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "order": "-in_course_cnt",
        "offset": offset,
        "limit": limit,
      };

      Map<String, dynamic> reqData = {};
      if(uidSearchInput.text.isNotEmpty) {
        List? uids = FilterStripUtils.stringToList(uidSearchInput.text);
        reqData["uid"] = uids;
      }
      if(contentSearchInput.text.isNotEmpty){
        reqData["content"] = contentSearchInput.text;
      }
      if(contentSearchInputExact.text.isNotEmpty){
        reqData["fullContent"] = contentSearchInputExact.text;
      }

      ListResponseEntity<EnKnowledgeEntity>? response;
      if(currentKnowledgeType.value == KnowledgeTypeEnum.EN_WORD){
        if(pronunciationSearchInput.text.isNotEmpty){
          reqData["ipa"] = pronunciationSearchInput.text;
        }
        response = await LanguageConsoleRequest.getEnWordKnowledgeList(
          parameters: parameters,
          data: reqData,
        );
        
      }else{
        response = await LanguageConsoleRequest.getEnPhraseKnowledgeList(
          parameters: parameters,
          data: reqData,
        );
      }

      if(response == null) return;
      total = response.count??0;
      List<EnKnowledgeEntity> newList = response.datas??[];
      _syncSelectedSemantics(newList);
      knowledgeList.addAll(newList);
    } finally{
      isLoading = false;
      if(showLoading) ToastUtils.hideLoading();
    }

  }

  /// 将已选择知识点中的语义回填到当前列表数据
  void _syncSelectedSemantics(List<EnKnowledgeEntity> list){
    for (final item in list) {
      if(item.uid == null) continue;
      for (final selected in selectKnowledgeList) {
        if(selected.uid == item.uid){
          item.selectedSemantics = selected.selectedSemantics;
          break;
        }
      }
    }
  }

  /// 判断知识点是否已被选中
  bool isKnowledgeSelected(EnKnowledgeEntity data){
    if(data.uid == null) return false;
    for (final item in selectKnowledgeList) {
      if(item.uid == data.uid) return true;
    }
    return false;
  }



  /// 重置分页并重新请求知识点列表
  Future<void> reloadKnowledgeList() async{
    total = 0;
    offset = 0;
    knowledgeList.clear();
    await getKnowledgeList();
  }

  /// 清空知识点已选语义
  void _clearSelectedSemantics(EnKnowledgeEntity data){
    data.selectedSemantics = null;
    if(data.uid == null) return;
    for (final item in knowledgeList) {
      if(item.uid == data.uid){
        item.selectedSemantics = null;
        break;
      }
    }
  }

  /// 处理选中集合变化后的联动行为
  Future<void> _afterSelectedChanged() async{
    if(selectKnowledgeList.isEmpty){
      return;
    }

    String firstContent = selectKnowledgeList.first.content ?? "";
    if(contentSearchInputExact.text != firstContent){
      contentSearchInputExact.text = firstContent;
      await reloadKnowledgeList();
    }
  }

  /// 点击知识点行时的选择逻辑
  Future<void> onTapKnowledge(BuildContext context, EnKnowledgeEntity data) async{
    if(data.uid == null) return;

    if(isKnowledgeSelected(data)){
      _clearSelectedSemantics(data);
      selectKnowledgeList.removeWhere((item) => item.uid == data.uid);
      selectKnowledgeList.refresh();
      knowledgeList.refresh();
      await _afterSelectedChanged();
      getScriptGenre(showLoading: false);
      return;
    }

    String content = data.content?.trim() ?? "";
    if(selectKnowledgeList.isNotEmpty){
      String firstContent = selectKnowledgeList.first.content?.trim() ?? "";
      if(content != firstContent){
        ToastUtils.showToast(text: "只能选择相同知识点内容");
        return;
      }
    }

    List<EnKnowledgeEntitySemantics> allSemantics = (data.semantics ?? []).whereType<EnKnowledgeEntitySemantics>().toList();
    if(allSemantics.isEmpty){
      ToastUtils.showToast(text: "该知识点暂无语义");
      return;
    }

    List<EnKnowledgeEntitySemantics> selectedSemantics = [];
    if(allSemantics.length == 1){
      selectedSemantics = [allSemantics.first];
    }else{
      List<EnKnowledgeEntitySemantics>? res = await ManageSelectSemanticDialog.show(
        context: context,
        semantics: allSemantics,
      );
      if(res == null || res.isEmpty) return;
      selectedSemantics = res;
    }

    data.selectedSemantics = selectedSemantics;
  
    if(data.uid != null){
      // 更新选中知识点缓存
      selectKnowledgeList.removeWhere((item) => item.uid == data.uid);
      selectKnowledgeList.add(data);
      selectKnowledgeList.refresh();
      knowledgeList.refresh();
    }

    await _afterSelectedChanged();
    getScriptGenre(showLoading: false);
  }



  /// 查询剧本题材
  Future<void> getScriptGenre({bool showLoading = true}) async{
    try {
      if(showLoading) ToastUtils.showLoading();
      Map<String, dynamic> reqData = {};
      if(selectKnowledgeList.isNotEmpty){
        reqData['subContent'] = {
          "uid": selectKnowledgeList.first.uid,
          "type": selectKnowledgeList.first.contentType,
        };
      }
      List<ManageScriptGenreEntity>? res = await LanguageConsoleDramaRequest.getScriptGenreList(data: reqData);
      if(res == null) return;
      scriptGenreList.clear();
      pathBList.clear();
      for(ManageScriptGenreEntity item in res){
        scriptGenreList.add(item);

        List<ManageVocabularyCreativityEntityMustIncludeSemantics> selectedSemanticList = [];
        for(EnKnowledgeEntity semantic in selectKnowledgeList){
          List<EnKnowledgeEntitySemantics> selectedSemantics = semantic.selectedSemantics??[];
          for(EnKnowledgeEntitySemantics semantic in selectedSemantics){
            selectedSemanticList.add(ManageVocabularyCreativityEntityMustIncludeSemantics(
              uid: semantic.uid,
              text: semantic.definition,
            ));
          }
        }
        pathBList.add(ManageCreateVocabularyPathBModel(
          genre: item,
          sceneCountController: TextEditingController(text: "1"),
          storyCreativityController: TextEditingController(),
          scriptMode: ManageScriptModeEnum.auto,
          mustIncludeSemantics: selectedSemanticList,
        ));
        
      }
    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }

   /// 选择生产路径
  void selectProductionPathFun(int type){
    selectProductionPath.value = type;
  }

  /// 查询创意列表
  Future<void> getPathAList() async{
    if(selectKnowledgeList.isEmpty) return ToastUtils.showToast(text: "请先选择词汇知识点");
    if(pathACandidateCountController.text.isEmpty) return ToastUtils.showToast(text: "请输入创意候选数量");

    try {
      pathARequestStatus.value = 1;
      pathAList.clear();

      List<Map<String, dynamic>> contentList = [];
      for (final item in selectKnowledgeList) {
        if(item.uid == null || item.contentType == null) continue;

        List<EnKnowledgeEntitySemantics> selectedSemantics = item.selectedSemantics??[];
        if(selectedSemantics.isEmpty) continue;

        for(EnKnowledgeEntitySemantics semantic in selectedSemantics){
          contentList.add({
            "uid": item.uid,
            "type": item.contentType,
            "semanticId": semantic.uid,
          });
        }
      }

      Map<String, dynamic> reqData = {
        "content": selectKnowledgeList.first.content,
        "contentList": contentList,
        "lang": "en",
        "locale": selectSceneArea.value.local,
        "numberOfIdeas": pathACandidateCountController.text,
      };
      List<ManageVocabularyCreativityEntity>? res = await LanguageConsoleDramaRequest.getVocabularyCreativityList(
        data: reqData,
        cancelToken: pathACancelToken,
      );
      if(res == null) {
        pathARequestStatus.value = 3;
        return;
      }
      pathAList.clear();
      for(ManageVocabularyCreativityEntity item in res){

        List<ManageCreateVocabularyPathASemanticModel> semantics = [];
        if(item.mustIncludeSemantics != null){
          for(ManageVocabularyCreativityEntityMustIncludeSemantics? semantic in item.mustIncludeSemantics??[]){
            if(semantic == null) continue;
            semantics.add(ManageCreateVocabularyPathASemanticModel(
              data: semantic,
              isSelected: true,
            ));
          }
        }

        pathAList.add(ManageCreateVocabularyPathAModel(
          data: item,
          sceneCountController: TextEditingController(text: item.sceneNumber?.toString()??"3"),
          storyCreativityController: TextEditingController(text: item.synopsis),
          genreNid: item.genre,
          scriptMode: item.scriptModeEnum,
          cefr: item.cefr,
          mustIncludeSemantics: semantics,
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
  void selectPathA(ManageCreateVocabularyPathAModel item){
    item.isSelected = !item.isSelected;
    pathAList.refresh();
  }


  /// 编辑手写创意
  Future<void> editHandwrittenCreativity(BuildContext context, ManageCreateVocabularyPathBModel item) async{
    if(selectKnowledgeList.isEmpty) return ToastUtils.showToast(text: "请先选择词汇知识点");
    
    int? sceneCount = int.tryParse(item.sceneCountController.text);
    String? storyCreativity = item.storyCreativityController.text;


    List<EnKnowledgeEntitySemantics> selectedSemanticList = [];
    for(EnKnowledgeEntity semantic in selectKnowledgeList){
      selectedSemanticList.addAll(semantic.selectedSemantics??[]);
    }

    List<int> selectedSemanticIds = [];
    for(ManageVocabularyCreativityEntityMustIncludeSemantics semantic in item.mustIncludeSemantics){
      if(semantic.uid == null) continue;
      selectedSemanticIds.add(semantic.uid!);
    }

    ManageCreateVocabularyScriptHandwrittenCreativityResult? res = await ManageCreateVocabularyScriptHandwrittenCreativityDialog.show(
      context: context,
      genre: item.genre,
      sceneCount: sceneCount,
      story: storyCreativity,
      cefr: item.cefr,
      scriptMode: item.scriptMode,
      semanticList: selectedSemanticList,
      selectedSemanticIds: selectedSemanticIds,
    );
    if(res == null) return;
    item.sceneCountController.text = res.sceneCount.toString();
    item.storyCreativityController.text = res.story??"";
    item.cefr = res.cefr;
    item.scriptMode = res.scriptMode;
    item.mustIncludeSemantics = res.mustIncludeSemantics.toList();
    item.isSelected = true;
    pathBList.refresh();
  }

  /// 取消选择手写创意
  void cancelSelectHandwrittenCreativity(ManageCreateVocabularyPathBModel item){
    item.isSelected = false;
    item.sceneCountController.text = "3";
    item.storyCreativityController.text = "";
    item.cefr = null;
    item.scriptMode = ManageScriptModeEnum.auto;
    item.mustIncludeSemantics = [];
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


  /// 选择故事场景
  void selectSceneAreaFun(LanguageCode code){
    selectSceneArea.value = code;
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
    if(selectKnowledgeList.isEmpty) return ToastUtils.showToast(text: "请选择词汇知识点");

    try {
      ToastUtils.showLoading();

      List<Map<String, dynamic>> contentList = [];
      for (final item in selectKnowledgeList) {
        if(item.uid == null || item.contentType == null) continue;

        List<EnKnowledgeEntitySemantics> selectedSemantics = item.selectedSemantics??[];
        if(selectedSemantics.isEmpty) continue;

        for(EnKnowledgeEntitySemantics semantic in selectedSemantics){
          contentList.add({
            "uid": item.uid,
            "type": item.contentType,
            "semanticId": semantic.uid,
          });
        }

      }

      List<String> mustIncludePersonaVariantsNids = [];

      for (var element in selectPersonaVariant) {
        if(element.variant.nid == null) continue;
        mustIncludePersonaVariantsNids.add(element.variant.nid!);
      }

      Map<String, dynamic> reqData = {
        "content": selectKnowledgeList.first.content,
        "contentList": contentList,
        "lang": "en",
        "locale": selectSceneArea.value.local,
        "mustIncludePersonaVariants": mustIncludePersonaVariantsNids,
      };

      if(selectProductionPath.value == 0){
        List<Map<String, dynamic>> ideas = [];
        for(var item in pathAList){
          if(!item.isSelected) continue;

          List<Map<String, dynamic>> mustIncludeSemantics = [];
          for(ManageCreateVocabularyPathASemanticModel semantic in item.mustIncludeSemantics){
            if(!semantic.isSelected) continue;
            mustIncludeSemantics.add({
              "uid": semantic.data.uid,
              "text": semantic.data.text,
            });
          }

          ideas.add({
            "cefr": item.cefr,
            "genre": item.genreNid,
            "scene_number": item.sceneCountController.text,
            "synopsis": item.storyCreativityController.text,
            "script_mode": item.scriptMode?.value,
            "must_include_semantics": mustIncludeSemantics,
          });
        }
        if(ideas.isEmpty) return ToastUtils.showToast(text: "请先选择至少一个创意候选");
        reqData["ideas"] = ideas;
      }else if(selectProductionPath.value == 1){
        List<Map<String, dynamic>> ideas = [];
        for(var item in pathBList){
          if(!item.isSelected) continue;

          List<Map<String, dynamic>> mustIncludeSemantics = [];
          for(ManageVocabularyCreativityEntityMustIncludeSemantics semantic in item.mustIncludeSemantics){
            mustIncludeSemantics.add({
              "uid": semantic.uid,
              "text": semantic.text,
            });
          }

          ideas.add({
            "cefr": item.cefr,
            "genre": item.genre.nid,
            "scene_number": item.sceneCountController.text,
            "synopsis": item.storyCreativityController.text,
            "script_mode": item.scriptMode?.value,
            "must_include_semantics": mustIncludeSemantics,
          });
        }
        if(ideas.isEmpty) return ToastUtils.showToast(text: "请先至少添加一个题材到生成计划");
        reqData["ideas"] = ideas;
      }else if(selectProductionPath.value == 2){
        reqData['genres'] = selectGenreNids.toList();
      }

      String? res = await LanguageConsoleDramaRequest.createVocabularyScript(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      Get.back(result: true);

    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 释放控制器资源
  @override
  void onClose() {
    uidSearchInput.dispose();
    contentSearchInput.dispose();
    contentSearchInputExact.dispose();
    pronunciationSearchInput.dispose();
    knowledgeScrollController.dispose();
    pathACancelToken.cancel();
    super.onClose();
  }
}
