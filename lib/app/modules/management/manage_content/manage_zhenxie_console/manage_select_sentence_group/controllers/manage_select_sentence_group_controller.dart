import 'dart:io';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';

class ManageSelectSentenceGroupController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageSelectSentenceGroupController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SELECT_SENTENCE_GROUP;

  @override
  String get breadcrumbTitle => '选择句组';

  // 传进来的参数
  int? sentenceId;
  /// 0 = 单元目标选择句组
  int pageType = 0;
  // --- 单元添加知识点的参数
  int? moduleId;
  int? unitId;

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{}.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "句面或句子ID",
      controller: TextEditingController(),
    ),
  };

  final RxList<CourseUnitTargetSentenceGrammarGroupEntity> dataList = <CourseUnitTargetSentenceGrammarGroupEntity>[].obs;

  /// 滚动控制器
  final ScrollController scrollController = ScrollController();
  /// 总条数
  int total = 0;
  /// offset
  int offset = 0;
  /// limit
  int limit = 20;
  /// 是否加载中
  final RxBool isLoading = false.obs;

  /// 选择的index
  final RxList<int> selectIndexs = <int>[].obs;


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if(Get.arguments != null){
      sentenceId = Get.arguments['sentenceId'];
      pageType = Get.arguments['pageType'] ?? 0;
      moduleId = Get.arguments['moduleId'];
      unitId = Get.arguments['unitId'];
      refreshList();
    }

    listenScroll();
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange){
        if(!isLoading.value && dataList.length < total){
          offset += limit;
          getListData();
        }
      }
    });
  }


  /// 刷新列表
  Future<void> refreshList() async{
    dataList.clear();
    offset = 0;
    total = 0;
    getListData();
  }

  /// 获取列表数据
  Future<void> getListData() async{
    if(sentenceId == null) return;
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };
      Map<String, dynamic> sortParams = FilterStripUtils.getSortOrderParameter(sorts: filterSorts);
      if(sortParams.isNotEmpty){
        params.addAll(sortParams);
      }

      Map<String, dynamic> reqData = {
        "sentenceIds": [sentenceId],
      };
      Map<String, dynamic> conditionParams = FilterStripUtils.getConditionParameter(
        conditions: filterConditions, 
        singleToList: true,
      );
      List<Map<String, dynamic>> filters = [];
      conditionParams.forEach((key, value) {
        filters.add({
          "code": key,
          "values": value,
        });
      });
      if(filters.isNotEmpty){
        reqData["filters"] = filters;
      }

      ListResponseEntity<CourseUnitTargetSentenceGrammarGroupEntity>? entity = await LanguageConsoleRequest.getSentenceGrammarList(
        params: conditionParams,
        data: reqData,
      );
      if (entity == null) return;
      dataList.addAll(entity.datas ?? []);
      total = entity.count ?? 0;
    } finally{
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  /// 选择句组
  void selectSentenceGroup(int index){
    if(selectIndexs.contains(index)){
      selectIndexs.remove(index);
    } else{
      selectIndexs.add(index);
    }
  }


  /// 添加提交
  Future<void> addSubmit() async{

    if(selectIndexs.isEmpty) return ToastUtils.showToast(text: "请选择句组");

    if(pageType == 0){
      addUnitKnowledgePoints();
    }

  }


  /// 添加单元知识点
  Future<void> addUnitKnowledgePoints() async{
    
    if(moduleId == null || unitId == null) return ToastUtils.showToast(text: "moduleId 或 unitId 不能为空");

    List<Map<String, dynamic>> reqData = [];
    for (var i = 0; i < dataList.length; i++) {
      if(!selectIndexs.contains(i)) continue;
      if(dataList[i].typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR){
        final realizationSets = dataList[i].payload?.sentencePair?.realizationSets ?? [];
        if(realizationSets.isEmpty) continue;
        final firstRealizationSet = realizationSets.first;
        final firstRealizationSetStruct = firstRealizationSet?.pairFromMember?.sentence;
        final toSentenceStruct = firstRealizationSet?.pairToMember?.sentence;
        if(firstRealizationSetStruct == null && toSentenceStruct == null) continue;
        if(firstRealizationSetStruct != null){
          reqData.add({
            "content": firstRealizationSetStruct.content,
            "contentId": firstRealizationSetStruct.sentenceId,
            "semanticId": firstRealizationSetStruct.semanticId,
            "definition": firstRealizationSetStruct.definition,
            "contentType": firstRealizationSetStruct.contentType,
          });
        }
        if(toSentenceStruct != null){
          reqData.add({
            "content": toSentenceStruct.content,
            "contentId": toSentenceStruct.sentenceId,
            "semanticId": toSentenceStruct.semanticId,
            "definition": toSentenceStruct.definition,
            "contentType": toSentenceStruct.contentType,
          });
        }

        reqData.add({
          "contentType": firstRealizationSet?.contentType,
          "contentId": firstRealizationSet?.uid,
        });

      }else{

        final realizationSets = dataList[i].payload?.realizationSets??[];
        if(realizationSets.isEmpty) continue;
        ZhenxieRealizationSetsEntity? realizationSetEntity = realizationSets.first;
        if(realizationSetEntity == null) continue;

        final memberList = realizationSetEntity.members??[];
        if(memberList.isEmpty) continue;

        for (var element in memberList) {
          if(element == null) continue;
          reqData.add({
            "content": element.sentence?.content,
            "contentId": element.sentence?.sentenceId,
            "semanticId": element.sentence?.semanticId,
            "definition": element.sentence?.definition,
            "contentType": element.sentence?.contentType,
          });
        }

        reqData.add({
          "contentType": realizationSetEntity.contentType,
          "contentId": realizationSetEntity.uid,
        });
        
      }
    
    }

    try {
      ToastUtils.showLoading();

      RequestConfig requestConfig = RequestConfig(
        requireToken: true,
        parameters: {"moduleId": moduleId},
        data: reqData,
      );
      ToastUtils.showLoading();
      final response = await KnowledgeUtil.add(unitId: unitId, config: requestConfig);
      if (response.code == HttpStatus.ok) {
        ToastUtils.showToast(text: '添加成功', type: ToastType.success);
        Get.back(result: true);
      } else {
        ToastUtils.showToast(text: response.message ?? '添加失败');
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
    } catch (e) {
      ToastUtils.showToast(text: e.toString());
    } finally {
      ToastUtils.hideLoading();
    }

  }





  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
