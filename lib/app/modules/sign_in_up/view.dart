
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../common/values/values.dart';
import '../../../common/widgets/widgets.dart';
import 'index.dart';



class SignInUpPage extends GetView<SignInUpController> {
  const SignInUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.cBgPrimary,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 800.wMin,
                  height: 920.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 80.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceSecondary.color,
                    borderRadius: BorderRadius.circular(40.wMin),
                    border: Border.all(color: AppTheme.cBorderBrand.color, width: 2.wMin),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CardTitleIconTextWidget(
                        title: '创建账号，开始行动',
                        svg: "assets/svg/public/login_title.svg",
                      ),
                      SizedBox(height: 32.wMin),
                      _buildPhoneNumberWidget(context),
                      SizedBox(height: 24.wMin),
                      _buildAuthCodeWidget(),
                      _buildPrivateWidget(),
                      SizedBox(height: 24.wMin),
                      ContinueButtonWidget(
                        text: "登录",
                        fontSize: 28.wMin,
                        onTap: controller.onLogin,
                        // buttonDisable: !controller.state.isChecked,
                      ),
                      SizedBox(height: 72.wMin),
                      _buildOtherLoginWidget(),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 40.wMin,
              top: MediaQuery.of(context).padding.top + 24.wMin,
              child: TapScaleWidget(
                onTap: () {
                  controller.onTourist();
                },
                sclae: 1.03,
                child: Text(
                  "游客模式 >",
                  style: TextStyle(
                    color: AppTheme.cTextBrand,
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Obx((){
          if (controller.appName.value.isEmpty || controller.version.value.isEmpty) {
            return const SizedBox();
          }
          String environment = "";
          if(controller.buildType.value == HttpEnvKey.dev){
            environment = "Dev ";
          }else if(controller.buildType.value == HttpEnvKey.beta){
            environment = "Beta ";
          }

          return Container(
            margin: EdgeInsets.only(right: 20.wMin),
            child: GestureDetector(
              onTap: (){
                controller.checkAppVersionText(context);
              },
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  "Version $environment${controller.version.value}",
                  style: TextStyle(
                    color: AppTheme.cTextSecondary.color,
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPhoneNumberWidget(BuildContext context){
    return Container(
      height: 70.wMin,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Row(
        spacing: 16.wMin,
        children: [
          TapScaleWidget(
            onTap: () {
              controller.onSelectCallingCode(context);
            },
            sclae: 1,
            child: Container(
              height: 70.wMin,
              padding: EdgeInsets.only(left: 12.wMin),
              color: Colors.transparent,
              child: Row(
                spacing: 16.wMin,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx((){
                    return Text(
                      "+${controller.state.callingCode}",
                      style: TextStyle(
                        color: AppTheme.cTextPrimary.color,
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  }),
                  SvgPicture.asset(
                    "assets/svg/public/icon_arrow_down.svg",
                    width: 24.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                  ),
                  Container(
                    width: 1.5.wMin,
                    height: 24.wMin,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller.phoneNumberController,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              // enableInteractiveSelection: false,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                color: AppTheme.cTextPrimary.color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                counterText: "",
                isDense: true,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: '请输入手机号码',
                hintStyle: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCodeWidget(){
    return Row(
      spacing: 16.wMin,
      children: [
        Expanded(
          child: Container(
            height: 70.wMin,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cSurfaceTertiary.color,
            ),
            child: TextField(
              controller: controller.authCodeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 6,
              // enableInteractiveSelection: false,
              style: TextStyle(
                color: AppTheme.cTextPrimary.color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                counterText: "",
                isDense: true,
                counter: const SizedBox.shrink(),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: '请输入验证码',
                hintStyle: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        Obx((){
            String text = "获取验证码";
            if(controller.state.isCountDown){
              text = "${controller.state.currentTime}s";
            }
            return TapScaleWidget(
              onTap: controller.state.isCountDown ? null : () {
                controller.onSendSms();
              },
              sclae: 1.05,
              child: Container(
                width: 185.wMin,
                height: 70.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: AppTheme.cTransparentBrand1.color,
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: AppTheme.cTextBrand.color,
                    fontSize: 22.wMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildPrivateWidget(){
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 14.wMin),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TapScaleWidget(
              onTap: () {
                controller.onCheck();
              },
              sclae: 1,
              child: Obx((){
                return AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                  child: Container(
                    padding: EdgeInsets.all(10.wMin),
                    child: SvgPicture.asset(
                      controller.state.isChecked ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
                      key: ValueKey(controller.state.isChecked),
                      width: 28.wMin,
                      height: 28.wMin,
                    ),
                  ),
                );
              }),
            ),
            Text.rich(TextSpan(
              style: TextStyle(
                color: AppTheme.cTextSecondary.color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                height: 1,
              ),
              children: [
                const TextSpan(text: '登录注册代表同意用户'),
                TextSpan(
                  text: '用户协议',
                  style: const TextStyle(color: AppTheme.cTextBrand),
                  recognizer: TapGestureRecognizer()..onTap = () {
                    controller.jumpToUserProtocol();
                  },
                ),
                const TextSpan(text: '和'),
                TextSpan(
                  text: '隐私协议',
                  style: const TextStyle(color: AppTheme.cTextBrand),
                  recognizer: TapGestureRecognizer()..onTap = () {
                    controller.jumpToPrivacyProtocol();
                  },
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  /// 其他登录方式
  Widget _buildOtherLoginWidget(){
    return Obx((){
      if(!controller.isSupportJverifyLogin.value) return const SizedBox.shrink();
      return Column(
        children: [
          Row(
            spacing: 8.wMin,
            children: [
              Expanded(
                child: Container(
                  height: 1.wMin,
                  color: AppTheme.cBorderTertiary.color,
                ),
              ),
              Text(
                "其他登录方式",
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1.wMin,
                  color: AppTheme.cBorderTertiary.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 32.wMin),
          TapScaleWidget(
            onTap: () {
              controller.onLoginByPhoneNumber();
            },
            sclae: 1.01,
            child: Container(
              width: double.infinity,
              height: 72.wMin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.wMin),
                color: Colors.transparent,
                border: Border.all(
                  color: AppTheme.cBorderSecondary.color,
                  width: 2.wMin,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8.wMin,
                children: [
                  SvgPicture.asset(
                    "assets/svg/public/icon_login_phone.svg",
                    height: 40.wMin,
                  ),
                  Text(
                    "使用本机号码一键登录",
                    style: TextStyle(
                      color: AppTheme.cTextBrand.color,
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

}
