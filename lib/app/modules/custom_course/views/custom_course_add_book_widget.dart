import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/card_public_widgets.dart';
import 'package:langwise/common/widgets/city_cascade_picker_widget.dart';
import 'package:langwise/common/widgets/city_pickers_widget.dart';
import 'package:langwise/common/widgets/list_animation_widget.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../controllers/custom_course_controller.dart';

class CustomCourseAddBookWidget extends GetView<CustomCourseController> {
  const CustomCourseAddBookWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.bookCurrentStep.value == 1) {
        return _buildCoverWidget(context);
      }

      if (controller.bookCurrentStep.value == 2) {
        return _getBookInfo(context);
      }

      if (controller.bookCurrentStep.value == 3) {
        if (controller.bookEntity.status == 3) {
          //此书籍支持
          return _checkSupportBookInfo(context);
        } else {
          //此书籍不支持
          return _checkNotSupportBookInfo(context);
        }
      }

      return const SizedBox();
    });
  }

  //确认支持书籍
  Widget _checkSupportBookInfo(context) {
    return Column(
      children: [
        SizedBox(height: 32.wMin),
        Text(
          "信息确认",
          style: TextStyle(
            fontSize: 40.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 40.wMin),
        SizedBox(
            width: 800.wMin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "孩子上学地区",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 15.wMin),
                CityCascadePickerWidget(
                  initDistrictCode: controller.initDistrictCode.value,
                  onConfirm: (data) {
                    controller.initDistrictCode.value = data.districtCode;
                    controller.bookInfoButtonDisable.value = false;
                  },
                ),
              ],
            )),
        SizedBox(height: 40.wMin),
        SizedBox(
            width: 800.wMin,
            child: ListAnimationWidget(
              index: 3,
              child: CardInputWidget(
                title: "书籍名称",
                hintText: "请输入类似 一年级 新概念1",
                controller: controller.bookInfoNameInput,
                maxLength: 30,
                onClean: () {
                  controller.bookInfoNameInput.clear();
                  controller.bookInfoButtonDisable.value = true;
                },
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    controller.bookInfoButtonDisable.value = false;
                  } else {
                    controller.bookInfoButtonDisable.value = true;
                  }
                },
              ),
            )),
        SizedBox(height: 40.wMin),
        SizedBox(
            width: 800.wMin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "难度等级",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 15.wMin),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 15.wMin, vertical: 15.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cBgTertiary,
                    borderRadius: BorderRadius.circular(12.wMin),
                  ),
                  child: Text(
                    'Level ${controller.bookEntity.grade}',
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            )),
        const Spacer(),
        TapScaleWidget(
          onTap: () {
            if (!controller.bookInfoButtonDisable.value) {
              controller.courseInfoContinue(context);
            }
          },
          child: Container(
            width: 832.wMin,
            height: 72.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: controller.bookInfoButtonDisable.value ? AppTheme.cTextDisabled : AppTheme.cSurfaceInfo.color,
            ),
            child: Text('继续',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: controller.bookInfoButtonDisable.value ? AppTheme.cTextSecondary : AppTheme.cInverseTextLight,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ),
        SizedBox(height: 47.wMin)
      ],
    );
  }

  //确认不支持书籍
  Widget _checkNotSupportBookInfo(context) {
    return SizedBox(
        width: 800.wMin,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 25.wMin),
            const CardTitleIconTextWidget(
              title: "信息确认",
              hideIcon: true,
            ),
            SizedBox(height: 20.wMin),
            Container(
              width: 800.wMin,
              padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 15.wMin),
              decoration: BoxDecoration(
                color: AppTheme.cDifficultyBackgroundColor6.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.wMin),
              ),
              child: Text(
                controller.bookEntity.tip ?? '',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cDifficultyBackgroundColor6,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: 12.wMin),
            SizedBox(
                width: 800.wMin,
                child: ListAnimationWidget(
                  index: 0,
                  child: CardInputWidget(
                    enabled: false,
                    title: "ISBN",
                    hintText: "请输入书籍ISBN",
                    controller: controller.bookIsbnController,
                    maxLength: 30,
                  ),
                )),
            SizedBox(height: 24.wMin),
            SizedBox(
                width: 800.wMin,
                child: ListAnimationWidget(
                  index: 1,
                  child: CardInputWidget(
                    title: "书籍名称",
                    hintText: "请输入类似 一年级 新概念1",
                    controller: controller.bookInfoNameInput,
                    maxLength: 30,
                    onClean: () {
                      controller.bookInfoNameInput.clear();
                      controller.bookInfoButtonDisable.value = true;
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        controller.bookInfoButtonDisable.value = false;
                      } else {
                        controller.bookInfoButtonDisable.value = true;
                      }
                    },
                  ),
                )),
            SizedBox(height: 12.wMin),
            SizedBox(
                width: 800.wMin,
                child: ListAnimationWidget(
                  index: 2,
                  child: CardInputWidget(
                    title: "请填写书籍作用",
                    hintText: "请添加书籍用途描述",
                    controller: controller.courseDescribeInput,
                    onClean: () {
                      controller.courseDescribeInput.clear();
                    },
                  ),
                )),
            SizedBox(height: 12.wMin),
            SizedBox(
                width: 800.wMin,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "孩子上学地区",
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 15.wMin),
                    CityPickersWidget(
                      initDistrictCode: controller.initDistrictCode.value,
                      onConfirm: (data) {
                        controller.initDistrictCode.value = data.districtCode;
                      },
                    ),
                  ],
                )),
            Spacer(),
            GestureDetector(
              onTap: () {
                if(controller.bookInfoButtonDisable.value)return;
                controller.reportBookInfo();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: controller.bookInfoButtonDisable.value ? AppTheme.cBgTertiary : AppTheme.cSurfaceInfo.color,
                ),
                alignment: Alignment.center,
                height: 72.wMin,
                width: 500.wMin,
                child: Text(
                  "继续",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 47.wMin)
          ],
        ));
  }

  ///获取教材信息
  Widget _getBookInfo(context) {
    return Column(
      children: [
        SizedBox(height: 30.wMin),
        const CardTitleIconTextWidget(
          title: "获取教材信息",
          hideIcon: true,
        ),
        SizedBox(height: 40.wMin),
        GestureDetector(
          onTap: () {
            controller.bookSelectIndex.value = 0;
            controller.bookInfoButtonDisable.value = false;
          },
          child: Container(
            width: 800.wMin,
            padding: EdgeInsets.all(20.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              border: Border.all(
                color: AppTheme.cBgTertiary,
                width: 2.wMin,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'AI匹配信息',
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    SvgPicture.asset(
                      controller.bookSelectIndex.value == 0 ? Assets.publicIconRadio : Assets.publicIconRadioUn,
                      width: 32.wMin,
                      colorFilter: controller.bookSelectIndex.value == 0 ? const ColorFilter.mode(AppTheme.cBgBrand, BlendMode.srcIn) : null,
                    ),
                  ],
                ),
                SizedBox(height: 20.wMin),
                Text(
                  '根据封面封底去公共图书库匹配教材信息，如果没有成功匹配或匹配不对，可以使用下面直接输入ISBN码来准确获取信息',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24.wMin),
        GestureDetector(
          onTap: () {
            controller.bookSelectIndex.value = 1;
            if (controller.isbnController.text.length == 13) {
              controller.bookInfoButtonDisable.value = false;
            } else {
              controller.bookInfoButtonDisable.value = true;
            }
          },
          child: Container(
            width: 800.wMin,
            padding: EdgeInsets.all(20.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              border: Border.all(
                color: AppTheme.cBgTertiary,
                width: 2.wMin,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '手动输入ISBN',
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    SvgPicture.asset(
                      controller.bookSelectIndex.value == 1 ? Assets.publicIconRadio : Assets.publicIconRadioUn,
                      width: 32.wMin,
                      colorFilter: controller.bookSelectIndex.value == 1 ? const ColorFilter.mode(AppTheme.cBgBrand, BlendMode.srcIn) : null,
                    ),
                  ],
                ),
                SizedBox(height: 20.wMin),
                Text(
                  'ISBN码通常位于书籍封底右下角，请输入13位数字',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 10.wMin),
                Center(
                  child: Container(
                    width: 200.wMin,
                    height: 200.wMin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.wMin),
                    ),
                    child: Image.asset('assets/images/custom_course/ISBN.png'),
                  ),
                ),
                SizedBox(height: 20.wMin),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.wMin,
                    vertical: 8.wMin,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.wMin),
                    border: Border.all(
                      color: AppTheme.cBgTertiary,
                      width: 2.wMin,
                    ),
                  ),
                  child: TextField(
                    controller: controller.isbnController,
                    onTap: () {
                      controller.bookSelectIndex.value = 1;
                    },
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextPrimary,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "例如：9787111633449",
                      hintStyle: const TextStyle(color: AppTheme.cQuizDefaultBackground),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.wMin,
                      ),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(13),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      if (controller.bookSelectIndex.value == 1) {
                        if (value.length == 13) {
                          controller.bookInfoButtonDisable.value = false;
                        } else {
                          controller.bookInfoButtonDisable.value = true;
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _backCoverBtn(),
          SizedBox(width: 20.wMin),
          GestureDetector(
              onTap: () {
                if(controller.bookInfoButtonDisable.value)return;
                controller.courseInfoContinue(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: controller.bookInfoButtonDisable.value ? AppTheme.cBgTertiary : AppTheme.cSurfaceInfo.color,
                ),
                alignment: Alignment.center,
                height: 72.wMin,
                width: 500.wMin,
                child: Text(
                  "继续",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )),
        ]),
        SizedBox(height: 47.wMin),
      ],
    );
  }

  Widget _backCoverBtn() {
    return GestureDetector(
      onTap: () {
        controller.bookCurrentStep.value = 1;
        controller.bookSelectIndex.value = -1;
        controller.bookInfoButtonDisable.value = false;
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cBgTertiary,
        ),
        alignment: Alignment.center,
        height: 72.wMin,
        width: 500.wMin,
        child: Text(
          "返回拍照",
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 封面封底上传卡片
  Widget _buildCoverWidget(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 30.wMin),
        Text.rich(
          TextSpan(text: "请找出", children: [
            TextSpan(
                text: controller.cefr.value,
                style: TextStyle(
                  fontSize: 40.wMin,
                  color: AppTheme.cTextBrand,
                  fontWeight: FontWeight.w600,
                )),
            const TextSpan(text: '这本书'),
          ]),
          style: TextStyle(
            fontSize: 40.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.wMin),
        Text(
          '拍照上传封面封底，或者直接上传封面封底图片',
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 8.wMin),
        GestureDetector(
          onTap: () {
            controller.customerService(context);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99.wMin),
              color: AppTheme.cSurfaceSecondary.color,
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/svg/public/kefu.svg',
                  width: 40.wMin,
                  height: 40.wMin,
                ),
                SizedBox(width: 8.wMin),
                Text(
                  '操作遇到问题？点这联系助教',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(height: 24.wMin),
        Row(
          children: [
            SizedBox(width: 70.wMin),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cSurfacePrimary.color,
                  borderRadius: BorderRadius.circular(24.wMin),
                ),
                padding: EdgeInsets.all(24.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '添加封面',
                          style: TextStyle(
                            fontSize: 28.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            controller.showSampleCover();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: Color(0x1A0EA5E9),
                                borderRadius: BorderRadius.circular(8.wMin),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
                              child: Row(children: [
                                Text(
                                  '查看样图',
                                  style: TextStyle(
                                    fontSize: 22.wMin,
                                    color: AppTheme.cTextBrand,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(width: 8.wMin),
                                SvgPicture.asset(
                                  'assets/svg/manage/icon_chevron_right.svg',
                                  width: 20.wMin,
                                  height: 20.wMin,
                                  colorFilter: const ColorFilter.mode(AppTheme.cTextBrand, BlendMode.srcIn),
                                )
                              ])),
                        )
                      ],
                    ),
                    SizedBox(height: 20.wMin),
                    Obx(
                      () => _buildImageWidget(
                        filePath: controller.frontCover.value,
                        svg: "assets/svg/custom_course/book_front_cover.svg",
                        onPhotoAlbumTap: () {
                          controller.selectFrontCoverFromAlbum(context);
                        },
                        onCameraTap: () {
                          controller.selectFrontCover(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 24.wMin),
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cSurfacePrimary.color,
                borderRadius: BorderRadius.circular(24.wMin),
              ),
              padding: EdgeInsets.all(24.wMin),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    Text(
                      '添加封底',
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                        onTap: () {
                          controller.showSampleCover();
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              color: Color(0x1A0EA5E9),
                              borderRadius: BorderRadius.circular(8.wMin),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
                            child: Row(children: [
                              Text(
                                '查看样图',
                                style: TextStyle(
                                  fontSize: 22.wMin,
                                  color: AppTheme.cTextBrand,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 8.wMin),
                              SvgPicture.asset(
                                'assets/svg/manage/icon_chevron_right.svg',
                                width: 20.wMin,
                                height: 20.wMin,
                                colorFilter: const ColorFilter.mode(AppTheme.cTextBrand, BlendMode.srcIn),
                              )
                            ])))
                  ],
                ),
                SizedBox(height: 20.wMin),
                Obx(
                  () => _buildImageWidget(
                    filePath: controller.backCover.value,
                    svg: "assets/svg/custom_course/book_back_cover.svg",
                    onPhotoAlbumTap: () {
                      controller.selectBackCoverFromAlbum(context);
                    },
                    onCameraTap: () {
                      controller.selectBackCover(context);
                    },
                  ),
                )
              ]),
            )),
            SizedBox(width: 70.wMin),
          ],
        ),
        SizedBox(height: 72.wMin),
        TapScaleWidget(
          onTap: () {
            if (controller.frontCover.value.isEmpty || controller.backCover.value.isEmpty) {
              ToastUtils.showToast(text: "请上传封面和封底");
              return;
            }
            controller.courseInfoContinue(context);
          },
          sclae: 1.001,
          child: Container(
            height: 72.wMin,
            width: 832.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: controller.frontCover.value.isEmpty || controller.backCover.value.isEmpty ? AppTheme.cSurfaceTertiary.color : AppTheme.cSurfaceInfo.color,
            ),
            alignment: Alignment.center,
            child: Text(
              controller.frontCover.value.isEmpty || controller.backCover.value.isEmpty ? '请上传封面和封底' : '继续',
              style: TextStyle(
                fontSize: 24.wMin,
                color: controller.frontCover.value.isEmpty || controller.backCover.value.isEmpty ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildImageWidget({
    String filePath = "",
    required String svg,
    void Function()? onPhotoAlbumTap,
    void Function()? onCameraTap,
  }) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
          ),
          child: filePath.isEmpty
              ? SvgPicture.asset(
                  svg,
                  height: 401.wMin,
                )
              : Image.file(
                  File(filePath),
                  height: 401.wMin,
                  errorBuilder: (context, error, stackTrace) {
                    return SvgPicture.asset(
                      svg,
                      height: 401.wMin,
                    );
                  },
                ),
        ),
        SizedBox(width: 16.wMin),
        Expanded(
          child: Column(
            children: [
              GestureDetector(
                onTap: onCameraTap,
                child: Container(
                  height: 192.wMin,
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceSecondary.color,
                    borderRadius: BorderRadius.circular(8.wMin),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Container(
                          color: const Color.fromRGBO(56, 189, 248, 0.1),
                          width: 56.wMin,
                          height: 56.wMin,
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/svg/public/icon_camera1.svg",
                              width: 28.wMin,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.wMin),
                      Text(
                        filePath.isEmpty ? "拍照" : "重新拍摄",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.wMin),
              GestureDetector(
                onTap: onPhotoAlbumTap,
                child: Container(
                  height: 192.wMin,
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceSecondary.color,
                    borderRadius: BorderRadius.circular(8.wMin),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Container(
                          color: const Color.fromRGBO(56, 189, 248, 0.1),
                          width: 56.wMin,
                          height: 56.wMin,
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/svg/public/icon_image1.svg",
                              width: 28.wMin,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.wMin),
                      Text(
                        filePath.isEmpty ? "上传" : "重新上传",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
