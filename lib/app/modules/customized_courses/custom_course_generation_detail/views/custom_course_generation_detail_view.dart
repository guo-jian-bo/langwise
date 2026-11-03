import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../../generated/assets.dart';
import '../../../../../theme/theme.dart';
import '../bindings/custom_course_generation_detail_binding.dart';
import '../controllers/custom_course_generation_detail_controller.dart';

class CustomCourseGenerationDetailView
    extends GetView<CustomCourseGenerationDetailController> {
  final String tagText;
  const CustomCourseGenerationDetailView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      CustomCourseGenerationDetailView(tagText: tag),
      binding: CustomCourseGenerationDetailBinding(tagText: tag),
      routeName: Routes.CUSTOM_COURSE_GENERATION_DETAIL,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 24.wMin),
            controller.fromType==4?Container():Container(
              padding: EdgeInsets.symmetric(horizontal: 40.wMin),
              child: Obx(() {
                if(controller.aiProcessStatus.value.generateStatus==1){
                  return const SizedBox.shrink();
                }
                return BackWidget(
                    title: controller.aiProcessStatus.value.courseTitle ?? "");
              }),
            ),
            Expanded(
              child: SizedBox(
                width: 1075.wMin,
                child: Column(
                  children: [
                    SizedBox(height: 60.wMin),
                    _buildTitleWidget(),
                    SizedBox(height: 16.wMin),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Obx(() {
                          return Column(
                            spacing: 40.wMin,
                            children: List.generate(
                                controller.aiAnimationRunList.length, (index) {
                              return Visibility(
                                visible:
                                    controller.aiAnimationRunList[index].show,
                                child: _buildAnimationItemWidget(
                                    controller.aiAnimationRunList[index]),
                              );
                            }),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildButtonsWidget(context),
    );
  }

  Widget _buildButtonsWidget(BuildContext context) {
    return Obx(() {
      Widget buttonWidget = Container();
      if (controller.runType.value == 0) {
        buttonWidget = ButtonWidget(
          text: "正在分析中",
          width: 720.wMin,
          height: 64.wMin,
          borderRadius: 12.wMin,
          color: AppTheme.cBorderPrimary,
          fontColor: AppTheme.cTextDisabled,
          fontSize: 28.wMin,
          fontWeight: FontWeight.w500,
        );
      } else if (controller.runType.value == 1) {
        buttonWidget = ButtonWidget(
          text: "去学习",
          width: 720.wMin,
          height: 64.wMin,
          borderRadius: 12.wMin,
          color: AppTheme.cBgBrand,
          fontColor: AppTheme.cStaticWhite,
          fontSize: 28.wMin,
          fontWeight: FontWeight.w500,
          sclae: 1.01,
          onTap: () {
            controller.goToLearn();
          },
        );
      } else if (controller.runType.value == 2) {
        buttonWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16.wMin,
          children: [
            ButtonWidget(
              text: "联系客服",
              width: 500.wMin,
              height: 64.wMin,
              borderRadius: 12.wMin,
              color: AppTheme.cFeedbackWarningBorder,
              fontColor: AppTheme.cStaticWhite,
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.01,
              onTap: () {
                controller.contactCustomerService(context);
              },
            ),
            ButtonWidget(
              text: "请重试",
              width: 500.wMin,
              height: 64.wMin,
              borderRadius: 12.wMin,
              color: AppTheme.cFeedbackErrorBorder,
              fontColor: AppTheme.cStaticWhite,
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.01,
              onTap: () {
                controller.reGenerateCourse();
              },
            ),
          ],
        );
      }
      return Container(
        padding: EdgeInsets.only(top: 24.wMin, bottom: 64.wMin),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buttonWidget,
          ],
        ),
      );
    });
  }

  Widget _buildTitleWidget() {
    return Container(
      padding: EdgeInsets.all(10.wMin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.cFeedbackInfoBackground,
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      child: Text(
        controller.aiProcessStatus.value.courseDescription ??
            "根据您的创建信息，ISBN码，正在生成自定义课程……",
        style: TextStyle(
          fontSize: 24.wMin,
          color: AppTheme.cFeedbackInfoText,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildAnimationItemWidget(AiAnimationRunModel data) {
    bool isCompleted = data.isCompleted;
    int progress = data.process;
    String stepName = data.name;
    String statusDesc = data.error ? "" : (data.subName ?? '处理中');

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
                SizedBox(height: 4.wMin),
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
                            if (isCompleted) {
                              return Text(
                                isCompleted ? statusDesc : "$statusDesc...",
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
                                  color: AppTheme.cBgBrand,
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
                          "$progress%",
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
          Visibility(
            visible: data.value != null,
            child: Text(
              isCompleted ? data.value ?? "" : "",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary,
              ),
            ),
          ),
          SizedBox(width: 6.wMin),
          // 右侧完成状态图标
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: isCompleted
                ? SvgPicture.asset(
                    data.error
                        ? Assets.customCourseIconCheckErrCircle
                        : Assets.customCourseIconCheckOkCircle,
                    width: 36.wMin,
                    height: 36.wMin,
                  )
                : SpinKitDualRing(
                    color: AppTheme.cFeedbackDefaultIcon,
                    key: const ValueKey(false),
                    size: 36.wMin,
                    lineWidth: 2.wMin,
                    duration: const Duration(milliseconds: 300),
                  ),
          ),
        ],
      ),
    );
  }
}
