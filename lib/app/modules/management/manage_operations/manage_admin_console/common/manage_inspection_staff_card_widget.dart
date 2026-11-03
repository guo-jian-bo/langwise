import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../manage_inspection_statistics/models/manage_inspection_staff_model.dart';

class ManageInspectionStaffCardWidget extends StatelessWidget {
  final ManageInspectionStaffModel staff;
  final VoidCallback? onTap;

  const ManageInspectionStaffCardWidget({
    super.key,
    required this.staff,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderTranslucentNone.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 10.wMin,
                  runSpacing: 10.wMin,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...staff.roleNames.map((role) {
                      return _buildPillTagWidget(
                        text: role,
                        bgColor: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12),
                        borderColor: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.22),
                        textColor: AppTheme.cSurfaceSuccess.color,
                      );
                    }),
                    if (staff.lastActiveAt != null)
                      Text(
                        '最近操作 ${DateFormatUtil.getTimeAgoText(staff.lastActiveAt)}',
                        style: TextStyle(
                          fontSize: 14.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextTertiary.color,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12.wMin),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                decoration: BoxDecoration(
                  color: staff.isOnDuty ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2) : AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6.wMin),
                  border: Border.all(
                    color: staff.isOnDuty ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12) : AppTheme.cSurfaceError.color.withValues(alpha: .12),
                    width: 1.wMin,
                  ),
                ),
                child: Text(
                  staff.isOnDuty ? "已启用" : "已停用",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: staff.isOnDuty ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceError.color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.wMin),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      staff.name,
                      style: TextStyle(
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                    if (staff.tags.isNotEmpty) ...[
                      SizedBox(height: 12.wMin),
                      Wrap(
                        spacing: 12.wMin,
                        runSpacing: 8.wMin,
                        children: staff.tags.map((name) {
                          return Text(
                            name,
                            style: TextStyle(
                              fontSize: 18.wMin,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.cTextTertiary.color,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 16.wMin),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 14.wMin,
                children: [
                  _itemRightWight('领取中', staff.stats.receiving),
                  _itemRightWight('今日操作', staff.stats.todayOperations),
                  _itemRightWight('通知', staff.stats.notifications),
                  _itemRightWight('工单', staff.stats.tickets),
                ],
              )
            ],
          ),
        ],
      ),
    );
    if (onTap == null) return child;
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.003,
      child: child,
    );
  }

  Widget _itemRightWight(String text, int i, {Color? color}) {
    return Container(
      height: 76.wMin,
      width: 80.wMin,
      padding: EdgeInsets.all(6.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase,
        border: Border.all(
          color: AppTheme.cBorderNone,
        ),
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          Text(
            '$i',
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w600,
              color: color ?? AppTheme.cTextPrimary.color,
            ),
          )
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
}
