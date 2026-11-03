import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'zhenxie_paragraph_text_widget.dart';

/// 弹窗内单个拍位对应的展示数据。
class _ParagraphStepDetailsItemData {
  final String beatNid;
  final String? paragraphTypeNid;
  final ParagraphRhetoricalEntityList? rhetorical;
  final ArticleBlueprintEntityBlueprintsSlotsAllowedParagraphs? allowedParagraph;

  const _ParagraphStepDetailsItemData({
    required this.beatNid,
    this.paragraphTypeNid,
    this.rhetorical,
    this.allowedParagraph,
  });
}

/// 左侧评点区单个连续拍位片段的数据。
class _ParagraphCritiqueGroupData {
  final String beatNid;
  final String text;

  const _ParagraphCritiqueGroupData({
    required this.beatNid,
    required this.text,
  });
}

class ZhenxieParagraphStepDetailsDialog {
  static Future<void> show({
    required BuildContext context,
    required bool isManagement,
    required ZhenxieTaskDetailsEntity detailsData,
    required List<ParagraphRhetoricalEntityList> paragraphRhetoricalList,
    String? initBeatNid,
  }) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ZhenxieParagraphStepDetailsDialogWidget(
          isManagement: isManagement,
          detailsData: detailsData,
          paragraphRhetoricalList: paragraphRhetoricalList,
          initBeatNid: initBeatNid,
        );
      },
    );
  }
}

class ZhenxieParagraphStepDetailsDialogWidget extends StatefulWidget {
  final bool isManagement;
  final ZhenxieTaskDetailsEntity detailsData;
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;
  final String? initBeatNid;
  const ZhenxieParagraphStepDetailsDialogWidget({
    super.key,
    this.isManagement = false,
    required this.detailsData,
    required this.paragraphRhetoricalList,
    this.initBeatNid,
  });

  @override
  State<ZhenxieParagraphStepDetailsDialogWidget> createState() => _ZhenxieParagraphStepDetailsDialogWidgetState();
}

class _ZhenxieParagraphStepDetailsDialogWidgetState extends State<ZhenxieParagraphStepDetailsDialogWidget> {
  /// 当前弹窗里选中的拍位 nid。
  String? selectBeatNid;

  /// 统一的选中边框色。
  static const Color _selectedBorderColor = Color(0xffFB923C);

  @override
  void initState() {
    super.initState();
    _initSelectedBeatNid();
  }

  /// 初始化弹窗默认选中的拍位。
  void _initSelectedBeatNid() {
    final beatNidList = _usedBeatNidList;
    if (beatNidList.isEmpty) return;
    final initBeatNid = widget.initBeatNid;
    selectBeatNid = beatNidList.contains(initBeatNid) ? initBeatNid : beatNidList.first;
  }

  /// 当前弹窗展示的整段范文。
  ZhenxieTaskDetailsEntityParagraphInstance? get _dialogParagraph {
    final initBeatNid = widget.initBeatNid;
    if (initBeatNid?.isNotEmpty == true) {
      final member = _findMember(beatNid: initBeatNid!);
      final paragraph = _findParagraph(
        member?.paragraphId,
        beatNid: initBeatNid,
        paragraphTypeNid: member?.paragraphTypeNid,
      );
      if (paragraph != null) return paragraph;
    }
    final memberList = widget.detailsData.memberList ?? const <ZhenxieTaskDetailsEntityParagraphInstance?>[];
    for (final paragraph in memberList) {
      if (paragraph?.content?.isNotEmpty == true) return paragraph;
    }
    return null;
  }

  /// 当前段落实际用到的拍位列表，按正文中首次出现顺序排列。
  List<String> get _usedBeatNidList {
    final beatSpanList = _dialogParagraph?.beatSpans ?? const <ZhenxieTaskDetailsEntityParagraphBeatSpan?>[];
    final beatNidList = <String>[];
    for (final beatSpan in beatSpanList) {
      final beatNid = beatSpan?.beatNid;
      if (beatNid == null || beatNid.isEmpty || beatNidList.contains(beatNid)) continue;
      beatNidList.add(beatNid);
    }
    return beatNidList;
  }

  /// 当前弹窗右侧与正文共用的拍位数据列表。
  List<_ParagraphStepDetailsItemData> get _dialogItemList {
    final paragraph = _dialogParagraph;
    final beatNidList = _usedBeatNidList;
    final itemList = <_ParagraphStepDetailsItemData>[];
    for (final beatNid in beatNidList) {
      final rhetorical = widget.paragraphRhetoricalList.firstWhereOrNull((item) => item.nid == beatNid);
      itemList.add(
        _ParagraphStepDetailsItemData(
          beatNid: beatNid,
          paragraphTypeNid: paragraph?.paragraphTypeNid,
          rhetorical: rhetorical,
          allowedParagraph: _findAllowedParagraph(
            beatNid: beatNid,
            paragraphTypeNid: paragraph?.paragraphTypeNid,
          ),
        ),
      );
    }
    return itemList;
  }

  /// 转换正文高亮组件需要的拍位范围数据。
  List<ParagraphWritingGoalEntityBeatSpan?> get _paragraphBeatSpanList {
    final beatSpanList = _dialogParagraph?.beatSpans ?? const <ZhenxieTaskDetailsEntityParagraphBeatSpan?>[];
    return List.generate(beatSpanList.length, (index) {
      final beatSpan = beatSpanList[index];
      return ParagraphWritingGoalEntityBeatSpan(
        order: index,
        beatNid: beatSpan?.beatNid,
        start: beatSpan?.start,
        end: beatSpan?.end,
      );
    });
  }

  /// 转换正文高亮组件需要的知识点锚点数据。
  List<ParagraphWritingGoalEntityAnchor?> get _paragraphAnchorList {
    final anchorList = _dialogParagraph?.anchors ?? const <ZhenxieTaskDetailsEntityContentAnchor?>[];
    return List.generate(anchorList.length, (index) {
      final anchor = anchorList[index];
      return ParagraphWritingGoalEntityAnchor(
        contentType: anchor?.contentType,
        uid: anchor?.uid,
        semanticId: anchor?.semanticId,
        ranges: (anchor?.ranges ?? const <ZhenxieTaskDetailsEntitySurfaceRange?>[]).map((range) {
          return ParagraphWritingGoalEntityAnchorRange(
            start: range?.start,
            end: range?.end,
            text: range?.text,
          );
        }).toList(),
        foci: anchor?.foci?.map((item) => item?.toJson()).toList(),
      );
    });
  }

  /// 当前选中拍位对应的展示数据。
  _ParagraphStepDetailsItemData? get _currentItem {
    final itemList = _dialogItemList;
    if (itemList.isEmpty) return null;
    return itemList.firstWhereOrNull((item) => item.beatNid == selectBeatNid) ?? itemList.first;
  }

  /// 跳转到当前拍位对应的段落蓝图详情。
  Future<void> jumpToParagraphDetail() async {
    final paragraphTypeNid = _currentItem?.allowedParagraph?.paragraphTypeNid ?? _currentItem?.paragraphTypeNid;
    if (paragraphTypeNid == null) return;
    Get.back<void>();
    await TagRoutes.toNamed(
      Routes.ZHENXIE_PARAGRAPH_BLUEPRINT_DETAILS,
      arguments: {
        "nid": paragraphTypeNid,
        "isManagement": widget.isManagement,
      },
    );
  }

  /// 切换当前选中的拍位。
  void _switchBeat(String beatNid) {
    if (beatNid.isEmpty || selectBeatNid == beatNid) return;
    setState(() {
      selectBeatNid = beatNid;
    });
  }

  /// 查找当前拍位在文章蓝图里的段型说明。
  ArticleBlueprintEntityBlueprintsSlotsAllowedParagraphs? _findAllowedParagraph({
    required String beatNid,
    String? paragraphTypeNid,
  }) {
    final blueprintSlots = widget.detailsData.blueprint?.slots ?? const <ArticleBlueprintEntityBlueprintsSlots?>[];
    for (final blueprintSlot in blueprintSlots) {
      if (blueprintSlot?.beatNid != beatNid) continue;
      final allowedParagraphs = blueprintSlot?.allowedParagraphs ?? const <ArticleBlueprintEntityBlueprintsSlotsAllowedParagraphs?>[];
      final matched = allowedParagraphs.firstWhereOrNull((item) => item?.paragraphTypeNid == paragraphTypeNid);
      return matched ?? (allowedParagraphs.isNotEmpty ? allowedParagraphs.first : null);
    }
    return null;
  }

  /// 查找当前拍位对应的正文成员信息。
  ZhenxieTaskDetailsEntityMember? _findMember({
    required String beatNid,
    String? paragraphTypeNid,
  }) {
    final members = widget.detailsData.members ?? const <ZhenxieTaskDetailsEntityMember?>[];
    ZhenxieTaskDetailsEntityMember? fallback;
    for (final member in members) {
      if (member?.beatNid != beatNid) continue;
      fallback ??= member;
      if (paragraphTypeNid == null || member?.paragraphTypeNid == paragraphTypeNid) {
        return member;
      }
    }
    return fallback;
  }

  /// 根据段落 uid 或拍位信息查找范文正文。
  ZhenxieTaskDetailsEntityParagraphInstance? _findParagraph(
    int? paragraphId, {
    String? beatNid,
    String? paragraphTypeNid,
  }) {
    final memberList = widget.detailsData.memberList ?? const <ZhenxieTaskDetailsEntityParagraphInstance?>[];
    ZhenxieTaskDetailsEntityParagraphInstance? fallback;
    for (final paragraph in memberList) {
      if (paragraphId != null && (paragraph?.uid == paragraphId || paragraph?.paragraphId == paragraphId)) {
        return paragraph;
      }
      if (beatNid != null && paragraph?.beatNid == beatNid) {
        fallback ??= paragraph;
        if (paragraphTypeNid == null || paragraph?.paragraphTypeNid == paragraphTypeNid) {
          return paragraph;
        }
      }
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final dialogParagraph = _dialogParagraph;
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: Material(
        color: AppTheme.cOverlayBackground.color,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 1440.wMin,
              height: 800.wMin,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.wMin),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: double.infinity,
                      color: Color(0xffFFF7ED),
                      child: ZhenxieParagraphStepDetailsContentWidget(
                        content: dialogParagraph?.content ?? '',
                        isManagement: widget.isManagement,
                        selectBeatNid: selectBeatNid,
                        paragraphRhetoricalList: widget.paragraphRhetoricalList,
                        beatSpanList: _paragraphBeatSpanList,
                        anchors: _paragraphAnchorList,
                        onTapText: _switchBeat,
                      ),
                    ),
                  ),
                  _buildInfoWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建右侧拍位教学说明区。
  Widget _buildInfoWidget() {
    final itemList = _dialogItemList;
    return Container(
      width: 450.wMin,
      color: AppTheme.cSurfaceSecondary.color,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(32.wMin),
              child: Column(
                spacing: 24.wMin,
                children: List.generate(itemList.length, (index) {
                  return _buildInfoItemWidget(itemList[index]);
                }),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.centerRight,
            child: TapScaleWidget(
              onTap: () {
                jumpToParagraphDetail();
              },
              sclae: 1.05,
              child: Container(
                padding: EdgeInsets.all(32.wMin),
                color: Colors.transparent,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
          ),
        ],
      ),
    );
  }

  /// 构建右侧单个拍位说明卡片。
  Widget _buildInfoItemWidget(_ParagraphStepDetailsItemData item) {
    final bool selected = item.beatNid == selectBeatNid;
    return TapScaleWidget(
      onTap: () {
        _switchBeat(item.beatNid);
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.all(20.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase.color,
          borderRadius: BorderRadius.circular(20.wMin),
          border: Border.all(
            color: selected ? _selectedBorderColor : AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          spacing: 16.wMin,
          children: [
            _buildListItemTitleWidget(item),
            _buildListItemTextWidget(item),
          ],
        ),
      ),
    );
  }

  /// 构建右侧卡片标题。
  Widget _buildListItemTitleWidget(_ParagraphStepDetailsItemData item) {
    final rhetoricalName = LearningLangUtils.getLocalLang(item.rhetorical?.name);
    final rhetoricalGloss = LearningLangUtils.getLocalLang(item.rhetorical?.gloss);
    final primaryColor = item.rhetorical?.currentThemeColor?.colorValue ?? AppTheme.cTextPrimary.color;
    return Row(
      children: [
        SizedBox(
          width: 50.wMin,
          child: SuperpositionTextWidget(
            text: rhetoricalName?.text ?? '',
            foregroundColor: primaryColor.withValues(alpha: 0.55),
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ),
        Expanded(
          child: Text(
            rhetoricalName?.text ?? rhetoricalGloss?.text ?? '',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建右侧卡片说明文案。
  Widget _buildListItemTextWidget(_ParagraphStepDetailsItemData item) {
    final rhetoricalDescription = LearningLangUtils.getLocalLang(item.rhetorical?.description);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            rhetoricalDescription?.text ?? '',
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

class ZhenxieParagraphStepDetailsContentWidget extends StatefulWidget {
  /// 当前展示的范文正文。
  final String content;
  final bool isManagement;

  /// 当前选中的步骤 nid。
  final String? selectBeatNid;

  /// 段落拍位配置。
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;

  /// 当前段落的拍位切分数据。
  final List<ParagraphWritingGoalEntityBeatSpan?> beatSpanList;

  /// 当前段落的知识点锚点。
  final List<ParagraphWritingGoalEntityAnchor?>? anchors;

  /// 点击某个步骤文本后的回调。
  final void Function(String beatNid)? onTapText;
  const ZhenxieParagraphStepDetailsContentWidget({
    super.key,
    required this.content,
    this.isManagement = false,
    this.selectBeatNid,
    required this.paragraphRhetoricalList,
    required this.beatSpanList,
    required this.anchors,
    this.onTapText,
  });

  @override
  State<ZhenxieParagraphStepDetailsContentWidget> createState() => _ZhenxieParagraphStepDetailsContentWidgetState();
}

class _ZhenxieParagraphStepDetailsContentWidgetState extends State<ZhenxieParagraphStepDetailsContentWidget> {
  /// 左侧点评区的选中边框色。
  static const Color _selectedBorderColor = Color(0xff9A3412);

  /// 将连续的相同步骤文本合并成评点卡片数据。
  List<_ParagraphCritiqueGroupData> get _critiqueGroupList {
    final groupList = <_ParagraphCritiqueGroupData>[];
    for (final beatSpan in widget.beatSpanList) {
      final beatNid = beatSpan?.beatNid;
      final text = _findBeatText(beatSpan);
      if (beatNid == null || beatNid.isEmpty || text.isEmpty) continue;
      if (groupList.isNotEmpty && groupList.last.beatNid == beatNid) {
        final lastGroup = groupList.removeLast();
        groupList.add(_ParagraphCritiqueGroupData(
          beatNid: beatNid,
          text: '${lastGroup.text}$text',
        ));
        continue;
      }
      groupList.add(_ParagraphCritiqueGroupData(
        beatNid: beatNid,
        text: text,
      ));
    }
    return groupList;
  }

  /// 根据拍位范围从正文中截出当前评点文本。
  String _findBeatText(ParagraphWritingGoalEntityBeatSpan? beatSpan) {
    final start = beatSpan?.start;
    final end = beatSpan?.end;
    if (start == null || end == null) return '';
    if (start < 0 || end > widget.content.length || end <= start) return '';
    return widget.content.substring(start, end);
  }

  /// 根据拍位 nid 查找对应的修辞配置。
  ParagraphRhetoricalEntityList? _findRhetorical(String? beatNid) {
    if (beatNid == null || beatNid.isEmpty) return null;
    return widget.paragraphRhetoricalList.firstWhereOrNull((item) => item.nid == beatNid);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "默读",
              style: TextStyle(
                fontSize: 18.wMin,
                color: Colors.black.withValues(alpha: 0.5),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 16.wMin),
            _buildParagraphTextWidget(),
            SizedBox(height: 32.wMin),
            Text(
              "评点",
              style: TextStyle(
                fontSize: 18.wMin,
                color: Colors.black.withValues(alpha: 0.5),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 16.wMin),
            Column(
              spacing: 18.wMin,
              children: List.generate(_critiqueGroupList.length, (index) {
                return _buildStepItemWidget(_critiqueGroupList[index]);
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建左侧正文高亮区。
  Widget _buildParagraphTextWidget() {
    if (widget.content.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 48.wMin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.wMin),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.08),
            width: 1.wMin,
          ),
        ),
        child: Text(
          "暂无范文内容",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.wMin),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
          width: 1.wMin,
        ),
      ),
      child: ZhenxieParagraphTextWidget(
        content: widget.content,
        isManagement: widget.isManagement,
        selectBeatNid: widget.selectBeatNid,
        paragraphRhetoricalList: widget.paragraphRhetoricalList,
        beatSpanList: widget.beatSpanList,
        anchors: widget.anchors,
        onTapText: (beatNid) {
          if (beatNid.isEmpty) return;
          widget.onTapText?.call(beatNid);
        },
      ),
    );
  }

  /// 构建左侧单个点评卡片。
  Widget _buildStepItemWidget(_ParagraphCritiqueGroupData group) {
    final rhetorical = _findRhetorical(group.beatNid);
    final rhetoricalName = LearningLangUtils.getLocalLang(rhetorical?.name);
    final rhetoricalGloss = LearningLangUtils.getLocalLang(rhetorical?.gloss);
    final rhetoricalDescription = LearningLangUtils.getLocalLang(rhetorical?.description);
    final bool selected = group.beatNid == widget.selectBeatNid;
    return TapScaleWidget(
      onTap: () {
        widget.onTapText?.call(group.beatNid);
      },
      sclae: 1,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.wMin),
          color: Colors.white,
          border: Border.all(
            color: selected ? _selectedBorderColor : Colors.black.withValues(alpha: 0.1),
            width: 2.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48.wMin,
                  height: 48.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: rhetorical?.getThemeColor(AppThemeKey.light)?.colorValue,
                  ),
                  child: Text(
                    rhetoricalName?.text ?? '',
                    style: TextStyle(
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w500,
                      color: rhetorical?.getThemeColor(AppThemeKey.light)?.textColorValue,
                    ),
                  ),
                ),
                SizedBox(width: 6.wMin),
                Expanded(
                  child: Text(
                    rhetoricalName?.text ?? rhetoricalGloss?.text ?? '',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff131617),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.wMin),
            Text(
              group.text,
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                color: Color(0xff131617),
              ),
            ),
            SizedBox(height: 16.wMin),
            Text(
              rhetoricalDescription?.text ?? '',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: Color(0xff131617).withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
