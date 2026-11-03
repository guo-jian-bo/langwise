import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'manage_edit_book_controller.dart';
import 'manage_edit_book_course_model.dart';
import 'manage_edit_book_level_model.dart';

class ManageBookEditManager {
  static Future<BookResponseEntity?>? show({
    required BuildContext context,
    required BookResponseEntity entity,
    void Function(int index)? onTap,
  }) {
    return Get.dialog<BookResponseEntity?>(
      ManageBookEditView(entity: entity),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    ).then((value) {
      return value;
    });
  }
}

class ManageBookEditView extends GetView<ManageBookEditController> {
  final BookResponseEntity entity;

  const ManageBookEditView({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ManageBookEditController(entity),
        builder: (_) {
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
                        controller.close();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ManageTitleInputWidget(
              title: "书籍ID",
              hintText: '请输入书籍ID',
              controller: controller.courseIdController,
              readOnly: true,
            ),
            Gaps.getHeight(5.wh),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                controller.levelId != null
                    ? Column(
                        children: [
                          Text(
                            '该书籍已在课程中${controller.levelId}',
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: const Color(0xffEBEEF3),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Gaps.getHeight(5.wh),
                        ],
                      )
                    : const SizedBox.shrink(),
                ManageButton(
                  text: controller.levelId != null ? "更换课程" : "加入课程",
                  width: 100.wMin,
                  height: 30.wMin,
                  color: const Color(0xff393F5A),
                  borderColor: Colors.transparent,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: const Color(0xffEBEEF3),
                    fontWeight: FontWeight.w400,
                  ),
                  onTap: () {
                    controller.getLevelList();
                  },
                ),
              ],
            ),
            Gaps.getHeight(24.wh),
            ManageTitleInputWidget(
              title: "模块ID",
              hintText: '请输入模块ID',
              controller: controller.moduleIdController,
              readOnly: true,
            ),
            Gaps.getHeight(24.wh),
            ManageTitleInputWidget(
              title: "主ISBN",
              hintText: '请输入ISBN',
              required: true,
              controller: controller.isbnController,
              readOnly: false,
              child: _buildISBNTTailWidget(),
              onSubmitted: OptimizeUtils.throttle((text) {
                controller.onGetCourseInfo();
              }, 300),
            ),
            Gaps.getHeight(24.wh),
            _buildISBNWidget(),
            Gaps.getHeight(24.wh),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ManageAddCover(
                  title: '封面',
                  des: '添加封面',
                  icon: Assets.managerAdd,
                  filePath: controller.entity.coverUrl,
                  onTap: () {
                    return controller.onAddCover(context);
                  },
                ),
                Gaps.getWidth(20.ww),
                ManageAddPdfCard(
                  title: 'PDF',
                  des: '上传PDF',
                  icon: Assets.managerAdd,
                  filePath: controller.pdfFilePath,
                  previewUrl: controller.pdfPreviewUrl,
                  onPreview: (url) async {
                    if (url.startsWith('http://') || url.startsWith('https://')) {
                      await WebViewUtils.openWebView(url: url);
                      return;
                    }
                    ToastUtils.showManageToast(text: "预览链接无效");
                  },
                  onTap: () {
                    return controller.onAddPdf(context);
                  },
                ),
              ],
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    )),
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

  Widget _buildISBNTTailWidget() {
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
                  controller.close();
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
                        controller.onEditBook();
                      }, 100),
              ),
            ],
          );
        });
  }
}

class ManageBookSettingLevelWidget extends StatefulWidget {
  final int? levelId;
  final List<ManageEditBookCourseModel> courseList;
  const ManageBookSettingLevelWidget(
      {super.key, this.levelId, required this.courseList});

  @override
  State<ManageBookSettingLevelWidget> createState() =>
      _ManageBookSettingLevelWidgetState();
}

class _ManageBookSettingLevelWidgetState
    extends State<ManageBookSettingLevelWidget> {
  /// 等级ID
  int? currentLevelId;

  @override
  void initState() {
    super.initState();
    currentLevelId = widget.levelId;
  }

  @override
  Widget build(BuildContext context) {
    final List<ManageEditBookCourseModel> courses = widget.courseList;
    return Scaffold(
      backgroundColor: const Color(0xff040712).withValues(alpha: 0.6),
      body: Center(
        child: Container(
          width: 760.wMin,
          height: 700.wMin,
          padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 24.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            border: Border.all(
              color: const Color(0xff444B5F),
              width: 1.wMin,
            ),
            color: const Color(0xff23283D),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "选择课程等级",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: const Color(0xffEBEEF3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TapScaleWidget(
                    onTap: () {
                      Get.back();
                    },
                    sclae: 1.03,
                    child: SvgPicture.asset(
                      'assets/svg/manage/icon_close.svg',
                      width: 20.wMin,
                      height: 20.wMin,
                      colorFilter: const ColorFilter.mode(
                        Color(0xffEDF0F4),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
              Gaps.getHeight(20.wMin),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    final levels = course.levelList ?? <ManageEditBookLevelModel>[];
                    if (levels.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      margin: EdgeInsets.only(bottom: 20.wh),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: course.name ?? ''),
                                if (course.uid != null)
                                  TextSpan(
                                    text: '  #${course.uid}',
                                    style: TextStyle(
                                      color: const Color(0xffACB4C0).withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                              ],
                            ),
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: const Color(0xffEBEEF3),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Gaps.getHeight(12.wMin),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 12.wMin,
                              crossAxisSpacing: 12.wMin,
                              childAspectRatio: 4.2,
                            ),
                            itemBuilder: (context, levelIndex) {
                              final model = levels[levelIndex];
                              final bool isSelected = currentLevelId == model.uid;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentLevelId = model.uid;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xff2388FF).withValues(alpha: 0.2)
                                        : const Color(0xff2A314A),
                                    borderRadius: BorderRadius.circular(8.wMin),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xff2388FF)
                                          : const Color(0xff444B5F),
                                      width: 1.wMin,
                                    ),
                                  ),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(text: model.name ?? ''),
                                        if (model.uid != null)
                                          TextSpan(
                                            text: '  #${model.uid}',
                                            style: TextStyle(
                                              fontSize: 12.wMin,
                                              color: (isSelected
                                                      ? const Color(0xffEBEEF3)
                                                      : const Color(0xffACB4C0))
                                                  .withValues(alpha: 0.8),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.wMin,
                                      color: isSelected
                                          ? const Color(0xffEBEEF3)
                                          : const Color(0xffACB4C0),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemCount: levels.length,
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: courses.length,
                ),
              ),
              Gaps.getHeight(10.wMin),
              Align(
                alignment: Alignment.centerRight,
                child: ManageButton(
                  text: "确认",
                  width: 90.ww,
                  height: 30.wh,
                  color: const Color(0xff2388FF),
                  borderColor: Colors.transparent,
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: const Color(0xffEBEEF3),
                    fontWeight: FontWeight.w400,
                  ),
                  onTap: () {
                    if (currentLevelId != null) {
                      if (Get.isRegistered<ManageBookEditController>()) {
                        ManageBookEditController manageBookEditController =
                            Get.find<ManageBookEditController>();
                        manageBookEditController
                            .bindNewLevelId(currentLevelId!);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
