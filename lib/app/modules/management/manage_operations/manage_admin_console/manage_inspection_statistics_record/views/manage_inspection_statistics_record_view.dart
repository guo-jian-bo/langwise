import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/filter_widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../common/manage_inspection_staff_card_widget.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_inspection_statistics_record_binding.dart';
import '../controllers/manage_inspection_statistics_record_controller.dart';
import '../models/manage_inspection_operation_record_model.dart';

class ManageInspectionStatisticsRecordView extends GetView<ManageInspectionStatisticsRecordController> {
  final String tagText;
  const ManageInspectionStatisticsRecordView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_INSPECTION_STATISTICS_RECORD}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      () => ManageInspectionStatisticsRecordView(tagText: tag),
      binding: ManageInspectionStatisticsRecordBinding(tag: tag),
      routeName: Routes.MANAGE_INSPECTION_STATISTICS_RECORD,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      floatingActionButton: _buildRecordFilterWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 180.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(),
            _buildStaffOverviewWidget(),
            _buildRecordListWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 70.wMin),
      margin: EdgeInsets.only(top: 16.wMin),
      child: Row(
        children: [
          Text(
            '${controller.staff.name} · 巡检记录',
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(width: 24.wMin),
          Text(
            '查看该工作人员当前领取中的学员，以及历史巡检操作留痕。',
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffOverviewWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 70.wMin),
      margin: EdgeInsets.only(top: 24.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '工作人员概览',
                      style: TextStyle(
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                    SizedBox(height: 4.wMin),
                    Text(
                      '当前领取情况与累计操作统计。',
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.wMin),
          _buildStaffCardWidget(),
        ],
      ),
    );
  }

  Widget _buildStaffCardWidget() {
    return ManageInspectionStaffCardWidget(
      staff: controller.staff,
    );
  }

  Widget _buildRecordListWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 70.wMin),
      margin: EdgeInsets.only(top: 32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '操作记录',
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 4.wMin),
          Text(
            '每一次领取、转交、通知、工单与学员资料修改都会在这里留痕。',
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          SizedBox(height: 16.wMin),
          Obx(() {
            final list = controller.filteredRecordList;
            return ListView.separated(
              itemCount: list.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
              itemBuilder: (context, index) {
                return _buildRecordItemWidget(list[index]);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecordItemWidget(ManageInspectionOperationRecordModel record) {
    final timeText = DateFormatUtil.formatStr(record.time, newPattern: 'yyyy/MM/dd HH:mm');
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderTranslucentNone.color,
          width: 1.wMin,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildPillTagWidget(
                        text: record.tag,
                        bgColor: AppTheme.cSurfaceTertiary.color,
                        borderColor: AppTheme.cBorderSecondary.color,
                        textColor: AppTheme.cTextSecondary.color,
                      ),
                      SizedBox(width: 12.wMin),
                      Text(
                        timeText,
                        style: TextStyle(
                          fontSize: 14.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextTertiary.color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.wMin),
                  Text(
                    record.title,
                    style: TextStyle(
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                  SizedBox(height: 8.wMin),
                  Text(
                    record.desc,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 24.wMin),
            Align(
              alignment: Alignment.bottomRight,
              child: _buildOperatorWidget(record.operator),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorWidget(ManageInspectionOperationRecordOperatorModel operator) {
    return Container(
      width: 300.wMax,
      padding: EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 14.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.wMin),
        color: AppTheme.cSurfaceSecondary.color,
        border: Border.all(
          color: AppTheme.cBorderNone.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            operator.name,
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 2.wMin),
          Text(
            '${operator.id} · ${operator.phone}',
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTagWidget({
    required String text,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: borderColor,
          width: 0.8.wMin,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18.wMin,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildRecordFilterWidget() {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 70.wMin),
        child: FilterStripWidget(
          width: double.infinity,
          searchSingleWidth: 520.wMin,
          conditions: {...controller.filterConditions},
          searchs: controller.filterSearchs,
          onConditions: (conditions) {
            controller.filterConditions.value = conditions;
          },
          onReset: (sorts, conditions) {
            controller.filterConditions.value = conditions;
          },
          onSingleClearSearch: () {
            controller.onSearchChanged('');
          },
          onSearch: () {
            controller.onSearchChanged(controller.filterSearchs['keyword']?.controller.text ?? '');
          },
        ),
      );
    });
  }
}
