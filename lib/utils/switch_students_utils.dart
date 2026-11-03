

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../app/modules/application/controllers/application_controller.dart';
import '../app/modules/user_center/common/switch_student_loading_dialog.dart';
import '../common/entities/entities.dart';
import '../common/https/https.dart';
import '../common/public_controller/config_controller.dart';
import '../common/public_controller/mv_player_global_float_controller.dart';
import '../common/stores/stores.dart';
import '../common/widgets/widgets.dart';
import '../theme/theme_utils.dart';

class SwitchStudentsUtils{

  
  /// 显示快速切换学员弹窗
  static Future<void> showQuickSwitchStudent(BuildContext context) async {

    /// 用户学员列表
    List<UserTeamEntityMembers> userTeamMembers = [];

    try {
      ToastUtils.showLoading();
      UserTeamEntity? team = await UserRequest.getUserTeam();
      if (team == null) return;
      List<UserTeamEntityMembers?> members = team.members ?? [];
      for (UserTeamEntityMembers? member in members) {
        if (member == null || member.memberId == null) continue; 
        userTeamMembers.add(member);
      }

    } finally{
      ToastUtils.hideLoading();
    }

    if(userTeamMembers.isEmpty) return;
    
    await showCupertinoDialog(
      context: context, 
      barrierDismissible: false,
      builder: (BuildContext context) {
        return QuickSwitchStudentDialogWidget(
          userTeamMembers: userTeamMembers,
        );
      },
    );

  }


  /// 切换学员
  static Future<void> switchStudent({
    required BuildContext context,
    required int? targetMemberId,
    required String? targetAvatarUrl,
    required String? targetName,
    Future<void> Function()? onComplete,
  }) async {
    await SwitchStudentLoadingDialog.show(
      context: context,
      currentAvatarUrl: UserStore.to.userInfo.value.memberAvatarUrl,
      currentName: UserStore.to.userInfo.value.memberName,
      targetAvatarUrl: targetAvatarUrl,
      targetName: targetName,
      onComplete: () async {
        Map<String, dynamic> reqData = {
          "memberId": targetMemberId,
        };
        bool switchRes = await UserRequest.switchStudent(reqData);
        if (!switchRes) return;
       
        MvPlayerGlobalFloatController.to.stop();
        
        if (UserStore.to.userInfo.value.config?.theme != null) {
          ThemeUtils.changeTheme(UserStore.to.userInfo.value.config!.theme!);
        }

        if (Get.isRegistered<ConfigController>()) {
          await Get.find<ConfigController>().initConfig();
        }


        if(Get.isRegistered<ApplicationController>()){
          await Get.find<ApplicationController>().refreshHomePages();
        }

        // 待定 后续可能还会刷新其他东西

         await onComplete?.call();
      },
    );
  }


}




class QuickSwitchStudentDialogWidget extends StatefulWidget {
  final List<UserTeamEntityMembers> userTeamMembers;
  const QuickSwitchStudentDialogWidget({super.key, required this.userTeamMembers});

  @override
  State<QuickSwitchStudentDialogWidget> createState() => _QuickSwitchStudentDialogWidgetState();
}

class _QuickSwitchStudentDialogWidgetState extends State<QuickSwitchStudentDialogWidget> {

  /// 切换学员
  Future<void> _switchStudent(UserTeamEntityMembers item) async{
    if(item.memberId == null) return;
    bool isPwdRight = await ParentPasswordialog.show(context: context, isCheckHasPassword: false);
    if (!isPwdRight) return;
    SwitchStudentsUtils.switchStudent(
      context: context, 
      targetMemberId: item.memberId, 
      targetAvatarUrl: item.avatarUrl, 
      targetName: item.nickname,
      onComplete: () async{
        await UserStore.to.getUserInfo();
        Get.back(result: true);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Container(
          width: 576.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            color: AppTheme.cSurfaceSecondary.color,
          ),
          child: Stack(
            children: [

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitleWidget(),
                  _buildListWidget(),
                  SizedBox(height: 24.wMin),
                ],
              ),

              Positioned(
                right: 16.wMin,
                top: 16.wMin,
                child: TapScaleWidget(
                  sclae: 1.05,
                  onTap: () => Get.back(),
                  child: Container(
                    width: 42.wMin,
                    height: 42.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cSurfaceTertiary.color,
                    ),
                    child: SvgPicture.asset(
                      "assets/svg/public/x.svg",
                      width: 24.wMin,
                      height: 24.wMin,
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


  Widget _buildTitleWidget(){
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(32.wMin),
      child: Text(
        "快速切换学员",
        style: TextStyle(
          fontSize: 28.wMin,
          color: AppTheme.cTextPrimary.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }


  Widget _buildListWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Column(
        spacing: 8.wMin,
        children: List.generate(widget.userTeamMembers.length, (index){
          return _buildItemWidget(widget.userTeamMembers[index]);
        }),
      ),
    );
  }


  Widget _buildItemWidget(UserTeamEntityMembers item){
    bool isCurrent = UserStore.to.userInfo.value.memberId == item.memberId;

    return TapScaleWidget(
      sclae: 1.01,
      onTap: isCurrent ? null : () {
        _switchStudent(item);
      },
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Row(
          spacing: 10.wMin,
          children: [
      
            ClipOval(
              child: CachedImageWidget(
                item.avatarUrl ?? "",
                width: 80.wMin,
                height: 80.wMin,
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
      
            Expanded(
              child: Column(
                spacing: 10.wMin,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nickname??"",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _buildTierWidget(item.assessmentTier),
      
                ],
              ),
            ),
      
      
            _buildSwitchButtonWidget(item),
      
          ],
        ),
      ),
    );
  }


  Widget _buildTierWidget(int? assessmentTier){
    if(assessmentTier == null){
      return Container(
        height: 26.wMin,
        padding: EdgeInsets.symmetric(horizontal: 4.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.wMin),
          color: AppTheme.cFeedbackErrorIcon.color,
        ),
        child: Text(
          "未评测",
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cInverseTextLight.color,
            fontWeight: FontWeight.w400,
          ),
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
  }


  Widget _buildSwitchButtonWidget(UserTeamEntityMembers item){
    bool isCurrent = UserStore.to.userInfo.value.memberId == item.memberId;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.wMin),
      color: Colors.transparent,
      child: Text(
        isCurrent ? "当前学员" : "点击切换",
        style: TextStyle(
          fontSize: 22.wMin,
          color: isCurrent ? AppTheme.cTextBrand.color : AppTheme.cTextTertiary.color,
          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );  


  }


}