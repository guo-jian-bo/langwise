import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../../routes/routes.dart';
import '../../../../../common/commons.dart';
import '../bindings/manage_quiz_label_picture_setting_binding.dart';
import '../controllers/manage_quiz_label_picture_setting_controller.dart';

class ManageQuizLabelPictureSettingView extends GetView<ManageQuizLabelPictureSettingController> {
  final String tagText;
  const ManageQuizLabelPictureSettingView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_QUIZ_LABEL_PICTURE_SETTING}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageQuizLabelPictureSettingView(tagText: tag),
      binding: ManageQuizLabelPictureSettingBinding(tag: tag),
      routeName: Routes.MANAGE_QUIZ_LABEL_PICTURE_SETTING,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBoxWidget(int index) {
      if (controller.imageInfoList[controller.currentImageIndex.value].showKnowledgeList[index].rect == Rect.zero) return Container();
      return Positioned(
        top: controller.imageInfoList[controller.currentImageIndex.value].showKnowledgeList[index].rect.top,
        left: controller.imageInfoList[controller.currentImageIndex.value].showKnowledgeList[index].rect.left,
        child: TapScaleWidget(
          onTap: controller.selectKnowledgeIndex.value == index
              ? null
              : () {
                  controller.changeSelectIndex(index);
                },
          sclae: 1.01,
          child: Container(
            padding: EdgeInsets.all(5.wMin),
            width: controller.imageInfoList[controller.currentImageIndex.value].showKnowledgeList[index].rect.width,
            height: controller.imageInfoList[controller.currentImageIndex.value].showKnowledgeList[index].rect.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              gradient: LinearGradient(
                colors: [
                  const Color(0xff757575).withValues(alpha: 0.08),
                  const Color(0xffDDDDDD).withValues(alpha: 0.29),
                ],
              ),
            ),
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: Radius.circular(12.wMin),
              dashPattern: [5.wMin, 5.wMin],
              padding: EdgeInsets.zero,
              strokeCap: StrokeCap.round,
              strokeWidth: 3.wMin,
              color: Colors.white,
              child: Container(
                alignment: Alignment.center,
                child: AutoSizeText(
                  controller.imageInfoList[controller.currentImageIndex.value].showKnowledgeList[index].data.content ?? "",
                  minFontSize: 2,
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48.wMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget buildImageWidget() {
      return Obx(() {
        return ClipRRect(
          borderRadius: BorderRadius.circular(30.wMin),
          child: DrawBoxWidget(
            initRect: controller.imageInfoList[controller.currentImageIndex.value].showKnowledgeList[controller.selectKnowledgeIndex.value].rect,
            width: 720.wMin,
            height: 720.wMin,
            onBoxChanged: (rect) => controller.drawBox(rect, 720.wMin),
            child: Container(
              width: 720.wMin,
              height: 720.wMin,
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                image: DecorationImage(
                  image: NetworkImage(controller.imageInfoList[controller.currentImageIndex.value].imageInfo.imageUrl ?? ""),
                ),
              ),
              child: Stack(
                children: List.generate(controller.imageInfoList[controller.currentImageIndex.value].showKnowledgeList.length, (index) {
                  return buildBoxWidget(index);
                }),
              ),
            ),
          ),
        );
      });
    }

    Widget buildWordWidget() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 370.wMin,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 16.wMin,
              children: [
                ButtonWidget(
                  sclae: 1.05,
                  text: "重新标注",
                  height: 40.wMin,
                  borderRadius: 6.wMin,
                  color: Colors.transparent,
                  fontSize: 14.wMin,
                  fontColor: const Color(0xffEBEEF3),
                  padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                  border: Border.all(width: 1.wMin, color: const Color(0xff767E95)),
                  onTap: () {
                    controller.reAnnotation();
                  },
                ),
                ButtonWidget(
                  sclae: 1.05,
                  text: "清空标注",
                  height: 40.wMin,
                  borderRadius: 6.wMin,
                  color: const Color(0xff353E5C),
                  fontSize: 14.wMin,
                  fontColor: const Color(0xffEBEEF3),
                  padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                  onTap: () {
                    controller.clearAnnotation();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16.wMin),
          Text(
            "选择单词，然后画框",
            style: TextStyle(
              fontSize: 22.wMin,
              color: const Color(0xffEBEFF5),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 16.wMin),
          SizedBox(
            width: 370.wMin,
            child: SingleChildScrollView(
              child: Obx(() {
                return Wrap(
                  spacing: 24.wMin,
                  runSpacing: 24.wMin,
                  children: List.generate(controller.imageInfoList[controller.currentImageIndex.value].showKnowledgeList.length, (int index) {
                    return SizedBox(
                      height: 290.wMin,
                      child: ManagePublicKnowledeRowItemWidget(
                        selected: controller.selectKnowledgeIndex.value == index,
                        isSingle: true,
                        content: controller.imageInfoList[controller.currentImageIndex.value].showKnowledgeList[index].data.content,
                        definition: controller.imageInfoList[controller.currentImageIndex.value].showKnowledgeList[index].data.definition,
                        imageUrl: controller.imageInfoList[controller.currentImageIndex.value].showKnowledgeList[index].data.imageUrl,
                        difficulty: controller.imageInfoList[controller.currentImageIndex.value].showKnowledgeList[index].data.difficulty?.min,
                        language: controller.language,
                        audioUrl: controller.imageInfoList[controller.currentImageIndex.value].showKnowledgeList[index].data.audioUrl,
                        onTap: () {
                          controller.changeSelectIndex(index);
                        },
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
        ],
      );
    }

    return ManageScaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 116.wMin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildImageWidget(),
                    SizedBox(width: 64.wMin),
                    buildWordWidget(),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(24.wMin),
              child: Obx(() {
                String text = "下一步";
                if (controller.nextButtonTextType.value == 0) {
                  text = "下一步";
                } else if (controller.nextButtonTextType.value == 1) {
                  text = "下个知识点";
                } else if (controller.nextButtonTextType.value == 2) {
                  text = "下张图片";
                }
                return ManageQuizSettingButtons(
                  button1Text: "取消",
                  onButton1: () {
                    Get.back();
                  },
                  button2Text: text,
                  onButton2: () {
                    controller.nextButton();
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
