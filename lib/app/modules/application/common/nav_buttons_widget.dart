import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/common/widgets/guide_engine/guide_anchor.dart';
import '../../../../common/stores/stores.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../controllers/application_controller.dart';
import '../model/application_nav_model.dart';

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
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildNavWidget(context),
          Positioned(
            right: 70.wMin,
            child: _buildUserWidget(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavWidget(BuildContext context) {
    final List<ApplicationNavModel> navDataList = [
      ApplicationNavModel("首页", "nav_main.webp"),
      ApplicationNavModel("甄听", "nav_exlisten.webp"),
      ApplicationNavModel('音乐', 'nav_music.webp'),
      ApplicationNavModel("要素", "nav_card.webp"),
      ApplicationNavModel("专项", "nav_specialized_courses.webp"),
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
            height: 128.wMin,
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
                        index: index,
                        itemKey: index == 3 ? cardsKey : null,
                        opacity: opactiyButton && index != 3,
                        onTap: () {
                          controller.changeNavIndex(index, context);
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
      child: IgnorePointer(
        ignoring: disableButton,
        child: Obx(() {
          // bool isAdmin = controller.userStore.userInfo.value.isAdmin;
          bool userIsAdmin = controller.userStore.rolePermissions.value.userIsAdmin;
          bool isImageReview = controller.userStore.rolePermissions.value.userIsImageReviewer;
          bool userIsExerciseReviewer = controller.userStore.rolePermissions.value.userIsExerciseReviewer;
          bool userIsVideoReviewer = controller.userStore.rolePermissions.value.userIsVideoReviewer;
          bool userIsAssReviewer = controller.userStore.rolePermissions.value.userIsAssReviewer;

          // isAdmin = false;
          // isImageReview = false;
          // userIsExerciseReviewer = false;

          List<Widget> manageWidgets = [];

          // if (isImageReview) {
          //   manageWidgets.add(_buildNavManageIconWidget(
          //     iconImg: "review_images.webp",
          //     onTap: () {
          //       controller.toPreviewImagePage();
          //     },
          //   ));
          // }

          // if(userIsExerciseReviewer){
          //   manageWidgets.add(_buildNavManageIconWidget(
          //     iconImg: "nav_review_exercises.webp",
          //     onTap: () {
          //       controller.toReviewExercisesPage();
          //     },
          //   ));
          // }

          // if(isAdmin){
          //   manageWidgets.add(_buildNavManageIconWidget(
          //     iconImg: "nav_manage.webp",
          //     onTap: () {
          //       controller.toManagePage();
          //     },
          //   ));
          // }

          if(userIsAdmin || isImageReview || userIsExerciseReviewer || userIsVideoReviewer || userIsAssReviewer){
            manageWidgets.add(_buildNavManageIconWidget(
              iconImg: "nav_manage_new.webp",
              onTap: () {
                controller.toManageNewPage(context);
              },
            ));
          }

          if (manageWidgets.isEmpty) return const SizedBox.shrink();

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 1.wMin,
                height: 39.wMin,
                color: AppTheme.cBorderTertiary.color,
                margin: EdgeInsets.symmetric(horizontal: 19.wMin),
              ),
              Row(
                spacing: 19.wMin,
                children: manageWidgets,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildNavManageIconWidget({
    required String iconImg,
    required void Function()? onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.05,
      child: Image.asset(
        "assets/images/application/$iconImg",
        width: 86.wMin,
        height: 86.wMin,
      ),
    );
  }

  Widget buildNavIconWidget({
    required ApplicationNavModel data,
    required int index,
    void Function()? onTap,
    GlobalKey? itemKey,
    bool opacity = false,
  }) {
    return Opacity(
      key: itemKey,
      opacity: opacity ? 0.4 : 1,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          TapScaleWidget(
            onTap: disableButton ? null : onTap,
            sclae: 1.05,
            child: Image.asset(
              "assets/images/application/${data.iconImg}",
              width: 86.wMin,
              height: 86.wMin,
            ),
          ),
          Positioned(
            bottom: -14.wMin,
            child: Obx(() {
              return AnimatedScale(
                duration: Duration(milliseconds: controller.navIndex.value == index ? 300 : 0),
                scale: controller.navIndex.value == index ? 1 : 0,
                curve: Curves.bounceOut,
                child: Container(
                  width: 10.wMin,
                  height: 10.wMin,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffACB5BC),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUserWidget(BuildContext context) {
    return IgnorePointer(
      ignoring: disableButton,
      child: Opacity(
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
                    GuideAnchor(
                      id: 'to_user_center',
                      route: Routes.APPLICATION,
                      child: _buildUserIconTextWidget(
                        svg: "assets/svg/public/icon_head.svg",
                        name: "我的",
                        onTap: () {
                          controller.toUserCenter(context);
                        },
                      ),
                    ),
                  ],
                ),
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
    return TapScaleWidget(
      onTap: () {
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
    void Function()? onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
        child: Column(
          spacing: 12.wMin,
          mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}
