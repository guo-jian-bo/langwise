import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';

class BecomeInviterController extends GetxController {

  /// -1: 加载中 0: 加载失败 1: 加载完成
  final RxInt loadingStatus = (-1).obs;

  /// 邀请者可获得奖励
  final RxList<InviterRewardsEntityList> inviterRewardsList = <InviterRewardsEntityList>[].obs;

  /// 任务列表
  final RxList<BecomeInviterTaskEntityListUserTasks> invitationTaskList = <BecomeInviterTaskEntityListUserTasks>[].obs;

  /// 当前完成的任务数量
  final RxInt completedTaskCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getInvitationTaskList(sendLearDay: true, again: true);
    getRewardInfo();
  }


  /// 获取邀请任务列表
  Future<void> getInvitationTaskList({bool sendLearDay = false, bool again = false, bool loading = true}) async {

    String taskCode = "CompleteDesignatedDailyTasks";
    String groupCode = "SHAREUSERS";

    try {
      if(loading) ToastUtils.showLoading();

      Map<String, dynamic> parameters = {
        "group": groupCode,
      };
      BecomeInviterTaskEntity? entity = await ActivitiesRequest.getInvitationTaskList(parameters: parameters); 
      if(entity == null) return;
      List<BecomeInviterTaskEntityList?>? list = entity.list??[];
      if(list.isEmpty) return;
      BecomeInviterTaskEntityList? group = list.firstWhereOrNull((e) => e?.group == groupCode);
      if(group == null) return;
      List<BecomeInviterTaskEntityListUserTasks?>? items = group.userTasks??[];
      invitationTaskList.clear();
      completedTaskCount.value = 0;
      for(BecomeInviterTaskEntityListUserTasks? item in items){
        if(item == null) continue;
        if(item.taskCode == taskCode && sendLearDay){
          item.current = await getAccumulationDay(item);
        }
        invitationTaskList.add(item);

        if(item.statusEnum == ActivityConsoleTaskStatus.COMPLETED){
          completedTaskCount.value++;
        }
      }

      if(invitationTaskList.isEmpty){
        loadingStatus.value = 0;
      }else{
        loadingStatus.value = 1;
      }

      if(again){
        getInvitationTaskListAgain();
      }

    } finally{
      if(loading) ToastUtils.hideLoading();
    }
  }

  /// 再次获取邀请任务列表
  Future<void> getInvitationTaskListAgain() async {
    Future.delayed(const Duration(milliseconds: 1300), (){
      if(isClosed) return;
      getInvitationTaskList(loading: false);
    });
  }


  /// 获取奖励信息
  Future<void> getRewardInfo() async {
    InviterRewardsEntity? entity = await ActivitiesRequest.getInviterRewardInfo();
    if(entity == null) return;
    List<InviterRewardsEntityList?> list = entity.list??[];
    inviterRewardsList.clear();
    for(InviterRewardsEntityList? item in list){
      if(item == null) continue;
      inviterRewardsList.add(item);
    }
  }



  /// 获取累积学习的天数
  Future<int?> getAccumulationDay(BecomeInviterTaskEntityListUserTasks item) async {

    // 如果禁用或者完成 不调用
    if(item.statusEnum == ActivityConsoleTaskStatus.BAN || item.statusEnum == ActivityConsoleTaskStatus.COMPLETED){
      return 0;
    }

    int? learningDay = item.current;
    
    try {

      // 这里调用华盛哥接口获取当前学习的天数
      int? todayMissionFinishDay = await getUserStudyDays();
      if(todayMissionFinishDay == null || todayMissionFinishDay == 0) return learningDay;
      // 如果当前学习天数和华盛哥接口返回的天数不一致 就需要调用楠哥接口告诉他当前行学习的天数
      if(learningDay != todayMissionFinishDay){
        await updateAccumulationDay(item, todayMissionFinishDay);
      }

      return todayMissionFinishDay;
      
    } catch (_) {}
    
    return learningDay;
    
  }


  /// 获取用户学习天数
  Future<int?> getUserStudyDays() async {
    LearningStatisticsEntity? result = await StudiesRequest.getUserStudyDays(showToast: false);
    return result?.todayMissionFinishDay;
  }


  Future<void> updateAccumulationDay(BecomeInviterTaskEntityListUserTasks item, int todayMissionFinishDay) async {
    try {
      Map<String, dynamic> reqData = {
        "taskCode": item.taskCode,
        "progressValue": todayMissionFinishDay,
      };
      bool result = await ActivitiesRequest.referralTaskProgress(reqData: reqData);
      if(!result) return;
      getInvitationTaskList();

    } catch (_) {}
  }



  /// 点击去完成
  Future<void> goCompleteTask(BecomeInviterTaskEntityListUserTasks item) async{
    bool isBan = item.taskTypeEnum != TaskTypeEnum.INSTANT && item.statusEnum == ActivityConsoleTaskStatus.BAN;
    if(isBan){
      ToastUtils.showToast(text: item.banTitle??"未满足条件");
      return;
    }

    await JumpPageUtils.jumpUserPages(item.jump?.code, item.jump?.params);
    getInvitationTaskList(sendLearDay: true);
    
  }


  /// 成为邀请人
  Future<void> referralApply() async{
    try {
      ToastUtils.showLoading();
      bool result = await ActivitiesRequest.referralApply();
      if(!result) return;
      UserStore.to.getUserRolePermissions();
      Get.offAndToNamed(Routes.INVITATION_LIST);
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
    super.onClose();
  }
}
