import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:api/api.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../utils/mqtt_utils/mqtt_message_services_code.dart';
import '../../../../../routes/routes.dart';
import '../../../../../routes/tag_routes.dart';
import '../../../dialog/dialogs.dart';
import '../../../dialog/manage_select_exercise_lesson_dialog.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';
import '../views/manage_knowledge_related_details_image_upload_dialog.dart';

class ManageKnowledgeRelatedDetailsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageKnowledgeRelatedDetailsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS;

  @override
  String get breadcrumbTitle => '知识点详情';

  /// 0题目 1图片 2视频
  int quizOrImage = 1;

  late String type;
  late int uid;
  int? semanticId;
  /// 页面传入的风格 id，用于首屏请求和左侧默认选中定位。
  late int styleId;

  final RxInt segmentIndex = 1.obs;

  final RxInt selectedPosIndex = 0.obs;
  final RxInt selectedStyleGroupIndex = (-1).obs;
  final RxInt selectedCountryGroupIndex = (-1).obs;
  bool _hasInitializedImageStyleSelection = false;
  bool _hasInitializedVideoStyleSelection = false;

  final RxList<EnEntitySemantics> semantics = <EnEntitySemantics>[].obs;

  final Rx<ImageStyleConfigV2ResponseData?> styleConfigV2 = Rx<ImageStyleConfigV2ResponseData?>(null);
  final RxBool loading = true.obs;
  final Rx<ContentReviewKnowledgeImagesResponseData?> imagesData = Rx<ContentReviewKnowledgeImagesResponseData?>(null);

  final RxInt imageCount = 0.obs;
  final RxInt exerciseCount = 0.obs;
  final RxInt videoCount = 0.obs;

  final ScrollController exerciseScrollController = ScrollController();
  final RxList<ExerciseTypeListEntity> exerciseTypeList = <ExerciseTypeListEntity>[].obs;
  final RxString selectedExerciseType = ''.obs;
  final RxList<QuizModel> exerciseList = <QuizModel>[].obs;
  final RxBool isBatchOperation = false.obs;
  final RxBool exerciseIsSelectAll = false.obs;
  final RxList<int> exerciseSelectIds = <int>[].obs;
  int exerciseListOffset = 0;
  int exerciseListLimit = 30;
  int exerciseListCount = 0;

  final RxList<int> exercisePendingReviewIds = <int>[].obs;

  StreamSubscription<PushMessageServiceEnitiy>? _messageSub;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if (Get.arguments != null) {
      final args = (Get.arguments ?? {}) as Map;
      type = (args['type'] ?? '').toString();

      uid = (args['uid'] is num) ? (args['uid'] as num).toInt() : int.tryParse(args['uid']?.toString() ?? '') ?? 0;
      semanticId = args['semanticId'];
      styleId = (args['styleId'] is num) ? (args['styleId'] as num).toInt() : int.tryParse(args['styleId']?.toString() ?? '') ?? 0;
      quizOrImage = args['quizOrImage'] ?? 1;
      segmentIndex.value = quizOrImage;
      init();
      initExerciseScrollListener();
    }

    _messageSub = MqttNotificationMessage.instance.listenByCode(
      codes: [
        MqttMessageServicesCode.MESSAGE_IMAGE_TASK,
        MqttMessageServicesCode.MESSAGE_ASS_TASK,
        MqttMessageServicesCode.MESSAGE_VIDEO_TASK,
      ], 
      whereBackPage: true,
      onData: (value){
        refreshByCode(value.message.code, value.isBackPage);
      },
    );
    
  }

  Future<void> init() async {
    await fetchSemanticList();

    await fetchStyleConfigV2();
    await fetchQuestionTypeList();
    await fetchImages();
    

    if (segmentIndex.value == 0) {
      exerciseListOffset = 0;
      exerciseList.clear();
      exerciseSelectIds.clear();
      exerciseIsSelectAll.value = false;
      await fetchExerciseList();
    }else if(segmentIndex.value == 1){
      
    }else if(segmentIndex.value == 2){
      await fetchVideoData();
    }
  }

  /// 根据code刷新对应的地方
  Future<void> refreshByCode(String? code, bool isBack) async {
    if(code == MqttMessageServicesCode.MESSAGE_IMAGE_TASK){
      if(isBack){
        fetchImages();
        return;
      }
      final res = await ContentReviewImageUtil.fetchKnowledgeImages(type, semanticId, uid, styleId);
      if(res == null) return;
      imagesData.value?.taskIds?.clear();
      imagesData.value?.taskIds?.addAll(res.data?.taskIds ?? []);
    }else if(code == MqttMessageServicesCode.MESSAGE_ASS_TASK || code == MqttMessageServicesCode.MESSAGE_VIDEO_TASK){
      fetchVideoList();
    }
  }

  Future<void> fetchSemanticList() async {
    try {
      final config = RequestConfig(
        requireToken: true,
      );
      final res = await WordUtil.semanticListNew(config: config, type: type, uid: uid);
      final list = res.data ?? const <EnEntitySemantics>[];
      semantics.assignAll(list);

      final idx = semantics.indexWhere((e) => e.uid == semanticId);
      if (idx >= 0) {
        selectedPosIndex.value = idx;
      } else {
        selectedPosIndex.value = 0;
        if (semantics.isNotEmpty) {
          semanticId = semantics.first.uid == 0 ? null : semantics.first.uid;
        }
      }

      if (semantics.isNotEmpty) {
        if (semanticId == null) {
          semanticId = semantics.first.uid == 0 ? null : semantics.first.uid;
          imageCount.value = semantics.first.image_cnt ?? 0;
          exerciseCount.value = semantics.first.exercise_cnt ?? 0;
          videoCount.value = semantics.first.video_cnt??0;
        } else {
          final idx = semantics.indexWhere((e) => e.uid == semanticId);
          if (idx >= 0) {
            imageCount.value = semantics[idx].image_cnt ?? 0;
            exerciseCount.value = semantics[idx].exercise_cnt ?? 0;
            videoCount.value = semantics[idx].video_cnt ?? 0;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> fetchImages() async {
    loading.value = true;
    final lastSelectedStyleId = currentSelectedStyleId;

    final res = await ContentReviewImageUtil.fetchKnowledgeImages(type, semanticId, uid, styleId);
    if (res?.data == null) {
      imagesData.value = null;
      loading.value = false;
      return;
    }

    imagesData.value = res!.data;
    loading.value = false;

    final styleGroups = imagesData.value?.styleGroups;
    if (styleGroups == null) return;
    _syncImageStyleSelection(styleGroups, lastSelectedStyleId);
  }

  Future<void> fetchStyleConfigV2() async {
    if (styleConfigV2.value != null) return;

    try {
      final config = RequestConfig(
        requireToken: true,
        data: const {},
        parameters: const {},
      );
      final res = await ImageUtil.stylesV2(config: config);
      if (res.data == null) return;
      styleConfigV2.value = res.data;
    } catch (_) {
      return;
    }
  }

  void setSelectedPosIndex(int index) {
    if (selectedPosIndex.value == index) return;

    final target = semantics[index];
    semanticId = target.uid == 0 ? null : target.uid;

    selectedPosIndex.value = index;
    imageCount.value = target.image_cnt ?? 0;
    exerciseCount.value = target.exercise_cnt ?? 0;
    videoCount.value = target.video_cnt ?? 0;
    if (segmentIndex.value == 0) {
      fetchExerciseData();
    } else if(segmentIndex.value == 1){
      fetchImages();
    }else if(segmentIndex.value == 2){
      fetchVideoData();
    }
  }

  Future<void> setSegmentIndex(int index) async {
    segmentIndex.value = index;
    if (index == 0) {
      await fetchExerciseData();
    } else if(index == 1){
      await fetchStyleConfigV2();
      fetchImages();
    } else if(index == 2){
      fetchVideoData();
    }
  }

  void selectCountryGroup({required int styleIndex, required int countryIndex}) {
    selectedStyleGroupIndex.value = styleIndex;
    selectedCountryGroupIndex.value = countryIndex;
  }

  /// 同步图片左侧默认选中项，优先保留用户当前选择，其次使用页面传入的风格 id。
  void _syncImageStyleSelection(List<ContentReviewStyleGroup> styleGroups, int? lastSelectedStyleId) {
    if (styleGroups.isEmpty) {
      selectedStyleGroupIndex.value = -1;
      selectedCountryGroupIndex.value = -1;
      _hasInitializedImageStyleSelection = true;
      return;
    }

    if (lastSelectedStyleId != null && _selectImageGroupByStyleId(styleGroups, lastSelectedStyleId)) {
      _hasInitializedImageStyleSelection = true;
      return;
    }

    if (!_hasInitializedImageStyleSelection && styleId > 0 && _selectImageGroupByStyleId(styleGroups, styleId)) {
      _hasInitializedImageStyleSelection = true;
      return;
    }

    final styleIndex = selectedStyleGroupIndex.value;
    final countryIndex = selectedCountryGroupIndex.value;
    final isAllSelected = styleIndex == -1 && countryIndex == -1;
    final hasValidSelectedGroup = styleIndex >= 0 &&
        styleIndex < styleGroups.length &&
        countryIndex >= 0 &&
        countryIndex < (styleGroups[styleIndex].countryGroups?.length ?? 0);
    if (!isAllSelected && !hasValidSelectedGroup) {
      selectedStyleGroupIndex.value = -1;
      selectedCountryGroupIndex.value = -1;
    }

    _hasInitializedImageStyleSelection = true;
  }

  /// 根据风格 id 定位图片左侧国家分组，并同步选中索引。
  bool _selectImageGroupByStyleId(List<ContentReviewStyleGroup> styleGroups, int targetStyleId) {
    for (int styleIndex = 0; styleIndex < styleGroups.length; styleIndex++) {
      final countryGroups = styleGroups[styleIndex].countryGroups ?? const <ContentReviewStyleCountryGroup>[];
      for (int countryIndex = 0; countryIndex < countryGroups.length; countryIndex++) {
        if (countryGroups[countryIndex].styleId != targetStyleId) continue;
        selectedStyleGroupIndex.value = styleIndex;
        selectedCountryGroupIndex.value = countryIndex;
        return true;
      }
    }
    return false;
  }

  List<ContentReviewImage> get currentImages {
    final d = imagesData.value;
    final groups = d?.styleGroups ?? const [];
    if (groups.isEmpty) return const [];

    final si = selectedStyleGroupIndex.value;
    final ci = selectedCountryGroupIndex.value;
    if (si == -1 && ci == -1) {
      var list = <ContentReviewImage>[];
      for (var group in groups) {
        list.addAll(group.countryGroups?.expand((e) => e.images ?? const []) ?? const []);
      }
      return list;
    }

    if (si < 0 || si >= groups.length) return const [];

    final countries = groups[si].countryGroups ?? const [];
    if (countries.isEmpty) return const [];

    if (ci < 0 || ci >= countries.length) return const [];

    return countries[ci].images ?? const [];
  }

  int? get currentSelectedStyleId {
    final d = imagesData.value;
    final groups = d?.styleGroups ?? const [];
    if (groups.isEmpty) return null;

    final si = selectedStyleGroupIndex.value;
    if (si < 0 || si >= groups.length) return null;

    final countries = groups[si].countryGroups ?? const [];
    if (countries.isEmpty) return null;

    final ci = selectedCountryGroupIndex.value;
    if (ci < 0 || ci >= countries.length) return null;
    return countries[ci].styleId;
  }

  Future<void> takedownImage(BuildContext context, ContentReviewImage image) async {
    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "是否下架该图片",
      content: "下架后将不再展示，并会同步删除该数据。\n请确认是否继续操作。",
      cancel: "再想想",
      define: "确定下架",
    );
    if(!askRes) return;

    final relationUid = image.semanticImageRelationId;
    if (relationUid == null) return;

    final res = await ContentReviewImageUtil.takedown(relationUid);
    if (res == null) {
      ToastUtils.showToast(text: '下架失败');
      return;
    }
    ToastUtils.showToast(text: '下架成功', type: ToastType.success);
    await init();
  }


  Future<void> convertImageWithSelection({
    required ContentReviewImage image,
    required List<int> styleIds,
    required int numberOfImages,
  }) async {
    final promptId = image.promptId;
    if (promptId == null) return;
    if (styleIds.isEmpty) return;

    final res = await ContentReviewImageUtil.convert(promptId, styleIds, numberOfImages);
    if (res == null) {
      ToastUtils.showToast(text: '转化失败');
      return;
    }
    ToastUtils.showToast(text: '转化成功', type: ToastType.success);
    await fetchImages();
  }

  Future<void> createNewImageWithPrompt({required List<int> styleIds, required int numberOfImages, required String prompt}) async {
    if (styleIds.isEmpty) {
      ToastUtils.showToast(text: "请选择风格");
      return;
    }

    if (prompt.isEmpty) {
      ToastUtils.showToast(text: '请填写提示词');
      return;
    }
    final n = numberOfImages <= 0 ? 1 : numberOfImages;

    final res = await ContentReviewImageUtil.createImageByPrompt(styleIds, n, type, semanticId, uid, prompt);
    if (res == null) {
      ToastUtils.showToast(text: '新建失败');
      return;
    }
    ToastUtils.showToast(text: '新建成功', type: ToastType.success);
    await fetchImages();
  }

  Future<void> createNewImageWithSelection({
    required List<int> styleIds,
    required int numberOfImages,
  }) async {
    if (styleIds.isEmpty) {
      ToastUtils.showToast(text: "请选择风格");
      return;
    }

    final n = numberOfImages <= 0 ? 1 : numberOfImages;

    final res = await ContentReviewImageUtil.createImage(styleIds: styleIds, numberOfImages: n, type: type, semanticId: semanticId, uid: uid);
    if (res == null) {
      ToastUtils.showToast(text: '新建失败');
      return;
    }
    ToastUtils.showToast(text: '新建成功', type: ToastType.success);
    await fetchImages();
  }

  /// 上传图片
  Future<void> imageUpload(BuildContext context) async{
    bool res = await ManageKnowledgeRelatedDetailsImageUploadDialog.show(
      context: context, 
      type: type, 
      uid: uid, 
      semanticId: semanticId,
    );
    if(!res) return;
    await fetchImages();
  }


  Future<void> openReviewedList() async {
    if ((imagesData.value?.taskIds ?? const []).isEmpty) {
      ToastUtils.showToast(text: '该语义没有审核任务', type: ToastType.info);
      return;
    }

    ManagePageRegistry.jumpTo(
      Routes.MANAGE_CHECK_IMAGE,
      arguments: {"taskIds": imagesData.value?.taskIds},
    ).then((value) {
      fetchImages();
    });
  }

  Future<void> editSemantic(BuildContext context) async {
    bool res = await ManageEditGlossDescDialog.showEdit(
      context: context,
      gloss: semantics[selectedPosIndex.value].gloss,
      descriptions: semantics[selectedPosIndex.value].descriptions,
      semanticId: semantics[selectedPosIndex.value].uid,
      showEduTier: false,
    );
    if (!res) return;
    if (type == ElementsCardType.word.value || type == ElementsCardType.phrase.value) {
      await fetchSemanticList();
    }
  }

  Future<void> openCourseList(int? semanticId) async {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_ENGLISH_COURSE_USAGE,
      arguments: {
        'uid': uid,
        'semanticId': semanticId == 0 ? null : semanticId,
        'type': type,
      },
    );
  }

  /// 图片生成视频
  Future<void> imageGeneratedVideo(BuildContext context, ContentReviewImage image) async{
    ManageImageGeneratedVideoDialog.show(
      context: context, 
      image: image, 
      type: type, 
      uid: uid, 
      semanticId: semanticId == 0 ? null : semanticId,
    );
  }

  /// 去统一图片创建
  Future<void> toUnifiedImageCreate({ContentReviewImage? img, bool isCreate = true}) async{
    int? styleId = img?.styleId;
    if(!isCreate){
      if(img?.imageId == null) return ToastUtils.showToast(text: "暂无图片ID");
    }else{
      styleId = currentSelectedStyleId;
    }
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_UNIFIED_IMAGE_CREATE,
      arguments: {
        "jumpCode": AppManageRoutesCode.knowledgeRelatedDetails,
        "uid": uid,
        "type": type,
        "semanticId": semanticId == 0 ? null : semanticId,
        "imageIds": isCreate ? [] : [img?.imageId!],
        "styleId": styleId,
        "params": {
          "uid": uid,
          "type": type,
          "semanticId": semanticId == 0 ? null : semanticId,
          "styleId": styleId,
          "quizOrImage": segmentIndex.value,
        },
      },
    );
    fetchImages();
  }



  void initExerciseScrollListener() {
    exerciseScrollController.addListener(() {
      if (exerciseScrollController.position.pixels >= exerciseScrollController.position.maxScrollExtent - 100 && !exerciseScrollController.position.outOfRange) {
        if ((exerciseListOffset + exerciseListLimit) < exerciseListCount && !loading.value) {
          loading.value = true;
          exerciseListOffset += exerciseListLimit;
          fetchExerciseList();
        }
      }
    });
  }

  Future<void> fetchExerciseData() async {
    try {
      loading.value = true;
      exerciseListOffset = 0;
      exerciseList.clear();
      exerciseSelectIds.clear();
      exerciseIsSelectAll.value = false;
      await fetchQuestionTypeList();
      await fetchExerciseList();
    } finally {
      loading.value = false;
    }
  }

  Future<void> fetchQuestionTypeList() async {
    Map<String, dynamic> reqData = {
      "uid": uid,
      "type": type,
    };

    if (semanticId != null) {
      reqData["semanticId"] = semanticId;
    }

    try {
      final res = await ManageExerciseRequest.getExerciseTypeList(reqData);
      if (res == null) return;

      exerciseTypeList.clear();

      int allCount = 0;
      for (var item in res) {
        allCount += item.count ?? 0;
      }
      exerciseTypeList.add(ExerciseTypeListEntity(type: "", name: "全部", count: allCount));
      exerciseTypeList.addAll(res);

      if (exerciseTypeList.isEmpty) return;

      if (selectedExerciseType.isEmpty) {
        selectedExerciseType.value = exerciseTypeList.first.type ?? "";
      }

      pendingReviewExerciseIds();
    } finally {
      loading.value = false;
    }
  }

  Future<void> pendingReviewExerciseIds() async {
    Map<String, dynamic> reqData = {
      "uid": uid,
      "type": type,
    };
    if (semanticId != null) {
      reqData["semanticId"] = semanticId;
    }
    ExerciseReviewIdsEntity? res = await ExerciseReviewRequest.getPendingReviewExerciseIds(reqData);
    if (res == null) return;
    List<int?> taskIds = res.taskIds ?? const [];
    exercisePendingReviewIds.clear();
    for (int? taskId in taskIds) {
      if (taskId == null) continue;
      exercisePendingReviewIds.add(taskId);
    }
  }

  void setSelectedExerciseType(String? type) {
    if (type == null) return;
    selectedExerciseType.value = type;
    exerciseListOffset = 0;
    exerciseList.clear();
    fetchExerciseList();
  }

  Future<void> fetchExerciseList() async {
    Map<String, dynamic> params = {
      "offset": exerciseListOffset,
      "limit": exerciseListLimit,
    };

    Map<String, dynamic> content = {
      "uid": uid,
      "type": type,
    };

    if (semanticId != null) {
      content["semanticId"] = semanticId;
    }

    Map<String, dynamic> reqData = {
      "content": content,
    };
    if (selectedExerciseType.isNotEmpty) {
      reqData["type"] = selectedExerciseType.value;
    }

    try {
      loading.value = true;
      ListResponseEntity<QuizModel>? res = await ManageExerciseRequest.getExerciseList(params, reqData);
      if (res == null) return;
      exerciseListCount = res.count ?? 0;
      exerciseList.addAll(res.datas ?? const []);
    } finally {
      loading.value = false;
    }
  }

  void batchOperationButton() {
    isBatchOperation.value = !isBatchOperation.value;
    if (!isBatchOperation.value) {
      exerciseSelectIds.clear();
      exerciseIsSelectAll.value = false;
    }
  }

  void selectExerciseIds(int uid) {
    if (exerciseSelectIds.contains(uid)) {
      exerciseSelectIds.remove(uid);
    } else {
      exerciseSelectIds.add(uid);
    }
    exerciseIsSelectAll.value = exerciseSelectIds.length == exerciseList.length;
  }

  void selectAllQuiz() {
    if (exerciseList.isEmpty) {
      exerciseSelectIds.clear();
      exerciseIsSelectAll.value = false;
      return ToastUtils.showManageToast(text: "暂无数据");
    }
    if (exerciseIsSelectAll.value) {
      exerciseSelectIds.clear();
    } else {
      for (int i = 0; i < exerciseList.length; i++) {
        if (exerciseList[i].uid == null) continue;
        if (exerciseSelectIds.contains(exerciseList[i].uid!)) continue;
        exerciseSelectIds.add(exerciseList[i].uid!);
      }
    }

    exerciseIsSelectAll.value = exerciseSelectIds.length == exerciseList.length;
  }

  /// 单独上下架
  Future<void> upDownLessonQuizOne(BuildContext context, QuizModel entity) async{
    if(entity.uid == null) return;
    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确定要 ${entity.access == AccessEnum.NORMAL.value ? '下架' : '上架'} 此题目吗？",
    );
    if (!askRes) return;
    bool res = await quizOperation(
      entity.access == AccessEnum.INTERNAL.value ? "batch_exercise_shelf_on" : "batch_exercise_shelf_off",
      [entity.uid!],
      entity.access == AccessEnum.INTERNAL.value ? "上架" : "下架",
    );
    if (!res) return;
    fetchExerciseData();


  }

  Future<void> upDownLessonQuiz(bool isUp) async {
    if (exerciseSelectIds.isEmpty) return ToastUtils.showManageToast(text: "请先选择题目");
    bool res = await quizOperation(
      isUp ? "batch_exercise_shelf_on" : "batch_exercise_shelf_off",
      exerciseSelectIds.toList(),
      isUp ? "上架" : "下架",
    );
    if (!res) return;
    fetchExerciseData();
  }

  Future<void> exerciseBatchDelete(BuildContext context) async {
    if (exerciseSelectIds.isEmpty) return ToastUtils.showManageToast(text: "请先选择题目");

    String method = "batch_exercise_shelf_delete";
    bool res = await AskDialog.show(
      context: context,
      title: "确定要从 后台数据中 删除该题？",
      content: "选中的题会从数据库中永久删除，并且不可恢复。",
      define: "确定删除",
      defineColor: const Color(0xffFF2D46),
      titleColor: const Color(0xffFF2D46),
    );

    if (!res) return;
    final del = await quizOperation(method, exerciseSelectIds.toList(), "删除");
    if (!del) return;
    await fetchSemanticList();
    fetchExerciseData();
  }

  Future<void> showDeleteQuizDialog(BuildContext context, int index, QuizModel quiz) async {
    if (quiz.uid == null) return;

    String method = "batch_exercise_shelf_delete";
    bool res = await AskDialog.show(
      context: context,
      title: "确定要从 后台数据中 删除该题？",
      content: "该题会从数据库中永久删除，并且不可恢复。",
      define: "确定删除",
      defineColor: const Color(0xffFF2D46),
      titleColor: const Color(0xffFF2D46),
    );

    if (!res) return;
    final del = await quizOperation(method, [quiz.uid!], "删除");
    if (!del) return;
    exerciseList.removeAt(index);
    await fetchQuestionTypeList();
    await fetchSemanticList();
  }

  Future<bool> quizOperation(String method, List<int> ids, String text) async {
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> data = {
        "exerciseIds": ids,
      };
      bool res = await ManageSelectQuziKnowledge.quizOperation(data, method);
      if (!res) return false;
      exerciseSelectIds.clear();
      exerciseIsSelectAll.value = false;
      ToastUtils.showManageToast(text: "$text成功");
      return true;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> toSendToCourse(BuildContext context, QuizModel quiz) async {
    if (quiz.uid == null) return;
    await ManageSelectExerciseLessonDialog.show(
      context: context,
      exerciseId: quiz.uid!,
      uid: uid,
      type: type,
      semanticId: semanticId,
    );
  }

  Future<void> toDemonstrate(List<QuizModel> list, {QuizModel? current}) async {
    if (list.isEmpty) return;
    dynamic res = await TagRoutes.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "currentQuizId": current?.uid,
        "quizDatas": list.toList(),
        "isShowUpDownStatus": true,
        "isAdminPage": true,
      },
    );
    if (res == null) return;
    Map<String, dynamic> resMap = res as Map<String, dynamic>;
    if (resMap["isEdit"] != true) return;
    String? manageRoute = resMap["manageRoute"];
    if (manageRoute == null || manageRoute.isEmpty) return;
    int? uid = resMap["quizId"];
    if (uid == null) return;
    await ManagePageRegistry.jumpTo(
      manageRoute,
      arguments: {
        "quizId": uid,
      },
    );
    await fetchSemanticList();
    fetchExerciseData();

  }

  Future<void> toNewQuiz(BuildContext context) async {
    String? exerciseType;
    String? exerciseTypeName;
    if (selectedExerciseType.value.isNotEmpty) {
      exerciseType = selectedExerciseType.value;
      exerciseTypeName = exerciseTypeList.firstWhere((element) => element.type == selectedExerciseType.value).name;
    }

    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_CREATE_EXERCISES,
      arguments: {
        "contentType": type,
        "contentId": uid,
        "semanticId": semanticId,
        "pageType": "course",
        "exerciseType": exerciseType,
        "exerciseTypeName": exerciseTypeName,
      },
    );
    await fetchSemanticList();
    fetchExerciseData();
  }

  Future<void> editQuiz(QuizModel quiz) async {
    String? manageRoute = QuizRoutesUtils.getEditQuizRouteNameByContentType(quiz.type);
    if (manageRoute == null || manageRoute == "") {
      ToastUtils.showManageToast(text: "不支持编辑此类型题目");
      return;
    }
    await ManagePageRegistry.jumpTo(
      manageRoute,
      arguments: {
        "quizId": quiz.uid,
      },
    );
    await fetchSemanticList();
    fetchExerciseData();
  }

  Future<void> toQuizReview() async {
    if (exercisePendingReviewIds.isEmpty) {
      return ToastUtils.showManageToast(text: "暂无待审核题目");
    }

    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_EXERCISES,
      arguments: {
        "taskIds": exercisePendingReviewIds.toList(),
      },
    );
    fetchExerciseData();
  }


  // ============= 以下是视频逻辑 ===================

  /// 待审核视频数量
  final RxInt pendingVideoReviewCount = 0.obs;
  /// 待审核字幕ids
  final RxList<int> assPendingReviewIds = <int>[].obs;
  final RxList<EnKnowledgeVideoEntityStyleGroups> videoList = <EnKnowledgeVideoEntityStyleGroups>[].obs;
  /// 视频 选择的风格id
  final RxInt videoSelectStyleId = (-1).obs;

  /// 筛选出来的视频列表
  final RxList<EnKnowledgeVideoEntityStyleGroupsCountryGroupsVideos> videoShowList = <EnKnowledgeVideoEntityStyleGroupsCountryGroupsVideos>[].obs;

  

  Future<void> fetchVideoData() async{
    final lastSelectedStyleId = videoSelectStyleId.value;
    try {
      loading.value = true;
      videoList.clear();
      videoShowList.clear();
      await fetchVideoList();
      changeVideoClass(_resolveVideoSelectedStyleId(lastSelectedStyleId));
    } finally {
      loading.value = false;
    }
  }

  Future<void> fetchVideoList() async{
    Map<String, dynamic> reqData = {
      "semanticId": semanticId,
      "type": type,
      "uid": uid,
    };
    EnKnowledgeVideoEntity? res = await LanguageConsoleRequest.getKnowledgeVideo(data: reqData);
    if(res == null) return;
    pendingVideoReviewCount.value = res.taskIds?.length??0;
    List<int?> assTaskIds = res.assTaskIds ?? const [];
    assPendingReviewIds.clear();
    for (int? taskId in assTaskIds) {
      if (taskId == null) continue;
      assPendingReviewIds.add(taskId);
    }

    List<EnKnowledgeVideoEntityStyleGroups?> styleGroups = res.styleGroups??[];
    videoList.clear();
    for (var element in styleGroups) {
      if(element == null) continue;
      videoList.add(element);
    }

  }

  /// 视频切换分类
  void changeVideoClass(int? styleId){
    if(styleId == null) return;
    videoSelectStyleId.value = styleId;

    videoShowList.clear();
    if(styleId == -1){

      for (var element in videoList) {
        List<EnKnowledgeVideoEntityStyleGroupsCountryGroups?> countryGroups = element.countryGroups??[];
        for (var group in countryGroups) {
          if(group == null) continue;
          List<EnKnowledgeVideoEntityStyleGroupsCountryGroupsVideos?> videos = group.videos??[];
          for (var videoItem in videos) {
            if(videoItem == null) continue;
            videoShowList.add(videoItem);
          }
        }
      }
      return;
    }

    for (var element in videoList) {
      List<EnKnowledgeVideoEntityStyleGroupsCountryGroups?> countryGroups = element.countryGroups??[];
      for (var group in countryGroups) {
        if(group == null) continue;
        if(group.styleId != styleId) continue;
        List<EnKnowledgeVideoEntityStyleGroupsCountryGroupsVideos?> videos = group.videos??[];
        for (var videoItem in videos) {
          if(videoItem == null) continue;
          videoShowList.add(videoItem);
        }
      }
    }
  }

  /// 计算视频左侧应该默认选中的风格 id。
  int _resolveVideoSelectedStyleId(int lastSelectedStyleId) {
    if (lastSelectedStyleId > 0 && _hasVideoStyleId(lastSelectedStyleId)) {
      _hasInitializedVideoStyleSelection = true;
      return lastSelectedStyleId;
    }

    if (!_hasInitializedVideoStyleSelection && styleId > 0 && _hasVideoStyleId(styleId)) {
      _hasInitializedVideoStyleSelection = true;
      return styleId;
    }

    _hasInitializedVideoStyleSelection = true;
    return -1;
  }

  /// 判断视频分组里是否存在目标风格 id。
  bool _hasVideoStyleId(int targetStyleId) {
    for (final styleGroup in videoList) {
      final countryGroups = styleGroup.countryGroups ?? const <EnKnowledgeVideoEntityStyleGroupsCountryGroups?>[];
      for (final countryGroup in countryGroups) {
        if (countryGroup?.styleId == targetStyleId) return true;
      }
    }
    return false;
  }

  /// 下架视频
  Future<void> downVideo(BuildContext context, int? relationUid) async{
    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "下架视频",
      content: "确定要下架此视频吗？",
    );
    if(!askRes) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": relationUid,
      };
      bool res = await LanguageConsoleRequest.downVideo(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "下架成功", type: ToastType.success);
      init();
    } finally{
      ToastUtils.hideLoading();
    }

  }

  /// 跳转至视频详情
  Future<void> toVideoDetils(int? videoRelationId) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_VIDEO_DETILS,
      arguments: {
        "videoRelationId": videoRelationId,
        "isAdminPage": true,
      },
    );
    await fetchVideoData();
  }

  /// 跳转至审核字幕页面
  Future<void> toReviewVideoAss() async{
    if(assPendingReviewIds.isEmpty) return ToastUtils.showToast(text: "暂无待审核字幕");
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_ASS,
      arguments: {
        "taskIds": assPendingReviewIds.toList(),
      },
    );
    await fetchVideoData();
  }

  /// 跳转至视频审核列表页面
  Future<void> toReviewVideo() async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_VIDEO,
      arguments: {
        "subContent": {
          'uid': uid, 
          'type': type, 
          'semanticId': semanticId,
        },
      },
    );
    init();
  }


  /// 新建视频
  Future<void> crtateVideoDialog(BuildContext context) async{
    ManageCreateVideoDialog.show(
      context: context,
      uid: uid,
      type: type,
      semanticId: semanticId,
    );
  }



  @override
  void onClose() {
    super.onClose();
    exerciseScrollController.dispose();
    _messageSub?.cancel();
  }
}
