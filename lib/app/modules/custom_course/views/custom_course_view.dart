import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/card_public_widgets.dart';
import 'package:langwise/common/widgets/customer_service_dialog.dart';
import 'package:langwise/common/widgets/guide_engine/guide_widget_ids.dart';
import 'package:langwise/common/widgets/step_progress_widget.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import '../bindings/custom_course_binding.dart';
import '../controllers/custom_course_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'custom_course_add_book_widget.dart';

class CustomCourseView extends GetView<CustomCourseController> {
  final String tagText;
  const CustomCourseView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => CustomCourseView(tagText: tag),
      binding: CustomCourseBinding(tagText: tag),
      routeName: Routes.CUSTOM_COURSE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getCurrentLocation(context);
    });

    return PopScope(
      canPop: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: AppTheme.cBgPrimary,
              body: Stack(
                children: [
                  Positioned.fill(
                    child: Column(
                      children: [
                        _buildTitleWidget(context),
                        _buildStepProgressWidget(),
                        Expanded(
                          child: Obx(() {
                            if (!controller.isInitPageController.value) {
                              return const SizedBox.shrink();
                            }

                            return PageView(
                              controller: controller.pageController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                if (controller.courseInfoCardShow.value) buildAddBook(context),
                                if (controller.knowledgeAddCardShow.value) buildAddKnowledge(context),
                                if (controller.scanTipCardShow.value) buildScanTip(context),
                                if (controller.courseGenerationCardShow.value) buildCourseGeneration(context),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  _buildCustomerServiceButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context) {
    return BreadcrumbWidget(
      onBack: () => controller.showExitConfirmation(context),
    );
  }

  Widget _buildStepProgressWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: 3.wMin,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 980.wMin),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            child: Obx(() {
              return StepProgressWidget(
                steps: controller.steps.toList(),
                activeColor: const Color(0xFFF59E0B),
                activeBorderOpacity: 0.2,
                activeBackgroundOpacity: 0.12,
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerServiceButton() {
    return Positioned(
      left: 56.wMin,
      bottom: 50.wMin,
      child: Obx(() {
        final bool showButton = controller.courseInfoCardShow.value && controller.currentPageIndex.value < 0.5;
        if (!showButton) {
          return const SizedBox.shrink();
        }

        return CustomerServiceButtonWidget(
          widgetId: GuideWidgetIds.customCourseCustomerServiceButton,
          pageCode: AppRoutesCode.customCourse,
        );
      }),
    );
  }

  //添加教材
  Widget buildAddBook(BuildContext context) {
    return CustomCourseAddBookWidget(tagText: tagText);
  }

  /// 添加知识点
  Widget buildAddKnowledge(BuildContext context) {
    return Obx(() {
      if (controller.knowledgeCurrentStep.value == 2) {
        return _buildKnowledgePointsConfirmStep(context);
      }
      return _buildKnowledgeMethodSelectionStep(context);
    });
  }

  Widget buildCourseGeneration(BuildContext context) {
    return Obx(() {
      final List<AiAnimationRunModel> steps = controller.generationRunList.toList();
      final int runType = controller.generationRunType.value;
      final int currentIndex = _getGenerationCurrentIndex(steps, runType);
      final double progressValue = _getGenerationProgressValue(steps, currentIndex, runType);
      final String progressText = runType == 1 ? "全部阶段已完成" : "${(progressValue * 100).clamp(0, 100).round()}%";
      final int completedCount = runType == 1 ? 5 : steps.where((item) => item.isCompleted).length;
      final AiAnimationRunModel? currentStep = steps.isEmpty ? null : steps[currentIndex.clamp(0, steps.length - 1)];
      final String rawCourseTitle = controller.generationStatus.value.courseTitle ?? controller.bookInfoNameInput.text.trim();
      final String courseTitle = rawCourseTitle.isEmpty ? "教材名称" : rawCourseTitle;
      final String courseDescription = controller.generationStatus.value.courseDescription?.trim() ?? "";

      return Column(
        children: [
          SizedBox(height: 36.wMin),
          Container(
            width: 1360.wMin,
            padding: EdgeInsets.fromLTRB(32.wMin, 28.wMin, 32.wMin, 32.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cSurfacePrimary.color,
              borderRadius: BorderRadius.circular(28.wMin),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGenerationHeader(
                  courseTitle: courseTitle,
                  courseDescription: courseDescription,
                  currentIndex: currentIndex,
                  completedCount: completedCount,
                  runType: runType,
                  totalCount: steps.isEmpty ? 5 : steps.length,
                ),
                SizedBox(height: 30.wMin),
                _buildGenerationStepRow(steps, currentIndex, runType),
                SizedBox(height: 34.wMin),
                if (runType == 1)
                  _buildGenerationCompletedCard()
                else
                  _buildGenerationRunningCard(
                    currentStep: currentStep,
                  ),
                SizedBox(height: 26.wMin),
                _buildGenerationProgressBar(
                  value: progressValue,
                  label: progressText,
                  isCompleted: runType == 1,
                  completedCount: completedCount,
                  totalCount: steps.isEmpty ? 5 : steps.length,
                ),
              ],
            ),
          ),
          const Spacer(),
          Obx(() {
            if (controller.generationRunType.value == 0) {
              return _buildGenerationBottomBar(
                child: _buildGenerationActionButton(
                  text: "AI 生成中...",
                  width: 440.wMin,
                  backgroundColor: AppTheme.cSurfacePrimary.color,
                  textColor: AppTheme.cBgBrand.color,
                  onTap: () {},
                ),
              );
            }
            if (controller.generationRunType.value == 1) {
              return _buildGenerationBottomBar(
                child: _buildGenerationActionButton(
                  text: "去学习",
                  width: 420.wMin,
                  backgroundColor: const Color(0xFF3D2404),
                  textColor: const Color(0xFFF59E0B),
                  onTap: controller.confirmGenerationAndGoLearn,
                ),
              );
            }
            return _buildGenerationBottomBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGenerationActionButton(
                    text: "联系客服",
                    width: 500.wMin,
                    backgroundColor: AppTheme.cFeedbackWarningBorder.color,
                    textColor: AppTheme.cStaticWhite.color,
                    onTap: () => controller.contactCustomerService(context),
                  ),
                  SizedBox(width: 16.wMin),
                  _buildGenerationActionButton(
                    text: "请重试",
                    width: 500.wMin,
                    backgroundColor: AppTheme.cFeedbackErrorBorder.color,
                    textColor: AppTheme.cStaticWhite.color,
                    onTap: controller.retryGenerateCourse,
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }

  Widget _buildGenerationHeader({
    required String courseTitle,
    required String courseDescription,
    required int currentIndex,
    required int completedCount,
    required int runType,
    required int totalCount,
  }) {
    final bool isCompleted = runType == 1;
    final String title = isCompleted ? "专属课程生成完成" : courseDescription;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 28.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.wMin),
                Text(
                  courseTitle,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: isCompleted ? "$totalCount" : "${currentIndex + 1}",
                  style: TextStyle(
                    fontSize: 42.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: " / $totalCount",
                  style: TextStyle(
                    fontSize: 22.wMin,
                    color: AppTheme.cTextTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKnowledgeMethodSelectionStep(BuildContext context) {
    return Column(children: [
      SizedBox(height: 36.wMin),
      Text(
        "选择知识点添加方式",
        style: TextStyle(
          fontSize: 56.wMin,
          color: AppTheme.cTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(height: 48.wMin),
      SizedBox(
        width: 1068.wMin,
        child: Column(
          children: [
            _buildKnowledgeMethodCard(
              title: "使用现成词汇表",
              description: "词汇表由相同教材的用户整理提供，并由AI 进一步核对后使用，通常是最快的添加方式。",
              isSelected: controller.knowledgeSelectIndex.value == 0,
              onTap: () => controller.selectAddKnowledgeMethod(0),
              showRecommend: true,
              showAi: true,
            ),
            SizedBox(height: 24.wMin),
            _buildKnowledgeMethodCard(
              title: "手动扫描词汇表",
              description: "适合已有词汇表图片，或需要自己逐步补充和校对知识点的情况。确认学点后，会先进入知识点处理，再统一开始课程生成。",
              isSelected: controller.knowledgeSelectIndex.value == 1,
              onTap: () => controller.selectAddKnowledgeMethod(1),
            ),
          ],
        ),
      ),
      const Spacer(),
      GestureDetector(
        onTap: () {
          if (!controller.knowledgeButtonDisable.value) {
            controller.knowledgeContinue(context);
          }
        },
        child: Container(
          width: 540.wMin,
          height: 72.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: controller.knowledgeButtonDisable.value ? AppTheme.cSurfaceTertiary.color : const Color(0xFF3D2404),
          ),
          child: Text(
            '继续',
            style: TextStyle(
              fontSize: 24.wMin,
              color: controller.knowledgeButtonDisable.value ? AppTheme.cTextTertiary : const Color(0xFFF59E0B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      SizedBox(height: 47.wMin)
    ]);
  }

  Widget _buildKnowledgePointsConfirmStep(BuildContext context) {
    final detail = controller.knowledgePackageShopDetail.value;
    if (detail == null) {
      return const SizedBox.shrink();
    }

    final bool isPointsEnough = controller.isKnowledgePointsEnough;
    final bool isCoinEnough = controller.isKnowledgeCoinEnough;
    final bool isPointsShortButCoinEnough = !isPointsEnough && isCoinEnough;
    final String subtitle = isPointsShortButCoinEnough
        ? "确认学点后，会直接进入课程生成。"
        : isPointsEnough
            ? "本次将消耗学点，并直接进入课程生成。"
            : "当前学点不足且乃币余额不够，请先充值乃币。";
    final String remainPointsLabel = isPointsEnough ? "还剩学点" : "还差学点";
    final int remainPointsValue = isPointsEnough ? controller.knowledgeRemainingPoints : controller.knowledgeRemainingPoints.abs();
    final Color remainPointsColor = isPointsEnough ? const Color(0xFF14E0A1) : const Color(0xFFFF4D6D);
    final String coinSummaryLabel = isCoinEnough ? "还剩乃币" : "还差乃币";
    final int coinSummaryValue = isCoinEnough ? controller.knowledgeRemainingCredit : controller.knowledgeRemainingCredit.abs();
    final Color coinSummaryColor = isCoinEnough ? const Color(0xFF1FB8FF) : const Color(0xFFFF4D6D);
    final bool showCoinSection = controller.shouldShowKnowledgeCoinSection;
    final bool showPrimaryAsDisabledStyle = !isCoinEnough;
    final String primaryButtonText = isPointsEnough
        ? "确认并生成课程"
        : isCoinEnough
            ? "兑换学点并生成课程"
            : "充值乃币";
    final String pointsCostText = _formatPoints(controller.knowledgeRequiredPoints);

    return Column(
      children: [
        SizedBox(height: 20.wMin),
        Text(
          "确认使用学点",
          style: TextStyle(
            fontSize: 48.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.wMin),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 44.wMin),
        Container(
          width: 1068.wMin,
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cSurfacePrimary.color,
            borderRadius: BorderRadius.circular(24.wMin),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildKnowledgeSummaryCard(
                      title: "当前学点",
                      value: detail.realUserPoints,
                    ),
                  ),
                  SizedBox(width: 12.wMin),
                  Expanded(
                    child: _buildKnowledgeSummaryCard(
                      title: "本次消耗",
                      value: pointsCostText,
                    ),
                  ),
                  SizedBox(width: 12.wMin),
                  Expanded(
                    child: _buildKnowledgeSummaryCard(
                      title: remainPointsLabel,
                      value: _formatPoints(remainPointsValue),
                      valueColor: remainPointsColor,
                    ),
                  ),
                ],
              ),
              if (isPointsShortButCoinEnough) ...[
                SizedBox(height: 12.wMin),
                Row(
                  children: [
                    Expanded(
                      child: _buildKnowledgeSummaryCard(
                        title: "下次发放时间",
                        value: _buildNextPointGrantDateText(),
                      ),
                    ),
                    SizedBox(width: 12.wMin),
                    Expanded(
                      child: _buildKnowledgeSummaryCard(
                        title: "下次发放数量",
                        value: UserStore.to.userInfo.value.vipPointsStr,
                      ),
                    ),
                    SizedBox(width: 12.wMin),
                    Expanded(
                      child: _buildKnowledgeSummaryCard(
                        title: "日常奖励",
                        value: "学点奖励",
                      ),
                    ),
                  ],
                ),
              ],
              if (showCoinSection) ...[
                SizedBox(height: 16.wMin),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cBgPrimary,
                    borderRadius: BorderRadius.circular(16.wMin),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4.wMin,
                        height: 36.wMin,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(2.wMin),
                        ),
                      ),
                      SizedBox(width: 12.wMin),
                      Expanded(
                        child: Text(
                          isPointsShortButCoinEnough
                              ? "如果不着急，也可以等待 ${_buildNextPointGrantDateText()} 发放学点后再添加。"
                              : "当前乃币余额不足，请先充值乃币后再继续。",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: AppTheme.cTextSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.wMin),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "乃币信息",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 16.wMin),
                Row(
                  children: [
                    Expanded(
                      child: _buildKnowledgeSummaryCard(
                        title: "当前乃币",
                        value: detail.realUserCredit,
                      ),
                    ),
                    SizedBox(width: 12.wMin),
                    Expanded(
                      child: _buildKnowledgeSummaryCard(
                        title: "本次需扣",
                        value: detail.realOrderCredit,
                      ),
                    ),
                    SizedBox(width: 12.wMin),
                    Expanded(
                      child: _buildKnowledgeSummaryCard(
                        title: coinSummaryLabel,
                        value: _formatCredit(coinSummaryValue),
                        valueColor: coinSummaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 1068.wMin,
          child: Row(
            children: [
              Expanded(
                child: _buildKnowledgeActionButton(
                  text: "返回调整",
                  onTap: controller.backToKnowledgeMethodSelection,
                  backgroundColor: AppTheme.cSurfacePrimary.color,
                  textColor: const Color(0xFFF59E0B),
                ),
              ),
              SizedBox(width: 16.wMin),
              Expanded(
                child: _buildKnowledgeActionButton(
                  text: primaryButtonText,
                  onTap: () => controller.knowledgeContinue(context),
                  backgroundColor: showPrimaryAsDisabledStyle ? const Color(0xFF4A080D) : const Color(0xFF3D2404),
                  textColor: showPrimaryAsDisabledStyle ? const Color(0xFFFF5B6B) : const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 47.wMin),
      ],
    );
  }

  Widget _buildKnowledgeMethodCard({
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
    bool showRecommend = false,
    bool showAi = false,
  }) {
    final Color borderColor = isSelected ? const Color(0xFF7A4A05) : Colors.transparent;
    final Color backgroundColor = isSelected ? const Color(0xFF2B1A03) : AppTheme.cSurfacePrimary.color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.wMin),
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 28.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (showRecommend) ...[
                        SizedBox(width: 12.wMin),
                        _buildKnowledgeBadge(
                          text: '推荐',
                          backgroundColor: const Color(0xFF4C3006),
                          textColor: const Color(0xFFF59E0B),
                        ),
                      ],
                      if (showAi) ...[
                        SizedBox(width: 8.wMin),
                        _buildKnowledgeAiBadge(),
                      ],
                    ],
                  ),
                  SizedBox(height: 14.wMin),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cTextSecondary,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20.wMin),
            _buildKnowledgeSelectIcon(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgeBadge({
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: backgroundColor,
        border: Border.all(
          color: const Color(0xFF8C5A08),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.wMin,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildKnowledgeAiBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF9D8CFF),
            Color(0xFFFF8A65),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/svg/public/icon_ai.svg',
            width: 16.wMin,
            height: 16.wMin,
          ),
          SizedBox(width: 4.wMin),
          Text(
            'AI',
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeSelectIcon(bool isSelected) {
    return Container(
      width: 28.wMin,
      height: 28.wMin,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFFF59E0B) : Colors.transparent,
        border: Border.all(
          color: isSelected ? const Color(0xFFF59E0B) : AppTheme.cBorderTertiary.color,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Icon(
              Icons.check_rounded,
              size: 18.wMin,
              color: AppTheme.cTextPrimary,
            )
          : null,
    );
  }

  Widget _buildGenerationStepRow(List<AiAnimationRunModel> steps, int currentIndex, int runType) {
    final List<String> labels = ['框架', '单元', '句子', '课时', '内容'];
    return Row(
      children: List.generate(labels.length * 2 - 1, (itemIndex) {
        if (itemIndex.isEven) {
          final int index = itemIndex ~/ 2;
          final bool isDone = runType == 1 || (index < steps.length && steps[index].isCompleted);
          final bool isCurrent = runType != 1 && index == currentIndex;
          final String numberText = (index + 1).toString().padLeft(2, '0');

          return SizedBox(
            width: 72.wMin,
            child: Column(
              children: [
                _buildGenerationStepCircle(
                  isDone: isDone,
                  isCurrent: isCurrent,
                  numberText: numberText,
                ),
                SizedBox(height: 12.wMin),
                Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        final int lineIndex = itemIndex ~/ 2;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 34.wMin, left: 14.wMin, right: 14.wMin),
            height: 2.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999.wMin),
              gradient: (runType == 1 || lineIndex < currentIndex) ? _buildGenerationAiGradient() : null,
              color: (runType == 1 || lineIndex < currentIndex) ? null : const Color(0xFF4A4A4A),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGenerationStepCircle({
    required bool isDone,
    required bool isCurrent,
    required String numberText,
  }) {
    final bool useGradientStyle = isDone || isCurrent;
    return Container(
      width: 56.wMin,
      height: 56.wMin,
      padding: EdgeInsets.all(1.5.wMin),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: useGradientStyle ? _buildGenerationAiGradient() : null,
        color: useGradientStyle ? null : const Color(0xFF5A5A5A),
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: useGradientStyle ? const Color(0xFF2B2231) : const Color(0xFF313131),
        ),
        child: isDone
            ? ShaderMask(
                shaderCallback: (Rect bounds) {
                  return _buildGenerationAiGradient().createShader(bounds);
                },
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 28.wMin,
                ),
              )
            : (useGradientStyle
                ? _buildGenerationGradientText(
                    numberText,
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w600,
                  )
                : Text(
                    numberText,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cTextTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
      ),
    );
  }

  Widget _buildGenerationGradientText(
    String text, {
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return _buildGenerationAiTextGradient().createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  LinearGradient _buildGenerationAiGradient() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFF8D99FF),
        Color(0xFFC686FF),
        Color(0xFFFF6778),
        Color(0xFFFFBA71),
        Color(0xFFAA6EEE),
        Color(0xFFBC82F3),
      ],
      stops: [0.0, 0.16, 0.42, 0.62, 0.82, 1.0],
    );
  }

  LinearGradient _buildGenerationAiTextGradient() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFF8D99FF),
        Color(0xFFC686FF),
        Color(0xFFFF6778),
        Color(0xFFFFBA71),
      ],
    );
  }

  Widget _buildGenerationRunningCard({
    required AiAnimationRunModel? currentStep,
  }) {
    final String stepName = (currentStep?.name ?? '').trim().isEmpty ? "正在生成专属课程" : currentStep!.name;
    final String statusDescription = (currentStep?.subName ?? '').trim().isEmpty ? "AI 正在处理中..." : currentStep!.subName!;
    final int? resultCount = currentStep?.cnt;
    final String resultStep = (currentStep?.step ?? '').trim().isEmpty ? "" : currentStep!.step!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.wMin, 22.wMin, 24.wMin, 24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cTextPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AI正在分析中...",
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextSecondary,
            ),
          ),
          SizedBox(height: 16.wMin),
          Text(
            stepName,
            style: TextStyle(
              fontSize: 32.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.wMin),
          Text(
            statusDescription,
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.wMin),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: resultCount?.toString() ?? '--',
                  style: TextStyle(
                    fontSize: 56.wMin,
                    color: const Color(0xFFF59E0B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: resultStep.isEmpty ? "" : " 个$resultStep",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: const Color(0xFFF59E0B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGenerationCompletedCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.wMin, 24.wMin, 24.wMin, 24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cTextPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "专属课程已就绪",
            style: TextStyle(
              fontSize: 48.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.wMin),
          Row(
            children: [
              Expanded(
                child: _buildGenerationMetricCard(
                  controller.generationStatus.value.moduleFramework?.step ?? "--",
                  controller.generationStatus.value.moduleFramework?.cnt,
                ),
              ),
              SizedBox(width: 8.wMin),
              Expanded(
                child: _buildGenerationMetricCard(
                  controller.generationStatus.value.unitPlan?.step ?? "--",
                  controller.generationStatus.value.unitPlan?.cnt,
                ),
              ),
              SizedBox(width: 8.wMin),
              Expanded(
                child: _buildGenerationMetricCard(
                  controller.generationStatus.value.sentenceGeneration?.step ?? "--",
                  controller.generationStatus.value.sentenceGeneration?.cnt,
                ),
              ),
              SizedBox(width: 8.wMin),
              Expanded(
                child: _buildGenerationMetricCard(
                  controller.generationStatus.value.lessonGeneration?.step ?? "--",
                  controller.generationStatus.value.lessonGeneration?.cnt,
                ),
              ),
              SizedBox(width: 8.wMin),
              Expanded(
                child: _buildGenerationMetricCard(
                  controller.generationStatus.value.contentGeneration?.step ?? "--",
                  controller.generationStatus.value.contentGeneration?.cnt,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenerationMetricCard(String title, int? count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 18.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cTextPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18.wMin),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.wMin),
          Text(
            count?.toString() ?? '--',
            style: TextStyle(
              fontSize: 56.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerationProgressBar({
    required double value,
    required String label,
    required bool isCompleted,
    required int completedCount,
    required int totalCount,
  }) {
    final double normalized = value.clamp(0, 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 6.wMin,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(999.wMin),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: normalized,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(999.wMin),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.wMin),
        Text(
          label,
          style: TextStyle(
            fontSize: 16.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: isCompleted ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildGenerationBottomBar({required Widget child}) {
    return Padding(
      padding: EdgeInsets.only(top: 24.wMin, bottom: 64.wMin),
      child: child,
    );
  }

  Widget _buildGenerationActionButton({
    required String text,
    required double width,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 64.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.wMin),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 28.wMin,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  int _getGenerationCurrentIndex(List<AiAnimationRunModel> steps, int runType) {
    if (steps.isEmpty) {
      return 0;
    }
    if (runType == 1) {
      return steps.length - 1;
    }
    for (int i = 0; i < steps.length; i++) {
      if (!steps[i].isCompleted) {
        return i;
      }
    }
    return steps.length - 1;
  }

  double _getGenerationProgressValue(List<AiAnimationRunModel> steps, int currentIndex, int runType) {
    if (steps.isEmpty) {
      return 0;
    }
    if (runType == 1) {
      return 1;
    }
    final int completedCount = steps.where((item) => item.isCompleted).length;
    final int currentProgress = currentIndex < steps.length ? steps[currentIndex].process : 0;
    return ((completedCount + (currentProgress / 100)) / steps.length).clamp(0, 1);
  }

  Widget _buildKnowledgeSummaryCard({
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTertiary.color,
        borderRadius: BorderRadius.circular(16.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            value,
            style: TextStyle(
              fontSize: 36.wMin,
              color: valueColor ?? AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeActionButton({
    required String text,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: backgroundColor,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24.wMin,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _buildNextPointGrantDateText() {
    final DateTime now = DateTime.now();
    final DateTime nextMonth = DateTime(now.year, now.month + 1, 1);
    return '${nextMonth.month} 月 ${nextMonth.day} 日';
  }

  String _formatPoints(int value) {
    final String text = value.toString();
    final RegExp regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return text.replaceAllMapped(regExp, (match) => '${match[1]},');
  }

  String _formatCredit(int cents) {
    return (cents / 100).toStringAsFixed(2);
  }

  /// 第二条路的提示卡片
  Widget buildScanTip(BuildContext context) {
    return CardBoxWidget(
      continueText: '扫描',
      pageIndex: 1,
      currentPageIndex: controller.currentPageIndex.value,
      buttonDisable: false,
      showBorder: false,
      onContinue: OptimizeUtils.noneThrottle(() {
        //扫描单词
        controller.scanWord(context);
      }, 1000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 64.wMin),
          const Center(
            child: CardTitleIconTextWidget(
              title: "添加单词表",
              hideIcon: true,
            ),
          ),
          SizedBox(height: 40.wMin),
          Center(
            child: Image.asset(
              'assets/images/custom_course/custom_course_example.png',
              height: 300.wMin,
            ),
          ),
          SizedBox(height: 40.wMin),
          Text(
            '示例',
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.wMin),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w500,
              ),
              children: [
                const TextSpan(
                  text: "请扫描",
                ),
                TextSpan(
                  text: "教材背面单词表",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextBrand,
                  ),
                ),
                const TextSpan(text: "，必须包含单元信息"),
                TextSpan(
                  text: "Unit1",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextBrand,
                  ),
                ),
                const TextSpan(text: "，信息安全可控，识别后自动匹配学习资料。"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
