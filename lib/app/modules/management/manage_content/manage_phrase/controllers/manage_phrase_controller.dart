

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../controllers/manage_setting_controller.dart';
import '../../../dialog/dialogs.dart';
import '../../../enums/enums.dart';
import '../../../models/manage_english_content_management_sentence_model.dart';
import '../../../models/models.dart';
import '../../../utils/utils.dart';

class ManagePhraseController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManagePhraseController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_PHRASE;

  @override
  String get breadcrumbTitle => '短语';

  /// 语言code
  final String languageCode = "en";

  final RxMap<String, FilterConditionData> filterConditionDatas = <String, FilterConditionData>{
    "in_course": FilterConditionData(
      title: "课程归属",
      isSingle: true,
      conditions: [
        FilterConditionItem(
          name: CourseAffiliationEnum.inCourse.name,
          value: true,
          color: const Color(0xff818CF8),
        ),
        FilterConditionItem(
          name: CourseAffiliationEnum.notInCourse.name,
          value: false,
          color: const Color(0xff818CF8),
        ),
      ],
    ),
    "published": FilterConditionData(
      title: "发布状态",
      isSingle: true,
      conditions: [
        FilterConditionItem(
          name: ReleaseStatusEnum.PUBLISHED.name,
          value: true,
          color: const Color(0xffF97316),
        ),
        FilterConditionItem(
          name: ReleaseStatusEnum.UNPUBLISHED.name,
          value: false,
          color: const Color(0xffF97316),
        ),
      ],
    ),
    "locked": FilterConditionData(
      title: "定稿状态",
      isSingle: true,
      conditions: [
        FilterConditionItem(
          name: "定稿",
          value: true,
          color: const Color(0xffF97316),
        ),
        FilterConditionItem(
          name: "未定稿",
          value: false,
          color: const Color(0xffF97316),
        ),
      ],
    ),
    "checked": FilterConditionData(
      title: "审核状态",
      isSingle: true,
      conditions: [
        FilterConditionItem(
          name: "已审核",
          value: true,
          color: AppTheme.cSurfaceSuccess.color,
        ),
        FilterConditionItem(
          name: "未审核",
          value: false,
          color: AppTheme.cSurfaceError.color,
        ),
      ],
    ),
    "order": FilterConditionData(
      title: "排序",
      isSingle: true,
      crossAxisCount: 4,
      conditions: [
        FilterConditionItem(
          name: "课程数量降序",
          value: "-in_course_cnt",
          color: AppTheme.cTextBrand.color,
          selected: true
        ),
        FilterConditionItem(
          name: "课程数量升序",
          value: "in_course_cnt",
          color: AppTheme.cTextBrand.color,
        ),
        FilterConditionItem(
          name: "词频降序",
          value: "-wordFreq",
          color: AppTheme.cTextBrand.color,
        ),
        FilterConditionItem(
          name: "词频升序",
          value: "wordFreq",
          color: AppTheme.cTextBrand.color,
        ),
        FilterConditionItem(
          name: "uid降序",
          value: "-uid",
          color: AppTheme.cTextBrand.color,
        ),
        FilterConditionItem(
          name: "uid升序",
          value: "uid",
          color: AppTheme.cTextBrand.color,
        ),
      ],
    ),
  }.obs;

  final Map<String, FilterInputData> filterInputDatas = {
    "uid": FilterInputData(
      hintText: "uid",
      controller: TextEditingController(),
    ),
    "content": FilterInputData(
      hintText: "短语",
      controller: TextEditingController(),
    ),
  };

  /// 一键展开/折叠
  final RxBool isAllExpand = false.obs;

  final RxList<ManageExpandModel<EnKnowledgeEntity>> knowledgeList = <ManageExpandModel<EnKnowledgeEntity>>[].obs;
  final RxInt totalCount = 0.obs;
  int offset = 0;
  int limit = 20;
  final PagerController pagerController = PagerController();
  

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments != null) {
      int? uid = Get.arguments["uid"];
      filterInputDatas['uid']?.controller.text = uid.toString();
    }
    getKnowledgeList();
  }

  /// 筛选-改变
  void changeFilterConditionData(Map<String, FilterConditionData> datas) {
    filterConditionDatas.value = datas;
    filterConditionDatas.refresh();
    pagerController.jumpToPage(1);
  }

  /// 搜索提交
  void searchSubmitted() {
    pagerController.jumpToPage(1);
  }


  /// 分页器回调
  void pagerCallback(int page, int pageSize) {
    offset = (page - 1) * pageSize;
    limit = pageSize;
    getKnowledgeList();
  }


  Future<void> getKnowledgeList() async {
    try {
      
      ToastUtils.showLoading();

      Map<String, dynamic> parameters = {
        "offset": offset,
        "limit": limit,
      };

      List<FilterConditionItem>? filterResolved = FilterDialog.getFilterData(key: "order", filterConditionData: filterConditionDatas);
      if(filterResolved != null && filterResolved.isNotEmpty){
        parameters['order'] = filterResolved.first.value;  
      }

      Map<String, dynamic> data = {
        "mediaMode": ManageSettingController.to.defaultResources.value == ResourceTypeEnum.image ? 0 : 1,
      };

      List<FilterConditionItem>? filterResolved2 = FilterDialog.getFilterData(key: "in_course", filterConditionData: filterConditionDatas);
      if(filterResolved2 != null && filterResolved2.isNotEmpty){
        data['in_course'] = filterResolved2.first.value;  
      }

      List<FilterConditionItem>? filterResolved3 = FilterDialog.getFilterData(key: "published", filterConditionData: filterConditionDatas);
      if(filterResolved3 != null && filterResolved3.isNotEmpty){
        data['published'] = filterResolved3.first.value;  
      }

      List<FilterConditionItem>? filterResolved6 = FilterDialog.getFilterData(key: "locked", filterConditionData: filterConditionDatas);
      if(filterResolved6 != null && filterResolved6.isNotEmpty){
        data['locked'] = filterResolved6.first.value;
      }

      List<FilterConditionItem>? filterResolved7 = FilterDialog.getFilterData(key: "checked", filterConditionData: filterConditionDatas);
      if(filterResolved7 != null && filterResolved7.isNotEmpty){
        data['checked'] = filterResolved7.first.value;
      }


      String? searchStr = FilterDialog.getSearchStr(key: "uid", filterInputDatas: filterInputDatas);
      List<int>? uids = FilterDialog.stringToIntList(searchStr);
      if(uids != null){
        data['uid'] = uids;
      }

      String? contentStr = FilterDialog.getSearchStr(key: "content", filterInputDatas: filterInputDatas);
      if(contentStr != null){
        data['content'] = contentStr;
      }

      int? styleId = await ManageSettingController.to.getDefaultStyleId();
      if(styleId != null){
        data['styleId'] = styleId;
      }

      ListResponseEntity<EnKnowledgeEntity>? response = await LanguageConsoleRequest.getEnPhraseKnowledgeList(
        parameters: parameters,
        data: data,
      );
      if(response == null) return;
      totalCount.value = response.count??0;

      List<EnKnowledgeEntity>? datas = response.datas;
      if(datas == null) return;

      List<int> openUids = knowledgeList.where((e) => e.isExpanded).map((e) => e.data.uid!).toList();

      knowledgeList.clear();
      for(var e in datas){
        var model = ManageExpandModel<EnKnowledgeEntity>(data: e);
        if(openUids.contains(e.uid) || isAllExpand.value){
          model.isExpanded = true;
        }
        knowledgeList.add(model);
      }

    } finally{
      ToastUtils.hideLoading();
    }

  }


  /// 展开收起语义
  void toggleSemantic(ManageExpandModel<EnKnowledgeEntity> entity) {
    entity.isExpanded = !entity.isExpanded;
    knowledgeList.refresh();
  }

  /// 一键展开/折叠
  void onAllExpand(){
    isAllExpand.value = !isAllExpand.value;
    for (var element in knowledgeList) {
      element.isExpanded = isAllExpand.value;
    }
    knowledgeList.refresh();
  }


  /// 创建短语
  Future<void> showCreatePhrase(BuildContext context) async{
    bool res = await ManageAddPhraseDialog.show(context: context);
    if(!res) return;
  }


  /// 单词添加记录
  Future<void> jumpToCreateHistory(BuildContext context) async{

    String? contentType;
    if(knowledgeList.isNotEmpty){
      contentType = knowledgeList.first.data.contentType??"";
    }
    contentType ??= ElementsCardType.phrase.value;


    dynamic uid = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_CREATE_HISTORY,
      arguments: {
        "contentType": contentType,
      },
    );
    if(uid == null) return;

    filterInputDatas['uid']?.controller.text = uid.toString();
    pagerController.jumpToPage(1);

  }

  /// 删除知识点
  Future<void> deleteKnowledge(BuildContext context, ManageExpandModel<EnKnowledgeEntity> entity) async{
    if(entity.data.uid == null) return;
    bool askRes = await DeleteDialog.show(
      context: context, 
      title: "删除",
      subTitle: "您确定要删除这个知识点吗？",
    );

    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      bool res = await LanguageConsoleRequest.deletePhrase(entity.data.uid!);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      getKnowledgeList();
    } finally{
      ToastUtils.hideLoading();
    }

  }

  /// 编辑知识点
  Future<void> editKnowledge(BuildContext context, ManageExpandModel<EnKnowledgeEntity> entity) async{
    EnKnowledgeEntity? res = await ManageEditPhraseDialog.show(context: context, knowledge: entity.data);
    if(res == null) return;
    entity.data = res;
    knowledgeList.refresh();
  }


  Future<void> onKnowledgeCore(BuildContext context, ManageExpandModel<EnKnowledgeEntity> entity) async{
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_CORE_KNOWLEDGE,
      arguments: {
        "uid": entity.data.uid,
        "type": entity.data.contentType,
      },
    );
  }

  /// 删除短语语义
  Future<void> deleteSemantic(BuildContext context, ManageExpandModel<EnKnowledgeEntity> entity, EnKnowledgeEntitySemantics semantic) async{
    if(semantic.uid == null) return;
    
    ManageDelSemanticEnum? deleteType = await ManageDelSemanticDialog.show(
      context: context, 
      sid: semantic.uid!,
      content: entity.data.content??"",
    );
    if(deleteType == null) return;
    if(deleteType == ManageDelSemanticEnum.database){
      try {
        ToastUtils.showLoading();
        bool res = await LanguageConsoleRequest.deletePhraseSemantic(semantic.uid!);
        if(!res) return;
        ToastUtils.showToast(text: "删除成功", type: ToastType.success);
        getKnowledgeList();
      } finally{
        ToastUtils.hideLoading();
      }
      return;
    }

    if(entity.data.uid == null) return;
    
    List<int?> semanticIds = entity.data.semanticIds??[];
    semanticIds.remove(semantic.uid!);
    
    Map<String, dynamic> reqData = {
      "semanticIds": semanticIds,
    };

    try {
      ToastUtils.showLoading();
      EnKnowledgeEntity? res = await LanguageConsoleRequest.editPhrase(entity.data.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      getKnowledgeList();
    } finally{
      ToastUtils.hideLoading();
    }

    
  }

  /// 编辑语义
  Future<void> editSemantic(BuildContext context, EnKnowledgeEntitySemantics semantic) async {
    if(semantic.uid == null) return;
    bool res = await ManageEditGlossDescDialog.showEdit(
      context: context,
      gloss: semantic.gloss,
      descriptions: semantic.descriptions,
      semanticId: semantic.uid!,
      eduTier: semantic.eduTierEnum,
    );
    if(!res) return;
    getKnowledgeList();
  }

  Future<void> onSemanticVideo(EnKnowledgeEntity knowledge, EnKnowledgeEntitySemantics semantic) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: {
        'type': knowledge.contentType,
        'uid': knowledge.uid,
        'semanticId': semantic.uid,
        "quizOrImage": 2,
      },
    );

    getKnowledgeList();
  }

  Future<void> onSemanticImage(EnKnowledgeEntity knowledge, EnKnowledgeEntitySemantics semantic) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: {
        'type': knowledge.contentType,
        'uid': knowledge.uid,
        'semanticId': semantic.uid,
        "quizOrImage": 1,
      },
    );

    getKnowledgeList();
  }
  
  Future<void> onSemanticExercises(EnKnowledgeEntity knowledge, EnKnowledgeEntitySemantics semantic) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: {
        'type': knowledge.contentType,
        'uid': knowledge.uid,
        'semanticId': semantic.uid,
        "quizOrImage": 0,
      },
    );

    getKnowledgeList();
  }

  Future<void> onSemanticQuote(EnKnowledgeEntity knowledge, EnKnowledgeEntitySemantics semantic) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_ENGLISH_COURSE_USAGE,
      arguments: {
        "type": knowledge.contentType,
        'uid': knowledge.uid,
        "semanticId": semantic.uid,
      },
    );

    getKnowledgeList();
  }

  /// 添加语义
  Future<void> addSemantic(BuildContext context, ManageExpandModel<EnKnowledgeEntity> entity) async{

    List<EnKnowledgeEntitySemantics>? selects = await ManageSelectSemanticDialog.show(
      context: context,
      initSemantics: entity.data.semantics??[],
      languageCode: entity.data.language,
    );
    if(selects == null) return;

    try {
      ToastUtils.showLoading();

      List<int> semanticIds = selects.map((e) => e.uid!).toList();

      Map<String, dynamic> reqData = {
        "semanticIds": semanticIds,
      };

      EnKnowledgeEntity? res = await LanguageConsoleRequest.editPhrase(entity.data.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "添加成功", type: ToastType.success);
      entity.data = res;
      knowledgeList.refresh();

    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 关联语义
  Future<void> onCorrelationSemantic(BuildContext context, ManageExpandModel<EnKnowledgeEntity> entity) async{
    if(entity.data.uid == null || entity.data.contentType == null) return;
    
    bool res = await ManageCorrelationSemanticDialog.show(
      context: context, 
      contentId: entity.data.uid!, 
      contentType: entity.data.contentType!,
    );
    if(!res) return;

    getKnowledgeList();

  }

  /// 跳转至音频管理
  Future<void> jumpToAudioManage(EnKnowledgeEntity entity, EnKnowledgeEntityAudioExpressionList data) async{

    if(!ManageAuthUtils.isAuth(ManageAuthCode.audioExpressQuery)) return;

    int index = entity.audioExpressionList?.indexOf(data) ?? 0;

    List<ManageEnglishContentManagementSentenceIpaAudioModel?> audios = [];
    List<EnKnowledgeEntityAudioExpressionList?> audioExpressionList = entity.audioExpressionList??[];
    for(var item in audioExpressionList){
      if(item == null) continue;
      audios.add(ManageEnglishContentManagementSentenceIpaAudioModel.fromJson(item.toJson()));
    }

    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_AUDIO_SUBTITLE_EDITOR,
      arguments: {
        "audioList": audios,
        "currentAudioIndex": index,
        "type": entity.contentType,
      },
    );

    getKnowledgeList();

  }



  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
