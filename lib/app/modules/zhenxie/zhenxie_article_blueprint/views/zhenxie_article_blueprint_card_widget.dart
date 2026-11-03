import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../common/widgets/zhenxie_widgets/article_blueprint_min_table_widget.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../management/common/commons.dart';

class ZhenxieArticleBlueprintCardWidget extends StatefulWidget {
  /// 当前文章蓝图下可用的段落修辞拍列表。
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;

  /// 当前文章蓝图家族数据。
  final ArticleBlueprintEntity data;

  /// 是否处于管理端模式。
  final bool isManagement;

  /// 点击整张文章蓝图卡片时的回调。
  final void Function(ArticleBlueprintEntity data)? onTap;

  /// 点击具体蓝图摘要表时的回调。
  final void Function(ArticleBlueprintEntity data, ArticleBlueprintEntityBlueprints blueprint)? onTapBlueprint;

  const ZhenxieArticleBlueprintCardWidget({
    super.key,
    required this.paragraphRhetoricalList,
    required this.data,
    this.isManagement = false,
    this.onTap,
    this.onTapBlueprint,
  });

  @override
  State<ZhenxieArticleBlueprintCardWidget> createState() => _ZhenxieArticleBlueprintCardWidgetState();
}

class _ZhenxieArticleBlueprintCardWidgetState extends State<ZhenxieArticleBlueprintCardWidget> {
  /// 每张蓝图卡片的测量 key，用于同步同一行左右卡片的真实高度。
  final Map<String, GlobalKey> _blueprintCardKeyMap = {};

  /// 每一行当前已经同步完成的高度。
  final Map<int, double> _rowHeightMap = {};

  /// 避免同一帧里重复调度高度测量。
  bool _isMeasureScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleCardMeasure();
  }

  @override
  void didUpdateWidget(covariant ZhenxieArticleBlueprintCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleCardMeasure();
  }

  @override
  Widget build(BuildContext context) {
    final blueprints = _buildBlueprintList();
    _scheduleCardMeasure();
    return TapScaleWidget(
      onTap: widget.onTap == null ? null : () => widget.onTap?.call(widget.data),
      sclae: 1,
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32.wMin),
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
            if (blueprints.isNotEmpty) ...[
              SizedBox(height: 16.wMin),
              _buildBlueprintGridWidget(blueprints),
            ],
          ],
        ),
      ),
    );
  }

  /// 过滤空蓝图，保证下方两列区域只消费可展示的数据。
  List<ArticleBlueprintEntityBlueprints> _buildBlueprintList() {
    return (widget.data.blueprints ?? const <ArticleBlueprintEntityBlueprints?>[]).whereType<ArticleBlueprintEntityBlueprints>().toList();
  }

  /// 构建文章蓝图家族头部信息区，对齐 Web 端的标题 + 描述布局。
  Widget _buildHeaderWidget() {
    final name = LearningLangUtils.getLocalLang(widget.data.name);
    final description = LearningLangUtils.getLocalLang(widget.data.description);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name?.text ?? '',
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cZhenxieFontPrimary.color,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                ),
              ),
              SizedBox(height: 6.wMin),
              Text(
                description?.text ?? '',
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontTertiary.color,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                ),
              ),
              Visibility(
                visible: widget.isManagement,
                child: Container(
                  margin: EdgeInsets.only(top: 8.wMin),
                  child: CopyTagWidget(
                    name: "文章",
                    value: widget.data.nid ?? '',
                    isShow: widget.isManagement,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.isManagement) ...[
          SizedBox(width: 12.wMin),
          ButtonWidget(
            text: "编辑详情",
            onTap: widget.onTap == null ? null : () => widget.onTap?.call(widget.data),
            padding: EdgeInsets.symmetric(horizontal: 8.wMin),
            height: 32.wMin,
            borderRadius: 99,
            color: AppTheme.cSurfaceLayerBase.color,
            fontSize: 18.wMin,
            fontColor: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
            border: Border.all(
              color: AppTheme.cBorderSubtle.color,
              width: 1.wMin,
            ),
            leftIcon: Container(
              margin: EdgeInsets.only(right: 6.wMin),
              child: SvgPicture.asset(
                "assets/svg/manage/icon_edit.svg",
                width: 18.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 使用两列行块布局承载所有蓝图，并通过真实测量结果同步同一行高度。
  Widget _buildBlueprintGridWidget(List<ArticleBlueprintEntityBlueprints> blueprints) {
    final rowCount = (blueprints.length / 2).ceil();
    return Column(
      children: List.generate(rowCount, (rowIndex) {
        final leftIndex = rowIndex * 2;
        final rightIndex = leftIndex + 1;
        final leftBlueprint = blueprints[leftIndex];
        final rightBlueprint = rightIndex < blueprints.length ? blueprints[rightIndex] : null;
        final rowHeight = _rowHeightMap[rowIndex];
        return Container(
          margin: EdgeInsets.only(top: rowIndex == 0 ? 0 : 16.wMin),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildBlueprintCardSlot(
                  blueprint: leftBlueprint,
                  rowIndex: rowIndex,
                  columnIndex: 0,
                  rowHeight: rowHeight,
                ),
              ),
              SizedBox(width: 16.wMin),
              Expanded(
                child: rightBlueprint == null
                    ? SizedBox.shrink()
                    : _buildBlueprintCardSlot(
                        blueprint: rightBlueprint,
                        rowIndex: rowIndex,
                        columnIndex: 1,
                        rowHeight: rowHeight,
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// 构建单张蓝图卡片槽位；首次按自然高度布局，测量完成后再套用同行最大高度。
  Widget _buildBlueprintCardSlot({
    required ArticleBlueprintEntityBlueprints blueprint,
    required int rowIndex,
    required int columnIndex,
    required double? rowHeight,
  }) {
    final keyId = _buildBlueprintCardKeyId(
      rowIndex: rowIndex,
      columnIndex: columnIndex,
      blueprint: blueprint,
    );
    final card = Container(
      key: _blueprintCardKeyFor(keyId),
      child: _buildBlueprintCardWidget(blueprint),
    );
    if (rowHeight == null) return card;
    return SizedBox(height: rowHeight, child: card);
  }

  /// 构建单个路径蓝图卡片，保留原有色彩体系，仅收敛头部排布。
  Widget _buildBlueprintCardWidget(ArticleBlueprintEntityBlueprints blueprint) {
    return TapScaleWidget(
      onTap: widget.onTapBlueprint == null ? null : () => widget.onTapBlueprint?.call(widget.data, blueprint),
      sclae: 1,
      borderRadius: 16.wMin,
      backColor: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.02),
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cZhenxieBackgroundPrimary.color,
          borderRadius: BorderRadius.circular(20.wMin),
          border: Border.all(
            color: AppTheme.cZhenxieBorderPrimary.color,
            width: 0.8.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBlueprintHeaderWidget(blueprint),
            SizedBox(height: 10.wMin),
            _buildBlueprintContentWidget(blueprint),
          ],
        ),
      ),
    );
  }

  /// 构建概览态蓝图头部，弱化封面区域，改成标题和标签横向收口。
  Widget _buildBlueprintHeaderWidget(ArticleBlueprintEntityBlueprints blueprint) {
    final name = LearningLangUtils.getLocalLang(blueprint.name);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            name?.text ?? '',
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontPrimary.color,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
        ),
        Wrap(
          spacing: 6.wMin,
          runSpacing: 6.wMin,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildTagWidget(tagText: _buildParagraphCountText(blueprint)),
            _buildTagWidget(tagText: _buildDifficultyText(blueprint)),
            if (widget.isManagement) ...[
              CopyTagWidget(
                name: "蓝图",
                value: blueprint.nid ?? '',
                isShow: widget.isManagement,
              ),
              CopyTagWidget(
                name: "框架",
                value: blueprint.frameworkNid ?? '',
                isShow: widget.isManagement,
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// 构建蓝图摘要表区域，并继续复用原有点击跳转能力。
  Widget _buildBlueprintContentWidget(ArticleBlueprintEntityBlueprints blueprint) {
    final slots = blueprint.slots ?? const <ArticleBlueprintEntityBlueprintsSlots?>[];
    return SizedBox(
      width: double.infinity,
      child: ArticleBlueprintMinTableWidget(
        paragraphRhetoricalList: widget.paragraphRhetoricalList,
        slots: slots,
        frame: blueprint.frame,
      ),
    );
  }

  /// 统一生成段数范围文案。
  String _buildParagraphCountText(ArticleBlueprintEntityBlueprints blueprint) {
    final minParagraphCount = blueprint.minParagraphCount ?? 0;
    final maxParagraphCount = blueprint.maxParagraphCount ?? 0;
    if (minParagraphCount == maxParagraphCount) return "$minParagraphCount段";
    return "$minParagraphCount-$maxParagraphCount段";
  }

  /// 统一生成难度范围文案。
  String _buildDifficultyText(ArticleBlueprintEntityBlueprints blueprint) {
    return "L${blueprint.difficulty?.min ?? 0}-L${blueprint.difficulty?.max ?? 0}";
  }

  /// 统一构建卡片内的小标签样式。
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

  /// 生成单张蓝图卡片的稳定测量标识。
  String _buildBlueprintCardKeyId({
    required int rowIndex,
    required int columnIndex,
    required ArticleBlueprintEntityBlueprints blueprint,
  }) {
    final nid = blueprint.nid ?? '';
    return "$rowIndex-$columnIndex-$nid";
  }

  /// 获取单张蓝图卡片的测量 key。
  GlobalKey _blueprintCardKeyFor(String keyId) {
    return _blueprintCardKeyMap.putIfAbsent(keyId, () => GlobalKey());
  }

  /// 在布局完成后读取左右卡片真实高度，并同步同一行的最大值。
  void _scheduleCardMeasure() {
    if (_isMeasureScheduled) return;
    _isMeasureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isMeasureScheduled = false;
      _measureRowHeights();
    });
  }

  /// 根据当前渲染结果更新每一行的真实同步高度。
  void _measureRowHeights() {
    if (!mounted) return;
    final blueprints = _buildBlueprintList();
    final nextHeights = <int, double>{};
    final rowCount = (blueprints.length / 2).ceil();
    for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) {
      final leftIndex = rowIndex * 2;
      final rightIndex = leftIndex + 1;
      final leftHeight = _measureBlueprintCardHeight(
        _buildBlueprintCardKeyId(
          rowIndex: rowIndex,
          columnIndex: 0,
          blueprint: blueprints[leftIndex],
        ),
      );
      final rightHeight = rightIndex < blueprints.length
          ? _measureBlueprintCardHeight(
              _buildBlueprintCardKeyId(
                rowIndex: rowIndex,
                columnIndex: 1,
                blueprint: blueprints[rightIndex],
              ),
            )
          : 0.0;
      final rowHeight = leftHeight > rightHeight ? leftHeight : rightHeight;
      if (rowHeight > 0) nextHeights[rowIndex] = rowHeight;
    }
    if (_isSameRowHeightMap(_rowHeightMap, nextHeights)) return;
    setState(() {
      _rowHeightMap
        ..clear()
        ..addAll(nextHeights);
    });
  }

  /// 读取单张蓝图卡片当前的真实高度。
  double _measureBlueprintCardHeight(String keyId) {
    final renderBox = _blueprintCardKeyMap[keyId]?.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return 0;
    return renderBox.size.height;
  }

  /// 判断行高映射是否发生变化，避免重复刷新。
  bool _isSameRowHeightMap(Map<int, double> left, Map<int, double> right) {
    if (left.length != right.length) return false;
    for (final entry in left.entries) {
      final rightHeight = right[entry.key];
      if (rightHeight == null) return false;
      if ((entry.value - rightHeight).abs() > 0.5) return false;
    }
    return true;
  }
}
