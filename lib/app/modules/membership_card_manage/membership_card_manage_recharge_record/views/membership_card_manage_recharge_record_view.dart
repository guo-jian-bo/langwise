import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../controllers/membership_card_manage_recharge_record_controller.dart';
import '../models/membership_card_manage_recharge_record_model.dart';

class MembershipCardManageRechargeRecordView
    extends GetView<MembershipCardManageRechargeRecordController> {
  const MembershipCardManageRechargeRecordView({super.key});

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
              '充值记录',
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
                          controller.isLoading.value ? '' : '暂无充值记录',
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
                    return _buildRecordRow(
                      controller.recordList[index],
                      index,
                    );
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
          _buildHeaderCell('实际到账', flex: 14),
          _buildHeaderCell('充值金额', flex: 14),
          _buildHeaderCell('返利金额', flex: 14),
          _buildHeaderCell('充值时间', flex: 20),
          _buildHeaderCell('生成状态', flex: 14),
          _buildHeaderCell('备注', flex: 24),
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

  Widget _buildRecordRow(
    MembershipCardManageRechargeRecordModel item,
    int index,
  ) {
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
          _buildRowCell(item.amountText, flex: 14),
          _buildRowCell(item.totalAmountText, flex: 14),
          _buildRowCell(item.bonusAmountText, flex: 14),
          _buildRowCell(_formatDate(item.created), flex: 20),
          Expanded(
            flex: 14,
            child: _buildStatusCell(item.statusText),
          ),
          _buildRowCell(item.remarkText, flex: 24, maxLines: 2),
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
        child: _buildTextCell(text, maxLines: maxLines),
      ),
    );
  }

  Widget _buildTextCell(String text, {int maxLines = 1}) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 18.wMin,
        color: AppTheme.cTextPrimary,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
    );
  }

  Widget _buildStatusCell(String statusText) {
    final isSuccess = statusText.contains('成功');
    final isError = statusText.contains('退款') || statusText.contains('失败');
    final Color textColor = isSuccess
        ? AppTheme.cFeedbackSuccessText
        : isError
            ? AppTheme.cFeedbackErrorText
            : AppTheme.cTextSecondary;
    final Color backgroundColor = isSuccess
        ? AppTheme.cFeedbackSuccessText.withValues(alpha: 0.16)
        : isError
            ? AppTheme.cFeedbackErrorText.withValues(alpha: 0.16)
            : AppTheme.cBgQuaternary;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.wMin,
          vertical: 6.wMin,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6.wMin),
        ),
        child: Text(
          statusText,
          style: TextStyle(
            fontSize: 18.wMin,
            color: textColor,
            fontWeight: FontWeight.w600,
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
