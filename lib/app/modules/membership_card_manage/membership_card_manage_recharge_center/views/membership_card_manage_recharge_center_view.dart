import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import '../../controllers/membership_card_manage_controller.dart';
import '../controllers/membership_card_manage_recharge_center_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../models/membership_card_manage_recharge_center_model.dart';

class MembershipCardManageRechargeCenterView extends GetView<MembershipCardManageRechargeCenterController> {
  const MembershipCardManageRechargeCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => MembershipCardManageRechargeCenterController());
    MembershipCardManageController membershipCardManageController = Get.find<MembershipCardManageController>();

    return SingleChildScrollView(
      controller: controller.scrollController,
      child: Obx(
        () => Column(
          children: [
            Row(
              children: [
                headCardWidget(
                    "可用余额", membershipCardManageController.model.value.priceStr ?? "0.00", "元", "assets/svg/membership_card/membership_card_balance.svg", const Color(0xFF0EA5E9)),
                const Spacer(),
                headCardWidget("累计充值", membershipCardManageController.model.value.topUpPriceStr?.toString() ?? "0.00", "元",
                    "assets/svg/membership_card/membership_card_recharge.svg", const Color(0xFF00BC7D),
                    isShowButton: true),
                const Spacer(),
                headCardWidget("体验卡", membershipCardManageController.model.value.sendCouponNum?.toString() ?? "0", "张", "assets/svg/membership_card/membership_card_balance.svg",
                    const Color(0xFF0EA5E9)),
                const Spacer(),
                headCardWidget("生成卡数", membershipCardManageController.model.value.totalGeneratedCards?.toString() ?? "0", "张",
                    "assets/svg/membership_card/membership_card_generate_num.svg", const Color(0xFFC026D3)),
                const Spacer(),
                headCardWidget("激活卡数", membershipCardManageController.model.value.totalActivatedCards?.toString() ?? "0", "张",
                    "assets/svg/membership_card/membership_card_activation_num.svg", const Color(0xFFFB923C)),
              ],
            ),
            SizedBox(height: 20.wMin),
            GridView.builder(
              key: const PageStorageKey('recharge_scroll_grid'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 400.wMin,
                crossAxisSpacing: 20.wMin,
                mainAxisSpacing: 20.wMin,
              ),
              itemCount: controller.rechargeCenterEntity.value.list?.length ?? 0,
              itemBuilder: (context, index) {
                return cardWidget(controller.rechargeCenterEntity.value.list?[index], index, context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget headCardWidget(String title, String content, String unit, String imageStr, Color color, {bool isShowButton = false}) {
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
                Container(
                  height: 40.wMin,
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isShowButton) SizedBox(width: 140.wMin),
                if (!isShowButton) SizedBox(width: 240.wMin),
                if (isShowButton)
                  SizedBox(
                    width: 160.wMin,
                    child: TapScaleWidget(
                      onTap: () {
                        Get.toNamed(Routes.MEMBERSHIP_CARD_MANAGE_RECHARGE_RECORD);
                      },
                      sclae: 1.03,
                      child: Container(
                        alignment: Alignment.center,
                        height: 40.wMin,
                        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.wMin),
                          color: AppTheme.cBgTertiary,
                        ),
                        child: Text(
                          '查看充值记录',
                          style: TextStyle(
                            fontSize: 20.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
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

  Widget cardWidget(MembershipCardManageRechargeCenterModel? model, int index, context) {
    return Container(
      padding: EdgeInsets.all(30.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgQuaternary,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '¥ ${model?.minAmount ?? 0}',
            style: TextStyle(
              fontSize: 56.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.wMin),
          Text(
            model?.description ?? '',
            style: TextStyle(
              fontSize: 32.wMin,
              color: AppTheme.cFeedbackSuccessText,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 20.wMin),
          Text(
            '实际获得：${(model?.minAmount ?? 0) + (model?.bonusRate ?? 0)}元',
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 20.wMin),
          Visibility(
            visible: model?.isSendCoupon ?? false,
            child: Text(
              model?.sendCouponDescription ?? '',
              style: TextStyle(
                fontSize: 28.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              controller.recharge(model);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.wMin),
              decoration: BoxDecoration(
                color: AppTheme.cBgBrand,
                borderRadius: BorderRadius.circular(10.wMin),
              ),
              child: Center(
                child: Text(
                  '立即充值',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
