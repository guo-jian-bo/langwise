import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/membership_card_manage/membership_card_manage_rebate_statistics/controllers/membership_card_manage_rebate_statistics_controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import '../controllers/membership_card_manage_controller.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../membership_card_manage_code_manage/views/membership_card_manage_code_manage_view.dart';
import '../membership_card_manage_generate_code/views/membership_card_manage_generate_code_view.dart';
import '../membership_card_manage_rebate_statistics/views/membership_card_manage_rebate_statistics_view.dart';
import '../membership_card_manage_recharge_center/views/membership_card_manage_recharge_center_view.dart';

class MembershipCardManageView extends GetView<MembershipCardManageController> {
  const MembershipCardManageView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.cBgPrimary.color,
        body: Container(
          // padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 20.wMin),
          padding: EdgeInsets.only(
            top: 20.wMin,
            left: 40.wMin + MediaQuery.of(context).padding.left,
            right: 40.wMin + MediaQuery.of(context).padding.right,
          ),
          child: Column(
            children: [
              headWidget(),
              Expanded(
                child: Obx(
                  () => contentWidget(),
                ),
              ),
              SizedBox(height: 20.wMin),
            ],
          ),
        ),
      ),
    );
  }

  Widget contentWidget() {
    if (controller.currentIndex.value == 0) {
      return const MembershipCardManageGenerateCodeView();
    } else if (controller.currentIndex.value == 1) {
      return const MembershipCardManageCodeManageView();
    } else if (controller.currentIndex.value == 2) {
      return const MembershipCardManageRechargeCenterView();
    } else if (controller.currentIndex.value == 3) {
      return const MembershipCardManageRebateStatisticsView();
    }
    return Container();
  }

  Widget headWidget() {
    return Column(
      children: [
        SizedBox(height: 10.wMin),
        TapScaleWidget(
          sclae: 1,
          onTap: () {
            Get.back();
          },
          child: Row(
            children: [
              const BackWidget(),
              Text(
                '会员卡管理',
                style: TextStyle(
                  fontSize: 22.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Obx(
                () => Row(
                  children: [
                    Text(
                      '代理商：${controller.model.value.agentName ?? ''} (ID: ${controller.model.value.agentNo ?? ''})',
                      style: TextStyle(
                        fontSize: 22.wMin,
                        color: AppTheme.cTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (controller.model.value.isAdmin == true) ...[
                      SizedBox(width: 16.wMin),
                      ManageButton(
                        text: "查看数据看板",
                        width: 140.wMin,
                        height: 42.wMin,
                        color: AppTheme.cBgTertiary,
                        borderColor: AppTheme.cBorderSecondary,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                        onTap: () {
                          Get.toNamed(Routes.MEMBERSHIP_CARD_MANAGE_AGENT_DASHBOARD);
                        },
                      ),
                    ],
                  ],
                ),
              ),
         
            ],
          ),
        ),
        SizedBox(height: 20.wMin),
        // Obx(
        //   () => Row(
        //     children: [
        //       headCardWidget(
        //           "可用余额",
        //           controller.model.value.priceStr ?? "0.00",
        //           "元",
        //           "assets/svg/membership_card/membership_card_balance.svg",
        //           const Color(0xFF0EA5E9)),
        //       const Spacer(),
        //       headCardWidget(
        //           "累计充值",
        //           controller.model.value.topUpPriceStr?.toString() ?? "0.00",
        //           "元",
        //           "assets/svg/membership_card/membership_card_recharge.svg",
        //           const Color(0xFF00BC7D)),
        //       const Spacer(),
        //       headCardWidget(
        //           "体验卡",
        //           controller.model.value.sendCouponNum?.toString() ?? "0",
        //           "张",
        //           "assets/svg/membership_card/membership_card_balance.svg",
        //           const Color(0xFF0EA5E9)),
        //       const Spacer(),
        //       headCardWidget(
        //           "生成卡数",
        //           controller.model.value.totalGeneratedCards?.toString() ?? "0",
        //           "张",
        //           "assets/svg/membership_card/membership_card_generate_num.svg",
        //           const Color(0xFFC026D3)),
        //       const Spacer(),
        //       headCardWidget(
        //           "激活卡数",
        //           controller.model.value.totalActivatedCards?.toString() ?? "0",
        //           "张",
        //           "assets/svg/membership_card/membership_card_activation_num.svg",
        //           const Color(0xFFFB923C)),
        //     ],
        //   ),
        // ),
        // SizedBox(height: 20.wMin),
        Container(
          width: double.infinity,
          height: 70.wMin,
          decoration: BoxDecoration(
            color: AppTheme.cBgTertiary,
            borderRadius: BorderRadius.circular(12.wMin),
          ),
          child: Obx(
            () => Row(
              children: [
                SizedBox(width: 20.wMin),
                ManageButton(
                  text: "生成卡密",
                  width: 120.wMin,
                  height: 50.wMin,
                  color: controller.currentIndex.value == 0 ? AppTheme.cTextPrimary : AppTheme.cBgTertiary,
                  borderColor: controller.currentIndex.value == 0 ? Colors.transparent : AppTheme.cBorderSecondary,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: controller.currentIndex.value == 0 ? AppTheme.cBgSecondary : AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                  onTap: () {
                    controller.currentIndex.value = 0;
                  },
                ),
                SizedBox(width: 20.wMin),
                ManageButton(
                  text: "卡密管理",
                  width: 120.wMin,
                  height: 50.wMin,
                  color: controller.currentIndex.value == 1 ? AppTheme.cTextPrimary : AppTheme.cBgTertiary,
                  borderColor: controller.currentIndex.value == 1 ? Colors.transparent : AppTheme.cBorderSecondary,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: controller.currentIndex.value == 1 ? AppTheme.cBgSecondary : AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                  onTap: () {
                    controller.currentIndex.value = 1;
                  },
                ),
                SizedBox(width: 20.wMin),
                ManageButton(
                  text: "充值中心",
                  width: 120.wMin,
                  height: 50.wMin,
                  color: controller.currentIndex.value == 2 ? AppTheme.cTextPrimary : AppTheme.cBgTertiary,
                  borderColor: controller.currentIndex.value == 2 ? Colors.transparent : AppTheme.cBorderSecondary,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: controller.currentIndex.value == 2 ? AppTheme.cBgSecondary : AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                  onTap: () {
                    controller.currentIndex.value = 2;
                  },
                ),
                SizedBox(width: 20.wMin),
                ManageButton(
                  text: "统计返点",
                  width: 120.wMin,
                  height: 50.wMin,
                  color: controller.currentIndex.value == 3 ? AppTheme.cTextPrimary : AppTheme.cBgTertiary,
                  borderColor: controller.currentIndex.value == 3 ? Colors.transparent : AppTheme.cBorderSecondary,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: controller.currentIndex.value == 3 ? AppTheme.cBgSecondary : AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                  onTap: () {
                    controller.currentIndex.value = 3;
                    if (Get.isRegistered<MembershipCardManageRebateStatisticsController>()) {
                      Get.find<MembershipCardManageRebateStatisticsController>().initData();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20.wMin),
      ],
    );
  }

  Widget headCardWidget(String title, String content, String unit, String imageStr, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cBgQuaternary,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Padding(
        padding: EdgeInsets.all(15.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 200.wMin),
                CircleAvatar(
                  radius: 22.wMin,
                  backgroundColor: color,
                  child: SvgPicture.asset(
                    imageStr,
                    width: 26.wMin,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 32.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' $unit',
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
