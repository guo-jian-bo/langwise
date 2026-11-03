import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../../routes/routes.dart';
import '../../../../../common/commons.dart';
import '../bindings/manage_quiz_label_picture_images_binding.dart';
import '../controllers/manage_quiz_label_picture_images_controller.dart';

class ManageQuizLabelPictureImagesView extends GetView<ManageQuizLabelPictureImagesController> {
  final String tagText;
  const ManageQuizLabelPictureImagesView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_QUIZ_LABEL_PICTURE_IMAGES}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageQuizLabelPictureImagesView(tagText: tag),
      binding: ManageQuizLabelPictureImagesBinding(tag: tag),
      routeName: Routes.MANAGE_QUIZ_LABEL_PICTURE_IMAGES,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildImageWigdet(int? styleId, ManageLabelPictureEntityImageStyleInfoListImageInfoList? image, int index) {
      return TapScaleWidget(
        onTap: () => controller.selectImage(styleId, image),
        sclae: 1.05,
        child: Container(
          padding: EdgeInsets.all(8.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            border: Border.all(
              width: 1.wMin,
              color: controller.selectImageMap[styleId]?.imageId == image?.imageId ? const Color(0xff353E5C) : Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${index + 1}",
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 3.wMin),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.wMin),
                child: Container(
                  width: 126.wMin,
                  height: 126.wMin,
                  color: Colors.white.withValues(alpha: 0.1),
                  child: CachedImageWidget(
                    image?.imageUrl ?? "",
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildRowWidget(ManageLabelPictureEntityImageStyleInfoList data) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: EdgeInsets.all(24.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            color: const Color(0xff141828),
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 24.wMin,
              children: [
                ...List.generate(data.imageInfoList?.length ?? 0, (index) {
                  return buildImageWigdet(data.styleId, data.imageInfoList![index], index);
                }),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      data.styleName ?? "",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: const Color(0xffEBEFF5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TapScaleWidget(
                      onTap: () {
                        controller.regenerateImage(data);
                      },
                      sclae: 1.05,
                      child: Container(
                        width: 150.wMin,
                        padding: EdgeInsets.symmetric(vertical: 8.wMin),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.wMin),
                          color: const Color(0xff353E5C),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/svg/manage/icon_refresh.svg",
                              width: 24.wMin,
                            ),
                            Text(
                              "重新生成",
                              style: TextStyle(
                                fontSize: 18.wMin,
                                color: const Color(0xffEBEFF5),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ManageScaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Obx(() {
                if (controller.resultState.value == -1) return Container();
                if (controller.resultState.value == 1) {
                  return Container(
                    margin: EdgeInsets.only(top: 300.wMin, left: 250.wMin),
                    child: SvgPicture.asset(
                      "assets/svg/manage/icon_not_data.svg",
                      width: 200.wMin,
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.only(top: 20.wh, bottom: MediaQuery.of(context).padding.bottom, left: 40.wMin),
                  child: Obx(() {
                    return Column(
                      spacing: 8.wMin,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(controller.imagesData.length, (index) {
                        return buildRowWidget(controller.imagesData[index]);
                      }),
                    );
                  }),
                );
              }),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(() {
                  if (controller.resultState.value == -1) return Container();
                  if (controller.resultState.value == 1) {
                    return ManageQuizSettingButtons(
                      onButton0: () {
                        Get.back();
                      },
                      button1Text: "放弃生成",
                      button1Color: const Color(0xff353E5C),
                      button1BorderColor: const Color(0xff353E5C),
                      onButton1: () {
                        controller.giveUp();
                      },
                      button2Text: "重新生成",
                      onButton2: () {
                        controller.reGenerate();
                      },
                      button3Text: "下一步",
                      onButton3: () {
                        controller.nextButton();
                      },
                    );
                  }
                  return ManageQuizSettingButtons(
                    onButton0: () {
                      Get.back();
                    },
                    button1Text: "放弃生成",
                    button1Color: const Color(0xff353E5C),
                    button1BorderColor: const Color(0xff353E5C),
                    onButton1: () {
                      controller.giveUp();
                    },
                    button2Text: "重新生成",
                    onButton2: () {
                      controller.reGenerate();
                    },
                    button3Text: "下一步",
                    onButton3: () {
                      controller.nextButton();
                    },
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
