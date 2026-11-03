
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../utils/utils.dart';
import 'course_unit_target_controller.dart';

class CourseUnitTargetSyntaxController extends GetxController {
  final String tagText;
  CourseUnitTargetSyntaxController({required this.tagText});

  /// 父级页面控制器。
  CourseUnitTargetController get controller => Get.find<CourseUnitTargetController>(tag: tagText);

  ///句法统计
  final Rx<UnitTargetSyntaxStatisticsEntity?> syntaxStatistics = Rx(null);

  /// 句子句组列表
  final RxList<CourseUnitTargetSentenceGrammarGroupEntity> groupList = <CourseUnitTargetSentenceGrammarGroupEntity>[].obs;

  /// 滚动控制器
  final ScrollController scrollController = ScrollController();
  /// 总条数
  final RxInt total = 0.obs;
  /// offset
  int offset = 0;
  /// limit
  int limit = 20;
  /// 是否加载中
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    listenScroll();
  }


  /// 监听列表滚动进行分页加载
  void listenScroll(){
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange){
        if(!isLoading.value && groupList.length < total.value){
          offset += limit;
          getSyntaxKnowledge(showLoading: true);
        }
      }
    });
  }

  /// 获取句法页面统计
  Future<void> getSyntaxStatistics() async{
    try {
      ToastUtils.showLoading();
      UnitTargetSyntaxStatisticsEntity? entity;
      if (controller.isManagement) {
        entity = await CourseConsoleRequest.getCourseUnitTargetSyntaxStatistics(unitId: controller.unitId!);
      } else {
        entity = await CourseAppUtil.getCourseUnitTargetSyntaxStatistics(unitId: controller.unitId!);
      }
      if (entity == null) return;
      syntaxStatistics.value = entity;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 刷新列表
  Future<void> refreshList({bool showLoading = false}) async{
    try {
      if(showLoading) ToastUtils.showLoading();
      groupList.clear();
      offset = 0;
      total.value = 0;
      await getSyntaxKnowledge();
    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 获取句组列表
  Future<void> getSyntaxKnowledge({bool showLoading = false}) async {

    List<int> sentenceIds = [];
    final syntaxKnowledgeList = controller.knowledgeController.syntaxKnowledgeList;
    for(final item in syntaxKnowledgeList){
      if(item.contentId == null) continue;
      sentenceIds.add(item.contentId!);
    }

    try {
      isLoading.value = true;
      if(showLoading) ToastUtils.showLoading();
      Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };
      Map<String, dynamic> reqData = {
        "sentenceIds": sentenceIds,
      };

      ListResponseEntity<CourseUnitTargetSentenceGrammarGroupEntity>? entity;
      if (controller.isManagement) {
        entity = await LanguageConsoleRequest.getUnitSentenceGrammarList(
          unitId: controller.unitId!,
          params: params,
          data: reqData,
        );
      }else {
        entity = await CourseAppUtil.getUnitSentenceGrammarList(
          unitId: controller.unitId!,
          params: params,
          data: reqData,
        );
      }
      if (entity == null) return;
      groupList.addAll(entity.datas ?? []);
      total.value = entity.count ?? 0;

    }finally{
      isLoading.value = false;
      if(showLoading) ToastUtils.hideLoading();
    }
  }


  /// 获取语法列表
  Future<void> getGrammarList({bool showLoading = false}) async{
    if(controller.unitId == null) return;
    try {
      if(showLoading) ToastUtils.showLoading();
      CourseUnitTargetSentenceGrammarEntity? entity;
      if (controller.isManagement) {
        entity = await CourseConsoleRequest.getCourseUnitTargetSentenceGrammarList(unitId: controller.unitId!);
      } else {
        entity = await CourseAppUtil.getCourseUnitTargetSentenceGrammarList(unitId: controller.unitId!);
      }
      if (entity == null) return;
      final points = entity.grammar?.points ?? [];

      controller.knowledgeController.updateSentenceGrammarList(points.whereType<CourseUnitTargetSentenceGrammarPointEntity>().toList());

    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }

  }

// /course/unit/5326/knowledge/grammar/list
}
