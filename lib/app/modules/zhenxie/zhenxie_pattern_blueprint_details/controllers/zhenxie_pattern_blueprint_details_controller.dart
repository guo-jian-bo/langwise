import 'package:api/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/mixins/mixins.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../theme/theme.dart';
import '../../../elements/utils/elements_page_utils.dart';
import '../views/zhenxie_pattern_edit_represent_dialog.dart';

class ZhenxiePatternBlueprintDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxiePatternBlueprintDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_PATTERN_BLUEPRINT_DETAILS;

  @override
  String get breadcrumbTitle => '句型蓝图详情';

  /// 传进来的参数
  String? nid;
  /// 是否是金字塔
  bool supportsPyramid = false;
  /// 是否是管理端入口打开
  bool isManagement = false;

  final Rx<PatternBlueprintEntity> patternBlueprint = PatternBlueprintEntity().obs;

  /// 蓝图例句列表
  final RxList<PatternBlueprintExampleEntity> exampleList = <PatternBlueprintExampleEntity>[].obs;
  /// 滚动控制器
  final ScrollController scrollController = ScrollController();
  /// 总条数
  int total = 0;
  /// offset
  int offset = 0;
  /// limit
  int limit = 40;
  /// 是否加载中
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    if (Get.arguments != null) {
      isManagement = Get.arguments["isManagement"] ?? false;
      nid = Get.arguments["nid"];
      supportsPyramid = Get.arguments["supportsPyramid"]??false;
      getDetatils();
    }
    initBreadcrumb(tagText, title: supportsPyramid ? "生长金字塔详情" : "句型蓝图详情");
    listenScroll();
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange){
        if(!isLoading.value && exampleList.length < total){
          offset += limit;
          getExampleList();
        }
      }
    });
  }

  /// 查询详情
  Future<void> getDetatils() async {
    if (nid == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {};
      if(supportsPyramid){
        parameters["supportsPyramid"] = true;
      }
      PatternBlueprintEntity? res = await LanguageConsoleRequest.queryPatternBlueprint(nid!, parameters: parameters);
      if (res == null) return;
      patternBlueprint.value = res;
      await refreshExampleList();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 刷新列表
  Future<void> refreshExampleList() async{
    exampleList.clear();
    offset = 0;
    total = 0;
    await getExampleList();
  }

  Future<void> getExampleList() async{
    try {
      isLoading.value = true;
      Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };

      Map<String, dynamic> reqData = {
        "assetNid": nid,
        "supportsPyramid": supportsPyramid,
      };
      
      ListResponseEntity<PatternBlueprintExampleEntity>? list = await LanguageConsoleRequest.queryPatternBlueprintExample(
        parameters: params, 
        data: reqData,
      );
      if(list == null) return;
      total = list.count??0;
      exampleList.addAll(list.datas??[]);
    }finally{
      isLoading.value = false;
    }
  }

  /// 根据uid查询代表句
  Future<void> getExampleForUid(PatternBlueprintExampleEntity data) async{
    if(data.uid == null) return;
    try {
      Map<String, dynamic> reqData = {
        "assetNid": nid,
        "supportsPyramid": supportsPyramid,
        "uids": [data.uid],
      };
      ListResponseEntity<PatternBlueprintExampleEntity>? list = await LanguageConsoleRequest.queryPatternBlueprintExample(
        data: reqData,
      );
      if(list == null) return;
      List<PatternBlueprintExampleEntity> datas = list.datas??[];
      for (var element in exampleList) {
        for (var item in datas) {
          if(item.uid == element.uid){
            element = item;
          }
        }
      }
      exampleList.refresh();
    } catch (_) {}
  }

  /// 槽位详情
  Future<void> slotDetails(BuildContext context, SentenceSlotMapItemEntity item) async {
    await PatternSlotDetailsDialog.show(context: context, item: item, isManagement: isManagement);
  }

  /// 槽位例句说明
  Future<void> slotSentenceExample(
    BuildContext context,
    PatternBlueprintSentenceBriefSegmentEntity segment,
    PatternBlueprintSentenceBriefEntity? item,
  ) async {
    await SlotSentenceExampleDialog.show(
      context: context,
      segment: segment,
      nid: nid??"",
      sentenceId: item?.sentenceId,
      isManagement: isManagement,
    );
  }

  /// 编辑名称说明
  Future<void> editNameDesc(BuildContext context) async {
    if(nid == null) return;

    EditNameDescDialogResult? res = await EditNameDescDialog.show(
      context: context,
      name: patternBlueprint.value.name,
      description: patternBlueprint.value.description,
    );
    if(res == null) return;
    try {
      ToastUtils.showLoading();
      List<Map<String, dynamic>> nameList = [];
      List<Map<String, dynamic>> descriptionList = [];
      res.name?.forEach((e) {
        nameList.add(e?.toJson()??{});
      });
      res.description?.forEach((e) {
        descriptionList.add(e?.toJson()??{});
      });

      Map<String, dynamic> reqData = {
        "name": nameList,
        "description": descriptionList,
      };

      PatternBlueprintEntity? resp = await LanguageConsoleRequest.editPatternBlueprint(
        nid: nid!,
        data: reqData,
      );
      if(resp == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      patternBlueprint.value = resp;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 编辑代表句
  Future<void> editRepresent(BuildContext context) async {
    if(nid == null) return;
    List<PatternBlueprintSentenceBriefEntity?> sentenceRealizationList = patternBlueprint.value.sentenceRealizationList??[];
    PatternBlueprintEntity? resp = await ZhenxiePatternEditRepresentDialog.show(
      context: context,
      nid: nid!,
      sentenceRealizationList: sentenceRealizationList,
    );
    if(resp == null) return;
    patternBlueprint.value = resp;
  }

  /// 蓝图例句句子组上下架
  Future<void> exampleSentenceGroupShelf(PatternBlueprintExampleEntity example) async {
    if(example.uid == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": example.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
      };
      bool resp = await LanguageConsoleRequest.zhenxieExampleAccess(
        uid: example.uid!,
        data: reqData,
      );
      if(!resp) return;
      ToastUtils.showToast(text: "${example.isNormal ? "下架" : "上架"}成功", type: ToastType.success);
      example.access = example.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value;
      exampleList.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 删除代表句组
  Future<void> exampleSentenceGroupDelete(BuildContext context, int index, PatternBlueprintExampleEntity example) async {
    if(example.uid == null) return;
    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确认删除 代表句${index + 1} 吗？",
      defineColor: AppTheme.cSurfaceError.color,
    );
    if(!ask) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": AccessEnum.DELETED.value,
      };
      bool resp = await LanguageConsoleRequest.zhenxieExampleAccess(
        uid: example.uid!,
        data: reqData,
      );
      if(!resp) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      exampleList.removeWhere((element) => element.uid == example.uid);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 蓝图例句句子上下架
  Future<void> exampleSentenceShelf(PatternBlueprintSentenceBriefEntity? sentence) async{
    if(sentence == null) return;
    if(sentence.sentenceId == null) return;
    try {
      ToastUtils.showLoading();
      final response = await SentenceUtil.editSentence(
        uid: sentence.sentenceId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            "access": sentence.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
            "hasVideo": true,
          },
        ),
      );
      if(response.data == null) {
        ToastUtils.showToast(text: response.message ?? "${sentence.isNormal ? "下架" : "上架"}失败");
        return;
      }
      ToastUtils.showToast(text: "${sentence.isNormal ? "下架" : "上架"}成功", type: ToastType.success);
      sentence.access = sentence.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value;
      exampleList.refresh();
      
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
    } catch (_) {
      ToastUtils.showToast(text: "${sentence.isNormal ? "下架" : "上架"}失败");
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 拓展学习
  Future<void> expandLearning(PatternBlueprintSentenceBriefEntity? item) async {
    ElementsPageUtils.jumpElementsPage(
      contentId: item?.sentenceId, 
      contentType: KnowledgeTypeEnum.EN_SENTENCE.value, 
      semanticId: null, 
      content: item?.content,
      styleId: null, 
      dialect: null,
    );
  }
}
