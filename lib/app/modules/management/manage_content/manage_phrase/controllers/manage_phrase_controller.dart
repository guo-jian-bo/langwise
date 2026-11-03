

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../controllers/manage_setting_controller.dart';
import '../../../dialog/dialogs.dart';
import '../../../enums/enums.dart';
import '../../../models/models.dart';
import '../../../utils/utils.dart';

class ManagePhraseController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManagePhraseController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_PHRASE;

  @override
  String get breadcrumbTitle => '短语';

  /// 语言code
  final String languageCode = "en";

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{
    "in_course_cnt": FilterSortsData(
      title: "课程归属",
      sorts: [
        FilterSortsItem(name: "课程数量升序", direction: FilterSortDirection.up),
        FilterSortsItem(name: "课程数量降序", direction: FilterSortDirection.down, selected: true, isDefault: true),
      ],
    ),
    "wordFreq": FilterSortsData(
      title: "词频",
      sorts: [
        FilterSortsItem(name: "词频升序", direction: FilterSortDirection.up),
        FilterSortsItem(name: "词频降序", direction: FilterSortDirection.down),
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

  final RxMap<String, FilterConditionsData> filterConditions = {
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
    "keyword": FilterSearchsData(
      title: "关键字",
      hintText: "关键字",
      controller: TextEditingController(),
    ),
    "uid": FilterSearchsData(
      title: "uid",
      hintText: "uid",
      controller: TextEditingController(),
      isCommaSeparated: true,
    ),
    "content": FilterSearchsData(
      title: "短语",
      hintText: "短语",
      controller: TextEditingController(),
    ),
  };

  /// 一键展开/折叠
  final RxBool isAllExpand = false.obs;

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
    getKnowledgeList();
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

      ListResponseEntity<EnKnowledgeEntity>? response = await LanguageConsoleRequest.getEnPhraseKnowledgeList(
        parameters: parameters,
        data: data,
      );
      if(response == null) return;
      totalCount.value = response.count??0;

      List<EnKnowledgeEntity>? datas = response.datas;
      if(datas == null) return;

      List<int> openUids = knowledgeList.where((e) => e.isExpanded).map((e) => e.data.uid!).toList();

      knowledgeList.clear();
      for(var e in datas){
        var model = ManageExpandModel<EnKnowledgeEntity>(data: e);
        if(openUids.contains(e.uid) || isAllExpand.value){
          model.isExpanded = true;
        }
        knowledgeList.add(model);
      }

    } finally{
      ToastUtils.hideLoading();
    }

  }


  /// 展开收起语义
  void toggleSemantic(ManageExpandModel<EnKnowledgeEntity> entity) {
    entity.isExpanded = !entity.isExpanded;
    knowledgeList.refresh();
  }

  /// 一键展开/折叠
  void onAllExpand(){
    isAllExpand.value = !isAllExpand.value;
    for (var element in knowledgeList) {
      element.isExpanded = isAllExpand.value;
    }
    knowledgeList.refresh();
  }


  /// 创建短语
  Future<void> showCreatePhrase(BuildContext context) async{
    bool res = await ManageAddPhraseDialog.show(context: context);
    if(!res) return;
  }


  /// 单词添加记录
  Future<void> jumpToCreateHistory(BuildContext context) async{

    String? contentType;
    if(knowledgeList.isNotEmpty){
      contentType = knowledgeList.first.data.contentType??"";
    }
    contentType ??= ElementsCardType.phrase.value;


    dynamic uid = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_CREATE_HISTORY,
      arguments: {
        "contentType": contentType,
      },
    );
    if(uid == null) return;

    filterSearchs['uid']?.controller.text = uid.toString();
    pagerController.jumpToPage(1);

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
      bool res = await LanguageConsoleRequest.deletePhrase(entity.data.uid!);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      getKnowledgeList();
    } finally{
      ToastUtils.hideLoading();
    }

  }

  /// 编辑知识点
  Future<void> editKnowledge(BuildContext context, ManageExpandModel<EnKnowledgeEntity> entity) async{
    EnKnowledgeEntity? res = await ManageEditPhraseDialog.show(context: context, knowledge: entity.data);
    if(res == null) return;
    entity.data = res;
    knowledgeList.refresh();
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

  /// 删除短语语义
  Future<void> deleteSemantic(BuildContext context, ManageExpandModel<EnKnowledgeEntity> entity, EnKnowledgeEntitySemantics semantic) async{
    if(semantic.uid == null) return;
    
    ManageDelSemanticEnum? deleteType = await ManageDelSemanticDialog.show(
      context: context, 
      sid: semantic.uid!,
      content: entity.data.content??"",
    );
    if(deleteType == null) return;
    if(deleteType == ManageDelSemanticEnum.database){
      try {
        ToastUtils.showLoading();
        bool res = await LanguageConsoleRequest.deletePhraseSemantic(semantic.uid!);
        if(!res) return;
        ToastUtils.showToast(text: "删除成功", type: ToastType.success);
        getKnowledgeList();
      } finally{
        ToastUtils.hideLoading();
      }
      return;
    }

    if(entity.data.uid == null) return;
    
    List<int?> semanticIds = entity.data.semanticIds??[];
    semanticIds.remove(semantic.uid!);
    
    Map<String, dynamic> reqData = {
      "semanticIds": semanticIds,
    };

    try {
      ToastUtils.showLoading();
      EnKnowledgeEntity? res = await LanguageConsoleRequest.editPhrase(entity.data.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      getKnowledgeList();
    } finally{
      ToastUtils.hideLoading();
    }

    
  }

  /// 编辑语义
  Future<void> editSemantic(BuildContext context, EnKnowledgeEntitySemantics semantic) async {
    if(semantic.uid == null) return;
    bool res = await ManageEditGlossDescDialog.showEdit(
      context: context,
      gloss: semantic.gloss,
      descriptions: semantic.descriptions,
      semanticId: semantic.uid!,
      eduTier: semantic.eduTierEnum,
    );
    if(!res) return;
    getKnowledgeList();
  }

  Future<void> onSemanticVideo(EnKnowledgeEntity knowledge, EnKnowledgeEntitySemantics semantic) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: {
        'type': knowledge.contentType,
        'uid': knowledge.uid,
        'semanticId': semantic.uid,
        "quizOrImage": 2,
      },
    );

    getKnowledgeList();
  }

  Future<void> onSemanticImage(EnKnowledgeEntity knowledge, EnKnowledgeEntitySemantics semantic) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: {
        'type': knowledge.contentType,
        'uid': knowledge.uid,
        'semanticId': semantic.uid,
        "quizOrImage": 1,
      },
    );

    getKnowledgeList();
  }
  
  Future<void> onSemanticExercises(EnKnowledgeEntity knowledge, EnKnowledgeEntitySemantics semantic) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: {
        'type': knowledge.contentType,
        'uid': knowledge.uid,
        'semanticId': semantic.uid,
        "quizOrImage": 0,
      },
    );

    getKnowledgeList();
  }

  Future<void> onSemanticQuote(EnKnowledgeEntity knowledge, EnKnowledgeEntitySemantics semantic) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_ENGLISH_COURSE_USAGE,
      arguments: {
        "type": knowledge.contentType,
        'uid': knowledge.uid,
        "semanticId": semantic.uid,
      },
    );

    getKnowledgeList();
  }

  /// 添加语义
  Future<void> addSemantic(BuildContext context, ManageExpandModel<EnKnowledgeEntity> entity) async{

    List<EnKnowledgeEntitySemantics>? selects = await ManageSelectSemanticDialog.show(
      context: context,
      initSemantics: entity.data.semantics??[],
      languageCode: entity.data.language,
    );
    if(selects == null) return;

    try {
      ToastUtils.showLoading();

      List<int> semanticIds = selects.map((e) => e.uid!).toList();

      Map<String, dynamic> reqData = {
        "semanticIds": semanticIds,
      };

      EnKnowledgeEntity? res = await LanguageConsoleRequest.editPhrase(entity.data.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "添加成功", type: ToastType.success);
      entity.data = res;
      knowledgeList.refresh();

    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 关联语义
  Future<void> onCorrelationSemantic(BuildContext context, ManageExpandModel<EnKnowledgeEntity> entity) async{
    if(entity.data.uid == null || entity.data.contentType == null) return;
    
    bool res = await ManageCorrelationSemanticDialog.show(
      context: context, 
      contentId: entity.data.uid!, 
      contentType: entity.data.contentType!,
    );
    if(!res) return;

    getKnowledgeList();

  }



  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
