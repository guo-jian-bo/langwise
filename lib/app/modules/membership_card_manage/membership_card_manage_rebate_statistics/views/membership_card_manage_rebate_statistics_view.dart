import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/tag_routes.dart';

import '../../controllers/membership_card_manage_controller.dart';
import '../controllers/membership_card_manage_rebate_statistics_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../models/membership_card_manage_rebate_statistics_model.dart';

class MembershipCardManageRebateStatisticsView extends GetView<MembershipCardManageRebateStatisticsController> {
  final String tagText;
  const MembershipCardManageRebateStatisticsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    MembershipCardManageController membershipCardManageController =
        Get.find<MembershipCardManageController>(tag: tagText);

    return EasyRefresh(
      controller: controller.refreshController,
      header: const ClassicHeader(
        dragText: "下拉刷新",
        armedText: "释放刷新",
        readyText: "正在刷新...",
        processingText: "加载中...",
        processedText: "刷新完成",
        failedText: "刷新失败",
        showMessage: false,
      ),
      onRefresh: () async {
        // 账户界面概览刷新数据
        if (Get.isRegistered<MembershipCardManageController>(tag: tagText)) {
          MembershipCardManageController membershipCardManageController =
              Get.find<MembershipCardManageController>(tag: tagText);
          await membershipCardManageController.initData();
        }

        // 刷新统计数据
        await controller.initData();
      },
      child: SingleChildScrollView(
        child: Obx(
          () => Column(
            children: [
              Obx(
                () => Row(
                  children: [
                    headCardWidget("可用余额", membershipCardManageController.model.value.priceStr ?? "0.00", "元", "assets/svg/membership_card/membership_card_balance.svg",
                        const Color(0xFF0EA5E9)),
                    const Spacer(),
                    headCardWidget("累计充值", membershipCardManageController.model.value.topUpPriceStr?.toString() ?? "0.00", "元",
                        "assets/svg/membership_card/membership_card_recharge.svg", const Color(0xFF00BC7D)),
                    const Spacer(),
                    headCardWidget("体验卡", membershipCardManageController.model.value.sendCouponNum?.toString() ?? "0", "张",
                        "assets/svg/membership_card/membership_card_balance.svg", const Color(0xFF0EA5E9)),
                    const Spacer(),
                    headCardWidget("生成卡数", membershipCardManageController.model.value.totalGeneratedCards?.toString() ?? "0", "张",
                        "assets/svg/membership_card/membership_card_generate_num.svg", const Color(0xFFC026D3)),
                    const Spacer(),
                    headCardWidget("激活卡数", membershipCardManageController.model.value.totalActivatedCards?.toString() ?? "0", "张",
                        "assets/svg/membership_card/membership_card_activation_num.svg", const Color(0xFFFB923C)),
                  ],
                ),
              ),
              SizedBox(height: 40.wMin),
              GestureDetector(
                onTap: () {
                  TagRoutes.toNamed(Routes.MEMBERSHIP_CARD_MANAGE_REBATE_RECORD);
                },
                child: Container(
                  width: double.infinity,
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
                        "查看返点记录",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40.wMin),
              statisticCardWidget(controller.statisticsEntity.value.month),
              SizedBox(height: 40.wMin),
              statisticCardWidget(controller.statisticsEntity.value.quarter),
              SizedBox(height: 40.wMin),
              statisticCardWidget(controller.statisticsEntity.value.your),
            ],
          ),
        ),
      ),
    );
  }

  Widget statisticCardWidget(MembershipCardManageRebateStatisticsModel? model) {
    if (model == null) {
      return const SizedBox.shrink();
    }

    String? title;
    if (model.periodType == 'MONTH') {
      title = '月度统计';
    } else if (model.periodType == 'QUARTER') {
      title = '季度统计';
    } else if (model.periodType == 'YOUR') {
      title = '年度统计';
    }

    String? level;
    if (model.currentTierLevel != null) {
      level = '第${controller.convertNumberToChinese(model.currentTierLevel ?? 0)}档';
    } else {
      level = '距离下个档位已完成';
    }

    String? percentage;
    if (model.currentTierRate != null) {
      percentage = ' (${model.currentTierRate ?? 0}%)';
    }

    String? lastLevel;
    if (model.lastTierLevel != null) {
      lastLevel = '第${controller.convertNumberToChinese(model.lastTierLevel ?? 0)}档 (${model.lastTierRate ?? 100}%)';
    }

    String? lastRebateStatus;
    if (model.lastRebateStatus != null) {
      lastRebateStatus = model.lastRebateStatus == true ? '已发放' : '未发放';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cBgSecondary,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.wMin),
            Text(
              title ?? '',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary,
              ),
            ),
            // 下方返点档位
            SizedBox(height: 20.wMin),
            // 上方统计信息
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cBgTertiary,
                      borderRadius: BorderRadius.circular(12.wMin),
                      border: Border.all(
                        color: AppTheme.cBgQuaternary,
                        width: 4.wMin,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 12.wMin),
                          decoration: const BoxDecoration(
                            color: AppTheme.cBgQuaternary,
                          ),
                          child: Text(
                            '当前周期进度',
                            style: TextStyle(
                              fontSize: 24.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextPrimary,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20.wMin),
                          child: Obx(
                            () {
                              final expanded = controller.isExpanded(model.periodType, isCurrent: true);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStatRow(
                                    '建卡金额',
                                    '${model.currentCreatedAmountStr ?? 0} 元',
                                    24.wMin,
                                    AppTheme.cTextSecondary,
                                  ),
                                  _buildStatRow(
                                    '当前档位',
                                    percentage != null ? '$level$percentage' : '无',
                                    24.wMin,
                                    AppTheme.cTextBrand,
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () => controller.toggleExpanded(model.periodType, isCurrent: true),
                                    child: Row(
                                      children: [
                                        Text(
                                          '查看更多',
                                          style: TextStyle(
                                            fontSize: 24.wMin,
                                            fontWeight: FontWeight.w400,
                                            color: AppTheme.cTextTertiary,
                                          ),
                                        ),
                                        Spacer(),
                                        SvgPicture.asset(expanded ? 'assets/svg/manage/icon_chevron_up.svg' : 'assets/svg/manage/icon_chevron_down.svg',
                                            width: 32.wMin, height: 32.wMin)
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: expanded,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildStatRow(
                                          '退款金额',
                                          '${model.currentRefundAmountStr ?? 0} 元',
                                          24.wMin,
                                          AppTheme.cTextTertiary,
                                          titleFontColor: AppTheme.cTextTertiary,
                                        ),
                                        _buildStatRow(
                                          '实际激活金额',
                                          '${model.currentActivatedAmountStr ?? 0} 元',
                                          28.wMin,
                                          AppTheme.cTextTertiary,
                                          titleFontColor: AppTheme.cTextTertiary,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(color: AppTheme.cTextSecondary),
                                  _buildStatRow(
                                    '预计返点',
                                    '${model.currentEstimatedRebateStr ?? 0} 元',
                                    28.wMin,
                                    AppTheme.cTextPrimary,
                                  ),
                                  SizedBox(
                                    height: 60.wMin,
                                    child: _buildStatRow(
                                      '距离下一档位',
                                      '还需要 ${model.amountToNextTierStr ?? 0} 元',
                                      24.wMin,
                                      AppTheme.cUserMaxMember2,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cBgTertiary,
                      borderRadius: BorderRadius.circular(12.wMin),
                      border: Border.all(
                        color: AppTheme.cBgQuaternary,
                        width: 4.wMin,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 12.wMin),
                          decoration: const BoxDecoration(
                            color: AppTheme.cBgQuaternary,
                          ),
                          child: Text(
                            '上个周期进度',
                            style: TextStyle(
                              fontSize: 24.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextPrimary,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20.wMin),
                          child: Obx(
                            () {
                              final expanded = controller.isExpanded(model.periodType, isCurrent: false);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStatRow(
                                    '建卡金额(以此金额统计返点)',
                                    '${model.lastActivatedAmountStr ?? 0} 元',
                                    24.wMin,
                                    AppTheme.cTextSecondary,
                                  ),
                                  _buildStatRow(
                                    '档位',
                                    lastLevel ?? '无',
                                    24.wMin,
                                    AppTheme.cTextBrand,
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () => controller.toggleExpanded(model.periodType, isCurrent: false),
                                    child: Row(
                                      children: [
                                        Text(
                                          '查看更多',
                                          style: TextStyle(
                                            fontSize: 24.wMin,
                                            fontWeight: FontWeight.w400,
                                            color: AppTheme.cTextTertiary,
                                          ),
                                        ),
                                        Spacer(),
                                        SvgPicture.asset(expanded ? 'assets/svg/manage/icon_chevron_up.svg' : 'assets/svg/manage/icon_chevron_down.svg',
                                            width: 32.wMin, height: 32.wMin)
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: expanded,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildStatRow(
                                          '退款金额',
                                          '${model.lastRefundAmountStr ?? 0} 元',
                                          24.wMin,
                                          AppTheme.cTextSecondary,
                                          titleFontColor: AppTheme.cTextTertiary
                                        ),
                                        _buildStatRow(
                                          '实际激活金额',
                                          '${model.lastActualAmountStr ?? 0} 元',
                                          28.wMin,
                                          AppTheme.cTextPrimary,
                                          titleFontColor: AppTheme.cTextTertiary
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(color: AppTheme.cTextSecondary),
                                  _buildStatRow(
                                    '返点金额',
                                    '${model.lastRebateAmountStr ?? 0} 元',
                                    28.wMin,
                                    AppTheme.cTextPrimary,
                                  ),
                                  SizedBox(
                                    height: 60.wMin,
                                    child: _buildStatRow(
                                      '发放状态',
                                      lastRebateStatus,
                                      24.wMin,
                                      AppTheme.cTextBrand,
                                      isHighlighted: true,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.wMin),
            Text(
              '返点档位',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary,
              ),
            ),
            // 下方返点档位
            SizedBox(height: 20.wMin),
            Row(
              children: List.generate(
                model.configData!.length,
                (i) {
                  return _buildLevelCard(model.configData![i], model);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String title, String? subTitle, double fontSize, Color fontColor, {Color titleFontColor = AppTheme.cTextSecondary, bool isHighlighted = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
              color: titleFontColor,
            ),
          ),
          isHighlighted
              ? subTitle != null
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
                      decoration: BoxDecoration(
                        color: AppTheme.cFeedbackSuccessBorder.withAlpha(26),
                        borderRadius: BorderRadius.circular(6.wMin),
                      ),
                      child: Text(
                        subTitle,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cFeedbackSuccessBorder,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
              : Text(
                  subTitle!,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w400,
                    color: fontColor,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(MembershipCardManageRebateStatisticsLevelModel levelModel, MembershipCardManageRebateStatisticsModel? model) {
    final isActive = model?.currentTierLevel == levelModel.gear;
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.cBgBrand.withOpacity(0.1) : AppTheme.cBgTertiary,
                borderRadius: BorderRadius.circular(12.wMin),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: isActive ? AppTheme.cBgBrand.withOpacity(0.3) : AppTheme.cBgQuaternary,
                    padding: EdgeInsets.symmetric(
                      vertical: 20.wMin,
                    ),
                    child: Center(
                      child: Text(
                        '第${controller.convertNumberToChinese(levelModel.gear ?? 1)}档',
                        style: TextStyle(fontSize: 20.wMin, fontWeight: FontWeight.w500, color: isActive ? AppTheme.cTextPrimary : AppTheme.cTextSecondary),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.wMin),
                  Text(
                    '${levelModel.minAmountStr}元',
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 10.wMin),
                  Text(
                    '${levelModel.bonusRate?.toString() ?? ''}% 返点',
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 20.wMin),
                ],
              ),
            ),
          ),
          SizedBox(width: 30.wMin),
        ],
      ),
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
