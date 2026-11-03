import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import '../controllers/custom_course_manage_photos_controller.dart';
import '../../../../../theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/common/widgets/widgets.dart';

import '../bindings/custom_course_manage_photos_binding.dart';
import '../models/custom_course_manage_photos_model.dart';

class CustomCourseManagePhotosView
    extends GetView<CustomCourseManagePhotosController> {
  final String tagText;
  const CustomCourseManagePhotosView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      CustomCourseManagePhotosView(tagText: tag),
      binding: CustomCourseManagePhotosBinding(tagText: tag),
      routeName: Routes.CUSTOM_COURSE_MANAGE_PHOTOS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.scrollToLast();
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.cBgPrimary,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Obx(
                    () => Padding(
                      padding: EdgeInsets.only(
                          top: 100.wMin,
                          left: 30.wMin,
                          right: 30.wMin,
                          bottom: 30.wMin),
                      child: RawScrollbar(
                        controller: controller.scrollController, // 添加controller
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: ReorderableListView(
                          scrollController:
                              controller.scrollController, // 添加scrollController
                          scrollDirection: Axis.horizontal,
                          buildDefaultDragHandles: true,
                          proxyDecorator: (child, index, animation) {
                            return Material(
                              color: Colors.transparent,
                              child: child,
                            );
                          },
                          onReorder: (oldIndex, newIndex) {
                            controller.changeCardPosition(oldIndex, newIndex);
                          },
                          children: imageWidgets(),
                        ),
                      ),
                    ),
                  ),
                ),
                _bottomWidget(),
              ],
            ),
            Positioned(
              top: 20.wMin,
              right: 20.wMin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        '为保证识别准确，请仅保留包含单词列表的页面。',
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextPrimary,
                        ),
                      ),
                      SvgPicture.asset(
                        "assets/svg/custom_course/icon_course_tip.svg",
                        width: 26.wMin,
                        height: 26.wMin,
                        colorFilter: ColorFilter.mode(
                          AppTheme.cTextPrimary.color,
                          BlendMode.srcIn,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20.wMin),
                  Obx(
                    () => Visibility(
                      visible: !controller.isShowTip.value,
                      child: Container(
                        width: 240.wMin,
                        decoration: BoxDecoration(
                          color: AppTheme.cBgQuaternary,
                          borderRadius: BorderRadius.circular(10.wMin),
                        ),
                        child: Padding(
                            padding: EdgeInsets.all(15.0.wMin),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '长按并拖拽知识点卡片至知识点暂存区可以调整页面顺序哦',
                                  style: TextStyle(
                                    fontSize: 20.wMin,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.cTextPrimary,
                                  ),
                                ),
                                SizedBox(height: 20.wMin),
                                TapScaleWidget(
                                  onTap: () {
                                    controller.isShowTip.value = true;
                                  },
                                  sclae: 1.1,
                                  child: Text(
                                    '知道了',
                                    style: TextStyle(
                                      fontSize: 20.wMin,
                                      color: AppTheme.cTextBrand,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> imageWidgets() {
    List<Widget> widgets = [];
    for (int index = 0; index < controller.imagesList.length; index++) {
      widgets.add(Row(
        key: ValueKey(index),
        mainAxisSize: MainAxisSize.min,
        children: [
          ReorderableDelayedDragStartListener(
            index: index,
            child: _imageWidget(index, controller.imagesList[index]),
          ),
          SizedBox(width: 30.wMin),
        ],
      ));
    }
    widgets.add(_addImageWidget());
    return widgets;
  }

  Widget _addImageWidget() {
    return AspectRatio(
      key: const ValueKey('add_button'),
      aspectRatio: 2 / 3,
      child: GestureDetector(
        onTap: () {
          controller.addImageItem();
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cBgSecondary,
            borderRadius: BorderRadius.circular(10.wMin),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.wMin),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cBgTertiary,
                borderRadius: BorderRadius.circular(10.wMin),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.cFeedbackDefaultBackground,
                      radius: 40.wMin,
                      child: SvgPicture.asset(
                        "assets/svg/public/icon_add.svg",
                        width: 50.wMin,
                        colorFilter: ColorFilter.mode(
                          AppTheme.cTextPrimary.color,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.wMin),
                    Text(
                      '添加新界面',
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageWidget(int index, CustomCourseManagePhotosModel model) {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cBgSecondary,
          borderRadius: BorderRadius.circular(10.wMin),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.wMin),
          child: Column(
            children: [
              Container(
                height: 80.wMin,
                decoration: BoxDecoration(
                  color: AppTheme.cBgTertiary,
                  borderRadius: BorderRadius.circular(10.wMin),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15.wMin),
                      child: Text(
                        '第 ${index + 1} 页',
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 15.wMin),
                      child: TapScaleWidget(
                        onTap: () {
                          controller.deleteItem(index);
                        },
                        sclae: 1.1,
                        child: SvgPicture.asset(
                          "assets/svg/custom_course/icon_book_info_trash.svg",
                          width: 30.wMin,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.wMin),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.wMin),
                  child: model.uid != null
                      ? CachedImageWidget(
                          model.imageUrl!,
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : Image.file(
                          File(model.imageUrl!),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.fill,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomWidget() {
    return Container(
      width: double.infinity,
      height: 152.wMin,
      color: AppTheme.cBgPrimary,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TapScaleWidget(
              onTap: () {
                controller.reshoot();
              },
              sclae: 1.1,
              child: Container(
                width: 176.wMin,
                height: 72.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.cBgQuaternary,
                  borderRadius: BorderRadius.circular(12.wMin),
                ),
                child: Text(
                  '重拍本书',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cFeedbackErrorBorder,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                TapScaleWidget(
                  onTap: () {
                    controller.saveExit();
                  },
                  sclae: 1.1,
                  child: Container(
                    width: 176.wMin,
                    height: 72.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.cBgQuaternary,
                      borderRadius: BorderRadius.circular(12.wMin),
                    ),
                    child: Text(
                      '保存退出',
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 15.wMin,
                ),
                TapScaleWidget(
                  onTap: () {
                    controller.startRecognize();
                  },
                  sclae: 1.1,
                  child: Container(
                    width: 200.wMin,
                    height: 72.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.cTextBrand,
                      borderRadius: BorderRadius.circular(12.wMin),
                    ),
                    child: Text(
                      '开始识别知识点',
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
