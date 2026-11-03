import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_play/models/models.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../../common/https/https.dart';
import '../../../../../../../../../utils/utils.dart';
import '../../../../../../../routes/routes.dart';
import '../../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../../utils/manage_page_registry.dart';

class QuizLabelPictureSettingModel {
  ManageUnitKnowledgeEntity data;
  Rect rect;
  double xPercent;
  double yPercent;
  double widthPercent;
  double heightPercent;
  QuizLabelPictureSettingModel({
    required this.data,
    this.rect = Rect.zero,
    this.xPercent = 0,
    this.yPercent = 0,
    this.widthPercent = 0,
    this.heightPercent = 0,
  });
}

class QuizLabelPictureImageInfoModel {
  int styleId;
  ManageLabelPictureEntityImageStyleInfoListImageInfoList imageInfo;
  QuizModel quizData;
  List<QuizLabelPictureSettingModel> showKnowledgeList;
  bool complete;
  QuizLabelPictureImageInfoModel({
    required this.styleId,
    required this.imageInfo,
    required this.quizData,
    required this.showKnowledgeList,
    this.complete = false,
  });
}

class ManageQuizLabelPictureSettingController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageQuizLabelPictureSettingController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_QUIZ_LABEL_PICTURE_SETTING;

  @override
  String get breadcrumbTitle => '标注图片-设置';

  List<ManageUnitKnowledgeEntity>? unitKnowledgeList;
  int? unitId;
  int? difficultyMin;
  int? difficultyMax;
  String? language;
  int? lessonId;
  int? aiRecordId;
  String? aiCode;
  int? configId;
  QuizModel? quizModel;
  List<Map<String, dynamic>>? imageArgs;

  final RxInt selectKnowledgeIndex = 0.obs;
  final RxList<QuizLabelPictureImageInfoModel> imageInfoList = <QuizLabelPictureImageInfoModel>[].obs;
  final RxInt currentImageIndex = 0.obs;

  bool nextButtonFlag = false;
  final RxInt nextButtonTextType = 1.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if (Get.arguments != null) {
      Map argumentsMap = Get.arguments;

      quizModel = argumentsMap["quizModel"];
      List<Map<String, dynamic>>? argumentsKnowledgeList = argumentsMap["knowledgeList"];
      if (argumentsKnowledgeList != null) {
        unitKnowledgeList = argumentsKnowledgeList.map((e) => ManageUnitKnowledgeEntity.fromJson(e)).toList();
      }
      unitId = argumentsMap["unitId"];
      difficultyMin = argumentsMap["difficultyMin"];
      difficultyMax = argumentsMap["difficultyMax"];
      language = argumentsMap["language"];
      aiCode = argumentsMap["aiCode"];
      lessonId = argumentsMap["lessonId"];
      aiRecordId = argumentsMap["aiRecordId"];
      configId = argumentsMap["configId"];

      imageArgs = argumentsMap["imageArgs"];

      if (imageArgs != null && quizModel != null && unitKnowledgeList != null) {
        for (int i = 0; i < imageArgs!.length; i++) {
          int? styleId = imageArgs![i]['styleId'];
          ManageLabelPictureEntityImageStyleInfoListImageInfoList? imageInfo = imageArgs![i]['imageInfo'];
          if (styleId == null || imageInfo == null) continue;

          List<QuizLabelPictureSettingModel> showKnowledgeList = [];
          for (int j = 0; j < unitKnowledgeList!.length; j++) {
            ManageLabelPictureEntityImageStyleInfoListImageInfoListContentPositions? initBoxInfo = getInitBoxInfo(unitKnowledgeList![j], imageInfo);
            Rect rect = Rect.fromLTWH(
              (initBoxInfo?.relativeBox?[0] ?? 0) * 720.wMin,
              (initBoxInfo?.relativeBox?[1] ?? 0) * 720.wMin,
              (initBoxInfo?.relativeBox?[2] ?? 0) * 720.wMin,
              (initBoxInfo?.relativeBox?[3] ?? 0) * 720.wMin,
            );

            showKnowledgeList.add(QuizLabelPictureSettingModel(
              data: unitKnowledgeList![j],
              rect: rect,
              xPercent: initBoxInfo?.relativeBox?[0] ?? 0,
              yPercent: initBoxInfo?.relativeBox?[1] ?? 0,
              widthPercent: initBoxInfo?.relativeBox?[2] ?? 0,
              heightPercent: initBoxInfo?.relativeBox?[3] ?? 0,
            ));
          }

          List<QuizModelOptions> options = [];
          for (int j = 0; j < showKnowledgeList.length; j++) {
            options.add(QuizModelOptions(
              text: showKnowledgeList[j].data.content,
              audioUrl: showKnowledgeList[j].data.audioUrl,
              imageUrl: showKnowledgeList[j].data.imageUrl,
              position: styleId,
              boxs: [
                showKnowledgeList[j].xPercent,
                showKnowledgeList[j].yPercent,
                showKnowledgeList[j].widthPercent,
                showKnowledgeList[j].heightPercent,
              ],
            ));
          }

          QuizModel quizData = QuizModel.fromJson(quizModel!.toJson());
          quizData.options = options;
          quizData.stems = [
            QuizModelStems(
              imageUrl: imageInfo.imageUrl,
              styleId: styleId,
              imageId: imageInfo.imageId,
            ),
          ];

          imageInfoList.add(QuizLabelPictureImageInfoModel(
            styleId: styleId,
            imageInfo: imageInfo,
            quizData: quizData,
            complete: i == 0,
            showKnowledgeList: showKnowledgeList,
          ));
        }
      }
      getNextButtonText();
    }
  }

  ManageLabelPictureEntityImageStyleInfoListImageInfoListContentPositions? getInitBoxInfo(
      ManageUnitKnowledgeEntity data, ManageLabelPictureEntityImageStyleInfoListImageInfoList? imageInfo) {
    if (imageInfo == null) return null;
    List<ManageLabelPictureEntityImageStyleInfoListImageInfoListContentPositions?>? contentPositions = imageInfo.contentPositions;
    if (contentPositions == null) return null;
    for (int i = 0; i < contentPositions.length; i++) {
      if (contentPositions[i] == null) continue;
      if (contentPositions[i]!.contentId == data.contentId && contentPositions[i]!.semanticId == data.semanticId && contentPositions[i]!.contentType == data.contentType) {
        return contentPositions[i]!;
      }
    }
    return null;
  }

  void drawBox(Rect rect, double size) {
    imageInfoList[currentImageIndex.value].showKnowledgeList[selectKnowledgeIndex.value].rect = rect;

    double xPercent = (rect.left / size);
    double yPercent = (rect.top / size);
    double widthPercent = (rect.width / size);
    double heightPercent = (rect.height / size);

    imageInfoList[currentImageIndex.value].showKnowledgeList[selectKnowledgeIndex.value].xPercent = xPercent;
    imageInfoList[currentImageIndex.value].showKnowledgeList[selectKnowledgeIndex.value].yPercent = yPercent;
    imageInfoList[currentImageIndex.value].showKnowledgeList[selectKnowledgeIndex.value].widthPercent = widthPercent;
    imageInfoList[currentImageIndex.value].showKnowledgeList[selectKnowledgeIndex.value].heightPercent = heightPercent;

    imageInfoList[currentImageIndex.value].quizData.options?[selectKnowledgeIndex.value]?.boxs = [
      xPercent,
      yPercent,
      widthPercent,
      heightPercent,
    ];

    if (currentImageIndex.value == imageInfoList.length - 1) {
      imageInfoList[currentImageIndex.value].complete = true;
    }
    imageInfoList.refresh();

    getNextButtonText();
  }

  void clearAnnotation() {
    for (int i = 0; i < imageInfoList.length; i++) {
      imageInfoList[i].complete = false;
      if (imageInfoList[i].quizData.options == null) continue;
      for (int j = 0; j < imageInfoList[i].quizData.options!.length; j++) {
        imageInfoList[i].quizData.options?[j]?.boxs = [];
      }
      for (int j = 0; j < imageInfoList[i].showKnowledgeList.length; j++) {
        imageInfoList[i].showKnowledgeList[j].rect = Rect.zero;
        imageInfoList[i].showKnowledgeList[j].xPercent = 0;
        imageInfoList[i].showKnowledgeList[j].yPercent = 0;
        imageInfoList[i].showKnowledgeList[j].widthPercent = 0;
        imageInfoList[i].showKnowledgeList[j].heightPercent = 0;
      }
    }
    imageInfoList.refresh();

    getNextButtonText();
  }

  Future<void> reAnnotation() async {
    int? imageId = imageInfoList[currentImageIndex.value].imageInfo.imageId;
    if (imageId == null) {
      ToastUtils.showManageToast(text: "imageId异常");
      return;
    }
    ToastUtils.showLoading();
    ManageLabelPictureEntity? result = await ManageSelectQuziKnowledge.regenerateLabelPicturTip(imageId);
    ToastUtils.hideLoading();
    if (result == null) return;
    if (result.imageStyleInfoList?.isEmpty ?? true) {
      ToastUtils.showManageToast(text: "重新标注失败");
      return;
    }

    ManageLabelPictureEntityImageStyleInfoList? imageStyleInfoList = result.imageStyleInfoList!.first;
    if (imageStyleInfoList == null) {
      ToastUtils.showManageToast(text: "重新标注失败");
      return;
    }

    for (int i = 0; i < imageInfoList[currentImageIndex.value].showKnowledgeList.length; i++) {
      List<ManageLabelPictureEntityImageStyleInfoListImageInfoList?>? imageList = imageStyleInfoList.imageInfoList;
      if (imageList == null) continue;

      ManageLabelPictureEntityImageStyleInfoListImageInfoList? imageInfo;

      for (int j = 0; j < imageList.length; j++) {
        if (imageList[j] == null) continue;
        if (imageList[j]!.imageId == imageInfoList[currentImageIndex.value].imageInfo.imageId) {
          imageInfo = imageList[j];
          break;
        }
      }
      if (imageInfo == null) continue;

      ManageLabelPictureEntityImageStyleInfoListImageInfoListContentPositions? initBoxInfo =
          getInitBoxInfo(imageInfoList[currentImageIndex.value].showKnowledgeList[i].data, imageInfo);
      if (initBoxInfo == null) continue;
      Rect rect = Rect.fromLTWH(
        (initBoxInfo.relativeBox?[0] ?? 0) * 720.wMin,
        (initBoxInfo.relativeBox?[1] ?? 0) * 720.wMin,
        (initBoxInfo.relativeBox?[2] ?? 0) * 720.wMin,
        (initBoxInfo.relativeBox?[3] ?? 0) * 720.wMin,
      );
      imageInfoList[currentImageIndex.value].showKnowledgeList[i].rect = rect;
      imageInfoList[currentImageIndex.value].showKnowledgeList[i].xPercent = initBoxInfo.relativeBox?[0] ?? 0;
      imageInfoList[currentImageIndex.value].showKnowledgeList[i].yPercent = initBoxInfo.relativeBox?[1] ?? 0;
      imageInfoList[currentImageIndex.value].showKnowledgeList[i].widthPercent = initBoxInfo.relativeBox?[2] ?? 0;
      imageInfoList[currentImageIndex.value].showKnowledgeList[i].heightPercent = initBoxInfo.relativeBox?[3] ?? 0;

      imageInfoList[currentImageIndex.value].quizData.options?[i]?.boxs = [
        initBoxInfo.relativeBox?[0] ?? 0,
        initBoxInfo.relativeBox?[1] ?? 0,
        initBoxInfo.relativeBox?[2] ?? 0,
        initBoxInfo.relativeBox?[3] ?? 0,
      ];
    }

    selectKnowledgeIndex.value = 0;
    imageInfoList.refresh();

    getNextButtonText();
  }

  void getNextButtonText() {
    for (int i = 0; i < imageInfoList[currentImageIndex.value].showKnowledgeList.length; i++) {
      if (imageInfoList[currentImageIndex.value].showKnowledgeList[i].rect == Rect.zero) {
        nextButtonTextType.value = 1;
        return;
      }
    }

    for (int i = 0; i < imageInfoList.length; i++) {
      if (!imageInfoList[i].complete) {
        nextButtonTextType.value = 2;
        return;
      }
    }

    nextButtonTextType.value = 0;
  }

  void changeSelectIndex(int index) {
    selectKnowledgeIndex.value = index;
  }

  Future<void> nextButton() async {
    if (quizModel == null) {
      ToastUtils.showManageToast(text: "模版信息异常");
      return;
    }

    if (imageInfoList.isEmpty) {
      ToastUtils.showManageToast(text: "图片信息异常");
      return;
    }

    for (int i = 0; i < imageInfoList[currentImageIndex.value].showKnowledgeList.length; i++) {
      if (imageInfoList[currentImageIndex.value].showKnowledgeList[i].rect == Rect.zero) {
        selectKnowledgeIndex.value = i;
        ToastUtils.showManageToast(text: "请画 ${imageInfoList[currentImageIndex.value].showKnowledgeList[i].data.content ?? ''} 的框");
        getNextButtonText();
        return;
      }
    }

    if (nextButtonFlag) return;
    nextButtonFlag = true;

    imageInfoList[currentImageIndex.value].complete = true;

    for (int i = 0; i < imageInfoList.length; i++) {
      if (!imageInfoList[i].complete) {
        currentImageIndex.value = i;
        selectKnowledgeIndex.value = 0;
        if (currentImageIndex.value == imageInfoList.length - 1) {
          imageInfoList[i].complete = true;
        }
        getNextButtonText();
        Future.delayed(const Duration(seconds: 1), () {
          nextButtonFlag = false;
        });
        return;
      }
    }

    List<QuizModel> drowQuizList = [];
    for (int i = 0; i < imageInfoList.length; i++) {
      drowQuizList.add(imageInfoList[i].quizData);
    }

    List<Map<String, dynamic>> argumentsKnowledgeList = [];
    for (int i = 0; i < unitKnowledgeList!.length; i++) {
      argumentsKnowledgeList.add(unitKnowledgeList![i].toJson());
    }

    dynamic pageRes = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_QUIZ_LABEL_PICTURE_PRVIEW,
      arguments: {
        "quizList": drowQuizList,
        "unitId": unitId,
        "aiCode": aiCode,
        "aiRecordId": aiRecordId,
        "knowledgeList": argumentsKnowledgeList,
        "difficultyMin": difficultyMin,
        "difficultyMax": difficultyMax,
        "language": language,
        "lessonId": lessonId,
        "configId": configId,
      },
    );
    Future.delayed(const Duration(seconds: 1), () {
      nextButtonFlag = false;
    });

    if (pageRes == null) return;
    int editIndex = pageRes;
    currentImageIndex.value = editIndex;
    imageInfoList[currentImageIndex.value].complete = false;
    selectKnowledgeIndex.value = 0;
  }

  @override
  void onClose() {
    super.onClose();
  }
}
