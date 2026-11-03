import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import '../../controllers/membership_card_manage_controller.dart';
import '../controllers/membership_card_manage_generate_code_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../models/membership_card_manage_generate_code_model.dart';

class MembershipCardManageGenerateCodeView extends GetView<MembershipCardManageGenerateCodeController> {
  const MembershipCardManageGenerateCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    // 确保控制器已注册
    Get.lazyPut(() => MembershipCardManageGenerateCodeController());

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cBgTertiary,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Padding(
        padding: EdgeInsets.all(15.wMin),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '选择会员等级',
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12.wMin),
                    Obx(
                      () => Row(
                        mainAxisSize: MainAxisSize.max,
                        children: List.generate(
                          controller.vipList.length,
                          (i) {
                            return headCardWidget(controller.vipList[i], i);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 12.wMin),
                    Obx(
                      () => Visibility(
                        visible: !controller.isShowCardNum.value,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '学员数量 (最少1个，最多3个)',
                              style: TextStyle(
                                fontSize: 24.wMin,
                                color: AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.wMin),
                            numberWidget(),
                            SizedBox(height: 12.wMin),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      '选择时长',
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.wMin),
                    Obx(
                      () => Wrap(
                        spacing: 20.wMin,
                        runSpacing: 20.wMin,
                        children: List.generate(
                          controller.couponSupplyList.length,
                          (i) {
                            return timeCellWidget(controller.couponSupplyList[i], i);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 12.wMin),
                    priceWidget(),
                    SizedBox(height: 20.wMin),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.wMin),
            payWidget(context),
          ],
        ),
      ),
    );
  }

  Widget payWidget(BuildContext context) {
    MembershipCardManageController membershipCardManageController = Get.find<MembershipCardManageController>();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgQuaternary,
        borderRadius: BorderRadius.circular(10.wMin),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '当前余额',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.wMin),
              Obx(
                () => Text(
                  '${membershipCardManageController.model.value.priceStr ?? "0.00"} 元',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cFeedbackSuccessText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
                    GestureDetector(
            onTap: () {
              Get.toNamed(Routes.MEMBERSHIP_CARD_MANAGE_GENERATE_RECORD);
            },
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 15.wMin, horizontal: 24.wMin),
                decoration: BoxDecoration(
                  color:   AppTheme.cBgDisabled,
                  borderRadius: BorderRadius.circular(10.wMin),
                ),
                child: Center(
                  child: Text(
                      "查看记录",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ),
              ),
            
          ),
          SizedBox(width: 12.wMin),
        
          GestureDetector(
            onTap: () {
              if (controller.settlementModel.value.price == null) {
                return;
              }
              controller.confirmPaymentInformation(context);
            },
            child: Obx(
              () => Container(
                padding: EdgeInsets.symmetric(vertical: 15.wMin, horizontal: 80.wMin),
                decoration: BoxDecoration(
                  color: controller.settlementModel.value.price == null ? AppTheme.cBgDisabled : AppTheme.cBgBrand,
                  borderRadius: BorderRadius.circular(10.wMin),
                ),
                child: Center(
                  child: Obx(
                    () => Text(
                      controller.settlementModel.value.price == null ? '生成卡密' : '生成卡密（${controller.settlementModel.value.priceStr ?? '0.00'}元）',
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        
        ],
      ),
    );
  }

  Widget priceWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgQuaternary,
        borderRadius: BorderRadius.circular(10.wMin),
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '会员费用（${controller.usageMonths.value}个月）',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.wMin),
            Container(
              width: double.infinity,
              height: 2.wMin,
              color: AppTheme.cBorderSecondary,
            ),
            SizedBox(height: 15.wMin),
            Row(
              children: [
                Text(
                  '总计',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${controller.settlementModel.value.priceStr ?? 0.00}元',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextBrand,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Obx(
              () => Visibility(
                visible: controller.settlementModel.value.discountProportion != null,
                child: Column(
                  children: [
                    SizedBox(height: 15.wMin),
                    Text(
                      '节省了 ${controller.settlementModel.value.discountProportionStr ?? '0.0'}% （${controller.settlementModel.value.discountPriceStr ?? '0.0'}元）',
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cFeedbackSuccessText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget timeCellWidget(MembershipCardManageGenerateCodeCouponSupplyListModel item, int index) {
    return SizedBox(
      width: 550.wMin,
      child: Column(
        children: [
          Obx(
            () => GestureDetector(
              onTap: () {
                if (controller.selectTimeIndex.value != index) {
                  controller.selectTimeIndex.value = index;
                  controller.usageMonths.value = item.usageMonths ?? 0;
                  controller.getSettlement();
                }
              },
              child: Container(
                padding: EdgeInsets.all(15.wMin),
                decoration: BoxDecoration(
                  color: controller.selectTimeIndex.value == index ? AppTheme.cBgBrand.withAlpha(25) : AppTheme.cBgTertiary,
                  borderRadius: BorderRadius.circular(10.wMin),
                  border: Border.all(
                    color: controller.selectTimeIndex.value == index ? AppTheme.cBgBrand : AppTheme.cBgQuaternary,
                    width: 4.wMin,
                  ),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name ?? '',
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6.wMin),
                        Text(
                          item.description ?? '',
                          style: TextStyle(
                            fontSize: 20.wMin,
                            color: AppTheme.cTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Text(
                          '实际时长',
                          style: TextStyle(
                            fontSize: 20.wMin,
                            color: AppTheme.cTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6.wMin),
                        Text(
                          '${item.usageMonths ?? ''}个月',
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12.wMin),
        ],
      ),
    );
  }

  Widget numberWidget() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(20.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cBgQuaternary,
            borderRadius: BorderRadius.circular(10.wMin),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Obx(
                    () => Text(
                      '副卡×${controller.additionalCardNum.value}',
                      style: TextStyle(
                        fontSize: 30.wMin,
                        color: AppTheme.cBgBrand,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 70.wMin),
                  Text(
                    '首位学员免费',
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.wMin),
              Obx(
                () => Text(
                  '${controller.additionalCardNum.value}个宝宝学习',
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (controller.additionalCardNum.value > 1) {
                      controller.additionalCardNum.value--;
                      controller.getSettlement();
                    }
                  },
                  child: Icon(
                    Icons.remove_circle_outline,
                    color: const Color(0xffBAC0CC),
                    size: 50.wMin,
                  ),
                ),
                SizedBox(width: 30.wMin),
                Obx(
                  () => Text(
                    '${controller.additionalCardNum.value}',
                    style: TextStyle(
                      fontSize: 40.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 30.wMin),
                GestureDetector(
                  onTap: () {
                    if (controller.additionalCardNum.value < 3) {
                      controller.additionalCardNum.value++;
                      controller.getSettlement();
                    }
                  },
                  child: Icon(
                    Icons.add_circle_outline,
                    color: const Color(0xffBAC0CC),
                    size: 50.wMin,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.wMin),
            // Text(
            //   '额外学员 ¥9.9/个',
            //   style: TextStyle(
            //     fontSize: 24.wMin,
            //     color: AppTheme.cTextPrimary,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
          ],
        )
      ],
    );
  }

  Widget headCardWidget(MembershipCardManageGenerateCodeVIPListModel item, int index) {
    bool isSelect = controller.selectLevelIndex.value == index;
    Color selectColor = AppTheme.cBgBrand;
    if (item.vipType == 'Plus') {
      selectColor = AppTheme.cBgBrand;
    } else if (item.vipType == 'Pro') {
      selectColor = AppTheme.cUserProMember2;
    } else if (item.vipType == 'Max') {
      selectColor = AppTheme.cUserMaxMember2;
    } else if (item.vipType == '成员席位') {
      selectColor = AppTheme.cUserSeatCard2;
    }

    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (controller.selectLevelIndex.value != index) {
                  if (controller.vipList[index].isSeatService == true) {
                    controller.isShowCardNum.value = true;
                  } else {
                    controller.isShowCardNum.value = false;
                  }
                  controller.selectLevelIndex.value = index;
                  controller.getSettlement();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30.wMin, vertical: 20.wMin),
                decoration: BoxDecoration(
                  color: isSelect ? selectColor : AppTheme.cBgQuaternary,
                  borderRadius: BorderRadius.circular(10.wMin),
                ),
                child: Row(
                  children: [
                    Text(
                      item.vipType ?? '',
                      style: TextStyle(
                        fontSize: 32.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '¥${item.priceStr ?? ''}/月',
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 20.wMin),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 30.wMin),
        ],
      ),
    );
  }
}
