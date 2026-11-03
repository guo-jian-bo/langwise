import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../theme/theme.dart';
import '../../management/common/commons.dart';

class ZhenxiePhrasePairItemWidget extends StatelessWidget {
  final PhrasePairEntitySlots? slot;
  final bool isManagement;

  const ZhenxiePhrasePairItemWidget({
    super.key,
    required this.slot,
    this.isManagement = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<PhrasePairEntitySlotsMembers?> members = slot?.members ?? [];
    PhrasePairEntitySlotsMembers? current;
    if (members.isNotEmpty) {
      current = members.first;
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          border: Border.all(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.wMin),
              child: Row(
                children: [
                  Text(
                    slot?.eyebrow ?? '',
                    style: TextStyle(
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                  Spacer(),
                  Text(
                    "${slot?.members?.length ?? 0}条",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
            current?.phraseId == null ? _buildErrorWidget(current) : _buildCorrectWidget(current),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrectWidget(PhrasePairEntitySlotsMembers? current) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 4.wMin,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                current?.surface ?? '',
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              CopyTagWidget(
                name: "短语",
                value: current?.phraseId?.toString() ?? '',
                isShow: isManagement,
              ),
            ],
          ),
          SizedBox(height: 10.wMin),
          Text(
            current?.semanticBrief ?? '',
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(PhrasePairEntitySlotsMembers? current) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.wMin),
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceError.color.withValues(alpha: 0.1),
        border: Border.all(
          color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
          width: 1.wMin,
        ),
      ),
      child: Row(
        children: [
          _buildTagWidget(tagText: slot?.eyebrow ?? ''),
          Expanded(
            child: Text(
              current?.surface ?? '',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }) {
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: borderColor.withValues(alpha: 0.2),
          width: 0.5.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tagText,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
