import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../controllers/manage_students_controller.dart';

class ManageStudentsView extends GetView<ManageStudentsController> { 
  const ManageStudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Container(
        alignment: Alignment.center,
        child: Container(
          width: 1680.wMin,
          padding: EdgeInsets.only(
            top: 40.wMin + MediaQuery.of(context).padding.top,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const BackWidget(title: "管理学员"),

                  Visibility(
                    visible: controller.userStore.userInfo.value.teamId != null,
                    child: Container(
                      margin: EdgeInsets.only(left: 16.wMin),
                      child: ButtonWidget(
                        text: "团队ID: ${controller.userStore.userInfo.value.teamId ?? ""}",
                        padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
                        borderRadius: 8.wMin,
                        color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                        fontColor: AppTheme.cSurfaceBrand.color,
                        fontSize: 18.wMin,
                        sclae: 1.01,
                        onTap: () {
                          controller.copyUserId(controller.userStore.userInfo.value.teamId);
                        },
                      ),
                    ),
                  ),

                ],
              ),
              Expanded(
                child: _buildStudentListWidget(context),
              ),
        
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentListWidget(BuildContext context){
    return Obx((){

      /// 是否展示购买席位按钮
      bool showBuyButton = controller.userStore.userInfo.value.maxTraineeSize != null &&
          controller.userStore.userInfo.value.maxTraineeSize! > controller.userTeamMembers.length;
      if(controller.userStore.userInfo.value.isFree){
        showBuyButton = false;
      }
      // showBuyButton = false;

      return SingleChildScrollView(
        padding: EdgeInsets.only(
          top: 16.wMin,
          bottom: 16.wMin + MediaQuery.of(Get.context!).padding.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cBgSecondary.color,
            borderRadius: BorderRadius.circular(12.wMin),
          ),
          child: Column(
            children: [
              ...List.generate(controller.userTeamMembers.length, (index){
                if(controller.userTeamMembers[index].memberId == null){ // 空席位
                  return _buildWaitAssignWidget(context, controller.userTeamMembers[index], index);
                }
                return _buildStudentItemWidget(controller.userTeamMembers[index], context, index);
              }),
              Visibility(
                visible: showBuyButton,
                child: _buildBuySeatWidget(controller.userTeamMembers.length),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 购买席位
  Widget _buildBuySeatWidget(int index){
    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.cBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Row(
        children: [
          TapScaleWidget(
            onTap: () {
              controller.buySeat();
            },
            sclae: 1.03,
            child: Container(
              width: 68.7.wMin,
              height: 68.7.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cBgTertiary.color,
              ),
              child: SvgPicture.asset(
                "assets/svg/public/icon_add.svg",
                width: 32.wMin,
              ),
            ),
          ),
          SizedBox(width: 24.wMin),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "可购买 ${controller.currentBuySeatCount.value} 个席位",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SizedBox(height: 4.wMin),
              Text(
                "与家人朋友共享",
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ],
          ),
          const Spacer(),
          ButtonWidget(
            text: "立即购买",
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
            borderRadius: 6.wMin,
            color: AppTheme.cSurfaceTertiary.color,
            fontColor: AppTheme.cTextPrimary.color,
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: () async {
              await controller.buySeat();
            },
          ),
        ],
      ),
    );
  }

  /// 待分配
  Widget _buildWaitAssignWidget(BuildContext context, UserTeamEntityMembers data, int index){
    
    String expired = DateFormatUtil.formatStrtoStr(data.expired?.end);
    
    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        border: index == 0 ? null : Border(
          top: BorderSide(
            color: AppTheme.cBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Row(
        spacing: 24.wMin,
        children: [
          SvgPicture.asset(
            "assets/svg/public/icon_user.svg",
            width: 68.7.wMin,
            height: 68.7.wMin,
          ),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "待分配席位",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                SizedBox(height: 4.wMin),
                Row(
                  children: [
                    Text(
                      "学位 ${data.traineeId?.padLeft(2, '0')} ｜ ",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextTertiary.color,
                      ),
                    ),
                    Text(
                      data.isExpired??false ? "已于 $expired 过期" : "您拥有此席位",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: data.isExpired??false ? AppTheme.cFeedbackErrorText.color : AppTheme.cTextTertiary.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "到期时间",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  (data.isExpired??false) ? "已于 $expired 过期" : expired,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: data.isExpired??false ? AppTheme.cFeedbackErrorText.color : AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
          
          Row(
            children: [
              Visibility(
                visible: data.traineeId != null && !controller.userStore.userInfo.value.isFree,
                child: ButtonWidget(
                  text: "续期",
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
                  borderRadius: 6.wMin,
                  color: AppTheme.cSurfaceTertiary.color,
                  fontColor: AppTheme.cTextPrimary.color,
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  sclae: 1.03,
                  onTap: () {
                    controller.renewStudent(data);
                  },
                ),
              ),
              SizedBox(width: 16.wMin),
              ButtonWidget(
                text: data.isExpired??false ? "已过期" : "添加学员",
                padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
                borderRadius: 6.wMin,
                color: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextPrimary.color,
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                onTap: (data.isExpired??false) ? null : () {
                  controller.createStudent(context, traineeId: data.traineeId);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentItemWidget(UserTeamEntityMembers data, BuildContext context, int index){

    String showInfo = "";

    String? moduleTitle = data.moduleTitle;
    if(moduleTitle != null){
      showInfo += "$moduleTitle ";
    }

    DateTime? birthdayDate = DateFormatUtil.tryParseDate(data.birthday??"");
    if(birthdayDate != null){
      String birthday = DateFormatUtil.formatStr(birthdayDate, newPattern: "yyyy-MM-dd", locale: Get.locale);
      showInfo += birthday;
    }

    String address = data.address??"";
    if(address.isNotEmpty){
      showInfo += " ｜ $address";
    }

    String expired = DateFormatUtil.formatStrtoStr(data.expired?.end);

    /// 是否是当前学员
    bool isCurrentStudent = data.memberId == controller.userStore.userInfo.value.memberId;

    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        border: index == 0 ? null : Border(
          top: BorderSide(
            color: AppTheme.cBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Row(
        spacing: 24.wMin,
        children: [
          ClipOval(
            child: Container(
              width: 68.7.wMin,
              height: 68.7.wMin,
              color: AppTheme.cBlackAlpha10,
              child: CachedImageWidget(
                data.avatarUrl??"",
                placeholder: SvgPicture.asset(
                  "assets/svg/public/icon_user.svg",
                  width: 68.7.wMin,
                  height: 68.7.wMin,
                ),
                errorWidget: SvgPicture.asset(
                  "assets/svg/public/icon_user.svg",
                  width: 68.7.wMin,
                  height: 68.7.wMin,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6.wMin,
              children: [
                Row(
                  spacing: 16.wMin,
                  children: [
                    Text(
                      data.nickname??"",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary,
                      ),
                    ),
                    ButtonWidget(
                      text: "ID: ${data.memberId ?? ""}",
                      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
                      borderRadius: 8.wMin,
                      color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                      fontColor: AppTheme.cSurfaceBrand.color,
                      fontSize: 18.wMin,
                      sclae: 1.01,
                      onTap: () {
                        controller.copyUserId(data.memberId);
                      },
                    ),
                    Visibility(
                      visible: isCurrentStudent,
                      child: ButtonWidget(
                        text: "当前学员",
                        padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
                        borderRadius: 8.wMin,
                        color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                        fontColor: AppTheme.cSurfaceBrand.color,
                        fontSize: 18.wMin,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "学位 ${data.traineeId?.padLeft(2, '0')} ｜ ",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                    Text(
                      showInfo,
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "到期时间",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  (data.isExpired??false) ? "已于 $expired 过期" : expired,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: data.isExpired??false ? AppTheme.cFeedbackErrorText.color : AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
          
          Row(
            children: [
              Visibility(
                visible: data.traineeId != null && !controller.userStore.userInfo.value.isFree,
                child: ButtonWidget(
                  text: "续期",
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
                  borderRadius: 6.wMin,
                  color: AppTheme.cSurfaceTertiary.color,
                  fontColor: AppTheme.cTextPrimary.color,
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  sclae: 1.03,
                  onTap: () {
                    controller.renewStudent(data);
                  },
                ),
              ),
              SizedBox(width: 20.wMin),
              TapScaleWidget(
                onTap: (){
                  controller.createStudent(context, data: data);
                },
                sclae: 1.1,
                child: Container(
                  padding: EdgeInsets.all(16.wMin),
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_edit.svg",
                    width: 24.wMin,
                    height: 24.wMin,
                  ),
                ),
              ),
              TapScaleWidget(
                onTap: (){
                  controller.deleteStudent(context, data);
                },
                sclae: 1.1,
                child: Container(
                  padding: EdgeInsets.all(16.wMin),
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_delete.svg",
                    width: 24.wMin,
                    height: 24.wMin,
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }





}
