import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/back_widget.dart';
import 'package:langwise/common/widgets/card_public_widgets.dart';
import 'package:langwise/common/widgets/knowledge_selection_widget.dart';
import 'package:langwise/common/widgets/step_progress_widget.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
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
      CustomCourseView(tagText: tag),
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
              body: Column(
                children: [
                  _buildTitleWidget(context), 
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
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 10.wMin,
        left: 80.wMin,
        right: 80.wMin + 64.wMin,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BackWidget(onTap: () => controller.showExitConfirmation(context)),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 24.wMin),
              alignment: Alignment.center,
              child: Obx(() {
                return StepProgressWidget(
                  steps: controller.steps.toList(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  //添加教材
  Widget buildAddBook(BuildContext context) {
    return CustomCourseAddBookWidget(tagText: tagText);
  }

  /// 添加知识点
  Widget buildAddKnowledge(BuildContext context) {
    return Column(children: [
      SizedBox(height: 64.wMin),
      const CardTitleIconTextWidget(
        title: "添加知识点",
      ),
      SizedBox(height: 40.wMin),
      SizedBox(
        width: 800.wMin,
        child: KnowledgeSelectionContainer(
          selectedIndex: controller.knowledgeSelectIndex.value,
          onSelectionChanged: (index) => controller.selectAddKnowledgeMethod(index),
          items: [
            KnowledgeSelectionItem(
              title: "复用其他用户词汇表",
              showAiIcon: true,
              subtitle: Text(
                "已有${controller.scanTimes.value}位用户扫描过相同书籍，并由AI交叉确认，无需等待和再次核对",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextDisabled,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            KnowledgeSelectionItem(
              title: "手动扫描词汇表",
              subtitle: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextDisabled,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    const TextSpan(text: "手动拍照上传，系统识别后，还需要再次手动核对词汇表，用时较长，"),
                    TextSpan(
                      text: "大约需要${controller.manualScanTime.value}",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cFeedbackErrorBorder,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      Spacer(),
      TapScaleWidget(
        onTap: () {
          if (!controller.knowledgeButtonDisable.value) {
              controller.knowledgeContinue(context);
          }
        },
        child: Container(
          width: 832.wMin,
          height: 72.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: controller.knowledgeButtonDisable.value ? AppTheme.cTextDisabled : AppTheme.cSurfaceInfo.color,
          ),
          child: Text('继续',
              style: TextStyle(
                fontSize: 24.wMin,
                color: controller.knowledgeButtonDisable.value ? AppTheme.cTextSecondary : AppTheme.cInverseTextLight,
                fontWeight: FontWeight.w600,
              )),
        ),
      ),
      SizedBox(height: 47.wMin)
    ]);
  }

  /// 第二条路的提示卡片
  Widget buildScanTip(BuildContext context) {
    return CardBoxWidget(
      continueText: '扫描',
      pageIndex: 1,
      currentPageIndex: controller.currentPageIndex.value,
      buttonDisable: false,
      showBorder:false,
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
