import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../common/widgets/zhenxie_widgets/paragraph_rhetorical_widget.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/tag_routes.dart';
import '../../../management/common/commons.dart';

class ZhenxieParagraphBlueprintDetailsCardWidget extends StatefulWidget {
  final ParagraphBlueprintEntityBlueprints? data;
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;
  final bool isManagement;
  const ZhenxieParagraphBlueprintDetailsCardWidget({
    super.key,
    required this.data,
    required this.paragraphRhetoricalList,
    this.isManagement = false,
  });

  @override
  State<ZhenxieParagraphBlueprintDetailsCardWidget> createState() => _ZhenxieParagraphBlueprintDetailsCardWidgetState();
}

class _ZhenxieParagraphBlueprintDetailsCardWidgetState extends State<ZhenxieParagraphBlueprintDetailsCardWidget> {
  /// 优先使用当前主题的拍位主色，避免继续依赖旧的顶层 color 字段。
  Color _getPrimaryColor(ParagraphRhetoricalEntityList? paragraphRhetorical, {required Color fallbackColor}) {
    return paragraphRhetorical?.currentThemeColor?.colorValue ?? fallbackColor;
  }

  /// 跳转至句子蓝图列表
  Future<void> _toToSentenceBlueprintList(ParagraphBlueprintEntityBlueprintsSlotOption? slotOption) async {
    if (slotOption?.nid == null) return;
    await TagRoutes.toNamed(
      Routes.ZHENXIE_PATTERN_BLUEPRINT,
      arguments: {
        "isManagement": widget.isManagement,
        "filterFamilyNids": slotOption?.nid == null ? null : [slotOption?.nid ?? ''],
      },
    );
  }

  /// 跳转至句间配链列表
  Future<void> _toToSentencePairList(ParagraphBlueprintEntityBlueprintsSlotOption? slotOption) async {
    if (slotOption?.nid == null) return;
    await TagRoutes.toNamed(
      Routes.ZHENXIE_SENTENCE_PAIR,
      arguments: {
        "isManagement": widget.isManagement,
        "filterPairTypeNids": slotOption?.nid == null ? null : [slotOption?.nid ?? ''],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) return Container();
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        borderRadius: BorderRadius.circular(20.wMin),
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 0.8.wMin,
        ),
      ),
      child: Column(
        children: [
          _buildItemTitleWidget(),
          SizedBox(height: 16.wMin),
          _buildItemContentWidget(),
        ],
      ),
    );
  }

  Widget _buildItemTitleWidget() {
    final name = LearningLangUtils.getLocalLang(widget.data?.name);
    final description = LearningLangUtils.getLocalLang(widget.data?.description);
    int minSentenceCount = widget.data?.minSentenceCount ?? 0;
    int maxSentenceCount = widget.data?.maxSentenceCount ?? 0;
    String showCount = "$minSentenceCount-$maxSentenceCount句";
    if (minSentenceCount == maxSentenceCount) {
      showCount = "$minSentenceCount句";
    }

    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 8.wMin,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                name?.text ?? '',
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cZhenxieFontPrimary.color,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                ),
              ),
              Text(
                description?.text ?? '',
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontTertiary.color,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                ),
              ),
            ],
          ),
        ),
        _buildTagWidget(
          tagText: showCount,
        ),
        SizedBox(width: 4.wMin),
        _buildTagWidget(
          tagText: "L${widget.data?.difficulty?.min ?? 0}-L${widget.data?.difficulty?.max ?? 0}",
        ),
        Visibility(
          visible: widget.isManagement,
          child: Container(
            margin: EdgeInsets.only(left: 4.wMin),
            child: CopyTagWidget(
              name: "蓝图",
              value: widget.data?.nid ?? '',
              isShow: widget.isManagement,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemContentWidget() {
    List<ParagraphBlueprintEntityBlueprintsSlots?> slots = widget.data?.slotList ?? [];

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

  Widget _buildItemContentCardWidget({
    required ParagraphRhetoricalContainerData status,
    ParagraphRhetoricalEntityList? paragraphRhetorical,
    ParagraphBlueprintEntityBlueprintsSlots? slot,
  }) {
    final bool isOptional = status.status == ParagraphRhetoricalStatusEnum.optional;
    final bool isEmpty = status.status == ParagraphRhetoricalStatusEnum.empty;
    final bool isDotted = isOptional || isEmpty;
    final Color primaryColor = _getPrimaryColor(paragraphRhetorical, fallbackColor: AppTheme.cSurfaceLayerBase.color);
    Color borderColor = primaryColor.withValues(alpha: 0.6);
    List<Color> bgColors = [
      primaryColor.withValues(alpha: 0.2),
      primaryColor.withValues(alpha: 0.08),
    ];
    Color titleColor = AppTheme.cTextPrimary.color;
    Color descriptionColor = AppTheme.cTextPrimary.color;
    Color repeatCountColor = AppTheme.cTextTertiary.color;
    if (isOptional) {
      bgColors = [AppTheme.cSurfaceLayerBase.color, AppTheme.cSurfaceLayerBase.color];
    } else if (isEmpty) {
      borderColor = AppTheme.cBorderDark.color;
      bgColors = [AppTheme.cSurfaceLayerBase.color, AppTheme.cSurfaceLayerBase.color];
      titleColor = AppTheme.cTextPrimary.color.withValues(alpha: 0.6);
      descriptionColor = AppTheme.cTextPrimary.color.withValues(alpha: 0.6);
      repeatCountColor = AppTheme.cTextTertiary.color;
    }

    final jobName = LearningLangUtils.getLocalLang(slot?.jobName);

    return Container(
      margin: EdgeInsets.only(left: 8.wMin, right: 8.wMin, top: 8.wMin),
      child: DottedBorder(
        color: borderColor,
        strokeWidth: 1.wMin,
        dashPattern: [5.wMin, isDotted ? 3.wMin : 0],
        borderType: BorderType.RRect,
        radius: Radius.circular(16.0.wMin),
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.wMin),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 512.wMin,
                padding: EdgeInsets.all(6.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: bgColors,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.wMin),
                      child: Text(
                        jobName?.text ?? '',
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w500,
                          color: titleColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildItemContentCardBodyWidget(
                        status: status,
                        slot: slot,
                        descriptionColor: descriptionColor,
                        repeatCountColor: repeatCountColor,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -140.wMin,
                child: Visibility(
                  visible: isEmpty,
                  child: Transform.rotate(
                    angle: 0.67,
                    child: Container(
                      width: 16.wMin,
                      height: 800.wMin,
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
    );
  }

  Widget _buildItemContentCardBodyWidget({
    required ParagraphRhetoricalContainerData status,
    ParagraphBlueprintEntityBlueprintsSlots? slot,
    required Color descriptionColor,
    required Color repeatCountColor,
  }) {
    final jobDescription = LearningLangUtils.getLocalLang(slot?.jobDescription);
    List<ParagraphBlueprintEntityBlueprintsSlotOption?> allowedFamilies = slot?.allowedFamilies ?? [];
    ParagraphBlueprintEntityBlueprintsSlotOption? allowedPairTypeToNext = slot?.allowedPairTypeToNext;

    int repeatMin = slot?.repeatMin ?? 0;
    int repeatMax = slot?.repeatMax ?? 0;
    String repeatCount = "$repeatMin-$repeatMax句";
    if (repeatMin == repeatMax) {
      repeatCount = "$repeatMin句";
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.wMin),
            child: Text(
              jobDescription?.text ?? '',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: descriptionColor,
              ),
            ),
          ),
          Container(
            height: 1.wMin,
            color: AppTheme.cBorderDefault.color,
            margin: EdgeInsets.symmetric(horizontal: 16.wMin),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16.wMin,
                children: [
                  _buildItemContentCardBodyItemsWidget(
                    title: "拍内",
                    items: allowedFamilies,
                  ),
                  Visibility(
                    visible: allowedPairTypeToNext != null,
                    child: _buildItemContentCardBodyItemsWidget(
                      title: "拍间过渡",
                      items: [allowedPairTypeToNext],
                      isPairType: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 1.wMin,
            color: AppTheme.cBorderDefault.color,
            margin: EdgeInsets.symmetric(horizontal: 16.wMin),
          ),
          Container(
            padding: EdgeInsets.all(16.wMin),
            child: Text(
              repeatCount,
              style: TextStyle(
                fontSize: 14.wMin,
                fontWeight: FontWeight.w400,
                color: repeatCountColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemContentCardBodyItemsWidget({
    required String title,
    required List<ParagraphBlueprintEntityBlueprintsSlotOption?> items,
    bool isPairType = false,
  }) {
    if (items.isEmpty) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
        SizedBox(height: 10.wMin),
        Wrap(
          spacing: 6.wMin,
          runSpacing: 6.wMin,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: List.generate(items.length, (index) {
            final name = LearningLangUtils.getLocalLang(items[index]?.name);
            return ButtonWidget(
              text: name?.text ?? '',
              alignment: null,
              padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
              borderRadius: 99,
              color: AppTheme.cSurfaceLayerElevated.color,
              border: Border.all(
                color: AppTheme.cBorderSubtle.color,
                width: 0.8.wMin,
              ),
              fontSize: 18.wMin,
              fontColor: AppTheme.cTextSecondary.color,
              sclae: 1.03,
              rightIcon: SvgPicture.asset(
                "assets/svg/public/icon_w_arrow_right.svg",
                width: 20.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
              ),
              onTap: () {
                if (isPairType) {
                  _toToSentencePairList(items[index]);
                } else {
                  _toToSentenceBlueprintList(items[index]);
                }
              },
            );
          }),
        ),
      ],
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
