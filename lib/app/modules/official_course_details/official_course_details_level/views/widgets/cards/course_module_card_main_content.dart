import 'package:flutter/material.dart';
import 'package:langwise/common/entities/theme_style_entity.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/color_utils.dart';
import 'package:langwise/utils/style_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/platform_backdrop_filter_widget.dart';

class CourseModuleCardMainContent extends StatelessWidget {
  final Widget cover;
  final String title;
  final String description;
  final List<ThemeTextEntity?>? tierMappings;
  final bool showStatusMask;
  final String statusMaskTitle;
  final Color? statusMaskTitleColor;

  const CourseModuleCardMainContent({
    super.key,
    required this.cover,
    required this.title,
    required this.description,
    this.tierMappings,
    this.showStatusMask = false,
    this.statusMaskTitle = '',
    this.statusMaskTitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cover,
            SizedBox(width: 16.wMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 32.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12.wMin),
                  if ((tierMappings?.isNotEmpty ?? false))
                    Wrap(
                      spacing: 6.wMin,
                      runSpacing: 6.wMin,
                      children: List.generate(
                        tierMappings?.length ?? 0,
                        (index) => _buildTagChip(tierMappings?[index]),
                      ),
                    ),
                  SizedBox(height: 10.wMin),
                  Expanded(
                    child: Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showStatusMask && statusMaskTitle.trim().isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cBlackAlpha50,
          
                ),
                alignment: Alignment.center,
                child: Text(
                  statusMaskTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 32.wMin,
                    color:
                        statusMaskTitleColor ?? AppTheme.cStaticWhite.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTagChip(ThemeTextEntity? themeTextEntity) {
    final ThemeTextStyleEntity? style =
        StyleUtils.getCurrentThemeText(themeTextEntity?.style);
    final Color baseColor =
        ColorUtils.parseColor(style?.color) ?? AppTheme.cTextPrimary.color;
    return Container(
      padding: EdgeInsets.all(4.wMin),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4.wMin),
        border: Border.all(
          color: baseColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        themeTextEntity?.text?.trim() ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: baseColor,
          fontSize: 14.wMin,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}
