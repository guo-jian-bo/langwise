import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../model/elements_jump_module_type.dart';

class ElementsSentenceAnalysisController extends GetxController
    with RoutesBreadcrumbMixin {
  final String tagText;
  ElementsSentenceAnalysisController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.EN_SENTENCE_ANALYSIS;

  @override
  String get breadcrumbTitle => "语句分析";

  /// 页面路由入参：句子主键
  int? contentId;

  /// 页面路由入参：分析层
  String? layer;

  /// 页面路由入参：旧版模块语义
  String? module;

  /// 分析页当前分析层
  final RxString analysisLayer = 'chunks'.obs;

  /// 分析页结构详情原始数据
  final Rx<EnSentenceStructureDetailEntity> sentenceDetils = EnSentenceStructureDetailEntity().obs;

  final RxBool isLoading = true.obs;

  /// 关联 tab 独立分页列表
  final RxList<CourseUnitTargetSentenceGrammarGroupEntity> relationList =
      <CourseUnitTargetSentenceGrammarGroupEntity>[].obs;

  /// 关联 tab 滚动控制器
  final ScrollController relationsScrollController = ScrollController();

  /// 关联 tab 总条数
  final RxInt relationsTotal = 0.obs;

  /// 关联 tab 是否加载中
  final RxBool isRelationsLoading = false.obs;

  /// 关联 tab 当前 offset
  int relationsOffset = 0;

  /// 关联 tab 单页数量
  final int relationsLimit = 8;

  /// 关联 tab 是否已完成首轮加载
  bool hasLoadedRelations = false;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    _initArguments();
    _listenRelationsScroll();
    if (contentId != null) {
      initData();
    } else {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    relationsScrollController.dispose();
    super.onClose();
  }

  void _initArguments() {
    final dynamic arguments = Get.arguments;
    if (arguments == null) return;
    contentId = arguments['contentId'];
    layer = arguments['layer']?.toString();
    module = arguments['module']?.toString();
    analysisLayer.value = _resolveLayer(
      explicitLayer: layer,
      module: module,
    );
  }

  Future<void> initData() async {
    try {
      ToastUtils.showLoading();
      isLoading.value = true;
      await getDetilsV2();
      if (analysisLayer.value == 'relations') {
        await refreshRelations();
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> getDetilsV2() async {
    if (contentId == null) {
      isLoading.value = false;
      return;
    }
    final EnSentenceStructureDetailEntity? detils =
        await ElementsRequest.getSentenceStructureDetils(contentId!);
    if (detils == null) {
      isLoading.value = false;
      return;
    }
    sentenceDetils.value = detils;
    isLoading.value = false;
  }

  void changeAnalysisLayer(String layer) {
    if ((layer).isEmpty || analysisLayer.value == layer) return;
    analysisLayer.value = layer;
    if (layer == 'relations' && !hasLoadedRelations) {
      refreshRelations();
    }
  }

  /// 监听关联 tab 列表滚动，触发分页加载
  void _listenRelationsScroll() {
    relationsScrollController.addListener(() {
      if (relationsScrollController.position.pixels <
          relationsScrollController.position.maxScrollExtent - 200) {
        return;
      }
      if (relationsScrollController.position.outOfRange) return;
      if (isRelationsLoading.value) return;
      if (relationList.length >= relationsTotal.value) return;
      relationsOffset += relationsLimit;
      getRelations();
    });
  }

  /// 重置关联 tab 分页并重新请求
  Future<void> refreshRelations() async {
    relationList.clear();
    relationsOffset = 0;
    relationsTotal.value = 0;
    hasLoadedRelations = false;
    await getRelations();
  }

  /// 获取关联 tab 句组列表
  Future<void> getRelations() async {
    if (contentId == null) return;
    try {
      isRelationsLoading.value = true;
      final ListResponseEntity<CourseUnitTargetSentenceGrammarGroupEntity>? entity =
          await LanguageUtil.getSentenceGrammarList(
        params: {
          'offset': relationsOffset,
          'limit': relationsLimit,
        },
        data: {
          'sentenceIds': [contentId],
        },
      );
      if (entity == null) return;
      relationList.addAll(entity.datas ?? []);
      relationsTotal.value = entity.count ?? 0;
      hasLoadedRelations = true;
    } finally {
      isRelationsLoading.value = false;
    }
  }

  String _resolveLayer({
    String? explicitLayer,
    String? module,
  }) {
    if ((explicitLayer ?? '').isNotEmpty) {
      return explicitLayer!;
    }
    if (module == ElementsJumpModuleType.SYNTACTIC_ANALYSIS) {
      return 'syntax';
    }
    if (module == ElementsJumpModuleType.COMPONENT_ANALYSIS) {
      return 'svoca';
    }
    if (module == ElementsJumpModuleType.CHUNK_ANALYSIS ||
        module == ElementsJumpModuleType.GRID_VIEW ||
        module == ElementsJumpModuleType.COLLAPSE_VIEW ||
        module == ElementsJumpModuleType.STRUCTURE_ANALYSIS) {
      return 'chunks';
    }
    return 'chunks';
  }
}
