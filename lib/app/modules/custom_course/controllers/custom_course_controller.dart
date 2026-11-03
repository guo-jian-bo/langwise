import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/custom_course/views/sample_cover_dialog.dart';
import 'package:langwise/app/modules/home/controllers/home_controller.dart';
import 'package:langwise/app/modules/official_course_details/controllers/official_course_details_controller.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/custom_course_book_entity.dart';
import 'package:langwise/common/entities/custom_course_knowledge_info_entity.dart';
import 'package:langwise/common/entities/custom_course_order_ids_entity.dart';
import 'package:langwise/common/entities/customized_courses_create_entity.dart';
import 'package:langwise/common/entities/customized_courses_info_entity.dart';
import 'package:langwise/common/entities/customized_courses_steps_entity.dart';
import 'package:langwise/common/entities/location.dart';
import 'package:langwise/common/entities/package_shop_detail_entity.dart';
import 'package:langwise/common/https/customized_courses.dart';
import 'package:langwise/common/https/pay.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/common/widgets/camera_macos_custom_curse_dialog.dart';
import 'package:langwise/common/widgets/camera_windows_custom_curse_dialog.dart';
import 'package:langwise/common/widgets/confirm_order_widget.dart';
import 'package:langwise/common/widgets/parent_password_dialog.dart';
import 'package:langwise/common/widgets/qrcode_dialog.dart';
import 'package:langwise/common/widgets/step_progress_widget.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../views/custom_course_choose_book_dialog.dart';

class CustomCourseController extends GetxController {
  //传进来的参数
  int? courseId;
  int? levelId;
  int? moduleId;
  //是否从管理界面进来的
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

  // 扫描书籍次数
  final RxInt scanTimes = 0.obs;

  // 手动扫描需要的时长
  final RxString manualScanTime = "30-60分钟".obs;

  /// 扫描提示卡片是否显示
  final RxBool scanTipCardShow = false.obs;

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
    if (Get.arguments != null) {
      courseId = Get.arguments['courseId'];
      levelId = Get.arguments['levelId'];
      moduleId = Get.arguments['moduleId'];
      fromType = Get.arguments['fromType']; //4 从计划来
      cefr.value = Get.arguments['cefr'] ?? '';
      gradeIndex = Get.arguments['gradeIndex'] ?? 0;
      levelName.value = Get.arguments['levelName'] ?? '';
    }

    initServiceData();
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
    );
    if (!askRes) return;
    Get.back();
  }

  /// 封面-拍照
  Future<void> selectFrontCover(BuildContext context) async {
    File? file = await ImagePickerUtils.courseTakePhoto(context: context, cropAspectRatio: 3 / 4, isCoursesBook: true, isCoursesBookFront: true);
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
    File? file = await ImagePickerUtils.coursePickImage(context: context, cropAspectRatio: 3 / 4, isCoursesBook: true);
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

  /// 封底-拍照
  Future<void> selectBackCover(BuildContext context) async {
    File? file = await ImagePickerUtils.courseTakePhoto(context: context, cropAspectRatio: 3 / 4, isCoursesBook: true, isCoursesBookFront: false);
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
    File? file = await ImagePickerUtils.coursePickImage(context: context, cropAspectRatio: 3 / 4, isCoursesBook: true);
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
      bookCurrentStep.value = 2;
      bookSelectIndex.value = 0;
      bookInfoButtonDisable.value = false;
    } else if (bookCurrentStep.value == 2) {
      if (bookSelectIndex.value == 0) {
        matchBookInfoWithAI();
      } else {
        matchBookInfoWithISBN();
      }
    } else if (bookCurrentStep.value == 3) {
      if (bookEntity.status == 3) {
        try {
          ToastUtils.showLoading();
          if (knowledgeInfo == null) {
            getBookScanCount();
          }

          knowledgeAddCardShow.value = true;
          pageViewNext();
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

      Map<String, dynamic> reqData = {
        "isbn": bookEntity.isbn,
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
    int? isbn = int.tryParse(isbnController.text);
    if (isbn == null) {
      ToastUtils.showManageToast(text: '请输入正确的ISBN码', type: ManageToastType.error);
      return;
    }

    try {
      ToastUtils.showLoading();

      CustomCourseBookListEntity? bookList = await CustomizedCoursesRequest.getBookInfoWithISBN(isbn);
      if (bookList == null) return;
      dealBookListEntity(bookList, false);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// ai匹配教材信息
  Future<void> matchBookInfoWithAI() async {
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "frontCover": frontCoverKey.value,
        "backCover": backCoverKey.value,
        "addressCode": initDistrictCode.value,
      };
      CustomCourseBookListEntity? bookList = await CustomizedCoursesRequest.getBookInfoWithAI(reqData);
      dealBookListEntity(bookList!, true);
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
        if (Get.context == null) return;
        buttonTitle.value = "继续";
        knowledgeAddCardShow.value = false;

        bool? res = await AskDialog.showUserCancelAsk(
          context: Get.context!,
          title: "ISBN码格式错误",
          content: "ISBN码格式错误，是否返回选择手动输入？",
          cancel: "重新添加教材",
          define: "去手动输入",
        );
        if (res == null) return;
        if (res) {
          bookSelectIndex.value = 1;
          if (isbnController.text.length == 13) {
            bookInfoButtonDisable.value = false;
          } else {
            bookInfoButtonDisable.value = true;
          }
          return;
        } else {
          bookCurrentStep.value = 1;
          bookSelectIndex.value = -1;
          return;
        }
      }
    } else if (bookEntity.status == 1) {
      //识别到条形码,但条形码不在库
      if (isAI) {
        if (Get.context == null) return;
        buttonTitle.value = "继续";
        knowledgeAddCardShow.value = false;

        bool? res = await AskDialog.showUserCancelAsk(
          context: Get.context!,
          title: "ISBN码格式错误",
          content: "ISBN码格式错误，是否返回选择手动输入？",
          cancel: "退出添加教材",
          define: "去手动输入",
        );
        if (res == null) return;
        if (res) {
          bookSelectIndex.value = 1;
          if (isbnController.text.length == 13) {
            bookInfoButtonDisable.value = false;
          } else {
            bookInfoButtonDisable.value = true;
          }
          return;
        } else {
          bookCurrentStep.value = 1;
          bookSelectIndex.value = -1;
          return;
        }
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
      bookCurrentStep.value = 3;
    } else {
      //识别到条形码,且条形码在库,且支持
      if (bookEntity.status == 4) {
        var res = await AskDialog.showUserAsk(context: Get.context!, title: bookEntity.tip, content: '', cancel: "仍要添加", define: "取消添加");
        if (!res) {
          bookEntity.status = 3;
        } else {
          bookCurrentStep.value = 2;
          bookSelectIndex.value = -1;
          bookInfoButtonDisable.value = true;
          return;
        }
      }
      bookInfoNameInput.text = bookEntity.title ?? '';
      buttonTitle.value = "继续";
      bookCurrentStep.value = 3;
      if (bookEntity.grade != gradeIndex) {
        var aim = CommonUtil.grades[(bookEntity.grade??1)-1];
        var res = await AskDialog.showUserAsk(context: Get.context!, title: "教材位置校对", content: "识别到该教材为$aim，是否将其从$levelName移动到正确的位置?", cancel: "仍留在$levelName", define: "移动到$aim");
        if (res) {
          if (courseId == null || bookEntity.grade == null) {
            return;
          }
          _changeCourseLevelToGrade(bookEntity.grade!);
        }
      }
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
    knowledgeButtonDisable.value = knowledgeSelectIndex.value == -1;
  }

  /// 选择添加知识点方式
  void selectAddKnowledgeMethod(int index) {
    knowledgeSelectIndex.value = index;
    getKnowledgeCardButtonFlag();
  }

  /// 知识点卡片继续按钮
  Future<void> knowledgeContinue(BuildContext context) async {
    reuseVocabularyKnowledge(context);
  }

  /// 获取状态
  Future<void> reuseVocabularyKnowledge(BuildContext context) async {
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

      ConfirmOrderWidgetManager.showC(
        context: context,
        packageShopDetailEntity: packageShopDetail,
        onOk: () {
          pay(context, packageShopDetail);
        },
        onRecharge: () async {
          final bool isPwdRight = await ParentPasswordialog.show(context: Get.context!);
          if (!isPwdRight) return;

          /// 跳转至充值乃币页面
          await Get.toNamed(Routes.RECHARGE_NAIBI);
        },
      );
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 支付
  Future<void> pay(BuildContext context, PackageShopDetailEntity packageShopDetail) async {
    try {
      ToastUtils.showLoading();

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
        if (Get.isRegistered<OfficialCourseDetailsController>()) {
          Get.find<OfficialCourseDetailsController>().getModuleList(isLoading: false);
        }
        return;
      }
      // 创建和支付成功
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().initHomeCardList();
      }

      //第二条路支付成功,更换卡片位为扫描单词
      if (knowledgeSelectIndex.value == 1) {
        knowledgeAddCardShow.value = false;
        scanTipCardShow.value = true;
        courseId = createRes.courseId;
        levelId = createRes.levelId;
        moduleId = createRes.moduleId;
        return;
      } else {
        //第一条路支付成功

        if (Get.isRegistered<OfficialCourseDetailsController>()) {
          OfficialCourseDetailsController officialCourseDetailsController = Get.find<OfficialCourseDetailsController>();
          await officialCourseDetailsController.getModuleList(isPlan: true, isLoading: false);
          if (fromType == 4) {
            Get.offNamed(
              Routes.OFFICIAL_COURSE_DETAILS,
              arguments: {
                "courseId": courseId,
                "levelId": levelId,
                "moduleId": moduleId,
                "isSwitchCourse": false,
                "fromType": fromType,
                "goCustomCourseProgress": true,
              },
            );
          } else {
            Get.offNamedUntil(
              Routes.OFFICIAL_COURSE_DETAILS,
              ModalRoute.withName(Routes.APPLICATION),
              arguments: {
                "courseId": courseId,
                "levelId": levelId,
                "moduleId": moduleId,
                "isSwitchCourse": false,
                "fromType": fromType,
                "goCustomCourseProgress": true,
              },
            );
          }
        } else {
          if (fromType == 4) {
            Get.offNamed(
              Routes.OFFICIAL_COURSE_DETAILS,
              arguments: {
                "courseId": courseId,
                "levelId": levelId,
                "moduleId": moduleId,
                "fromType": fromType,
                "goCustomCourseProgress": true,
              },
            );
          } else {
            Get.offNamedUntil(
              Routes.OFFICIAL_COURSE_DETAILS,
              ModalRoute.withName(Routes.APPLICATION),
              arguments: {
                "courseId": courseId,
                "levelId": levelId,
                "moduleId": moduleId,
                "goCustomCourseProgress": true,
              },
            );
          }
        }
      }
    } finally {
      ToastUtils.hideLoading();
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
    Get.toNamed(
      Routes.CUSTOM_COURSE_SHOOT_WORDS,
      arguments: params,
    );
  }

  ///获取位置
  Future<void> getCurrentLocation(BuildContext context) async {
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
    await QrCodeDialog.reportCustomer(context);
  }
}
