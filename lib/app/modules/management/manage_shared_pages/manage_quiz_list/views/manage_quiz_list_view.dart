import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_quiz_list_binding.dart';
import '../controllers/manage_quiz_list_controller.dart';

class ManageQuizListView extends GetView<ManageQuizListController> {
  final String tagText;
  const ManageQuizListView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_QUIZ_LIST}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageQuizListView(tagText: tag),
      binding: ManageQuizListBinding(tag: tag),
      routeName: Routes.MANAGE_QUIZ_LIST,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.only(
          top: 20.wh,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned.fill(
              child: Obx(() {
                final quizList = controller.filteredLessonQuizList;
                return ManageQuizGridViewQuizWidget(
                  padding: EdgeInsets.only(
                    top: 24.wMin,
                    left: 24.wMin,
                    right: 24.wMin,
                    bottom: 24.wMin + MediaQuery.of(context).padding.bottom + 140.wMin,
                  ),
                  needsLongPressDraggable: controller.currentFilter.value != "all",
                  showStatus: true,
                  showCheck: true,
                  selectIds: controller.batchOperationIds.toList(),
                  datas: quizList,
                  quizId: controller.quizId,
                  onReorder: controller.currentFilter.value == "all"
                      ? (oldIndex, newIndex) {
                          controller.sortQuizList(oldIndex, newIndex);
                        }
                      : null,
                  onTap: (index) {
                    final actualIndex = controller.lessonQuizList.indexWhere((item) => item.uid == quizList[index].uid);
                    if (actualIndex < 0) return;
                    controller.toDemonstrate(actualIndex);
                  },
                  onSelect: (uid) {
                    controller.selectQuiz(uid);
                  },
                );
              }),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: _buildBottomToolbar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomToolbar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 60.wMin),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: PlatformBackdropFilterWidget(
          sigmaX: 4.wMin,
          sigmaY: 4.wMin,
          child: Container(
            height: 80.wMin,
            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: AppTheme.cSurfaceSearchBackground.color,
              border: Border.all(
                color: AppTheme.cBorderDark.color,
                width: 1.wMin,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildLeftGroup(),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _buildCenterGroup(context),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildRightGroup(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftGroup() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.bookUnitLessonRefresh],
          child: _buildToolbarButton(
            text: "刷新课时计划",
            color: const Color(0xff0EA5E9),
            onTap: () {
              controller.refreshLessonPlan();
            },
          ),
        ),
        SizedBox(width: 12.wMin),
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.bookUnitLessonExercise],
          child: _buildToolbarButton(
            text: "重新生成题目",
            color: const Color(0xff0EA5E9),
            onTap: () {
              controller.regenerateLessonQuiz();
            },
          ),
        ),
        SizedBox(width: 12.wMin),
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.exerciseV2Create],
          child: _buildToolbarButton(
            text: "新建题目",
            color: const Color(0xff0EA5E9),
            onTap: () {
              controller.toSelectKnowledgePage();
            },
          ),
        ),
        SizedBox(width: 12.wMin),
        ManageAuthBoxWidget(
          authCodes: const [
            ManageAuthCode.exercisePage,
            ManageAuthCode.exerciseLessonBind,
          ],
          child: _buildToolbarButton(
            text: "关联题目",
            color: Colors.transparent,
            border: Border.all(width: 1.wMin, color: const Color(0xff0EA5E9)),
            onTap: () {
              controller.relatedTopics();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCenterGroup(BuildContext context) {
    return ManageAuthBoxWidget(
      authCodes: const [ManageAuthCode.exerciseOperationCode],
      child: _buildGroupContainer(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionChip(
              text: "全选",
              color: const Color(0xffE2E8F0),
              fontColor: const Color(0xff0F172A),
              onTap: () {
                controller.selectAllFilteredQuiz();
              },
            ),
            SizedBox(width: 8.wMin),
            _buildActionChip(
              text: "取消全选",
              color: const Color(0xffE2E8F0),
              fontColor: const Color(0xff0F172A),
              onTap: () {
                controller.clearFilteredSelection();
              },
            ),
            SizedBox(width: 12.wMin),
            _buildActionChip(
              text: "上架",
              color: const Color(0xff44AF5C),
              onTap: () {
                controller.upDownLessonQuiz(true);
              },
            ),
            SizedBox(width: 8.wMin),
            _buildActionChip(
              text: "下架",
              color: const Color(0xffFB923C),
              onTap: () {
                controller.upDownLessonQuiz(false);
              },
            ),
            SizedBox(width: 8.wMin),
            _buildActionChip(
              text: "删除",
              color: const Color(0xffF43F5E),
              onTap: () {
                controller.showBatchDeleteQuizDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightGroup() {
    return Obx(() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildGroupContainer(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterChip(
                  text: "全部",
                  count: controller.lessonQuizCount.value,
                  color: const Color(0xffE2E8F0),
                  activeColor: const Color(0xff0EA5E9),
                  isActive: controller.currentFilter.value == "all",
                  onTap: () {
                    controller.changeFilter("all");
                  },
                ),
                SizedBox(width: 8.wMin),
                _buildFilterChip(
                  text: "上架",
                  count: controller.publishedQuizCount,
                  color: const Color(0xffE2E8F0),
                  activeColor: const Color(0xff44AF5C),
                  isActive: controller.currentFilter.value == "published",
                  onTap: () {
                    controller.changeFilter("published");
                  },
                ),
                SizedBox(width: 8.wMin),
                _buildFilterChip(
                  text: "下架",
                  count: controller.unpublishedQuizCount,
                  color: const Color(0xffE2E8F0),
                  activeColor: const Color(0xffFB923C),
                  isActive: controller.currentFilter.value == "unpublished",
                  onTap: () {
                    controller.changeFilter("unpublished");
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 12.wMin),
          _buildToolbarButton(
            text: "模拟体验",
            gradient: const LinearGradient(
              colors: [
                Color(0xffA855F7),
                Color(0xff7C3AED),
              ],
            ),
            onTap: () {
              final quizList = controller.filteredLessonQuizList;
              if (quizList.isEmpty) {
                ToastUtils.showManageToast(text: "暂无题目可体验");
                return;
              }
              final actualIndex = controller.lessonQuizList.indexWhere((item) => item.uid == quizList.first.uid);
              if (actualIndex < 0) return;
              controller.toDemonstrate(actualIndex);
            },
          ),
        ],
      );
    });
  }

  Widget _buildGroupContainer({required Widget child}) {
    return Container(
      height: 56.wMin,
      padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppTheme.cSurfaceSearchBackground.color,
        border: Border.all(
          color: AppTheme.cBorderDark.color,
          width: 0.8.wMin,
        ),
      ),
      child: child,
    );
  }

  Widget _buildToolbarButton({
    required String text,
    Color? color,
    Gradient? gradient,
    Border? border,
    VoidCallback? onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.03,
      child: Container(
        height: 56.wMin,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          gradient: gradient,
          border: border,
          borderRadius: BorderRadius.circular(999.wMin),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18.wMin,
            color: const Color(0xffEBEFF5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required String text,
    required Color color,
    Color fontColor = const Color(0xffEBEFF5),
    VoidCallback? onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.03,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 10.wMin),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999.wMin),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.wMin,
            color: fontColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String text,
    required int count,
    required Color color,
    required Color activeColor,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    final Color backgroundColor = isActive ? activeColor : Colors.transparent;
    final Color textColor = isActive ? const Color(0xffEBEFF5) : AppTheme.cTextSecondary.color;
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.03,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 10.wMin),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999.wMin),
        ),
        child: Text(
          "$text $count",
          style: TextStyle(
            fontSize: 16.wMin,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
