import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../dialog/dialogs.dart';
import '../../../enums/enums.dart';
import '../../../models/manage_create_quiz_model.dart';
import '../../../models/manage_english_content_management_sentence_model.dart';
import '../../../models/models.dart';
import '../../../utils/utils.dart';
import '../views/manage_english_content_management_song_edit_dialog.dart';

class ManageSongController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageSongController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SONG;

  @override
  String get breadcrumbTitle => '歌曲';

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
  }.obs;

  final Map<String, FilterInputData> filterInputDatas = {
    "uid": FilterInputData(
      hintText: "uid",
      controller: TextEditingController(),
    ),
    "title": FilterInputData(
      hintText: "名称",
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

  /// 组装筛选数据
  Future<void> setFilterData() async{

    FilterConditionData? accentList = await FilterDataUtils.getAccentList(parameters: {"contentType": "EN_SONG"});
    if(accentList != null) {
      filterConditionDatas["accentIds"] = accentList;
    }

    await getSongDifficultyLevel();

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

  /// 获取歌曲难度等级
  Future<void> getSongDifficultyLevel() async{
    ManageCreateQuizModel? res = await ManageEnglishContentManagementSongRequest.getSongFilter();
    if(res == null) return;
    
    List<String> cefrLevels = res.cefrLevels??[];
    List<ManageCreateQuizGenresModel>? genres = res.genres; // 风格
    List<ManageCreateQuizThemesModel>? themes = res.themes; // 主题

    List<FilterConditionItem> cefrConditions = [];
    for(var item in cefrLevels){
      cefrConditions.add(FilterConditionItem(
        name: item, 
        value: item,
        color: AppTheme.cTextSecondary.color,
      ));
    }
    if(cefrConditions.isNotEmpty) {
      filterConditionDatas["difficulty"] = FilterConditionData(
        title: "难度等级",
        conditions: cefrConditions,
        isSingle: true,
        crossAxisCount: 7,
      );
    }

    List<FilterConditionItem> genreConditions = [];
    for(ManageCreateQuizGenresModel item in genres ?? []){
      LanguageText? name = item.name?.firstWhereOrNull((e) => e.lang == "en");
      genreConditions.add(FilterConditionItem(
        name: name?.text??"", 
        value: name?.text?? "",
        color: AppTheme.cTextSecondary.color,
      ));
    }
    if(genreConditions.isNotEmpty) {
      filterConditionDatas["genre"] = FilterConditionData(
        title: "曲风",
        conditions: genreConditions,
        isSingle: true,
      );
    }

    List<FilterConditionItem> themeConditions = [];
    for(ManageCreateQuizThemesModel item in themes ?? []){
      LanguageText? name = item.name?.firstWhereOrNull((e) => e.lang == "en");
      themeConditions.add(FilterConditionItem(
        name: name?.text??"", 
        value: name?.text?? "",
        color: AppTheme.cTextSecondary.color,
      ));
    }
    if(themeConditions.isNotEmpty) {
      filterConditionDatas["theme"] = FilterConditionData(
        title: "主题",
        conditions: themeConditions,
        isSingle: true,
      );
    }
    
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

      List<FilterConditionItem>? filterResolved5 = FilterDialog.getFilterData(key: "accentIds", filterConditionData: filterConditionDatas);
      if(filterResolved5 != null && filterResolved5.isNotEmpty){
        data['accentIds'] = filterResolved5.map((e) => e.value).toList();  
      }

      List<FilterConditionItem>? filterResolved6 = FilterDialog.getFilterData(key: "locked", filterConditionData: filterConditionDatas);
      if(filterResolved6 != null && filterResolved6.isNotEmpty){
        data['locked'] = filterResolved6.first.value;
      }
      
      List<FilterConditionItem>? filterResolved7 = FilterDialog.getFilterData(key: "difficulty", filterConditionData: filterConditionDatas);
      if(filterResolved7 != null && filterResolved7.isNotEmpty){
        data['difficulty'] = filterResolved7.first.value;
      }
      
      List<FilterConditionItem>? filterResolved8 = FilterDialog.getFilterData(key: "genre", filterConditionData: filterConditionDatas);
      if(filterResolved8 != null && filterResolved8.isNotEmpty){
        data['genre'] = filterResolved8.first.value;
      }
      
      List<FilterConditionItem>? filterResolved9 = FilterDialog.getFilterData(key: "theme", filterConditionData: filterConditionDatas);
      if(filterResolved9 != null && filterResolved9.isNotEmpty){
        data['theme'] = filterResolved9.first.value;
      }


      String? searchStr = FilterDialog.getSearchStr(key: "uid", filterInputDatas: filterInputDatas);
      List<int>? uids = FilterDialog.stringToIntList(searchStr);
      if(uids != null){
        data['uid'] = uids;
      }

      String? titleStr = FilterDialog.getSearchStr(key: "title", filterInputDatas: filterInputDatas);
      if(titleStr != null){
        data['title'] = titleStr;
      }

      ListResponseEntity<EnKnowledgeEntity>? response = await LanguageConsoleRequest.getEnSongKnowledgeList(
        parameters: parameters,
        data: data,
      );
      if(response == null) return;
      totalCount.value = response.count??0;

      List<EnKnowledgeEntity>? datas = response.datas;
      if(datas == null) return;

      List<int> assetsUids = knowledgeList.where((e) => e.assetType == 1).map((e) => e.data.uid!).toList();

      knowledgeList.clear();
      for(var e in datas){
        var model = ManageExpandModel<EnKnowledgeEntity>(data: e);
        if(assetsUids.contains(e.uid)){
          model.assetType = 1;
        }
        knowledgeList.add(model);
      }

    } finally{
      ToastUtils.hideLoading();
    }

  }

  Future<void> showCreateText(BuildContext context) async{
    EnKnowledgeEntity? entity = await ManageCreateTextManager.show(context: context);
    if(entity == null) return;
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

  Future<void> editKnowledge(BuildContext context, ManageExpandModel<EnKnowledgeEntity> entity) async{
    EnKnowledgeEntity? res = await ManageEditSongManager.show(context: context, entity: entity.data);
    if(res == null) return;
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
      bool res = await LanguageConsoleRequest.deleteSong(entity.data.uid!);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      getKnowledgeList();
    } finally{
      ToastUtils.hideLoading();
    }

  }

  Future<void> onKnowledgeVideo(EnKnowledgeEntity knowledge) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: {
        'type': knowledge.contentType,
        'uid': knowledge.uid,
        "quizOrImage": 2,
      },
    );

    getKnowledgeList();
  }

  Future<void> onKnowledgeImage(EnKnowledgeEntity knowledge) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: {
        'type': knowledge.contentType,
        'uid': knowledge.uid,
        "quizOrImage": 1,
      },
    );

    getKnowledgeList();
  }
  
  Future<void> onKnowledgeExercises(EnKnowledgeEntity knowledge) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: {
        'type': knowledge.contentType,
        'uid': knowledge.uid,
        "quizOrImage": 0,
      },
    );

    getKnowledgeList();
  }

  /// 图片定稿
  Future<void> finalDraftImage(EnKnowledgeEntity knowledge) async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": knowledge.relationImage?.uid,
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
  Future<void> cancelFinalDraftImage(BuildContext context, EnKnowledgeEntity knowledge) async{
    bool askRes = await AskDialog.showUserAsk(
      context: context, 
      title: "温馨提示",
      content: "您确定要取消图片定稿吗？",
    );

    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": knowledge.relationImage?.uid,
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
  Future<void> finalDraftVideo(EnKnowledgeEntityRelationVideo? relationVideo) async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": relationVideo?.uid,
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
  Future<void> cancelFinalDraftVideo(BuildContext context, EnKnowledgeEntityRelationVideo? relationVideo) async{
    bool askRes = await AskDialog.showUserAsk(
      context: context, 
      title: "温馨提示",
      content: "您确定要取消视频定稿吗？",
    );

    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": relationVideo?.uid,
      };
      bool res = await LanguageConsoleRequest.unlockDraftVideo(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "取消定稿成功", type: ToastType.success);
      getKnowledgeList();
    } finally{
      ToastUtils.hideLoading();
    }
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

  Future<void> onKnowledgeQuote(EnKnowledgeEntity knowledge) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_ENGLISH_COURSE_USAGE,
      arguments: {
        "type": knowledge.contentType,
        'uid': knowledge.uid,
      },
    );

    getKnowledgeList();
  }


}
