import 'package:flutter/material.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/widgets/guide_engine/guide_anchor.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/painter/painter.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

class MissionControlCenterSpecialMenuWidget extends StatefulWidget {
  final List<TaskMissionMenuEntityList> taskMissionMenuList;
  final void Function(BuildContext context, TaskMissionMenuEntityList item)? onTap;
  const MissionControlCenterSpecialMenuWidget({
    super.key, 
    required this.taskMissionMenuList, 
    this.onTap,
  });

  @override
  State<MissionControlCenterSpecialMenuWidget> createState() => _MissionControlCenterSpecialMenuWidgetState();
}

class _MissionControlCenterSpecialMenuWidgetState extends State<MissionControlCenterSpecialMenuWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180.wMin,
      alignment: Alignment.center,
      child: CustomPaint(
        painter: GradientBorderPainter(
          strokeWidth: 1.5.wMin,
          radius: BorderRadius.vertical(top: Radius.circular(32.wMin)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.cBorderBrand.color,
              AppTheme.cBorderBrand.color.withValues(alpha: 0.6),
              AppTheme.cBorderBrand.color.withValues(alpha: 0.4),
              AppTheme.cBorderBrand.color.withValues(alpha: 0),
            ],
          ),
        ),
        child: Container(
          padding: EdgeInsets.only(
            left: 40.wMin,
            right: 40.wMin,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.wMin)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.cTransparentBrand2.color,
                AppTheme.cBgPrimary.color,
              ],
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.taskMissionMenuList.length, (index) {
                return _buildBottomMenuItemWidget(context, widget.taskMissionMenuList[index], index);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomMenuItemWidget(BuildContext context, TaskMissionMenuEntityList item, int index) {
    return GuideAnchor(
      id: 'professional_mission_${item.type}',
      route: Routes.MISSION_CONTROL_CENTER,
      child: SizedBox(
        width: 200.wMin,
        child: Column(
          spacing: 6.wMin,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 88.wMin,
              height: 88.wMin,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  TapScaleWidget(
                    onTap: () {
                      widget.onTap?.call(context, item);
                    },
                    sclae: 1.03,
                    child: CachedImageWidget(
                      item.iconUrl ?? "",
                      width: 88.wMin,
                      height: 88.wMin,
                      fadeInDuration: Duration.zero,
                      placeholder: Container(),
                    ),
                  ),
                  Visibility(
                    visible: (item.taskCount ?? 0) > 0,
                    child: Positioned(
                      right: -16.wMin,
                      top: -16.wMin,
                      child: Container(
                        padding: EdgeInsets.all(6.wMin),
                        decoration: BoxDecoration(
                          color: AppTheme.cSurfaceError.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.cStaticWhite.color,
                            width: 2.wMin,
                          ),
                        ),
                        child: Text(
                          item.taskCount?.toString() ?? "0",
                          style: TextStyle(
                            fontSize: 22.wMin,
                            color: AppTheme.cStaticWhite.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              item.title ?? "",
              style: TextStyle(
                fontSize: 22.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
        
          ],
        ),
      ),
    );
  }
  
}