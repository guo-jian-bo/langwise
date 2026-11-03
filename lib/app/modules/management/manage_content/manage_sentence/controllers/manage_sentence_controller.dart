
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../controllers/manage_setting_controller.dart';
import '../../../dialog/dialogs.dart';
import '../../../enums/enums.dart';
import '../../../models/models.dart';
import '../../../utils/utils.dart';

class ManageSentenceController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageSentenceController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SENTENCE;

  @override
  String get breadcrumbTitle => '句子';

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
      title: "名字",
      hintText: "名字",
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

      ListResponseEntity<EnKnowledgeEntity>? response = await LanguageConsoleRequest.getEnSentenceKnowledgeList(
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
      bool res = await LanguageConsoleRequest.deleteSentence(entity.data.uid!);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      getKnowledgeList();
    } finally{
      ToastUtils.hideLoading();
    }

  }

  Future<void> onSemanticVideo(EnKnowledgeEntity knowledge) async{
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

  Future<void> onSemanticImage(EnKnowledgeEntity knowledge) async{
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
  
  Future<void> onSemanticExercises(EnKnowledgeEntity knowledge) async{
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

  Future<void> showCreateSentence(BuildContext context) async{
    ManageAddSentenceDialog.show(context: context);
  }

  Future<void> editKnowledge(BuildContext context, ManageExpandModel<EnKnowledgeEntity> entity) async{
    EnKnowledgeEntity? res = await ManageEditSentenceManager.show(context: context, entity: entity.data);
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

  Future<void> onSemanticQuote(EnKnowledgeEntity knowledge) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_ENGLISH_COURSE_USAGE,
      arguments: {
        "type": knowledge.contentType,
        'uid': knowledge.uid,
      },
    );

    getKnowledgeList();
  }

  Future<void> jumpToCreateHistory(BuildContext context) async{

    String? contentType;
    if(knowledgeList.isNotEmpty){
      contentType = knowledgeList.first.data.contentType??"";
    }
    contentType ??= ElementsCardType.sentence.value;


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


  void toUsagePage(int uid, EnEntitySemantics item, String? contentType) {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_ENGLISH_COURSE_USAGE,
      arguments: {
        "type": contentType,
        'uid': uid,
        'semanticId': item.uid,
      },
    );
  }
}
