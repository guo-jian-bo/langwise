import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../controllers/manage_setting_controller.dart';
import '../../../dialog/dialogs.dart';
import '../../../enums/enums.dart';
import '../../../models/manage_create_quiz_model.dart';
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

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{
    "in_course_cnt": FilterSortsData(
      title: "课程归属",
      sorts: [
        FilterSortsItem(name: "课程数量升序", direction: FilterSortDirection.up),
        FilterSortsItem(name: "课程数量降序", direction: FilterSortDirection.down, selected: true, isDefault: true),
      ],
    ),
    "uid": FilterSortsData(
      title: "uid",
      sorts: [
        FilterSortsItem(name: "uid升序", direction: FilterSortDirection.up),
        FilterSortsItem(name: "uid降序", direction: FilterSortDirection.down),
      ],
    ),
  }.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{
    "accesses": FilterConditionsData(
      title: "上下架状态",
      isSingle: false,
      conditions: [
        FilterConditionsItem(name: "上架", value: AccessEnum.NORMAL.value),
        FilterConditionsItem(name: "下架", value: AccessEnum.INTERNAL.value),
      ],
    ),
    "locked": FilterConditionsData(
      title: "定稿状态",
      conditions: [
        FilterConditionsItem(name: "定稿", value: true),
        FilterConditionsItem(name: "未定稿", value: false),
      ],
    ),
    "published": FilterConditionsData(
      title: "发布状态",
      conditions: [
        FilterConditionsItem(name: ReleaseStatusEnum.PUBLISHED.name, value: true),
        FilterConditionsItem(name: ReleaseStatusEnum.UNPUBLISHED.name, value: false),
      ],
    ),
    "checked": FilterConditionsData(
      title: "审核状态",
      conditions: [
        FilterConditionsItem(name: "已审核", value: true),
        FilterConditionsItem(name: "未审核", value: false),
      ],
    ),
    "in_course": FilterConditionsData(
      title: "课程归属",
      conditions: [
        FilterConditionsItem(name: CourseAffiliationEnum.inCourse.name, value: true),
        FilterConditionsItem(name: CourseAffiliationEnum.notInCourse.name, value: false),
      ],
    ),
  }.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "uid": FilterSearchsData(
      title: "uid",
      hintText: "uid",
      controller: TextEditingController(),
      isCommaSeparated: true,
    ),
    "title": FilterSearchsData(
      title: "名称",
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
      filterSearchs['uid']?.controller.text = uid.toString();
    }

    setFilterData();
  }

  /// 组装筛选数据
  Future<void> setFilterData() async{

    await getSongDifficultyLevel();

    getKnowledgeList();
  }

  /// 获取歌曲难度等级
  Future<void> getSongDifficultyLevel() async{
    ManageCreateQuizModel? res = await ManageEnglishContentManagementSongRequest.getSongFilter();
    if(res == null) return;
    
    List<String> cefrLevels = res.cefrLevels??[];
    List<ManageCreateQuizGenresModel>? genres = res.genres; // 风格
    List<ManageCreateQuizThemesModel>? themes = res.themes; // 主题

    List<FilterConditionsItem> cefrConditions = [];
    for(var item in cefrLevels){
      cefrConditions.add(FilterConditionsItem(
        name: item,
        value: item,
      ));
    }
    if(cefrConditions.isNotEmpty) {
      filterConditions["difficulty"] = FilterConditionsData(
        title: "难度等级",
        conditions: cefrConditions,
      );
    }

    List<FilterConditionsItem> genreConditions = [];
    for(ManageCreateQuizGenresModel item in genres ?? []){
      LanguageText? name = item.name?.firstWhereOrNull((e) => e.lang == "en");
      genreConditions.add(FilterConditionsItem(
        name: name?.text??"",
        value: name?.text?? "",
      ));
    }
    if(genreConditions.isNotEmpty) {
      filterConditions["genre"] = FilterConditionsData(
        title: "曲风",
        conditions: genreConditions,
      );
    }

    List<FilterConditionsItem> themeConditions = [];
    for(ManageCreateQuizThemesModel item in themes ?? []){
      LanguageText? name = item.name?.firstWhereOrNull((e) => e.lang == "en");
      themeConditions.add(FilterConditionsItem(
        name: name?.text??"",
        value: name?.text?? "",
      ));
    }
    if(themeConditions.isNotEmpty) {
      filterConditions["theme"] = FilterConditionsData(
        title: "主题",
        conditions: themeConditions,
      );
    }
    
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
      Map<String, dynamic> sortOrder = FilterStripUtils.getSortOrderParameter(sorts: filterSorts);
      parameters.addAll(sortOrder);

      Map<String, dynamic> data = {
        "mediaMode": ManageSettingController.to.defaultResources.value == ResourceTypeEnum.image ? 0 : 1,
      };
      Map<String, dynamic> conditionParameter = FilterStripUtils.getConditionParameter(conditions: filterConditions);
      data.addAll(conditionParameter);

      Map<String, dynamic> searchParameter = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
      data.addAll(searchParameter);

      int? styleId = await ManageSettingController.to.getDefaultStyleId();
      if(styleId != null){
        data['styleId'] = styleId;
      }

      ListResponseEntity<EnKnowledgeEntity>? response = await LanguageConsoleRequest.getEnSongKnowledgeList(
        parameters: parameters,
        data: data,
      );
      if(response == null) return;
      totalCount.value = response.count??0;

      List<EnKnowledgeEntity>? datas = response.datas;
      if(datas == null) return;

      knowledgeList.clear();
      for(var e in datas){
        var model = ManageExpandModel<EnKnowledgeEntity>(data: e);
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

  Future<void> editKnowledge(BuildContext context, ManageExpandModel<EnKnowledgeEntity> entity) async{
    EnKnowledgeEntity? res = await ManageEditSongManager.show(context: context, entity: entity.data);
    if(res == null) return;
    getKnowledgeList();
  }

    /// 上下架知识点
  Future<void> onListingAndDelisting(BuildContext context, ManageExpandModel<EnKnowledgeEntity> entity) async{
    bool res = await AskDialog.showUserAsk(
      context: context,
      title: entity.data.isNormal ? "下架": "上架",
      content: "确定要${entity.data.isNormal ? "下架": "上架"}此知识点吗？",
      define: entity.data.isNormal ? "下架": "上架",
      defineColor: entity.data.isNormal ? AppTheme.cSurfaceError.color : AppTheme.cSurfaceSuccess.color,
    );
    if(!res) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": entity.data.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
      };

      EnKnowledgeEntity? res = await LanguageConsoleRequest.editSong(entity.data.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "${entity.data.isNormal ? "下架": "上架"}成功", type: ToastType.success);
      entity.data = res;
      knowledgeList.refresh();

    } finally{
      ToastUtils.hideLoading();
    }
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
