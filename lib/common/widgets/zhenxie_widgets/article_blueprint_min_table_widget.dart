import 'dart:math';
import 'dart:ui' show Tangent;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../entities/entities.dart';
import '../../enum/enum.dart';
import 'writing_boards/model/writing_board_frame_section_type.dart';
import 'paragraph_rhetorical_widget.dart';

class CourseBlueprintTableWidget extends StatefulWidget {
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;
  final KnowledgeCommonEntityListParamsData data;
  const CourseBlueprintTableWidget({
    super.key,
    required this.paragraphRhetoricalList,
    required this.data,
  });

  @override
  State<CourseBlueprintTableWidget> createState() => _CourseBlueprintTableWidgetState();
}

class _CourseBlueprintTableWidgetState extends State<CourseBlueprintTableWidget> {
  /// 承载整块路径区域的根节点，用于把卡片坐标转换成画布内坐标。
  final GlobalKey _pathRootKey = GlobalKey();

  /// 每张候选段型卡片的测量锚点，供连线层读取真实位置。
  final Map<String, GlobalKey> _pathNodeKeyMap = {};

  /// 当前已经计算好的连线路径布局。
  List<_ArticleBlueprintPathLayout> _pathLayouts = [];

  /// 避免同一帧里重复调度坐标测量。
  bool _isPathMeasureScheduled = false;

  /// 记录最近一次参与布局的宽度，宽度变化时需要重新测量。
  double? _lastPathLayoutWidth;

  /// 将课程目标里的 slots 转成蓝图表格通用槽位结构。
  List<ArticleBlueprintEntityBlueprintsSlots> get _blueprintSlots {
    final currentSlots = <ArticleBlueprintEntityBlueprintsSlots>[];
    for (final slot in widget.data.slots ?? const <KnowledgeCommonEntityListParamsDataSlot?>[]) {
      if (slot?.fill == 'hidden' || slot?.beatNid?.isEmpty != false) continue;
      currentSlots.add(
        ArticleBlueprintEntityBlueprintsSlots(
          order: slot?.order,
          beatNid: slot?.beatNid,
          required: true,
          repeatMin: slot?.paragraphType == null ? 0 : 1,
          repeatMax: slot?.paragraphType == null ? 0 : 1,
          allowedParagraphs: slot?.paragraphType == null
              ? const []
              : [
                  ArticleBlueprintEntityBlueprintsSlotsAllowedParagraphs(
                    paragraphTypeNid: slot?.paragraphTypeNid,
                    paragraphType: slot?.paragraphType,
                  ),
                ],
        ),
      );
    }
    return currentSlots;
  }

  /// 将课程文首文尾配置转换成表格组件可直接使用的 frame 数据。
  ArticleBlueprintEntityBlueprintsFrame? get _blueprintFrame {
    return ArticleBlueprintEntityBlueprintsFrame(
      hasHead: widget.data.hasHead == true && widget.data.headFill == true,
      hasTail: widget.data.hasTail == true && widget.data.tailFill == true,
      hasHeadings: false,
      headName: widget.data.headName,
      tailName: widget.data.tailName,
    );
  }

  @override
  void initState() {
    super.initState();
    _schedulePathMeasure();
  }

  @override
  void didUpdateWidget(covariant CourseBlueprintTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _schedulePathMeasure();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: _blueprintFrame?.hasHead == true,
          child: _buildFistLastWidget(
            type: "文首格式",
            nameList: _blueprintFrame?.headName,
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            if (_lastPathLayoutWidth != constraints.maxWidth) {
              _lastPathLayoutWidth = constraints.maxWidth;
              _schedulePathMeasure();
            }

            return Stack(
              key: _pathRootKey,
              children: [
                _buildRhetoricalBodyWidget(),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ArticleBlueprintPathPainter(
                        layouts: _pathLayouts,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        Visibility(
          visible: _blueprintFrame?.hasTail == true,
          child: Container(
            alignment: Alignment.centerRight,
            child: _buildFistLastWidget(
              type: "文尾格式",
              nameList: _blueprintFrame?.tailName,
              isFist: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRhetoricalBodyWidget() {
    final slots = _blueprintSlots;
    return ParagraphRhetoricalContainerWidget(
      paragraphRhetoricalList: widget.paragraphRhetoricalList.toList(),
      statusList: List.generate(widget.paragraphRhetoricalList.length, (index) {
        final slot = slots.firstWhereOrNull((e) => e.beatNid == widget.paragraphRhetoricalList[index].nid);
        return ParagraphRhetoricalContainerData(
          status: slot?.statusEnum ?? ParagraphRhetoricalStatusEnum.empty,
          beatNid: widget.paragraphRhetoricalList[index].nid,
        );
      }),
      statusItemWidgetBuilder: (status, paragraphRhetorical, index) {
        final slot = slots.firstWhereOrNull((e) => e.beatNid == widget.paragraphRhetoricalList[index].nid);

        int maxLength = 0;
        for (final element in slots) {
          maxLength = max(maxLength, element.allowedParagraphs?.length ?? 0);
        }

        return Container(
          margin: EdgeInsets.only(left: 4.wMin, right: 4.wMin, top: 16.wMin),
          child: _buildItemContentWidget(
            paragraphRhetorical: widget.paragraphRhetoricalList[index],
            slot: slot,
            maxLength: maxLength,
          ),
        );
      },
    );
  }

  Widget _buildFistLastWidget({
    required String type,
    required List<LanguageText?>? nameList,
    bool isFist = true,
  }) {
    final name = LearningLangUtils.getLocalLang(nameList);
    return Container(
      margin: EdgeInsets.only(
        bottom: isFist ? 10.wMin : 0,
        top: !isFist ? 10.wMin : 0,
      ),
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: const Color(0xffCCBCB8).withValues(alpha: 0.12),
        border: Border.all(
          color: const Color(0xffCCBCB8).withValues(alpha: 0.12),
          width: 1.wMin,
        ),
      ),
      constraints: BoxConstraints(
        minWidth: 82.wMin,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.wMin,
        children: [
          Text(
            type,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: const Color(0xffCCBCB8),
            ),
          ),
          Text(
            name?.text ?? '',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemContentWidget({
    required ParagraphRhetoricalEntityList paragraphRhetorical,
    ArticleBlueprintEntityBlueprintsSlots? slot,
    required int maxLength,
  }) {
    final safeLength = max(maxLength, 1);
    final allHeight = safeLength * 64.wMin + (safeLength - 1) * 36.wMin;
    final allowedParagraphs = slot?.allowedParagraphs ?? [];

    if (allowedParagraphs.isEmpty) {
      return Container(
        height: allHeight,
        alignment: Alignment.center,
        child: _buildItemContentItemWidget(
          paragraphRhetorical: paragraphRhetorical,
          statusEnum: slot?.statusEnum ?? ParagraphRhetoricalStatusEnum.empty,
          item: null,
          repeatText: _buildRepeatText(slot),
        ),
      );
    }

    return Container(
      height: allHeight,
      alignment: Alignment.center,
      child: ListView.separated(
        itemCount: allowedParagraphs.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) {
          return Container(
            alignment: Alignment.center,
            height: 36.wMin,
            child: Text(
              "或",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          );
        },
        itemBuilder: (context, index) {
          final nodeId = ArticleBlueprintTableUtils.buildPathNodeId(
            beatNid: paragraphRhetorical.nid,
            paragraphTypeNid: allowedParagraphs[index]?.paragraphTypeNid,
            itemIndex: index,
          );
          return Container(
            key: ArticleBlueprintTableUtils.pathNodeKeyFor(_pathNodeKeyMap, nodeId),
            child: _buildItemContentItemWidget(
              paragraphRhetorical: paragraphRhetorical,
              statusEnum: slot?.statusEnum ?? ParagraphRhetoricalStatusEnum.empty,
              item: allowedParagraphs[index],
              repeatText: _buildRepeatText(slot),
            ),
          );
        },
      ),
    );
  }

  /// 课程蓝图当前仅支持单段槽位，这里统一输出展示文案。
  String _buildRepeatText(ArticleBlueprintEntityBlueprintsSlots? slot) {
    final repeatMin = slot?.repeatMin ?? 0;
    final repeatMax = slot?.repeatMax ?? 0;
    if (repeatMin == repeatMax) return "$repeatMin段";
    return "$repeatMin-$repeatMax段";
  }

  Widget _buildItemContentItemWidget({
    required ParagraphRhetoricalEntityList paragraphRhetorical,
    required ParagraphRhetoricalStatusEnum statusEnum,
    required String repeatText,
    ArticleBlueprintEntityBlueprintsSlotsAllowedParagraphs? item,
  }) {
    bool isDotted = statusEnum == ParagraphRhetoricalStatusEnum.optional || statusEnum == ParagraphRhetoricalStatusEnum.empty;
    Color primaryColor = paragraphRhetorical.currentThemeColor?.colorValue ?? AppTheme.cInverseOverlay5.color;
    Color borderColor = primaryColor.withValues(alpha: 0.3);
    List<Color> bgColors = [primaryColor.withValues(alpha: 0.2), primaryColor.withValues(alpha: 0.08)];
    if (statusEnum == ParagraphRhetoricalStatusEnum.optional) {
      borderColor = primaryColor.withValues(alpha: 0.3);
      bgColors = [AppTheme.cSurfaceLayerBase.color, AppTheme.cSurfaceLayerBase.color];
    } else if (statusEnum == ParagraphRhetoricalStatusEnum.empty) {
      borderColor = AppTheme.cBorderDark.color;
      bgColors = [AppTheme.cSurfaceLayerBase.color, AppTheme.cSurfaceLayerBase.color];
    }

    final name = LearningLangUtils.getLocalLang(item?.paragraphType?.name);

    return Container(
      width: double.infinity,
      height: 64.wMin,
      padding: EdgeInsets.symmetric(horizontal: 4.wMin),
      child: DottedBorder(
        color: borderColor,
        strokeWidth: 1.wMin,
        dashPattern: [5.wMin, isDotted ? 3.wMin : 0],
        borderType: BorderType.RRect,
        radius: Radius.circular(10.0.wMin),
        padding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.wMin),
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
                    name?.text ?? '',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                  SizedBox(height: 2.wMin),
                  Text(
                    repeatText,
                    style: TextStyle(
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -18.wMin,
              child: Visibility(
                visible: statusEnum == ParagraphRhetoricalStatusEnum.empty,
                child: Transform.rotate(
                  angle: 0.7,
                  child: Container(
                    width: 12.wMin,
                    height: 120.wMin,
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
    );
  }

  /// 在布局稳定后读取卡片坐标，生成本次需要绘制的连线布局。
  void _schedulePathMeasure() {
    if (_isPathMeasureScheduled) return;
    _isPathMeasureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isPathMeasureScheduled = false;
      _measurePathLayouts();
    });
  }

  /// 读取当前卡片的真实位置，并按篇章蓝图路径规则生成 forward / bypass 连线。
  void _measurePathLayouts() {
    final nextLayouts = ArticleBlueprintTableUtils._measurePathLayouts(
      pathRootKey: _pathRootKey,
      pathNodeKeyMap: _pathNodeKeyMap,
      paragraphRhetoricalList: widget.paragraphRhetoricalList,
      slots: _blueprintSlots,
    );
    if (ArticleBlueprintTableUtils._isSamePathLayouts(_pathLayouts, nextLayouts)) return;
    setState(() {
      _pathLayouts = nextLayouts;
    });
  }
}

class ArticleBlueprintMinMinTableWidget extends StatefulWidget {
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;
  final List<ArticleBlueprintEntityBlueprintsSlots?> slots;
  final ArticleBlueprintEntityBlueprintsFrame? frame;
  final String? selectBeatNid;
  final WritingBoardFrameSectionType? highlightedFrameSection;
  final void Function(WritingBoardFrameSectionType type)? onTapFrameSection;
  final void Function(String? nid)? onSelectBeatNid;
  const ArticleBlueprintMinMinTableWidget({
    super.key,
    required this.paragraphRhetoricalList,
    required this.slots,
    this.frame,
    this.selectBeatNid,
    this.highlightedFrameSection,
    this.onTapFrameSection,
    this.onSelectBeatNid,
  });

  @override
  State<ArticleBlueprintMinMinTableWidget> createState() => _ArticleBlueprintMinMinTableWidgetState();
}

class _ArticleBlueprintMinMinTableWidgetState extends State<ArticleBlueprintMinMinTableWidget> {
  /// 承载整块路径区域的根节点，用于把卡片坐标转换成画布内坐标。
  final GlobalKey _pathRootKey = GlobalKey();

  /// 每张候选段型卡片的测量锚点，供连线层读取真实位置。
  final Map<String, GlobalKey> _pathNodeKeyMap = {};

  /// 当前已经计算好的连线路径布局。
  List<_ArticleBlueprintPathLayout> _pathLayouts = [];

  /// 避免同一帧里重复调度坐标测量。
  bool _isPathMeasureScheduled = false;

  /// 记录最近一次参与布局的宽度，宽度变化时需要重新测量。
  double? _lastPathLayoutWidth;

  @override
  void initState() {
    super.initState();
    _schedulePathMeasure();
  }

  @override
  void didUpdateWidget(covariant ArticleBlueprintMinMinTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _schedulePathMeasure();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: widget.frame?.hasHead == true,
          child: _buildFistLastWidget(
            type: "文首格式",
            nameList: widget.frame?.headName,
            sectionType: WritingBoardFrameSectionType.head,
          ),
        ),
        _buildHeadingsHintWidget(),
        LayoutBuilder(
          builder: (context, constraints) {
            if (_lastPathLayoutWidth != constraints.maxWidth) {
              _lastPathLayoutWidth = constraints.maxWidth;
              _schedulePathMeasure();
            }

            return Stack(
              key: _pathRootKey,
              children: [
                _buildRhetoricalBodyWidget(),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ArticleBlueprintPathPainter(
                        layouts: _pathLayouts,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        Visibility(
          visible: widget.frame?.hasTail == true,
          child: Container(
            alignment: Alignment.centerRight,
            child: _buildFistLastWidget(
              type: "文尾格式",
              nameList: widget.frame?.tailName,
              sectionType: WritingBoardFrameSectionType.tail,
              isFist: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRhetoricalBodyWidget() {
    return ParagraphRhetoricalContainerWidget(
      paragraphRhetoricalList: widget.paragraphRhetoricalList.toList(),
      statusList: List.generate(widget.paragraphRhetoricalList.length, (index) {
        final slot = widget.slots.firstWhereOrNull((e) => e?.beatNid == widget.paragraphRhetoricalList[index].nid);
        return ParagraphRhetoricalContainerData(
          status: slot?.statusEnum ?? ParagraphRhetoricalStatusEnum.empty,
          beatNid: widget.paragraphRhetoricalList[index].nid,
        );
      }),
      statusItemWidgetBuilder: (status, paragraphRhetorical, index) {
        final slot = widget.slots.firstWhereOrNull((e) => e?.beatNid == widget.paragraphRhetoricalList[index].nid);
        final currentLength = slot?.allowedParagraphs?.length ?? 0;

        return Container(
          margin: EdgeInsets.only(left: 4.wMin, right: 4.wMin, top: 4.wMin),
          child: _buildItemContentWidget(
            paragraphRhetorical: widget.paragraphRhetoricalList[index],
            slot: slot,
            maxLength: currentLength,
          ),
        );
      },
    );
  }

  Widget _buildFistLastWidget({
    required String type,
    required List<LanguageText?>? nameList,
    required WritingBoardFrameSectionType sectionType,
    bool isFist = true,
  }) {
    final name = LearningLangUtils.getLocalLang(nameList);
    return _buildBlueprintFrameSectionCard(
      type: type,
      title: name?.text ?? '',
      highlighted: widget.highlightedFrameSection == sectionType,
      margin: EdgeInsets.only(
        bottom: isFist ? 10.wMin : 0,
        top: !isFist ? 10.wMin : 0,
      ),
      onTap: widget.onTapFrameSection == null ? null : () => widget.onTapFrameSection?.call(sectionType),
    );
  }

  Widget _buildHeadingsHintWidget() {
    if (widget.frame?.hasHeadings != true) return Container();
    final highlighted = widget.highlightedFrameSection == WritingBoardFrameSectionType.headings;
    return TapScaleWidget(
      onTap: widget.onTapFrameSection == null ? null : () => widget.onTapFrameSection?.call(WritingBoardFrameSectionType.headings),
      sclae: 1,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.wMin),
        padding: EdgeInsets.symmetric(horizontal: 2.wMin),
        color: Colors.transparent,
        child: Text(
          "正文里可以加小标题",
          style: TextStyle(
            fontSize: 13.wMin,
            fontWeight: FontWeight.w400,
            color: highlighted ? Color(0xffFB923C) : Color(0xffFDE68A).withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildItemContentWidget({
    required ParagraphRhetoricalEntityList paragraphRhetorical,
    ArticleBlueprintEntityBlueprintsSlots? slot,
    required int maxLength,
  }) {
    final safeLength = max(maxLength, 1);
    double allHeight = safeLength * 44.wMin + (safeLength - 1) * 36.wMin;
    final allowedParagraphs = slot?.allowedParagraphs ?? [];

    if (allowedParagraphs.isEmpty) {
      return Container(
        height: allHeight,
        alignment: Alignment.center,
        child: _buildItemContentItemWidget(
          paragraphRhetorical: paragraphRhetorical,
          statusEnum: slot?.statusEnum ?? ParagraphRhetoricalStatusEnum.empty,
          item: null,
        ),
      );
    }

    return Container(
      height: allHeight,
      alignment: Alignment.center,
      child: ListView.separated(
        itemCount: allowedParagraphs.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) {
          return Container(
            alignment: Alignment.center,
            height: 36.wMin,
            child: Text(
              "或",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          );
        },
        itemBuilder: (context, index) {
          final nodeId = ArticleBlueprintTableUtils.buildPathNodeId(
            beatNid: paragraphRhetorical.nid,
            paragraphTypeNid: allowedParagraphs[index]?.paragraphTypeNid,
            itemIndex: index,
          );
          return Container(
            key: ArticleBlueprintTableUtils.pathNodeKeyFor(_pathNodeKeyMap, nodeId),
            child: _buildItemContentItemWidget(
              paragraphRhetorical: paragraphRhetorical,
              statusEnum: slot?.statusEnum ?? ParagraphRhetoricalStatusEnum.empty,
              item: allowedParagraphs[index],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemContentItemWidget({
    required ParagraphRhetoricalEntityList paragraphRhetorical,
    required ParagraphRhetoricalStatusEnum statusEnum,
    ArticleBlueprintEntityBlueprintsSlotsAllowedParagraphs? item,
  }) {
    bool isDotted = statusEnum == ParagraphRhetoricalStatusEnum.optional || statusEnum == ParagraphRhetoricalStatusEnum.empty;
    Color primaryColor = paragraphRhetorical.currentThemeColor?.colorValue ?? AppTheme.cInverseOverlay5.color;
    Color borderColor = primaryColor.withValues(alpha: 0.3);
    List<Color> bgColors = [primaryColor.withValues(alpha: 0.2), primaryColor.withValues(alpha: 0.08)];
    Color titleColor = AppTheme.cTextPrimary.color;
    if (statusEnum == ParagraphRhetoricalStatusEnum.optional) {
      borderColor = primaryColor.withValues(alpha: 0.3);
      bgColors = [AppTheme.cSurfaceLayerBase.color, AppTheme.cSurfaceLayerBase.color];
    } else if (statusEnum == ParagraphRhetoricalStatusEnum.empty) {
      borderColor = AppTheme.cBorderDark.color;
      bgColors = [AppTheme.cSurfaceLayerBase.color, AppTheme.cSurfaceLayerBase.color];
    }

    final name = LearningLangUtils.getLocalLang(item?.paragraphType?.name);

    bool isSelected = widget.selectBeatNid == paragraphRhetorical.nid;
    if (isSelected) {
      borderColor = Color(0xffFB923C);
    }

    return IgnorePointer(
      ignoring: statusEnum == ParagraphRhetoricalStatusEnum.empty,
      child: TapScaleWidget(
        onTap: () {
          widget.onSelectBeatNid?.call(paragraphRhetorical.nid);
        },
        sclae: 1.03,
        child: Container(
          width: double.infinity,
          height: 44.wMin,
          padding: EdgeInsets.symmetric(horizontal: 4.wMin),
          child: DottedBorder(
            color: borderColor,
            strokeWidth: 1.wMin,
            dashPattern: [5.wMin, isDotted && !isSelected ? 3.wMin : 0],
            borderType: BorderType.RRect,
            radius: Radius.circular(10.0.wMin),
            padding: EdgeInsets.zero,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.wMin),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: bgColors,
                    ),
                  ),
                  child: Text(
                    name?.text ?? '',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                ),
                Positioned(
                  top: -18.wMin,
                  child: Visibility(
                    visible: statusEnum == ParagraphRhetoricalStatusEnum.empty,
                    child: Transform.rotate(
                      angle: 0.7,
                      child: Container(
                        width: 12.wMin,
                        height: 100.wMin,
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

  /// 在布局稳定后读取卡片坐标，生成本次需要绘制的连线布局。
  void _schedulePathMeasure() {
    if (_isPathMeasureScheduled) return;
    _isPathMeasureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isPathMeasureScheduled = false;
      _measurePathLayouts();
    });
  }

  /// 读取当前卡片的真实位置，并按篇章蓝图路径规则生成 forward / bypass 连线。
  void _measurePathLayouts() {
    final List<_ArticleBlueprintPathLayout> nextLayouts = ArticleBlueprintTableUtils._measurePathLayouts(
      pathRootKey: _pathRootKey,
      pathNodeKeyMap: _pathNodeKeyMap,
      paragraphRhetoricalList: widget.paragraphRhetoricalList,
      slots: widget.slots,
    );
    if (ArticleBlueprintTableUtils._isSamePathLayouts(_pathLayouts, nextLayouts)) return;
    setState(() {
      _pathLayouts = nextLayouts;
    });
  }

  Color _blueprintFrameSectionBorderColor(bool highlighted) {
    return const Color(0xffCCBCB8).withValues(alpha: highlighted ? 1 : 0.12);
  }

  Color _blueprintFrameSectionBackgroundColor(bool highlighted) {
    return const Color(0xffCCBCB8).withValues(alpha: highlighted ? 0.2 : 0.12);
  }

  Widget _buildBlueprintFrameSectionCard({
    required String type,
    required String title,
    required bool highlighted,
    EdgeInsetsGeometry? margin,
    double minWidth = 82,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: margin,
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: _blueprintFrameSectionBackgroundColor(highlighted),
          border: Border.all(
            color: _blueprintFrameSectionBorderColor(highlighted),
            width: 1.wMin,
          ),
        ),
        constraints: BoxConstraints(
          minWidth: minWidth.wMin,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.wMin,
          children: [
            Text(
              type,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: const Color(0xffCCBCB8),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleBlueprintMinTableWidget extends StatefulWidget {
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;
  final List<ArticleBlueprintEntityBlueprintsSlots?> slots;
  final ArticleBlueprintEntityBlueprintsFrame? frame;
  const ArticleBlueprintMinTableWidget({
    super.key,
    required this.paragraphRhetoricalList,
    required this.slots,
    this.frame,
  });

  @override
  State<ArticleBlueprintMinTableWidget> createState() => _ArticleBlueprintMinTableWidgetState();
}

class _ArticleBlueprintMinTableWidgetState extends State<ArticleBlueprintMinTableWidget> {
  /// 承载整块路径区域的根节点，用于把卡片坐标转换成画布内坐标。
  final GlobalKey _pathRootKey = GlobalKey();

  /// 每张候选段型卡片的测量锚点，供连线层读取真实位置。
  final Map<String, GlobalKey> _pathNodeKeyMap = {};

  /// 当前已经计算好的连线路径布局。
  List<_ArticleBlueprintPathLayout> _pathLayouts = [];

  /// 避免同一帧里重复调度坐标测量。
  bool _isPathMeasureScheduled = false;

  /// 记录最近一次参与布局的宽度，宽度变化时需要重新测量。
  double? _lastPathLayoutWidth;

  @override
  void initState() {
    super.initState();
    _schedulePathMeasure();
  }

  @override
  void didUpdateWidget(covariant ArticleBlueprintMinTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _schedulePathMeasure();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: widget.frame?.hasHead == true,
          child: _buildFistLastWidget(type: "文首格式", nameList: widget.frame?.headName),
        ),
        _buildHasHeadingsWidget(),
        LayoutBuilder(
          builder: (context, constraints) {
            if (_lastPathLayoutWidth != constraints.maxWidth) {
              _lastPathLayoutWidth = constraints.maxWidth;
              _schedulePathMeasure();
            }

            return Stack(
              key: _pathRootKey,
              children: [
                _buildRhetoricalBodyWidget(),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ArticleBlueprintPathPainter(
                        layouts: _pathLayouts,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        Visibility(
          visible: widget.frame?.hasTail == true,
          child: Container(
            alignment: Alignment.centerRight,
            child: _buildFistLastWidget(
              type: "文尾格式",
              nameList: widget.frame?.tailName,
              isFist: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRhetoricalBodyWidget() {
    return ParagraphRhetoricalContainerWidget(
      paragraphRhetoricalList: widget.paragraphRhetoricalList.toList(),
      statusList: List.generate(widget.paragraphRhetoricalList.length, (index) {
        final slot = widget.slots.firstWhereOrNull((e) => e?.beatNid == widget.paragraphRhetoricalList[index].nid);
        return ParagraphRhetoricalContainerData(
          status: slot?.statusEnum ?? ParagraphRhetoricalStatusEnum.empty,
          beatNid: widget.paragraphRhetoricalList[index].nid,
        );
      }),
      statusItemWidgetBuilder: (status, paragraphRhetorical, index) {
        final slot = widget.slots.firstWhereOrNull((e) => e?.beatNid == widget.paragraphRhetoricalList[index].nid);
        int repeatMin = slot?.repeatMin ?? 0;
        int repeatMax = slot?.repeatMax ?? 0;
        String repeatText = "$repeatMin-$repeatMax";
        if (repeatMin == repeatMax) {
          repeatText = "$repeatMin";
        }

        int maxLength = 0;
        for (var element in widget.slots) {
          maxLength = max(maxLength, element?.allowedParagraphs?.length ?? 0);
        }

        return Column(
          children: [
            Text(
              "$repeatText段",
              style: TextStyle(
                fontSize: 14.wMin,
                fontWeight: FontWeight.w400,
                color: repeatMax == 0 ? AppTheme.cTextTertiary.color : AppTheme.cTextSecondary.color,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 4.wMin, right: 4.wMin, top: 10.wMin),
              child: _buildItemContentWidget(
                paragraphRhetorical: widget.paragraphRhetoricalList[index],
                slot: slot,
                maxLength: maxLength,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFistLastWidget({
    required String type,
    required List<LanguageText?>? nameList,
    bool isFist = true,
  }) {
    final name = LearningLangUtils.getLocalLang(nameList);
    return Container(
      margin: EdgeInsets.only(
        bottom: isFist ? 10.wMin : 0,
        top: !isFist ? 10.wMin : 0,
      ),
      padding: EdgeInsets.all(10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: Color(0xffCCBCB8).withValues(alpha: 0.12),
        border: Border.all(
          color: Color(0xffCCBCB8).withValues(alpha: 0.12),
          width: 1.5.wMin,
        ),
      ),
      constraints: BoxConstraints(
        minWidth: isFist ? 290.wMin : 82.wMin,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.wMin,
        children: [
          Text(
            type,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: Color(0xffCCBCB8),
            ),
          ),
          Text(
            name?.text ?? '',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHasHeadingsWidget() {
    if (widget.frame?.hasHeadings != true) return Container();
    return Container(
      margin: EdgeInsets.only(bottom: 10.wMin),
      child: Text(
        "正文里可以加小标题",
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cSurfaceSuccess.color,
        ),
      ),
    );
  }

  Widget _buildItemContentWidget({
    required ParagraphRhetoricalEntityList paragraphRhetorical,
    ArticleBlueprintEntityBlueprintsSlots? slot,
    required int maxLength,
  }) {
    final safeLength = max(maxLength, 1);
    double allHeight = safeLength * 70.wMin + (safeLength - 1) * 30.wMin;
    final allowedParagraphs = slot?.allowedParagraphs ?? [];

    if (allowedParagraphs.isEmpty) {
      return Container(
        height: allHeight,
        alignment: Alignment.center,
        child: _buildItemContentItemWidget(
          paragraphRhetorical: paragraphRhetorical,
          statusEnum: slot?.statusEnum ?? ParagraphRhetoricalStatusEnum.empty,
          item: null,
        ),
      );
    }

    return Container(
      height: allHeight,
      alignment: Alignment.center,
      child: ListView.separated(
        itemCount: allowedParagraphs.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) {
          return Container(
            alignment: Alignment.center,
            height: 30.wMin,
            child: Text(
              "或",
              style: TextStyle(
                fontSize: 14.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          );
        },
        itemBuilder: (context, index) {
          final nodeId = ArticleBlueprintTableUtils.buildPathNodeId(
            beatNid: paragraphRhetorical.nid,
            paragraphTypeNid: allowedParagraphs[index]?.paragraphTypeNid,
            itemIndex: index,
          );
          return Container(
            key: ArticleBlueprintTableUtils.pathNodeKeyFor(_pathNodeKeyMap, nodeId),
            child: _buildItemContentItemWidget(
              paragraphRhetorical: paragraphRhetorical,
              statusEnum: slot?.statusEnum ?? ParagraphRhetoricalStatusEnum.empty,
              item: allowedParagraphs[index],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemContentItemWidget({
    required ParagraphRhetoricalEntityList paragraphRhetorical,
    required ParagraphRhetoricalStatusEnum statusEnum,
    ArticleBlueprintEntityBlueprintsSlotsAllowedParagraphs? item,
  }) {
    bool isDotted = statusEnum == ParagraphRhetoricalStatusEnum.optional || statusEnum == ParagraphRhetoricalStatusEnum.empty;
    Color primaryColor = paragraphRhetorical.currentThemeColor?.colorValue ?? AppTheme.cInverseOverlay5.color;
    Color borderColor = primaryColor.withValues(alpha: 0.6);
    List<Color> bgColors = [primaryColor.withValues(alpha: 0.2), primaryColor.withValues(alpha: 0.08)];
    Color titleColor = AppTheme.cTextPrimary.color;
    Color subTitleColor = AppTheme.cTextTertiary.color;
    if (statusEnum == ParagraphRhetoricalStatusEnum.optional) {
      borderColor = primaryColor.withValues(alpha: 0.6);
      bgColors = [AppTheme.cSurfaceLayerBase.color, AppTheme.cSurfaceLayerBase.color];
    } else if (statusEnum == ParagraphRhetoricalStatusEnum.empty) {
      borderColor = AppTheme.cBorderDark.color;
      bgColors = [AppTheme.cSurfaceLayerBase.color, AppTheme.cSurfaceLayerBase.color];
    }

    final name = LearningLangUtils.getLocalLang(item?.paragraphType?.name);
    final usageName = LearningLangUtils.getLocalLang(item?.usageName);

    return Container(
      width: double.infinity,
      height: 70.wMin,
      padding: EdgeInsets.symmetric(horizontal: 8.wMin),
      child: DottedBorder(
        color: borderColor,
        strokeWidth: 1.wMin,
        dashPattern: [5.wMin, isDotted ? 3.wMin : 0],
        borderType: BorderType.RRect,
        radius: Radius.circular(16.0.wMin),
        padding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
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
                    name?.text ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: 4.wMin),
                  Text(
                    usageName?.text ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
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
                visible: statusEnum == ParagraphRhetoricalStatusEnum.empty,
                child: Transform.rotate(
                  angle: 0.7,
                  child: Container(
                    width: 12.wMin,
                    height: 130.wMin,
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
    );
  }

  /// 在布局稳定后读取卡片坐标，生成本次需要绘制的连线布局。
  void _schedulePathMeasure() {
    if (_isPathMeasureScheduled) return;
    _isPathMeasureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isPathMeasureScheduled = false;
      _measurePathLayouts();
    });
  }

  /// 读取当前卡片的真实位置，并按篇章蓝图路径规则生成 forward / bypass 连线。
  void _measurePathLayouts() {
    final List<_ArticleBlueprintPathLayout> nextLayouts = ArticleBlueprintTableUtils._measurePathLayouts(
      pathRootKey: _pathRootKey,
      pathNodeKeyMap: _pathNodeKeyMap,
      paragraphRhetoricalList: widget.paragraphRhetoricalList,
      slots: widget.slots,
    );
    if (ArticleBlueprintTableUtils._isSamePathLayouts(_pathLayouts, nextLayouts)) return;
    _pathLayouts = nextLayouts;
    if(mounted) setState(() {});
  }
}

class ArticleBlueprintMaxTableWidget extends StatefulWidget {
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;
  final List<ArticleBlueprintEntityBlueprintsSlots?> slots;
  final ArticleBlueprintEntityBlueprintsFrame? frame;
  final void Function(ArticleBlueprintEntityBlueprintsSlotsAllowedParagraphs? paragraphs)? onTapParagraph;
  const ArticleBlueprintMaxTableWidget({
    super.key,
    required this.paragraphRhetoricalList,
    required this.slots,
    this.frame,
    this.onTapParagraph,
  });

  @override
  State<ArticleBlueprintMaxTableWidget> createState() => _ArticleBlueprintMaxTableWidgetState();
}

class _ArticleBlueprintMaxTableWidgetState extends State<ArticleBlueprintMaxTableWidget> {
  /// 承载整块路径区域的根节点，用于把卡片坐标转换成画布内坐标。
  final GlobalKey _pathRootKey = GlobalKey();

  /// 每张候选段型卡片的测量锚点，供连线层读取真实位置。
  final Map<String, GlobalKey> _pathNodeKeyMap = {};

  /// 当前已经计算好的连线路径布局。
  List<_ArticleBlueprintPathLayout> _pathLayouts = [];

  /// 避免同一帧里重复调度坐标测量。
  bool _isPathMeasureScheduled = false;

  /// 记录最近一次参与布局的宽度，宽度变化时需要重新测量。
  double? _lastPathLayoutWidth;

  @override
  void initState() {
    super.initState();
    _schedulePathMeasure();
  }

  @override
  void didUpdateWidget(covariant ArticleBlueprintMaxTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _schedulePathMeasure();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: widget.frame?.hasHead == true,
          child: _buildFistLastWidget(
            type: "文首格式",
            nameList: widget.frame?.headName,
            descriptionList: widget.frame?.headDescription,
          ),
        ),
        _buildHasHeadingsWidget(),
        LayoutBuilder(
          builder: (context, constraints) {
            if (_lastPathLayoutWidth != constraints.maxWidth) {
              _lastPathLayoutWidth = constraints.maxWidth;
              _schedulePathMeasure();
            }

            return Stack(
              key: _pathRootKey,
              children: [
                _buildRhetoricalBodyWidget(),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ArticleBlueprintPathPainter(
                        layouts: _pathLayouts,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        Visibility(
          visible: widget.frame?.hasTail == true,
          child: Container(
            alignment: Alignment.centerRight,
            child: _buildFistLastWidget(
              type: "文尾格式",
              nameList: widget.frame?.tailName,
              descriptionList: widget.frame?.tailDescription,
              isFist: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRhetoricalBodyWidget() {
    return ParagraphRhetoricalContainerWidget(
      paragraphRhetoricalList: widget.paragraphRhetoricalList.toList(),
      statusList: List.generate(widget.paragraphRhetoricalList.length, (index) {
        final slot = widget.slots.firstWhereOrNull((e) => e?.beatNid == widget.paragraphRhetoricalList[index].nid);
        return ParagraphRhetoricalContainerData(
          status: slot?.statusEnum ?? ParagraphRhetoricalStatusEnum.empty,
          beatNid: widget.paragraphRhetoricalList[index].nid,
        );
      }),
      statusItemWidgetBuilder: (status, paragraphRhetorical, index) {
        final slot = widget.slots.firstWhereOrNull((e) => e?.beatNid == widget.paragraphRhetoricalList[index].nid);
        int repeatMin = slot?.repeatMin ?? 0;
        int repeatMax = slot?.repeatMax ?? 0;
        String repeatText = "$repeatMin-$repeatMax";
        if (repeatMin == repeatMax) {
          repeatText = "$repeatMin";
        }

        int maxLength = 0;
        for (var element in widget.slots) {
          maxLength = max(maxLength, element?.allowedParagraphs?.length ?? 0);
        }

        return Column(
          children: [
            Text(
              "$repeatText段",
              style: TextStyle(
                fontSize: 14.wMin,
                fontWeight: FontWeight.w400,
                color: repeatMax == 0 ? AppTheme.cTextTertiary.color : AppTheme.cTextSecondary.color,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 16.wMin, right: 16.wMin, top: 16.wMin),
              child: _buildItemContentWidget(
                paragraphRhetorical: widget.paragraphRhetoricalList[index],
                slot: slot,
                maxLength: maxLength,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFistLastWidget({
    required String type,
    required List<LanguageText?>? nameList,
    required List<LanguageText?>? descriptionList,
    bool isFist = true,
  }) {
    final name = LearningLangUtils.getLocalLang(nameList);
    final description = LearningLangUtils.getLocalLang(descriptionList);

    return Container(
      margin: EdgeInsets.only(
        bottom: isFist ? 16.wMin : 0,
        top: !isFist ? 16.wMin : 0,
      ),
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: Color(0xffCCBCB8).withValues(alpha: 0.12),
        border: Border.all(
          color: Color(0xffCCBCB8).withValues(alpha: 0.12),
          width: 1.5.wMin,
        ),
      ),
      constraints: BoxConstraints(
        minWidth: isFist ? 290.wMin : 82.wMin,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.wMin,
        children: [
          Text(
            type,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: Color(0xffCCBCB8),
            ),
          ),
          Text(
            name?.text ?? '',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          Text(
            description?.text ?? '',
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHasHeadingsWidget() {
    if (widget.frame?.hasHeadings != true) return Container();
    return Container(
      margin: EdgeInsets.only(bottom: 10.wMin),
      child: Text(
        "正文里可以加小标题",
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cSurfaceSuccess.color,
        ),
      ),
    );
  }

  Widget _buildItemContentWidget({
    required ParagraphRhetoricalEntityList paragraphRhetorical,
    ArticleBlueprintEntityBlueprintsSlots? slot,
    required int maxLength,
  }) {
    final safeLength = max(maxLength, 1);
    double allHeight = safeLength * 180.wMin + (safeLength - 1) * 36.wMin;
    final allowedParagraphs = slot?.allowedParagraphs ?? [];

    if (allowedParagraphs.isEmpty) {
      return Container(
        height: allHeight,
        alignment: Alignment.center,
        child: _buildItemContentItemWidget(
          paragraphRhetorical: paragraphRhetorical,
          statusEnum: slot?.statusEnum ?? ParagraphRhetoricalStatusEnum.empty,
          item: null,
        ),
      );
    }

    return Container(
      height: allHeight,
      alignment: Alignment.center,
      child: ListView.separated(
        itemCount: allowedParagraphs.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) {
          return Container(
            alignment: Alignment.center,
            height: 36.wMin,
            child: Text(
              "或",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          );
        },
        itemBuilder: (context, index) {
          final nodeId = ArticleBlueprintTableUtils.buildPathNodeId(
            beatNid: paragraphRhetorical.nid,
            paragraphTypeNid: allowedParagraphs[index]?.paragraphTypeNid,
            itemIndex: index,
          );
          return Container(
            key: ArticleBlueprintTableUtils.pathNodeKeyFor(_pathNodeKeyMap, nodeId),
            child: _buildItemContentItemWidget(
              paragraphRhetorical: paragraphRhetorical,
              statusEnum: slot?.statusEnum ?? ParagraphRhetoricalStatusEnum.empty,
              item: allowedParagraphs[index],
            ),
          );
        },
      ),
    );
  }

  /// 在布局稳定后读取卡片坐标，生成本次需要绘制的连线布局。
  void _schedulePathMeasure() {
    if (_isPathMeasureScheduled) return;
    _isPathMeasureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isPathMeasureScheduled = false;
      _measurePathLayouts();
    });
  }

  /// 读取当前卡片的真实位置，并按篇章蓝图路径规则生成 forward / bypass 连线。
  void _measurePathLayouts() {
    final List<_ArticleBlueprintPathLayout> nextLayouts = ArticleBlueprintTableUtils._measurePathLayouts(
      pathRootKey: _pathRootKey,
      pathNodeKeyMap: _pathNodeKeyMap,
      paragraphRhetoricalList: widget.paragraphRhetoricalList,
      slots: widget.slots,
    );
    if (ArticleBlueprintTableUtils._isSamePathLayouts(_pathLayouts, nextLayouts)) return;
    setState(() {
      _pathLayouts = nextLayouts;
    });
  }

  Widget _buildItemContentItemWidget({
    required ParagraphRhetoricalEntityList paragraphRhetorical,
    required ParagraphRhetoricalStatusEnum statusEnum,
    ArticleBlueprintEntityBlueprintsSlotsAllowedParagraphs? item,
  }) {
    bool isDotted = statusEnum == ParagraphRhetoricalStatusEnum.optional || statusEnum == ParagraphRhetoricalStatusEnum.empty;
    Color primaryColor = paragraphRhetorical.currentThemeColor?.colorValue ?? AppTheme.cInverseOverlay5.color;
    Color borderColor = primaryColor.withValues(alpha: 0.6);
    List<Color> bgColors = [primaryColor.withValues(alpha: 0.2), primaryColor.withValues(alpha: 0.08)];
    if (statusEnum == ParagraphRhetoricalStatusEnum.optional) {
      borderColor = primaryColor.withValues(alpha: 0.6);
      bgColors = [AppTheme.cSurfaceLayerBase.color, AppTheme.cSurfaceLayerBase.color];
    } else if (statusEnum == ParagraphRhetoricalStatusEnum.empty) {
      borderColor = AppTheme.cBorderDark.color;
      bgColors = [AppTheme.cSurfaceLayerBase.color, AppTheme.cSurfaceLayerBase.color];
    }

    return IgnorePointer(
      ignoring: statusEnum == ParagraphRhetoricalStatusEnum.empty || widget.onTapParagraph == null,
      child: TapScaleWidget(
        onTap: () {
          widget.onTapParagraph?.call(item);
        },
        sclae: 1.01,
        child: Container(
          width: double.infinity,
          height: 180.wMin,
          padding: EdgeInsets.symmetric(horizontal: 8.wMin),
          child: DottedBorder(
            color: borderColor,
            strokeWidth: 1.wMin,
            dashPattern: [5.wMin, isDotted ? 3.wMin : 0],
            borderType: BorderType.RRect,
            radius: Radius.circular(16.0.wMin),
            padding: EdgeInsets.zero,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(6.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.wMin),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: bgColors,
                    ),
                  ),
                  child: _buildItemContentItemBodyWidget(
                    item: item,
                    primaryColor: primaryColor,
                  ),
                ),
                Positioned(
                  top: -50.wMin,
                  child: Visibility(
                    visible: statusEnum == ParagraphRhetoricalStatusEnum.empty,
                    child: Transform.rotate(
                      angle: 0.7,
                      child: Container(
                        width: 16.wMin,
                        height: 280.wMin,
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

  Widget _buildItemContentItemBodyWidget({
    ArticleBlueprintEntityBlueprintsSlotsAllowedParagraphs? item,
    required Color primaryColor,
  }) {
    if (item == null) return Container();
    final name = LearningLangUtils.getLocalLang(item.paragraphType?.name);
    final usageName = LearningLangUtils.getLocalLang(item.usageName);
    final description = LearningLangUtils.getLocalLang(item.paragraphType?.description);

    return Container(
      padding: EdgeInsets.all(10.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name?.text ?? '',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
              ),
              Visibility(
                visible: widget.onTapParagraph != null,
                child: Container(
                  width: 32.wMin,
                  height: 32.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withValues(alpha: 0.12),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                      width: 0.8.wMin,
                    ),
                  ),
                  child: SvgPicture.asset(
                    'assets/svg/public/icon_w_arrow_right.svg',
                    width: 20.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.wMin),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4.wMin,
                  children: [
                    Text(
                      usageName?.text ?? '',
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                    Text(
                      description?.text ?? '',
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextTertiary.color,
                      ),
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
}

/// 单个候选段型卡片的路径节点。
class _ArticleBlueprintPathNode {
  final String id;

  const _ArticleBlueprintPathNode({
    required this.id,
  });
}

/// 一拍对应的一层路径节点和状态。
class _ArticleBlueprintPathLayer {
  final String beatNid;
  final ParagraphRhetoricalStatusEnum status;
  final Color color;
  final List<_ArticleBlueprintPathNode> nodes;

  const _ArticleBlueprintPathLayer({
    required this.beatNid,
    required this.status,
    required this.color,
    required this.nodes,
  });
}

/// 路径边类型：正常前进或跨过 optional 拍的 bypass。
enum _ArticleBlueprintPathEdgeKind {
  forward,
  bypass,
}

/// 连接两个路径节点的抽象边。
class _ArticleBlueprintPathEdge {
  final String fromNodeId;
  final String toNodeId;
  final _ArticleBlueprintPathEdgeKind kind;
  final Color color;

  const _ArticleBlueprintPathEdge({
    required this.fromNodeId,
    required this.toNodeId,
    required this.kind,
    required this.color,
  });
}

/// 已经换算到画布坐标系里的可绘制路径。
class _ArticleBlueprintPathLayout {
  final String targetNodeId;
  final Offset start;
  final Offset control1;
  final Offset control2;
  final Offset end;
  final _ArticleBlueprintPathEdgeKind kind;
  final Color color;

  const _ArticleBlueprintPathLayout({
    required this.targetNodeId,
    required this.start,
    required this.control1,
    required this.control2,
    required this.end,
    required this.kind,
    required this.color,
  });

  /// 判断两条已布局路径是否等价，用于抑制重复刷新。
  bool isSameAs(_ArticleBlueprintPathLayout other) {
    return targetNodeId == other.targetNodeId &&
        _sameOffset(start, other.start) &&
        _sameOffset(control1, other.control1) &&
        _sameOffset(control2, other.control2) &&
        _sameOffset(end, other.end) &&
        kind == other.kind &&
        color.toARGB32() == other.color.toARGB32();
  }

  bool _sameOffset(Offset left, Offset right) {
    return (left.dx - right.dx).abs() < 0.5 && (left.dy - right.dy).abs() < 0.5;
  }
}

/// 箭头几何信息，供线尾截断和实心箭头绘制共用。
class _ArticleBlueprintArrowHead {
  final Offset tip;
  final Offset leftWing;
  final Offset rightWing;
  final Offset backPoint;
  final double backDistance;
  final Color color;

  const _ArticleBlueprintArrowHead({
    required this.tip,
    required this.leftWing,
    required this.rightWing,
    required this.backPoint,
    required this.backDistance,
    required this.color,
  });
}

/// 绘制候选段型卡片之间的正文路径连线。
class _ArticleBlueprintPathPainter extends CustomPainter {
  final List<_ArticleBlueprintPathLayout> layouts;

  const _ArticleBlueprintPathPainter({
    required this.layouts,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (layouts.isEmpty) return;

    final Map<String, List<_ArticleBlueprintPathLayout>> layoutsByTarget = {};
    for (final layout in layouts) {
      layoutsByTarget.putIfAbsent(layout.targetNodeId, () => []).add(layout);
    }

    for (final group in layoutsByTarget.values) {
      if (group.length <= 1) {
        _paintSingleLayout(canvas: canvas, layout: group.first);
        continue;
      }

      _paintMergedArrowGroup(canvas: canvas, group: group);
    }
  }

  /// 单条入线维持原来的单箭头表现。
  void _paintSingleLayout({
    required Canvas canvas,
    required _ArticleBlueprintPathLayout layout,
  }) {
    final path = Path()
      ..moveTo(layout.start.dx, layout.start.dy)
      ..cubicTo(
        layout.control1.dx,
        layout.control1.dy,
        layout.control2.dx,
        layout.control2.dy,
        layout.end.dx,
        layout.end.dy,
      );

    final strokePaint = Paint()
      ..color = layout.kind == _ArticleBlueprintPathEdgeKind.bypass ? layout.color.withValues(alpha: 0.55) : layout.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5.wMin
      ..strokeCap = StrokeCap.round;
    final _ArticleBlueprintArrowHead? arrowHead = _buildArrowHead(path: path, color: strokePaint.color);
    final Path drawPath = _trimPathForArrow(path: path, trimLength: arrowHead?.backDistance ?? 0);

    if (layout.kind == _ArticleBlueprintPathEdgeKind.bypass) {
      _drawDashedPath(canvas: canvas, path: drawPath, paint: strokePaint, dashLength: 8.wMin, gapLength: 5.wMin);
      if (arrowHead != null) _drawArrowHead(canvas: canvas, arrowHead: arrowHead);
      return;
    }

    canvas.drawPath(drawPath, strokePaint);
    if (arrowHead != null) _drawArrowHead(canvas: canvas, arrowHead: arrowHead);
  }

  /// 多条入线命中同一目标卡片时，先汇到共同尾点，再只画一个箭头。
  void _paintMergedArrowGroup({
    required Canvas canvas,
    required List<_ArticleBlueprintPathLayout> group,
  }) {
    final _ArticleBlueprintPathLayout sample = group.first;
    final _ArticleBlueprintArrowHead arrowHead = _buildSharedArrowHead(
      tip: sample.end,
      color: sample.color,
    );
    final Offset joint = arrowHead.backPoint;

    for (final layout in group) {
      final path = Path()
        ..moveTo(layout.start.dx, layout.start.dy)
        ..cubicTo(
          layout.control1.dx,
          layout.control1.dy,
          min(layout.control2.dx, joint.dx - 4.wMin),
          layout.control2.dy,
          joint.dx,
          joint.dy,
        );

      final strokePaint = Paint()
        ..color = layout.kind == _ArticleBlueprintPathEdgeKind.bypass ? layout.color.withValues(alpha: 0.65) : layout.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.wMin
        ..strokeCap = StrokeCap.round;

      if (layout.kind == _ArticleBlueprintPathEdgeKind.bypass) {
        _drawDashedPath(canvas: canvas, path: path, paint: strokePaint, dashLength: 5.wMin, gapLength: 4.wMin);
        continue;
      }

      canvas.drawPath(path, strokePaint);
    }

    _drawArrowHead(canvas: canvas, arrowHead: arrowHead);
  }

  /// 手动切分 PathMetric 绘制虚线，用来表达“绕过可写拍”的 bypass。
  void _drawDashedPath({
    required Canvas canvas,
    required Path path,
    required Paint paint,
    required double dashLength,
    required double gapLength,
  }) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  /// 按路径末端切线生成一个更圆滑的实心箭头。
  _ArticleBlueprintArrowHead? _buildArrowHead({
    required Path path,
    required Color color,
  }) {
    final iterator = path.computeMetrics().iterator;
    if (!iterator.moveNext()) return null;

    final metric = iterator.current;
    final double sampleOffset = max(0, metric.length - 10.wMin);
    final Tangent? tipTangent = metric.getTangentForOffset(metric.length);
    final Tangent? sampleTangent = metric.getTangentForOffset(sampleOffset);
    if (tipTangent == null || sampleTangent == null) return null;

    final Offset delta = tipTangent.position - sampleTangent.position;
    if (delta.distance <= 0.1) return null;

    final Offset direction = delta / delta.distance;
    final double arrowLength = 7.wMin;
    final double arrowAngle = pi / 6;
    final Offset tip = tipTangent.position;
    final Offset leftWing = tip - _rotateOffset(direction, arrowAngle) * arrowLength;
    final Offset rightWing = tip - _rotateOffset(direction, -arrowAngle) * arrowLength;
    final Offset backPoint = tip - direction * (arrowLength * 0.9);
    return _ArticleBlueprintArrowHead(
      tip: tip,
      leftWing: leftWing,
      rightWing: rightWing,
      backPoint: backPoint,
      backDistance: arrowLength * 0.9,
      color: color,
    );
  }

  /// 多入线目标统一使用一个朝向卡片的箭头，避免多个箭头挤在一起难以辨认。
  _ArticleBlueprintArrowHead _buildSharedArrowHead({
    required Offset tip,
    required Color color,
  }) {
    final Offset direction = const Offset(1, 0);
    final double arrowLength = 7.wMin;
    final double arrowAngle = pi / 6;
    final Offset leftWing = tip - _rotateOffset(direction, arrowAngle) * arrowLength;
    final Offset rightWing = tip - _rotateOffset(direction, -arrowAngle) * arrowLength;
    final Offset backPoint = tip - direction * (arrowLength * 0.9);
    return _ArticleBlueprintArrowHead(
      tip: tip,
      leftWing: leftWing,
      rightWing: rightWing,
      backPoint: backPoint,
      backDistance: arrowLength * 0.9,
      color: color,
    );
  }

  /// 把线身收在箭头尾心，避免线直接冲到箭头尖上导致连接生硬。
  Path _trimPathForArrow({
    required Path path,
    required double trimLength,
  }) {
    if (trimLength <= 0) return path;
    final iterator = path.computeMetrics().iterator;
    if (!iterator.moveNext()) return path;

    final metric = iterator.current;
    final double end = max(0, metric.length - trimLength);
    return metric.extractPath(0, end);
  }

  /// 在路径右端补一个实心箭头，方向跟随曲线末段切线。
  void _drawArrowHead({
    required Canvas canvas,
    required _ArticleBlueprintArrowHead arrowHead,
  }) {
    final Paint arrowPaint = Paint()
      ..color = arrowHead.color
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.round;
    final Path arrowPath = Path()
      ..moveTo(arrowHead.tip.dx, arrowHead.tip.dy)
      ..lineTo(arrowHead.leftWing.dx, arrowHead.leftWing.dy)
      ..lineTo(arrowHead.backPoint.dx, arrowHead.backPoint.dy)
      ..lineTo(arrowHead.rightWing.dx, arrowHead.rightWing.dy)
      ..close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  /// 旋转单位方向向量，用于生成箭头两侧翅膀。
  Offset _rotateOffset(Offset offset, double angle) {
    final double cosValue = cos(angle);
    final double sinValue = sin(angle);
    return Offset(
      offset.dx * cosValue - offset.dy * sinValue,
      offset.dx * sinValue + offset.dy * cosValue,
    );
  }

  @override
  bool shouldRepaint(covariant _ArticleBlueprintPathPainter oldDelegate) {
    if (oldDelegate.layouts.length != layouts.length) return true;
    for (int index = 0; index < layouts.length; index++) {
      if (!oldDelegate.layouts[index].isSameAs(layouts[index])) return true;
    }
    return false;
  }
}

class ArticleBlueprintTableUtils {
  /// 为每张候选卡片生成稳定的路径节点 id。
  static String buildPathNodeId({
    required String? beatNid,
    required String? paragraphTypeNid,
    required int itemIndex,
  }) {
    return '${beatNid ?? ''}:${paragraphTypeNid ?? ''}:$itemIndex';
  }

  /// 返回候选卡片对应的测量 key，不改动现有 UI，只额外挂测点。
  static GlobalKey pathNodeKeyFor(Map<String, GlobalKey> pathNodeKeyMap, String nodeId) {
    return pathNodeKeyMap.putIfAbsent(nodeId, () => GlobalKey(debugLabel: nodeId));
  }

  /// 统一读取卡片坐标，并按篇章蓝图路径规则生成 forward / bypass 连线布局。
  static List<_ArticleBlueprintPathLayout> _measurePathLayouts({
    required GlobalKey pathRootKey,
    required Map<String, GlobalKey> pathNodeKeyMap,
    required List<ParagraphRhetoricalEntityList> paragraphRhetoricalList,
    required List<ArticleBlueprintEntityBlueprintsSlots?> slots,
  }) {
    final RenderBox? rootBox = pathRootKey.currentContext?.findRenderObject() as RenderBox?;
    if (rootBox == null || !rootBox.hasSize) return [];

    final List<_ArticleBlueprintPathLayer> layers = _buildPathLayers(
      paragraphRhetoricalList: paragraphRhetoricalList,
      slots: slots,
    );
    final List<_ArticleBlueprintPathEdge> edges = _buildPathEdges(layers);
    final List<_ArticleBlueprintPathLayout> layouts = [];

    for (final edge in edges) {
      final Rect? fromRect = _measurePathNodeRect(
        rootBox: rootBox,
        pathNodeKeyMap: pathNodeKeyMap,
        nodeId: edge.fromNodeId,
      );
      final Rect? toRect = _measurePathNodeRect(
        rootBox: rootBox,
        pathNodeKeyMap: pathNodeKeyMap,
        nodeId: edge.toNodeId,
      );
      if (fromRect == null || toRect == null) continue;
      layouts.add(_buildPathLayout(edge: edge, fromRect: fromRect, toRect: toRect));
    }

    return layouts;
  }

  /// 判断两组已布局路径是否等价，用于抑制重复刷新。
  static bool _isSamePathLayouts(List<_ArticleBlueprintPathLayout> left, List<_ArticleBlueprintPathLayout> right) {
    if (left.length != right.length) return false;
    for (int index = 0; index < left.length; index++) {
      if (!left[index].isSameAs(right[index])) return false;
    }
    return true;
  }

  /// 把候选卡片的全局位置换算到路径画布内部坐标系。
  static Rect? _measurePathNodeRect({
    required RenderBox rootBox,
    required Map<String, GlobalKey> pathNodeKeyMap,
    required String nodeId,
  }) {
    final GlobalKey? nodeKey = pathNodeKeyMap[nodeId];
    final RenderBox? nodeBox = nodeKey?.currentContext?.findRenderObject() as RenderBox?;
    if (nodeBox == null || !nodeBox.hasSize) return null;

    final Offset topLeft = nodeBox.localToGlobal(Offset.zero, ancestor: rootBox);
    return topLeft & nodeBox.size;
  }

  /// 按当前四拍顺序整理出路径层，只有非空候选卡片才参与实际连线。
  static List<_ArticleBlueprintPathLayer> _buildPathLayers({
    required List<ParagraphRhetoricalEntityList> paragraphRhetoricalList,
    required List<ArticleBlueprintEntityBlueprintsSlots?> slots,
  }) {
    return List.generate(paragraphRhetoricalList.length, (index) {
      final paragraphRhetorical = paragraphRhetoricalList[index];
      final slot = slots.firstWhereOrNull((e) => e?.beatNid == paragraphRhetorical.nid);
      final status = slot?.statusEnum ?? ParagraphRhetoricalStatusEnum.empty;
      final color = paragraphRhetorical.currentThemeColor?.colorValue ?? AppTheme.cInverseOverlay5.color;
      final List<ArticleBlueprintEntityBlueprintsSlotsAllowedParagraphs> allowedParagraphs = status == ParagraphRhetoricalStatusEnum.empty
          ? <ArticleBlueprintEntityBlueprintsSlotsAllowedParagraphs>[]
          : (slot?.allowedParagraphs ?? []).whereType<ArticleBlueprintEntityBlueprintsSlotsAllowedParagraphs>().toList();

      return _ArticleBlueprintPathLayer(
        beatNid: paragraphRhetorical.nid ?? '',
        status: status,
        color: color,
        nodes: List.generate(allowedParagraphs.length, (itemIndex) {
          final item = allowedParagraphs[itemIndex];
          return _ArticleBlueprintPathNode(
            id: buildPathNodeId(
              beatNid: paragraphRhetorical.nid,
              paragraphTypeNid: item.paragraphTypeNid,
              itemIndex: itemIndex,
            ),
          );
        }),
      );
    });
  }

  /// 对齐 Web 端 compositionPathModel：forward 连到下一有效拍，optional 拍额外允许 bypass。
  static List<_ArticleBlueprintPathEdge> _buildPathEdges(List<_ArticleBlueprintPathLayer> layers) {
    final List<_ArticleBlueprintPathLayer> liveLayers = layers.where((layer) => layer.nodes.isNotEmpty).toList();
    final List<_ArticleBlueprintPathEdge> edges = [];

    for (int index = 0; index < liveLayers.length; index++) {
      final layer = liveLayers[index];
      int nextIndex = index + 1;
      bool skippedOptional = false;

      while (nextIndex < liveLayers.length) {
        final targetLayer = liveLayers[nextIndex];
        final kind = skippedOptional ? _ArticleBlueprintPathEdgeKind.bypass : _ArticleBlueprintPathEdgeKind.forward;
        for (final fromNode in layer.nodes) {
          for (final toNode in targetLayer.nodes) {
            edges.add(_ArticleBlueprintPathEdge(
              fromNodeId: fromNode.id,
              toNodeId: toNode.id,
              kind: kind,
              color: targetLayer.color,
            ));
          }
        }
        if (targetLayer.status != ParagraphRhetoricalStatusEnum.optional) break;
        skippedOptional = true;
        nextIndex += 1;
      }
    }

    return edges;
  }

  /// 根据两张卡片的矩形位置生成一条平滑贝塞尔路径。
  static _ArticleBlueprintPathLayout _buildPathLayout({
    required _ArticleBlueprintPathEdge edge,
    required Rect fromRect,
    required Rect toRect,
  }) {
    final Offset start = Offset(fromRect.right - 6.wMin, fromRect.center.dy);
    final Offset end = Offset(toRect.left + 6.wMin, toRect.center.dy);
    final double dx = max(0, end.dx - start.dx);
    final double curveDx = min(56.wMin, dx * 0.42);
    final double bulge = edge.kind == _ArticleBlueprintPathEdgeKind.bypass ? -18.wMin : 0;

    return _ArticleBlueprintPathLayout(
      targetNodeId: edge.toNodeId,
      start: start,
      control1: Offset(start.dx + curveDx, start.dy + bulge),
      control2: Offset(end.dx - curveDx, end.dy + bulge),
      end: end,
      kind: edge.kind,
      color: edge.color,
    );
  }
}
