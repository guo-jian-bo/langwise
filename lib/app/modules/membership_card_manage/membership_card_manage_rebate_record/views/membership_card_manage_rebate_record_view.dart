import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../controllers/membership_card_manage_rebate_record_controller.dart';
import '../models/membership_card_manage_rebate_record_model.dart';

class MembershipCardManageRebateRecordView
    extends GetView<MembershipCardManageRebateRecordController> {
  const MembershipCardManageRebateRecordView({super.key});

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
            _buildHeader(),
            SizedBox(height: 12.wMin),
            _buildTip(),
            SizedBox(height: 24.wMin),
            Expanded(child: _buildTableCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(height: 10.wMin),
        Row(
          children: [
            const BackWidget(),
            Text(
              '返点记录',
              style: TextStyle(
                fontSize: 22.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTip() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.wMin),
      child: Text(
        '提示：返利金额保留按照四舍五入两位小数。',
        style: TextStyle(
          fontSize: 16.wMin,
          color: AppTheme.cTextSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildTableCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.wMin),
        child: Column(
          children: [
            _buildTableHeader(),
            Expanded(
              child: Obx(() {
                if (controller.recordList.isEmpty) {
                  return ListView(
                    controller: controller.scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    children: [
                      SizedBox(height: 120.wMin),
                      Center(
                        child: Text(
                          controller.isLoading.value ? '' : '暂无返点记录',
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

                return ListView.builder(
                  controller: controller.scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount:
                      controller.recordList.length + (controller.hasMore ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (index >= controller.recordList.length) {
                      return SizedBox(height: 300.wMin);
                    }
                    return _buildRecordRow(controller.recordList[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgQuaternary,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.cBgTertiary,
            width: 1.wMin,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('周期', flex: 13),
          _buildHeaderCell('类型', flex: 11),
          _buildHeaderCell('建卡金额', flex: 16),
          _buildHeaderCell('返利', flex: 18),
          _buildHeaderCell('返点金额', flex: 16),
          _buildHeaderCell('发放时间', flex: 26),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.wMin,
          color: AppTheme.cTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRecordRow(MembershipCardManageRebateRecordModel item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgSecondary,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.cBgTertiary,
            width: 1.wMin,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildRowCell(item.periodText, flex: 13),
          _buildRowCell(item.typeText, flex: 11),
          _buildRowCell(item.distPriceText, flex: 16),
          _buildRowCell(item.rebateWithRatioText, flex: 18),
          _buildRowCell(item.distributionPriceText, flex: 16),
          _buildRowCell(_formatDate(item.distributionTime), flex: 26),
        ],
      ),
    );
  }

  Widget _buildRowCell(
    String text, {
    required int flex,
    int maxLines = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.only(right: 8.wMin),
        child: Text(
          text,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '--';
    }
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '${dateTime.year}.$month.$day $hour:$minute:$second';
  }
}
