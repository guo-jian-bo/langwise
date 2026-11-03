import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../theme/theme.dart';
import '../../../management/common/commons.dart';

/// 短语配对卡片：对齐 ui_ux React 的甄写纸面风格（衬线字体 + 纸面配色）。
/// 结构参考句型蓝图：竖排紧凑，教例块钉在卡片下半段。
class ZhenxiePhrasePairCardWidget extends StatelessWidget {
  final PhrasePairEntity data;
  final bool isManagement;
  final void Function()? onTap;

  const ZhenxiePhrasePairCardWidget({
    super.key,
    required this.data,
    this.onTap,
    this.isManagement = false,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1,
      backColor: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.06),
      borderRadius: 16.wMin,
      child: Container(
        padding: EdgeInsets.all(20.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cZhenxieBackgroundPrimary.color,
          border: Border.all(
            color: AppTheme.cZhenxieBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderWidget(),
            _buildTeachingWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWidget() {
    final name = LearningLangUtils.getLocalLang(data.name);
    final description = LearningLangUtils.getLocalLang(data.description);
    final int pairCount = data.pairCount ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      height: 8.wMin,
                      width: 8.wMin,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xffD9D9D9),
                      ),
                    ),
                    SizedBox(width: 6.wMin),
                    Text(
                      data.pairTypeNameZh ?? '',
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cZhenxieFontTertiary.color,
                        fontFamily: AppFontValue.sourceHanSerifCN,
                      ),
                    ),
                  ]),
                  SizedBox(height: 6.wMin),
                  Wrap(
                    spacing: 4.wMin,
                    runSpacing: 4.wMin,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        name?.text ?? '',
                        style: TextStyle(
                          fontSize: 26.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cZhenxieFontPrimary.color,
                          fontFamily: AppFontValue.sourceHanSerifCN,
                        ),
                      ),
                      CopyTagWidget(
                        name: "配对",
                        value: data.nid ?? '',
                        isShow: isManagement,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.wMin),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildTagWidget(tagText: _difficultyLabel()),
                SizedBox(height: 6.wMin),
                Text(
                  pairCount > 0 ? (data.relationDirection ?? '') : '待挑',
                  style: TextStyle(
                    fontSize: 15.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary.color,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.wMin),
        Text(
          description?.text ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontSecondary.color,
            fontFamily: AppFontValue.sourceHanSerifCN,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTeachingWidget() {
    final List<PhrasePairEntitySlots?> slots = data.slots ?? [];
    if (slots.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 16.wMin),
      padding: EdgeInsets.only(top: 16.wMin),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.cZhenxieBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.wMin,
        children: List.generate(slots.length, (index) {
          return _buildSlotWidget(slots[index]);
        }),
      ),
    );
  }

  Widget _buildSlotWidget(PhrasePairEntitySlots? slot) {
    final List<PhrasePairEntitySlotsMembers?> members = slot?.members ?? [];
    final PhrasePairEntitySlotsMembers? member =
        members.firstWhereOrNull((e) => e?.teaching == true) ?? (members.isNotEmpty ? members.first : null);
    final bool miss = member?.missFrom == true;
    final String surface = (member?.surface?.isNotEmpty == true) ? member!.surface! : '待挑';
    final bool isDim = member == null || member.draft == true || member.surface?.isNotEmpty != true;

    final Color surfaceColor =
        miss ? AppTheme.cZhenxieError.color : (isDim ? AppTheme.cZhenxieFontSecondary.color : AppTheme.cZhenxieFontPrimary.color);
    final Color labelColor = miss ? AppTheme.cZhenxieError.color : AppTheme.cZhenxieFontTertiary.color;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 76.wMin,
          child: Text(
            slot?.eyebrow ?? '',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: labelColor,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
        ),
        SizedBox(width: 12.wMin),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 4.wMin,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    surface,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w500,
                      color: surfaceColor,
                      fontFamily: AppFontValue.sourceHanSerifCN,
                    ),
                  ),
                  CopyTagWidget(
                    name: "短语",
                    value: member?.phraseId?.toString() ?? '',
                    isShow: isManagement && (member?.phraseId ?? 0) > 0,
                  ),
                ],
              ),
              if (member?.semanticBrief?.isNotEmpty == true) ...[
                SizedBox(height: 2.wMin),
                Text(
                  member!.semanticBrief!,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary.color,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _difficultyLabel() {
    final ConfigController configController = Get.find<ConfigController>();
    final DifficultieEntity? min = DifficultieUtils.getLanguageDifficultieLevel(
      configController.appConfig.value,
      "en",
      data.difficulty?.min,
    );
    final DifficultieEntity? max = DifficultieUtils.getLanguageDifficultieLevel(
      configController.appConfig.value,
      "en",
      data.difficulty?.max,
    );
    return "${min?.name?.text ?? ''} - ${max?.name?.text ?? ''}";
  }

  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cZhenxieFontTertiary,
    Color bgColor = AppTheme.cZhenxieBackgroundPrimary,
    Color borderColor = AppTheme.cZhenxieBorderPrimary,
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
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
        ],
      ),
    );
  }
}
