import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/build_image.dart';
import 'package:langwise/common/widgets/date_time_picker_widget.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_public_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'manage_create_book_controller.dart';

class ManageBookCreateViewManager {
  static Future<BookResponseEntity?>? show({
    required BuildContext context,
    void Function(int index)? onTap,
  }) {
    return Get.dialog<BookResponseEntity?>(
      const ManageBookCreateView(),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    ).then((value) {
      print('---创建book弹框消失---');
      return value;
    });
  }
}

class ManageBookCreateView extends GetView<ManageBookCreateController> {
  const ManageBookCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ManageBookCreateController(),
        builder: (_) {
          return LayoutBuilder(builder: (context, constraints) {
            return Scaffold(
              backgroundColor: const Color(0xff040712).withValues(alpha: 0.8),
              body: Center(
                child: Container(
                  width: 1080.ww,
                  height: 980.wh,
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.ww, vertical: 24.wh),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.wMin),
                    border: Border.all(
                      color: const Color(0xff444B5F),
                      width: 1.wMin,
                    ),
                    color: const Color(0xff181B25),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ManageTitleWidget(
                        title: "教材",
                        onCloseTap: () {
                          Get.back();
                        },
                      ),
                      Gaps.getHeight(35.wh),
                      _buildContentWidget(context),
                      Gaps.getHeight(24.wh),
                      _buildBottomWidget(),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  /// 主视图
  Widget _buildContentWidget(BuildContext context) {
    return Container(
      height: 780.wh,
      padding: EdgeInsets.symmetric(horizontal: 16.ww, vertical: 16.wh),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: const Color(0xff22293C),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            ManageTitleInputWidget(
              title: "ISBN",
              hintText: '请输入ISBN',
              required: true,
              controller: controller.isbnController,
              readOnly: false,
              child: _buildISBNTTailWidget(context),
              onSubmitted: OptimizeUtils.throttle((text) {
                controller.onGetCourseInfo();
              }, 300),
            ),
            Gaps.getHeight(24.wh),
            _buildISBNWidget(),
            Gaps.getHeight(24.wh),
            ManageAddCover(
              title: '封面',
              des: '添加封面',
              icon: Assets.managerAdd,
              onTap: () {
                print('添加封面');
                return controller.onAddCover(context);
              },
            ),
            Gaps.getHeight(24.wh),
            ManageTitleInputWidget(
              title: "书名",
              hintText: '请输入课程名称',
              required: true,
              controller: controller.courseNameController,
              readOnly: false,
            ),
            Gaps.getHeight(24.wh),
            ManageTitleInputWidget(
              title: "出版社",
              hintText: '请输入出版社',
              controller: controller.publishingHouseController,
              readOnly: false,
            ),
            Gaps.getHeight(24.wh),
            ManageTitleInputWidget(
              title: "作者",
              hintText: '请输入作者',
              controller: controller.authorController,
              readOnly: false,
            ),
            Gaps.getHeight(24.wh),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ManageTitleInputWidget(
                    title: "出版时间",
                    hintText: '请输入出版时间',
                    controller: controller.publishingDateController,
                    readOnly: true,
                    onTap: OptimizeUtils.noneThrottle(() {
                      final DateTime now = DateTime.now();
                      DateTimePickerUtils.showYMD(
                        context: Get.context!,
                        title: '请选择出版时间',
                        initialDate: controller.publishingDate,
                        minDate: now.subtract(const Duration(days: 365 * 17)),
                        maxDate: DateTime(now.year + 2, 1, 1),
                        onTap: (date) {
                          controller.setPublishingDate(date);
                        },
                      );
                    }, 100),
                  ),
                ),
                Gaps.getWidth(20.ww),
                Expanded(
                  flex: 1,
                  child: ManageTitleInputWidget(
                    title: "版次",
                    hintText: '请输入版次',
                    required: true,
                    controller: controller.versionController,
                    readOnly: false,
                  ),
                )
              ],
            ),
            Gaps.getHeight(24.wh),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ManageSelectWidget(
                    title: "学科",
                    hintText: '请选择科目',
                    value: controller.subjectTitle,
                    readOnly: false,
                    options: CommonUtil.subjectValues,
                    onChanged: (String value, int index) {
                      controller.setSubject(index);
                    },
                  ),
                ),
                Gaps.getWidth(20.ww),
                Expanded(
                  flex: 1,
                  child: ManageSelectWidget(
                    title: "年级",
                    hintText: '请选择年级',
                    value: controller.gradeTitle,
                    readOnly: false,
                    options: CommonUtil.grades,
                    onChanged: (String value, int index) {
                      controller.setGrade(index);
                    },
                  ),
                ),
                Gaps.getWidth(20.ww),
                Expanded(
                  flex: 1,
                  child: ManageSelectWidget(
                    title: "学期",
                    hintText: '请选择学期',
                    value: controller.schoolTermTitle,
                    readOnly: false,
                    options: CommonUtil.schoolTerms,
                    onChanged: (String value, int index) {
                      controller.setSchoolTerm(index);
                    },
                  ),
                ),
              ],
            ),
            Gaps.getHeight(24.wh),
          ],
        ),
      ),
    );
  }

  Widget _buildISBNWidget() {
    return Column(
      children: [
        for (int i = 0; i < controller.isbnList.length; i++)
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: ManageTitleInputWidget(
                      title: "补充ISBN",
                      hintText: '请补充ISBN',
                      controller: controller.isbnList[i],
                      readOnly: false,
                      onSubmitted: OptimizeUtils.throttle((text) {
                        controller.onGetCourseInfo();
                      }, 300),
                    ),
                  ),
                  Gaps.getWidth(12.ww),
                  TapScaleWidget(
                    onTap: OptimizeUtils.noneThrottle(() {
                      controller.removeISBN(i);
                    }, 100),
                    sclae: 1.5,
                    child: Container(
                      width: 32.wMax,
                      height: 32.wMax,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(3.wMin),
                      ),
                      child: SvgPicture.asset('assets/images/manager/trash.svg',
                          width: 32.wMin, height: 32.wMin),
                    ),
                  ),
                ],
              ),
              Gaps.getHeight(24.wh),
            ],
          ),
        GestureDetector(
          onTap: () {
            controller.addISBN();
          },
          child: DottedBorder(
            radius: Radius.circular(8.wMin),
            borderType: BorderType.RRect,
            padding: EdgeInsets.zero,
            color: const Color(0xff4B5268),
            dashPattern: const [4, 2],
            child: Padding(
              padding: EdgeInsets.all(10.0.wMin),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/svg/public/icon_add.svg',
                    width: 20.wMin,
                    height: 20.wMin,
                    colorFilter: const ColorFilter.mode(
                      Color(0xffACB4C0),
                      BlendMode.srcIn,
                    ),
                  ),
                  Gaps.getWidth(5.ww),
                  Text(
                    "添加ISBN",
                    style: TextStyle(
                      fontSize: 12.wMin,
                      color: const Color(0xffACB4C0),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildISBNTTailWidget(BuildContext context) {
    return GetBuilder(
        init: controller,
        id: 'isbn',
        builder: (_) {
          return TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              controller.onGetCourseInfo();
            }, 300),
            sclae: 1.03,
            child: Container(
                padding: EdgeInsets.only(
                    left: 12.ww, right: 12.ww, top: 4.wh, bottom: 4.wh),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.wMin),
                  color: const Color(0xff393F5A),
                ),
                child: Row(
                  children: [
                    buildImage(Assets.managerDownload,
                        width: 18.wMax, height: 18.wMax),
                    Gaps.getWidth(8.ww),
                    Text(
                      "获取教材信息",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: const Color(0xffEDF0F4),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )),
          );
        });
  }

  Widget _buildBottomWidget() {
    return GetBuilder(
        init: controller,
        id: 'bottom_button',
        builder: (_) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ManageButton(
                text: "取消",
                width: 80.ww,
                height: 40.wh,
                borderColor: const Color(0xff666F8D),
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: const Color(0xffEBEEF3),
                  fontWeight: FontWeight.w400,
                ),
                onTap: () {
                  Get.back();
                },
              ),
              SizedBox(width: 11.ww),
              ManageButton(
                text: "上传所有信息",
                width: 120.ww,
                height: 40.wh,
                color: !controller.uploadButtonFlag
                    ? const Color(0xff353E5C)
                    : const Color(0xff2388FF),
                borderColor: Colors.transparent,
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: controller.uploadButtonFlag
                      ? const Color(0xffEBEEF3)
                      : const Color(0xffACB4C0),
                  fontWeight: FontWeight.w400,
                ),
                onTap: !controller.uploadButtonFlag
                    ? null
                    : OptimizeUtils.noneThrottle(() {
                        controller.onCreateBook();
                      }, 100),
              ),
            ],
          );
        });
  }
}
