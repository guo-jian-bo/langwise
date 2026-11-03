import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/card_public_widgets.dart';
import 'package:langwise/common/widgets/city_pickers_widget.dart';
import 'package:langwise/common/widgets/difficulty_dropdown_widget.dart';
import 'package:langwise/common/widgets/list_animation_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/difficultie_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../controllers/customized_courses_controller.dart';

class CustomizedCoursesIdentifyBookWidget extends GetView<CustomizedCoursesController> {
  const CustomizedCoursesIdentifyBookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 32.wMin),
          const CardTitleIconTextWidget(
            title: "添加教材",
            hideIcon: true,
          ),
          SizedBox(height: 40.wMin),
          ListAnimationWidget(
            index: 1,
            child: Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildImageWidget(
                    filePath: controller.frontCover.value,
                    svg: "assets/svg/custom_course/book_front_cover.svg",
                    buttonText: "教材封面",
                    onTap: () {
                      controller.selectFrontCover(context);
                    },
                  ),
                  _buildImageWidget(
                    filePath: controller.backCover.value,
                    svg: "assets/svg/custom_course/book_back_cover.svg",
                    buttonText: "教材封底",
                    onTap: () {
                      controller.selectBackCover(context);
                    },
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: 40.wMin),
          CityPickersWidget(
            initDistrictCode: controller.initDistrictCode.value,
            onConfirm: (data) {
              controller.initDistrictCode.value = data.districtCode;
            },
          ),
          SizedBox(height: 24.wMin),
          ListAnimationWidget(
            index: 2,
            child: CardInputWidget(
              title: "ISBN",
              hintText: "请输入ISBN",
              controller: controller.scanBookISBNInput,
              onClean: () {
                controller.scanBookISBNInput.clear();
                controller.getCourseInfoCardButtonFlag();
              },
              onChanged: (value) {
                controller.getCourseInfoCardButtonFlag();
              },
            ),
          ),
          Visibility(
            visible: controller.recognitionErrorTip.isNotEmpty,
            child: Column(
              children: [
                SizedBox(height: 5.wMin),
                Text(
                  controller.recognitionErrorTip.value,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cFeedbackErrorText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.wMin),
          ListAnimationWidget(
            index: 3,
            child: CardInputWidget(
              title: "书籍名称",
              hintText: "请输入类似 一年级 新概念1",
              controller: controller.bookInfoNameInput,
              maxLength: 30,
              onClean: () {
                controller.bookInfoNameInput.clear();
                controller.getCourseInfoCardButtonFlag();
              },
              onChanged: (value) {
                controller.getCourseInfoCardButtonFlag();
              },
            ),
          ),
          SizedBox(height: 24.wMin),
          ListAnimationWidget(
            index: 4,
            child: DifficultyDropdownWidget(
              difficulties: controller.difficultyList.toList(),
              selectedIndex: controller.selectDifficultyIndex.value,
              onSelected: (int index, DifficultieEntity difficulty) {
                controller.onUpdateDifficultyIndex(index, difficulty);
              },
            ),
          ),
          SizedBox(height: 24.wMin),
          Visibility(
            visible: controller.recognitionErrorTip.isNotEmpty,
            child: Column(
              children: [
                ListAnimationWidget(
                  index: 5,
                  child: CardInputWidget(
                    title: "请填写书籍作用",
                    hintText: "请添加书籍用途描述",
                    controller: controller.courseDescribeInput,
                    onClean: () {
                      controller.courseDescribeInput.clear();
                      controller.getCourseInfoCardButtonFlag();
                    },
                    onChanged: (value) {
                      controller.getCourseInfoCardButtonFlag();
                    },
                  ),
                ),
                SizedBox(height: 24.wMin),
              ],
            ),
          ),
        ],
      );
  }

  //上传教材封面与封底---(改版后)
  Widget _buildImageWidget({
    String filePath = "",
    required String svg,
    required String buttonText,
    void Function()? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Visibility(
          visible: filePath.isEmpty,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                svg,
                height: 300.wMin,
              ),
              GestureDetector(
                onTap: onTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80.wMin,
                      height: 80.wMin,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.2),
                        borderRadius: BorderRadius.circular(40.wMin),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/svg/public/icon_camera1.svg",
                          width: 40.wMin,
                          height: 40.wMin,
                          colorFilter: ColorFilter.mode(
                            AppTheme.cTextPrimary.color,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.wMin),
                    Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cBlackAlpha50,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: filePath.isNotEmpty,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.file(
                File(filePath),
                height: 300.wMin,
                errorBuilder: (context, error, stackTrace) {
                  return SvgPicture.asset(
                    svg,
                    height: 300.wMin,
                  );
                },
              ),
              GestureDetector(
                  onTap: onTap,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80.wMin,
                        height: 80.wMin,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(0, 0, 0, 0.2),
                          borderRadius: BorderRadius.circular(40.wMin),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/svg/public/icon_camera1.svg",
                            width: 40.wMin,
                            height: 40.wMin,
                            colorFilter: ColorFilter.mode(
                              AppTheme.cTextPrimary.color,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.wMin),
                      Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cBlackAlpha50,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

