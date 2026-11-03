import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../controllers/user_center_controller.dart';

class UserCenterStudentsWidget extends GetView<UserCenterController> {
  /// 用户中心 学员
  final String tagText;
  const UserCenterStudentsWidget({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      int? memberId = controller.userStore.userInfo.value.memberId;
      List<UserTeamEntityMembers> members = controller.userTeamMembers.toList();
      int maxTraineeSize = controller.userStore.userInfo.value.maxTraineeSize ?? 0;
      int buySize = maxTraineeSize - members.length;
      
      if (memberId != null) {
        members.removeWhere((element) => element.memberId == memberId);
      }

      
      // if(members.isEmpty) return Container();

      /// 是否展示购买席位按钮
      bool showBuyButton = buySize > 0;
      if (controller.userStore.userInfo.value.isFree) {
        showBuyButton = false;
      }
      // showBuyButton = false;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "我的学员",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Visibility(
                visible: memberId == null,
                child: TapScaleWidget(
                  onTap: (){
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
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(vertical: 16.wMin),
            child: Row(
              spacing: 19.wMin,
              children: [
                ...List.generate(members.length, (index) {
                  if (members[index].memberId == null) {
                    // 空席位
                    return _buildWaitAssignWidget(context, members[index],index);
                  }
                  return _buildStudentItemWidget(context, members[index]);
                }),
                Visibility(
                  visible: showBuyButton,
                  child: _buildBuySeatWidget(buySize),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStudentItemWidget(BuildContext context, UserTeamEntityMembers? member) {
    String showTime = "";
    DateTime? dateTime = DateFormatUtil.tryParseDate(member?.lastStudied);
    if (dateTime != null) {
      bool todayState = DateUtils.isSameDay(dateTime, DateTime.now());
      if (todayState) {
        showTime = "最近活动：今天";
      } else {
        showTime = "最近活动：${DateFormatUtil.formatStr(dateTime, newPattern: "MM-dd", locale: Get.locale)}";
      }
    }

    String expired = DateFormatUtil.formatStrtoStr(member?.expired?.end);

    return Container(
      width: 405.wMin,
      height: 206.wMin,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cBgSecondary.color,
      ),
      child: Column(
        children: [
          Row(
            children: [
              TapScaleWidget(
                onTap: () {
                  controller.editStudent(context, member);
                },
                sclae: 1,
                child: Stack(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 80.wMin,
                        height: 80.wMin,
                        child: CachedImageWidget(
                          member?.avatarUrl ?? "",
                          width: 80.wMin,
                          height: 80.wMin,
                          placeholder: SvgPicture.asset(
                            "assets/svg/public/icon_user.svg",
                            height: 80.wMin,
                            width: 80.wMin,
                          ),
                          errorWidget: SvgPicture.asset(
                            "assets/svg/public/icon_user.svg",
                            height: 80.wMin,
                            width: 80.wMin,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 24.wMin,
                        height: 24.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.cBgBrand.color,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          "assets/svg/public/icon_edit.svg",
                          width: 16.wMin,
                          height: 16.wMin,
                          colorFilter: ColorFilter.mode(AppTheme.cStaticWhite.color, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24.wMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            member?.nickname ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: AppTheme.cTextPrimary.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TapScaleWidget(
                          onTap: () {
                            controller.deleteStudent(context, member);
                          },
                          sclae: 1,
                          child: Container(
                            color: Colors.transparent,
                            child: SvgPicture.asset(
                              "assets/svg/custom_course/icon_book_info_trash.svg",
                              width: 32.wMin,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      showTime,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextSecondary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8.wMin),
                    Text(
                      member?.isExpired ?? false ? "已于 $expired 过期" : "到期时间：$expired",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: member?.isExpired ?? false ? AppTheme.cFeedbackErrorText.color : AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildButtonsWidget(context, member),
        ],
      ),
    );
  }

  Widget _buildButtonsWidget(BuildContext context, UserTeamEntityMembers? member) {
    if (member?.isExpired ?? false) {
      bool isRenewal = member?.traineeId != null && !controller.userStore.userInfo.value.isFree;

      return ButtonWidget(
        text: isRenewal ? "续期" : "已过期",
        height: 56.wMin,
        borderRadius: 6.wMin,
        color: AppTheme.cSurfaceTertiary.color,
        fontColor: AppTheme.cTextSecondary.color,
        fontSize: 24.wMin,
        fontWeight: FontWeight.w600,
        sclae: 1.02,
        onTap: !isRenewal ? null : () {
          controller.renewStudent(member);
        },
      );
    }

    int? currentMemberId = controller.userStore.userInfo.value.memberId;

    return Row(
      spacing: 12.wMin,
      children: [
        // Expanded(
        //   child: ButtonWidget(
        //     text: "查看",
        //     height: 56.wMin,
        //     borderRadius: 6.wMin,
        //     color: AppTheme.cBgTertiary.color,
        //     fontColor: AppTheme.cTextPrimary.color,
        //     fontSize: 24.wMin,
        //     fontWeight: FontWeight.w600,
        //     sclae: 1.02,
        //     onTap: () {

        //     },
        //   ),
        // ),
        Expanded(
          child: ButtonWidget(
            text: currentMemberId == member?.memberId ? "已激活" : "切换到 ${member?.nickname ?? ""} 学习",
            height: 56.wMin,
            borderRadius: 6.wMin,
            color: AppTheme.cBgBrand.color,
            fontColor: AppTheme.cStaticWhite.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            sclae: 1.02,
            onTap: () {
              if (currentMemberId == member?.memberId) return;
              controller.switcherStudent(context, member);
            },
          ),
        ),
      ],
    );
  }


  /// 待分配席位
  Widget _buildWaitAssignWidget(BuildContext context, UserTeamEntityMembers data,int index) {
    String expired = DateFormatUtil.formatStrtoStr(data.expired?.end);

    bool isExpired = data.isExpired??false;
    if(!isExpired&&controller.isSetAnchor.value==-1){
      controller.isSetAnchor.value = index;
    }

    bool isRenewal = data.traineeId != null && !controller.userStore.userInfo.value.isFree;

    return DottedBorder(
      borderType: BorderType.RRect,
      borderPadding: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      color: AppTheme.cBorderPrimary.color,
      radius: Radius.circular(16.wMin),
      strokeWidth: 1.wMin,
      dashPattern: [6.wMin, 6.wMin],
      child: Container(
        width: 405.wMin,
        height: 206.wMin,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cBgSecondary.color,
        ),
        child: Column(
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  "assets/svg/public/icon_user.svg",
                  height: 80.wMin,
                  width: 80.wMin,
                ),
                SizedBox(width: 24.wMin),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "待分配席位",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Visibility(
                      visible: !(data.isExpired ?? false),
                      child: Text(
                        "您拥有此席位",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cTextSecondary.color,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.wMin),
                    Text(
                      data.isExpired ?? false ? "已于 $expired 过期" : "到期时间：$expired",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: isExpired ? AppTheme.cFeedbackErrorText.color : AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            isExpired?ButtonWidget(
              text: (isRenewal ? "续期" : "已过期"),
              height: 56.wMin,
              borderRadius: 6.wMin,
              color: AppTheme.cSurfaceTertiary.color,
              fontColor: AppTheme.cTextSecondary.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              sclae: 1.02,
              onTap: () {
                if (isExpired) {
                  if(isRenewal) {
                    controller.renewStudent(data);
                  }
                  return;
                }
                controller.createStudent(context, data.traineeId);
              },
            ):controller.isSetAnchor.value==index?ButtonWidget(
                text: "添加学员",
                height: 56.wMin,
                borderRadius: 6.wMin,
                color: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                sclae: 1.02,
                onTap: () {
                  if (isExpired) {
                    if(isRenewal) {
                      controller.renewStudent(data);
                    }
                    return;
                  }
                  controller.createStudent(context, data.traineeId);
                },
            ):ButtonWidget(
                text: "添加学员",
                height: 56.wMin,
                borderRadius: 6.wMin,
                color: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                sclae: 1.02,
                onTap: () {
                  if (isExpired) {
                    if(isRenewal) {
                      controller.renewStudent(data);
                    }
                    return;
                  }
                  controller.createStudent(context, data.traineeId);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// 购买席位
  Widget _buildBuySeatWidget(int buySize) {
    return DottedBorder(
      borderType: BorderType.RRect,
      borderPadding: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      color: AppTheme.cBorderPrimary.color,
      radius: Radius.circular(16.wMin),
      strokeWidth: 1.wMin,
      dashPattern: [6.wMin, 6.wMin],
      child: Container(
        width: 405.wMin,
        height: 206.wMin,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cBgSecondary.color,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80.wMin,
                  height: 80.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cBgTertiary.color,
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_add.svg",
                    width: 48.wMin,
                  ),
                ),
                SizedBox(width: 24.wMin),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "可购买 $buySize 个席位",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "与家人朋友共享",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextSecondary.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            ButtonWidget(
              text: "立即购买",
              height: 56.wMin,
              borderRadius: 6.wMin,
              color: AppTheme.cSurfaceTertiary.color,
              fontColor: AppTheme.cTextSecondary.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              sclae: 1.02,
              onTap: () {
                controller.buySeat();
              },
            ),
          ],
        ),
      ),
    );
  }
}
