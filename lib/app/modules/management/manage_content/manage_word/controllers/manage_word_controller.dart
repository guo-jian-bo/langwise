import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../dialog/dialogs.dart';
import '../../../enums/enums.dart';
import '../../../models/manage_open_model.dart';
import '../../../utils/utils.dart';

class ManageWordController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageWordController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_WORD;
  
  @override
  String get breadcrumbTitle => '单词';
  
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
      title: "图片定稿",
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
    "noNeedSyllablesInt": FilterConditionData(
      title: "发布音节",
      isSingle: true,
      conditions: [
        FilterConditionItem(
          name: "不需要发布音节",
          value: -1,
          color: AppTheme.cTextTertiary.color,
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
      hintText: "知识点",
      controller: TextEditingController(),
    ),
    "fullContent": FilterInputData(
      hintText: "知识点(精确)",
      controller: TextEditingController(),
    ),
    "ipa": FilterInputData(
      hintText: "音标",
      controller: TextEditingController(),
    ), 
  };

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
    setFilterData();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }


  /// 组装筛选数据
  Future<void> setFilterData() async{
    FilterConditionData? accentList = await FilterDataUtils.getAccentList();
    if(accentList != null) {
      filterConditionDatas["accentIds"] = accentList;
    }

    filterConditionDatas['in_course_cnt'] = FilterConditionData(
      title: "排序",
      isSingle: true,
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
      ],
    );

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

      List<FilterConditionItem>? filterResolved = FilterDialog.getFilterData(key: "in_course_cnt", filterConditionData: filterConditionDatas);
      if(filterResolved != null && filterResolved.isNotEmpty){
        parameters['order'] = filterResolved.first.value;  
      }

      Map<String, dynamic> data = {};

      List<FilterConditionItem>? filterResolved2 = FilterDialog.getFilterData(key: "in_course", filterConditionData: filterConditionDatas);
      if(filterResolved2 != null && filterResolved2.isNotEmpty){
        data['in_course'] = filterResolved2.first.value;  
      }

      List<FilterConditionItem>? filterResolved3 = FilterDialog.getFilterData(key: "published", filterConditionData: filterConditionDatas);
      if(filterResolved3 != null && filterResolved3.isNotEmpty){
        data['published'] = filterResolved3.first.value;  
      }

      List<FilterConditionItem>? filterResolved4 = FilterDialog.getFilterData(key: "noNeedSyllablesInt", filterConditionData: filterConditionDatas);
      if(filterResolved4 != null && filterResolved4.isNotEmpty){
        data['noNeedSyllablesInt'] = filterResolved4.first.value;  
      }

      List<FilterConditionItem>? filterResolved5 = FilterDialog.getFilterData(key: "accentIds", filterConditionData: filterConditionDatas);
      if(filterResolved5 != null && filterResolved5.isNotEmpty){
        data['accentIds'] = filterResolved5.map((e) => e.value).toList();  
      }

      List<FilterConditionItem>? filterResolved6 = FilterDialog.getFilterData(key: "locked", filterConditionData: filterConditionDatas);
      if(filterResolved6 != null && filterResolved6.isNotEmpty){
        data['locked'] = filterResolved6.first.value;
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

      String? fullContentStr = FilterDialog.getSearchStr(key: "fullContent", filterInputDatas: filterInputDatas);
      if(fullContentStr != null){
        data['fullContent'] = fullContentStr;
      }

      String? ipaStr = FilterDialog.getSearchStr(key: "ipa", filterInputDatas: filterInputDatas);
      if(ipaStr != null){
        data['ipa'] = ipaStr;
      }

      ListResponseEntity<EnKnowledgeEntity>? response = await LanguageConsoleRequest.getEnWordKnowledgeList(
        parameters: parameters,
        data: data,
      );
      if(response == null) return;
      totalCount.value = response.count??0;

      List<EnKnowledgeEntity>? datas = response.datas;
      if(datas == null) return;

      List<int> openUids = knowledgeList.where((e) => e.isExpanded).map((e) => e.data.uid!).toList();
      List<int> assetsUids = knowledgeList.where((e) => e.assetType == 1).map((e) => e.data.uid!).toList();

      knowledgeList.clear();
      for(var e in datas){
        var model = ManageExpandModel<EnKnowledgeEntity>(data: e);
        if(openUids.contains(e.uid)){
          model.isExpanded = true;
        }
        if(assetsUids.contains(e.uid)){
          model.assetType = 1;
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

  /// 切换图片视频
  void toggleImageVideo(){

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

      EnKnowledgeEntity? res = await LanguageConsoleRequest.editWord(entity.data.uid!, data: reqData);
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
      bool res = await LanguageConsoleRequest.deleteWord(entity.data.uid!);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      getKnowledgeList();
    } finally{
      ToastUtils.hideLoading();
    }

  }


  /// 编辑知识点
  Future<void> editKnowledge(BuildContext context, ManageExpandModel<EnKnowledgeEntity> entity) async{
    EnKnowledgeEntity? res = await ManageEditWordDialog.show(context: context, knowledge: entity.data);
    if(res == null) return;
    entity.data = res;
    knowledgeList.refresh();
  }

  /// 删除单词语义
  Future<void> deleteWordSemantic(BuildContext context, EnKnowledgeEntitySemantics semantic) async{
    if(semantic.uid == null) return;
    bool askRes = await DeleteDialog.show(
      context: context, 
      title: "删除",
      subTitle: "您确定要删除这个语义吗？",
    );

    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      bool res = await LanguageConsoleRequest.deleteWordSemantic(semantic.uid!);
      if(!res) return;
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




  /// 图片定稿
  Future<void> finalDraftImage(EnKnowledgeEntitySemantics semantic) async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": semantic.relationImage?.uid,
      };
      bool res = await LanguageConsoleRequest.finalDraftImage(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "定稿成功", type: ToastType.success);
      getKnowledgeList();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 图片取消定稿
  Future<void> cancelFinalDraftImage(BuildContext context, EnKnowledgeEntitySemantics semantic) async{
    bool askRes = await AskDialog.showUserAsk(
      context: context, 
      title: "温馨提示",
      content: "您确定要取消图片定稿吗？",
    );

    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": semantic.relationImage?.uid,
      };
      bool res = await LanguageConsoleRequest.unlockDraftImage(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "取消定稿成功", type: ToastType.success);
      getKnowledgeList();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 视频定稿
  Future<void> finalDraftVideo(EnKnowledgeEntitySemantics semantic) async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": semantic.relationVideo?.uid,
      };
      bool res = await LanguageConsoleRequest.finalDraftVideo(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "定稿成功", type: ToastType.success);
      getKnowledgeList();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 视频取消定稿
  Future<void> cancelFinalDraftVideo(BuildContext context, EnKnowledgeEntitySemantics semantic) async{
    bool askRes = await AskDialog.showUserAsk(
      context: context, 
      title: "温馨提示",
      content: "您确定要取消视频定稿吗？",
    );

    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": semantic.relationVideo?.uid,
      };
      bool res = await LanguageConsoleRequest.unlockDraftVideo(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "取消定稿成功", type: ToastType.success);
      getKnowledgeList();
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 跳转至音频管理
  Future<void> jumpToAudioManage(EnKnowledgeEntity entity, EnKnowledgeEntityIpaAudioList data) async{

    if(!ManageAuthUtils.isAuth(ManageAuthCode.audioWordIpaQuery)) return;

    int index = entity.ipaAudioList?.indexOf(data) ?? 0;

    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_WORD_AUDIO,
      arguments: {
        "audioList": entity.ipaAudioList,
        "currentAudioIndex": index,
        "wordId": entity.uid,
      },
    );

    getKnowledgeList();

  }

  /// 创建单词
  Future<void> showCreateWord(BuildContext context) async{
    bool res = await ManageAddWordDialog.show(context: context);
    if(!res) return;
  }


  /// 单词添加记录
  Future<void> jumpToCreateHistory(BuildContext context) async{

    String? contentType;
    if(knowledgeList.isNotEmpty){
      contentType = knowledgeList.first.data.contentType??"";
    }
    contentType ??= ElementsCardType.word.value;


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






}
