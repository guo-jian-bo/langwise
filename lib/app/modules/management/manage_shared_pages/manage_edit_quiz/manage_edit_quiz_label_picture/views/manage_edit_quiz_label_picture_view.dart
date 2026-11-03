import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_edit_quiz_label_picture_binding.dart';
import '../controllers/manage_edit_quiz_label_picture_controller.dart';

class ManageEditQuizLabelPictureView extends GetView<ManageEditQuizLabelPictureController> {
  final String tagText;
  const ManageEditQuizLabelPictureView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_EDIT_QUIZ_LABEL_PICTURE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageEditQuizLabelPictureView(tagText: tag),
      binding: ManageEditQuizLabelPictureBinding(tag: tag),
      routeName: Routes.MANAGE_EDIT_QUIZ_LABEL_PICTURE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: tagText,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: ManageScaffold(
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
                          buildWordWidget(context),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: EdgeInsets.all(50.wMin),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ButtonWidget(
                            text: "题型演示",
                            fontColor: const Color(0xffEBEFF5),
                            fontSize: 18.wMin,
                            color: const Color(0xFF353E5C),
                            width: 120.wMin,
                            height: 45.wMin,
                            borderRadius: 4.wMin,
                            sclae: 1.05,
                            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                            onTap: () {
                              controller.showQuizEditResult();
                            },
                          ),
                          SizedBox(width: 12.wMin),
                          ButtonWidget(
                            text: "保存",
                            fontColor: const Color(0xffEBEFF5),
                            fontSize: 18.wMin,
                            color: const Color(0xff2388FF),
                            width: 100.wMin,
                            height: 45.wMin,
                            borderRadius: 4.wMin,
                            sclae: 1.05,
                            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                            onTap: () {
                              controller.saveQuiz();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildBoxWidget(int index) {
    if (controller.showKnowledgeList[index].rect == Rect.zero) return Container();
    return Positioned(
      top: controller.showKnowledgeList[index].rect.top,
      left: controller.showKnowledgeList[index].rect.left,
      child: TapScaleWidget(
        onTap: controller.selectKnowledgeIndex.value == index
            ? null
            : () {
                controller.changeSelectIndex(index);
              },
        sclae: 1.01,
        child: Container(
          padding: EdgeInsets.all(5.wMin),
          width: controller.showKnowledgeList[index].rect.width,
          height: controller.showKnowledgeList[index].rect.height,
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
                controller.showKnowledgeList[index].option?.text ?? "",
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
    if (controller.showKnowledgeList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      return ClipRRect(
        borderRadius: BorderRadius.circular(30.wMin),
        child: DrawBoxWidget(
          initRect: controller.showKnowledgeList[controller.selectKnowledgeIndex.value].rect,
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
                image: NetworkImage(controller.labelImageUrl),
              ),
            ),
            child: Stack(
              children: List.generate(controller.showKnowledgeList.length, (index) {
                return buildBoxWidget(index);
              }),
            ),
          ),
        ),
      );
    });
  }

  Widget buildWordWidget(BuildContext context) {
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
                text: "重新生成",
                height: 40.wMin,
                borderRadius: 6.wMin,
                color: const Color(0xff353E5C),
                fontSize: 14.wMin,
                fontColor: const Color(0xffEBEEF3),
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                onTap: () {
                  controller.reGenerate(context);
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
            child: controller.showKnowledgeList.isNotEmpty
                ? Obx(() {
                    return Wrap(
                      spacing: 24.wMin,
                      runSpacing: 24.wMin,
                      children: List.generate(controller.showKnowledgeList.length, (int index) {
                        return SizedBox(
                          height: 290.wMin,
                          child: ManagePublicKnowledeRowItemWidget(
                            selected: controller.selectKnowledgeIndex.value == index,
                            isSingle: true,
                            content: controller.showKnowledgeList[index].option?.text,
                            definition: controller.showKnowledgeList[index].option?.explanation?.first?.text,
                            imageUrl: controller.showKnowledgeList[index].option?.imageUrl,
                            difficulty: controller.showKnowledgeList[index].option?.difficulty,
                            language: 'en',
                            audioUrl: controller.showKnowledgeList[index].option?.audioUrl,
                            onTap: () {
                              controller.changeSelectIndex(index);
                            },
                          ),
                        );
                      }),
                    );
                  })
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
