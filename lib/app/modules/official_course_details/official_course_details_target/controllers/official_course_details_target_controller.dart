import 'dart:async';
import 'dart:io';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/utils/utils.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../management/common/manage_select_knowledge_table/view.dart';
import '../../../management/common/manage_select_knowledge_table/views/select_semantic_widget.dart';
import '../../../management/utils/utils.dart';
import '../../common/official_course_details_target_widgets.dart';
import '../enum/course_knowledge_visible_enum.dart';
import '../models/course_details_target_content_type_model.dart';
import '../common/course_details_target_download_dialog.dart';

class OfficialCourseDetailsTargetController extends GetxController {
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

  /// 知识点可见筛选
  final List<CourseKnowledgeVisibleEnum> knowledgeVisibleFilterList = CourseKnowledgeVisibleEnum.values;

  /// 选中的知识点可见筛选
  final Rx<CourseKnowledgeVisibleEnum> selectedKnowledgeVisibleFilter = CourseKnowledgeVisibleEnum.all.obs;

  @override
  void onInit() {
    super.onInit();
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
        entity = await OfficialCourseDetailsRequest.getAdminUnitTarget(unitId!);
      } else {
        if (courseId == null || levelId == null || moduleId == null || unitId == null) return;
        entity = await OfficialCourseDetailsRequest.getUnitTarget(courseId!, moduleId!, unitId!);
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
      if (searchController.text.trim().isNotEmpty) {
        realTimeSearch(searchController.text.trim());
      }

      switchKnowledgeVisibleFilter(selectedKnowledgeVisibleFilter.value);
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
      // duration: const Duration(milliseconds: 300),
      // curve: Curves.ease,
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

  /// 切换知识点可见性
  void switchKnowledgeVisibleFilter(CourseKnowledgeVisibleEnum value) {
    selectedKnowledgeVisibleFilter.value = value;

    List<UnitKnowledgePointsEntityKnowledgeList> list = allKnowledgeList.toList();
    List<UnitKnowledgePointsEntityKnowledgeList> respList = [];

    for (int i = 0; i < list.length; i++) {
      if (value == CourseKnowledgeVisibleEnum.all) {
        respList.add(list[i]);
      } else if (value == CourseKnowledgeVisibleEnum.visible) {
        if (list[i].accessIsVisible) {
          respList.add(list[i]);
        }
      } else if (value == CourseKnowledgeVisibleEnum.invisible) {
        if (!list[i].accessIsVisible) {
          respList.add(list[i]);
        }
      }
    }

    classifyKnowledgeList(respList);
  }

  /// 展开搜索框
  void expandSearch() {
    isSearchExpanded.value = true;
    searchFocusNode.requestFocus();
  }

  /// 实时执行搜索
  void realTimeSearch(String value) {
    String keyword = value.trim();

    bool isEmpty = keyword.isEmpty;

    List<UnitKnowledgePointsEntityKnowledgeList> list = allKnowledgeList.toList();

    List<UnitKnowledgePointsEntityKnowledgeList> respList = [];

    for (int i = 0; i < list.length; i++) {
      UnitKnowledgePointsEntityKnowledgeList item = list[i];

      bool titleContains = item.title?.toLowerCase().contains(keyword.toLowerCase()) == true;
      bool contentContains = item.content?.toLowerCase().contains(keyword.toLowerCase()) == true;
      bool isContains = titleContains || contentContains;

      if (!isContains && !isEmpty) continue;

      respList.add(item);
    }

    classifyKnowledgeList(respList);
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

    Get.toNamed(Routes.OFFICIAL_COURSE_DETAILS_PREVIEW, arguments: {
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

    Get.toNamed(Routes.OFFICIAL_COURSE_DETAILS_DICTATION, arguments: {
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

    Get.toNamed(Routes.OFFICIAL_COURSE_DETAILS_FLASH_NOTES, arguments: {
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
    } else if (type == CourseDetailsTargetEditToastType.exercise) {
      // 题目
      await adminEditExerciseFunction(knowledge);
    } else if (type == CourseDetailsTargetEditToastType.content) {
      // 内容
      await adminEditContentFunction(knowledge);
    } else if (type == CourseDetailsTargetEditToastType.replace) {
      // 替换
      await adminEditReplaceFunction(context, knowledge);
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

  /// 管理端替换方法
  Future<void> adminEditReplaceFunction(BuildContext context, UnitKnowledgePointsEntityKnowledgeList knowledge) async {
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
  Future<void> onEditKnowledgeSemantic(UnitKnowledgePointsEntityKnowledgeList knowledge, EnEntitySemantics selectedSemantics) async {
    
    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.editKnowledgeSemantic(
        unitId: unitId, 
        knowledgeId: knowledge.uid, 
        semanticId: selectedSemantics.uid, 
        config: RequestConfig(requireToken: true),
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
}
