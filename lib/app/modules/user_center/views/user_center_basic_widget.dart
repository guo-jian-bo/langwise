import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';
import '../controllers/user_center_controller.dart';

class UserCenterBasicWidget extends GetView<UserCenterController> {
  /// 用户中心基本信息
  final String tagText;
  const UserCenterBasicWidget({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {

    bool showManagePed = false;
    bool userIsAdmin = controller.userStore.rolePermissions.value.userIsAdmin;
    bool isReviewers = controller.userStore.rolePermissions.value.isReviewers;
    if(userIsAdmin || isReviewers){
      showManagePed = true;
    }



    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cBgSecondary,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.wMin),
              child: Row(
                children: [
                  Text(
                    "账号信息",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GuideStepWidget(
                    id: GuideWidgetIds.userCenterEditInfoButton,
                    onTap: () async{
                      controller.toEditUserProfile();
                    },
                    sclae: 1.03,
                    child: Container(
                      height: 40.wMin,
                      padding: EdgeInsets.symmetric(horizontal: 12.wMin),
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
                            colorFilter: const ColorFilter.mode(
                                AppTheme.cTextPrimary, BlendMode.srcIn),
                          ),
                          Text(
                            "编辑信息",
                            style: TextStyle(
                              fontSize: 20.wMin,
                              color: AppTheme.cTextPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  Visibility(
                    visible: showManagePed,
                    child: Row(
                      children: [
                        SizedBox(width: 16.wMin),
                        TapScaleWidget(
                          onTap: () {
                            controller.setManagePassword(context);
                          },
                          sclae: 1.03,
                          child: Container(
                            height: 40.wMin,
                            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.wMin),
                              color: AppTheme.cBgTertiary,
                            ),
                            child: Row(
                              spacing: 8.wMin,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/svg/public/icon_lock_key.svg",
                                  width: 20.wMin,
                                  height: 20.wMin,
                                  colorFilter: const ColorFilter.mode(
                                      AppTheme.cTextPrimary, BlendMode.srcIn),
                                ),
                                Obx(() {
                                  bool hasPassword = controller.userStore.rolePermissions.value.manageHasPassword;
                                  return Text(
                                    hasPassword ? "重置后台管理密码" : "设置后台管理密码",
                                    style: TextStyle(
                                      fontSize: 20.wMin,
                                      color: AppTheme.cTextPrimary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Visibility(
                    visible: controller.userStore.userInfo.value.isSalesAgent,
                    child: Row(
                      children: [
                        SizedBox(width: 16.wMin),
                        TapScaleWidget(
                          onTap: () {
                            controller.setMembershipCardPassword(context);
                          },
                          sclae: 1.03,
                          child: Container(
                            height: 40.wMin,
                            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.wMin),
                              color: AppTheme.cBgTertiary,
                            ),
                            child: Row(
                              spacing: 8.wMin,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/svg/public/icon_lock_key.svg",
                                  width: 20.wMin,
                                  height: 20.wMin,
                                  colorFilter: const ColorFilter.mode(
                                      AppTheme.cTextPrimary, BlendMode.srcIn),
                                ),
                                Obx(() {
                                  bool hasPassword = controller.userStore.userInfo.value.isSalesAgentPassword ?? false;
                                  return Text(
                                    hasPassword ? "重置代理密码" : "设置代理密码",
                                    style: TextStyle(
                                      fontSize: 20.wMin,
                                      color: AppTheme.cTextPrimary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.wMin),
                  GuideStepWidget(
                    id: GuideWidgetIds.userCenterResetParentPasswordButton,
                    onTap: () async{
                      controller.setParentPassword(context);
                    },
                    sclae: 1.03,
                    child: Container(
                      height: 40.wMin,
                      padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin),
                        color: AppTheme.cBgTertiary,
                      ),
                      child: Row(
                        spacing: 8.wMin,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/svg/public/icon_lock_key.svg",
                            width: 20.wMin,
                            height: 20.wMin,
                            colorFilter: const ColorFilter.mode(AppTheme.cTextPrimary, BlendMode.srcIn),
                          ),
                          Obx(() {
                            bool hasPassword = controller.userStore.userInfo.value.hasPassword == 1;
                            return Text(
                              hasPassword ? "重置家长密码" : "设置家长密码",
                              style: TextStyle(
                                fontSize: 20.wMin,
                                color: AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w400,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.wMin),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.wMin),
              child: Row(
                spacing: 40.wMin,
                children: [
                  Obx(() {
                    return ClipOval(
                      child: Container(
                        width: 160.wMin,
                        height: 160.wMin,
                        color: AppTheme.cBlackAlpha10,
                        child: CachedImageWidget(
                          controller.userStore.userInfo.value.avatarUrl ?? "",
                          placeholder: SvgPicture.asset(
                            "assets/svg/public/icon_user.svg",
                            height: 80.wMin,
                          ),
                          errorWidget: SvgPicture.asset(
                            "assets/svg/public/icon_user.svg",
                            height: 80.wMin,
                          ),
                        ),
                      ),
                    );
                  }),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 12.wMin,
                          children: [
                            Obx(() {
                              return Text(
                                controller.userStore.userInfo.value.nickname ?? "",
                                style: TextStyle(
                                  fontSize: 28.wMin,
                                  color: AppTheme.cTextPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }),
                            TapScaleWidget(
                              onTap: () async{
                                controller.copyUserId();
                              },
                              sclae: 1.01,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.wMin),
                                  color: AppTheme.cFeedbackInfoBackground,
                                ),
                                child: Obx(() {
                                  return Text(
                                    "ID: ${controller.userStore.userInfo.value.userId ?? ""}",
                                    style: TextStyle(
                                      fontSize: 20.wMin,
                                      color: AppTheme.cTextBrand,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  );
                                }),
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Obx(() {
                                  List<UserInfoEntityUserBadges?> list = controller.userStore.userInfo.value.userBadges ?? [];
                                  if (list.isEmpty) return const SizedBox();
                                  return Row(
                                    children: List.generate(list.length, (index) {
                                        return CachedImageWidget(
                                          list[index]?.badgeUrl ?? "",
                                          width: 24.wMin,
                                          height: 24.wMin,
                                          errorWidget: Container(),
                                          placeholder: Container(),
                                        );
                                      },
                                    ),
                                  );
                                }),
                              ),
                            ),
                            Visibility(
                              visible: controller.userStore.userInfo.value.isSalesAgent,
                              child: GestureDetector(
                                onTap: () {
                                  controller.jumpToCardMember(context);
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/svg/membership_card/icon_popularize.svg",
                                      height: 36.wMin,
                                    ),
                                    SizedBox(width: 8.wMin),
                                    Text(
                                      "代理商",
                                      style: TextStyle(
                                        fontSize: 20.wMin,
                                        color: AppTheme.cDifficultyBackgroundColor66,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SvgPicture.asset(
                                      "assets/svg/user_center/icon_chevron_right1.svg",
                                      height: 30.wMin,
                                      colorFilter: const ColorFilter.mode(
                                        AppTheme.cDifficultyBackgroundColor66,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //SizedBox(width: 5.wMin),
                          ],
                        ),
                        SizedBox(height: 30.wMin),
                        Obx(() {
                          return Column(
                            spacing: 10.wMin,
                            children: [
                              Row(
                                spacing: 10.wMin,
                                children: [
                                  _buildBasicInformationRowTextWidget(
                                    "手机号码：", 
                                    controller.userStore.userInfo.value.phone ??"",
                                  ),
                                  // _buildBasicInformationRowTextWidget("电子邮箱：", "xxxxxxxxxxxxxx@xxxx.com"),
                                ],
                              ),
                              Row(
                                spacing: 10.wMin,
                                children: [
                                  _buildBasicInformationRowTextWidget(
                                    "加入时间：",
                                    DateFormatUtil.formatStrtoStr(controller.userStore.userInfo.value.created ?? ""),
                                  ),
                                  _buildBasicInformationRowTextWidget(
                                    "最近登录：",
                                    DateFormatUtil.formatStrtoStr(controller.userStore.userInfo.value.lastLoginTime ?? ""),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 52.wMin),
            Container(height: 1.wMin, color: AppTheme.cBorderSecondary),
            SizedBox(height: 24.wMin),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.wMin),
              child: Row(
                children: [
                 TapScaleWidget(
                   onTap: () {
                     controller.signOut(context);
                   },
                   sclae: 1.03,
                   child: Container(
                     width: 205.wMin,
                     height: 64.wMin,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(12.wMin),
                       color: AppTheme.cBgHover,
                     ),
                     child: Row(
                       spacing: 8.wMin,
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         SvgPicture.asset(
                           "assets/svg/user_center/icon_sign_out.svg",
                           width: 32.wMin,
                           height: 32.wMin,
                           colorFilter: const ColorFilter.mode(
                               AppTheme.cTextPrimary, BlendMode.srcIn),
                         ),
                         Text(
                           "退出登录",
                           style: TextStyle(
                             fontSize: 24.wMin,
                             color: AppTheme.cTextPrimary,
                             fontWeight: FontWeight.w500,
                           ),
                         )
                       ],
                     ),
                   ),
                 ),
                  const Spacer(),
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      GuideStepWidget(
                        id: GuideWidgetIds.userCenterContactTeacherButton,
                        onTap: () async{
                          controller.customerService(context);
                        },
                        sclae: 1.02,
                        child: Container(
                          width: 232.wMin,
                          height: 64.wMin,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.wMin),
                            color: AppTheme.cBgHover,
                          ),
                          child: Row(
                            spacing: 8.wMin,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 40.wMin,
                                height: 40.wMin,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.wMin),
                                  color: AppTheme.cSurfaceBrand.color,
                                ),
                                child: SvgPicture.asset(
                                  "assets/svg/public/icon_headset.svg",
                                  width: 32.wMin,
                                  colorFilter: ColorFilter.mode(AppTheme.cStaticWhite.color, BlendMode.srcIn),
                                ),
                              ),
                              Text(
                                "联系助教老师",
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  color: AppTheme.cTextPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Obx((){
                        return Visibility(
                        visible: controller.showContactTeacherTipsFlag.value,
                          child: Positioned(
                            top: -55.wMin,
                            height: 52.wMin,
                            child: BubbleBox(
                              backgroundColor: AppTheme.cSurfaceInfo.color,
                              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                              shape: BubbleShapeBorder(
                                direction: BubbleDirection.bottom,
                                arrowQuadraticBezierLength: 2.wMin,
                                radius: BorderRadius.circular(6.wMin),
                                arrowHeight: 8.wMin,
                                arrowAngle: 12.wMin,
                                smooth: 1.wMin,
                              ),
                              child: Center(
                                child: Text(
                                  "一对一规划 量身定制课",
                                  style: TextStyle(
                                    fontSize: 24.wMin,
                                    color: AppTheme.cStaticWhite.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInformationRowTextWidget(String name, String? value) {
    return Expanded(
      child: Row(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
