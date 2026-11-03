import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/theme/theme_quiz_utils.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../controllers/official_course_details_controller.dart';

class OfficialCourseDetailsLessonQuizListPage extends StatefulWidget {
  final String tagText;
  final int unitId;
  final int lessonId;
  final String levelTitle;
  final String moduleTitle;
  final String? title;

  const OfficialCourseDetailsLessonQuizListPage({
    super.key,
    required this.tagText,
    required this.unitId,
    required this.lessonId,
    required this.levelTitle,
    required this.moduleTitle,
    this.title,
  });

  @override
  State<OfficialCourseDetailsLessonQuizListPage> createState() => _OfficialCourseDetailsLessonQuizListPageState();
}

class _OfficialCourseDetailsLessonQuizListPageState extends State<OfficialCourseDetailsLessonQuizListPage> {
  late final OfficialCourseDetailsController controller;
  late Future<LessonQuizData?> _future;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OfficialCourseDetailsController>(tag: widget.tagText);
    _future = controller.fetchLessonQuizData(context, widget.unitId, widget.lessonId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24.wMin,
              left: 40.wMin,
              right: 40.wMin,
              bottom: 16.wMin,
            ),
            child: Row(
              children: [
                const BackWidget(),
                Expanded(
                  child: Row(
                    children: [
                      TapScaleWidget(
                        sclae: 1.02,
                        onTap: () {
                          if (Get.key.currentState?.canPop() ?? false) {
                            Get.back();
                          }
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            controller.toLevel();
                          });
                        },
                        child: Text(
                          widget.levelTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 28.wMin,
                            color: AppTheme.cTextPrimary.color.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        " / ",
                        style: TextStyle(
                          fontSize: 28.wMin,
                          color: AppTheme.cTextPrimary.color.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TapScaleWidget(
                        sclae: 1.02,
                        onTap: () {
                          Get.back();
                        },
                        child: Text(
                          widget.moduleTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 28.wMin,
                            color: AppTheme.cTextPrimary.color.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        " / ",
                        style: TextStyle(
                          fontSize: 28.wMin,
                          color: AppTheme.cTextPrimary.color.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.title ?? "题目列表",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 28.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<LessonQuizData?>(
              future: _future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center();
                }
                final data = snapshot.data;
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
                    final isCurrent = _currentIndex == index;
                    return TapScaleWidget(
                      onTap: () async {
                        setState(() {
                          _currentIndex = index;
                        });
                        await controller.toQuizPage(
                          widget.unitId,
                          widget.lessonId,
                          quiz.uid ?? data.exerciseCurrentId,
                          data.quizList,
                        );
                        if (!mounted) return;
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (!mounted) return;
                        setState(() {
                          _future = controller.fetchLessonQuizData(context, widget.unitId, widget.lessonId);
                        });
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
