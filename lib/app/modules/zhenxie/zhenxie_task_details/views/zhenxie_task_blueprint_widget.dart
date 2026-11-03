import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../common/widgets/zhenxie_widgets/article_blueprint_min_table_widget.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/model/writing_board_data.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/model/writing_board_frame_section_type.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/tag_routes.dart';

class ZhenxieTaskBlueprintWidget extends StatefulWidget {
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;
  final ZhenxieTaskDetailsEntity detailsData;
  final bool isManagement;
  final WritingBoardContentSourceMacro contentSource;
  final WritingBoardEditPolicyMacro editPolicy;
  final String? selectBeatNid;
  final WritingBoardFrameSectionType? highlightedFrameSection;
  final void Function(WritingBoardFrameSectionType type)? onTapFrameSection;
  final void Function(String beatNid)? onSelectBeatNid;
  const ZhenxieTaskBlueprintWidget({
    super.key,
    required this.paragraphRhetoricalList,
    required this.detailsData,
    this.isManagement = false,
    this.contentSource = WritingBoardContentSourceMacro.task,
    this.editPolicy = WritingBoardEditPolicyMacro.stageRule,
    this.selectBeatNid,
    this.highlightedFrameSection,
    this.onTapFrameSection,
    this.onSelectBeatNid,
  });

  @override
  State<ZhenxieTaskBlueprintWidget> createState() => _ZhenxieTaskBlueprintWidgetState();
}

class _ZhenxieTaskBlueprintWidgetState extends State<ZhenxieTaskBlueprintWidget> {
  /// 只有范文只读态允许点击蓝图框架区域做高亮联动。
  bool get _canTapFrameSection {
    return widget.contentSource == WritingBoardContentSourceMacro.exemplar && widget.editPolicy == WritingBoardEditPolicyMacro.readOnly;
  }

  /// 跳转至文章蓝图详情
  Future<void> jumpToArticleDetail() async {
    TagRoutes.toNamed(
      Routes.ZHENXIE_ARTICLE_BLUEPRINT_DETAILS,
      arguments: {
        "blueprintNid": widget.detailsData.blueprint?.nid,
        "isManagement": widget.isManagement,
      },
    );
  }

  /// 跳转至段落蓝图
  Future<void> jumpToParagraphDetail(ArticleBlueprintEntityBlueprintsSlotsAllowedParagraphs? allowedParagraph) async {
    final paragraphTypeNid = allowedParagraph?.paragraphTypeNid;
    if (paragraphTypeNid == null) return;

    TagRoutes.toNamed(
      Routes.ZHENXIE_PARAGRAPH_BLUEPRINT_DETAILS,
      arguments: {
        "nid": paragraphTypeNid,
        "isManagement": widget.isManagement,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final slots = _currentTaskBlueprintSlots;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 18.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBlueprintWidget(),
          SizedBox(height: 18.wMin),
          Column(
            spacing: 18.wMin,
            children: List.generate(slots.length, (index) {
              return _buildListItemWidget(slots[index]);
            }),
          ),
        ],
      ),
    );
  }

  /// 构建当前任务实际使用的文章蓝图拍位列表。
  List<ArticleBlueprintEntityBlueprintsSlots> get _currentTaskBlueprintSlots {
    final blueprintSlots = widget.detailsData.blueprint?.slots ?? [];
    final stageSlots = widget.detailsData.stage?.slots ?? [];
    final currentSlots = <ArticleBlueprintEntityBlueprintsSlots>[];
    for (final blueprintSlot in blueprintSlots) {
      final stageSlot = stageSlots.firstWhereOrNull((e) => e?.beatNid == blueprintSlot?.beatNid);
      if (stageSlot == null || stageSlot.fill == 'hidden') continue;
      final allowedParagraph = blueprintSlot?.allowedParagraphs?.firstWhereOrNull((e) {
        return e?.paragraphTypeNid == stageSlot.paragraphTypeNid;
      });
      currentSlots.add(
        ArticleBlueprintEntityBlueprintsSlots(
          order: blueprintSlot?.order,
          beatNid: blueprintSlot?.beatNid,
          required: blueprintSlot?.required,
          repeatMin: blueprintSlot?.repeatMin,
          repeatMax: blueprintSlot?.repeatMax,
          allowedParagraphs: allowedParagraph != null ? [allowedParagraph] : const [],
        ),
      );
    }
    return currentSlots;
  }

  Widget _buildInfoBlueprintWidget() {
    final description = LearningLangUtils.getLocalLang(widget.detailsData.blueprint?.description);
    return Container(
      padding: EdgeInsets.all(4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(color: AppTheme.cBorderSubtle.color, width: 0.8.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 12.wMin),
              Expanded(
                child: Text(
                  description?.text ?? '',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
              ),
              TapScaleWidget(
                onTap: () {
                  jumpToArticleDetail();
                },
                sclae: 1.05,
                child: Container(
                  padding: EdgeInsets.all(12.wMin),
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Text(
                        "文章蓝图",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w500,
                          color: Color(0xffFB923C),
                        ),
                      ),
                      SvgPicture.asset(
                        "assets/svg/public/icon_w_arrow_right.svg",
                        width: 20.wMin,
                        colorFilter: ColorFilter.mode(Color(0xffFB923C), BlendMode.srcIn),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cSurfaceBg.color,
              border: Border.all(color: AppTheme.cBorderDefault.color, width: 1.wMin),
            ),
            child: ArticleBlueprintMinMinTableWidget(
              paragraphRhetoricalList: widget.paragraphRhetoricalList.toList(),
              slots: _currentTaskBlueprintSlots,
              frame: widget.detailsData.blueprint?.frame,
              selectBeatNid: widget.selectBeatNid,
              highlightedFrameSection: widget.highlightedFrameSection,
              onTapFrameSection: _canTapFrameSection ? widget.onTapFrameSection : null,
              onSelectBeatNid: (nid) {
                widget.onSelectBeatNid?.call(nid ?? "");
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItemWidget(ArticleBlueprintEntityBlueprintsSlots? slot) {
    String slotNid = slot?.beatNid ?? "";
    bool selected = slotNid == widget.selectBeatNid;
    return TapScaleWidget(
      onTap: () {
        widget.onSelectBeatNid?.call(slotNid);
      },
      sclae: 1,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(20.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: selected ? Color(0xffFB923C) : AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          spacing: 12.wMin,
          children: [
            _buildListItemTitleWidget(slot),
            _buildListItemTextWidget(slot),
          ],
        ),
      ),
    );
  }

  Widget _buildListItemTitleWidget(ArticleBlueprintEntityBlueprintsSlots? slot) {
    String slotNid = slot?.beatNid ?? "";
    final step = widget.paragraphRhetoricalList.firstWhereOrNull((e) => slotNid == e.nid);
    final stageSlot = widget.detailsData.stage?.slots?.firstWhereOrNull((e) => e?.beatNid == slotNid);
    final allowedParagraph = slot?.allowedParagraphs?.firstWhereOrNull((e) {
      return e?.paragraphTypeNid == stageSlot?.paragraphTypeNid;
    });
    final stepName = LearningLangUtils.getLocalLang(step?.name);
    final paragraphTypeName = LearningLangUtils.getLocalLang(
      allowedParagraph?.paragraphType?.name ?? stageSlot?.paragraphType?.name,
    )?.text;
    final usageName = LearningLangUtils.getLocalLang(allowedParagraph?.usageName)?.text ?? "";
    final titleText = [paragraphTypeName, usageName].where((e) => e?.isNotEmpty ?? false).join(' · ');
    Color colorValue = step?.currentThemeColor?.colorValue ?? AppTheme.cSurfaceBrand.color;

    return Row(
      children: [
        SizedBox(
          width: 50.wMin,
          child: Text(
            stepName?.text ?? '',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: colorValue,
            ),
          ),
        ),
        Expanded(
          child: Text(
            titleText,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ),
        TapScaleWidget(
          onTap: () {
            jumpToParagraphDetail(allowedParagraph);
          },
          sclae: 1.05,
          child: Container(
            padding: EdgeInsets.all(2.wMin),
            color: Colors.transparent,
            child: Row(
              children: [
                Text(
                  "段落蓝图",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w500,
                    color: Color(0xffFB923C),
                  ),
                ),
                SvgPicture.asset(
                  "assets/svg/public/icon_w_arrow_right.svg",
                  width: 20.wMin,
                  colorFilter: ColorFilter.mode(Color(0xffFB923C), BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListItemTextWidget(ArticleBlueprintEntityBlueprintsSlots? slot) {
    final slotNid = slot?.beatNid ?? "";
    final stageSlot = widget.detailsData.stage?.slots?.firstWhereOrNull((e) => e?.beatNid == slotNid);
    final allowedParagraph = slot?.allowedParagraphs?.firstWhereOrNull((e) {
      return e?.paragraphTypeNid == stageSlot?.paragraphTypeNid;
    });
    final usageDescription = LearningLangUtils.getLocalLang(allowedParagraph?.usageDescription)?.text ?? "";
    final paragraphDescription = LearningLangUtils.getLocalLang(
      allowedParagraph?.paragraphType?.description ?? stageSlot?.paragraphType?.description,
    )?.text;
    final contentText = usageDescription.isNotEmpty ? usageDescription : paragraphDescription;

    return Row(
      children: [
        SizedBox(
          width: 50.wMin,
          child: Text(
            "教学",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ),
        Expanded(
          child: Text(
            contentText ?? "",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ),
      ],
    );
  }
}
