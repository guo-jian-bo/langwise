import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../bindings/membership_card_manage_agent_dashboard_binding.dart';
import '../controllers/membership_card_manage_agent_dashboard_controller.dart';
import '../models/membership_card_manage_agent_dashboard_model.dart';

class MembershipCardManageAgentDashboardView
    extends GetView<MembershipCardManageAgentDashboardController> {
  final String tagText;
  const MembershipCardManageAgentDashboardView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      MembershipCardManageAgentDashboardView(tagText: tag),
      binding: MembershipCardManageAgentDashboardBinding(tagText: tag),
      routeName: Routes.MEMBERSHIP_CARD_MANAGE_AGENT_DASHBOARD,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Container(
        padding: EdgeInsets.only(
          top: 20.wMin,
          left: 40.wMin + MediaQuery.of(context).padding.left,
          right: 40.wMin + MediaQuery.of(context).padding.right,
          bottom: 20.wMin + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          children: [
            _buildHeader(context),
            SizedBox(height: 24.wMin),
            _buildSummaryCard(),
            SizedBox(height: 24.wMin),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.wMin),
        Row(
          children: [
            const BackWidget(),
            Text(
              '代理商数据看板',
              style: TextStyle(
                fontSize: 22.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            _buildDateRangeField(context),
            SizedBox(width: 16.wMin),
            _buildSearchBox(context),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRangeField(BuildContext context) {
    return Builder(
      builder: (context) {
        return TapScaleWidget(
          onTap: () {
            controller.filterTime(context);
          },
          sclae: 1.02,
          child: Container(
            height: 52.wMin,
            padding: EdgeInsets.only(left: 16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26.wMin),
              color: AppTheme.cMemberCardSearchBackground,
              border: Border.all(
                color: AppTheme.cMemberCardInactiveBackground,
                width: 2.wMin,
              ),
            ),
            child: Obx(() {
              String startDate = "开始日期";
              String endDate = "结束日期";

              if (controller.startDate.value != null &&
                  controller.endDate.value != null) {
                startDate = DateFormatUtil.formatStr(controller.startDate.value!);
                endDate = DateFormatUtil.formatStr(controller.endDate.value!);
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$startDate ～ $endDate",
                    style: TextStyle(
                      color: AppTheme.cTextPrimary,
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TapScaleWidget(
                    onTap: () {
                      controller.clearFilterTime();
                    },
                    sclae: 1.1,
                    child: Container(
                      width: 52.wMin,
                      height: 52.wMin,
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        "assets/svg/public/x.svg",
                        width: 22.wMin,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    return Container(
      width: 360.wMin,
      height: 52.wMin,
      padding: EdgeInsets.symmetric(horizontal: 18.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cMemberCardSearchBackground,
        borderRadius: BorderRadius.circular(26.wMin),
        border: Border.all(
          color: AppTheme.cMemberCardInactiveBackground,
          width: 2.wMin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: '输入代理商ID或代理商昵称',
                hintStyle: const TextStyle(
                  color: AppTheme.cQuizDefaultBackground,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10.wMin),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => controller.onSearch(),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.searchController,
            builder: (_, value, __) => Visibility(
              visible: value.text.isNotEmpty,
              child: GestureDetector(
                onTap: controller.onClearSearch,
                child: Padding(
                  padding: EdgeInsets.only(right: 10.wMin),
                  child: Icon(
                    Icons.close,
                    color: AppTheme.cQuizDefaultBackground,
                    size: 24.wMin,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: controller.onSearch,
            child: Icon(
              Icons.search,
              color: AppTheme.cQuizDefaultBackground,
              size: 28.wMin,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Obx(() {
      final entity = controller.dashboardEntity.value;
      final items = [
        _DashboardMetric('开卡总金额', MembershipCardManageAgentDashboardItemModel.formatMoney(entity.createPrice)),
        _DashboardMetric('激活总金额', MembershipCardManageAgentDashboardItemModel.formatMoney(entity.activatePrice)),
        _DashboardMetric('充值总金额', MembershipCardManageAgentDashboardItemModel.formatMoney(entity.topUpPrice)),
        _DashboardMetric('剩余金额', MembershipCardManageAgentDashboardItemModel.formatMoney(entity.surplusPrice)),
        _DashboardMetric('返利总金额', MembershipCardManageAgentDashboardItemModel.formatMoney(entity.rebatePrice)),
        _DashboardMetric('开卡数量', (entity.createCards ?? 0).toString()),
        _DashboardMetric('激活总数量', (entity.activateCards ?? 0).toString()),
        _DashboardMetric('退款总金额', MembershipCardManageAgentDashboardItemModel.formatMoney(entity.refundPrice)),
      ];

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cBgSecondary,
          borderRadius: BorderRadius.circular(16.wMin),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 3 * 16.wMin) / 4;
            return Wrap(
              spacing: 16.wMin,
              runSpacing: 16.wMin,
              children: items
                  .map(
                    (item) => SizedBox(
                      width: itemWidth,
                      child: _buildSummaryItem(item),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      );
    });
  }

  Widget _buildSummaryItem(_DashboardMetric item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 18.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgTertiary,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            '${item.unit}${item.value}',
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value && controller.detailList.isEmpty) {
        return const Center();
      }

      if (controller.detailList.isEmpty) {
        return ListView(
          controller: controller.scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: [
            SizedBox(height: 120.wMin),
            Center(
              child: Text(
                '暂无代理商数据',
                style: TextStyle(
                  fontSize: 22.wMin,
                  color: AppTheme.cTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }

      return GridView.builder(
        controller: controller.scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20.wMin,
          mainAxisSpacing: 20.wMin,
          mainAxisExtent: 350.wMin,
        ),
        itemCount: controller.detailList.length,
        itemBuilder: (_, index) => _buildDetailCard(controller.detailList[index]),
      );
    });
  }

  Widget _buildDetailCard(MembershipCardManageAgentDashboardItemModel item) {
    return Container(
      padding: EdgeInsets.all(20.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgSecondary,
        borderRadius: BorderRadius.circular(16.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    Text(
                      item.titleText,
                      style: TextStyle(
                        fontSize: 22.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.wMin),
                    Text(
                      item.subTitleText,
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: AppTheme.cTextSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.wMin),
              Text(
                item.rightTitleText,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.wMin),
          Divider(color: AppTheme.cBgTertiary, height: 1.wMin),
          SizedBox(height: 18.wMin),
          _buildMetricWrap(
            [
              _DashboardMetric('开卡总金额', item.createPriceText),
              _DashboardMetric('激活总金额', item.activatePriceText),
              _DashboardMetric('充值总金额', item.topUpPriceText),
              _DashboardMetric('退款总金额', item.refundPriceText),
              _DashboardMetric('返利总金额', item.rebatePriceText),
              _DashboardMetric('赠送金额', item.donateAmountText),
              _DashboardMetric('余额', item.surplusPriceText),
            ],
          ),
          SizedBox(height: 12.wMin),
          Divider(color: AppTheme.cBgTertiary, height: 1.wMin),
          SizedBox(height: 12.wMin),
          _buildMetricWrap(
            [
              _DashboardMetric('累计生成卡片数', '${item.totalGeneratedCards ?? 0}', unit: ' 张'),
              _DashboardMetric('累计激活卡片数', '${item.totalActivatedCards ?? 0}', unit: ' 张'),
              _DashboardMetric('开卡数量', '${item.createCards ?? 0}', unit: ' 张'),
              _DashboardMetric('激活数量', '${item.activateCards ?? 0}', unit: ' 张'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricWrap(List<_DashboardMetric> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 3 * 12.wMin) / 4;
        return Wrap(
          spacing: 12.wMin,
          runSpacing: 16.wMin,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: _buildMetricItem(item),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildMetricItem(_DashboardMetric item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: TextStyle(
            fontSize: 16.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 8.wMin),

        Text.rich(
  TextSpan(
    children: [
      TextSpan(
       text: '${item.value}',
       
       
          style: TextStyle(
            fontSize: 22.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),// 红色、加粗、稍微放大
      ),
      TextSpan(
       text: '${item.unit}',
       
       
          style: TextStyle(
           fontSize: 16.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),// 红色、加粗、稍微放大
      ),
    ],
  ),
),
      ],
    );
  }
}

class _DashboardMetric {
  final String title;
  final String value;
  final String unit;

  const _DashboardMetric(this.title, this.value, {this.unit = ''});
}
