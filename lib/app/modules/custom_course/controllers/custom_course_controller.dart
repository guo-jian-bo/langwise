import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/custom_course/views/sample_cover_dialog.dart';
import 'package:langwise/app/modules/home/controllers/home_controller.dart';
import 'package:langwise/app/modules/official_course_details/controllers/official_course_details_controller.dart';
import 'package:langwise/app/modules/official_course_details/official_course_details_level/controllers/official_course_details_level_controller.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/entities/custom_course_book_entity.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/entities/location.dart';
import 'package:langwise/common/https/customized_courses.dart';
import 'package:langwise/common/https/official_course_details.dart';
import 'package:langwise/common/https/pay.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/common/widgets/camera_macos_custom_curse_dialog.dart';
import 'package:langwise/common/widgets/camera_windows_custom_curse_dialog.dart';
import 'package:langwise/common/widgets/parent_password_dialog.dart';
import 'package:langwise/common/widgets/customer_service_dialog.dart';
import 'package:langwise/common/widgets/step_progress_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../views/custom_course_choose_book_dialog.dart';

class CustomCourseController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  CustomCourseController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.CUSTOM_COURSE;

  @override
  String get breadcrumbTitle => '添加教材';

  //传进来的参数
  int? courseId;
  int? levelId;
  int? moduleId;
  // 0=新增教材 1=从管理界面进来的 4=从学习计划进入
  int? fromType;

  final RxList<StepProgressData> steps = <StepProgressData>[
    StepProgressData(
      step: 1,
      name: "教材添加",
      current: true,
    ),
    StepProgressData(
      step: 2,
      name: "知识点添加",
    ),
    StepProgressData(
      step: 3,
      name: "知识点校对",
    ),
    StepProgressData(
      step: 4,
      name: "课程生成",
    ),
  ].obs;

  late final PageController pageController;
  final RxBool isInitPageController = false.obs;
  final RxDouble currentPageIndex = 0.0.obs;

  /// 位置城市编码
  final RxBool locationRequested = false.obs;
  final RxString initDistrictCode = "".obs;

  /// 课程信息
  final RxBool courseInfoCardShow = false.obs;

  //添加教材的按钮标题
  final RxString buttonTitle = "继续".obs;

  // 课程按钮
  final RxBool bookInfoButtonDisable = true.obs;

  //课程当前步骤
  final RxInt bookCurrentStep = 1.obs;

  // 获取教材信息方式
  final RxInt bookSelectIndex = (-1).obs;

  // 封底条形码识别结果model
  late CustomCourseBookEntity bookEntity;

  //封底条形码识别结果是否提示
  final RxString recognitionErrorTip = ''.obs;
  final RxBool levelPlacementResolved = false.obs;

  final TextEditingController isbnController = TextEditingController();
  // 书籍名称
  final TextEditingController bookInfoNameInput = TextEditingController();
  // 书籍ISBN
  final TextEditingController bookIsbnController = TextEditingController();
  // 请填写书籍作用
  final TextEditingController courseDescribeInput = TextEditingController();

  /// 添加知识点
  final RxBool knowledgeAddCardShow = false.obs;

  // 添加知识点按钮
  final RxBool knowledgeButtonDisable = true.obs;

  // 知识点info 扫描次数 和 大概完成时间
  CustomCourseKnowledgeInfoEntity? knowledgeInfo;

  // 添加知识点方式
  final RxInt knowledgeSelectIndex = (0).obs;
  final RxInt knowledgeCurrentStep = 1.obs;

  // 扫描书籍次数
  final RxInt scanTimes = 0.obs;

  // 手动扫描需要的时长
  final RxString manualScanTime = "30-60分钟".obs;
  final Rxn<PackageShopDetailEntity> knowledgePackageShopDetail = Rxn<PackageShopDetailEntity>();
  final RxList<AiAnimationRunModel> generationRunList = <AiAnimationRunModel>[].obs;
  final Rx<CourseGenerateStatusResponseEntity> generationStatus = CourseGenerateStatusResponseEntity().obs;
  final RxInt generationRunType = 0.obs;
  int? generationTaskId;
  bool _generationDisposed = false;

  /// 扫描提示卡片是否显示
  final RxBool scanTipCardShow = false.obs;
  final RxBool courseGenerationCardShow = false.obs;

  //书籍识别的各种情况0：未识别，1：识别成功，2：识别在库不支持 3识别不在库 4未识别出isbn码
  final RxInt bookIdentifyStatus = 0.obs;

  /// 语言
  final RxString languageCode = "en".obs;

  ///封面、封底
  final RxString frontCover = "".obs;
  final RxString backCover = "".obs;
  final RxString frontCoverKey = ''.obs;
  final RxString backCoverKey = ''.obs;
  final RxString frontCoverNetWorkUrl = ''.obs;
  final RxString backCoverNetWorkUrl = ''.obs;
  RxString cefr = ''.obs;
  RxString levelName = ''.obs;
  int gradeIndex = 0;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      courseId = Get.arguments['courseId'];
      levelId = Get.arguments['levelId'];
      moduleId = Get.arguments['moduleId'];
      fromType = Get.arguments['fromType']; //4 从计划来
      cefr.value = Get.arguments['cefr'] ?? '';
      gradeIndex = Get.arguments['gradeIndex'] ?? 0;
      levelName.value = Get.arguments['levelName'] ?? '';
      generationTaskId = Get.arguments['taskId']?.toInt();
    }

    if (courseId == null && generationTaskId != null) {
      courseInfoCardShow.value = false;
      knowledgeAddCardShow.value = false;
      scanTipCardShow.value = false;
      courseGenerationCardShow.value = true;
      generationRunType.value = 0;
      generationRunList.clear();
      generationStatus.value = CourseGenerateStatusResponseEntity();
      stepSetting();
      currentPageIndex.value = 0.0;
      pageController = PageController(viewportFraction: 1, initialPage: 0);
      pageController.addListener(() {
        currentPageIndex.value = pageController.page ?? 0;
      });
      isInitPageController.value = true;
      getGenerationStatus();
      return;
    }

    initServiceData();
  }

  void reprocessExistingBook() {
    bookCurrentStep.value = 1;
    bookSelectIndex.value = -1;
    recognitionErrorTip.value = '';
    levelPlacementResolved.value = false;
    bookInfoButtonDisable.value = frontCoverKey.value.isEmpty || backCoverKey.value.isEmpty;
  }

  void enterManualIsbnInput() {
    bookCurrentStep.value = 2;
    bookSelectIndex.value = 1;
    bookInfoButtonDisable.value = isbnController.text.length != 13;
  }

  void backToFailureChoice() {
    bookCurrentStep.value = 2;
    bookSelectIndex.value = -1;
    bookInfoButtonDisable.value = false;
  }

  Future<void> continueAddingExistingBook(BuildContext context) async {
    bookEntity.status = 3;
    buttonTitle.value = "继续";
    bookInfoNameInput.text = bookEntity.title ?? '';
    bookInfoButtonDisable.value = false;
    if (bookEntity.levelMatched == false && !levelPlacementResolved.value) {
      bookCurrentStep.value = 2;
      bookCurrentStep.refresh();
      return;
    }
    bookCurrentStep.value = 3;
  }

  Future<void> selectLevelPlacement({required bool moveToSuggested}) async {
    if (moveToSuggested && courseId != null && bookEntity.grade != null) {
      await _changeCourseLevelToGrade(bookEntity.grade!);
    }
    levelPlacementResolved.value = true;
    bookInfoNameInput.text = bookEntity.title ?? '';
    buttonTitle.value = "继续";
    bookCurrentStep.value = 3;
    bookInfoButtonDisable.value = false;
  }

  /// 初始化服务数据
  Future<void> initServiceData() async {
    try {
      ToastUtils.showLoading();
      await getStepsData();
      // 这里获取课程数据
      await getCourseInfo();
      initDistrictCode.value = UserStore.to.userInfo.value.addressCode?.toString() ?? '';
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 获取步骤信息
  Future<void> getStepsData() async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.userCustomV2LoadCreateStatus)) return;
    Map<String, dynamic> reqData = {
      "courseId": courseId,
      "levelId": levelId,
      "moduleId": moduleId,
    };
    CustomizedCoursesStepsEntity? stepsEntity = await CustomizedCoursesRequest.getStepsData(reqData);
    if (stepsEntity == null) return;
    List<StepProgressData> stepsList = [];
    List<CustomizedCoursesStepsEntityStatuses?> statuses = stepsEntity.statuses ?? [];
    for (int i = 0; i < statuses.length; i++) {
      CustomizedCoursesStepsEntityStatuses? status = statuses[i];
      if (status == null) continue;
      List<CustomizedCoursesStepsEntityStatusesItems?> items = status.items ?? [];
      if (items.length < 2) {
        items.add(items.first);
      }
      items.sort((a, b) {
        return (a?.index ?? 0) - (b?.index ?? 0);
      });

      stepsList.add(StepProgressData(
        step: i + 1,
        name: status.title ?? "",
        code: status.code,
        current: status.current ?? false,
        complete: status.completed ?? false,
        items: List.generate(items.length, (index) {
          return StepProgressDataItems(
            code: items[index]?.code,
            title: items[index]?.title,
            index: items[index]?.index,
          );
        }),
      ));
    }

    steps.value = stepsList;

    StepProgressData current = steps.singleWhere((e) => e.current);
    int initialPage = 0;
    if (current.code == StepProgressEnum.LEVEL_CREATED || current.code == StepProgressEnum.MODULE_UN_CREATED) {
      courseInfoCardShow.value = true;
      initialPage = 0;
    }
    if (current.code == StepProgressEnum.MODULE_CREATED || current.code == StepProgressEnum.KNOWLEDGE_ADDING) {
      courseInfoCardShow.value = true;
      knowledgeAddCardShow.value = true;
      initialPage = 1;
    }

    stepSetting();

    getKnowledgeCardButtonFlag();

    currentPageIndex.value = initialPage.toDouble();
    pageController = PageController(viewportFraction: 1, initialPage: initialPage);
    pageController.addListener(() {
      currentPageIndex.value = pageController.page ?? 0;
    });

    isInitPageController.value = true;
  }

  /// 获取课程信息
  Future<void> getCourseInfo() async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.userCustomLoadCourseLevelModuleInfo)) return;
    if (courseId == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "courseId": courseId,
        "levelId": levelId,
        "moduleId": moduleId,
      };
      CustomizedCoursesInfoEntity? responseEntity = await CustomizedCoursesRequest.getCourseInfo(reqData);
      if (responseEntity == null) return;
      languageCode.value = responseEntity.language ?? '';

      List<CustomizedCoursesInfoEntityLevelList?> levelList = responseEntity.levelList ?? [];
      CustomizedCoursesInfoEntityLevelList? currentLevel;
      for (int i = 0; i < levelList.length; i++) {
        CustomizedCoursesInfoEntityLevelList? level = levelList[i];
        if (level == null) continue;
        if (level.uid == levelId) {
          currentLevel = level;
          if (cefr.value == "") {
            cefr.value = currentLevel.name ?? '';
          }
          break;
        }
      }

      if (moduleId != null) {
        List<CustomizedCoursesInfoEntityLevelListModuleList?> moduleList = currentLevel?.moduleList ?? [];
        for (int i = 0; i < moduleList.length; i++) {
          CustomizedCoursesInfoEntityLevelListModuleList? module = moduleList[i];
          if (module == null) continue;
          if (module.uid == moduleId) {
            if (module.isbn != null && module.bookId != null) {
              bookEntity = CustomCourseBookEntity(
                uid: module.bookId!,
                isbn: module.isbn ?? '',
                coverUrl: module.coverUrl ?? '',
                cover: module.cover ?? '',
              );
            }
            break;
          }
        }
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 设置 当前实际到哪一步
  void stepSetting() {
    int stepIndex = 0;

    if (courseInfoCardShow.value) {
      stepIndex = 0;
    }
    if (knowledgeAddCardShow.value) {
      stepIndex = 1;
    }
    if (courseGenerationCardShow.value) {
      stepIndex = 3;
    }
    for (int i = 0; i < steps.length; i++) {
      if (i == stepIndex) {
        steps[i].current = true;
        break;
      }
      steps[i].current = false;
      steps[i].complete = true;
      if ((steps[i].items?.length ?? 0) > 1) {
        steps[i].code = steps[i].items?.last.code;
        steps[i].name = steps[i].items?.last.title ?? "";
      }
    }
    steps.refresh();
  }

  /// pageview下一步
  Future<void> pageViewNext() async {
    stepSetting();
    await pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  /// 退出页面确认
  Future<void> showExitConfirmation(BuildContext context) async {
    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: '温馨提示',
      content: '是否确认退出课程创建？',
      defineColor: AppTheme.cAmber,
    );
    if (!askRes) return;
    Get.back();
  }

  /// 封面-拍照
  Future<void> selectFrontCover(BuildContext context) async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.resourceToken)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }

    File? file =
        await ImagePickerUtils.takeProcessedPhoto(context: context, cropAspectRatio: 3 / 4, isCoursesBook: true, isCoursesBookFront: true);
    if (file == null) return;
    frontCover.value = file.path;
    // 上传封面至服务器
    final record = await OssUploadFileUtils.uploadUserFile(
      filePath: frontCover.value,
    );
    if (record?.key == null) return;
    frontCoverKey.value = record!.key!;
    checkCoverIsUploaded();
  }

  /// 封面-相册
  Future<void> selectFrontCoverFromAlbum(BuildContext context) async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.resourceToken)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }
    File? file = await ImagePickerUtils.pickProcessedImage(context: context, cropAspectRatio: 3 / 4);
    if (file == null) return;
    try {
      ToastUtils.showLoading();
      // 上传封面至服务器
      final record = await OssUploadFileUtils.uploadUserFile(
        filePath: file.path,
      );
      if (record?.key == null) return;
      frontCover.value = file.path;
      frontCoverKey.value = record!.key!;
      checkCoverIsUploaded();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 封底-拍照
  Future<void> selectBackCover(BuildContext context) async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.resourceToken)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }
    File? file =
        await ImagePickerUtils.takeProcessedPhoto(context: context, cropAspectRatio: 3 / 4, isCoursesBook: true, isCoursesBookFront: false);
    if (file == null) return;
    backCover.value = file.path;
    // 上传封底至服务器
    final record = await OssUploadFileUtils.uploadUserFile(
      filePath: backCover.value,
    );
    if (record?.key == null) return;
    backCoverKey.value = record!.key!;
    checkCoverIsUploaded();
  }

  /// 封底-相册
  Future<void> selectBackCoverFromAlbum(BuildContext context) async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.resourceToken)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }
    File? file = await ImagePickerUtils.pickProcessedImage(context: context, cropAspectRatio: 3 / 4);
    if (file == null) return;
    try {
      ToastUtils.showLoading();
      // 上传封底至服务器
      final record = await OssUploadFileUtils.uploadUserFile(
        filePath: file.path,
      );
      if (record?.key == null) return;
      backCover.value = file.path;
      backCoverKey.value = record!.key!;
      checkCoverIsUploaded();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 检查封面和封底是否上传完成
  void checkCoverIsUploaded() async {
    if (frontCoverKey.value.isEmpty || backCoverKey.value.isEmpty) return;
    bookInfoButtonDisable.value = false;
    bookCurrentStep.value = 1;
  }

  /// 课程信息卡片继续按钮
  Future<void> courseInfoContinue(BuildContext context) async {
    if (bookCurrentStep.value == 1) {
      bookInfoButtonDisable.value = true;
      recognitionErrorTip.value = '';
      levelPlacementResolved.value = false;
      await matchBookInfoWithAI();
    } else if (bookCurrentStep.value == 2) {
      await matchBookInfoWithISBN();
    } else if (bookCurrentStep.value == 3) {
      if (bookEntity.status == 3) {
        try {
          ToastUtils.showLoading();
          if (knowledgeInfo == null) {
            await getBookScanCount();
          }

          knowledgeCurrentStep.value = 1;
          knowledgePackageShopDetail.value = null;
          getKnowledgeCardButtonFlag();
          knowledgeAddCardShow.value = true;
          await WidgetsBinding.instance.endOfFrame;
          await pageViewNext();
        } finally {
          ToastUtils.hideLoading();
        }
      } else {
        reportBookInfo();
      }
    }
  }

  /// 获取教材扫描次数和手动扫描时长
  Future<void> getBookScanCount() async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.userCustomV2AddKnowledgeInfoPage)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }

    Map<String, dynamic> parameters = {
      "bookId": bookEntity.uid,
    };
    CustomCourseKnowledgeInfoEntity? knowledge = await CustomizedCoursesRequest.getCustomCourseKnowledgeInfo(parameters);
    if (knowledge != null) {
      knowledgeInfo = knowledge;
      scanTimes.value = knowledge.reuseCount ?? 0;
      manualScanTime.value = knowledge.timeRange ?? manualScanTime.value;
    }
  }

  /// 上报教材信息至服务器
  void reportBookInfo() async {
    try {
      ToastUtils.showLoading();
      final String? resolvedIsbn = (bookEntity.isbn?.trim().isNotEmpty ?? false)
          ? bookEntity.isbn!.trim()
          : (bookIsbnController.text.trim().isNotEmpty ? bookIsbnController.text.trim() : null);

      Map<String, dynamic> reqData = {
        "isbn": resolvedIsbn,
        "purpose": courseDescribeInput.text.trim(),
        "addressCode": initDistrictCode.value,
        "difficulty": bookEntity.difficulty,
        "name": bookInfoNameInput.text.trim(),
        "recordId": bookEntity.recordId,
      };
      bool res = await CustomizedCoursesRequest.uploadUnBookInfo(reqData);
      if (res) {
        ToastUtils.showToast(text: "已上报成功", type: ToastType.success);
        Get.back();
      } else {
        bool askRes = await AskDialog.showUserAsk(
          context: Get.context!,
          title: "提示",
          content: "上报失败",
          define: "重新上报",
        );
        if (askRes) {
          return;
        } else {
          Get.back();
          return;
        }
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// ISBN码匹配教材信息
  Future<void> matchBookInfoWithISBN() async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.courseUserCustomLoadIsbnInfo)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }

    int? isbn = int.tryParse(isbnController.text);
    if (isbn == null) {
      ToastUtils.showManageToast(text: '请输入正确的ISBN码', type: ManageToastType.error);
      return;
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "levelId": levelId,
      };
      CustomCourseBookListEntity? bookList = await CustomizedCoursesRequest.getBookInfoWithISBN(isbn, parameters: parameters);
      if (bookList == null) return;
      dealBookListEntity(bookList, false);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// ai匹配教材信息
  Future<void> matchBookInfoWithAI() async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.userCustomLoadIsbnInfos)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "frontCover": frontCoverKey.value,
        "backCover": backCoverKey.value,
        "addressCode": initDistrictCode.value,
        "levelId": levelId,
      };
      CustomCourseBookListEntity? bookList = await CustomizedCoursesRequest.getBookInfoWithAI(reqData);
      if (bookList == null) return;
      dealBookListEntity(bookList, true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  ///处理识别出的教材列表
  void dealBookListEntity(CustomCourseBookListEntity bookList, bool isAI) async {
    if (bookList.list?.isEmpty ?? true) return;

    if (bookList.list!.length > 1) {
      CustomCourseBookEntity? book = await CustomCourseChooseBookDialog.show(
        context: Get.context!,
        bookList: bookList,
      );
      if (book == null) return;
      bookEntity = book;
      dealBookEntity(isAI);
    } else {
      bookEntity = bookList.list!.first;
      dealBookEntity(isAI);
    }
  }

  ///处理识别出或手动选择的教材
  void dealBookEntity(bool isAI) async {
    if (bookEntity.status == 0) {
      //未识别到条形码
      if (isAI) {
        buttonTitle.value = "继续";
        knowledgeAddCardShow.value = false;
        recognitionErrorTip.value = 'AI 暂时未能识别出有效的教材信息，请手动输入 ISBN 继续补录。';
        bookCurrentStep.value = 2;
        bookSelectIndex.value = -1;
        bookInfoButtonDisable.value = false;
        return;
      }
    } else if (bookEntity.status == 1) {
      //识别到条形码,但条形码不在库
      if (isAI) {
        buttonTitle.value = "继续";
        knowledgeAddCardShow.value = false;
        recognitionErrorTip.value = 'AI 未能准确识别这本教材，请手动输入 ISBN 继续补录。';
        bookCurrentStep.value = 2;
        bookSelectIndex.value = -1;
        bookInfoButtonDisable.value = false;
        return;
      } else {
        bool? res = await AskDialog.showUserCancelAsk(
          context: Get.context!,
          title: "请确认您输入的ISBN码",
          content: "您输入的号码是：\n\n${isbnController.text}\n\n这个号码是否正确？",
          cancel: "返回修改",
          define: "确认无误",
        );
        if (res == null) return;
        if (!res) {
          return;
        }

        bookIsbnController.text = isbnController.text;
        bookInfoNameInput.text = bookEntity.title ?? '';
        buttonTitle.value = "提交图书信息";
        knowledgeAddCardShow.value = false;
        bookInfoButtonDisable.value = true;
        bookCurrentStep.value = 3;
      }
    } else if (bookEntity.status == 2) {
      //识别到条形码,但条形码在库,但不支持
      bookIsbnController.text = bookEntity.isbn ?? '';
      bookInfoNameInput.text = bookEntity.title ?? '';
      buttonTitle.value = "提交图书信息";
      knowledgeAddCardShow.value = false;
      bookInfoButtonDisable.value = false;
      bookCurrentStep.value = 3;
    } else {
      //识别到条形码,且条形码在库,且支持
      if (bookEntity.status == 4) {
        bookInfoNameInput.text = bookEntity.title ?? '';
        buttonTitle.value = "继续";
        recognitionErrorTip.value = '';
        levelPlacementResolved.value = false;
        bookCurrentStep.value = 2;
        bookInfoButtonDisable.value = false;
        return;
      }
      bookInfoNameInput.text = bookEntity.title ?? '';
      buttonTitle.value = "继续";
      recognitionErrorTip.value = '';
      if (bookEntity.levelMatched == false && !levelPlacementResolved.value) {
        bookCurrentStep.value = 2;
        bookInfoButtonDisable.value = false;
        return;
      }
      bookInfoButtonDisable.value = false;
      bookCurrentStep.value = 3;

      // if (bookEntity.grade != gradeIndex) {
      //   var aim = CommonUtil.grades[(bookEntity.grade??1)-1];
      //   var res = await AskDialog.showUserAsk(context: Get.context!, title: "教材位置校对", content: "识别到该教材为$aim，是否将其从$levelName移动到正确的位置?", cancel: "仍留在$levelName", define: "移动到$aim");
      //   if (res) {
      //     if (courseId == null || bookEntity.grade == null) {
      //       return;
      //     }

      //   }
      // }
    }
  }

  Future<void> _changeCourseLevelToGrade(int grade) async {
    try {
      ToastUtils.showLoading();
      final resp = await CustomizedCoursesRequest.changeCourseLevel(courseId: courseId!, tier: grade);
      if (resp == null) {
        ToastUtils.showToast(text: "移动失败");
        return;
      } else {
        levelId = resp.uid;
        ToastUtils.showToast(text: '移动成功', type: ToastType.success);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 知识点卡片按钮是否禁用
  void getKnowledgeCardButtonFlag() {
    if (knowledgeCurrentStep.value == 2) {
      knowledgeButtonDisable.value = false;
      return;
    }
    knowledgeButtonDisable.value = knowledgeSelectIndex.value == -1;
  }

  /// 选择添加知识点方式
  void selectAddKnowledgeMethod(int index) {
    knowledgeSelectIndex.value = index;
    getKnowledgeCardButtonFlag();
  }

  void backToKnowledgeMethodSelection() {
    knowledgeCurrentStep.value = 1;
    getKnowledgeCardButtonFlag();
  }

  /// 知识点卡片继续按钮
  Future<void> knowledgeContinue(BuildContext context) async {
    print('djiajf1');
    if (knowledgeCurrentStep.value == 1) {
      print('djiajf2');
      await reuseVocabularyKnowledge();
      return;
    }
    print('djiajf3');
    final PackageShopDetailEntity? packageShopDetail = knowledgePackageShopDetail.value;
    print('djiajf4');
    if (packageShopDetail == null) return;
    print('djiajf5');
    if (isKnowledgeCoinEnough) {
      await pay(context, packageShopDetail);
      return;
    }
    print('djiajf6');
    final bool isPwdRight = await ParentPasswordialog.show(context: Get.context!);
    if (!isPwdRight) return;
    print('djiajf17');
    await TagRoutes.toNamed(Routes.RECHARGE_NAIBI);
    await reuseVocabularyKnowledge();
  }

  /// 获取状态
  Future<void> reuseVocabularyKnowledge() async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.userCustomLoadProductInfo)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.servicePackageShoppingDetail)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }

    try {
      ToastUtils.showLoading();
      CustomCourseOrderIdsEntity? vocabularyInfo = await CustomizedCoursesRequest.getOrderIds();
      if (vocabularyInfo == null || levelId == null) return;

      // 获取套餐详情
      Map<String, dynamic> packReqData = {
        "servicePackageId": vocabularyInfo.servicePackageId,
        "servicePackageVersion": vocabularyInfo.servicePackageVersion,
        "defaultCoupon": false,
      };
      PackageShopDetailEntity? packageShopDetail = await PayRequest.getPackageShopDetail(packReqData);
      if (packageShopDetail == null) return;
      knowledgePackageShopDetail.value = packageShopDetail;
      knowledgeCurrentStep.value = 2;
      getKnowledgeCardButtonFlag();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  int get knowledgeUserPoints => knowledgePackageShopDetail.value?.userPoints ?? 0;

  int get knowledgeOrderPoints => knowledgePackageShopDetail.value?.orderPoints ?? 0;

  int get knowledgeRequiredPoints {
    final PackageShopDetailEntity? detail = knowledgePackageShopDetail.value;
    if (detail == null) return 0;
    if ((detail.orderPoints ?? 0) > 0) {
      return detail.orderPoints!;
    }
    return detail.servicePackage?.price ?? detail.servicePackage?.priceOriginal ?? detail.servicePackage?.originalPrice ?? 0;
  }

  int get knowledgeRemainingPoints => knowledgeUserPoints - knowledgeRequiredPoints;

  int get knowledgeUserCredit => knowledgePackageShopDetail.value?.userCredit ?? 0;

  int get knowledgeOrderCredit => knowledgePackageShopDetail.value?.orderCredit ?? 0;

  int get knowledgeRechargeCredit => knowledgePackageShopDetail.value?.rechargeCredit ?? 0;

  int get knowledgeRemainingCredit => knowledgeUserCredit - knowledgeOrderCredit;

  bool get isKnowledgePointsEnough => knowledgeRequiredPoints > 0 && knowledgeRemainingPoints >= 0;

  bool get isKnowledgeCoinEnough => knowledgePackageShopDetail.value?.isAffordable ?? false;

  bool get shouldShowKnowledgeCoinSection => !isKnowledgePointsEnough;

  /// 支付
  Future<void> pay(BuildContext context, PackageShopDetailEntity packageShopDetail) async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.userCustomCreateCourseModule)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }
    const bool shouldShowLoading = true;
    bool didHideLoading = false;
    try {
      if (shouldShowLoading) {
        ToastUtils.showLoading();
      }

      int operation = knowledgeSelectIndex.value == 0 ? 1 : 2;

      Map<String, dynamic> reqData = {
        "courseId": courseId,
        "levelId": levelId,
        "moduleId": moduleId,
        "operation": operation,
        "module": {
          "bookId": bookEntity.uid,
          "language": languageCode.value,
          "difficulty": bookEntity.difficulty,
          "title": bookInfoNameInput.text,
          "cover": frontCoverKey.value,
          "isbn": bookEntity.isbn,
        },
        "orderPay": {
          "servicePackageId": packageShopDetail.servicePackage?.servicePackageId,
          "servicePackageVersion": packageShopDetail.servicePackage?.servicePackageVersion,
          "payMethod": packageShopDetail.servicePackage?.payMethod?.toLowerCase(),
        },
      };
      final CustomizedCoursesCreateEntity? createRes = await CustomizedCoursesRequest.createCourse(reqData);
      if (createRes == null) {
        final officialCourseDetailsController = TagRoutes.findLast<OfficialCourseDetailsController>(Routes.OFFICIAL_COURSE_DETAILS);
        if (officialCourseDetailsController != null) {
          await officialCourseDetailsController.getModuleList(isLoading: false);
        }
        return;
      }
      OfficialCourseDetailsLevelController.invalidateCache(courseId: createRes.courseId);
      // 创建和支付成功
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().initHomeCardList();
      }

      knowledgeCurrentStep.value = 1;
      knowledgePackageShopDetail.value = null;

      //第二条路支付成功,更换卡片位为扫描单词
      if (knowledgeSelectIndex.value == 1) {
        if (shouldShowLoading) {
          ToastUtils.hideLoading();
          didHideLoading = true;
        }
        knowledgeAddCardShow.value = false;
        scanTipCardShow.value = true;
        courseId = createRes.courseId;
        levelId = createRes.levelId;
        moduleId = createRes.moduleId;
        return;
      } else {
        if (shouldShowLoading) {
          ToastUtils.hideLoading();
          didHideLoading = true;
        }
        await _enterCourseGenerationStep(createRes);
      }
    } finally {
      if (shouldShowLoading && !didHideLoading) {
        ToastUtils.hideLoading();
      }
    }
  }

  Future<void> _enterCourseGenerationStep(CustomizedCoursesCreateEntity createRes) async {
    courseId = createRes.courseId;
    levelId = createRes.levelId;
    moduleId = createRes.moduleId;
    generationTaskId = createRes.taskId;
    generationRunType.value = 0;
    generationRunList.clear();
    generationStatus.value = CourseGenerateStatusResponseEntity();
    courseGenerationCardShow.value = true;
    stepSetting();
    await WidgetsBinding.instance.endOfFrame;
    if (pageController.hasClients) {
      await pageViewNext();
    }
    await getGenerationStatus();
  }

  Future<void> getGenerationStatus() async {
    if (_generationDisposed || generationTaskId == null) return;
    final CourseGenerateStatusResponseEntity? responseEntity =
        await CustomizedCoursesRequest.getAiProcessStatus({"taskId": generationTaskId});
    if (_generationDisposed) return;
    if (responseEntity == null) {
      generationRunList
        ..clear()
        ..add(AiAnimationRunModel(
          name: "课程模块框架构建",
          subName: "处理中",
          error: true,
        ));
      generationRunType.value = 2;
      generationRunList.refresh();
      return;
    }

    generationStatus.value = responseEntity;
    generationRunList.value = [
      AiAnimationRunModel(
        name: responseEntity.moduleFramework?.stepName ?? "",
        step: responseEntity.moduleFramework?.step,
        subName: responseEntity.moduleFramework?.statusDescription,
        value: responseEntity.moduleFramework?.statisticsInfo,
        cnt: responseEntity.moduleFramework?.cnt,
        dataCompleted: responseEntity.moduleFramework?.completed ?? false,
        error: responseEntity.moduleFramework?.isFailed ?? false,
      ),
      AiAnimationRunModel(
        name: responseEntity.unitPlan?.stepName ?? "",
        step: responseEntity.unitPlan?.step,
        subName: responseEntity.unitPlan?.statusDescription,
        value: responseEntity.unitPlan?.statisticsInfo,
        cnt: responseEntity.unitPlan?.cnt,
        dataCompleted: responseEntity.unitPlan?.completed ?? false,
        error: responseEntity.unitPlan?.isFailed ?? false,
      ),
      AiAnimationRunModel(
        name: responseEntity.sentenceGeneration?.stepName ?? "",
        step: responseEntity.sentenceGeneration?.step,
        subName: responseEntity.sentenceGeneration?.statusDescription,
        value: responseEntity.sentenceGeneration?.statisticsInfo,
        cnt: responseEntity.sentenceGeneration?.cnt,
        dataCompleted: responseEntity.sentenceGeneration?.completed ?? false,
        error: responseEntity.sentenceGeneration?.isFailed ?? false,
      ),
      AiAnimationRunModel(
        name: responseEntity.lessonGeneration?.stepName ?? "",
        step: responseEntity.lessonGeneration?.step,
        subName: responseEntity.lessonGeneration?.statusDescription,
        value: responseEntity.lessonGeneration?.statisticsInfo,
        cnt: responseEntity.lessonGeneration?.cnt,
        dataCompleted: responseEntity.lessonGeneration?.completed ?? false,
        error: responseEntity.lessonGeneration?.isFailed ?? false,
      ),
      AiAnimationRunModel(
        name: responseEntity.contentGeneration?.stepName ?? "",
        step: responseEntity.contentGeneration?.step,
        subName: responseEntity.contentGeneration?.statusDescription,
        value: responseEntity.contentGeneration?.statisticsInfo,
        cnt: responseEntity.contentGeneration?.cnt,
        dataCompleted: responseEntity.contentGeneration?.completed ?? false,
        error: responseEntity.contentGeneration?.isFailed ?? false,
      ),
    ];
    generationRunType.value = 0;
    await _runGenerationAnimation();
  }

  void _pollGenerationStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    if (_generationDisposed) return;
    await getGenerationStatus();
  }

  Future<void> _runGenerationAnimation() async {
    for (int i = 0; i < generationRunList.length; i++) {
      if (_generationDisposed) return;
      generationRunList[i].show = true;

      if (generationRunList[i].error) {
        generationRunType.value = 2;
        generationRunList[i].subName = "处理失败";
        generationRunList[i].isCompleted = true;
        generationRunList.refresh();
        return;
      }

      if ((generationStatus.value.notDisplayed?.length ?? 0) > i) {
        generationRunList[i].isCompleted = true;
        generationRunList[i].showProgress = false;
        generationRunList.refresh();
        continue;
      }

      if (!generationRunList[i].showProgress) {
        generationRunList[i].isCompleted = true;
        generationRunList.refresh();
        continue;
      }

      await Future.delayed(const Duration(milliseconds: 500));
      if (_generationDisposed) return;

      if (!generationRunList[i].dataCompleted) {
        if (generationStatus.value.generateStatus == 1) {
          _pollGenerationStatus();
        }
        return;
      }

      for (int j = 0; j <= 10; j++) {
        final int randomDuration = Random().nextInt(10) + 100;
        await Future.delayed(Duration(milliseconds: randomDuration));
        if (_generationDisposed) return;
        generationRunList[i].process = j * 10;
        generationRunList.refresh();
      }

      await Future.delayed(const Duration(milliseconds: 200));
      if (_generationDisposed) return;
      generationRunList[i].isCompleted = true;
      generationRunList.refresh();

      if (i + 1 < generationRunList.length) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (_generationDisposed) return;
        generationRunList[i + 1].show = true;
        generationRunList.refresh();
      }
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    if (_generationDisposed) return;
    generationRunType.value = 1;
  }

  Future<void> retryGenerateCourse() async {
    generationRunType.value = 0;
    generationRunList.clear();
    if (courseId == null) {
      await getGenerationStatus();
      return;
    }
    final bool res = await CustomizedCoursesRequest.reGenerateCourse({"courseId": courseId});
    if (!res) return;
    await getGenerationStatus();
  }

  Future<void> contactCustomerService(BuildContext context) async {
    await CustomerServiceDialog.reportCustomer(context);
  }

  Future<void> confirmGenerationAndGoLearn() async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.userCustomConfirmCourseFinish)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }

    if (generationTaskId == null) return;
    bool didHideLoading = false;
    try {
      ToastUtils.showLoading();
      final bool isSuccess = await CustomizedCoursesRequest.customConfirm({"taskId": generationTaskId});
      if (!isSuccess) return;
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().initHomeCardList();
      }
      final detailsController = TagRoutes.findLast<OfficialCourseDetailsController>(Routes.OFFICIAL_COURSE_DETAILS);
      final int currentFromType = fromType ?? 0;
      if (currentFromType == 4) {
        Get.back(result: true);
        return;
      }
      if (courseId == null && detailsController != null) {
        await detailsController.getModuleList(isLoading: false, isFirst: true);
        Get.back(result: true);
        return;
      }
      if (courseId != null) {
        final int targetCourseId = courseId!;
        int? targetLevelId = levelId;
        int? targetModuleId = moduleId;
        if (targetModuleId == null || targetModuleId <= 0) {
          if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseCurrentStatus)) {
            return;
          }
          final CustomCourseStatusEntity? status = await OfficialCourseDetailsRequest.getCustomCourseStatus({
            "courseId": targetCourseId,
          });
          targetModuleId = status?.currentModule?.uid;
        }
        if (detailsController != null) {
          ToastUtils.hideLoading();
          didHideLoading = true;
          await detailsController.switchToCourse(
            courseId: targetCourseId,
            levelId: targetLevelId,
            moduleId: targetModuleId,
            isLoading: false,
          );
          Get.until((route) => route.settings.name == Routes.OFFICIAL_COURSE_DETAILS);
          return;
        }
        if (currentFromType == 0 || currentFromType == 1) {
          ToastUtils.hideLoading();
          didHideLoading = true;
          await TagRoutes.offNamed(
            Routes.OFFICIAL_COURSE_DETAILS,
            arguments: {
              "courseId": targetCourseId,
              "levelId": targetLevelId,
              "moduleId": targetModuleId,
              "isSwitchCourse": true,
              "goCustomCourseProgress": false,
            },
          );
          return;
        }
      }
      Get.back(result: true);
    } finally {
      if (!didHideLoading) {
        ToastUtils.hideLoading();
      }
    }
  }

  /// 扫描单词
  void scanWord(BuildContext context) async {
    bool isCameraPermission = await PermissionUtils.camera(context);
    if (!isCameraPermission) {
      return;
    }

    Map<String, dynamic> params = {
      "courseId": courseId,
      "levelId": levelId,
      "moduleId": moduleId,
      'fromCourseDetailPage': false,
    };

    if (Platform.isMacOS) {
      String? deviceId = await CameraMacOSCustomCurseDialog.show(
        context: Get.context!,
      );
      params["deviceId"] = deviceId;
    } else if (Platform.isWindows) {
      CameraDescription? cameraDescription = await CameraWindowsCustomCurseDialog.show(
        context: Get.context!,
      );
      params["cameraDescription"] = cameraDescription;
    }
    await TagRoutes.toNamed(
      Routes.CUSTOM_COURSE_SHOOT_WORDS,
      arguments: params,
    );
  }

  ///获取位置
  Future<void> getCurrentLocation(BuildContext context) async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.resourceGecodeCity)) return;
    //只请求一次位置
    if (locationRequested.value) return;
    locationRequested.value = true;

    bool isLocationPermission = await PermissionUtils.location(context);
    if (!isLocationPermission) return;

    // 获取当前经纬度
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.lowest,
      ),
    );

    //根据经纬度获取城市编码
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "longitude": position.longitude,
        "latitude": position.latitude,
      };
      LocationResponseEntity? cityCode = await CustomizedCoursesRequest.getCityCode(reqData);
      if (cityCode == null) return;
      initDistrictCode.value = cityCode.addressCode;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void showSampleCover() {
    SampleCoverDialog.show(context: Get.context!);
  }

  /// 帮助与客服
  Future<void> customerService(BuildContext context) async {
    await CustomerServiceDialog.reportCustomer(context);
  }

  @override
  void onClose() {
    _generationDisposed = true;
    super.onClose();
  }
}

class AiAnimationRunModel {
  String name;
  String? step;
  String? subName;
  String? value;
  int? cnt;
  bool isCompleted = false;
  bool error = false;
  int process = 0;
  bool show = false;
  bool showProgress;
  bool dataCompleted;

  AiAnimationRunModel({
    required this.name,
    this.step,
    this.subName,
    this.value,
    this.cnt,
    this.error = false,
    this.showProgress = true,
    this.dataCompleted = true,
  });
}
