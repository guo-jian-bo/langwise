import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../stores/stores.dart';

class ConfirmOrderWidgetManager {
  static show(
    final PackageShopDetailEntity packageShopDetailEntity,
    final VoidCallback? onCancel,
    final VoidCallback? onOk,
    final VoidCallback? onRecharge,
  ) {
    return Get.dialog(ConfirmOrderWidget(
      packageShopDetailEntity: packageShopDetailEntity,
      onCancel: onCancel,
      onOk: onOk,
      onRecharge: onRecharge,
    ));
  }

  static Future<void> showC({
    required BuildContext context,
    required PackageShopDetailEntity packageShopDetailEntity,
    String? title,
    VoidCallback? onCancel,
    VoidCallback? onOk,
    VoidCallback? onRecharge,
  }) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ConfirmOrderWidget(
          packageShopDetailEntity: packageShopDetailEntity,
          title: title,
          onCancel: onCancel,
          onOk: onOk,
          onRecharge: onRecharge,
        );
      },
    );
  }
}

class ConfirmOrderWidget extends StatelessWidget {
  final PackageShopDetailEntity packageShopDetailEntity;
  final VoidCallback? onCancel;
  final VoidCallback? onOk;
  final VoidCallback? onRecharge;
  final String? title;

  const ConfirmOrderWidget({
    super.key,
    required this.packageShopDetailEntity,
    this.title = '确认解锁「自建课程」',
    this.onCancel,
    this.onOk,
    this.onRecharge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Container(
          width: 680.wMin,
          height: 840.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            color: AppTheme.cBgSecondary,
          ),
          child: Column(
            children: [
              Gaps.getHeight(32.wMin),
              Text(
                title??'',
                style: TextStyle(
                  fontSize: 36.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gaps.getHeight(48.wMin),
              Padding(
                padding: EdgeInsets.only(left: 84.wMin, right: 84.wMin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceWidget(
                      type: 1,
                      title: "学点余额",
                      money: packageShopDetailEntity.realUserPoints,
                    ),
                    _buildBalanceWidget(
                      type: 2,
                      title: "乃币余额",
                      money: packageShopDetailEntity.realUserCredit,
                    ),
                  ],
                ),
              ),
              Gaps.getHeight(16.wMin),
              _buildInfoWidget(),
              _buildPayMethodWidget(),
              const Spacer(),
              Expanded(child: _buildBottomWidget()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceWidget({
    required int type,
    required String title,
    required String money,
  }) {
    return Expanded(
      child: Column(
        children: [
          UserBalanceIcon(
            type: type,
            boxSize: 64.wMin,
            iconSize: 40.wMin,
            bgColorOption: 1,
            iconColor: AppTheme.cStaticWhite.color,
          ),
          Gaps.getHeight(16.wMin),
          Text(
            money,
            style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextPrimary, fontWeight: FontWeight.w500, height: 1.0),
          ),
          Gaps.getHeight(10.wMin),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          ),
          Visibility(
            visible: type == 1,
            child: Container(
              margin: EdgeInsets.only(top: 6.wMin),
              child: Text(
                "每月赠送 ${UserStore.to.userInfo.value.vipPointsStr} 学点",
                style: TextStyle(
                  fontSize: 22.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cLearnSomethingPrimary.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoWidget() {
    return Container(
      decoration: const BoxDecoration(
          // borderRadius: BorderRadius.circular(12.wMin),
          // color: AppTheme.cBgTertiary,
          color: Colors.transparent),
      margin: EdgeInsets.only(left: 84.wMin, right: 84.wMin),
      padding: EdgeInsets.only(top: 24.wMin),
      child: Column(
        children: [
          _buildItemWidget(title: "商品/服务", info: packageShopDetailEntity.servicePackage?.title ?? ''),
          Gaps.getHeight(16.wMin),
          _buildItemWidget(title: "数量", info: '1个'),
          Gaps.getHeight(16.wMin),
          _buildItemWidget(title: "单价", info: "${packageShopDetailEntity.servicePackage?.realPrice ?? '0'}点"),
          Gaps.getHeight(8.wMin),
          Divider(
            color: AppTheme.cBorderPrimary,
            height: 1.wMin,
          ),
          Gaps.getHeight(8.wMin),
        ],
      ),
    );
  }

  Widget _buildItemWidget({
    required String title,
    required info,
    TextStyle? titleTextStyle,
    TextStyle? infoTextStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: titleTextStyle ?? TextStyle(fontSize: 24.wMin, color: AppTheme.cTextSecondary, fontWeight: FontWeight.w500, height: 1.0),
        ),
        Flexible(
            child: Text(
          info,
          style: infoTextStyle ?? TextStyle(overflow: TextOverflow.ellipsis, fontSize: 20.wMin, color: AppTheme.cTextPrimary, fontWeight: FontWeight.w500, height: 1.0),
        )),
      ],
    );
  }

  Widget _buildPayMethodWidget() {
    final bool isAffordable = packageShopDetailEntity.isAffordable;
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent
          // borderRadius: BorderRadius.only(topLeft: Radius.circular(12.wMin), topRight: Radius.circular(12.wMin)),
          // color: AppTheme.cBgTertiary,
          ),
      margin: EdgeInsets.only(left: 84.wMin, right: 84.wMin),
      padding: EdgeInsets.only(top: 24.wMin, bottom: 8.wMin),
      child: Column(
        children: [
          _buildItemWidget(title: "支付方式", info: ""),
          Gaps.getHeight(16.wMin),
          _buildItemWidget(
            title: "学点支付",
            info: "${packageShopDetailEntity.realOrderPoints}点",
            titleTextStyle: TextStyle(fontSize: 24.wMin, color: AppTheme.cUserMaxMember1, fontWeight: FontWeight.w500, height: 1.0),
          ),
          Gaps.getHeight(16.wMin),
          _buildItemWidget(
              title: "乃币支付",
              info: "${packageShopDetailEntity.realOrderCredit}乃币",
              titleTextStyle: TextStyle(
                fontSize: 24.wMin,
                color: isAffordable ? AppTheme.cUserPlusMember1 : AppTheme.cFeedbackErrorText,
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
              infoTextStyle: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 20.wMin,
                  color: isAffordable ? AppTheme.cTextPrimary : AppTheme.cFeedbackErrorText,
                  fontWeight: FontWeight.w500,
                  height: 1.0)),
          if (!isAffordable) Gaps.getHeight(16.wMin),
          if (!isAffordable)
            _buildItemWidget(
              title: "",
              info: "乃币余额不足",
              infoTextStyle: TextStyle(fontSize: 24.wMin, color: AppTheme.cFeedbackErrorText, fontWeight: FontWeight.w500, height: 1.0),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomWidget() {
    final bool isAffordable = packageShopDetailEntity.isAffordable;

    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      padding: EdgeInsets.only(top: 28.wMin),
      margin: EdgeInsets.only(left: 84.wMin, right: 84.wMin),
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: ManageButton(
            text: "取消",
            height: 64.wMin,
            radius: 12.wMin,
            borderColor: Colors.transparent,
            color: AppTheme.cBgHover,
            style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextTertiary, fontWeight: FontWeight.w500, height: 1.0),
            onTap: OptimizeUtils.noneThrottle(() {
              Get.back();
              onCancel?.call();
            }, 300),
          )),
          Gaps.getWidth(24.wMin),
          Expanded(
              child: ManageButton(
            text: isAffordable ? "确认支付" : "立即充值",
            height: 64.wMin,
            radius: 12.wMin,
            color: isAffordable ? AppTheme.cBgBrand : AppTheme.cFeedbackWarningBorder.color,
            borderColor: Colors.transparent,
            style: TextStyle(fontSize: 24.wMin, color: AppTheme.cStaticWhite, fontWeight: FontWeight.w500, height: 1.0),
            onTap: OptimizeUtils.noneThrottle(() {
              Get.back();
              if (isAffordable) {
                onOk?.call();
              } else {
                onRecharge?.call();
              }
            }, 1000),
          )),
        ],
      ),
    );
  }
}
