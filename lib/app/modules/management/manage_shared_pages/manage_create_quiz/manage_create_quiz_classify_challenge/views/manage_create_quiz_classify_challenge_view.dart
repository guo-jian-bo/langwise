import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/component/button_widgets.dart';
import 'package:quiz_play/component/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_create_quiz_classify_challenge_binding.dart';
import '../controllers/manage_create_quiz_classify_challenge_controller.dart';

class ManageCreateQuizClassifyChallengeView extends GetView<ManageCreateQuizClassifyChallengeController> {
  final String tagText;
  const ManageCreateQuizClassifyChallengeView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CREATE_QUIZ_CLASSIFY_CHALLENGE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageCreateQuizClassifyChallengeView(tagText: tag),
      binding: ManageCreateQuizClassifyChallengeBinding(tag: tag),
      routeName: Routes.MANAGE_CREATE_QUIZ_CLASSIFY_CHALLENGE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: ManageScaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 24.wMin, top: 24.wMin),
                  child: Text(
                    "手动创建",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: const Color(0xffACB4C0),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 20.wMin),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      key: controller.dialogKey,
                      margin: EdgeInsets.symmetric(horizontal: 24.wMin),
                      padding: EdgeInsets.only(top: 16.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin),
                        color: const Color(0xff22293C),
                      ),
                      child: Column(
                        spacing: 16.wMin,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildKnowledgeListWidget(),
                          ...List.generate(controller.classList.length, (index) {
                            return buildClassListWidget(index);
                          }),
                          Padding(
                            padding: EdgeInsets.all(20.wMin),
                            child: TapScaleWidget(
                              scale: 1.01,
                              onTap: () {
                                controller.addOption(context);
                              },
                              child: DottedBorder(
                                radius: Radius.circular(8.wMin),
                                borderType: BorderType.RRect,
                                padding: EdgeInsets.zero,
                                color: const Color(0xff444B5F),
                                dashPattern: const [3, 2],
                                strokeWidth: 1.wMin,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 20.wMin),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/svg/manage/icon_add.svg",
                                        height: 22.wMin,
                                      ),
                                      Text(
                                        "添加分类",
                                        style: TextStyle(
                                          fontSize: 16.wMin,
                                          color: const Color(0xffEAECFF),
                                          fontWeight: FontWeight.w400,
                                        ),
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
                  ),
                ),
                SizedBox(height: 24.wMin),
                Row(
                  children: [
                    const Spacer(),
                    ButtonWidget(
                      text: "取消",
                      fontColor: const Color(0xffEBEFF5),
                      color: Colors.transparent,
                      border: Border.all(width: 2.wMin, color: const Color(0xff353E5C)),
                      fontSize: 18.wMin,
                      width: 100.wMin,
                      height: 45.wMin,
                      borderRadius: 4.wMin,
                      sclae: 1.05,
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                      onTap: () {
                        Get.back();
                      },
                    ),
                    SizedBox(width: 12.wMin),
                    ButtonWidget(
                      text: "创建",
                      fontColor: const Color(0xffEBEFF5),
                      fontSize: 18.wMin,
                      color: const Color(0xff2388FF),
                      width: 100.wMin,
                      height: 45.wMin,
                      borderRadius: 4.wMin,
                      sclae: 1.05,
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                      onTap: () {
                        controller.createQuiz();
                      },
                    ),
                    SizedBox(width: 24.wMin),
                  ],
                ),
                SizedBox(height: 24.wMin),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildKnowledgeListWidget() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24.wMin,
        children: List.generate(controller.unitKnowledgeList?.length ?? 0, (index) {
          return SizedBox(
            height: 290.wMin,
            child: ManagePublicKnowledeRowItemWidget(
              onTap: () {
                if (controller.selectKnowledgeIndexs.contains(index)) {
                  controller.selectKnowledgeIndexs.remove(index);
                } else {
                  controller.selectKnowledgeIndexs.add(index);
                }
                controller.update();
              },
              selected: controller.selectKnowledgeIndexs.contains(index),
              isFore: !controller.selectUnIndexs.contains(index),
              content: controller.unitKnowledgeList?[index].content ?? "",
              imageUrl: controller.unitKnowledgeList?[index].imageUrl ?? "",
              language: controller.language,
              difficulty: controller.unitKnowledgeList?[index].difficulty?.min ?? 0,
              audioUrl: controller.unitKnowledgeList?[index].audioUrl ?? "",
              definition: controller.unitKnowledgeList?[index].definition ?? "",
            ),
          );
        }),
      ),
    );
  }

  Widget buildClassListWidget(int index) {
    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: const Color(0xff141828).withValues(alpha: 0.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TapScaleWidget(
            onTap: () {
              for (int i = 0; i < controller.classList[index].selectIndex.length; i++) {
                controller.selectUnIndexs.remove(controller.classList[index].selectIndex[i]);
              }
              controller.classList.removeAt(index);
              controller.update();
            },
            child: Container(
              color: Colors.transparent,
              child: SvgPicture.asset(
                "assets/svg/manage/icon_close.svg",
                width: 24.wMin,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DottedBorder(
                radius: Radius.circular(8.wMin),
                borderType: BorderType.RRect,
                padding: EdgeInsets.zero,
                color: const Color(0xff444B5F),
                dashPattern: const [3, 2],
                child: Container(
                  padding: EdgeInsets.only(left: 12.wMin, right: 12.wMin, bottom: 12.wMin),
                  width: 180.wMin,
                  height: 265.wMin,
                  child: Stack(
                    children: [
                      Column(
                        spacing: 16.wMin,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                controller.classList[index].classData.content ?? "",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  color: const Color(0xffEBEEF3),
                                  fontWeight: FontWeight.w400,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                          ButtonWidget(
                            text: "添加到当前分类",
                            sclae: 1.03,
                            borderRadius: 6.wMin,
                            color: const Color(0xff353E5C),
                            fontSize: 14.wMin,
                            height: 40.wMin,
                            fontColor: const Color(0xffACB4C0),
                            onTap: () {
                              if (controller.selectKnowledgeIndexs.isEmpty) {
                                ToastUtils.showManageToast(text: "请先选择知识点", containerKey: controller.dialogKey);
                                return;
                              }
                              controller.selectUnIndexs.addAll(controller.selectKnowledgeIndexs);
                              controller.classList[index].selectIndex.addAll(controller.selectKnowledgeIndexs);
                              controller.selectKnowledgeIndexs.clear();
                              controller.update();
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 24.wMin,
                    children: List.generate(controller.classList[index].selectIndex.length, (index1) {
                      int selectIndex = controller.classList[index].selectIndex[index1];
                      return SizedBox(
                        height: 290.wMin,
                        child: ManagePublicKnowledeRowItemWidget(
                          onTR: () {
                            controller.selectUnIndexs.remove(selectIndex);
                            controller.classList[index].selectIndex.removeAt(index1);
                            controller.update();
                          },
                          svg: "assets/svg/manage/icon_bg_delete.svg",
                          content: controller.unitKnowledgeList?[selectIndex].content ?? "",
                          definition: controller.unitKnowledgeList?[selectIndex].definition ?? "",
                          imageUrl: controller.unitKnowledgeList?[selectIndex].imageUrl ?? "",
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
