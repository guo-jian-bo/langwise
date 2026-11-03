import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';


import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../bindings/limit_discoun_detail_binding.dart';
import '../controllers/limit_discoun_detail_controller.dart';

class LimitDiscounDetailView extends GetView<LimitDiscounDetailController> {
  final String tagText;
  const LimitDiscounDetailView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      LimitDiscounDetailView(tagText: tag),
      binding: LimitDiscounDetailBinding(tagText: tag),
      routeName: Routes.LIMIT_DISCOUN_DETAIL,
      arguments: arguments,
      preventDuplicates: false,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          width: 1680.wMin,
          margin: EdgeInsets.only(
            top: 56.wMin + MediaQuery.of(context).padding.top,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx((){
                return BackWidget(title: controller.statusData.value.title??"");
              }),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 180.wMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.wMin),
                      _buildRuleIntroduceWidget(),
                      SizedBox(height: 32.wMin),
                      _buildStepWidget(),
                      SizedBox(height: 32.wMin),
                      _buildUploadScreenshotWidget(context),
                      SizedBox(height: 32.wMin),
                      _buildRemindWidget(),
                      SizedBox(height: 32.wMin + MediaQuery.of(context).padding.bottom),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildRemindWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cFeedbackWarningBackground,
      ),
      child: Row(
        spacing: 8.wMin,
        children: [
          SvgPicture.asset(
            "assets/svg/public/icon_danger.svg",
            width: 24.wMin,
            height: 24.wMin,
          ),
          Expanded(
            child: Text(
              "请确保上传的截图清晰可见，包含必要的设备信息。我们会在1-3个工作日内处理您的申请并发放买一送一券。",
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cFeedbackWarningText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 上传截图部分
  Widget _buildUploadScreenshotWidget(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "上传截图",
          style: TextStyle(
            fontSize: 28.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.wMin),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cBgSecondary,
          ),
          child: Column(
            spacing: 32.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropTarget(
                onDragDone: (details) {
                  controller.dropIsEnter.value = false;
                  controller.dropInFiles(details.files);
                },
                onDragEntered: (details) {
                  controller.dropIsEnter.value = true;
                },
                onDragExited: (details) {
                  controller.dropIsEnter.value = false;
                },
                child: TapScaleWidget(
                  onTap: (){
                    controller.selectImage(context);
                  },
                  sclae: 1.005,
                  child: Obx((){
                    return AnimatedScale(
                      duration: const Duration(milliseconds: 80),
                      scale: controller.dropIsEnter.value ? 1.005 : 1.0,
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: Radius.circular(12.wMin),
                        dashPattern: [6.wMin, 4.wMin],
                        padding: EdgeInsets.zero,
                        color: AppTheme.cBorderSecondary,
                        strokeWidth: 2.wMin,
                        child: Container(
                          height: 224.wMin,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: controller.dropIsEnter.value ? AppTheme.cBgTertiary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.wMin),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Visibility(
                                    visible: Platform.isLinux || Platform.isWindows || Platform.isMacOS,
                                    child: Text(
                                      "将图片拖到此处，或者 ",
                                      style: TextStyle(
                                        fontSize: 24.wMin,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.cTextSecondary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "上传文件",
                                    style: TextStyle(
                                      fontSize: 24.wMin,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.cBorderBrand,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppTheme.cBorderBrand,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.wMin),
                              Text(
                                "支持 JPG、JPEG、PNG 格式",
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.cTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx((){
                  return Row(
                    spacing: 12.wMin,
                    children: List.generate(controller.selectFiles.length, (index){
                      return _buildImagesWidget(index, controller.selectFiles[index]);
                    }),
                  );
                }),
              ),
              ButtonWidget(
                text: "保存",
                borderRadius: 12.wMin,
                height: 64.wMin,
                color: AppTheme.cFeedbackInfoIcon,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                fontColor: AppTheme.cStaticWhite,
                sclae: 1.005,
                onTap: () {
                  controller.save();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagesWidget(int index, UpdateImageModel file){
    ImageProvider? image;
    if(file.isNetword){
      image = NetworkImage(file.url);
    } else {
      image = FileImage(File(file.url));
    }

    return Container(
      width: 300.wMin,
      height: 300.wMin,
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        image: DecorationImage(
          image: image,
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        alignment: Alignment.topRight,
        child: TapScaleWidget(
          sclae: 1.05,
          onTap: () {
            controller.selectFiles.removeAt(index);
          },
          child: Container(
            width: 42.wMin,
            height: 42.wMin,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cBgActive,
            ),
            child: SvgPicture.asset(
              "assets/svg/public/x.svg",
              width: 24.wMin,
              height: 24.wMin,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "领取步骤",
          style: TextStyle(
            fontSize: 28.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.wMin),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cBgSecondary,
          ),
          child: Column(
            spacing: 8.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepItemWidget('打开牛听听 APP', '进入"我的"页面', 0),
              _buildStepItemWidget('找到"管理牛听听"按钮', '点击进入管理页面', 1),
              _buildStepItemWidget('截屏上传', '如果一屏截不完，可以截多屏上传', 2, isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItemWidget(String name, String desc, int index, {bool isLast = false}){
    return IntrinsicHeight(
      child: Row(
        spacing: 10.wMin,
        children: [
          Column(
            spacing: 8.wMin,
            children: [
              Container(
                width: 36.wMin,
                height: 36.wMin,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cFeedbackInfoBackground,
                ),
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cFeedbackInfoText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Visibility(
                visible: !isLast,
                child: Container(
                  width: 1.wMin,
                  height: 60.wMin,
                  color: AppTheme.cFeedbackInfoBackground,
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleIntroduceWidget(){
    

    return Column(
      children: [
        Obx((){
          String? expired = controller.statusData.value.expired;
          DateTime? date = DateFormatUtil.tryParseDate(expired);
          if(date == null) return Container();
          String expiredText = DateFormatUtil.formatLocale(date, locale: Get.locale);
          if(expiredText.isEmpty) return Container();
          DateTime now = DateTime.now();
          if(now.isAfter(date)){
            expiredText = "活动已结束";
          }

          return Row(
            children: [
              Text(
                "限时优惠",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 24.wMin),
              Text(
                "截止日期: ",
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                expiredText,
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cFeedbackErrorText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }),
        SizedBox(height: 8.wMin),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cBgSecondary,
          ),
          child: Column(
            spacing: 16.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntroduceTextWidget([const _IntroduceTextModel(value: "所有超记牛Max、牛平板、牛手表，有一台算一台可以领取一张买一送一券。")]),
              _buildIntroduceTextWidget([const _IntroduceTextModel(value: "每个账号只能使用一次买一送一券，但可以将券转送给其他人。")]),
              _buildIntroduceTextWidget([
                const _IntroduceTextModel(value: "如果您转送的券被他人使用，您将获得"),
                const _IntroduceTextModel(value: "10%的乃币补偿", textColor: AppTheme.cFeedbackSuccessText, fontWeight: FontWeight.w600),
                const _IntroduceTextModel(value: "（乃币与人民币 1:1 等值）。"),
              ]),
              _buildIntroduceTextWidget([const _IntroduceTextModel(value: "此活动旨在感谢支持我们的粉丝，让大家在转送券时没有心理负担，同时为长期支持的粉丝提供额外补偿。")]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntroduceTextWidget(List<_IntroduceTextModel> values){
    return Row(
      spacing: 8.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "·",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cFeedbackInfoText,
          ),
        ),
        Expanded(
          child: Text.rich(TextSpan(
            children: values.map((e) => TextSpan(
              text: e.value,
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: e.fontWeight ?? FontWeight.w400,
                color: e.textColor ?? AppTheme.cTextPrimary,
              ),
            )).toList(),
          )),
        ),
      ],
    );
  }


}

class _IntroduceTextModel{
  final String value;
  final Color? textColor;
  final FontWeight? fontWeight;
  const _IntroduceTextModel({required this.value, this.textColor, this.fontWeight});
}
