
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';
import '../common/members_info_dialog.dart';
import '../controllers/user_center_controller.dart';

class UserCenterMemberWidget extends GetView<UserCenterController> {
  ///用户中心 会员信息
  const UserCenterMemberWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1680.wMin / 3 - 20.wMin,
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cBgSecondary,
      ),
      child: Column(
        children: [
          TapScaleWidget(
            onTap: () {
              MembersInfoDialog.show(context: context);
            },
            sclae: 1,
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  Text(
                    "我的会员信息",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Obx((){
                    String vipType = "";
                    List<UserInfoEntityVipList?> vipList = controller.userStore.userInfo.value.vipList??[];
                    if(vipList.isEmpty) return Container();

                    /// 根据第一条数据的过期时间 去重vipList
                    String? firstEndTime = vipList[0]?.end;
                    if (firstEndTime != null) {
                      // 保留第一条数据，移除其他具有相同过期时间的数据
                      List<UserInfoEntityVipList?> uniqueList = [vipList[0]];
                      for (int i = 1; i < vipList.length; i++) {
                        if (vipList[i]?.end != firstEndTime) {
                          uniqueList.add(vipList[i]);
                        }
                      }
                      vipList = uniqueList;
                    }

                    for(int i = 0; i < vipList.length; i++){
                      if(vipList[i]?.type == null || (vipList[i]?.type?.isEmpty??true)) continue;
                      vipType += vipList[i]?.type??"";
                      if(i != vipList.length - 1){
                        vipType += "、";
                      }
                    }

                    return Text(
                      vipType,
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextSecondary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  }),
                  SvgPicture.asset(
                    "assets/svg/user_center/icon_chevron_right1.svg",
                    width: 32.wMin,
                    height: 32.wMin,
                  ),
                ],  
              ),
            ),
          ),
          SizedBox(height: 12.wMin),
          // Obx((){
          //   return MemberCardWidget(
          //     member: controller.userStore.userInfo.value.vipType, 
          //     vipEnd: controller.userStore.userInfo.value.vipEnd,
          //     studentNumber: controller.userStore.userInfo.value.studentCount??0,
          //     vipConfigs: controller.userStore.userInfo.value.vipConfigs,
          //   );
          // }),
          _buildMemberInfoWidget(),
          SizedBox(height: 16.wMin),
          ButtonWidget(
            text: "升级会员",
            borderRadius: 12.wMin,
            color: AppTheme.cSurfaceBrand,
            height: 64.wMin,
            fontColor: AppTheme.cStaticWhite,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.02,
            onTap: (){
              controller.toMemberCenter();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemberInfoWidget(){
    return Obx((){
      List<UserInfoEntityVipList?> vipList = controller.userStore.userInfo.value.vipList??[];
      vipList.removeWhere((element) => element == null);

      if(vipList.isEmpty) return Expanded(child: Container());

      /// 根据第一条数据的过期时间 去重vipList
      String? firstEndTime = vipList[0]?.end;
      if (firstEndTime != null) {
        // 保留第一条数据，移除其他具有相同过期时间的数据
        List<UserInfoEntityVipList?> uniqueList = [vipList[0]];
        for (int i = 1; i < vipList.length; i++) {
          if (vipList[i]?.end != firstEndTime) {
            uniqueList.add(vipList[i]);
          }
        }
        vipList = uniqueList;
      }

      return Expanded(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            if(vipList.length > 2) Positioned(
              bottom: 0,
              left: 0,
              child: _buildOtherMemberInfoWidget(vipList[2]),
            ),
            if(vipList.length > 1) Positioned(
              bottom: vipList.length == 2 ? 0 : 46.wMin,
              left: 0,
              child: _buildOtherMemberInfoWidget(vipList[1]),
            ),
            if(vipList.isNotEmpty) _buildMemberInfoItemWidget(vipList[0], vipList),
          ],
        ),
      );
    });
  }

  Widget _buildMemberInfoItemWidget(UserInfoEntityVipList? data, List<UserInfoEntityVipList?> vipList){
    MemberLevelColor memberColors = StatusUtils.getMemberColorsByVipConfigs(controller.userStore.userInfo.value.vipConfigs, data?.type);
    
    String vipEnd = DateFormatUtil.formatStrtoStr(data?.end);

    double height = double.infinity;
    if(vipList.length == 2){
      height = 190.wMin;
    }else if(vipList.length == 3){
      height = 148.wMin;
    }
    
    return Container(
      width: 490.wMin,
      height: height,
      padding: EdgeInsets.only(left: 18.wMin, right: 18.wMin, bottom: 10.wMin, top: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            memberColors.pale,
            memberColors.deep,  
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10.wMin,
            right: 16.wMin,
            child: SvgPicture.asset(
              "assets/svg/user_center/card_bg_crown.svg",
              width: 110.wMin,
              colorFilter: ColorFilter.mode(memberColors.pale, BlendMode.srcIn),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data?.type??"",
                style: TextStyle(
                  fontSize: 54.wMin,
                  color: AppTheme.cStaticWhite.color,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              SizedBox(height: 4.wMin),
              Text(
                data?.describe??"",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cStaticWhite.color,
                  fontWeight: FontWeight.w500,
                  height: 0.8,
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Visibility(
                  visible: vipEnd.isNotEmpty,
                  child: Text(
                    "到期时间：$vipEnd",
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: AppTheme.cStaticWhite.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Visibility(
                  visible: data?.day != null,
                  child: Text(
                    "剩余天数：${data?.day??0} 天",
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: AppTheme.cStaticWhite.color,
                      fontWeight: FontWeight.w500,
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


  Widget _buildOtherMemberInfoWidget(UserInfoEntityVipList? data){
    MemberLevelColor memberColors = StatusUtils.getMemberColorsByVipConfigs(controller.userStore.userInfo.value.vipConfigs, data?.type);
    
    String vipEnd = DateFormatUtil.formatStrtoStr(data?.end);
    

    return Container(
      width: 490.wMin,
      height: 148.wMin,
      padding: EdgeInsets.only(left: 18.wMin, right: 18.wMin, bottom: 10.wMin, top: 6.wMin),
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            memberColors.pale,
            memberColors.deep,  
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            data?.type??"",
            style: TextStyle(
              fontSize: 36.wMin,
              color: AppTheme.cStaticWhite.color,
              fontWeight: FontWeight.w600,
              height: 0.8,
            ),
          ),
          Text(
            "到期时间：$vipEnd",
            style: TextStyle(
              fontSize: 14.wMin,
              color: AppTheme.cStaticWhite.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      )
    );
  }

}