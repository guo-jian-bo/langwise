

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../theme/theme.dart';
import '../../../../routes/routes.dart';
import '../bindings/become_inviter_binding.dart';
import '../controllers/become_inviter_controller.dart';

class BecomeInviterView extends GetView<BecomeInviterController> {
  final String tagText;
  const BecomeInviterView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => BecomeInviterView(tagText: tag),
      binding: BecomeInviterBinding(tagText: tag),
      routeName: Routes.BECOME_INVITER,
      arguments: arguments,
      preventDuplicates: false,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        children: [
          const BreadcrumbWidget(),
          Expanded(
            child: Stack(
              children: [
                _buildTitleWidget(context),
                Positioned(
                  top: 160.wMin,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBodyWidget(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomFloatWidget(),
    );
  }


  Widget _buildTitleWidget(BuildContext context){
    return SizedBox(
      height: 400.wMin,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            width: MediaQuery.of(context).size.width,
            height: 400.wMin,
            child: Image.asset(
              "assets/images/user_center/inviter_title.png",
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            top: 20.wMin,
            left: 40.wMin,
            right: 40.wMin,
            child: SizedBox(
              height: 140.wMin,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "成为邀请者得奖励",
                        style: TextStyle(
                          fontSize: 48.wMin,
                          color: AppTheme.cInverseTextLight.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "完成以下任务，解锁邀请资格",
                        style: TextStyle(
                          fontSize: 28.wMin,
                          color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  _buildInviterTaskWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  


  /// 邀请任务进度
  Widget _buildInviterTaskWidget(){
    return SizedBox(
      width: 500.wMin,
      child: Obx((){
        int completedTaskCount = controller.completedTaskCount.value;
        int totalTaskCount = controller.invitationTaskList.length;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 8.wMin,
          children: [
            Row(
              children: [
                Text(
                  "邀请资格任务进度",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  "$completedTaskCount/$totalTaskCount",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            Row(
              spacing: 4.wMin,
              children: List.generate(totalTaskCount, (index){

                Color color = AppTheme.cInverseTextLight.color.withValues(alpha: 0.1);
                if(index < completedTaskCount){
                  color = AppTheme.cInverseTextLight.color;
                }

                return Expanded(
                  child: Container(
                    height: 12.wMin,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                );
              }),
            ),

          ],
        );
      }),
    );
  }


  Widget _buildBodyWidget(){
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.wMin),
          topRight: Radius.circular(32.wMin),
        ),
        color: AppTheme.cBgPrimary.color,
        border: Border(
          top: BorderSide(
            color: const Color(0xffC4B5FD),
            width: 4.wMin,
          ),
        ),
      ),
      child: Obx((){
        if(controller.loadingStatus.value == 0){
          return const NotDataWidget(message: "当前暂无任务");
        }
        return ListView.separated(
          itemCount: controller.invitationTaskList.length,
          padding: EdgeInsets.symmetric(horizontal: 220.wMin, vertical: 40.wMin),
          separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
          itemBuilder: (context, index){
            return _buildTaskItemWidget(controller.invitationTaskList[index], index);
          },
        );
      }),
    );
  }

  Widget _buildTaskItemWidget(BecomeInviterTaskEntityListUserTasks data, int index){
    double progress = 0;
    if((data.progressTarget??0) != 0){
      progress = (data.current??0) / (data.progressTarget??0);
      if(progress < 0) progress = 0;
    }

    bool isBan = data.taskTypeEnum != TaskTypeEnum.INSTANT && data.statusEnum == ActivityConsoleTaskStatus.BAN;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 22.wMin, vertical: 18.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: AppTheme.cSurfaceSecondary.color,
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
      ),
      child: Row(
        children: [
          Container(
            width: 48.wMin,
            height: 48.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromRGBO(167, 139, 250, 0.08),
              border: Border.all(width: 1.wMin, color: const Color.fromRGBO(167, 139, 250, 0.25)),
            ),
            child: Text(
              "${index + 1}",
              style: TextStyle(
                fontSize: 24.wMin,
                color: const Color(0xffA78BFA),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 24.wMin),


          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.name??"",
                            style: TextStyle(
                              fontSize: 28.wMin,
                              color: AppTheme.cTextPrimary.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            data.description??"",
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: AppTheme.cTextTertiary.color,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                
                    Visibility(
                      visible: data.statusEnum != ActivityConsoleTaskStatus.COMPLETED,
                      child: TapScaleWidget(
                        onTap: OptimizeUtils.noneThrottle(() {
                          controller.goCompleteTask(data);
                        }, 300),
                        sclae: 1.05,
                        child: Container(
                          width: 150.wMin,
                          height: 64.wMin,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.wMin),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                const Color(0xff8B5CF6).withValues(alpha: isBan ? 0.4 : 1),
                                const Color(0xffA78BFA).withValues(alpha: isBan ? 0.4 : 1),
                              ],
                            ),
                          ),
                          child: Text(
                            "去完成",
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: AppTheme.cInverseTextLight.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                
                    Visibility(
                      visible: data.statusEnum == ActivityConsoleTaskStatus.COMPLETED,
                      child: Container(
                        width: 78.wMin,
                        height: 78.wMin,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(167, 139, 250, 0.2),
                        ),
                        child: SvgPicture.asset(
                          "assets/svg/public/icon_check.svg",
                          width: 40.wMin,
                        ),
                      ),
                    ),
                  ],
                ),

                Visibility(
                  visible: (data.statusEnum == ActivityConsoleTaskStatus.IN_PROGRESS || data.statusEnum == ActivityConsoleTaskStatus.NOT_STARTED) && data.taskTypeEnum == TaskTypeEnum.ACCUMULATION,
                  child: Container(
                    margin: EdgeInsets.only(top: 20.wMin),
                    child: Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10.wMin,
                            backgroundColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.05),
                            color: AppTheme.cTextBrand.color,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                  
                        SizedBox(width: 16.wMin),
                        Text.rich(TextSpan(
                          style: TextStyle(
                            fontSize: 22.wMin,
                            color: AppTheme.cTextTertiary.color,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            TextSpan(text: "${data.current??0}", style: TextStyle(color: AppTheme.cTextPrimary.color)),
                            TextSpan(text: "/${data.progressTarget??0}"),
                          ],
                        )),
                  
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
      
        ],
      ),
    );
  }


  Widget _buildBottomFloatWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 220.wMin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCanObtainWidget(),
          SizedBox(height: 10.wMin),
          _buildBottemButtonWidget(),
        ],
      ),
    );
  }


  Widget _buildCanObtainWidget(){
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.wMin),
      child: Container(
        height: 126.wMin,
        padding: EdgeInsets.only(left: 22.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceSecondary.color,
          image: const DecorationImage(
            image: AssetImage("assets/images/user_center/inviter_card_bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Row(
          children: [

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "成为邀请者后可获得",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "邀请好友，共享学习收获",
                  style: TextStyle(
                    fontSize: 22.wMin,
                    color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            SizedBox(width: 20.wMin),

            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx((){
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(controller.inviterRewardsList.length, (index){
                  
                        InviterRewardsEntityList item = controller.inviterRewardsList[index];
                  
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Visibility(
                              visible: index > 0,
                              child: _buildCanObtainDivItemWidget(),
                            ),
                            _buildCanObtainItemWidget(
                              value: item.priceName??"", 
                              subtitle: item.description??"",
                              type: item.typeEnum,
                            ),
                          ],
                        );
                  
                      }),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCanObtainItemWidget({
    required String value,
    required String subtitle,
    required ReferralAwardTypeEnum? type,
  }){

    String image = "";
    if(type == ReferralAwardTypeEnum.POINTS){
      image = "assets/images/public/icon_learn_point.png";
    }else if(type == ReferralAwardTypeEnum.CREDIT){
      image = "assets/images/public/icon_nai_coin.png";
    } else if(type == ReferralAwardTypeEnum.PLUS_VIP){
      image = "assets/images/public/icon_plus_s.png";
    } else if(type == ReferralAwardTypeEnum.PRO_VIP){
      image = "assets/images/public/icon_pro_s.png";
    } else if(type == ReferralAwardTypeEnum.MAX_VIP){
      image = "assets/images/public/icon_max_s.png";
    }

    return Container(
      height: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 42.wMin),
      child: Row(
        children: [
      
          Visibility(
            visible: image.isNotEmpty,
            child: Container(
              width: 72.wMin,
              height: 72.wMin,
              margin: EdgeInsets.only(right: 24.wMin),
              child: Image.asset(
                image,
              ),
            ),
          ),
      
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 32.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 22.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
      
        ],
      ),
    );
  }

  Widget _buildCanObtainDivItemWidget(){
    return Container(
      height: 55.wMin,
      width: 1.wMin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }


  Widget _buildBottemButtonWidget(){
    return Obx((){
      int completedTaskCount = controller.completedTaskCount.value;
      int totalTaskCount = controller.invitationTaskList.length;
      bool isCompleted = completedTaskCount == totalTaskCount && totalTaskCount != 0;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Visibility(
            visible: !isCompleted,
            child: ButtonWidget(
              text: "还需要完成 ${totalTaskCount - completedTaskCount} 项任务",
              width: 700.wMin,
              height: 72.wMin,
              borderRadius: 14.wMin,
              color: AppTheme.cSurfaceQuaternary.color,
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              fontColor: AppTheme.cTextTertiary.color,
              leftIcon: Container(
                margin: EdgeInsets.only(right: 8.wMin),
                child: SvgPicture.asset(
                  "assets/svg/public/icon_lock_blank.svg", 
                  width: 32.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                ),
              ),
            ),
          ),

          Visibility(
            visible: isCompleted,
            child: TapScaleWidget(
              onTap: OptimizeUtils.noneThrottle(() {
                controller.referralApply();
              }, 300),
              sclae: 1.01,
              child: Container(
                width: 700.wMin,
                height: 72.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.wMin),
                  border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 0.20),
                    width: 2.wMin,
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0.0, 0.5, 1.0],
                    colors: [
                      Color(0xFFA78BFA),
                      Color(0xFF818CF8),
                      Color(0xFFD946EF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA78BFA),
                      offset: Offset(0, 2.wMin),
                      blurRadius: 10.wMin,
                    ),
                  ],
                ),
                child: Text(
                  "已完成全部任务 解锁邀请者权限",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    color: AppTheme.cInverseTextLight.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 10.wMin),

          Visibility(
            visible: !isCompleted,
            child: Text(
              "完成所有任务后即可解锁邀请资格，开始邀请好友赚取奖励",
              style: TextStyle(
                fontSize: 22.wMin,
                color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          SizedBox(height: 10.wMin),
        ],
      );
    });
  }

  

}
