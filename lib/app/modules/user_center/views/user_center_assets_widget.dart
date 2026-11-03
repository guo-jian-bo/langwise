import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/widgets/guide_engine/guide_anchor.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../controllers/user_center_controller.dart';

class UserCenterCardCouponsWidget extends GetView<UserCenterController> {
  /// 用户中心 卡券
  const UserCenterCardCouponsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        List<CouponTabEntity> cardCouponsList = controller.cardCouponsList.toList();
        if (cardCouponsList.isEmpty) return Container();
        List<CouponTabEntity> others = cardCouponsList.sublist(1);

        return GuideAnchor(
            id: 'check_coupons_detail',
            route: Routes.USER_CENTER,
            child: TapScaleWidget(
              onTap: () {
                controller.toMyCoupons();
              },
              sclae: 1.03,
              child: UserAssetsInfoCardWidget(
                  infoData: UserAssetsInfoModel(
                    title: "卡券",
                    type: 0,
                    balance: controller.userStore.userInfo.value.coupon?.toString() ?? "0",
                    balanceDesc: "可用卡券总数",
                  ),
                  child: Row(
                    children: List.generate(others.length, (index) {
                      return UserCenterAssetsItemWidget(
                        name: others[index].title ?? "",
                        value: others[index].count?.toString() ?? "0",
                      );
                    }),
                  ),
                  buttons: Row(
                    children: [
                      Expanded(
                          child: Container(
                        height: 64.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.cSurfaceTertiary.color,
                          borderRadius: BorderRadius.circular(12.wMin),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "兑换/查看卡券",
                              style: TextStyle(
                                fontSize: 24.wMin,
                                color: AppTheme.cCardCouponsPrimary.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  )),
            ));
      }),
    );
  }
}

class UserCenterLearnPointsWidget extends GetView<UserCenterController> {
  /// 用户中心 学点
  const UserCenterLearnPointsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        int points = controller.userStore.userInfo.value.points ?? 0;
        String pointsStr = NumberUtils.formatNumberWithCommas(points.toDouble());

        String? nextTime = controller.userStore.userInfo.value.nextIssueLearnSomethingTime;
        String nextTimeStr = DateFormatUtil.formatStrtoStr(nextTime);

        return UserAssetsInfoCardWidget(
          infoData: UserAssetsInfoModel(
            title: "学点",
            type: 1,
            balance: pointsStr,
            balanceDesc: "可用学点",
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.wMin),
            child: Visibility(
              visible: nextTimeStr.isNotEmpty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "下次发放时间",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    nextTimeStr,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: AppTheme.cTextSecondary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          buttons: Row(
            spacing: 12.wMin,
            children: [
              Expanded(
                child: ButtonWidget(
                  text: "查看明细",
                  height: 64.wMin,
                  borderRadius: 12.wMin,
                  color: AppTheme.cSurfaceTertiary.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  fontColor: AppTheme.cTextBrand.color,
                  sclae: 1.03,
                ),
              ),
              Expanded(
                child: ButtonWidget(
                  text: "充值学点",
                  height: 64.wMin,
                  borderRadius: 12.wMin,
                  color: AppTheme.cSurfaceTertiary.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  fontColor: AppTheme.cLearnSomethingPrimary.color,
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
}

class UserCenterNsCoinWidget extends GetView<UserCenterController> {
  /// 用户中心 乃币
  const UserCenterNsCoinWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        int credit = controller.userStore.userInfo.value.credit ?? 0;
        String creditStr = NumberUtils.formatNumberWithCommas(credit / 100);
        int totalCredits = controller.userStore.userInfo.value.totalCredits ?? 0;
        String totalCreditsStr = NumberUtils.formatNumberWithCommas(totalCredits / 100);
        int useCredits = totalCredits - credit;
        String useCreditsStr = NumberUtils.formatNumberWithCommas(useCredits / 100);

        return UserAssetsInfoCardWidget(
          infoData: UserAssetsInfoModel(
            title: "乃币",
            type: 2,
            balance: creditStr,
            balanceDesc: "可用乃币",
          ),
          child: Row(
            children: [
              UserCenterAssetsItemWidget(
                name: "已使用",
                value: useCreditsStr,
              ),
              UserCenterAssetsItemWidget(
                name: "总获得",
                value: totalCreditsStr,
              ),
            ],
          ),
          buttons: ButtonWidget(
            text: "充值乃币",
            height: 64.wMin,
            borderRadius: 12.wMin,
            color: AppTheme.cSurfaceTertiary.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            fontColor: AppTheme.cNsCoinBgPrimary.color,
            sclae: 1.03,
          ),
          onTap: () {
            controller.toRechargeNaibi(context);
          },
        );
      }),
    );
  }
}

class UserCenterAssetsItemWidget extends StatefulWidget {
  final String? value;
  final String? name;
  const UserCenterAssetsItemWidget({super.key, this.value, this.name});

  @override
  State<UserCenterAssetsItemWidget> createState() => _UserCenterAssetsItemWidgetState();
}

class _UserCenterAssetsItemWidgetState extends State<UserCenterAssetsItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 4.wMin,
        children: [
          Text(
            widget.value ?? "",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          Text(
            widget.name ?? "",
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
