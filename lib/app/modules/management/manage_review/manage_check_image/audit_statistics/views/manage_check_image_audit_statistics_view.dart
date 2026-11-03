import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/date_time_picker_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/manage_scaffold.dart';
import '../bindings/manage_check_image_audit_statistics_binding.dart';
import '../controllers/manage_check_image_audit_statistics_controller.dart';

class ManageCheckImageAuditStatisticsView extends GetView<ManageCheckImageAuditStatisticsController> {
  final String tagText;
  const ManageCheckImageAuditStatisticsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CHECK_IMAGE_AUDIT_STATISTICS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageCheckImageAuditStatisticsView(tagText: tag),
      binding: ManageCheckImageAuditStatisticsBinding(tag: tag),
      routeName: Routes.MANAGE_CHECK_IMAGE_AUDIT_STATISTICS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return ManageScaffold(
      title: "审核统计",
      body: Obx(
        () {
          final data = controller.statistics.value;
          return Container(
            padding: EdgeInsets.only(
              left: 24.wMin,
              right: 24.wMin,
              top: 16.wMin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 54.wMin,
                  child: _toolBar(context),
                ),
                SizedBox(height: 16.wMin),
                if (controller.isLoading.value)
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 36.wMin,
                        height: 36.wMin,
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.only(bottom: 120.wMin),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                title: '总审核任务数',
                                value: '${data?.totalTaskCount ?? 0}',
                                subTitle: '个任务',
                              ),
                            ),
                            SizedBox(width: 16.wMin),
                            Expanded(
                              child: _statCard(
                                title: '总审核图片数',
                                value: '${data?.totalImageCount ?? 0}',
                                subTitle: '张图片',
                                valueColor: const Color(0xFF63DE77),
                              ),
                            ),
                            SizedBox(width: 16.wMin),
                            Expanded(
                              child: _statCard(
                                title: '未审核任务数',
                                value: '${data?.totalNoCheckedTaskCount ?? 0}',
                                subTitle: '个任务',
                                valueColor: const Color(0xFFFF2D46),
                              ),
                            ),
                            SizedBox(width: 16.wMin),
                            Expanded(
                              child: _statCard(
                                title: '未审核图片数',
                                value: '${data?.totalNoCheckedImageCount ?? 0}',
                                subTitle: '张图片',
                                valueColor: const Color(0xFFFF2D46),
                              ),
                            ),
                            SizedBox(width: 16.wMin),
                            Expanded(
                              child: _statCard(
                                title: '被放弃任务数',
                                value: '${data?.totalAbandonedTaskCount ?? 0}',
                                subTitle: '个任务',
                                valueColor: const Color(0xFFFF2D46),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.wMin),
                        Container(
                          padding: EdgeInsets.all(16.wMin),
                          decoration: BoxDecoration(
                            color: AppTheme.cSurfaceSecondary.color,
                            borderRadius: BorderRadius.circular(8.wMin),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('审核员排名', style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 32.wMin, fontWeight: FontWeight.w400)),
                              SizedBox(height: 12.wMin),
                              ...(data?.auditorStats ?? const []).asMap().entries.map((entry) {
                                final idx = entry.key;
                                final item = entry.value;
                                return _rankItem(
                                  rank: idx + 1,
                                  userId: item.userId,
                                  name: item.auditorName ?? '系统审核员',
                                  taskCount: item.taskCount ?? 0,
                                  imageCount: item.imageCount ?? 0,
                                  failedTaskCount: item.failedTaskCount ?? 0,
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _toolBar(BuildContext context) {
    return Row(
      children: [
        Builder(builder: (context) {
          return GestureDetector(
            onTap: () {
              DateTimePickerUtils.showStartEndCalender(
                  context: context,
                  minDate: DateTime(2024, 11, 18),
                  maxDate: DateTime.now(),
                  initialStartDate: controller.startDate.value,
                  initialEndDate: controller.endDate.value,
                  onTap: (startDate, endDate) {
                    var _startDate = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
                    var _endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
                    controller.setDate(mStartDate: _startDate, mEndDate: _endDate);
                  });
            },
            child: Container(
                alignment: Alignment.center,
                height: 54.wMin,
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: AppTheme.cSurfaceSecondary.color,
                  border: Border.all(
                    color: AppTheme.cBorderPrimary.color,
                    width: 1.wMin,
                  ),
                ),
                child: Row(
                  children: [
                    Text('${controller.formatDateLabel(controller.startDate.value)}~${controller.formatDateLabel(controller.endDate.value)}',
                        style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 14.wMin)),
                    if (controller.startDate.value != null && controller.endDate.value != null)
                      GestureDetector(
                        onTap: () {
                          controller.clearDateRange();
                        },
                        child: SvgPicture.asset('assets/svg/public/icon_clean.svg', width: 24.wMin, height: 24.wMin),
                      ),
                  ],
                )),
          );
        }),
        Spacer(),
        Obx(() {
          final isOnlyMe = controller.onlyMe.value;
          return Row(
            children: [
              _toggleChip(
                label: '只看自己',
                selected: isOnlyMe,
                onTap: isOnlyMe ? null : controller.toggleOnlyMe,
              ),
              SizedBox(width: 12.wMin),
              _toggleChip(
                label: '查看全部',
                selected: !isOnlyMe,
                onTap: isOnlyMe ? controller.toggleOnlyMe : null,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _toggleChip({
    required String label,
    required bool selected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54.wMin,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2388FF) : const Color(0xFF353E5C),
          borderRadius: BorderRadius.circular(6.wMin),
        ),
        child: Text(label, style: TextStyle(color: Colors.white, fontSize: 16.wMin)),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subTitle,
    Color valueColor = const Color(0xFF2388FF),
  }) {
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceSecondary.color,
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 14.wMin)),
          SizedBox(height: 8.wMin),
          Text(value, style: TextStyle(color: valueColor, fontSize: 28.wMin, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.wMin),
          Text(subTitle, style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 14.wMin)),
        ],
      ),
    );
  }

  Widget _rankItem({
    required int rank,
    required int? userId,
    required String name,
    required int taskCount,
    required int imageCount,
    required int failedTaskCount,
  }) {
    Color rankColor;
    if (rank == 1) {
      rankColor = const Color(0xFFFF9E0D);
    } else if (rank == 2) {
      rankColor = const Color(0xFF929292);
    } else if (rank == 3) {
      rankColor = const Color(0xFF85592C);
    } else {
      rankColor = const Color(0xFF353E5C);
    }

    return GestureDetector(
      onTap: userId == null || userId == -1
          ? null
          : () {
              Get.back(
                result: userId,
              );
            },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: AppTheme.cSurfaceSecondary.color,
          border: Border(
            top: BorderSide(
              color: AppTheme.cBorderPrimary.color,
              width: 1.wMin,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.wMin,
              height: 44.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: rankColor, shape: BoxShape.circle),
              child: AutoSizeText('$rank', style: TextStyle(color: Colors.white, fontSize: 27.wMin, fontWeight: FontWeight.w400)),
            ),
            SizedBox(width: 12.wMin),
            Expanded(
              flex: 9,
              child: Text(name, style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 27.wMin)),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$taskCount', style: TextStyle(color: const Color(0xFF2388FF), fontSize: 27.wMin, fontWeight: FontWeight.w500)),
                  Text('任务通过', style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 19.wMin)),
                ],
              ),
            ),
            SizedBox(width: 24.wMin),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$imageCount', style: TextStyle(color: const Color(0xFF63DE77), fontSize: 27.wMin, fontWeight: FontWeight.w500)),
                  Text('图片通过', style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 19.wMin)),
                ],
              ),
            ),
            SizedBox(width: 24.wMin),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$failedTaskCount', style: TextStyle(color: const Color(0xFFFF2D46), fontSize: 27.wMin, fontWeight: FontWeight.w500)),
                  Text('任务失败', style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 19.wMin)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
