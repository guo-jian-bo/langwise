import 'package:api/api.dart';
import 'package:get/get.dart';
import 'package:quiz_play/models/quiz_model.dart';

import '../../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../../common/https/https.dart';
import '../../../../../../../../../utils/utils.dart';
import '../../../../../../../routes/routes.dart';
import '../../../../../common/manage_ai_queue_controller.dart';
import '../../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../../utils/manage_page_registry.dart';

class ManageQuizLabelPictureImagesController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageQuizLabelPictureImagesController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_QUIZ_LABEL_PICTURE_IMAGES;

  @override
  String get breadcrumbTitle => '标注图片-选择图片';

  int? unitId;
  int? aiRecordId;
  String? language;
  int? lessonId;

  List<ManageUnitKnowledgeEntity>? unitKnowledgeList;
  int? difficultyMin;
  int? difficultyMax;
  String? aiCode;
  int? lessonTemplateId;
  int? configId;

  QuizModel? quizModel;

  final RxList<ManageLabelPictureEntityImageStyleInfoList> imagesData = <ManageLabelPictureEntityImageStyleInfoList>[].obs;
  final RxMap<int, ManageLabelPictureEntityImageStyleInfoListImageInfoList> selectImageMap = <int, ManageLabelPictureEntityImageStyleInfoListImageInfoList>{}.obs;
  final RxInt resultState = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if (Get.arguments != null) {
      unitId = Get.arguments['unitId'] ?? 0;
      lessonId = Get.arguments['lessonId'] ?? 0;
      language = Get.arguments['language'];
      if (Get.arguments['aiRecordId'] != null) {
        if (Get.arguments['aiRecordId'] is int) {
          aiRecordId = Get.arguments['aiRecordId'];
        } else {
          aiRecordId = int.tryParse(Get.arguments['aiRecordId']);
        }
      }

      initData();
    }
  }

  Future<void> initData() async {
    try {
      ToastUtils.showLoading();
      getUnitInfo();
      await getAiBackQuizData();
      await getImagesDatas();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> getUnitInfo() async {
    if (unitId == null) return;
    Map<String, dynamic> reqData = {
      "uid": [unitId],
    };
    try {
      ResponseEntity<ListResponseEntity<NewUnitResponseEntity<MiniLessonResponseEntity>>> unitEntity = await UnitUtil.fetchPages(
        config: RequestConfig(
          data: reqData,
          requireToken: true,
        ),
      );
      if (unitEntity.data == null) return;
      List<NewUnitResponseEntity<MiniLessonResponseEntity>>? unitList = unitEntity.data!.datas;
      if (unitList == null) return;
      if (unitList.isEmpty) return;
      difficultyMin = unitList.first.difficulty?.min;
      difficultyMax = unitList.first.difficulty?.max;
      language = unitList.first.language;

      ResponseEntity<ListResponseEntity<LessonResponseEntity<dynamic>>> lessonEntity = await LessonUtil.fetchPages(
          config: RequestConfig(
        data: {
          "uid": [lessonId],
        },
        requireToken: true,
      ));
      if (lessonEntity.data == null) return;
      List<LessonResponseEntity<dynamic>>? lessonList = lessonEntity.data!.datas;
      if (lessonList == null) return;
      if (lessonList.isEmpty) return;
      lessonTemplateId = lessonList.first.lessonTemplateId;
    } catch (e) {
      return;
    }
  }

  Future<void> getAiBackQuizData() async {
    if (aiRecordId == null) {
      return;
    }
    AiBackPreviewInfoEntity? resData = await ManageSelectQuziKnowledge.getAiBackQuizData(aiRecordId!);
    if (resData == null) {
      return;
    }
    if (resData.list == null) {
      return;
    }

    aiCode = resData.suggestCode;
    configId = resData.exerciseTemplate?.uid;
    if (resData.list?.isNotEmpty ?? false) {
      quizModel = resData.list?.first;
    }

    if (resData.knowledgeList != null) {
      List<ManageUnitKnowledgeEntity?> resKnowledgeList = resData.knowledgeList ?? [];
      List<ManageUnitKnowledgeEntity> respKnowledgeList = [];
      for (int i = 0; i < resKnowledgeList.length; i++) {
        if (resKnowledgeList[i] == null) continue;
        respKnowledgeList.add(resKnowledgeList[i]!);
      }
      unitKnowledgeList = respKnowledgeList;
    }
  }

  Future<void> getImagesDatas() async {
    Map<String, dynamic> reqParam = {
      "aiRecordId": aiRecordId,
    };
    ManageLabelPictureEntity? labelPictureEntity = await ManageSelectQuziKnowledge.getLabelPictureDatas(reqParam);
    if (labelPictureEntity == null) {
      resultState.value = 1;
      return;
    }
    List<ManageLabelPictureEntityImageStyleInfoList?> imageStyleInfoList = labelPictureEntity.imageStyleInfoList ?? [];
    imagesData.clear();
    for (int i = 0; i < imageStyleInfoList.length; i++) {
      if (imageStyleInfoList[i] == null) continue;
      imagesData.add(imageStyleInfoList[i]!);
    }

    if (imagesData.isEmpty) {
      resultState.value = 1;
    } else {
      resultState.value = 0;
    }
  }

  void selectImage(int? styleId, ManageLabelPictureEntityImageStyleInfoListImageInfoList? data) {
    if (styleId == null) return;
    if (data == null) return;
    selectImageMap[styleId] = data;
  }

  Future<void> giveUp() async {
    if (aiRecordId == null) return;
    try {
      ToastUtils.showLoading();
      bool res = await AiQueueRequest.giveUp(aiRecordId!);
      if (!res) return;
      await Get.find<ManageAiQueueController>().getQueueList(lessonId);
      ToastUtils.showManageToast(text: "提交成功");
      Get.back();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> reGenerate() async {
    if (aiRecordId == null) return;
    try {
      ToastUtils.showLoading();
      bool res = await AiQueueRequest.reGenerate(aiRecordId!);
      if (!res) return;
      await Get.find<ManageAiQueueController>().getQueueList(lessonId);
      ToastUtils.showManageToast(text: "提交成功");
      Get.back();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> regenerateImage(ManageLabelPictureEntityImageStyleInfoList data) async {
    if (aiRecordId == null) return;
    Map<String, dynamic> reqParam = {
      "styleId": data.styleId,
    };
    try {
      ToastUtils.showLoading();
      bool res = await ManageSelectQuziKnowledge.regenerateLabelPicture(aiRecordId!, reqParam);
      if (!res) return;
      await Get.find<ManageAiQueueController>().getQueueList(lessonId);
      ToastUtils.showManageToast(text: "提交成功");
      Get.back();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void nextButton() {
    if (selectImageMap.isEmpty) {
      ToastUtils.showManageToast(text: "请先选择图片");
      return;
    }

    if (selectImageMap.length != imagesData.length) {
      ToastUtils.showManageToast(text: "每个风格必须选择一张图片");
      return;
    }

    List<Map<String, dynamic>> imageArgs = [];
    for (int i = 0; i < selectImageMap.length; i++) {
      imageArgs.add({
        "styleId": selectImageMap.keys.elementAt(i),
        "imageInfo": selectImageMap.values.elementAt(i),
      });
    }

    List<Map<String, dynamic>> argumentsKnowledgeList = [];
    for (int i = 0; i < unitKnowledgeList!.length; i++) {
      argumentsKnowledgeList.add(unitKnowledgeList![i].toJson());
    }
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_QUIZ_LABEL_PICTURE_SETTING,
      arguments: {
        "imageArgs": imageArgs,
        "quizModel": quizModel,
        "aiRecordId": aiRecordId,
        "knowledgeList": argumentsKnowledgeList,
        "unitId": unitId,
        "difficultyMin": difficultyMin,
        "difficultyMax": difficultyMax,
        "language": language,
        "aiCode": aiCode,
        "lessonId": lessonId,
        "configId": configId,
      },
    );
  }
}
