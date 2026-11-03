import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/filter_widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../common/manage_inspection_staff_card_widget.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_inspection_statistics_binding.dart';
import '../controllers/manage_inspection_statistics_controller.dart';
import '../models/manage_inspection_staff_model.dart';

class ManageInspectionStatisticsView extends GetView<ManageInspectionStatisticsController> {
  final String tagText;
  const ManageInspectionStatisticsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_INSPECTION_STATISTICS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageInspectionStatisticsView(tagText: tag),
      binding: ManageInspectionStatisticsBinding(tag: tag),
      routeName: Routes.MANAGE_INSPECTION_STATISTICS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ManageScaffold(
        body: Column(
          children: [
            _buildTitleWidget(),
            _buildStatisticsWidget(),
            Expanded(child: _buildListWidget()),
          ],
        ),
        floatingActionButton: _buildBottomBarWidget(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
            '巡检统计',
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(width: 24.wMin),
          Text(
            '按工作人员查看巡检领取、转交、通知发送、工单处理与学员资料操作的完整留痕。',
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

  Widget _buildStatisticsWidget() {
    return Obx(() {
      return Container(
        margin: EdgeInsets.only(top: 16.wMin),
        padding: EdgeInsets.symmetric(horizontal: 70.wMin),
        child: Row(
          spacing: 16.wMin,
          children: [
            _buildStatisticsItemWidget('在岗人员', '${controller.onDutyCount.value}'),
            _buildStatisticsItemWidget('已领取学员', '${controller.receivedStudentsCount.value}'),
            _buildStatisticsItemWidget('今日操作', '${controller.todayOperationsCount.value}'),
            _buildStatisticsItemWidget('通知发送', '${controller.notificationsCount.value}'),
            _buildStatisticsItemWidget('工单处理', '${controller.ticketCount.value}'),
          ],
        ),
      );
    });
  }

  Widget _buildStatisticsItemWidget(String name, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderNone.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 38.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListWidget() {
    return Obx(() {
      final list = controller.filteredStaffList;
      return ListView.separated(
        itemCount: list.length,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 70.wMin, right: 70.wMin, top: 20.wMin),
        separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
        itemBuilder: (context, index) {
          return _buildStaffItemWidget(list[index]);
        },
      );
    });
  }

  Widget _buildStaffItemWidget(ManageInspectionStaffModel staff) {
    return ManageInspectionStaffCardWidget(
      staff: staff,
      onTap: () {
        controller.checkRecord(staff);
      },
    );
  }

  Widget _buildBottomBarWidget() {
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
            controller.filterConditions.refresh();
          },
          onReset: (sorts, conditions) {
            controller.filterConditions.value = conditions;
            controller.filterConditions.refresh();
          },
          onSearch: () {
            controller.onSearchChanged(controller.filterSearchs['content']?.controller.text ?? '');
          },
        ),
      );
    });
  }
}
