import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/static/static_data.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../../home/controllers/home_controller.dart';

class PreparationPlanListController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  PreparationPlanListController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.PREPARATION_PLAN_LIST;

  @override
  String get breadcrumbTitle => "备考计划";

  /// 传进来的参数
  int initIndex = 0;


  final PageController pageController = PageController(viewportFraction: 0.4);
  final RxDouble currentPageIndex = 0.0.obs;

  List<IconDropdownCheckData<int>> minuteDurationList = [];
  
  /// 计划列表
  final RxList<PreparationPlanModel> planDataList = <PreparationPlanModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      initIndex = Get.arguments["initIndex"]??0;
    }

    minuteDurationList = StaticData.getMinuteList();
    getPlanDataList().then((_){
      pageController.animateToPage(initIndex, duration: const Duration(milliseconds: 300), curve: Curves.ease);
    });
    pageController.addListener((){
      currentPageIndex.value = pageController.page??0;
    });
  }


  /// 获取备考计划列表
  Future<void> getPlanDataList() async{
    try {
      ToastUtils.showLoading();
      PreparationPlanEntity? resData = await ExamPreparationRequest.getExamPreparationList();
      if(resData == null) return;
      List<PreparationPlanEntityList?>? list = resData.list;
      if(list == null) return;
      planDataList.clear();
      for(int i = 0; i < list.length; i++){
        if(list[i] == null) continue;
        int dailyDuration = (list[i]!.dailyDuration??0); 
        
        planDataList.add(PreparationPlanModel(
          planNameInput: TextEditingController(text: list[i]!.name??""),
          data: list[i]!,
          buttonDisabled: (list[i]!.name?.isEmpty??true).obs,
          reviewTimeDurationMinute: (dailyDuration ~/ 60).obs,
        ));
      }
    } finally{
      ToastUtils.hideLoading();
    }

    
  }
  /// 删除复习日期
  Future<void> removeReviewDate(int planIndex, int index) async{
    if((planDataList[planIndex].data.timeSlots?.length??0) <= 1){
      ToastUtils.showToast(text: "至少需要保留一个复习日期");
      return;
    }
    planDataList[planIndex].data.timeSlots?.removeAt(index);
    planDataList.refresh();
  }

  /// 选择每次复习时长
  Future<void> selectReviewTime(BuildContext context, int planIndex) async{

    List<PlanSettingDurationModel> durationList = [
      PlanSettingDurationModel(name: "小考", minute: 60, color: AppTheme.cTextSecondary.color),
      PlanSettingDurationModel(name: "中考", minute: 120, color: AppTheme.cFeedbackInfoText.color),
      PlanSettingDurationModel(name: "大考", minute: 180, color: AppTheme.cFeedbackErrorText.color),
    ];
    int? res = await PlanSettingDurationDialog.show(
      context: context,
      initMinute: planDataList[planIndex].reviewTimeDurationMinute.value,
      durationList: durationList,
      maxMinute: 180,
      minMinute: 5,
    );
    if(res == null) return;

    planDataList[planIndex].reviewTimeDurationMinute.value = res;
    planDataList[planIndex].data.dailyDuration = res * 60;
    planDataList.refresh();
  }

  /// 删除计划
  Future<void> removePlan(BuildContext context, int planIndex) async{
    if(planDataList[planIndex].data.uid == null){
      ToastUtils.showToast(text: "删除失败");
      return;
    }
    bool ask = await AskDialog.showUserAsk(
      context: context, 
      title: "温馨提示", 
      content: "确定要删除备考计划 ${planDataList[planIndex].data.name} 吗？", 
      define: "删除",
      showLastCountdown: true,
    );
    if(!ask) return;
    ToastUtils.showLoading();
    try {
      bool res = await ExamPreparationRequest.delPlan(planDataList[planIndex].data.uid!);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      planDataList.removeAt(planIndex);
      planDataList.refresh();
      if(currentPageIndex.value == planIndex){
        if(planDataList.isNotEmpty){
          currentPageIndex.value = planIndex - 1;
        }
      }
      if(Get.isRegistered<HomeController>()){
        await Get.find<HomeController>().initHomeCardList();
      }
      if(planDataList.isEmpty){
        Get.back();
      }
    } finally {
      ToastUtils.hideLoading();
    }
    
  }


  Future<void> addPlan() async{
    dynamic res = await TagRoutes.toNamed(Routes.EXAM_PREPARATION);
    if(res == null) return;
    await getPlanDataList();
    pageController.animateToPage(planDataList.length - 1, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }


  /// 编辑计划
  Future<void> editPlan(int planIndex) async{
    PreparationPlanModel model = planDataList[planIndex];
    if(model.data.uid == null) return;
    try {
      ToastUtils.showLoading();

      List<PreparationPlanTimeSlots?> sTimeSlots = model.data.timeSlots??[];
      List<Map<String, dynamic>> timeSlots = [];
      for(int i = 0; i < sTimeSlots.length; i++){
        if(sTimeSlots[i] == null) continue;
        timeSlots.add(sTimeSlots[i]!.toJson());
      }

      Map<String, dynamic> reqData = {
        "name": model.planNameInput.text,
        "language": model.data.language,
        "dailyDuration": model.data.dailyDuration,
        "timeSlots": timeSlots,
        "examDate": model.data.examDate,
        "startPrepDate": model.data.startPrepDate,
      };
      bool res = await ExamPreparationRequest.editPlan(planDataList[planIndex].data.uid!, reqData);
      if(!res) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      if(Get.isRegistered<HomeController>()){
        await Get.find<HomeController>().initHomeCardList();
      }
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

    for(int i = 0; i < planDataList.length; i++){
      planDataList[i].planNameInput.dispose();
    }

    super.onClose();
  }

}


class PreparationPlanModel{
  final TextEditingController planNameInput;
  final PreparationPlanEntityList data;
  final RxBool buttonDisabled;
  final RxInt reviewTimeDurationMinute;
  PreparationPlanModel({
    required this.planNameInput,
    required this.data,
    required this.buttonDisabled,
    required this.reviewTimeDurationMinute,
  });
}
