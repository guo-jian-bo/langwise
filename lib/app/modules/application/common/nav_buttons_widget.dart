import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/stores/stores.dart';
import '../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../routes/routes.dart';
import '../controllers/application_controller.dart';
import '../controllers/message_controller.dart';

class NavButtonsWidget extends GetView<ApplicationController> {
  /// 是否禁用按钮 是否禁用所有按钮
  final bool disableButton;

  /// 执行手机卡片动画需要的key 给卡册按钮
  final GlobalKey? cardsKey;

  /// 是否透明按钮 是否透明所有按钮 除了卡册
  final bool opactiyButton;
  const NavButtonsWidget({super.key, this.disableButton = false, this.cardsKey, this.opactiyButton = false});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: disableButton,
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildNavWidget(context),
            Positioned(
              right: 70.wMin,
              child: _buildUserWidget(context),
            ),
            Positioned(
              left: 56.wMin,
              child: CustomerServiceButtonWidget(widgetId: GuideWidgetIds.homeCustomerServiceButton, pageCode: AppRoutesCode.home),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavWidget(BuildContext context) {
    final List<AppHomeButtonEnum> navDataList = [
      AppHomeButtonEnum.home,
      AppHomeButtonEnum.zhenTing,
      AppHomeButtonEnum.script,
      AppHomeButtonEnum.music,
      AppHomeButtonEnum.dictionary,
      AppHomeButtonEnum.pronunciation,
    ];

    return Container(
      padding: EdgeInsets.only(bottom: 20.wMin),
      constraints: BoxConstraints(
        maxWidth: 900.wMin,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.wMin),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            height: 158.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.wMin),
              color: AppTheme.cStaticBlack.color.withValues(alpha: 0.05),
              border: Border.all(
                width: 1.wMin,
                color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.1),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 20.wMin, right: 20.wMin),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    spacing: 19.wMin,
                    children: List.generate(navDataList.length, (index) {
                      return buildNavIconWidget(
                        data: navDataList[index],
                        itemKey: navDataList[index] == AppHomeButtonEnum.dictionary ? cardsKey : null,
                        opacity: opactiyButton && navDataList[index] != AppHomeButtonEnum.dictionary,
                        onTap: () async{
                          controller.changeNavIndex(navDataList[index], context);
                        },
                      );
                    }),
                  ),
                  _buildManageWidget(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 管理图标
  Widget _buildManageWidget(BuildContext context) {
    return Opacity(
      opacity: opactiyButton ? 0.4 : 1,
      child: Obx(() {
        bool userIsAdmin = controller.userStore.rolePermissions.value.userIsAdmin;
        bool isReviewers = controller.userStore.rolePermissions.value.isReviewers;
      
        List<Widget> manageWidgets = [];
      
        if(userIsAdmin || isReviewers){
          manageWidgets.add(_buildNavManageIconWidget(
            data: AppHomeButtonEnum.management,
            onTap: () {
              controller.toManageNewPage(context);
            },
          ));
        }
      
        if (manageWidgets.isEmpty) return const SizedBox.shrink();
      
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 1.wMin,
              height: 86.wMin,
              color: AppTheme.cBorderTertiary.color,
              margin: EdgeInsets.only(
                left: 19.wMin,
                right: 19.wMin,
                top: 2.wMin,
              ),
            ),
            Row(
              spacing: 19.wMin,
              children: manageWidgets,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNavManageIconWidget({
    required AppHomeButtonEnum data,
    required void Function()? onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.05,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            data.imagePath,
            width: 86.wMin,
            height: 86.wMin,
          ),
          SizedBox(height: 10.wMin),
          Text(
            data.name,
            style: TextStyle(
              fontSize: 22.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 6.wMin + 10.wMin),
        ],
      ),
    );
  }

  Widget buildNavIconWidget({
    required AppHomeButtonEnum data,
    Future<void> Function()? onTap,
    GlobalKey? itemKey,
    bool opacity = false,
  }) {

    return Opacity(
      key: itemKey,
      opacity: opacity ? 0.4 : 1,
      child: GuideStepWidget(
        id: data.widgetId,
        disableKey: disableButton,
        onTap: onTap,
        sclae: 1.05,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              data.imagePath,
              width: 86.wMin,
              height: 86.wMin,
            ),
            SizedBox(height: 10.wMin),
            Text(
              data.name,
              style: TextStyle(
                fontSize: 22.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            SizedBox(height: 6.wMin),
            AnimatedScale(
              duration: Duration(milliseconds: data == AppHomeButtonEnum.home ? 300 : 0),
              scale: data == AppHomeButtonEnum.home ? 1 : 0,
              curve: Curves.bounceOut,
              child: Container(
                width: 10.wMin,
                height: 10.wMin,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffACB5BC),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserWidget(BuildContext context) {
    
    return Opacity(
      opacity: opactiyButton ? 0.4 : 1,
      child: Container(
        padding: EdgeInsets.only(bottom: 20.wMin),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.wMin),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              height: 128.wMin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.wMin),
                color: AppTheme.cStaticBlack.color.withValues(alpha: 0.05),
                border: Border.all(
                  width: 1.wMin,
                  color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 8.wMin),
                  _buildUserHeadWidget(context),
                  SizedBox(width: 8.wMin),
                  Container(
                    width: 2.wMin,
                    height: 46.wMin,
                    color: AppTheme.cTextTertiary.color.withValues(alpha: 0.2),
                  ),
                  _buildUserLikeWidget(context),
                  Container(
                    width: 2.wMin,
                    height: 46.wMin,
                    color: AppTheme.cTextTertiary.color.withValues(alpha: 0.2),
                  ),
                  Obx((){
    
                    bool isMessagge = Get.find<MessageController>().unreadCount.value > 0;
    
                    return GuideStepWidget(
                      id: GuideWidgetIds.homeMessageButton,
                      disableKey: disableButton,
                      onTap: () async{
                        controller.openMessage(context);
                      },
                      child: _buildUserIconTextWidget(
                        svg: "assets/svg/public/icon_message.svg",
                        name: "消息",
                        showDot: isMessagge,
                      ),
                    );
                  }),
                  Container(
                    width: 2.wMin,
                    height: 46.wMin,
                    color: AppTheme.cTextTertiary.color.withValues(alpha: 0.2),
                  ),
                  GuideStepWidget(
                    id: GuideWidgetIds.homeUserButton,
                    disableKey: disableButton,
                    onTap: () async{
                      controller.toUserCenter(context);
                    },
                    child: _buildUserIconTextWidget(
                      svg: "assets/svg/public/icon_head.svg",
                      name: "我的",
                    ),
                  ),
    
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeadWidget(BuildContext context) {
    return Row(
      children: [
        Obx(() {
          String? memberAvatarUrl = UserStore.to.userInfo.value.memberAvatarUrl;

          return TapScaleWidget(
            onTap: () {
              if (UserStore.to.userInfo.value.memberId == null) {
                controller.toUserCenter(context, toUserModelIndex: 1);
                return;
              }

              if (UserStore.to.userInfo.value.assessmentTier == null) {
                controller.toUserCenter(context, toUserModelIndex: 0);
                return;
              }

              if (UserStore.to.userInfo.value.enableSwitchMember == true) {
                SwitchStudentsUtils.showQuickSwitchStudent(context);
              }
            },
            sclae: 1,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 86.wMin,
                  height: 86.wMin,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 2.wMin, color: AppTheme.cTextPrimary.withValues(alpha: 0.3)),
                  ),
                  child: ClipOval(
                    child: CachedImageWidget(
                      memberAvatarUrl ?? "",
                      placeholder: SvgPicture.asset(
                        "assets/svg/public/icon_user.svg",
                        width: 86.wMin,
                        height: 86.wMin,
                      ),
                      errorWidget: SvgPicture.asset(
                        "assets/svg/public/icon_user.svg",
                        width: 86.wMin,
                        height: 86.wMin,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -10.wMin,
                  child: Obx(() {
                    int? memberId = UserStore.to.userInfo.value.memberId;
                    if (memberId == null) {
                      return Container();
                    }

                    int? assessmentTier = UserStore.to.userInfo.value.assessmentTier;
                    if (assessmentTier == null) {
                      return Container(
                        height: 26.wMin,
                        padding: EdgeInsets.only(left: 4.wMin),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.wMin),
                          color: AppTheme.cFeedbackErrorIcon.color,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "去评测",
                              style: TextStyle(
                                fontSize: 18.wMin,
                                color: AppTheme.cInverseTextLight.color,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SvgPicture.asset(
                              "assets/svg/public/icon_w_arrow_right.svg",
                              width: 18.wMin,
                            ),
                          ],
                        ),
                      );
                    }
                    DifficultyColor diffColors = StatusUtils.getLevelBackgroundColor(assessmentTier);
                    return Container(
                      height: 26.wMin,
                      padding: EdgeInsets.symmetric(horizontal: 4.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.wMin),
                        color: diffColors.color1,
                      ),
                      child: Text(
                        "Level $assessmentTier",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cInverseTextLight.color,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        }),
        SizedBox(width: 8.wMin),
        Obx(() {
          bool? enableSwitchMember = UserStore.to.userInfo.value.enableSwitchMember;
          int? memberId = UserStore.to.userInfo.value.memberId;
          return Visibility(
            visible: memberId != null,
            child: TapScaleWidget(
              onTap: () {
                if (enableSwitchMember == true) {
                  SwitchStudentsUtils.showQuickSwitchStudent(context);
                }
              },
              sclae: 1,
              child: Container(
                color: Colors.transparent,
                child: Obx(() {
                  String? memberName = UserStore.to.userInfo.value.memberName;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8.wMin,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: 140.wMin,
                        ),
                        child: Text(
                          memberName ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextPrimary.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: enableSwitchMember == true,
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "切换学员",
                                style: TextStyle(
                                  fontSize: 18.wMin,
                                  color: AppTheme.cTextPrimary.color,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SvgPicture.asset(
                                "assets/svg/public/icon_switch.svg",
                                width: 18.wMin,
                                colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUserLikeWidget(BuildContext context) {
    return GuideStepWidget(
      id: GuideWidgetIds.homeFavoriteButton,
      disableKey: disableButton,
      onTap: () async{
        controller.toFavorite(context);
      },
      sclae: 1,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
        child: Column(
          spacing: 12.wMin,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.wMin,
              height: 40.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackErrorBorder.color),
                color: AppTheme.cFeedbackErrorBackground.color,
              ),
              child: SvgPicture.asset(
                "assets/svg/public/icon_like.svg",
                width: 24.wMin,
                height: 24.wMin,
              ),
            ),
            Text(
              "收藏",
              style: TextStyle(
                fontSize: 22.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildUserIconTextWidget({
    required String svg,
    required String name,
    bool showDot = false,
  }) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      child: Column(
        spacing: 12.wMin,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              SvgPicture.asset(
                svg,
                width: 40.wMin,
                height: 40.wMin,
                colorFilter: ColorFilter.mode(
                  AppTheme.cTextPrimary.color,
                  BlendMode.srcIn,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Visibility(
                  visible: showDot,
                  child: Container(
                    width: 12.wMin,
                    height: 12.wMin,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cSurfaceError.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: 22.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
