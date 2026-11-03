import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../bindings/membership_card_manage_generate_record_binding.dart';
import '../controllers/membership_card_manage_generate_record_controller.dart';
import '../models/membership_card_manage_generate_record_model.dart';

class MembershipCardManageGenerateRecordView
    extends GetView<MembershipCardManageGenerateRecordController> {
  final String tagText;
  const MembershipCardManageGenerateRecordView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => MembershipCardManageGenerateRecordView(tagText: tag),
      binding: MembershipCardManageGenerateRecordBinding(tagText: tag),
      routeName: Routes.MEMBERSHIP_CARD_MANAGE_GENERATE_RECORD,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        children: [
          BreadcrumbWidget(
            actionWidget: _buildSearchBox(context),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                left: 40.wMin + MediaQuery.of(context).padding.left,
                right: 40.wMin + MediaQuery.of(context).padding.right,
                top: 24.wMin,
                bottom: 20.wMin + MediaQuery.of(context).padding.bottom,
              ),
              child: _buildTableCard(context),
            ),
          ),
        ],
      ),
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
                hintText: '搜索用户ID/手机尾号',
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

  Widget _buildTableCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // color: AppTheme.cBgTertiary,
        borderRadius: BorderRadius.circular(6.wMin),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.wMin),
        child: Column(
          children: [
            _buildTableHeader(),
            Expanded(
              child: Obx(
                () {
                  if (controller.isLoading.value &&
                      controller.recordList.isEmpty) {
                    return const Center(
                    );
                  }

                  return controller.recordList.isEmpty
                      ? ListView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          children: [
                            SizedBox(height: 120.wMin),
                            Center(
                              child: Text(
                                '暂无建卡记录',
                                style: TextStyle(
                                  fontSize: 22.wMin,
                                  color: AppTheme.cTextSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          controller: controller.scrollController,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          itemCount: controller.recordList.length +
                              (controller.hasMore ? 0 : 1),
                          itemBuilder: (context, index) {
                            if (index >= controller.recordList.length) {
                              return SizedBox(
                                height:
                                    300.wMin,
                              );
                            }
                            return _buildRecordRow(
                              controller.recordList[index],
                              index,
                            );
                          },
                        );
                },
              ),
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
          _buildHeaderCell('卡种详情', flex: 24),
          _buildHeaderCell('金额', flex: 9),
          _buildHeaderCell('余额', flex: 9),
          _buildHeaderCell('激活人姓名', flex: 10),
          _buildHeaderCell('激活手机号', flex: 12),
          _buildHeaderCell('建卡日期', flex: 15),
          _buildHeaderCell('激活日期', flex: 15),
          _buildHeaderCell('状态', flex: 6),
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
    MembershipCardManageGenerateRecordModel item,
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
          _buildRowCell(item.cardDetail, flex: 24, maxLines: 2),
          _buildRowCell(item.amountStr, flex: 9),
          _buildRowCell(item.balanceStr, flex: 9),
          _buildRowCell(item.activateUserName ?? '--', flex: 10),
          _buildRowCell(item.activateUserPhone ?? '--', flex: 12),
          _buildRowCell(_formatDate(item.created), flex: 15),
          _buildRowCell(_formatDate(item.activated), flex: 15),
          Expanded(
            flex: 6,
            child: _buildStatusCell(item.statusText),
          ),
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
    final isSuccess = statusText == '已激活';
    final isPending = statusText == '未激活';
    final Color textColor = isSuccess
        ? AppTheme.cFeedbackSuccessText
        : isPending
            ? AppTheme.cTextSecondary
            : AppTheme.cFeedbackErrorText;
    final Color backgroundColor = isSuccess
        ? AppTheme.cFeedbackSuccessText.withValues(alpha: 0.16)
        : isPending
            ? AppTheme.cBgQuaternary
            : AppTheme.cFeedbackErrorText.withValues(alpha: 0.16);

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
