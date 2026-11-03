import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../theme/theme.dart';
import '../../management/common/commons.dart';

class ZhenxiePhraseContrastItemWidget extends StatelessWidget {
  final PhraseParadigmEntitySlots? slot;
  final bool isManagement;

  const ZhenxiePhraseContrastItemWidget({
    super.key,
    required this.slot,
    this.isManagement = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<PhraseParadigmEntitySlotsMembers?> members = slot?.members ?? [];
    final PhraseParadigmEntitySlotsMembers? current =
        members.firstWhereOrNull((element) => element?.eyebrowNid == slot?.eyebrowNid);

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
                  slot?.eyebrow ?? '',
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),
                SizedBox(width: 6.wMin),
                CopyTagWidget(
                  name: "轨值",
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
          Container(
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
                  slot?.eyebrowDescription ?? '',
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
