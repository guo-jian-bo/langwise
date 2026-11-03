import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../theme/theme.dart';
import '../../../utils/utils.dart';
import '../../entities/entities.dart';
import '../../enum/enum.dart';
import '../widgets.dart';
import 'paragraph_rhetorical_widget.dart';

class ZhenxieParagraphBlueprintOverviewTableWidget extends StatefulWidget {
  /// 段落修辞步骤元数据，用于渲染顶部圆点、连线和每拍信息。
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;

  /// 段型摘要预览对应的槽位列表。
  final List<ParagraphBlueprintEntityBlueprintsSlots?>? slotList;

  /// 当前写作目标中已落到正文的拍位范围，用于控制禁用和透明度。
  final List<ParagraphWritingGoalEntityBeatSpan?>? beatSpanList;

  /// 当前选中的拍位 nid，用于高亮当前卡片。
  final String? selectNid;

  /// 点击单个拍位卡片时的回调。
  final void Function(String nid)? onTap;

  const ZhenxieParagraphBlueprintOverviewTableWidget({
    super.key,
    required this.paragraphRhetoricalList,
    required this.slotList,
    this.beatSpanList,
    this.selectNid,
    this.onTap,
  });

  @override
  State<ZhenxieParagraphBlueprintOverviewTableWidget> createState() => _ZhenxieParagraphBlueprintOverviewTableWidgetState();
}

class _ZhenxieParagraphBlueprintOverviewTableWidgetState extends State<ZhenxieParagraphBlueprintOverviewTableWidget> {
  @override
  Widget build(BuildContext context) {
    final List<ParagraphBlueprintEntityBlueprintsSlots?> slots = widget.slotList ?? [];

    return ParagraphRhetoricalContainerWidget(
      paragraphRhetoricalList: widget.paragraphRhetoricalList.toList(),
      statusList: List.generate(widget.paragraphRhetoricalList.length, (index) {
        final slot = slots.firstWhereOrNull((e) => e?.beatNid == widget.paragraphRhetoricalList[index].nid);
        return ParagraphRhetoricalContainerData(
          status: slot?.statusEnum ?? ParagraphRhetoricalStatusEnum.empty,
          beatNid: widget.paragraphRhetoricalList[index].nid,
        );
      }),
      statusItemWidgetBuilder: (status, paragraphRhetorical, index) {
        final slot = slots.firstWhereOrNull((e) => e?.beatNid == widget.paragraphRhetoricalList[index].nid);
        return _buildItemContentCardWidget(
          status: status,
          paragraphRhetorical: paragraphRhetorical,
          slot: slot,
        );
      },
    );
  }

  /// 摘要卡片优先使用当前主题色配置。
  Color _getPrimaryColor(ParagraphRhetoricalEntityList? paragraphRhetorical, {required Color fallbackColor}) {
    return paragraphRhetorical?.currentThemeColor?.colorValue ?? fallbackColor;
  }

  /// 构建段型卡片里的摘要格子，和 Web overview 视觉保持一致。
  Widget _buildItemContentCardWidget({
    required ParagraphRhetoricalContainerData status,
    ParagraphRhetoricalEntityList? paragraphRhetorical,
    ParagraphBlueprintEntityBlueprintsSlots? slot,
  }) {
    final bool isOptional = status.status == ParagraphRhetoricalStatusEnum.optional;
    final bool isEmpty = status.status == ParagraphRhetoricalStatusEnum.empty;
    bool isDotted = isOptional || isEmpty;
    final Color primaryColor = _getPrimaryColor(paragraphRhetorical, fallbackColor: AppTheme.cInverseOverlay5.color);
    Color borderColor = primaryColor.withValues(alpha: 0.3);
    List<Color> bgColors = [
      primaryColor.withValues(alpha: 0.2),
      primaryColor.withValues(alpha: 0.08),
    ];
    Color titleColor = AppTheme.cTextPrimary.color;
    Color subTitleColor = AppTheme.cTextTertiary.color;

    if (isOptional) {
      borderColor = primaryColor.withValues(alpha: 0.3);
      bgColors = [AppTheme.cSurfaceLayerBase.color, AppTheme.cSurfaceLayerBase.color];
      titleColor = AppTheme.cTextPrimary.color;
      subTitleColor = AppTheme.cTextTertiary.color;
    } else if (isEmpty) {
      borderColor = AppTheme.cBorderDark.color;
      bgColors = [AppTheme.cSurfaceLayerBase.color, AppTheme.cSurfaceLayerBase.color];
      titleColor = AppTheme.cTextPrimary.color.withValues(alpha: 0.6);
      subTitleColor = AppTheme.cTextTertiary.color;
    }

    final jobName = LearningLangUtils.getLocalLang(slot?.jobName);

    int repeatMin = slot?.repeatMin ?? 0;
    int repeatMax = slot?.repeatMax ?? 0;
    String repeatCount = "$repeatMin-$repeatMax句";
    if (repeatMin == repeatMax) {
      repeatCount = "$repeatMin句";
    }

    final beatSpan = widget.beatSpanList?.firstWhereOrNull((element) => element?.beatNid == status.beatNid);
    if (widget.selectNid == status.beatNid) {
      borderColor = AppTheme.cWritePrimary.color;
      isDotted = false;
    }

    return IgnorePointer(
      ignoring: (widget.beatSpanList != null && beatSpan == null) || widget.onTap == null,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 4.wMin),
        padding: EdgeInsets.symmetric(horizontal: 8.wMin),
        child: TapScaleWidget(
          onTap: () {
            widget.onTap?.call(status.beatNid ?? "");
          },
          sclae: widget.onTap == null ? 1 : 1.01,
          child: DottedBorder(
            color: borderColor,
            strokeWidth: 1.5.wMin,
            dashPattern: [5.wMin, isDotted ? 3.wMin : 0],
            borderType: BorderType.RRect,
            radius: Radius.circular(16.0.wMin),
            padding: EdgeInsets.zero,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.wMin),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: bgColors,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        jobName?.text ?? '',
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w500,
                          color: titleColor,
                        ),
                      ),
                      SizedBox(height: 4.wMin),
                      Text(
                        repeatCount,
                        style: TextStyle(
                          fontSize: 14.wMin,
                          fontWeight: FontWeight.w400,
                          color: subTitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -18.wMin,
                  child: Visibility(
                    visible: status.status == ParagraphRhetoricalStatusEnum.empty,
                    child: Transform.rotate(
                      angle: 0.7,
                      child: Container(
                        width: 12.wMin,
                        height: 110.wMin,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.cInverseGray.color.withValues(alpha: 0.15),
                              AppTheme.cInverseGray.color.withValues(alpha: 0.3),
                              AppTheme.cInverseGray.color.withValues(alpha: 0.15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
