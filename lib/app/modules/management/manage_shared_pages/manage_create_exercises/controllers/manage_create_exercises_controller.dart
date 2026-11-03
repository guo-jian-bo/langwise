import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../routes/routes.dart';
import 'package:langwise/app/modules/management/models/manage_knowledge_table_model.dart';
import 'package:langwise/app/modules/management/utils/konwledge_utils.dart';
import '../../../common/manage_select_knowledge_table/view.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';
import '../views/manage_create_exercises_filter_dialog.dart';

class ManageCreateExercisesController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageCreateExercisesController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_CREATE_EXERCISES;

  @override
  String get breadcrumbTitle => '创建练习';

  String? contentType;
  int? contentId;
  int? semanticId;
  String? pageType;
  String? exerciseType;
  String? exerciseTypeName;

  final Rx<ManageCreateExercisesFilterResult> filterData = ManageCreateExercisesFilterResult().obs;

  final RxList<ManageLessonQuizTemplateEntity> exerciseTemplates = <ManageLessonQuizTemplateEntity>[].obs;

  final Rx<ManageLessonQuizTemplateEntity?> selectedExerciseTemplate = Rx(null);

  final RxList<ManageKnowledgeTableModel> selectedKnowledge = <ManageKnowledgeTableModel>[].obs;

  final Rx<ElementsCardType> defaultKnowledgeType = ElementsCardType.word.obs;

  final RxInt knowledgeMaxSelect = 4.obs;

  final RxInt knowledgeMinSelect = 1.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if (Get.arguments != null) {
      contentType = Get.arguments['contentType'];
      contentId = Get.arguments['contentId'];
      semanticId = Get.arguments['semanticId'];
      exerciseType = Get.arguments['exerciseType'];
      exerciseTypeName = Get.arguments['exerciseTypeName'];
      pageType = Get.arguments['pageType'];
      if (pageType == "superMemory") {
        filterData.value.lessonTemplateTypes = [
          ManageCreateExercisesFilterModel(
            value: LessonTypeEnum.supermemo.value,
            name: LessonTypeEnum.supermemo.name,
          ),
        ];
      } else if (pageType == "course") {
        filterData.value.lessonTemplateTypes = [
          ManageCreateExercisesFilterModel(
            value: LessonTypeEnum.course.value,
            name: LessonTypeEnum.course.name,
          ),
        ];
      }

      if (exerciseType != null && exerciseTypeName != null) {
        filterData.value.quizTypes = [
          ManageCreateExercisesFilterModel(
            value: exerciseType!,
            name: exerciseTypeName!,
          ),
        ];
      }
    }

    getDefaultKnowledge();
    getQuizTemplates();
  }

  Future<void> getQuizTemplates() async {
    if (contentType == null) return;

    try {
      ToastUtils.showLoading();
      exerciseTemplates.clear();
      selectedExerciseTemplate.value = null;

      Map<String, dynamic> reqData = {
        "contentType": contentType,
        "subContent": {
          "uid": contentId,
          "type": contentType,
          "semanticId": semanticId,
        },
      };

      List lessonTemplateTypes = filterData.value.lessonTemplateTypes?.map((e) => e.value).toList() ?? [];
      if (lessonTemplateTypes.isNotEmpty) {
        reqData['lessonTemplateTypes'] = lessonTemplateTypes;
      }

      List lessonTemplates = filterData.value.lessonTemplates?.map((e) => e.value).toList() ?? [];
      if (lessonTemplates.isNotEmpty) {
        reqData['lessonTemplates'] = lessonTemplates;
      }

      List quizTypes = filterData.value.quizTypes?.map((e) => e.value).toList() ?? [];
      if (quizTypes.isNotEmpty) {
        reqData['exerciseTypes'] = quizTypes;
      }

      final res = await ExercisesRequest.getQuizTemplates({}, reqData);
      if (res == null) return;
      exerciseTemplates.assignAll(res);

      if (exerciseTemplates.isNotEmpty) {
        selectExerciseTemplate(exerciseTemplates.first);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> getDefaultKnowledge() async {
    if (contentType == null) return;

    try {
      final res = await KonwledgeUtils.getKnowledgeDataByContentId(
        contentId: contentId,
        contentType: contentType,
        semanticId: semanticId,
      );
      if (res == null) return;
      res.enableSelect = false;

      selectedKnowledge.add(res);

      defaultKnowledgeType.value = res.type;
    } finally {}
  }

  void removeFilterLessonTemplateTypes(ManageCreateExercisesFilterModel model) {
    filterData.value.lessonTemplateTypes?.removeWhere((e) => e.value == model.value);
    filterData.refresh();
    getQuizTemplates();
  }

  void removeFilterLessonTemplatelds(ManageCreateExercisesFilterModel model) {
    filterData.value.lessonTemplates?.removeWhere((e) => e.value == model.value);
    filterData.refresh();
    getQuizTemplates();
  }

  void removeFilterQuizTypes(ManageCreateExercisesFilterModel model) {
    filterData.value.quizTypes?.removeWhere((e) => e.value == model.value);
    filterData.refresh();
    getQuizTemplates();
  }

  Future<void> selectFilter(BuildContext context, {bool isInit = false}) async {
    List<LessonTypeEnum>? forceLessonTemplateTypes;
    if (pageType == "superMemory") {
      forceLessonTemplateTypes = [LessonTypeEnum.supermemo];
    }

    ManageCreateExercisesFilterResult? res = await ManageCreateExercisesFilterDialog.show(
      context: context,
      initialData: filterData.value,
      contentType: contentType,
      contentId: contentId,
      semanticId: semanticId,
      forceLessonTemplateTypes: forceLessonTemplateTypes,
    );
    if (res == null) {
      if (isInit) {
        Get.back();
      }
      return;
    }
    filterData.value = res;
    getQuizTemplates();
  }

  void selectExerciseTemplate(ManageLessonQuizTemplateEntity template) {
    selectedExerciseTemplate.value = template;

    knowledgeMinSelect.value = template.template?.contentsLen?.min ?? 1;
    knowledgeMaxSelect.value = template.template?.contentsLen?.max ?? 16;

    bool isKnowledgeSingle = selectedExerciseTemplate.value?.template?.isKnowledgeSingle ?? false;
    if (isKnowledgeSingle) {
      for (int i = selectedKnowledge.length - 1; i > 0; i--) {
        if (selectedKnowledge.length == 1) break;
        selectedKnowledge.removeAt(i);
      }
    }
  }

  void updateSelectedKnowledge(List<ManageKnowledgeTableModel> models) {
    selectedKnowledge.value = models;
    selectedKnowledge.refresh();
  }

  void removeSelectedKnowledge(ManageKnowledgeTableModel model, int index) {
    if (index == 0) {
      ToastUtils.showManageToast(text: "默认知识点不允许删除");
      return;
    }

    selectedKnowledge.remove(model);
  }

  Future<void> onNext(BuildContext context) async {
    if (selectedExerciseTemplate.value == null) return ToastUtils.showManageToast(text: "请选择题目模版");
    if (selectedKnowledge.isEmpty) return ToastUtils.showManageToast(text: "请选择知识点");

    ManageLessonQuizTemplateEntity template = selectedExerciseTemplate.value!;

    bool knowledgeSingle = template.template?.isKnowledgeSingle ?? false;
    int knowledgeMinSelect = template.template?.contentsLen?.min ?? 4;

    List<ManageUnitKnowledgeEntity> knowledges = getSelect();

    if (!knowledgeSingle) {
      if (knowledges.length == 1) {
        ElementsCardType type = ElementsCardType.fromRawValue(knowledges.first.contentType ?? "");
        if (type == ElementsCardType.none) return;

        if (type != ElementsCardType.text && type != ElementsCardType.reveal && type != ElementsCardType.song && type != ElementsCardType.script) {
          if (knowledgeMinSelect > knowledges.length) {
            return ToastUtils.showManageToast(text: "请选择最少$knowledgeMinSelect个知识点");
          }
        }
      } else {
        if (knowledgeMinSelect > knowledges.length) {
          return ToastUtils.showManageToast(text: "请选择最少$knowledgeMinSelect个知识点");
        }
      }
    }

    List<Map<String, dynamic>> argumentsKnowledgeList = [];
    for (var item in knowledges) {
      argumentsKnowledgeList.add(item.toJson());
    }
    Map<String, dynamic> arguments = {
      "lessonQuizTemplate": template.toJson(),
      "knowledgeList": argumentsKnowledgeList,
      "language": "en",
      "contentType": contentType,
    };

    for (int i = selectedKnowledge.length - 1; i > 0; i--) {
      if (selectedKnowledge.length == 1) break;
      selectedKnowledge.removeAt(i);
    }

    ManagePageRegistry.jumpTo(
      Routes.MANAGE_CREATE_QUIZ,
      arguments: arguments,
    );
  }

  Future<void> showSelectKnowledgeDialog(BuildContext context) async {
    List<ManageUnitKnowledgeEntity> initKnowledges = getSelect();

    String? defaultContent;
    if(selectedKnowledge.isNotEmpty){
      if(selectedKnowledge.first.type == ElementsCardType.reveal){
        defaultContent = selectedKnowledge.first.reveal?.content;
      }else if(selectedKnowledge.first.type == ElementsCardType.text){
        defaultContent = selectedKnowledge.first.text?.content;
      }
    }
    

    List<BaseKnowledge>? values = await ManageSelectKnowledgeTableManager.show(
      context: context,
      defaultDessert: [],
      language: "en",
      hideText: true,
      selectMax: knowledgeMaxSelect.value - selectedKnowledge.length,
      defaultContent: defaultContent,
      dataDisableCallback: (BaseKnowledge targetEntity) {
        bool isDisable = initKnowledges.any((element) => element.contentId == targetEntity.uid);
        return isDisable;
      },
    );
    if (values == null) return;

    for (int i = 0; i < values.length; i++) {
      final entity = values[i];
      if (entity is EnWordEntity) {
        selectedKnowledge.add(ManageKnowledgeTableModel(
          type: ElementsCardType.word,
          selectSemantics: entity.selectedSemantics == null ? null : [entity.selectedSemantics!],
          word: entity,
          id: "${entity.uid}_word",
        ));
      } else if (entity is EnPhraseEntity) {
        selectedKnowledge.add(ManageKnowledgeTableModel(
          type: ElementsCardType.phrase,
          selectSemantics: entity.selectedSemantics == null ? null : [entity.selectedSemantics!],
          phrase: entity,
          id: "${entity.uid}_phrase",
        ));
      } else if (entity is EnSentenceEntity) {
        selectedKnowledge.add(ManageKnowledgeTableModel(
          type: ElementsCardType.sentence,
          selectSemantics: entity.selectedSemantics == null ? null : [entity.selectedSemantics!],
          sentence: entity,
          id: "${entity.uid}_sentence",
        ));
      } else if (entity is EnTextEntity) {
        selectedKnowledge.add(ManageKnowledgeTableModel(
          type: ElementsCardType.text,
          text: entity,
          id: "${entity.uid}_text",
        ));
      }
    }
  }

  List<ManageUnitKnowledgeEntity> getSelect() {
    List<ManageUnitKnowledgeEntity> knowledges = [];
    for (int i = 0; i < selectedKnowledge.length; i++) {
      ManageKnowledgeTableModel model = selectedKnowledge[i];
      if (model.type == ElementsCardType.word) {
        int? semanticId = model.selectSemantics?.isNotEmpty == true ? model.selectSemantics?.first.uid : null;
        knowledges.add(ManageUnitKnowledgeEntity(
          content: model.word?.content,
          contentId: model.word?.uid,
          contentType: model.word?.contentType,
          semanticId: semanticId,
          definition: model.word?.definition,
          imageUrl: model.word?.imageUrl,
          audioUrl: model.word?.audioUrl,
        ));
      } else if (model.type == ElementsCardType.phrase) {
        int? semanticId = model.selectSemantics?.isNotEmpty == true ? model.selectSemantics?.first.uid : null;
        knowledges.add(ManageUnitKnowledgeEntity(
          content: model.phrase?.content,
          contentId: model.phrase?.uid,
          contentType: model.phrase?.contentType,
          semanticId: semanticId,
          definition: model.phrase?.definition,
          imageUrl: model.phrase?.imageUrl,
          audioUrl: model.phrase?.audioUrl,
        ));
      } else if (model.type == ElementsCardType.sentence) {
        int? semanticId = model.selectSemantics?.isNotEmpty == true ? model.selectSemantics?.first.uid : null;
        knowledges.add(ManageUnitKnowledgeEntity(
          content: model.sentence?.content,
          contentId: model.sentence?.uid,
          contentType: model.sentence?.contentType,
          semanticId: semanticId,
          definition: model.sentence?.definition,
          imageUrl: model.sentence?.imageUrl,
          audioUrl: model.sentence?.audioUrl,
        ));
      } else if (model.type == ElementsCardType.text) {
        knowledges.add(ManageUnitKnowledgeEntity(
          content: model.text?.content,
          contentId: model.text?.uid,
          contentType: model.text?.contentType,
          definition: model.text?.definition,
          imageUrl: model.text?.imageUrl,
          audioUrl: model.text?.audioUrl,
        ));
      } else if (model.type == ElementsCardType.reveal) {
        knowledges.add(ManageUnitKnowledgeEntity(
          content: model.reveal?.content,
          contentId: model.reveal?.uid,
          contentType: model.reveal?.contentType,
          definition: model.reveal?.definition,
          imageUrl: model.reveal?.imageUrl,
          audioUrl: model.reveal?.audioUrl,
        ));
      } else if (model.type == ElementsCardType.script) {
        knowledges.add(ManageUnitKnowledgeEntity(
          content: model.script?.title?.firstWhereOrNull((element) => element?.lang == "zh")?.text,
          contentId: model.script?.uid,
          contentType: KnowledgeTypeEnum.SCRIPT.value,
        ));
      }
      
    }
    return knowledges;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

class ManagCereateExercisesTypeModel {
  final String type;
  final String name;

  ManagCereateExercisesTypeModel({required this.type, required this.name});
}
