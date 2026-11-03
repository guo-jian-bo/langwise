import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_beat_utils.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../../../../utils/download_content_resource_utils/course_details_target_download_dialog.dart';
import '../../../../routes/tag_routes.dart';
import 'course_unit_target_knowledge_controller.dart';
import 'course_unit_target_manage_controller.dart';
import 'course_unit_target_syntax_controller.dart';

class CourseUnitTargetController extends GetxController with DualBreadcrumbMixin, PageRefreshAwareMixin {
  final String tagText;
  CourseUnitTargetController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.COURSE_UNIT_TARGET;

  @override
  String get breadcrumbTitle => "单元目标";

  // 传进来的参数
  /// 是否是管理端
  bool isManagement = false;
  int? courseId;
  int? levelId;
  int? moduleId;
  int? unitId;
  String? language;
  CourseUnitTargetEnum initialKnowledgeType = CourseUnitTargetEnum.overview;

  /// 段落/文章的步骤
  final RxList<ParagraphRhetoricalEntityList> paragraphRhetoricalList = <ParagraphRhetoricalEntityList>[].obs;

  /// 单元目标详情
  final Rx<CourseUnitTargetEntity> unitKnowledgePoints = CourseUnitTargetEntity().obs;

  /// 知识点搜索/筛选控制器。
  CourseUnitTargetKnowledgeController get knowledgeController => Get.find<CourseUnitTargetKnowledgeController>(tag: tagText);

  /// 句法分页控制器。
  CourseUnitTargetSyntaxController get syntaxController => Get.find<CourseUnitTargetSyntaxController>(tag: tagText);

  /// 知识点管理控制器。
  CourseUnitTargetManageController get manageKnowledgeController => Get.find<CourseUnitTargetManageController>(tag: tagText);

  /// 锚点定位数据列表
  final RxList<AnchorPositionData> anchorPositionList = <AnchorPositionData>[].obs;

  /// 当前显示的知识点类型页面
  final Rx<CourseUnitTargetEnum> currentKnowledgeType = CourseUnitTargetEnum.overview.obs;

  /// 句法页面下的tab筛选 0=句子 1=句组 2=语法
  final RxInt syntaxTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      courseId = Get.arguments["courseId"];
      levelId = Get.arguments["levelId"];
      moduleId = Get.arguments["moduleId"];
      unitId = Get.arguments["unitId"];
      isManagement = Get.arguments["isManagement"] ?? false;
      // isManagement = false;
      language = Get.arguments["language"];
      initialKnowledgeType =
          CourseUnitTargetEnum.fromRawValue(Get.arguments["initialKnowledgeType"]?.toString() ?? "") ?? CourseUnitTargetEnum.overview;

      // unitId = 13860;
      getUnitTarget();
    }
    getParagraphRhetoricalList();
  }

  @override
  Future<void> onReturnPageRefresh(String? key) async{
    await getUnitTarget(showLoading: false, shouldResetKnowledgeType: false);
  }

  /// 段落/文章的步骤
  Future<void> getParagraphRhetoricalList() async {
    try {
      paragraphRhetoricalList.clear();
      await ensureZhenxieBeatData();
      for (final String beatNid in zhenxieBeatOrderList) {
        final ParagraphRhetoricalEntityList? item = zhenxieBeatMap[beatNid];
        if (item == null) continue;
        paragraphRhetoricalList.add(item);
      }
    } catch (_) {}
  }

  /// 刷新单元目标
  Future<void> refreshUnitTarget() async {
    try {
      ToastUtils.showLoading();
      await getUnitTarget(showLoading: false, shouldResetKnowledgeType: false);
      syntaxController.getSyntaxStatistics();
      if(syntaxTab.value == 1){
        await syntaxController.refreshList(showLoading: false);
      }else if(syntaxTab.value == 2){
        await syntaxController.getGrammarList(showLoading: false);
      }
    } finally{
      ToastUtils.hideLoading();
    }
  }


  Future<void> getUnitTarget({bool showLoading = true, bool shouldResetKnowledgeType = true}) async {
    if(isClosed) return;
    try {
      if (showLoading) ToastUtils.showLoading();

      CourseUnitTargetEntity? entity;
      if (isManagement) {
        if (unitId == null) return;
        entity = await CourseConsoleRequest.getCourseUnitTargetList(unitId: unitId!);
      } else {
        if (courseId == null || levelId == null || moduleId == null || unitId == null) return;

        entity = await CourseAppUtil.getCourseUnitTargetList(
          courseId: courseId!,
          moduleId: moduleId!,
          unitId: unitId!,
        );
      }
      if (entity == null) return;
      unitKnowledgePoints.value = entity;
      List<KnowledgeCommonEntityList?>? list = unitKnowledgePoints.value.knowledgeList;
      if (list == null) return;
      final knowledgeList = <KnowledgeCommonEntityList>[];
      for (int i = 0; i < list.length; i++) {
        KnowledgeCommonEntityList? item = list[i];
        if (item == null) continue;
        knowledgeList.add(item);
      }
      if(isClosed) return;
      knowledgeController.updateKnowledgeList(knowledgeList);

      separateKnowledgeType(shouldResetKnowledgeType: shouldResetKnowledgeType);

      manageKnowledgeController.executeSearch();

    } finally {
      if (showLoading) ToastUtils.hideLoading();
    }
  }

  /// 区分知识点类型
  void separateKnowledgeType({bool shouldResetKnowledgeType = true}) {
    anchorPositionList.clear();

    _addFilterLocateIfNeeded(CourseUnitTargetEnum.overview, []);
    _addFilterLocateIfNeeded(CourseUnitTargetEnum.vocabulary, knowledgeController.allVocabularyKnowledgeList);
    _addFilterLocateIfNeeded(CourseUnitTargetEnum.syntax, knowledgeController.allSyntaxKnowledgeList);
    _addFilterLocateIfNeeded(CourseUnitTargetEnum.listening, knowledgeController.allListeningKnowledgeList);
    _addFilterLocateIfNeeded(CourseUnitTargetEnum.reading, knowledgeController.allReadingKnowledgeList);
    _addFilterLocateIfNeeded(CourseUnitTargetEnum.writing, knowledgeController.allWritingKnowledgeList);
    _addFilterLocateIfNeeded(CourseUnitTargetEnum.comprehensive, knowledgeController.allComprehensiveKnowledgeList);

    if (anchorPositionList.isEmpty) return;

    if (shouldResetKnowledgeType) {
      currentKnowledgeType.value = _getAvailableKnowledgeType(initialKnowledgeType);
      return;
    }

    currentKnowledgeType.value = _getAvailableKnowledgeType(currentKnowledgeType.value);
  }

  /// 按分类添加底部筛选项
  void _addFilterLocateIfNeeded(CourseUnitTargetEnum type, List<KnowledgeCommonEntityList> list) {
    if (type != CourseUnitTargetEnum.overview && list.isEmpty && !isManagement) return;

    String name = type.title;
    if (type != CourseUnitTargetEnum.overview) {
      name += " ${list.length}";
    }
    // 设置筛选列表
    anchorPositionList.add(AnchorPositionData(
      key: GlobalKey(),
      name: name,
      value: type,
    ));
  }

  /// 获取当前列表中可用的知识点类型，不存在时默认取第一个。
  CourseUnitTargetEnum _getAvailableKnowledgeType(CourseUnitTargetEnum targetType) {
    for (final AnchorPositionData item in anchorPositionList) {
      if (item.value == targetType) return targetType;
    }
    return anchorPositionList.first.value as CourseUnitTargetEnum;
  }

  /// 切换知识点类型
  void switchKnowledgeType(CourseUnitTargetEnum type) {

    if(type == CourseUnitTargetEnum.syntax){
      if(syntaxController.syntaxStatistics.value == null){
        syntaxController.getSyntaxStatistics();
      }
    }

    currentKnowledgeType.value = type;
    if(type == CourseUnitTargetEnum.overview){
      updateBreadcrumbTitle(breadcrumbTitle);
    }else{
      updateBreadcrumbTitle(type.title);
    }
  }

  /// 切换句子类型
  Future<void> switchSyntaxType(int index) async{
    if (syntaxTab.value == index) return;
    
    if(index == 1){
      if(syntaxController.groupList.isEmpty){
        await syntaxController.refreshList(showLoading: true);
      }
    }else if(index == 2){
      if(knowledgeController.sentenceGrammarList.isEmpty){
        await syntaxController.getGrammarList(showLoading: true);
      }
    }
    syntaxTab.value = index;
  }

  /// 页面返回 需要先返回总览
  void checkBackToOverview({bool back = false}) {
    if (currentKnowledgeType.value != CourseUnitTargetEnum.overview) {
      currentKnowledgeType.value = CourseUnitTargetEnum.overview;
      updateBreadcrumbTitle(breadcrumbTitle);
      return;
    }
    if(!back) return;
    Get.back();

  }

  /// 下载方法
  Future<void> downloadAudio(BuildContext context) async {
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;
    bool student = await LockUtils.checkStudent(context);
    if (!student) return;

    List<KnowledgeCommonEntityList> knowledgeList = [];
    for (var element in knowledgeController.allKnowledgeList) {
      if (element.contentTypeEnum != KnowledgeTypeEnum.EN_COMPOSITION && element.contentTypeEnum != KnowledgeTypeEnum.SCRIPT) {
        knowledgeList.add(element);
      }
    }

    await CourseDetailsTargetDownloadDialog.show(
      context: context,
      knowledgeList: CourseDetailsTargetDownloadConvertUtils.buildKnowledgeTypeListFromCourseUnitTarget(knowledgeList),
      moduleName: unitKnowledgePoints.value.moduleName ?? "",
      unitName: unitKnowledgePoints.value.unitName ?? "",
    );
  }

  /// 跳转至语法详情 Routes.COURSE_UNIT_GRAMMAR_DETAILS
  Future<void> jumpToGrammarDetail(CourseUnitTargetSentenceGrammarTargetEntity? target) async {
    TagRoutes.toNamed(
      Routes.COURSE_UNIT_GRAMMAR_DETAILS,
      arguments: {
        "unitId": unitId,
        "targetUid": target?.uid,
        "isManagement": isManagement,
      },  
    );
  }



}
