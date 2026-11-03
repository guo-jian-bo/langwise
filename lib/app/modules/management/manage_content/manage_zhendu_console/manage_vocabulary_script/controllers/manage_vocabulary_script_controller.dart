import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/utils.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../../enums/manage_zhendu_enums.dart';

class ManageVocabularyScriptController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageVocabularyScriptController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_VOCABULARY_SCRIPT;

  @override
  String get breadcrumbTitle => '词汇剧本';


  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{
    "uid": FilterSortsData(
      title: "uid",
      sorts: [
        FilterSortsItem(name: "从小到大", direction: FilterSortDirection.up),
        FilterSortsItem(name: "从大到小", direction: FilterSortDirection.down, selected: true, isDefault: true),
      ],
    ),
    "created": FilterSortsData(
      title: "创建日期",
      sorts: [
        FilterSortsItem(name: "从早到晚", direction: FilterSortDirection.up),
        FilterSortsItem(name: "从晚到早", direction: FilterSortDirection.down),
      ],
    ),
  }.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{
    "access": FilterConditionsData(
      title: "发布状态",
      isSingle: false,
      conditions: [
        FilterConditionsItem(name: "发布", value: AccessEnum.NORMAL.value),
        FilterConditionsItem(name: "未发布", value: AccessEnum.INTERNAL.value),
      ],
    ),
    "locale": FilterConditionsData(
      title: "地区",
      conditions: ManageZhenduLocaleEnum.values.map((e) => FilterConditionsItem(
        name: e.value,
        value: e.value,
      )).toList(),
    ),
  }.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "uids": FilterSearchsData(
      title: "剧本uid",
      hintText: "剧本uid",
      controller: TextEditingController(),
      isCommaSeparated: true,
    ),
    "title": FilterSearchsData(
      title: "标题",
      hintText: "标题",
      controller: TextEditingController(),
    ),
    "wordId": FilterSearchsData(
      title: "单词ID",
      hintText: "单词ID",
      controller: TextEditingController(),
    ),
    "phraseId": FilterSearchsData(
      title: "短语ID",
      hintText: "短语ID",
      controller: TextEditingController(),
    ), 
  };

  final RxInt totalCount = 0.obs;
  int offset = 0;
  int limit = 20;
  final PagerController pagerController = PagerController();
  final RxList<ManageScriptEntity> dataList = <ManageScriptEntity>[].obs;


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if(Get.arguments != null){
      List? uids = Get.arguments['uids'];
      if(uids != null){
        filterSearchs['uids']?.controller.text = uids.join(',');
      }
    }
    getThemeGenreList();
    refreshListData();
  }

  /// 刷新列表数据
  Future<void> refreshListData() async{
    totalCount.value = 0;
    offset = 0;
    dataList.clear();
    await getDataList();
  }

  /// 获取主题题材列表 用作筛选
  Future<void> getThemeGenreList() async{
    List<ManageScriptThemeEntity>? res = await LanguageConsoleDramaRequest.getScriptThemeList();
    if(res != null){
      List<FilterConditionsItem> conditions = [];
      for (var element in res) {
        String? name = element.name?.firstWhereOrNull((e) => e?.lang == "zh")?.text;
        if(name == null && element.name?.isNotEmpty == true){
          name = element.name?.first?.text;
        }
        if(name == null || name.isEmpty) continue;
        conditions.add(FilterConditionsItem(name: name, value: element.nid));
      }
      filterConditions['theme_nid'] = FilterConditionsData(
        title: "主题",
        conditions: conditions,
      );
    }

    List<ManageScriptGenreEntity>? resGenre = await LanguageConsoleDramaRequest.getScriptGenreList();
    if(resGenre != null){
      List<FilterConditionsItem> conditions = [];
      for (var element in resGenre) {
        String? name = element.name?.firstWhereOrNull((e) => e?.lang == "zh")?.text;
        if(name == null && element.name?.isNotEmpty == true){
          name = element.name?.first?.text;
        }
        if(name == null || name.isEmpty) continue;
        conditions.add(FilterConditionsItem(name: name, value: element.nid));
      }
      filterConditions['genre_nid'] = FilterConditionsData(
        title: "题材",
        conditions: conditions,
      );
    }
  }

  /// 分页器回调
  void pagerCallback(int page, int pageSize) {
    offset = (page - 1) * pageSize;
    limit = pageSize;
    getDataList();
  }

  Future<void> getDataList() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "offset": offset,
        "limit": limit,
      };
      Map<String, dynamic> sortOrder = FilterStripUtils.getSortOrderParameter(sorts: filterSorts);
      parameters.addAll(sortOrder);

      Map<String, dynamic> reqData = {
        "scriptType": ScriptTypeEnum.vocabulary.value,
      };
      
      Map<String, dynamic> conditionParameter = FilterStripUtils.getConditionParameter(conditions: filterConditions);
      reqData.addAll(conditionParameter);

      Map<String, dynamic> searchParameter = FilterStripUtils.getSearchParameter(searchs: filterSearchs);

      if(searchParameter['wordId'] != null){
        searchParameter['contentId'] = searchParameter['wordId'];
        searchParameter['contentType'] = KnowledgeTypeEnum.EN_WORD.value;
        searchParameter.remove('wordId');
      }

      if(searchParameter['phraseId'] != null){
        reqData['contentId'] = searchParameter['phraseId'];
        searchParameter['contentType'] = KnowledgeTypeEnum.EN_PHRASE.value;
        searchParameter.remove('phraseId');
      }

      reqData.addAll(searchParameter);

      ListResponseEntity<ManageScriptEntity>? res = await LanguageConsoleDramaRequest.getScriptList(parameters: parameters, data: reqData);
      if(res == null) return;
      totalCount.value = res.count??0;
      List<ManageScriptEntity> list = res.datas??[];
      dataList.value = list;
    } finally{
      ToastUtils.hideLoading();
    }
  }

    /// 删除剧本
  Future<void> deleteData(BuildContext context, ManageScriptEntity entity) async{
    if(entity.uid == null) return;
    bool res = await AskDialog.showUserAsk(
      context: context,
      title: "删除",
      content: "确定要删除此剧本吗？",
      define: "删除",
      defineColor: AppTheme.cSurfaceError.color,
    );
    if(!res) return;
    try {
      ToastUtils.showLoading();
      bool res = await LanguageConsoleDramaRequest.scriptDelete(entity.uid!);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      getDataList();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 预览剧本
  Future<void> previewPreview(BuildContext context, ManageScriptEntity entity) async{
    /// 是否是管理端的标识 随机UUID
    String traceAdminHeader = const Uuid().v4();

    int? styleId;
    String? dialect;
    if(entity.visualProjects?.isNotEmpty == true){
      styleId = entity.visualProjects?.first?.styleId;
    }
    if(entity.audioProjects?.isNotEmpty == true){
      dialect = entity.audioProjects?.first?.dialect;
    }

    Get.toNamed(
      Routes.ZHENDU_SHOW_DETAIL,
      arguments: {
        "contentId": entity.uid,
        "locale": entity.locale,
        // "difficulty": entity.difficulty,
        "styleId": styleId,
        "dialect": dialect,
        "traceAdminHeader": traceAdminHeader,
      },
    );
  }

    /// 上下架
  Future<void> onListingAndDelisting(BuildContext context, ManageScriptEntity entity) async{
    if(entity.uid == null) return;
    bool res = await AskDialog.showUserAsk(
      context: context,
      title: entity.isNormal ? "取消发布": "发布",
      content: "确定要${entity.isNormal ? "取消发布": "发布"}此剧本吗？",
      define: entity.isNormal ? "取消发布": "发布",
      defineColor: entity.isNormal ? AppTheme.cSurfaceError.color : AppTheme.cSurfaceSuccess.color,
    );
    if(!res) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": entity.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
      };

      bool res = await LanguageConsoleDramaRequest.scriptEdit(entity.uid!, data: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "${entity.isNormal ? "取消发布": "发布"}成功", type: ToastType.success);
      getDataList();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 跳转至音频项目详情
  Future<void> toAudioProjectDetail(ManageScriptEntityAudioProjects? audioProject) async{
    if(audioProject?.projectId == null) return;
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_AUDIO_PROJECT_DETILS,
      arguments: {
        "projectId": audioProject?.projectId,
      },
    );
  }

  /// 跳转至视觉项目详情
  Future<void> toVisualProjectDetail(ManageScriptEntityVisualProjects? visualProject) async{
    if(visualProject?.projectId == null) return;
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_VISUAL_PROJECT_DETILS,
      arguments: {
        "projectId": visualProject?.projectId,
      },
    );
  }

  /// 题目
  Future<void> toQuiz(ManageScriptEntity data) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: {
        'type': KnowledgeTypeEnum.SCRIPT.value,
        'uid': data.uid,
        "quizOrImage": 0,
      },
    );
    getDataList();
  }

  /// 核心知识点
  Future<void> coreKnowledge(ManageScriptEntity data) async{
    if((data.usedKnowledgePoints?.length??0) == 0) return ToastUtils.showToast(text: "暂无核心知识点");
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_CORE_KNOWLEDGE,
      arguments: {
        "uid": data.uid,
        "type": KnowledgeTypeEnum.SCRIPT.value,
      },
    );
  }

  /// 分配分组
  Future<void> assignGroups(ManageScriptEntity data) async{
    dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_SCRIPT_ALLOCATION_GROUP,
      arguments: {
        "data": data.toJson(),
        "scriptType": ScriptTypeEnum.vocabulary.value,
      },
    );
    if(res == true){
      getDataList();
    }
  }

  /// 剧本详情
  Future<void> scriptDetils(ManageScriptEntity data) async{
    if(data.uid == null) return;
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_SCRIPT_DETAILS,
      arguments: {
        "scriptId": data.uid,
        "scriptType": ScriptTypeEnum.vocabulary.value,
      },
    );
  }

  /// 创建记录
  Future<void> createRecord() async{
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_ZHENDU_GENERATE_TASK,
      arguments: {
        "taskType": "scriptFromVocabulary",
      },
    );
  }

  /// 新建词汇剧本
  Future<void> createVocabularyScript() async{
    ManagePageRegistry.jumpTo(Routes.MANAGE_CREATE_VOCABULARY_SCRIPT);
  }
  

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
