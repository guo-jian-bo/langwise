import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

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
    Widget textItem(String text, {Color? color, double? fontSize}) {
      return Text(
        text,
        style: TextStyle(
          fontSize: fontSize ?? 22.wMin,
          color: color ?? const Color(0xffEBEEF3),
          fontWeight: FontWeight.w400,
        ),
      );
    }

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
                return ManageQuizGridViewQuizWidget(
                  padding: EdgeInsets.only(
                    top: 24.wMin,
                    left: 24.wMin,
                    right: 24.wMin,
                    bottom: 24.wMin + MediaQuery.of(context).padding.bottom + 120.wMin,
                  ),
                  needsLongPressDraggable: false,
                  showStatus: true,
                  showCheck: controller.isOpenBatchOperation.value,
                  selectIds: controller.batchOperationIds.toList(),
                  datas: controller.lessonQuizList.toList(),
                  quizId: controller.quizId,
                  onReorder: (oldIndex, newIndex) {
                    controller.sortQuizList(oldIndex, newIndex);
                  },
                  onDel: (index) {
                    controller.showDeleteQuizDialog(context, index);
                  },
                  onTap: (index) {
                    controller.toDemonstrate(index);
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
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.wMin),
                child: PlatformBackdropFilterWidget(
                  sigmaX: 30,
                  sigmaY: 30,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 100.wMin),
                    padding: EdgeInsets.all(20.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.wMin),
                      border: Border.all(width: 1.wMin, color: const Color(0xff353E5C)),
                      color: const Color(0xff141828).withValues(alpha: 0.5),
                    ),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Row(
                              children: [
                                textItem("题目"),
                                SizedBox(width: 8.wMin),
                                Obx(() {
                                  return textItem("${controller.lessonQuizCount.value}", color: const Color(0xff2388FF), fontSize: 28.wMin);
                                }),
                                SizedBox(width: 8.wMin),
                                textItem("道"),
                              ],
                            ),
                            SizedBox(width: 40.wMin),
                            Row(
                              children: [
                                textItem("时长"),
                                SizedBox(width: 8.wMin),
                                Obx(() {
                                  double minutes = controller.lessonQuizTotalTime.value / 60;
                                  return textItem(minutes.toStringAsFixed(1), color: const Color(0xffFF781F), fontSize: 28.wMin);
                                }),
                                SizedBox(width: 8.wMin),
                                textItem("分钟"),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        ManageAuthBoxWidget(
                          authCodes: const [
                            ManageAuthCode.exercisePage,
                            ManageAuthCode.exerciseLessonBind,
                          ],
                          child: ButtonWidget(
                            text: "关联题目",
                            fontColor: const Color(0xffEBEFF5),
                            fontSize: 18.wMin,
                            height: 56.wMin,
                            borderRadius: 4.wMin,
                            sclae: 1.05,
                            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                            onTap: () {
                              controller.relatedTopics();
                            },
                          ),
                        ),
                        SizedBox(width: 12.wMin),
                        ButtonWidget(
                          text: "刷新列表",
                          fontColor: const Color(0xffEBEFF5),
                          fontSize: 18.wMin,
                          height: 56.wMin,
                          borderRadius: 4.wMin,
                          sclae: 1.05,
                          padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                          onTap: () {
                            controller.getLessonQuizList();
                          },
                        ),
                        SizedBox(width: 12.wMin),
                        Obx(() {
                          if (!controller.isOpenBatchOperation.value) return Container(height: 0);
                          return _buildBatchOperationWidget(context);
                        }),
                        ManageAuthBoxWidget(
                          authCodes: const [ManageAuthCode.exerciseOperationCode],
                          child: ButtonWidget(
                            text: "批量操作",
                            fontColor: const Color(0xffEBEFF5),
                            fontSize: 18.wMin,
                            height: 56.wMin,
                            borderRadius: 4.wMin,
                            sclae: 1.05,
                            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                            onTap: () {
                              controller.isOpenBatchOperation.value = !controller.isOpenBatchOperation.value;
                              if (!controller.isOpenBatchOperation.value) {
                                controller.batchOperationIds.clear();
                                controller.isSelectAll.value = false;
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 12.wMin),
                        ButtonWidget(
                          text: "模拟体验",
                          fontColor: const Color(0xffEBEFF5),
                          fontSize: 18.wMin,
                          height: 56.wMin,
                          borderRadius: 4.wMin,
                          sclae: 1.05,
                          padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                          onTap: () {
                            controller.toDemonstrate(0);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchOperationWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wMin),
      margin: EdgeInsets.only(right: 6.wMin),
      height: 56.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        color: const Color(0xff353E5C),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TapScaleWidget(
            onTap: () {
              controller.showBatchDeleteQuizDialog(context);
            },
            sclae: 1.05,
            child: _buildOptionWidget(
              "删除已选",
              const Color(0xffFF2D46),
            ),
          ),
          SizedBox(width: 12.wMin),
          TapScaleWidget(
            onTap: () {
              controller.upDownLessonQuiz(true);
            },
            sclae: 1.05,
            child: _buildOptionWidget("上架", const Color(0xff44AF5C)),
          ),
          SizedBox(width: 12.wMin),
          TapScaleWidget(
            onTap: () {
              controller.upDownLessonQuiz(false);
            },
            sclae: 1.05,
            child: _buildOptionWidget("下架", const Color(0xffFF2D46)),
          ),
          SizedBox(width: 12.wMin),
          TapScaleWidget(
            onTap: () {
              controller.selectPublished();
            },
            sclae: 1.05,
            child: Obx(() => _buildOptionWidget(
                  controller.isSelectAllPublished.value ? "取消全选上架" : "全选上架",
                  const Color(0xff465070),
                )),
          ),
          SizedBox(width: 12.wMin),
          TapScaleWidget(
            onTap: () {
              controller.selectUnPublished();
            },
            sclae: 1.05,
            child: Obx(() => _buildOptionWidget(
                  controller.isSelectAllUnPublished.value ? "取消全选下架" : "全选下架",
                  const Color(0xff465070),
                )),
          ),
          SizedBox(width: 12.wMin),
          TapScaleWidget(
            onTap: () {
              controller.selectAllQuiz();
            },
            sclae: 1.05,
            child: Obx(() => _buildOptionWidget(
                  controller.isSelectAll.value ? "取消全选" : "全选",
                  const Color(0xff465070),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionWidget(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: color),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18.wMin,
          color: const Color(0xffEBEFF5),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
