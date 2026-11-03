import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/home/controllers/home_controller.dart';
import 'package:langwise/common/entities/custom_course_book_entity.dart';
import 'package:langwise/common/entities/location.dart';
import 'package:langwise/common/widgets/camera_macos_custom_curse_dialog.dart';
import 'package:langwise/common/widgets/camera_windows_custom_curse_dialog.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../../routes/routes.dart';
import '../../../routes/routes_breadcrumb_utils.dart';
import '../../../routes/tag_routes.dart';
import '../../official_course_details/controllers/official_course_details_controller.dart';

class CustomizedCoursesController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  CustomizedCoursesController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.CUSTOMIZED_COURSES;

  @override
  String get breadcrumbTitle => '自建课程';

  // 传进来的参数
  int? courseId;
  int? levelId;
  int? moduleId;

  /// 0=首页进来的(可以不用传)，1=课程详情进来的(新增等级)，2=课程详情/等级列表进来的(新增模块)
  int pageType = 0;

  final RxList<StepProgressData> steps = <StepProgressData>[
    StepProgressData(
      step: 1,
      name: "课程创建",
      current: true,
    ),
    StepProgressData(
      step: 2,
      name: "年级添加",
    ),
    StepProgressData(
      step: 3,
      name: "教材添加",
    ),
    StepProgressData(
      step: 4,
      name: "知识点添加",
    ),
    StepProgressData(
      step: 5,
      name: "知识点校对",
    ),
    StepProgressData(
      step: 6,
      name: "课程生成",
    ),
  ].obs;

  late final PageController pageController;
  final RxBool isInitPageController = false.obs;
  final RxDouble currentPageIndex = 0.0.obs;

  // --------------- 课程名称卡片 --------------------
  /// 课程名称
  final TextEditingController courseNameInput = TextEditingController();

  /// 请填写书籍作用
  final TextEditingController courseDescribeInput = TextEditingController();

  /// 语言
  final RxString languageCode = "en".obs;

  /// 课程封面
  final RxString courseCoverFileUrl = ''.obs;
  final RxString courseCoverNetWorkUrl = ''.obs;
  final RxString courseCoverKey = ''.obs;

  /// 按钮
  final RxBool courseButtonDisable = true.obs;

  // --------------- 等级卡片 --------------------
  /// 等级卡片是否显示
  final RxBool levelCardShow = false.obs;

  /// 等级
  final TextEditingController levelNameInput = TextEditingController();

  /// 按钮
  final RxBool levelButtonDisable = true.obs;

  // ---------------- 扫描ISBN卡片 --------------------
  /// 扫描ISBN卡片是否显示
  final RxBool scanISBNCardShow = false.obs;

  /// 按钮
  final RxBool scanISBNButtonDisable = true.obs;

  /// ISBN
  final TextEditingController scanBookISBNInput = TextEditingController();

  // ------------------ 课程信息卡片 ------------------
  /// 课程信息
  final RxBool courseInfoCardShow = false.obs;

  /// 按钮
  final RxBool bookInfoButtonDisable = true.obs;

  /// isbns书籍信息
  //BookResponseEntity? isbnInfo;

  /// 书籍名称
  final TextEditingController bookInfoNameInput = TextEditingController();

  /// 难度水平数据
  final RxList<DifficultieEntity> difficultyList = <DifficultieEntity>[].obs;

  /// 难度水平选择的下标
  final RxInt selectDifficultyIndex = 0.obs;

  /// 书籍封面
  //final RxString bookCoverFileUrl = ''.obs;
  //final RxString bookCoverNetWorkUrl = ''.obs;
  //final RxString bookCoverKey = ''.obs;

  // ------------------- 添加知识点卡片 -------------------
  /// 添加知识点
  final RxBool knowledgeAddCardShow = false.obs;

  /// 按钮
  final RxBool knowledgeButtonDisable = true.obs;

  /// 知识点info 扫描次数 和 大概完成时间
  CustomCourseKnowledgeInfoEntity? knowledgeInfo;

  /// 选择方式下标
  final RxInt knowledgeSelectIndex = (-1).obs;

  /// 扫描书籍次数
  final RxInt scanTimes = 0.obs;

  /// 手动扫描需要的时长
  final RxString manualScanTime = "30-60分钟".obs;

  ///封面、封底
  final RxString frontCover = "".obs;
  final RxString backCover = "".obs;
  final RxString coverKey = ''.obs;
  final RxString backCoverKey = ''.obs;
  final RxString frontCoverNetWorkUrl = ''.obs;
  final RxString backCoverNetWorkUrl = ''.obs;

  /// 封面和封底是否都上传完成
  final RxBool coverAllUploaded = false.obs;

  ///封底条形码识别结果model
  CustomCourseBookEntity? bookEntity;

  //封底条形码识别结果是否提示
  final RxString recognitionErrorTip = ''.obs;

  /// 位置城市编码
  final RxBool locationRequested = false.obs;
  final RxString initDistrictCode = "".obs;

  //服务端已储存的课程等级列表数组
  final RxList<CourseLevelEntityLevelList?> levleList =
      <CourseLevelEntityLevelList>[].obs;
  final RxBool levleRequested = false.obs;

  //添加教材的按钮标题
  final RxString buttonTitle = "继续".obs;

  final ScrollController addBookScrollController = ScrollController();

  /// 扫描提示卡片是否显示
  final RxBool scanTipCardShow = false.obs;

  //书籍识别的各种情况0：未识别，1：识别成功，2：识别在库不支持 3识别不在库 4未识别出isbn码
  final RxInt bookIdentifyStatus = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);

    if (Get.arguments != null) {
      courseId = Get.arguments['courseId'];
      levelId = Get.arguments['levelId'];
      moduleId = Get.arguments['moduleId'];
      pageType = Get.arguments['pageType'] ?? 0;
    }

    initServiceData();

    initDifficultyList();
    // initPageController();
  }

  ///将页面切换为横屏
  void changeOrientation() async {
    //await OrientationControlUtil.forceLandscape();
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
      LocationResponseEntity? cityCode =
          await CustomizedCoursesRequest.getCityCode(reqData);
      if (cityCode == null) return;
      initDistrictCode.value = cityCode.addressCode;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 选择封面
  Future<void> selectFrontCover(BuildContext context) async {
    File? file = await ImagePickerUtils.selectPicture(
      context: context,
      title: "上传教材封面",
      cropAspectRatio: 3 / 4,
      isCoursesBook: true,
      isCoursesBookFront: true,
    );
    if (file == null) return;
    frontCover.value = file.path;
    uploadCover(true);
  }

  /// 选择封底
  Future<void> selectBackCover(BuildContext context) async {
    File? file = await ImagePickerUtils.selectPicture(
      compress: false,
      context: context,
      title: "上传教材封底",
      cropAspectRatio: 3 / 4,
      isCoursesBook: true,
      isCoursesBookFront: false,
    );
    if (file == null) return;
    backCover.value = file.path;
    uploadCover(false);
  }

  /// 上传封面
  void uploadCover(bool isFront) async {
    if (isFront) {
      // 上传封面至服务器
      final record = await OssUploadFileUtils.uploadUserFile(filePath: frontCover.value);
      if (record?.key == null) return;
      coverKey.value = record!.key!;

      //如果更换封面，则不进行再次服务端效验教材
      if (coverAllUploaded.value) {
        return;
      }
    } else {
      // 上传封底至服务器
      final record = await OssUploadFileUtils.uploadUserFile(filePath: backCover.value);
      if (record?.key == null) return;
      backCoverKey.value = record!.key!;
    }
    checkCoverIsUploaded();
  }

  /// 检查封面和封底是否上传完成
  void checkCoverIsUploaded() async {
    if (coverKey.value.isEmpty || backCoverKey.value.isEmpty) return;
    coverAllUploaded.value = true;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "frontCover": coverKey.value,
        "backCover": backCoverKey.value,
        "addressCode": initDistrictCode.value,
      };
      CustomCourseBookListEntity? isbn =
          await CustomizedCoursesRequest.getBookInfoWithAI(reqData);
      if (isbn == null) return;
      bookEntity = isbn.list?.first;
      if (bookEntity?.status == 0) {
        //未识别到条形码
        if (Get.context == null) return;
        buttonTitle.value = "继续";
        recognitionErrorTip.value = bookEntity?.tip ?? '';
        knowledgeAddCardShow.value = false;
        stepSetting();

        scanBookISBNInput.text = '';
        bookInfoNameInput.text = '';

        bool askRes = await AskDialog.showUserAsk(
          context: Get.context!,
          title: "书籍识别失败",
          content: "请重新拍摄",
          define: "去重拍",
        );
        if (!askRes) {
          Get.back();
          return;
        } else {
          return;
        }
      } else if (bookEntity?.status == 1) {
        //识别到条形码,但条形码不在库
        knowledgeAddCardShow.value = false;
        stepSetting();
        recognitionErrorTip.value = bookEntity?.tip ?? '';
        buttonTitle.value = "提交反馈";
        scanBookISBNInput.text = bookEntity?.isbn ?? '';
        bookInfoNameInput.text = bookEntity?.title ?? '';
      } else if (bookEntity?.status == 2) {
        //识别到条形码,但条形码在库,但不支持
        knowledgeAddCardShow.value = false;
        stepSetting();
        recognitionErrorTip.value = bookEntity?.tip ?? '';
        buttonTitle.value = "提交反馈";

        scanBookISBNInput.text = bookEntity?.isbn ?? '';
        bookInfoNameInput.text = bookEntity?.title ?? '';
        if (bookEntity?.difficulty != null) {
          for (int i = 0; i < difficultyList.length; i++) {
            if (difficultyList[i].level == bookEntity?.difficulty) {
              selectDifficultyIndex.value = i;
            }
          }
        }
      } else if (bookEntity?.status == 3) {
        //识别到条形码,且条形码在库,且支持
        recognitionErrorTip.value = '';
        buttonTitle.value = "继续";

        scanBookISBNInput.text = bookEntity?.isbn ?? '';
        bookInfoNameInput.text = bookEntity?.title ?? '';
        if (bookEntity?.difficulty != null) {
          for (int i = 0; i < difficultyList.length; i++) {
            if (difficultyList[i].level == bookEntity?.difficulty) {
              selectDifficultyIndex.value = i;
            }
          }
        }
      }

      addBookScrollController.animateTo(
        addBookScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      getCourseInfoCardButtonFlag();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> initServiceData() async {
    try {
      ToastUtils.showLoading();
      await getStepsData();
      // 这里获取课程数据
      await getCourseInfo();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void initDifficultyList() async {
    List<ConfigEntityDifficulties>? difficulties =
        await Get.find<ConfigController>().getDifficultieList();
    if (difficulties == null) return;

    difficultyList.value = difficulties
        .map((e) => DifficultieEntity(
              level: e.level,
              name: DifficultieUtils.getLanguageData(
                  e.languages, languageCode.value),
            ))
        .toList();
  }

  void initPageController() {
    /// 定位到相应的位置
    int initialPage = 0;
    if (pageType == 1) {
      initialPage = 1;
      levelCardShow.value = true;
    } else if (pageType == 2) {
      initialPage = 2;
      levelCardShow.value = true;
      scanISBNCardShow.value = true;
    }
    stepSetting();

    currentPageIndex.value = initialPage.toDouble();
    pageController =
        PageController(viewportFraction: 0.4, initialPage: initialPage);
    pageController.addListener(() {
      currentPageIndex.value = pageController.page ?? 0;
    });
  }

  /// 获取步骤信息
  Future<void> getStepsData() async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.userCustomV2LoadCreateStatus)) return;
    Map<String, dynamic> reqData = {
      "courseId": courseId,
      "levelId": levelId,
      "moduleId": moduleId,
    };
    CustomizedCoursesStepsEntity? stepsEntity =
        await CustomizedCoursesRequest.getStepsData(reqData);
    if (stepsEntity == null) return;
    List<StepProgressData> stepsList = [];
    List<CustomizedCoursesStepsEntityStatuses?> statuses =
        stepsEntity.statuses ?? [];
    for (int i = 0; i < statuses.length; i++) {
      CustomizedCoursesStepsEntityStatuses? status = statuses[i];
      if (status == null) continue;
      List<CustomizedCoursesStepsEntityStatusesItems?> items =
          status.items ?? [];
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
    print(current.step);

    int initialPage = 0;

    if (current.code == StepProgressEnum.COURSE_CREATED ||
        current.code == StepProgressEnum.LEVEL_UN_CREATED) {
      levelCardShow.value = true;
      initialPage = 1;
    }
    if (current.code == StepProgressEnum.LEVEL_CREATED ||
        current.code == StepProgressEnum.MODULE_UN_CREATED) {
      levelCardShow.value = true;
      scanISBNCardShow.value = true;
      initialPage = 2;
    }
    if (current.code == StepProgressEnum.MODULE_CREATED ||
        current.code == StepProgressEnum.KNOWLEDGE_ADDING) {
      levelCardShow.value = true;
      scanISBNCardShow.value = true;
      courseInfoCardShow.value = true;
      knowledgeAddCardShow.value = true;
      initialPage = 4;
    }

    stepSetting();

    getCourseCardButtonFlag();
    getLevelCardButtonFlag();
    getScanISBNButtonFlag();
    getCourseInfoCardButtonFlag();
    getKnowledgeCardButtonFlag();

    currentPageIndex.value = initialPage.toDouble();
    pageController =
        PageController(viewportFraction: 0.4, initialPage: initialPage);
    pageController.addListener(() {
      currentPageIndex.value = pageController.page ?? 0;
    });

    isInitPageController.value = true;
  }

  Future<void> getCourseInfo() async {
    if (courseId == null) return;
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.userCustomLoadCourseLevelModuleInfo)) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "courseId": courseId,
        "levelId": levelId,
        "moduleId": moduleId,
      };
      CustomizedCoursesInfoEntity? responseEntity =
          await CustomizedCoursesRequest.getCourseInfo(reqData);
      if (responseEntity == null) return;
      courseNameInput.text = responseEntity.name ?? '';
      languageCode.value = responseEntity.language ?? '';
      courseCoverNetWorkUrl.value = responseEntity.coverUrl ?? '';
      courseCoverKey.value = responseEntity.cover ?? '';

      getCourseCardButtonFlag();

      List<CustomizedCoursesInfoEntityLevelList?> levelList =
          responseEntity.levelList ?? [];
      CustomizedCoursesInfoEntityLevelList? currentLevel;
      for (int i = 0; i < levelList.length; i++) {
        CustomizedCoursesInfoEntityLevelList? level = levelList[i];
        if (level == null) continue;
        if (level.uid == levelId) {
          levelNameInput.text = level.name ?? '';
          currentLevel = level;
          getLevelCardButtonFlag();
          break;
        }
      }

      if (moduleId != null) {
        List<CustomizedCoursesInfoEntityLevelListModuleList?> moduleList =
            currentLevel?.moduleList ?? [];
        for (int i = 0; i < moduleList.length; i++) {
          CustomizedCoursesInfoEntityLevelListModuleList? module =
              moduleList[i];
          if (module == null) continue;
          if (module.uid == moduleId) {
            scanBookISBNInput.text = module.isbn ?? '';
            bookInfoNameInput.text = module.name ?? '';
            selectDifficultyIndex.value =
                difficultyList.indexWhere((e) => e.level == module.difficulty);
            frontCoverNetWorkUrl.value = module.coverUrl ?? '';
            coverKey.value = module.cover ?? '';
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

  /// pageview下一步
  Future<void> pageViewNext() async {
    stepSetting();
    await pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  /// 设置 当前实际到哪一步
  void stepSetting() {
    int stepIndex = 0;
    if (levelCardShow.value) {
      stepIndex = 1;
    }
    if (scanISBNCardShow.value) {
      stepIndex = 2;
    }
    if (courseInfoCardShow.value) {
      stepIndex = 2;
    }
    if (knowledgeAddCardShow.value) {
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

  /// 判断所有输入
  bool verify(
      {bool level = false,
      bool isbn = false,
      bool book = false,
      bool knowledgeAdd = false}) {
    if (courseNameInput.text.trim().isEmpty) {
      ToastUtils.showToast(text: "请输入课程名称");
      return false;
    }
    if (courseCoverFileUrl.isEmpty && courseCoverNetWorkUrl.isEmpty) {
      ToastUtils.showToast(text: "请选择课程封面");
      return false;
    }
    if (level) {
      if (levelNameInput.text.trim().isEmpty) {
        ToastUtils.showToast(text: "请输入等级名称");
        return false;
      }
    }
    if (isbn) {
      if (scanBookISBNInput.text.trim().isEmpty) {
        ToastUtils.showToast(text: "请扫描或输入书籍ISBN");
        return false;
      }
    }
    if (book) {
      if (bookInfoNameInput.text.trim().isEmpty) {
        ToastUtils.showToast(text: "请输入书籍名称");
        return false;
      }

      if (coverKey.isEmpty && frontCoverNetWorkUrl.isEmpty) {
        ToastUtils.showToast(text: "请选择书籍封面");
        return false;
      }

      if (backCoverKey.isEmpty && backCoverNetWorkUrl.isEmpty) {
        ToastUtils.showToast(text: "请选择书籍封底");
        return false;
      }
    }
    if (knowledgeAdd) {
      if (knowledgeSelectIndex.value == -1) {
        ToastUtils.showToast(text: "请选择添加知识点方式");
        return false;
      }
    }

    return true;
  }

  // -------------------- 课程名称卡片 ---------------------

  /// 选择课程封面
  Future<void> selectCourseCover(BuildContext context) async {
    File? file = await ImagePickerUtils.selectPicture(context: context);
    if (file == null) return;
    courseCoverFileUrl.value = file.path;
    // 清空key 和 网络url 重新选择封面 证明需要修改需要重新上传
    courseCoverKey.value = "";
    courseCoverNetWorkUrl.value = "";
    getCourseCardButtonFlag();
  }

  /// 课程名称卡片按钮是否禁用
  void getCourseCardButtonFlag() {
    courseButtonDisable.value = courseNameInput.text.isEmpty ||
        (courseCoverFileUrl.value.isEmpty &&
            courseCoverNetWorkUrl.value.isEmpty);
  }

  /// 课程名称卡片继续按钮
  Future<void> courseNameContinue(BuildContext context) async {
    if (!verify()) return;
    levelCardShow.value = true;
    pageViewNext();
    return;
  }

  // -------------------- 等级卡片 ---------------------

  /// 等级卡片按钮是否禁用
  void getLevelCardButtonFlag() {
    levelButtonDisable.value = levelNameInput.text.isEmpty;
  }

  /// 等级卡片继续按钮
  Future<void> levelContinue(BuildContext context) async {
    if (!verify(level: true)) return;
    scanISBNCardShow.value = true;

    if (!levleRequested.value && courseId != null) {
      await getLevleListData();
    }

    for (var levle in levleList) {
      if (levle == null) continue;
      if (levle.name == levelNameInput.text.trim()) {
        // 等级已存在, 询问用户是否继续
        bool askRes = await AskDialog.showUserAsk(
          context: context,
          title: '温馨提示',
          content: '您当前课程已经有名称为 ${levle.name} 的等级，是否继续？',
        );
        if (!askRes) {
          return;
        } else {
          break;
        }
      }
    }
    pageViewNext();
  }

  //获取服务端已储存的课程等级列表数组
  Future<void> getLevleListData() async {
    levleRequested.value = true;
    try {
      ToastUtils.showLoading();
      CourseLevelEntity? resp =
          await OfficialCourseDetailsLevelRequest.getCourseLevelList(courseId!);
      if (resp == null) return;
      List<CourseLevelEntityLevelList?>? list = resp.levelList;
      if (list == null || list.isEmpty) return;
      levleList.value = list;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  // -------------------- 扫描ISBN卡片 ---------------------

  /// 扫描ISBN按钮是否禁用
  void getScanISBNButtonFlag() {
    scanISBNButtonDisable.value = scanBookISBNInput.text.isEmpty;
  }

  // ----------------------- 课程信息卡片 ---------------------

  /// 课程信息卡片按钮是否禁用
  void getCourseInfoCardButtonFlag() {
    if (bookEntity == null) {
      bookInfoButtonDisable.value = true;
      return;
    }

    if (bookEntity!.status == 0) {
      bookInfoButtonDisable.value = true;
    } else if (bookEntity!.status == 1 || bookEntity!.status == 2) {
      bookInfoButtonDisable.value = scanBookISBNInput.text.isEmpty ||
          bookInfoNameInput.text.isEmpty ||
          courseDescribeInput.text.isEmpty;
    } else if (bookEntity!.status == 3) {
      bookInfoButtonDisable.value =
          scanBookISBNInput.text.isEmpty || bookInfoNameInput.text.isEmpty;
    }
  }

  /// 更新选择的难度等级索引
  /// [index] 新的难度等级索引
  void onUpdateDifficultyIndex(int index, DifficultieEntity difficultyValue) {
    if (index >= 0 && index < difficultyList.length) {
      selectDifficultyIndex.value = index;
    }
    getCourseInfoCardButtonFlag();
  }

  /// 选择书籍封面
  // Future<void> selectBooksCover(BuildContext context) async {
  //   File? file = await ImagePickerUtils.selectPicture(
  //     context: context,
  //     cropAspectRatio: 3 / 4,
  //   );
  //   if (file == null) return;
  //   bookCoverFileUrl.value = file.path;
  //   // 清空key 和 网络url 重新选择封面 证明需要修改需要重新上传
  //   bookCoverKey.value = "";
  //   bookCoverNetWorkUrl.value = "";
  //   getCourseInfoCardButtonFlag();
  // }

  /// 课程信息卡片继续按钮
  Future<void> courseInfoContinue(BuildContext context) async {
    if (bookEntity == null) {
      return;
    }

    if (!verify(level: true, isbn: true, book: true)) return;

    if (bookEntity!.status == 1 || bookEntity!.status == 2) {
      try {
        ToastUtils.showLoading();

        Map<String, dynamic> reqData = {
          "isbn": scanBookISBNInput.text.trim(),
          "purpose": courseDescribeInput.text.trim(),
          "addressCode": initDistrictCode.value,
          "difficulty": difficultyList[selectDifficultyIndex.value].level,
          "name": bookInfoNameInput.text.trim(),
          "recordId": bookEntity?.recordId,
        };
        bool res = await CustomizedCoursesRequest.uploadUnBookInfo(reqData);
        if (res) {
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
            ToastUtils.showToast(text: "已上报成功");
            Get.back();
            return;
          }
        }
      } finally {
        ToastUtils.hideLoading();
      }

      return;
    }

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
  }

  Future<void> getBookScanCount() async {
    Map<String, dynamic> parameters = {
      "bookId": bookEntity?.uid,
    };
    CustomCourseKnowledgeInfoEntity? knowledge =
        await CustomizedCoursesRequest.getCustomCourseKnowledgeInfo(parameters);
    if (knowledge != null) {
      knowledgeInfo = knowledge;
      scanTimes.value = knowledge.reuseCount ?? 0;
      manualScanTime.value = knowledge.timeRange ?? manualScanTime.value;
    }
  }

  // ---------------------- 知识点卡片 ---------------------

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
    if (!verify(level: true, isbn: true, book: true, knowledgeAdd: true))
      return;
    reuseVocabularyKnowledge(context);
  }

  /// 获取状态
  Future<void> reuseVocabularyKnowledge(BuildContext context) async {
    try {
      ToastUtils.showLoading();
      CustomCourseOrderIdsEntity? vocabularyInfo =
          await CustomizedCoursesRequest.getOrderIds();
      if (vocabularyInfo == null) return;

      // 获取套餐详情
      Map<String, dynamic> packReqData = {
        "servicePackageId": vocabularyInfo.servicePackageId,
        "servicePackageVersion": vocabularyInfo.servicePackageVersion,
        "defaultCoupon": false,
      };
      PackageShopDetailEntity? packageShopDetail =
          await PayRequest.getPackageShopDetail(packReqData);
      if (packageShopDetail == null) return;

      ConfirmOrderWidgetManager.showC(
        context: context,
        packageShopDetailEntity: packageShopDetail,
        onOk: () {
          pay(context, packageShopDetail);
        },
        onRecharge: () async {
          final bool isPwdRight =
              await ParentPasswordialog.show(context: Get.context!);
          if (!isPwdRight) return;

          /// 跳转至充值乃币页面
          await TagRoutes.toNamed(Routes.RECHARGE_NAIBI);
        },
      );
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 支付
  Future<void> pay(
      BuildContext context, PackageShopDetailEntity packageShopDetail) async {
    try {
      ToastUtils.showLoading();

      if (courseCoverFileUrl.isNotEmpty) {
        // 上传封面
        final record = await OssUploadFileUtils.uploadUserFile(filePath: courseCoverFileUrl.value);
        if (record == null || record.key == null || record.url == null) return;
        courseCoverKey.value = record.key!;
        courseCoverNetWorkUrl.value = record.url!;
      }

      int operation = knowledgeSelectIndex.value == 0 ? 1 : 2;

      Map<String, dynamic> reqData = {
        "courseId": courseId,
        "levelId": levelId,
        "moduleId": moduleId,
        "operation": operation,
        "course": {
          "name": courseNameInput.text,
          "cover": courseCoverKey.value,
          "language": languageCode.value,
        },
        "level": {
          "name": levelNameInput.text,
          "language": languageCode.value,
        },
        "module": {
          "bookId": bookEntity?.uid,
          "language": languageCode.value,
          "difficulty": difficultyList[selectDifficultyIndex.value].level,
          // "subject": bookEntity?.subject,
          "title": bookInfoNameInput.text,
          "cover": coverKey.value,
          "isbn": scanBookISBNInput.text.trim(),
        },
        "orderPay": {
          "servicePackageId":
              packageShopDetail.servicePackage?.servicePackageId,
          "servicePackageVersion":
              packageShopDetail.servicePackage?.servicePackageVersion,
          "payMethod":
              packageShopDetail.servicePackage?.payMethod?.toLowerCase(),
        },
      };
      final CustomizedCoursesCreateEntity? createRes =
          await CustomizedCoursesRequest.createCourse(reqData);
      if (createRes == null) {
        final officialCourseDetailsController =
            TagRoutes.findLast<OfficialCourseDetailsController>(Routes.OFFICIAL_COURSE_DETAILS);
        if (officialCourseDetailsController != null) {
          officialCourseDetailsController.getModuleList(isLoading: false);
        }
        return;
      }
      // 创建和支付成功
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().initHomeCardList();
      }

      //第二条路支付成功后,更换卡片
      if (knowledgeSelectIndex.value == 1) {
        knowledgeAddCardShow.value = false;
        scanTipCardShow.value = true;
        courseId = createRes.courseId;
        levelId = createRes.levelId;
        moduleId = createRes.moduleId;
        return;
      }

      //第一条路支付成功后
      if (pageType == 0) {
        TagRoutes.offNamed(
          Routes.OFFICIAL_COURSE_DETAILS,
          arguments: {
            "courseId": createRes.courseId,
            "levelId": createRes.levelId,
            "moduleId": createRes.moduleId,
            "goCustomCourseProgress": true,
            // "reuseTaskId": createRes.taskId, // 传递任务ID用于后续跟踪
          },
        );
      } else if (pageType == 1 || pageType == 2) {
        Get.back(
          result: {
            "levelId": createRes.levelId,
            "moduleId": createRes.moduleId,
            // "reuseTaskId": createRes.taskId, // 传递任务ID用于后续跟踪
            "goCustomCourseProgress": true,
          },
        );
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
    };
    if (pageType == 0) {
      params["fromCourseDetailPage"] = false;
    }
    if (Platform.isMacOS) {
      String? deviceId = await CameraMacOSCustomCurseDialog.show(
        context: Get.context!,
      );
      params["deviceId"] = deviceId;
    } else if (Platform.isWindows) {
      CameraDescription? cameraDescription =
          await CameraWindowsCustomCurseDialog.show(
        context: Get.context!,
      );
      params["cameraDescription"] = cameraDescription;
    }
    await TagRoutes.toNamed(
      Routes.CUSTOM_COURSE_SHOOT_WORDS,
      arguments: params,
    );
  }
}
