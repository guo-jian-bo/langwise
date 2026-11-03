import 'dart:async';
import 'dart:io';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/utils/utils.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../management/common/manage_select_knowledge_table/view.dart';
import '../../../management/common/manage_select_knowledge_table/views/select_semantic_widget.dart';
import '../../../management/controllers/manage_setting_controller.dart';
import '../../../management/utils/utils.dart';
import '../../common/official_course_details_target_widgets.dart';
import '../models/course_details_target_content_type_model.dart';
import '../common/course_details_target_download_dialog.dart';

class OfficialCourseDetailsTargetController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  OfficialCourseDetailsTargetController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.OFFICIAL_COURSE_DETAILS_TARGET;

  @override
  String get breadcrumbTitle => "单元目标";

  /// 参数说明
  /// courseId 课程id
  /// levelId 等级id
  /// moduleId 模块id
  /// unitId 单元id
  /// isAdminPage 是否是管理端页面
  /// language 语言
  /// 在用户端 courseId levelId moduleId unitId 是必填参数
  /// 在管理端 unitId nestedKeyId language 是必填参数

  int? courseId;
  int? levelId;
  int? moduleId;
  int? unitId;

  /// 是否是管理端页面
  bool isAdminPage = false;
  String? language;

  /// 滚动视图控制器
  final ScrollController scrollController = ScrollController();

  /// 滚动视图显示控制器
  late final ListObserverController scrollObserverController;

  /// 知识点类型列表
  final RxList<CourseDetailsTargetContentTypeModel> knowledgeTypeList = <CourseDetailsTargetContentTypeModel>[].obs;

  /// 选择的知识点类型下标
  final RxInt selectedKnowledgeTypeIndex = 0.obs;

  final Rx<UnitKnowledgePointsEntity> unitKnowledgePoints = UnitKnowledgePointsEntity().obs;

  /// 所有数据列表
  final RxList<UnitKnowledgePointsEntityKnowledgeList> allKnowledgeList = <UnitKnowledgePointsEntityKnowledgeList>[].obs;

  /// 搜索框控制器
  final TextEditingController searchController = TextEditingController();

  /// 搜索框焦点
  final FocusNode searchFocusNode = FocusNode();

  /// 搜索框是否展开
  final RxBool isSearchExpanded = false.obs;

  /// 是否正在滚动
  final RxBool isScrolling = false.obs;

  /// 滚动监听timer
  Timer? scrollTimer;

  /// 管理端是否进行了编辑
  bool isAdminEdit = false;

  /// 是否进入排序模式
  final RxBool isSortMode = false.obs;

  /// 要排序的知识点类型
  final Rx<ElementsCardType> sortKnowledgeType = ElementsCardType.none.obs;


  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{
    "locked": FilterConditionsData(
      title: "定稿状态",
      conditions: [
        FilterConditionsItem(
          name: "定稿",
          value: true,
        ),
        FilterConditionsItem(
          name: "未定稿",
          value: false,
        ),
      ],
    ),
    "show": FilterConditionsData(
      title: "可见状态",
      conditions: [
        FilterConditionsItem(
          name: "前端可见",
          value: true,
        ),
        FilterConditionsItem(
          name: "前端不可见",
          value: false,
        ),
      ],
    ),
  }.obs;


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      courseId = Get.arguments["courseId"];
      levelId = Get.arguments["levelId"];
      moduleId = Get.arguments["moduleId"];
      unitId = Get.arguments["unitId"];
      isAdminPage = Get.arguments["isAdminPage"] ?? false;
      language = Get.arguments["language"];
      getUnitTarget();
    }

    scrollObserverController = ListObserverController(controller: scrollController);
  }

  Future<void> getUnitTarget({bool showLoading = true}) async {
    try {
      if (showLoading) ToastUtils.showLoading();
      UnitKnowledgePointsEntity? entity;
      if (isAdminPage) {
        if (unitId == null) return;

        Map<String, dynamic> parameters = {};
        if(Get.isRegistered<ManageSettingController>()){
          final ManageSettingController settingController = Get.find<ManageSettingController>();
          if(settingController.defaultResources.value == ResourceTypeEnum.video){
            parameters['mediaMode'] = 1; // 视频
          }
          parameters['styleId'] = settingController.defaultStyle.value.uid;
        }

        entity = await OfficialCourseDetailsRequest.getAdminUnitTarget(unitId!, parameters: parameters);
      } else {
        if (courseId == null || levelId == null || moduleId == null || unitId == null) return;

        ConfigController configController = Get.find<ConfigController>();
        entity = await OfficialCourseDetailsRequest.getUnitTarget(
          courseId!, 
          moduleId!, 
          unitId!,
          styleCode: Uri.encodeComponent(configController.currentShowStyleCode.value),
          mediaMode: configController.currentShowResource.value == ResourceTypeEnum.image ? 0 : 1,
        );
      }
      if (entity == null) return;
      unitKnowledgePoints.value = entity;
      List<UnitKnowledgePointsEntityKnowledgeList?>? list = unitKnowledgePoints.value.knowledgeList;
      if (list == null) return;
      allKnowledgeList.clear();
      for (int i = 0; i < list.length; i++) {
        UnitKnowledgePointsEntityKnowledgeList? item = list[i];
        if (item == null) continue;
        allKnowledgeList.add(item);
      }

      classifyKnowledge();
      applySearchAndFilter();

    } finally {
      if (showLoading) ToastUtils.hideLoading();
    }
  }

  /// 分类知识点
  void classifyKnowledge() {
    List<UnitKnowledgePointsEntityKnowledgeList> list = allKnowledgeList.toList();
    knowledgeTypeList.clear();

    List<CourseDetailsTargetContentTypeKnowledgeModel> wordList = [];
    List<CourseDetailsTargetContentTypeKnowledgeModel> phraseList = [];
    List<CourseDetailsTargetContentTypeKnowledgeModel> sentenceList = [];
    List<CourseDetailsTargetContentTypeKnowledgeModel> textList = [];
    List<CourseDetailsTargetContentTypeKnowledgeModel> songList = [];

    for (int i = 0; i < list.length; i++) {
      UnitKnowledgePointsEntityKnowledgeList? item = list[i];

      CourseDetailsTargetContentTypeKnowledgeModel knowledgeModel = CourseDetailsTargetContentTypeKnowledgeModel(
        knowledge: item,
        key: GlobalKey(),
      );

      if (item.isWord) {
        wordList.add(knowledgeModel);
      } else if (item.isPhrase) {
        phraseList.add(knowledgeModel);
      } else if (item.isSentence) {
        sentenceList.add(knowledgeModel);
      } else if (item.isText) {
        textList.add(knowledgeModel);
      } else if (item.isSong) {
        songList.add(knowledgeModel);
      }
    }

    if (wordList.isNotEmpty) {
      knowledgeTypeList.add(CourseDetailsTargetContentTypeModel(
        title: "单词",
        knowledges: wordList,
        orgKnowledges: wordList.map((e) => e.knowledge).toList(),
        columnCount: 3,
        type: ElementsCardType.word,
      ));
    }
    if (phraseList.isNotEmpty) {
      knowledgeTypeList.add(CourseDetailsTargetContentTypeModel(
        title: "短语",
        knowledges: phraseList,
        orgKnowledges: phraseList.map((e) => e.knowledge).toList(),
        columnCount: 3,
        type: ElementsCardType.phrase,
      ));
    }
    if (sentenceList.isNotEmpty) {
      knowledgeTypeList.add(CourseDetailsTargetContentTypeModel(
        title: "句子",
        knowledges: sentenceList,
        orgKnowledges: sentenceList.map((e) => e.knowledge).toList(),
        columnCount: 2,
        type: ElementsCardType.sentence,
      ));
    }
    if (songList.isNotEmpty) {
      knowledgeTypeList.add(CourseDetailsTargetContentTypeModel(
        title: "歌曲",
        knowledges: songList,
        orgKnowledges: songList.map((e) => e.knowledge).toList(),
        columnCount: 2,
        type: ElementsCardType.song,
      ));
    }
    if (textList.isNotEmpty) {
      knowledgeTypeList.add(CourseDetailsTargetContentTypeModel(
        title: "文章",
        knowledges: textList,
        orgKnowledges: textList.map((e) => e.knowledge).toList(),
        columnCount: 2,
        type: ElementsCardType.text,
      ));
    }
  }

  /// 切换知识点类型
  Future<void> switchKnowledgeType(int index) async {
    await scrollObserverController.jumpTo(
      index: index,
    );
    selectedKnowledgeTypeIndex.value = index;
  }

  /// 列表显示下标切换
  void switchShowListType(int index) {
    selectedKnowledgeTypeIndex.value = index;
    checkSearchText();
  }

  /// 判断搜索框是否有值 如果没有 则关闭搜索框
  void checkSearchText() {
    searchFocusNode.unfocus();
    if (searchController.text.trim().isEmpty) {
      searchController.clear();
      isSearchExpanded.value = false;
    }
  }

  /// 展开搜索框
  void expandSearch() {
    isSearchExpanded.value = true;
    searchFocusNode.requestFocus();
  }

  /// 实时执行搜索
  void realTimeSearch(String value) {
    applySearchAndFilter(keyword: value);
  }

  /// 应用搜索与筛选条件，取两者交集后刷新列表
  void applySearchAndFilter({String? keyword}) {
    String currentKeyword = keyword?.trim() ?? searchController.text.trim();
    List<UnitKnowledgePointsEntityKnowledgeList> respList = [];

    for (int i = 0; i < allKnowledgeList.length; i++) {
      UnitKnowledgePointsEntityKnowledgeList item = allKnowledgeList[i];

      if (!_matchesSearch(item, currentKeyword)) continue;
      if (!_matchesFilter(item)) continue;

      respList.add(item);
    }

    classifyKnowledgeList(respList);
  }

  /// 判断当前知识点是否命中搜索关键词
  bool _matchesSearch(UnitKnowledgePointsEntityKnowledgeList item, String keyword) {
    if (keyword.isEmpty) return true;

    String lowerKeyword = keyword.toLowerCase();
    bool titleContains = item.title?.toLowerCase().contains(lowerKeyword) == true;
    bool contentContains = item.content?.toLowerCase().contains(lowerKeyword) == true;
    return titleContains || contentContains;
  }

  /// 判断当前知识点是否满足筛选条件
  bool _matchesFilter(UnitKnowledgePointsEntityKnowledgeList item) {
    if (!isAdminPage || !isFilter()) return true;
    if (!Get.isRegistered<ManageSettingController>()) return true;

    final ManageSettingController settingController = Get.find<ManageSettingController>();

    Map<String, dynamic> conditionParameter = FilterStripUtils.getConditionParameter(conditions: filterConditions);
    bool? locked = conditionParameter["locked"];

    bool knowledgeLocked = false;
    if (settingController.defaultResources.value == ResourceTypeEnum.image) {
      knowledgeLocked = item.locked == true;
    } else {
      knowledgeLocked = item.video?.locked == true;
    }
    if (locked != null && locked != knowledgeLocked) return false;

    bool? show = conditionParameter["show"];

    if (show == null) return true;
    if (show == true) return item.accessIsVisible;
    return !item.accessIsVisible;
  }

  /// 分类组装数据
  void classifyKnowledgeList(List<UnitKnowledgePointsEntityKnowledgeList> list) {
    List<CourseDetailsTargetContentTypeKnowledgeModel> wordList = [];
    List<CourseDetailsTargetContentTypeKnowledgeModel> phraseList = [];
    List<CourseDetailsTargetContentTypeKnowledgeModel> sentenceList = [];
    List<CourseDetailsTargetContentTypeKnowledgeModel> textList = [];
    List<CourseDetailsTargetContentTypeKnowledgeModel> songList = [];

    for (int i = 0; i < list.length; i++) {
      UnitKnowledgePointsEntityKnowledgeList? item = list[i];

      CourseDetailsTargetContentTypeKnowledgeModel knowledgeModel = CourseDetailsTargetContentTypeKnowledgeModel(
        knowledge: item,
        key: GlobalKey(),
      );

      if (item.isWord) {
        wordList.add(knowledgeModel);
      } else if (item.isPhrase) {
        phraseList.add(knowledgeModel);
      } else if (item.isSentence) {
        sentenceList.add(knowledgeModel);
      } else if (item.isText) {
        textList.add(knowledgeModel);
      } else if (item.isSong) {
        songList.add(knowledgeModel);
      }
    }

    for (int i = 0; i < knowledgeTypeList.length; i++) {
      knowledgeTypeList[i].knowledges.clear();
    }

    for (int i = 0; i < knowledgeTypeList.length; i++) {
      CourseDetailsTargetContentTypeModel item = knowledgeTypeList[i];
      if (item.type == ElementsCardType.word) {
        item.knowledges.addAll(wordList);
      } else if (item.type == ElementsCardType.phrase) {
        item.knowledges.addAll(phraseList);
      } else if (item.type == ElementsCardType.sentence) {
        item.knowledges.addAll(sentenceList);
      } else if (item.type == ElementsCardType.text) {
        item.knowledges.addAll(textList);
      } else if (item.type == ElementsCardType.song) {
        item.knowledges.addAll(songList);
      }
    }

    knowledgeTypeList.refresh();
  }

  /// 监听滚动
  void handleScroll() {
    if (!isScrolling.value) {
      isScrolling.value = true;
    }

    // ② 防抖：每一次滚轮都会把 timer 重置，只有在一段时间没有新滚轮时才算“结束”
    scrollTimer?.cancel();
    scrollTimer = Timer(const Duration(seconds: 1), () {
      isScrolling.value = false;
    });
  }

  /// 获取单词短语句子的知识点
  List<UnitKnowledgePointsEntityKnowledgeList> getWPSKnowledgeList() {
    List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = [];
    for (int i = 0; i < allKnowledgeList.length; i++) {
      if (allKnowledgeList[i].isWord || allKnowledgeList[i].isPhrase || allKnowledgeList[i].isSentence) {
        knowledgeList.add(allKnowledgeList[i]);
      }
    }
    return knowledgeList;
  }

  /// 去预习
  Future<void> previewCourse(BuildContext context) async {
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;
    bool student = await LockUtils.checkStudent(context);
    if(!student) return;
    if (courseId == null || levelId == null || moduleId == null || unitId == null) return;

    List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = getWPSKnowledgeList();
    if (knowledgeList.isEmpty) return;

    TagRoutes.toNamed(Routes.OFFICIAL_COURSE_DETAILS_PREVIEW, arguments: {
      "unitName": unitKnowledgePoints.value.unitName,
      "knowledgeList": knowledgeList,
    });
  }

  /// 去听写
  Future<void> dictationCourse(BuildContext context) async {
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;
    bool student = await LockUtils.checkStudent(context);
    if(!student) return;
    if (courseId == null || levelId == null || moduleId == null || unitId == null) return;

    List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = getWPSKnowledgeList();
    if (knowledgeList.isEmpty) return;

    TagRoutes.toNamed(Routes.OFFICIAL_COURSE_DETAILS_DICTATION, arguments: {
      "unitName": unitKnowledgePoints.value.unitName,
      "knowledgeList": knowledgeList,
    });
  }

  ///闪卡模式
  Future<void> flashCardCourse(BuildContext context) async {
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;
    bool student = await LockUtils.checkStudent(context);
    if(!student) return;
    if (courseId == null || levelId == null || moduleId == null || unitId == null) return;

    List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = getWPSKnowledgeList();
    if (knowledgeList.isEmpty) return;

    TagRoutes.toNamed(Routes.OFFICIAL_COURSE_DETAILS_FLASH_NOTES, arguments: {
      "knowledgeList": knowledgeList,
    });
  }

  /// 去下载
  Future<void> downloadAudio(BuildContext context) async {
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;
    bool student = await LockUtils.checkStudent(context);
    if(!student) return;
    await CourseDetailsTargetDownloadDialog.show(
      context: context,
      knowledgeList: knowledgeTypeList,
      moduleName: unitKnowledgePoints.value.moduleName ?? "",
      unitName: unitKnowledgePoints.value.unitName ?? "",
    );
  }

  // --------------- 管理端方法 -----------------

  /// 管理端编辑方法
  Future<void> adminEditFunction(BuildContext context, CourseDetailsTargetEditToastType type, UnitKnowledgePointsEntityKnowledgeList knowledge) async {

    if (type == CourseDetailsTargetEditToastType.image) {
      // 图片
      await adminEditImageFunction(knowledge);
    } else if (type == CourseDetailsTargetEditToastType.video) {
      // 视频
      await adminEditVideoFunction(knowledge);
    }else if (type == CourseDetailsTargetEditToastType.exercise) {
      // 题目
      await adminEditExerciseFunction(knowledge);
    } else if (type == CourseDetailsTargetEditToastType.content) {
      // 内容
      await adminEditContentFunction(knowledge);
    } else if (type == CourseDetailsTargetEditToastType.replaceSemantics) {
      // 替换义
      await adminEditReplaceSemanticsFunction(context, knowledge);
    }else if (type == CourseDetailsTargetEditToastType.replaceWord) {
      // 替换词
      await adminEditReplaceWordFunction(context, knowledge);
    }
  }

  /// 管理端图片方法
  Future<void> adminEditImageFunction(UnitKnowledgePointsEntityKnowledgeList knowledge) async {
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: {
        'type': knowledge.contentType, 
        'uid': knowledge.contentId, 
        'semanticId': knowledge.semanticId,
        "quizOrImage": 1,
      },
    );

    await getUnitTarget(showLoading: false);
  }

  /// 管理端视频方法
  Future<void> adminEditVideoFunction(UnitKnowledgePointsEntityKnowledgeList knowledge) async {
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: {
        'type': knowledge.contentType, 
        'uid': knowledge.contentId, 
        'semanticId': knowledge.semanticId,
        "quizOrImage": 2,
      },
    );

    await getUnitTarget(showLoading: false);
  }

  /// 管理端题目方法
  Future<void> adminEditExerciseFunction(UnitKnowledgePointsEntityKnowledgeList knowledge) async {
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: {
        'type': knowledge.contentType, 
        'uid': knowledge.contentId, 
        'semanticId': knowledge.semanticId,
        "quizOrImage": 0,
      },
    );

    await getUnitTarget(showLoading: false);
  }

  /// 管理端内容方法
  Future<void> adminEditContentFunction(UnitKnowledgePointsEntityKnowledgeList knowledge) async {
    String routes = "";
    if (knowledge.isWord) {
      routes = Routes.MANAGE_WORD;
    } else if (knowledge.isPhrase) {
      routes = Routes.MANAGE_PHRASE;
    } else if (knowledge.isSentence) {
      routes = Routes.MANAGE_SENTENCE;
    } else if (knowledge.isText) {
      routes = Routes.MANAGE_ARTICLE;
    } else if (knowledge.isSong) {
      routes = Routes.MANAGE_SONG;
    }
    if (routes.isEmpty) return;

    await ManagePageRegistry.jumpTo(
      routes,
      arguments: {
        "uid": knowledge.contentId,
      },
    );

    await getUnitTarget(showLoading: false);
  }

  /// 管理端替换义方法
  Future<void> adminEditReplaceSemanticsFunction(BuildContext context, UnitKnowledgePointsEntityKnowledgeList knowledge) async {
    List<EnEntitySemantics>? semantics = await getEnDefinition(knowledge);
    if (semantics == null) return;
    SelectSemanticManager.show(
      context: context,
      semantics: semantics,
      onOkTap: (List<EnEntitySemantics> semantics) {
        print("选中的语义: ${semantics.length},$semantics");
        if (semantics.isEmpty) return;

        final EnEntitySemantics? selectedSemantics = semantics.firstWhereOrNull((element) => element.isSelected);
        if (selectedSemantics == null) return;

        onEditKnowledgeSemantic(knowledge, selectedSemantics);
      },
    );
  }

  /// 管理端替换词方法
  Future<void> adminEditReplaceWordFunction(BuildContext context, UnitKnowledgePointsEntityKnowledgeList knowledge) async{

    int tabCurrentIndex = 0;
    if(knowledge.isWord){
      tabCurrentIndex = 0;
    }else if(knowledge.isPhrase){
      tabCurrentIndex = 1;
    }

    List<BaseKnowledge>? selectList = await ManageSelectKnowledgeTableManager.show(
      context: context, 
      defaultDessert: [],
      selectMax: 1,
      singleSelectionMode: true,
      showEmptyTip: false,
      tabCurrentIndex: tabCurrentIndex,
      word: knowledge.content,
    );
    if(selectList == null) return;
    if(selectList.isEmpty) return;

    EnEntitySemantics? selectedSemantics;
    if(selectList.first is EnWordEntity){
      EnWordEntity entity = selectList.first as EnWordEntity;
      selectedSemantics = entity.selectedSemantics;
    }else if(selectList.first is EnPhraseEntity){
      EnPhraseEntity entity = selectList.first as EnPhraseEntity;
      selectedSemantics = entity.selectedSemantics;
    }
    if(selectedSemantics == null) return;

    onEditKnowledgeSemantic(knowledge, selectedSemantics, contentId: selectList.first.uid);




  }

  /// 获取释义
  Future<List<EnEntitySemantics>?> getEnDefinition(UnitKnowledgePointsEntityKnowledgeList knowledge) async {
    Map<String, dynamic> parameters = {
      'offset': 0,
      'limit': 30,
      "order": "-wordFreq",
    };
    Map<String, dynamic> data = {
      "uid": [knowledge.contentId]
    };

    List<EnEntitySemantics>? semantics;

    try {
      ToastUtils.showLoading();
      if (knowledge.isWord) {
        //单词
        final ListResponseEntity<EnWordEntity>? response = await ManageSelectQuziKnowledge.getEnWordKnowledgeList(
          parameters: parameters,
          data: data,
        );
        if ((response?.datas ?? []).isEmpty) {
          ToastUtils.showToast(text: "暂无数据");
          return null;
        }
        final EnWordEntity enWord = response!.datas!.first;
        semantics = enWord.semantics!.map((s) => s.copyWith(language: language)).toList();
      } else if (knowledge.isPhrase) {
        //短语
        final ListResponseEntity<EnPhraseEntity>? response = await ManageSelectQuziKnowledge.getEnPhraseKnowledgeList(
          parameters: parameters,
          data: data,
        );
        if ((response?.datas ?? []).isEmpty) {
          ToastUtils.showToast(text: "暂无数据");
          return null;
        }
        final EnPhraseEntity enPhrase = response!.datas!.first;
        semantics = enPhrase.semantics!.map((s) => s.copyWith(language: language)).toList();
      }
      if (semantics == null) return null;
      for (final EnEntitySemantics s in semantics) {
        if (s.uid == knowledge.semanticId) {
          s.isSelected = true;
        }
      }
      return semantics;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
    } catch (e) {
      ToastUtils.showManageToast(text: e.toString(), type: ManageToastType.error);
    } finally{
      ToastUtils.hideLoading();
    }

    return null;
  }



  /// 替换语义接口
  Future<void> onEditKnowledgeSemantic(UnitKnowledgePointsEntityKnowledgeList knowledge, EnEntitySemantics selectedSemantics, {int? contentId}) async {
    
    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.editKnowledgeSemantic(
        unitId: unitId, 
        knowledgeId: knowledge.uid, 
        semanticId: selectedSemantics.uid, 
        config: RequestConfig(
          requireToken: true,
          parameters: {
            "contentId": contentId,
          },
        ),
      );

      if (response.data == null) {
        throw response.message ?? "未知错误";
      }

      await getUnitTarget(showLoading: false);
      isAdminEdit = true;
      ToastUtils.showManageToast(text: "替换成功", type: ManageToastType.defaultType);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
    } catch (e) {
      ToastUtils.showManageToast(text: e.toString(), type: ManageToastType.error);
    } finally{
      ToastUtils.hideLoading();
    }


  }

  /// 添加知识点方法
  Future<void> adminAddKnowledgeFunction(BuildContext context) async {

    bool isHideOther = unitKnowledgePoints.value.specialty == SpecialtyEnum.EN_PHONICS;
    List<BaseKnowledge>? values = await ManageSelectKnowledgeTableManager.show(
      context: context,
      defaultDessert: [],
      language: language,
      showSelectKnowledgeAddButton: true,
      hidePhrase: isHideOther,
      hideSentence: isHideOther,
      hideText: isHideOther,
      topic: unitKnowledgePoints.value.moduleTopic,
      dataDisableCallback: (BaseKnowledge targetEntity) {
        bool isDisable = allKnowledgeList.any((element) => element.contentId == targetEntity.uid);
        return isDisable;
      },
    );
    if (values == null) return;

    try {
      final List<Knowledge> newLs = <Knowledge>[];

      for (int i = 0; i < values.length; i++) {
        final entity = values[i];
        if (entity is EnWordEntity) {
          newLs.add(Knowledge(
            uid: entity.uid,
            contentType: entity.contentType,
            content: entity.content,
            contentId: entity.uid,
            definition: entity.definition,
            semanticId: entity.selectedSemantics?.uid,
            imageUrl: entity.imageUrl,
            audioUrl: entity.audioUrl,
            language: entity.language,
          ));
        } else if (entity is EnPhraseEntity) {
          newLs.add(Knowledge(
            uid: entity.uid,
            contentType: entity.contentType,
            content: entity.content,
            contentId: entity.uid,
            definition: entity.definition,
            semanticId: entity.selectedSemantics?.uid,
            imageUrl: entity.imageUrl,
            audioUrl: entity.audioUrl,
            language: entity.language,
          ));
        } else if (entity is EnSentenceEntity) {
          newLs.add(Knowledge(
            uid: entity.uid,
            contentType: entity.contentType,
            content: entity.content,
            contentId: entity.uid,
            definition: entity.definition,
            semanticId: entity.selectedSemantics?.uid,
            imageUrl: entity.imageUrl,
            audioUrl: entity.audioUrl,
            language: entity.language,
          ));
        } else if (entity is EnTextEntity) {
          newLs.add(Knowledge(
            uid: entity.uid,
            contentType: entity.contentType,
            content: entity.content,
            contentId: entity.uid,
            definition: entity.title,
            imageUrl: entity.imageUrl,
            audioUrl: entity.audioUrl,
            language: entity.language,
          ));
        }
      }

      RequestConfig requestConfig = RequestConfig(
        requireToken: true,
        parameters: {"moduleId": moduleId},
        data: newLs.map((element) => element.toJson()).toList(),
      );
      ToastUtils.showLoading();
      final response = await KnowledgeUtil.add(unitId: unitId, config: requestConfig);
      if (response.code == HttpStatus.ok) {
        ToastUtils.showManageToast(text: '添加知识点成功');
        await getUnitTarget(showLoading: false);
        isAdminEdit = true;
      } else {
        ToastUtils.showManageToast(text: response.message ?? '添加知识点失败');
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
    } catch (e) {
      ToastUtils.showManageToast(text: e.toString());
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 知识点删除
  /// flag: 1 表示从当前知识点列表删除，0 表示从知识库里彻底删除
  Future<void> adminDeleteKnowledgeTap(BuildContext context, UnitKnowledgePointsEntityKnowledgeList knowledge, int flag) async {

    if (knowledge.uid == null) return;

    try {
      ToastUtils.showLoading();
      RequestConfig requestConfig = RequestConfig(
        requireToken: true,
        parameters: {
          "uid": [knowledge.uid],
          "flag": flag
        },
      );
      final response = await UnitUtil.deleteKnowledge(unitId: unitId, config: requestConfig);
      if (response.code == HttpStatus.ok) {
        ToastUtils.showManageToast(text: '删除成功');
        // units.removeAt(index);
        allKnowledgeList.remove(knowledge);
        classifyKnowledge();
        isAdminEdit = true;
      } else {
        ToastUtils.showManageToast(text: response.message ?? '删除失败');
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
    } catch (e) {
      ToastUtils.showManageToast(text: e.toString());
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 进入排序模式
  void enterSortingMode(ElementsCardType type){
    searchController.clear();

    for (final FilterConditionsData data in filterConditions.values) {
      for (final FilterConditionsItem condition in data.conditions) {
        condition.selected = false;
      }
    }

    applySearchAndFilter();

    isSortMode.value = true;
    sortKnowledgeType.value = type;
  }

  /// 知识点排序
  Future<void> onSortKnowledge(int oldIndex, int newIndex) async {
    try {
      ToastUtils.showLoading();
      CourseDetailsTargetContentTypeModel current = knowledgeTypeList.firstWhere((element) => element.type == sortKnowledgeType.value);
      List<CourseDetailsTargetContentTypeKnowledgeModel> knowledges = current.knowledges;

      CourseDetailsTargetContentTypeKnowledgeModel movedLesson = knowledges.removeAt(oldIndex);
      knowledges.insert(newIndex, movedLesson);

      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: {
          "index": newIndex + 1,
          "type": movedLesson.knowledge.contentType,
        },
      );

      final response = await KnowledgeUtil.order(
        unitId: unitId.toString(),
        knowledgeId: movedLesson.knowledge.uid,
        config: config,
      );
      if (response.code == HttpStatus.ok) {
        ToastUtils.showManageToast(text: "排序成功");
      } else {
        ToastUtils.showManageToast(text: response.message ?? "排序失败");
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 是否正在筛选中
  bool isFilter(){
    // 条件是否都为false
    bool isAllConditionFalse = filterConditions.values.every((element) => element.conditions.every((element) => !element.selected));
    return !isAllConditionFalse;
  }

  /// 筛选
  Future<void> onChangeFilter(Map<String, FilterConditionsData> datas) async{
    if(!isAdminPage) return;
    filterConditions.value = datas;
    applySearchAndFilter();
  }




}
