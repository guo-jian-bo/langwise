import 'dart:math';
import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 课程生成状态对话框
///
/// 用于显示课程生成过程中各个步骤的详细状态信息
class CourseGenerationStatusDialog {
  /// 显示课程生成状态对话框
  ///
  /// [context] 上下文
  /// [taskId] 任务ID
  /// [onComplete] 完成回调
  static Future<void> show({
    required BuildContext context,
    required int taskId,
    void Function(bool result)? onComplete,
  }) async {
    return Get.dialog<void>(
      CourseGenerationStatusDialogWidget(
        taskId: taskId,
        onComplete: onComplete,
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    );
  }
}

/// 课程生成状态对话框组件
class CourseGenerationStatusDialogWidget extends StatefulWidget {
  final int taskId;
  final void Function(bool result)? onComplete;

  const CourseGenerationStatusDialogWidget({
    super.key,
    required this.taskId,
    this.onComplete,
  });

  @override
  State<CourseGenerationStatusDialogWidget> createState() => _CourseGenerationStatusDialogWidgetState();
}

class _CourseGenerationStatusDialogWidgetState extends State<CourseGenerationStatusDialogWidget>
    with SafeSetStateMixin {
  CourseGenerateStatusResponseEntity? _statusData;
  final List<_StepRunModel> _stepRunList = [];
  bool _isRunningComplete = false;

  @override
  void initState() {
    super.initState();
    _loadStatusData();
  }

  /// 加载状态数据
  Future<void> _loadStatusData() async {
    try {
      ToastUtils.showLoading();

      final response = await CourseAppUtil.getGenerateStatusInfo(
          config: RequestConfig(
        requireToken: true,
        parameters: {'taskId': widget.taskId},
      ));

      if (ObjectUtil.isEmpty(response.data)) {
        throw response.message ?? '获取状态信息失败';
      }

      safeSetState(() {
        _statusData = response.data;
      });

      // 初始化步骤运行时列表
      _initStepRunList();

      // 开始运行动画
      _runStepAnimation();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message, type: ToastType.error);
    } catch (e) {
      ToastUtils.showToast(text: e.toString(), type: ToastType.error);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 初始化步骤运行时列表
  void _initStepRunList() {
    if (_statusData == null) return;

    final steps = _getStepsList();
    _stepRunList.clear();

    for (int i = 0; i < steps.length; i++) {
      _stepRunList.add(_StepRunModel(
        icon: steps[i].icon,
        color: steps[i].color,
        stepData: steps[i].stepData,
        showProgress: true,
      ));
    }

    // 显示第一个步骤
    if (_stepRunList.isNotEmpty) {
      _stepRunList.first.show = true;
    }
  }

  /// 运行步骤动画
  Future<void> _runStepAnimation() async {
    if (_stepRunList.isEmpty) return;

    for (int i = 0; i < _stepRunList.length; i++) {
      final step = _stepRunList[i];

      // 模拟进度动画
      await Future.delayed(const Duration(milliseconds: 500));

      for (int j = 0; j <= 10; j++) {
        int randomDuration = Random().nextInt(50) + 100;
        await Future.delayed(Duration(milliseconds: randomDuration));
        safeSetState(() {
          step.progress = j * 10;
        });
      }

      // 标记为完成
      await Future.delayed(const Duration(milliseconds: 200));
      safeSetState(() {
        step.isCompleted = true;
      });

      // 显示下一个步骤
      if (i + 1 < _stepRunList.length) {
        await Future.delayed(const Duration(milliseconds: 300));
        safeSetState(() {
          _stepRunList[i + 1].show = true;
        });
      }
    }

    // 所有步骤完成后的处理
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      widget.onComplete?.call(true);
    }

    safeSetState(() {
      _isRunningComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cBgPrimary,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  top: 56.wMin + MediaQuery.of(context).padding.top,
                  left: 68.wMin,
                  right: 68.wMin,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const BackWidget(title: ""),
                          Text(
                            _statusData?.courseTitle ?? '课程生成详情',
                            style: TextStyle(
                              fontSize: 28.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextPrimary,
                            ),
                          ),
                          SizedBox(width: 72.wMin),
                        ],
                      ),
                      _buildHeaderSection(),
                      Gaps.getHeight(40.wh),
                      _buildStepsSection(),
                    ],
                  ),
                ),
              ),
            ),
            if (_isRunningComplete)
              ListAnimationWidget(
                child: Container(
                  height: 64.wMin + 80.wMin + 20.wMin,
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(top: 20.wMin),
                  child: ButtonWidget(
                    text: "去学习",
                    width: 500.wMin,
                    height: 80.wMin,
                    color: AppTheme.cFeedbackInfoText,
                    borderRadius: 8.wMin,
                    fontSize: 28.wMin,
                    fontColor: AppTheme.cStaticWhite,
                    fontWeight: FontWeight.w600,
                    sclae: 1.03,
                    onTap: () {
                      Get.back(result: true);
                      widget.onComplete?.call(true);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建头部区域
  Widget _buildHeaderSection() {
    return Container(
      width: 1075.ww,
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 10.wh, bottom: 10.wh),
      decoration: BoxDecoration(
        color: AppTheme.cFeedbackInfoBackground,
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      child: Text(
        _statusData?.courseDescription ?? '根据您的创建信息，ISBN码，正在生成自定义课程......',
        style: TextStyle(
          fontSize: 24.wMin,
          color: AppTheme.cFeedbackInfoText,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 构建步骤区域
  Widget _buildStepsSection() {
    return Container(
      width: 1075.ww,
      alignment: Alignment.center,
      child: Column(
        children: List.generate(
          _stepRunList.length,
          (index) => Visibility(
            visible: _stepRunList[index].show,
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.wh),
              child: _buildStepItem(_stepRunList[index]),
            ),
          ),
        ),
      ),
    );
  }

  /// 获取步骤列表
  /// 只返回已完成的步骤
  List<_StepDisplayModel> _getStepsList() {
    if (ObjectUtil.isEmpty(_statusData?.courseTitle)) {
      return [];
    }

    final List<_StepDisplayModel> allSteps = [
      _StepDisplayModel(
        stepData: _statusData!.moduleFramework,
        icon: 'assets/svg/elements/icon_battle.svg',
        color: const Color(0xffC084FC),
      ),
      _StepDisplayModel(
        stepData: _statusData!.unitPlan,
        icon: 'assets/svg/elements/icon_scan.svg',
        color: const Color(0xff38BDF8),
      ),
      _StepDisplayModel(
        stepData: _statusData!.sentenceGeneration,
        icon: 'assets/svg/elements/icon_check_circle.svg',
        color: AppTheme.cFeedbackSuccessIcon,
      ),
      _StepDisplayModel(
        stepData: _statusData!.lessonGeneration,
        icon: 'assets/svg/elements/icon_check_circle.svg',
        color: AppTheme.cFeedbackSuccessIcon,
      ),
      _StepDisplayModel(
        stepData: _statusData!.contentGeneration,
        icon: 'assets/svg/elements/icon_check_circle.svg',
        color: AppTheme.cFeedbackSuccessIcon,
      ),
    ];

    // 只返回已完成的步骤
    return allSteps.where((step) => step.stepData?.isCompleted ?? false).toList();
  }

  /// 构建步骤项
  Widget _buildStepItem(_StepRunModel step) {
    final isCompleted = step.isCompleted;
    final progress = step.progress;
    final stepName = step.stepData?.stepName ?? '';
    final statusDesc = step.stepData?.statusDescription ?? '处理中';

    return ListAnimationWidget(
      verticalOffset: 20.wMin,
      child: Row(
        children: [
          // 内容区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stepName,
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary,
                  ),
                ),
                Gaps.getHeight(4.wMin),
                // 进度条或副标题区域
                Container(
                  alignment: Alignment.topLeft,
                  height: 30.wMin,
                  child: Row(
                    spacing: 8.wMin,
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (progress == 0 || isCompleted) {
                              return Text(
                                isCompleted ? statusDesc : "${statusDesc}...",
                                style: TextStyle(
                                  fontSize: 20.wMin,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.cTextTertiary,
                                ),
                              );
                            }
                            return Container(
                              height: 8.wMin,
                              width: double.infinity,
                              alignment: Alignment.topLeft,
                              decoration: BoxDecoration(
                                color: AppTheme.cFeedbackDefaultBackground,
                                borderRadius: BorderRadius.circular(100.wMin),
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                width: constraints.maxWidth * (progress / 100),
                                decoration: BoxDecoration(
                                  color: step.color,
                                  borderRadius: BorderRadius.circular(100.wMin),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Visibility(
                        visible: progress != 0 && !isCompleted,
                        child: Text(
                          "${progress}%",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 状态信息
          if (step.stepData?.statisticsInfo != null)
            Text(
              step.stepData!.statisticsInfo!,
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary,
              ),
            ),
          Gaps.getWidth(7.wMin),
          // 右侧完成状态图标
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: isCompleted
                ? SvgPicture.asset(
                    Assets.customCourseIconCheckOkCircle,
                    width: 36.wMin,
                    height: 36.wMin,
                  )
                : SpinKitDualRing(
                    color: AppTheme.cFeedbackDefaultIcon,
                    key: ValueKey(isCompleted),
                    size: 36.wMin,
                    lineWidth: 2.wMin,
                    duration: const Duration(milliseconds: 300),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stepRunList.clear();
    super.dispose();
  }
}

/// 步骤显示模型
class _StepDisplayModel {
  final CourseGenerateStepEntity? stepData;
  final String icon;
  final Color color;

  _StepDisplayModel({
    required this.stepData,
    required this.icon,
    required this.color,
  });
}

/// 步骤运行时模型
class _StepRunModel {
  String icon;
  Color color;
  bool isCompleted = false;
  int progress = 0;
  bool show = false;
  bool showProgress;
  CourseGenerateStepEntity? stepData;

  _StepRunModel({
    required this.icon,
    required this.color,
    required this.stepData,
    this.showProgress = true,
  });
}
