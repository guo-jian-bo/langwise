import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/common.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../stores/stores.dart';
import '../../values/values.dart';
import '../widgets.dart';

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
  bool isAllExpanded = false;

  List<_GuideTaskModel> taskList = [];



  @override
  void initState(){
    super.initState();

    int? userId = UserStore.to.userInfo.value.userId;
    if(userId != null){
      isShowAgain = StorageUtil().getBoolNull("${NOVICE_TASK_REMINDER_KEY}_$userId")??false;
    }

    _queryTaskList();

    taskList = List.generate(8, (index) {
      return _GuideTaskModel(
        isExpanded: false,
        rowKey: GlobalKey(),
        stepList: List.generate(10, (stepIndex) {
          return _GuideTaskStepModel(
            key: GlobalKey(),
            isCompleted: stepIndex < 3,
          );
        }),
      );
    });
  }

  /// 查询任务列表
  Future<void> _queryTaskList() async{
    
  }


  /// 展开收起全部
  void _toggleCollapse(){
    isAllExpanded = !isAllExpanded;
    for (var element in taskList) {
      element.isExpanded = isAllExpanded;
    }
    if(mounted) setState(() {});
  }

  /// 展开收起某个任务
  void _toggleTaskCollapse(_GuideTaskModel task){
    task.isExpanded = !task.isExpanded;

    // 检查是否有任务展开 如果有展开的 则 isAllExpanded 为 true
    // 否则 isAllExpanded 为 false
    bool expanded = taskList.any((element) => element.isExpanded);
    isAllExpanded = expanded;

    if(mounted) setState(() {});
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        children: [
      
          Expanded(
            child: Text(
              '免费领取 7天Max会员 10000学点',
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
                      "1 / ${taskList.length}",
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
                    value: 0.14285714285714286,
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
            onTap: (){},
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
            "英语水平评测",
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
        
        Visibility(
          visible: !task.isExpanded,
          child: Row(
            children: [
              SvgPicture.asset(
                "assets/svg/public/icon_duration.svg",
                width: 28.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
              ),
              SizedBox(width: 4.wMin),
              Text(
                "04:00",
                style: TextStyle(
                  fontSize: 22.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        Visibility(
          visible: task.isExpanded,
          child: Text(
            "预计时长：04:00",
            style: TextStyle(
              fontSize: 22.wMin,
              color: AppTheme.cTextBrand.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
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
    String rewardImage = "assets/images/public/icon_max.png";
    // assets/image/public/icon_pro.png
    // assets/image/public/icon_plus.png
    // assets/image/public/icon_learn_point.png
    // assets/image/public/icon_nai_coin.png
    return Row(
      children: [
        Image.asset(rewardImage, width: 98.wMin),
        SizedBox(width: 8.wMin),
        Text(
          "12天",
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 16.wMin),
        ButtonWidget(
          text: "未完成",
          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 8.wMin),
          borderRadius: 6.wMin,
          color: AppTheme.cSurfaceLayerElevated.color,
          fontSize: 18.wMin,
          fontWeight: FontWeight.w500,
          fontColor: AppTheme.cTextSecondary.color,
          sclae: 1.03,
        ),
      ],
    );
  }

  Widget _buildStepListWidget(_GuideTaskModel task){
    return GestureDetector(
      onTap: (){},
      child: Container(
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
              children: List.generate(task.stepList.length, (index){
                return _buildStepItemWidget(task.stepList[index], index);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepItemWidget(_GuideTaskStepModel step, int index){
    final Color stepBorderColor = step.isCompleted
        ? AppTheme.cBorderBrand.color
        : AppTheme.cBorderSecondary.color;

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
              color: AppTheme.cInverseSurface.color,
              border: Border.all(
                color: stepBorderColor,
                width: 4.wMin,
              ),
            ),
            child: Text(
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
            "课程已创建",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
      
          SizedBox(height: 16.wMin),
      
          ButtonWidget(
            text: "已完成",
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
            borderRadius: 6.wMin,
            color: AppTheme.cSurfaceTertiary.color,
            fontSize: 18.wMin,
            fontColor: AppTheme.cTextSecondary.color,
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

  GlobalKey rowKey;

  List<_GuideTaskStepModel> stepList;

  _GuideTaskModel({
    this.isExpanded = false,
    required this.rowKey,
    required this.stepList,
  });
}

class _GuideTaskStepModel{
  GlobalKey key;

  /// 是否完成
  bool isCompleted;

  _GuideTaskStepModel({
    required this.key,
    this.isCompleted = false,
  });
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

      final Paint paint = stepList[index].isCompleted ? completedPaint : uncompletedPaint;

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
