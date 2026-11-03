import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/widgets/guide_engine/guide_anchor.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../controllers/user_center_controller.dart';

class UserCenterActivateStudentsWidget extends GetView<UserCenterController> {
  /// 用户中心 当前激活学员
  final String tagText;
  const UserCenterActivateStudentsWidget({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "当前在学习的学员",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.wMin),
                Obx(() {
                  return Text(
                    "学习数据，都记录在 ${controller.userStore.userInfo.value.memberName ?? '此学员'} 下",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextSecondary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                }),
              ],
            ),
            const Spacer(),
            GuideAnchor(
              id: 'add_student',
              route: Routes.USER_CENTER,
              child: TapScaleWidget(
              onTap: () {
                controller.toManageStudents();
              },
              sclae: 1.05,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                height: 36.wMin,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40.wMin),
                ),
                child: Row(
                  children: [
                    Text(
                      "管理学员",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextBrand.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SvgPicture.asset(
                      "assets/svg/user_center/icon_chevron_right1.svg",
                      height: 32.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextBrand.color, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
        SizedBox(height: 24.wMin),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 24.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cBgSecondary.color,
          ),
          child: Obx(() {
            int? memberId = controller.userStore.userInfo.value.memberId;
            List<UserTeamEntityMembers> userTeamMembers = controller.userTeamMembers.toList();
            UserTeamEntityMembers? userTeamMember = userTeamMembers.firstWhereOrNull((element) => element.memberId == memberId);
            String expired = DateFormatUtil.formatStrtoStr(userTeamMember?.expired?.end);

            String showTime = "";
            DateTime? dateTime = DateFormatUtil.tryParseDate(userTeamMember?.lastStudied);
            if (dateTime != null) {
              bool todayState = DateUtils.isSameDay(dateTime, DateTime.now());
              if (todayState) {
                showTime = "今天";
              } else {
                showTime = DateFormatUtil.formatStr(dateTime, newPattern: "MM-dd", locale: Get.locale);
              }
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: Container(
                        width: 145.wMin,
                        height: 145.wMin,
                        color: AppTheme.cBlackAlpha10,
                        child: CachedImageWidget(
                          controller.userStore.userInfo.value.memberAvatarUrl ?? "",
                          placeholder: SvgPicture.asset(
                            "assets/svg/public/icon_user.svg",
                            height: 145.wMin,
                          ),
                          errorWidget: SvgPicture.asset(
                            "assets/svg/public/icon_user.svg",
                            height: 145.wMin,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.wMin),
                    Text(
                      controller.userStore.userInfo.value.memberName ?? "",
                      style: TextStyle(
                        fontSize: 36.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GuideAnchor(
                      id: "edit_profile",
                      route: Routes.USER_CENTER,
                      child: TapScaleWidget(
                        onTap: () {
                          controller.editStudent(context, userTeamMember);
                        },
                        sclae: 1.05,
                        child: Container(
                          padding: EdgeInsets.all(16.wMin),
                          color: Colors.transparent,
                          child: SvgPicture.asset(
                            "assets/svg/public/icon_edit.svg",
                            width: 32.wMin,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: showTime.isNotEmpty,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "最近活动",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextSecondary.color,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4.wMin),
                      Text(
                        showTime,
                        style: TextStyle(
                          fontSize: 28.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "到期时间",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextSecondary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 4.wMin),
                    Row(
                      spacing: 14.wMin,
                      children: [
                        Text(
                          expired,
                          style: TextStyle(
                            fontSize: 32.wMin,
                            color: AppTheme.cTextPrimary.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.wMin),
                            color: AppTheme.cFeedbackInfoBackground.color,
                          ),
                          child: Text(
                            "还剩 ${userTeamMember?.remainingDay ?? 0} 天",
                            style: TextStyle(
                              fontSize: 20.wMin,
                              color: AppTheme.cFeedbackInfoText.color,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Obx(() {
                  if (controller.userStore.userInfo.value.assessmentTier == null) {
                    return ButtonWidget(
                      text: "去评测",
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
                      color: AppTheme.cFeedbackWarningBackground.color,
                      borderRadius: 12.wMin,
                      sclae: 1.05,
                      fontSize: 28.wMin,
                      fontColor: AppTheme.cFeedbackWarningText.color,
                      fontWeight: FontWeight.w500,
                      onTap: () {
                        controller.toUserEvaluationLevel(context);
                      },
                    );
                  }

                  return GuideAnchor(
                      id: "check_assessment_report",
                      route: Routes.USER_CENTER,
                      child: TapScaleWidget(
                    onTap: () {
                      controller.toUserEvaluationResult();
                    },
                    sclae: 1,
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Row(
                            spacing: 4.wMin,
                            children: [
                              Text(
                                "当前等级",
                                style: TextStyle(
                                  fontSize: 32.wMin,
                                  color: AppTheme.cTextSecondary.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                width: 32.wMin,
                                height: 32.wMin,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.cBgBrand.color,
                                ),
                                child: SvgPicture.asset(
                                  "assets/svg/public/icon_w_arrow_right.svg",
                                  width: 24.wMin,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 10.wMin,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/public/icon_union_left.svg",
                                height: 85.wMin,
                              ),
                              Text(
                                "Level ${controller.userStore.userInfo.value.assessmentTier ?? 0}",
                                style: TextStyle(
                                  fontSize: 56.wMin,
                                  color: AppTheme.cTextPrimary.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SvgPicture.asset(
                                "assets/svg/public/icon_union_right.svg",
                                height: 85.wMin,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ));
                }),
              ],
            );
          }),
        ),
      ],
    );
  }
}
