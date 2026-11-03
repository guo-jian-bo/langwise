import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:langwise/common/widgets/guide_engine/guide_anchor.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../routes/routes.dart';
import '../../common/coupons_widget.dart';
import '../bindings/my_coupons_binding.dart';
import '../controllers/my_coupons_controller.dart';

class MyCouponsView extends GetView<MyCouponsController> {
  final String tagText;
  const MyCouponsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      MyCouponsView(tagText: tag),
      binding: MyCouponsBinding(tagText: tag),
      routeName: Routes.MY_COUPONS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.cBgPrimary,
      body: Container(
        alignment: Alignment.center,
        child: Container(
          width: 1680.wMin,
          margin: EdgeInsets.only(
            top: 40.wMin + MediaQuery.of(context).padding.top,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BackWidget(title: "我的优惠券"),
                  SizedBox(height: 18.wMin),
                  _buildLimitedTimeOfferWidget(),
                  SizedBox(height: 40.wMin - 16.wMin),
                  Obx(() {
                    return Row(
                      spacing: 8.wMin,
                      children: List.generate(controller.tabbarList.length, (index) {
                        return _buildTabbarItemWidget(controller.tabbarList[index], index);
                      }),
                    );
                  }),
                ],
              ),
              SizedBox(height: 11.wMin),
              Expanded(
                child: _buildCouponsList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCouponsList(BuildContext context) {
    return Obx(() {
      return GridView.builder(
        controller: controller.scrollController,
        itemCount: controller.couponList.length + 1,
        padding: EdgeInsets.only(
          top: 10.wMin,
          bottom: 10.wMin + MediaQuery.of(context).padding.bottom,
          left: 10.wMin,
          right: 10.wMin,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 32.wMin,
          crossAxisSpacing: 32.wMin,
          childAspectRatio: 480 / 280,
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddCouponsWidget(context);
          }
          return CardsCouponsWidget(
            data: controller.couponList[index - 1],
            onTap: () {
              controller.activationCoupon(context, controller.couponList[index - 1]);
            },
            onTransfer: (CouponEntityDatas data) {
              controller.transferCoupons(context, data);
            },
          );
        },
      );
    });
  }

  Widget _buildAddCouponsWidget(BuildContext context) {
    return GuideAnchor(
        id: 'check_coupons',
        route: Routes.MY_COUPONS,
        child: TapScaleWidget(
          onTap: () {
            controller.exchangeCoupons(context);
          },
          sclae: 1.01,
          child: DottedBorder(
            borderType: BorderType.RRect,
            padding: EdgeInsets.zero,
            color: AppTheme.cTextDisabled,
            radius: Radius.circular(12.wMin),
            strokeWidth: 1.wMin,
            dashPattern: [6.wMin, 6.wMin],
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                color: AppTheme.cBgSecondary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/svg/user_center/icon_add_circle.svg",
                    width: 48.wMin,
                    height: 48.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cFeedbackInfoIcon.color, BlendMode.srcIn),
                  ),
                  SizedBox(height: 16.wMin),
                  Text(
                    "兑换卡券",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "使用兑换码获取新卡券",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cTextSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildTabbarItemWidget(CouponTabEntity data, int index) {
    return Obx(() {
      bool selected = controller.tabbarIndex.value == index;
      return TapScaleWidget(
        onTap: () {
          controller.changeTabbarIndex(index);
        },
        sclae: 1.03,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: EdgeInsets.all(8.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: selected ? AppTheme.cBgSecondary : Colors.transparent,
          ),
          child: Row(
            children: [
              Visibility(
                visible: data.iconUrl != null,
                child: Container(
                  margin: EdgeInsets.only(right: 4.wMin),
                  child: CachedImageWidget(
                    selected ? data.iconUrl ?? "" : data.uniconUrl ?? "",
                    width: 24.wMin,
                    height: 24.wMin,
                    fadeInDuration: Duration.zero,
                    placeholder: Container(),
                    errorWidget: Container(),
                  ),
                ),
              ),
              Text(
                data.title ?? "",
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4.wMin),
              AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999.wMin),
                  color: selected ? AppTheme.cFeedbackSuccessBackground : AppTheme.cWhiteAlpha10,
                ),
                child: Text(
                  "${data.count ?? 0}张",
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLimitedTimeOfferWidget() {
    return Obx(() {
      if (controller.hotspotsActivityList.isEmpty) {
        return Container();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "限时优惠",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(vertical: 16.wMin),
            child: Row(
              spacing: 16.wMin,
              children: List.generate(controller.hotspotsActivityList.length, (index) {
                return CouponsWidget(
                  data: controller.hotspotsActivityList[index],
                  onTap: () {
                    controller.toLimitDiscountDetail(controller.hotspotsActivityList[index]);
                  },
                );
              }),
            ),
          ),
        ],
      );
    });
  }
}
