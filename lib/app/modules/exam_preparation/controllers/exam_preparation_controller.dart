import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/home/controllers/home_controller.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/date_time_picker_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../common/https/https.dart';
import '../../../../theme/theme.dart';
import '../../../routes/routes.dart';
import '../../../routes/routes_breadcrumb_utils.dart';
import '../../elements/common/elements_ai_animation_widget.dart';
import '../views/exam_preparation_time_dialog.dart';


class ExamPreparationController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  ExamPreparationController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.EXAM_PREPARATION;

  @override
  String get breadcrumbTitle => "创建备考计划";

  final List<AiAnimationModel> aiAnimationList = [
    AiAnimationModel(
      name: "扫描记忆盲区，弥补“学习欠账”",
      svgBackColor: const Color(0xffC084FC),
      iconSvg: "assets/svg/elements/icon_battle.svg",
      subName: "正在检索您长期未复习的知识点...",
      completeSubName: "AI会自动揪出你久拖未复习的‘学习欠账’...",
    ),
    AiAnimationModel(
      name: "识别学习瓶颈，识破“假努力”",
      svgBackColor: const Color(0xff38BDF8),
      iconSvg: "assets/svg/elements/icon_scan.svg",
      subName: "正在分析“反复学却总学不会”的顽固知识点...",
      completeSubName: "精准识别出‘反复学却总也学不会’的知识点...",
    ),
    AiAnimationModel(
      name: "评估提分潜力，专攻高分“硬骨头”",
      svgBackColor: const Color(0xffFB923C),
      iconSvg: "assets/svg/elements/icon_search.svg",
      subName: "正在锁定提分最快、价值最高的关键考点...",
      completeSubName: "主攻高分‘硬骨头’。AI为你精准锁定提分最快的知识点...",
    ),
    AiAnimationModel(
      name: "校准记忆节拍，挑战“长久记忆”",
      svgBackColor: const Color(0xff2DD4BF),
      iconSvg: "assets/svg/elements/icon_push_pin.svg",
      subName: "正在为您规划每个知识点的最佳复习节奏...",
      completeSubName: "AI如同精准的‘记忆节拍器’，为你校准每个知识点的最佳复习节奏...",
    ),
    AiAnimationModel(
      name: "分析完成！已生成专属强化方案",
      svgBackColor: AppTheme.cFeedbackSuccessIcon.color,
      iconSvg: "assets/svg/elements/icon_check_circle.svg",
      subName: "准备开始高效备考之旅！",
      showProgress: false,
    ),
  ];
  
  final PageController pageController = PageController(viewportFraction: 0.4);
  final RxDouble currentPageIndex = 0.0.obs;
  final RxBool showCreatePage = false.obs;
  final RxBool showReviewDatePage = false.obs;

  /// 计划名称
  final TextEditingController planNameInput = TextEditingController();
  /// 语言 名称
  final RxString languagText = "英语".obs;
  /// 语言 code
  final RxString languagCode = "en".obs;


  /// 计划名称按钮是否禁用
  final RxBool planNameInputDisabled = true.obs;

  /// 备考开始日期
  final Rx<DateTime> preparationStartDate = DateTime.now().obs;

  /// 考试当天日期
  final Rx<DateTime> testDayDate = DateTime.now().add(const Duration(days: 30)).obs;

  /// 每日计划复习时间
  final Rx<DateTime> planYourReviewTime = DateTime.now().obs;

  /// 每次复习时长 分钟
  final RxInt reviewTimeDurationMinute = 60.obs;

  /// 算出的复习日期结果
  final RxList<PreparationPlanTimeSlots> slotsResultList = <PreparationPlanTimeSlots>[].obs;

  
  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    pageController.addListener((){
      currentPageIndex.value = pageController.page??0;
    });
  }


  void getPlanNameInputDisabled(){
    if(planNameInput.text.trim().isEmpty){
      planNameInputDisabled.value = true;
    }else{
      planNameInputDisabled.value = false;
    }
  }

  /// 创建备考计划下一步按钮
  Future<void> planNameNext() async{
    showCreatePage.value = true;
    await pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }

  /// 编辑备考备考日期
  Future<void> editPreparationDate(BuildContext context) async{
    ExamPreparationTimeDialogReslut? reslut = await ExamPreparationTimeDialog.show(
      context: context,
      init: ExamPreparationTimeDialogReslut(
        preparationSartDate: preparationStartDate.value, 
        testDate: testDayDate.value,
      ),
    );
    if(reslut == null) return;
    preparationStartDate.value = reslut.preparationSartDate;
    testDayDate.value = reslut.testDate;
    if(preparationStartDate.value == reslut.preparationSartDate && testDayDate.value == reslut.testDate) return;
    showReviewDatePage.value = false;
    slotsResultList.clear();
  }

  /// 选择每次复习时长
  Future<void> selectReviewTime(BuildContext context) async{
    List<PlanSettingDurationModel> durationList = [
      PlanSettingDurationModel(name: "小考", minute: 60, color: AppTheme.cTextSecondary.color),
      PlanSettingDurationModel(name: "中考", minute: 120, color: AppTheme.cFeedbackInfoText.color),
      PlanSettingDurationModel(name: "大考", minute: 180, color: AppTheme.cFeedbackErrorText.color),
    ];
    int? res = await PlanSettingDurationDialog.show(
      context: context,
      initMinute: reviewTimeDurationMinute.value,
      durationList: durationList,
      maxMinute: 180,
      minMinute: 5,
    );
    if(res == null) return;
    reviewTimeDurationMinute.value = res;
  }

  /// 选择每日计划复习时间
  Future<void> selectReviewTimeMinute(BuildContext context) async{

    DateTimePickerUtils.showHM(
      context: context,
      title: "选择每日计划复习时间",
      initialDate: planYourReviewTime.value,
      onTap: (date) {
        if(planYourReviewTime.value == date) return;
        planYourReviewTime.value = date;
        showReviewDatePage.value = false;
        slotsResultList.clear();
      },
    );
  }

  /// 编辑备考日期下一步按钮
  Future<void> editPreparationDateNext(BuildContext context) async{
    if(showReviewDatePage.value){
      showReviewDatePage.value = true;
      await pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.linear);
      return;
    }

    String startDate = DateFormatUtil.formatStr(preparationStartDate.value);
    String endDate = DateFormatUtil.formatStr(testDayDate.value);
    int hour = planYourReviewTime.value.hour;
    int minute = planYourReviewTime.value.minute;

    Map<String, dynamic> reqData = {
      "startDate": startDate,
      "examDate": endDate,
      "hour": hour,
      "minute": minute,
    };
    
    
    AILoadingDialog.show(
      context: context,
      title: "倍效备考期间每次复习都会根据上次学习结果推演最优提分策略，让你的每一次复习都走在提分的最短路径上。",
      animationList: aiAnimationList,
      onComplete: (bool result) async{
        Get.back();
        if(!result) return;
        showReviewDatePage.value = true;
        await pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.linear);
      },
      onRequest: () async{
        PreparationGenerationDateEntity? res = await ExamPreparationRequest.getExamPreparationDateList(reqData);
        if(res == null) return false;
        List<PreparationPlanTimeSlots?>? slots = res.slots;
        if(slots == null) return false;
        List<PreparationPlanTimeSlots> slotsList = [];
        for(var item in slots){
          if(item == null) continue;
          slotsList.add(item);
        }
        slotsResultList.value = slotsList;
        if(slotsResultList.isEmpty) return false;
        return true;
      },
    );

  }


  /// 选择课程
  void selectCourse(BuildContext context){
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseAllowPlanList)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }
    SelectCourseDialog.show(
      context: context,
    );
  }

  /// 删除复习日期
  void removeReviewDate(int index){
    if(slotsResultList.length <= 1) return ToastUtils.showToast(text: "至少保留一条复习日期");
    slotsResultList.removeAt(index);
  }


  


  /// 创建备考计划
  Future<void> createPreparationPlan(BuildContext context) async{
    List<Map<String, dynamic>> timeSlots = [];
    for(int i = 0; i < slotsResultList.length; i++){
      slotsResultList[i].reviewNumber = i + 1;
      timeSlots.add(slotsResultList[i].toJson());
    }

    Map<String, dynamic> reqData = {
      "name": planNameInput.text,
      "language": languagCode.value,
      "examDate": DateFormatUtil.formatStr(testDayDate.value),
      "startPrepDate": DateFormatUtil.formatStr(preparationStartDate.value),
      "dailyDuration": reviewTimeDurationMinute.value * 60,
      "timeSlots": timeSlots,
    };

    try {
      ToastUtils.showLoading();
      bool res = await ExamPreparationRequest.createExamPreparation(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "创建成功", type: ToastType.success);
      if(Get.isRegistered<HomeController>()){
        await Get.find<HomeController>().initHomeCardList();
      }

      Get.back(result: true);

    } finally{
      ToastUtils.hideLoading();
    }
  }
  

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    pageController.dispose();
    planNameInput.dispose();
    super.onClose();
  }
}
