import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/stores/stores.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../config.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../controllers/about_us_controller.dart';

class AboutUsView extends GetView<AboutUsController> {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          width: 1680.wMin,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 40.wMin,
          ),
          child: Column(
            children: [
              const BackWidget(title: "关于我们"),
              Expanded(
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        GestureDetector(
                          onDoubleTap: () async{
                            if(!UserStore.to.rolePermissions.value.userIsAdmin) return;
                            // 复制token
                            String token = UserStore.to.accessToken;
                            if(token.isEmpty) return;
                            await Clipboard.setData(ClipboardData(text: token));
                            ToastUtils.showToast(text: "复制TOKEN成功", type: ToastType.success);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14.4.wMin),
                            child: Image.asset(
                              "assets/images/logo/app_logo.png", 
                              width: 80.wMin, 
                              height: 80.wMin,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.wMin),
                        Obx((){
                          return Visibility(
                          visible: controller.appName.value.isNotEmpty,
                            child: Text(
                              controller.appName.value,
                              style: TextStyle(
                                fontSize: 40.wMin,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.cTextPrimary,
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 4.wMin),
                        Obx((){
                          String environment = "";
                          
                          if(controller.buildType.value == HttpEnvKey.dev){
                            environment = "Dev ";
                          }else if(controller.buildType.value == HttpEnvKey.beta){
                            environment = "Beta ";
                          }
                          return Visibility(
                            visible: controller.version.value.isNotEmpty,
                            child: Text(
                              "Version $environment${controller.version.value}",
                              style: TextStyle(
                                fontSize: 24.wMin,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.cTextTertiary,
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 8.wMin),
                        Obx((){
                          return Visibility(
                            visible: controller.version.isNotEmpty,
                            child: TapScaleWidget(
                              onTap: () => controller.checkNewVersion(context),
                              sclae: 1,
                              child: _buildTextArrowWidget("检查新版本"),
                            ),
                          );
                        }),
                        TapScaleWidget(
                          onTap: () => controller.contactCustomerService(context),
                          sclae: 1,
                          child: _buildTextArrowWidget("联系客服"),
                        ),
                        Visibility(
                          visible: Platform.isIOS || Platform.isMacOS,
                          child: TapScaleWidget(
                            onTap: () => controller.goScore(),
                            sclae: 1,
                            child: _buildTextArrowWidget("去给${Config.appName}打分"),
                          ),
                        ),
                        TapScaleWidget(
                          onTap: () => controller.toBuildingDreams(),
                          sclae: 1,
                          child: _buildTextArrowWidget("特别鸣谢"),
                        ),
                        
                        TapScaleWidget(
                          onTap: () => controller.feedbackOpinion(context),
                          sclae: 1,
                          child: _buildTextArrowWidget("反馈意见"),
                        ),
                        TapScaleWidget(
                          onTap: () => controller.report(context),
                          sclae: 1,
                          child: _buildTextArrowWidget("违法不良信息举报"),
                        ),
                        TapScaleWidget(
                          onTap: () => controller.openSourceLicense(),
                          sclae: 1,
                          child: _buildTextArrowWidget("致谢与开源许可"),
                        ),
                        Visibility(
                          visible: UserStore.to.userInfo.value.recordLog == 1,
                          child: TapScaleWidget(
                            onTap: () => controller.uploadErrorLogs(),
                            sclae: 1,
                            child: _buildTextArrowWidget("上传日志"),
                          ),
                        ),
                        TapScaleWidget(
                          onTap: () => controller.clearCache(context),
                          sclae: 1,
                          child: _buildTextArrowWidget("清除缓存"),
                        ),

                        TapScaleWidget(
                          onTap: () => controller.unsubscribe(context),
                          sclae: 1,
                          child: _buildTextArrowWidget("注销账号"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        
              SizedBox(height: 4.wMin),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProtocolItemWidget("隐私政策", Config.userPrivacyProtocol),
                  Container(width: 1.wMin, height: 24.wMin, color: AppTheme.cBorderBrand),
                  _buildProtocolItemWidget("用户协议", Config.userProtocol),
                  Container(width: 1.wMin, height: 24.wMin, color: AppTheme.cBorderBrand),
                  _buildProtocolItemWidget("儿童隐私协议", Config.childPrivacyProtocol),
                  Container(width: 1.wMin, height: 24.wMin, color: AppTheme.cBorderBrand),
                  _buildProtocolItemWidget("会员服务协议", Config.memberProtocol),
                ],
              ),
              _buildRecordWidget(context),
              SizedBox(height: 10.wMin + MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }


  /// 备案信息
  Widget _buildRecordWidget(BuildContext context){
    return Column(
      spacing: 4.wMin,
      children: [
        GestureDetector(
          onTap: () => controller.checkAppRecordInfoText(context),
          child: Text(
            Config.appRecordInfo,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary,
            ),
          ),
        ),
        Text(
          "官方网站：${Config.appWebsite}",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary,
          ),
        ),
        Text(
          "版权所有：${Config.companyName}",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary,
          ),
        ),
      ],
    );
  }

  /// 协议
  Widget _buildProtocolItemWidget(String text, String url){
    return TapScaleWidget(
      onTap: () => controller.protocol(url),
      sclae: 1,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextBrand,
          ),
        ),
      ),
    );
  }


  Widget _buildTextArrowWidget(String text){
    return Container(
      width: 911.wMin,
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 18.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary,
            ),
          ),
          SvgPicture.asset(
            "assets/svg/user_center/icon_chevron_right1.svg",
            width: 24.wMin,
            height: 24.wMin,
          ),
        ],
      ),
    );
  }

}
