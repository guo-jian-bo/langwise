import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../theme/theme.dart';
import '../../management/common/commons.dart';

class ZhenxiePhraseMatchItemWidget extends StatelessWidget {
  final PhraseMatchEntitySlots? slot;
  final bool isManagement;

  const ZhenxiePhraseMatchItemWidget({
    super.key,
    required this.slot,
    this.isManagement = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<PhraseMatchEntitySlotsMembers?> members = slot?.members ?? [];
    final PhraseMatchEntitySlotsMembers? current =
        members.firstWhereOrNull((element) => element?.catalogMemberNid == slot?.eyebrowNid);

    return Container(
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
                  slot?.role == "anchor" ? "锚点" : "教例槽",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),
                SizedBox(width: 6.wMin),
                CopyTagWidget(
                  name: "成员",
                  value: slot?.eyebrowNid ?? '',
                  isShow: isManagement,
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
          current?.phraseId == null ? _buildErrorWidget() : _buildCorrectWidget(current),
        ],
      ),
    );
  }

  Widget _buildCorrectWidget(PhraseMatchEntitySlotsMembers? current) {
    return Container(
      padding: EdgeInsets.all(16.wMin),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 4.wMin,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                slot?.teachingExample ?? '',
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

  Widget _buildErrorWidget() {
    return Container(
      margin: EdgeInsets.all(16.wMin),
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
        border: Border.all(
          color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
          width: 1.wMin,
        ),
      ),
      child: Row(
        children: [
          _buildTagWidget(tagText: "待挑"),
          Expanded(
            child: Text(
              slot?.teachingExample ?? '',
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
