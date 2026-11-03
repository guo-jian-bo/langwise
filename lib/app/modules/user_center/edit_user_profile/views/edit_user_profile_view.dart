import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../routes/routes.dart';
import '../bindings/edit_user_profile_binding.dart';
import '../controllers/edit_user_profile_controller.dart';

class EditUserProfileView extends GetView<EditUserProfileController> {
  final String tagText;
  const EditUserProfileView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      EditUserProfileView(tagText: tag),
      binding: EditUserProfileBinding(tagText: tag),
      routeName: Routes.EDIT_USER_PROFILE,
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
          padding: EdgeInsets.only(
            top: 40.wMin + MediaQuery.of(context).padding.top,
          ),
          child: Column(
            children: [
              const BackWidget(title: "编辑个人资料"),
              SizedBox(height: 32.wMin),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.wMin),
                      color: AppTheme.cBgSecondary,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 40.wMin),
                        _buildHeadWidget(context),
                        SizedBox(height: 24.wMin),
                        _buildFormWidget(),
                        SizedBox(height: 24.wMin),
                        Container(height: 1.wMin, color: AppTheme.cBorderPrimary),
                        SizedBox(height: 24.wMin),
                        ButtonWidget(
                          text: "保存",
                          sclae: 1.02,
                          width: 320.wMin,
                          height: 64.wMin,
                          borderRadius: 12.wMin,
                          color: AppTheme.cBgBrand,
                          fontColor: AppTheme.cStaticWhite,
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w500,
                          onTap: (){
                            controller.save();
                          },
                        ),
                        SizedBox(height: 24.wMin),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormWidget(){
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 56.wMin,
      ),
      child: Column(
        children: [
          CardInputWidget(
            title: "用户名",
            hintText: "请输入用户名",
            controller: controller.nickNameController,
            onClean: () {
              controller.nickNameController.clear();
            },
          ),
          SizedBox(height: 32.wMin),
          Row(
            spacing: 24.wMin,
            children: [
              Expanded(
                child: CardInputWidget(
                  title: "用户ID",
                  controller: controller.userIdController,
                  enabled: false,
                  onClean: (){},
                ),
              ),
              Expanded(
                child: CardInputWidget(
                  title: "手机号",
                  controller: controller.phoneController,
                  enabled: false,
                  onClean: (){},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeadWidget(BuildContext context){
    return Column(
      children: [
        ClipOval(
          child: Container(
            width: 160.wMin,
            height: 160.wMin,
            color: AppTheme.cBlackAlpha10,
            child: Obx((){
              if(controller.headFilePath.isNotEmpty){
                return Image.file(
                  File(controller.headFilePath.value),
                  fit: BoxFit.cover,
                );
              }
              return CachedImageWidget(
                controller.userStore.userInfo.value.avatarUrl??"",
                fit: BoxFit.cover,
                placeholder: SvgPicture.asset(
                  "assets/svg/public/icon_user.svg",
                  height: 160.wMin,
                ),
                errorWidget: SvgPicture.asset(
                  "assets/svg/public/icon_user.svg",
                  height: 160.wMin,
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 16.wMin),

        TapScaleWidget(
          onTap: (){
            controller.selectHeadImage(context);
          },
          sclae: 1.03,
          child: Container(
            width: 156.wMin,
            height: 48.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cBgTertiary,
            ),
            child: Row(
              spacing: 8.wMin,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/svg/public/icon_edit.svg",
                  width: 20.wMin,
                  height: 20.wMin,
                  colorFilter: const ColorFilter.mode(AppTheme.cTextPrimary, BlendMode.srcIn),
                ),
                Text(
                  "选择照片",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20.wMin),
        

      ],
    );
  }

}
