import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/home/controllers/home_controller.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/app_routes_code.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../entities/entities.dart';
import '../../stores/stores.dart';
import '../../values/values.dart';
import '../widgets.dart';
import 'guide_engine.dart';

/// 引导任务列表弹窗
class GuideTaskListDialog{

  static Future<void> show({
    required BuildContext context,
  }) async{
    await showCupertinoDialog(
      context: context, 
      builder: (context) {
        return GuideTaskListDialogWidget();
      },
    );
  }

}

class GuideTaskListDialogWidget extends StatefulWidget {
  const GuideTaskListDialogWidget({super.key});

  @override
  State<GuideTaskListDialogWidget> createState() => _GuideTaskListDialogWidgetState();
}

class _GuideTaskListDialogWidgetState extends State<GuideTaskListDialogWidget> {

  /// 是否不再提示引导任务列表弹窗
  bool isShowAgain = false;

  /// 是否展开所有任务
  bool isAllExpanded = true;

  NewbieGuideEntity newbieGuideData = NewbieGuideEntity();

  /// 任务列表
  List<_GuideTaskModel> taskList = [];



  @override
  void initState(){
    super.initState();

    int? userId = UserStore.to.userInfo.value.userId;
    if(userId != null){
      isShowAgain = StorageUtil().getBoolNull("${NOVICE_TASK_REMINDER_KEY}_$userId")??false;
    }

    _queryTaskList(isInit: true);
    
  }

  /// 查询任务列表
  Future<void> _queryTaskList({bool isInit = false}) async{
    try {
      ToastUtils.showLoading();
      await GuideTaskController.to.loadNewbieGuideTaskList();

      NewbieGuideEntity entity = GuideTaskController.to.newbieGuideData.value;
      List<NewbieGuideEntityQuests?> quests = entity.quests??[];
      if(quests.isEmpty) return;
      newbieGuideData = entity;

      List<int> openQuestIds = [];

      if(isInit){
        // 第一个未完成的任务组 默认展开
        int firstUncompletedIndex = quests.indexWhere((element) => element?.status != 1 && element?.rights?.allLock == false);
        if(firstUncompletedIndex != -1){
          // 检查是否有权限
          openQuestIds.add(quests[firstUncompletedIndex]?.questId??0);
        }
      }else{
        for (var element in taskList) {
          if(element.isExpanded){
            // 记录展开的任务 id
            if(element.quest?.questId == null) continue;
            openQuestIds.add(element.quest?.questId??0);
          }
        }
      }

      taskList = List.generate(quests.length, (index) {
        List<NewbieGuideEntityQuestsTargets?> targets = quests[index]?.targets??[];

        return _GuideTaskModel(
          isExpanded: openQuestIds.contains(quests[index]?.questId),
          taskKey: GlobalKey(),
          rowKey: GlobalKey(),
          quest: quests[index],
          isCompleted: quests[index]?.status == 1,
          stepList: List.generate(targets.length, (stepIndex) {
            GuideTaskStepStatus status = GuideTaskStepStatus.unlocked;
            if(targets[stepIndex]?.status == 1){
              status = GuideTaskStepStatus.completed;
            } else {
              // 第一个未完成的任务 为当前任务
              int firstIndex = targets.indexWhere((element) => element?.status == 0);
              if(firstIndex == stepIndex){  
                status = GuideTaskStepStatus.current;
              }else{
                status = GuideTaskStepStatus.unlocked;
              }
            }
            return _GuideTaskStepModel(
              key: GlobalKey(),
              status: status,
              step: targets[stepIndex],
            );
          }),
        );
      });

      if(mounted) setState(() {});

      if(isInit){
        // 滚动到第一个未完成的任务组
        _GuideTaskModel? firstUncompletedTask = taskList.firstWhereOrNull((e) => e.isExpanded);
        if(firstUncompletedTask == null) return;    
        _scrollToTask(firstUncompletedTask);  
      }

    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 滚动到对应的任务
  void _scrollToTask(_GuideTaskModel task){
    // 下一帧
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      BuildContext? cxt = task.taskKey.currentContext;
      if(cxt == null) return;
      await Scrollable.ensureVisible(
        cxt,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
      );

      // 等待展开动画结束后再滚动步骤，避免在布局变化过程中定位不准。
      await Future.delayed(const Duration(milliseconds: 300));
      if(!mounted) return;

      _GuideTaskStepModel? currentStep = task.stepList.firstWhereOrNull((e) => e.status == GuideTaskStepStatus.current);
      if(currentStep == null) return;
      BuildContext? stepCxt = currentStep.key.currentContext;
      if(stepCxt == null || !stepCxt.mounted) return;
      await Scrollable.ensureVisible(
        stepCxt,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
      );

    });
  }

  /// 展开收起全部
  void _toggleCollapse(){
    isAllExpanded = !isAllExpanded;
    for (var element in taskList) {
      if((element.quest?.rights?.isLock ?? false) != false) continue;
      element.isExpanded = isAllExpanded;
    }
    if(mounted) setState(() {});
  }

  /// 展开收起某个任务
  void _toggleTaskCollapse(_GuideTaskModel task) async{
    if(task.quest?.rights != null){
      if (await LockUtils.checkLock(task.quest?.rights, context)) return;
    }
    
    task.isExpanded = !task.isExpanded;

    // 检查是否有任务展开 如果有展开的 则 isAllExpanded 为 true
    // 否则 isAllExpanded 为 false
    bool expanded = taskList.any((element) => element.isExpanded);
    isAllExpanded = expanded;

    if(mounted) setState(() {});
  }

  /// 查看发放详情
  Future<void> _showRewardDetail(_GuideTaskModel task) async{
    List<NewbieGuideEntityQuestsRewards?> rewards = task.quest?.rewards??[];
    if(rewards.isEmpty) return;

    bool res = await GuideRewardDialog.show(
      context: context, 
      rewards: rewards,
      status: task.quest?.status??0,
      rewardStatus: task.quest?.rewardStatus??0,
      finished: task.quest?.finished,
    );
    if(!res) return;
  }

  /// 开始任务
  /// [isAgain] 是否是 再来一遍
  /// [task] 任务
  /// [step] 任务步骤
   Future<void> _startTask(_GuideTaskModel task, _GuideTaskStepModel step, {bool isAgain = false}) async{
    if(task.quest?.rights != null){
      if (await LockUtils.checkLock(task.quest?.rights, context)) return;
    }

    int? questId = task.quest?.questId;
    if(questId == null) return;
    String? pageCode = step.step?.jump?.code;
    if(pageCode == null) return;

    /// 如果在家长密码黑名单中 则需要调用[await ParentPasswordialog.show] 输入家长密码
    if(AppRoutesCode.parentPasswordBlacklist.contains(pageCode)){
      bool parRes = await ParentPasswordialog.show(
        context: Get.context ?? context,
        isCheckHasPassword: false,
      );
      if(!parRes) return;
    }

    // 需要把当前任务上下文给页面任务列表接口
    GuideTaskController.to.setCurrentQuestId(questId);
    GuideTaskController.to.setIsAgain(isAgain);

    if(pageCode != AppRoutesCode.home){
      Get.back();
      JumpPageUtils.jumpUserPages(step.step?.jump); 
      return;
    }

    Get.back();
    if(Get.currentRoute != AppRoutesCode.home){
      Get.until((route) => route.settings.name == Routes.APPLICATION);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    bool isRegistered = Get.isRegistered<HomeController>();
    if(!isRegistered) return;
    await GuideTaskController.to.loadTasksAndStart(pageCode: pageCode);

  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        int? userId = UserStore.to.userInfo.value.userId;
        if(userId != null){
          StorageUtil().setBool("${NOVICE_TASK_REMINDER_KEY}_$userId", isShowAgain);
        }
      },
      child: GestureDetector(
        onTap: () => Get.back(),
        child: Material(
          color: AppTheme.cOverlayBackground.color,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cSurfaceSecondary.color,
                  borderRadius: BorderRadius.circular(40.wMin),
                ),
                child: Container(
                  width: 1440.wMin,
                  height: 990.wMin,
                  padding: EdgeInsets.symmetric(vertical: 32.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40.wMin),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, 0.06, 0.2],
                      colors: [
                        AppTheme.cBgBrand.color.withValues(alpha: 0.2),
                        AppTheme.cBgBrand.color.withValues(alpha: 0.1),
                        AppTheme.cBgBrand.color.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleWidget(),
                      SizedBox(height: 10.wMin),
                      Expanded(child: _buildTaskListWidget()),
                      SizedBox(height: 16.wMin),
                      _buildDoNotRemindAgain(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    int completedCount = taskList.where((element) => element.quest?.status == 1).length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        children: [
      
          Expanded(
            child: Text(
              newbieGuideData.name??"",
              style: TextStyle(
                fontSize: 36.wMin,
                color: AppTheme.cTextBrand.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(width: 16.wMin),

          SizedBox(
            width: 220.wMin,
            child: Column(
              spacing: 4.wMin,
              children: [
                Row(
                  children: [
                    Text(
                      "进度",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "$completedCount / ${taskList.length}",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: completedCount / taskList.length,
                    valueColor: AlwaysStoppedAnimation(AppTheme.cSurfaceBrand.color),
                    backgroundColor: AppTheme.cSurfaceLayerElevated.color,
                    minHeight: 8.wMin,
                  ),
                ),

              ],
            ),
          ),

          SizedBox(width: 40.wMin),

          TapScaleWidget(
            onTap: (){
              _queryTaskList();
            },
            sclae: 1.05,
            child: Container(
              width: 48.wMin,
              height: 48.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.wMin),
                color: AppTheme.cSurfaceTertiary.color,
              ),
              child: SvgPicture.asset(
                "assets/svg/public/icon_refresh.svg",
                width: 28.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
              ),
            ),
          ),

          SizedBox(width: 16.wMin),
      
          TapScaleWidget(
            onTap: _toggleCollapse,
            sclae: 1.05,
            child: Container(
              width: 48.wMin,
              height: 48.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.wMin),
                color: AppTheme.cSurfaceTertiary.color,
              ),
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: isAllExpanded ? 0.5 : 0,
                child: SvgPicture.asset(
                  "assets/svg/public/icon_arrow_down.svg",
                  width: 28.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskListWidget(){
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 10.wMin, horizontal: 32.wMin),
      child: Column(
        spacing: 8.wMin,
        children: List.generate(taskList.length, (taskIndex){
          return _buildTaskListItemWidget(taskList[taskIndex], taskIndex);
        }),
      ),
    );
  }

  Widget _buildTaskListItemWidget(_GuideTaskModel task, int taskIndex){
    return TapScaleWidget(
      onTap: () {
        _toggleTaskCollapse(task);
      },
      sclae: 1,
      child: Container(
        key: task.taskKey,
        width: double.infinity,
        padding: EdgeInsets.all(20.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceTertiary.color,
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskListItemTitleWidget(task, taskIndex),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: task.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst, 
              firstChild: Container(), 
              secondChild: _buildStepListWidget(task), 
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskListItemTitleWidget(_GuideTaskModel task, int taskIndex){
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: EdgeInsets.all(6.wMin),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: task.isExpanded ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2) : Colors.transparent,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 38.wMin,
            height: 38.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isExpanded ? AppTheme.cSurfaceBrand.color : Colors.transparent,
              border: Border.all(
                color: task.isExpanded ? AppTheme.cSurfaceBrand.color : AppTheme.cTextSecondary.color,
                width: 1.wMin,
              ),
            ),
            child: AutoSizeText(
              "${taskIndex + 1}",
              minFontSize: 6,
              style: TextStyle(
                fontSize: 22.wMin,
                color: task.isExpanded ? Colors.white : AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 24.wMin),
        Container(
          constraints: BoxConstraints(
            minWidth: 400.wMin,
          ),
          child: Text(
            task.quest?.name??"",
            style: TextStyle(
              fontSize: 28.wMin,
              color: task.isExpanded ? AppTheme.cTextBrand.color : AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 20.wMin),
        _buildRewardWidget(task),
        const Spacer(),
        
        // Visibility(
        //   visible: !task.isExpanded,
        //   child: Row(
        //     children: [
        //       SvgPicture.asset(
        //         "assets/svg/public/icon_duration.svg",
        //         width: 28.wMin,
        //         colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
        //       ),
        //       SizedBox(width: 4.wMin),
        //       Text(
        //         "04:00",
        //         style: TextStyle(
        //           fontSize: 22.wMin,
        //           color: AppTheme.cTextSecondary.color,
        //           fontWeight: FontWeight.w400,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        // Visibility(
        //   visible: task.isExpanded,
        //   child: Text(
        //     "预计时长：04:00",
        //     style: TextStyle(
        //       fontSize: 22.wMin,
        //       color: AppTheme.cTextBrand.color,
        //       fontWeight: FontWeight.w400,
        //     ),
        //   ),
        // ),

        // Visibility(
        //   visible: GuideTaskController.to.getUncompletedQuestCount() <= 0,
        //   child: ButtonWidget(
        //     text: "再来一遍",
        //     padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 8.wMin),
        //     borderRadius: 6.wMin,
        //     color:  AppTheme.cSurfaceLayerElevated.color,
        //     fontSize: 18.wMin,
        //     fontWeight: FontWeight.w500,
        //     fontColor: AppTheme.cTextSecondary.color,
        //     sclae: 1.03,
        //     onTap: () {
        //       _startTask(task, task.stepList.first, isAgain: true);
        //     },
        //   ),
        // ),

        SizedBox(width: 12.wMin),
        AnimatedRotation(
          duration: const Duration(milliseconds: 200),
          turns: task.isExpanded ? 0.5 : 0,
          child: SvgPicture.asset(
            "assets/svg/public/icon_arrow_down.svg",
            width: 24.wMin,
            colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }

  /// 奖励
  Widget _buildRewardWidget(_GuideTaskModel task){

    String rewardButtonText = "未完成";
    if(task.isCompleted){
      if(task.quest?.rewardStatus == 1){
        rewardButtonText = "发放详情";
      }else{
        rewardButtonText = "待发放";
      }
    }

    List<NewbieGuideEntityQuestsRewards?> rewards = task.quest?.rewards??[];

    // String rewardImage = "assets/images/public/icon_max.png";
    // assets/image/public/icon_pro.png
    // assets/image/public/icon_plus.png
    // assets/image/public/icon_learn_point.png
    // assets/image/public/icon_nai_coin.png

    return Expanded(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false, // 隐藏滚动条
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
          
              Row(
                children: List.generate(rewards.length, (index){
                  return Row(
                    spacing: 16.wMin,
                    children: [
                      Visibility(
                        visible: rewards[index]?.iconUrl != null,
                        child: Container(
                          margin: EdgeInsets.only(right: 8.wMin),
                          child: CachedImageWidget(
                            rewards[index]?.iconUrl??"", 
                            height: 48.wMin,
                          ),
                        ),
                      ),
                      Text(
                        rewards[index]?.displayName??"",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                }),
              ),
          
              SizedBox(width: 16.wMin),
              ButtonWidget(
                text: rewardButtonText,
                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 8.wMin),
                borderRadius: 6.wMin,
                color: task.isCompleted ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2) : AppTheme.cSurfaceLayerElevated.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                fontColor: task.isCompleted ? AppTheme.cTextBrand.color : AppTheme.cTextSecondary.color,
                sclae: 1.03,
                onTap: () {
                  _showRewardDetail(task);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepListWidget(_GuideTaskModel task){
    return GestureDetector(
      onTap: (){},
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cSurfaceSecondary.color,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 24.wMin),
          child: CustomPaint(
            key: task.rowKey,
            painter: _GuideStepConnectorPainter(
              rowKey: task.rowKey,
              stepList: task.stepList,
              connectorGap: 12.wMin,
            ),
            child: Row(
              spacing: 12.wMin,
              children: List.generate(task.stepList.length, (index){
                return _buildStepItemWidget(task, task.stepList[index], index);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepItemWidget(_GuideTaskModel task, _GuideTaskStepModel step, int index){
    Color stepBorderColor = AppTheme.cBorderBrand.color;
    String buttonText = "未解锁";
    Color buttonBgColor = AppTheme.cSurfaceTertiary.color;
    Color buttonTextFontColor = AppTheme.cTextSecondary.color;
    if(step.status == GuideTaskStepStatus.unlocked){
      stepBorderColor = AppTheme.cBorderSecondary.color;
      buttonBgColor = AppTheme.cSurfaceTertiary.color;
      buttonTextFontColor = AppTheme.cTextSecondary.color;
    }else if(step.status == GuideTaskStepStatus.completed){
      buttonText = "已完成";
      buttonBgColor = AppTheme.cSurfaceTertiary.color;
      buttonTextFontColor = AppTheme.cTextSecondary.color;
    }else{
      buttonText = "去完成";
      buttonBgColor = AppTheme.cSurfaceBrand.color;
      buttonTextFontColor = Colors.white;
    }

    return Container(
      constraints: BoxConstraints(
        minWidth: 220.wMin,
      ),
      child: Column(
        children: [
      
          Container(
            key: step.key,
            width: 56.wMin,
            height: 56.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: step.status == GuideTaskStepStatus.completed ? AppTheme.cSurfaceBrand.color : AppTheme.cInverseSurface.color,
              border: Border.all(
                color: stepBorderColor,
                width: 4.wMin,
              ),
            ),
            child: step.status == GuideTaskStepStatus.completed ? SvgPicture.asset(
              "assets/svg/public/icon_check_w.svg",
              width: 38.wMin,
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ) : Text(
              "${index + 1}",
              style: TextStyle(
                fontSize: 24.wMin,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      
          SizedBox(height: 6.wMin),
      
          Text(
            step.step?.displayName??"",
            style: TextStyle(
              fontSize: 24.wMin,
              color: step.status == GuideTaskStepStatus.unlocked ? AppTheme.cTextTertiary.color : AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
      
          SizedBox(height: 16.wMin),
      
          ButtonWidget(
            text: buttonText,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
            borderRadius: 6.wMin,
            color: buttonBgColor,
            fontSize: 18.wMin,
            fontColor: buttonTextFontColor,
            sclae: 1.03,
            onTap: () {
              if(step.status != GuideTaskStepStatus.current) return;
              _startTask(task, step);
            },
          ),
      
        ],
      ),
    );
  }


  /// 不再提示引导任务列表弹窗
  Widget _buildDoNotRemindAgain(){
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: TapScaleWidget(
        onTap: () {
          isShowAgain = !isShowAgain;
          StorageUtil().setBool(NOVICE_TASK_REMINDER_KEY, isShowAgain);
          if(mounted) setState(() {});
        },
        sclae: 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isShowAgain ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
              width: 24.wMin,
              height: 24.wMin,
            ),
            SizedBox(width: 8.wMin),
            Text(
              "不再提醒",
              style: TextStyle(
                color: AppTheme.cTextSecondary,
                fontSize: 22.wMin,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }


}



class _GuideTaskModel{
  /// 是否展开
  bool isExpanded;

  GlobalKey taskKey;

  GlobalKey rowKey;

  List<_GuideTaskStepModel> stepList;

  NewbieGuideEntityQuests? quest;

  /// 是否完成
  bool isCompleted;

  _GuideTaskModel({
    this.isExpanded = false,
    required this.taskKey,
    required this.rowKey,
    required this.stepList,
    this.quest,
    this.isCompleted = false,
  });
}

class _GuideTaskStepModel{
  GlobalKey key;

  /// 是否完成
  GuideTaskStepStatus status;


  NewbieGuideEntityQuestsTargets? step;

  _GuideTaskStepModel({
    required this.key,
    this.status = GuideTaskStepStatus.unlocked,
    this.step,
  });
}

enum GuideTaskStepStatus{
  /// 已完成
  completed,
  /// 当前步骤
  current,
  /// 未解锁步骤
  unlocked,
}

class _GuideStepConnectorPainter extends CustomPainter{
  final GlobalKey rowKey;
  final List<_GuideTaskStepModel> stepList;
  final double connectorGap;

  _GuideStepConnectorPainter({
    required this.rowKey,
    required this.stepList,
    required this.connectorGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (stepList.length < 2) return;

    final RenderBox? rowBox = rowKey.currentContext?.findRenderObject() as RenderBox?;
    if (rowBox == null || !rowBox.hasSize) return;

    final Paint completedPaint = Paint()
      ..color = AppTheme.cBorderBrand.color
      ..strokeWidth = 4.wMin
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint uncompletedPaint = Paint()
      ..color = AppTheme.cBorderDark.color
      ..strokeWidth = 4.wMin
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int index = 0; index < stepList.length - 1; index++) {
      final RenderBox? currentBox =
          stepList[index].key.currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? nextBox =
          stepList[index + 1].key.currentContext?.findRenderObject() as RenderBox?;
      if (currentBox == null || nextBox == null) continue;
      if (!currentBox.hasSize || !nextBox.hasSize) continue;

      final Offset currentCenter = currentBox.localToGlobal(
        currentBox.size.center(Offset.zero),
        ancestor: rowBox,
      );
      final Offset nextCenter = nextBox.localToGlobal(
        nextBox.size.center(Offset.zero),
        ancestor: rowBox,
      );

      final double startX = currentCenter.dx + currentBox.size.width / 2 + connectorGap;
      final double endX = nextCenter.dx - nextBox.size.width / 2 - connectorGap;
      if (endX <= startX) continue;

      final Paint paint = stepList[index].status == GuideTaskStepStatus.completed ? completedPaint : uncompletedPaint;

      canvas.drawLine(
        Offset(startX, currentCenter.dy),
        Offset(endX, nextCenter.dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GuideStepConnectorPainter oldDelegate) {
    return true;
  }
}
