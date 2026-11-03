import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../controllers/personal_data_controller.dart';

class PersonalDataView extends GetView<PersonalDataController> {
  const PersonalDataView({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Container(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 1680.wMin,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 40.wMin,
              bottom: MediaQuery.of(context).padding.bottom + 20.wMin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BackWidget(title: "个人资料"),
                    TapScaleWidget(
                      onTap: () {
                        controller.toAboutUs();
                      },
                      sclae: 1.1,
                      child: Container(
                        padding: EdgeInsets.all(10.wMin),
                        color: Colors.transparent,
                        child: SvgPicture.asset(
                          "assets/svg/user_center/icon_info.svg",
                          width: 32.wMin,
                          height: 32.wMin,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.wMin),
                IntrinsicHeight(
                  child: Row(
                    spacing: 20.wMin,
                    children: [
                      _buildBasicInformationWidget(context),
                      _buildMemberInformation(),
                    ],
                  ),
                ),
                SizedBox(height: 24.wMin),
                
                Obx((){
                  if(controller.userStore.userInfo.value.review == 0){
                    return Row(
                      spacing: 20.wMin,
                      children: [
                        _buildCardCoupons(),
                        _buildLearnSomethingWidget(context),
                        _buildNsCoinWidget(context),
                      ],
                    );
                  }
                  return Row(
                    spacing: 20.wMin,
                    children: [
                      _buildLearnSomethingWidget(context),
                      _buildNsCoinWidget(context),
                    ],
                  );
                }),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 乃币
  Widget _buildNsCoinWidget(BuildContext context){
    return Expanded(
      child: Obx((){

        int credit = controller.userStore.userInfo.value.credit??0;
        String creditStr = NumberUtils.formatNumberWithCommas(credit / 100);
        // int totalCredits = controller.userStore.userInfo.value.totalCredits??0;
        // String totalCreditsStr = NumberUtils.formatNumberWithCommas(totalCredits / 100);
        // int useCredits = totalCredits - credit;
        // String useCreditsStr = NumberUtils.formatNumberWithCommas(useCredits / 100);

        return UserAssetsInfoCardWidget(
          infoData: UserAssetsInfoModel(
            title: "乃币", 
            type: 2, 
            balance: creditStr,
            balanceDesc: "可用乃币", 
            // counts: [
            //   UserAssetsInfoCertificateModel(name: "已使用", value: useCreditsStr),
            //   UserAssetsInfoCertificateModel(name: "总获得", value: totalCreditsStr),
            // ],
          ),
          child: Container(),
          buttons: ButtonWidget(
            text: "充值乃币",
            height: 64.wMin,
            borderRadius: 12.wMin,
            color: AppTheme.cBorderDisabled,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            fontColor: AppTheme.cNsCoinBgPrimary,
            sclae: 1.03,
          ),
          onTap: () {
            controller.toRechargeNaibi(context);
          },
        );
      }),
    );
  }

  /// 学点
  Widget _buildLearnSomethingWidget(BuildContext context){
    return Expanded(
      child: Obx((){
        int points = controller.userStore.userInfo.value.points??0;
        String pointsStr = NumberUtils.formatNumberWithCommas(points.toDouble());
        // int totalPoints = controller.userStore.userInfo.value.totalPoints??0;
        // String totalPointsStr = NumberUtils.formatNumberWithCommas(totalPoints.toDouble());
        // int usePoints = totalPoints - points;
        // String usePointsStr = NumberUtils.formatNumberWithCommas(usePoints.toDouble());

        return UserAssetsInfoCardWidget(
          infoData: UserAssetsInfoModel(
            title: "学点", 
            type: 1, 
            balance: pointsStr, 
            balanceDesc: "可用学点", 
            // counts: [
            //   UserAssetsInfoCertificateModel(name: "已使用", value: usePointsStr),
            //   UserAssetsInfoCertificateModel(name: "总获得", value: totalPointsStr),
            // ],
          ),
          child: Container(),
          buttons: Row(
            spacing: 12.wMin,
            children: [
              Expanded(
                child: ButtonWidget(
                  text: "查看明细",
                  height: 64.wMin,
                  borderRadius: 12.wMin,
                  color: AppTheme.cBorderDisabled,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  fontColor: AppTheme.cTextBrand,
                  sclae: 1.03,
                ),
              ),
              Expanded(
                child: ButtonWidget(
                  text: "充值学点",
                  height: 64.wMin,
                  borderRadius: 12.wMin,
                  color: AppTheme.cBorderDisabled,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  fontColor: AppTheme.cLearnSomethingPrimary,
                  sclae: 1.03,
                  onTap: () {
                    controller.toLearningPointPayment(context);
                  },
                ),
              ),
            ],
          ),
          onTap: () {
            controller.toLearningPointDetails();
          },
        );
      }),
    );
  }


  /// 卡券
  Widget _buildCardCoupons(){
    
    return Expanded(
      child: Obx((){
        List<CouponTabEntity> cardCouponsList = controller.cardCouponsList.toList();
        if(cardCouponsList.isEmpty) return Container();
        // List<CouponTabEntity> others = cardCouponsList.sublist(1);

        return UserAssetsInfoCardWidget(
          infoData: UserAssetsInfoModel(
            title: "卡券", 
            type: 0, 
            balance: controller.userStore.userInfo.value.coupon?.toString()??"0", 
            balanceDesc: "可用卡券总数", 
            // counts: List.generate(others.length, (index){
            //   return UserAssetsInfoCertificateModel(
            //     name: others[index].title??"", 
            //     value: others[index].count?.toString()??"0",
            //   );
            // }),
          ),
          child: Container(),
          buttons: ButtonWidget(
            text: "查看卡券",
            height: 64.wMin,
            borderRadius: 12.wMin,
            color: AppTheme.cBorderDisabled,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            fontColor: AppTheme.cCardCouponsPrimary,
            sclae: 1.03,
          ),
          onTap: () {
            controller.toMyCoupons();
          },
        );
      }),
    );
  }

  /// 会员信息
  Widget _buildMemberInformation(){

    return TapScaleWidget(
      onTap: () {
        controller.toMemberCenter();
      },
      sclae: 1.015,
      child: Container(
        width: 1680.wMin / 3 - 20.wMin,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cBgSecondary,
        ),
        child: Column(
          children: [
            UserArrowTiele(
              title: "会员信息",
              fontSize: 28.wMin,
              fontWeight: FontWeight.w600,
              iconSize: 32.wMin,
            ),
            SizedBox(height: 16.wMin),
            Obx((){
              return MemberCardWidget(
                member: controller.userStore.userInfo.value.vipType, 
                vipEnd: controller.userStore.userInfo.value.vipEnd,
                studentNumber: controller.userStore.userInfo.value.studentCount??0,
                vipConfigs: controller.userStore.userInfo.value.vipConfigs,
              );
            }),
            const Spacer(),
            ButtonWidget(
              text: "升级会员",
              borderRadius: 12.wMin,
              color: AppTheme.cSurfaceBrand,
              padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
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
      ),
    );
  }

  /// 基本信息
  Widget _buildBasicInformationWidget(BuildContext context){
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
                    "基本信息",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),
                  
                  TapScaleWidget(
                    onTap: (){
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
                            colorFilter: const ColorFilter.mode(AppTheme.cTextPrimary, BlendMode.srcIn),
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

                  SizedBox(width: 40.wMin),

                  TapScaleWidget(
                    onTap: (){
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
                          Obx((){
                            bool hasPassword = controller.userStore.userInfo.value.hasPassword == 1;
                            return Text(
                              hasPassword ? "重置密码" : "设置密码",
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
                  Obx((){
                    return ClipOval(
                      child: Container(
                        width: 160.wMin,
                        height: 160.wMin,
                        color: AppTheme.cBlackAlpha10,
                        child: CachedImageWidget(
                          controller.userStore.userInfo.value.avatarUrl??"",
                          errorWidget: Center(
                            child: SvgPicture.asset(
                              "assets/svg/user_center/icon_head.svg",
                              height: 80.wMin,
                            ),
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
                            Obx((){
                              return Text(
                                controller.userStore.userInfo.value.nickname??"",
                                style: TextStyle(
                                  fontSize: 28.wMin,
                                  color: AppTheme.cTextPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.wMin),
                                color: AppTheme.cFeedbackInfoBackground,
                              ),
                              child: Obx((){
                                return Text(
                                  "ID: ${controller.userStore.userInfo.value.userId??""}",
                                  style: TextStyle(
                                    fontSize: 20.wMin,
                                    color: AppTheme.cTextBrand,
                                    fontWeight: FontWeight.w400,
                                  ),
                                );
                              }),
                            ),

                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Obx((){
                                  List<UserInfoEntityUserBadges?> list = controller.userStore.userInfo.value.userBadges??[];
                                  if(list.isEmpty) return const SizedBox();
                                  return Row(
                                    children: List.generate(list.length, (index){
                                      return CachedImageWidget(
                                        list[index]?.badgeUrl??"",
                                        width: 24.wMin,
                                        height: 24.wMin,
                                        errorWidget: Container(),
                                      );
                                    }),
                                  );
                                }),
                              ),
                            )

                          ],
                        ),
                        SizedBox(height: 30.wMin),
                        Obx((){
                          return Column(
                            spacing: 10.wMin,
                            children: [
                              Row(
                                spacing: 10.wMin,
                                children: [
                                  _buildBasicInformationRowTextWidget("手机号码：", controller.userStore.userInfo.value.phone??""),
                                  // _buildBasicInformationRowTextWidget("电子邮箱：", "xxxxxxxxxxxxxx@xxxx.com"),
                                ],
                              ),
                              Row(
                                spacing: 10.wMin,
                                children: [
                                  _buildBasicInformationRowTextWidget(
                                    "加入时间：", DateFormatUtil.formatStrtoStr(controller.userStore.userInfo.value.created??""),
                                  ),
                                  _buildBasicInformationRowTextWidget(
                                    "最近登录：", DateFormatUtil.formatStrtoStr(controller.userStore.userInfo.value.lastLoginTime??""),
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
              child: TapScaleWidget(
                onTap: (){
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
                        colorFilter: const ColorFilter.mode(AppTheme.cTextPrimary, BlendMode.srcIn),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInformationRowTextWidget(String name,  String? value){
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
              value??"",
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


