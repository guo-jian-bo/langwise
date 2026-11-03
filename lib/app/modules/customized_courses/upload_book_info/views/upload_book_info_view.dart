import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../controllers/upload_book_info_controller.dart';

class UploadBookInfoView extends GetView<UploadBookInfoController> {
  const UploadBookInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.cBgPrimary,
      body: Column(
        children: [
          _buildTitleWidget(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 270.wMin),
              child: Column(
                children: [
                  _buildTextInfoWidget(),
                  SizedBox(height: 32.wMin),
                  Container(
                    width: 1000.wMin,
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        Obx((){
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildImageWidget(
                                filePath: controller.frontCover.value,
                                svg: "assets/svg/custom_course/book_front_cover.svg",
                                buttonText: "点击上传教材封面",
                                onTap: () {
                                  controller.selectFrontCover(context);
                                },
                              ),
                              _buildImageWidget(
                                filePath: controller.backCover.value,
                                svg: "assets/svg/custom_course/book_back_cover.svg",
                                buttonText: "点击上传教材封底",
                                onTap: () {
                                  controller.selectBackCover(context);
                                },
                              ),
                            ],
                          );
                        }),
                        SizedBox(height: 32.wMin),
                        _buildAddressWidget(),
                      ],
                    ),
                  ),
            
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildButtonsWidget(context),
    );
  }

  Widget _buildButtonsWidget(BuildContext context){
    return Container(
      height: 152.wMin + MediaQuery.of(context).padding.bottom,
      color: AppTheme.cSurfaceSecondary,
      padding: EdgeInsets.only(left: 96.wMin, right: 96.wMin, top: 24.wMin),
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ButtonWidget(
            text: "重拍",
            sclae: 1.05,
            width: 176.wMin,
            height: 64.wMin,
            color: AppTheme.cBgQuaternary,
            fontColor: AppTheme.cTextBrand,
            borderRadius: 12.wMin,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            onTap: () => controller.reset(),
          ),
          ButtonWidget(
            text: "确认上传",
            sclae: 1.02,
            height: 64.wMin,
            width: 176.wMin,
            color: AppTheme.cSurfaceBrand,
            fontColor: AppTheme.cStaticWhite,
            borderRadius: 12.wMin,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            onTap: () async {
              await controller.uploadBookInfo(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "教材使用地区",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary,
          ),
        ),
        SizedBox(height: 12.wMin),
        CityPickersWidget(
          onConfirm: (data) {
            
            controller.initDistrictCode.value = data.districtCode;
          },
        ),
      ],
    );
  }

  Widget _buildImageWidget({
    String filePath = "",
    required String svg,
    required String buttonText,
    void Function()? onTap,
  }){
    return Column(
      children: [
        Visibility(
          visible: filePath.isEmpty,
          child: SvgPicture.asset(
            svg,
            height: 400.wMin,
          ),
        ),
        Visibility(
          visible: filePath.isNotEmpty,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.wMin),
            child: Image.file(
              File(filePath), 
              height: 400.wMin,
              errorBuilder: (context, error, stackTrace) {
                return SvgPicture.asset(
                  svg,
                  height: 400.wMin,
                );
              },
            ),
          ),
        ),
        SizedBox(height: 24.wMin),
        ButtonWidget(
          text: buttonText,
          width: 400.wMin,
          height: 96.wMin,
          borderRadius: 24.wMin,
          color: AppTheme.cBgTertiary,
          fontSize: 28.wMin,
          fontColor: AppTheme.cTextBrand,
          fontWeight: FontWeight.w500,
          sclae: 1.01,
          onTap: onTap,
        ),
      ],
    );
  }

  Widget _buildTextInfoWidget(){
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "拍摄教材要求",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary,
            ),
          ),
          Text(
            "需要拍摄教材正反面；",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary,
            ),
          ),
          Text.rich(TextSpan(
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary,
            ),
            children: [
              const TextSpan(text: "拍摄时确保教材封底"),
              TextSpan(
                text: "ISBN码字体清晰，信息完整",
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cFeedbackErrorText,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24.wMin, 
        left: 80.wMin, 
        right: 80.wMin + 64.wMin,
      ),
      child: const BackWidget(title: "上传教材信息"),
    );
  }

}
