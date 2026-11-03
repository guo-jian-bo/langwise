import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/theme/theme_quiz_utils.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../bindings/official_course_details_lesson_quiz_list_binding.dart';
import '../controllers/official_course_details_controller.dart';
import '../controllers/official_course_details_lesson_quiz_list_controller.dart';

class OfficialCourseDetailsLessonQuizListView extends GetView<OfficialCourseDetailsLessonQuizListController> {
  final String tagText;
  const OfficialCourseDetailsLessonQuizListView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => OfficialCourseDetailsLessonQuizListView(tagText: tag),
      binding: OfficialCourseDetailsLessonQuizListBinding(tagText: tag),
      routeName: Routes.OFFICIAL_COURSE_DETAILS_LESSON_QUIZ_LIST,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Column(
        children: [
          const BreadcrumbWidget(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center();
              }

              final data = controller.lessonQuizData.value;
              if (data == null || data.quizList.isEmpty) {
                return Center(
                  child: Text(
                    "暂无题目",
                    style: TextStyle(
                      fontSize: 22.wMin,
                      color: AppTheme.cTextQuaternary.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }

              return _buildQuizGridWidget(data);
            }),
          ),
        ],
      ),
    );
  }

  /// 构建题目网格区域。
  Widget _buildQuizGridWidget(LessonQuizData data) {
    final style = ThemeQuizUtils.getQuizPlayStyle();
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 16.wMin),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 18.wMin,
        mainAxisSpacing: 18.wMin,
        childAspectRatio: 1.75,
      ),
      itemCount: data.quizList.length,
      itemBuilder: (context, index) {
        final quiz = data.quizList[index];
        final number = (index + 1).toString().padLeft(3, "0");
        final isCurrent = controller.currentIndex.value == index;
        return TapScaleWidget(
          onTap: () async {
            await controller.openQuiz(index);
          },
          sclae: 1.01,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              border: Border.all(color: AppTheme.cBorderSecondary.color),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: QuizPublicQuizWidget(
                    borderRadius: 16,
                    data: quiz,
                    quizPlayStyle: style,
                    bgColor: AppTheme.cSurfaceSecondary.color.withValues(alpha: 0.0),
                  ),
                ),
                Positioned(
                  top: 10.wMin,
                  left: 10.wMin,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfacePrimary.color.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10.wMin),
                      border: Border.all(color: AppTheme.cBorderSecondary.color.withValues(alpha: 0.6)),
                    ),
                    child: Text(
                      number,
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color: AppTheme.cTextSecondary.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10.wMin,
                  right: 10.wMin,
                  child: _buildIndicatorBadge(
                    purpose: quiz.purpose,
                    result: quiz.result,
                    isCurrent: isCurrent,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndicatorBadge({
    required String? purpose,
    required String? result,
    required bool isCurrent,
  }) {
    final p = purpose ?? '';
    if (p.isEmpty) return const SizedBox.shrink();
    final value = p.substring(0, 1);
    final LearnTypeColors bgBorderColor = StatusUtils.getLearnTypeColor(
      p,
      result: result,
      isCurrent: isCurrent,
    );
    return Transform.scale(
      scale: isCurrent ? 1.08 : 1,
      child: Container(
        width: 27.wMin,
        height: 27.wMin,
        padding: EdgeInsets.only(top: 1.wMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgBorderColor.statusBgColor,
          border: Border.all(
            color: bgBorderColor.statusBorderColor,
            width: 2.wMin,
          ),
          boxShadow: [
            BoxShadow(
              color: bgBorderColor.shadowTypeColor,
              blurRadius: 2.wMin,
              spreadRadius: 3.wMin,
            ),
          ],
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.cStaticWhite.color,
            fontSize: 18.wMin,
            fontWeight: FontWeight.w800,
            fontFamily: "LangWiseFont",
            height: 1,
          ),
        ),
      ),
    );
  }
}
