import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 词源画布根卡片，内部承载内容卡、悬浮提示卡和连接线。
class EtymologyCanvasRootWidget extends StatefulWidget {
  const EtymologyCanvasRootWidget({
    super.key,
    this.contentKey,
    required this.contentText,
    required this.node,
    this.isActive = false,
  });

  /// 根节点内容容器 key，供外层画布测量头部和底部锚点。
  final GlobalKey? contentKey;
  final String contentText;
  final CardContentEtymologyNode node;
  final bool isActive;

  @override
  State<EtymologyCanvasRootWidget> createState() => _EtymologyCanvasRootWidgetState();
}

class _EtymologyCanvasRootWidgetState extends State<EtymologyCanvasRootWidget> {
  /// 内容卡片的定位锚点，用于计算连接线终点。
  final GlobalKey internalContentKey = GlobalKey();

  /// 提示卡片的定位锚点，用于计算连接线起点。
  final GlobalKey tipKey = GlobalKey();

  /// 统一复用内容卡的 key，同时服务内部连线和外层画布测量。
  GlobalKey get contentKey => widget.contentKey ?? internalContentKey;

  @override
  Widget build(BuildContext context) {
    final String tipText = _findLanguageText(widget.node.forkNote);
    return _EtymologyCanvasLinkedCardWidget(
      tipKey: tipKey,
      contentKey: contentKey,
      tipText: tipText,
      tipChild: tipText.isEmpty
          ? null
          : GestureDetector(
              key: tipKey,
              behavior: HitTestBehavior.translucent,
              onTap: () {},
              child: EtymologyCanvasTipCardWidget(text: tipText),
            ),
      contentChild: _buildContentWidget(),
    );
  }

  /// 构建根卡片里的内容主体。
  Widget _buildContentWidget() {
    final String labelText = _findLanguageText(widget.node.label);
    final String bubbleText = _findLanguageText(widget.node.bubble);
    return Container(
      key: contentKey,
      width: 260.wMin,
      height: 190.wMin,
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: AppTheme.cSurfaceWarning.color.withValues(alpha: widget.isActive ? 0.26 : 0.2),
        border: Border.all(
          color: AppTheme.cSurfaceWarning.color.withValues(alpha: widget.isActive ? 0.7 : 0.45),
          width: widget.isActive ? 1.2.wMin : 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "词源核",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cSurfaceWarning.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                "0",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Text(
            widget.contentText,
            style: TextStyle(
              fontSize: 32.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            labelText,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomLeft,
              child: AutoSizeText(
                bubbleText,
                maxLines: 3,
                minFontSize: 4,
                style: TextStyle(
                  fontSize: 13.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _findLanguageText(List<LanguageText?>? values) {
    if (values == null) return '';
    for (final LanguageText? item in values) {
      if (item?.lang == 'zh') return item?.text ?? '';
    }
    return '';
  }
}

/// 词源画布的文本说明卡片。
class EtymologyCanvasTextCardWidget extends StatefulWidget {
  const EtymologyCanvasTextCardWidget({
    super.key,
    this.contentKey,
    required this.node,
    this.isActive = false,
  });

  /// 文本节点内容容器 key，供外层画布测量头部和底部锚点。
  final GlobalKey? contentKey;
  final CardContentEtymologyNode node;
  final bool isActive;

  @override
  State<EtymologyCanvasTextCardWidget> createState() => _EtymologyCanvasTextCardWidgetState();
}

class _EtymologyCanvasTextCardWidgetState extends State<EtymologyCanvasTextCardWidget> {
  /// 内容卡片的定位锚点，用于计算连接线终点。
  final GlobalKey internalContentKey = GlobalKey();

  /// 提示卡片的定位锚点，用于计算连接线起点。
  final GlobalKey tipKey = GlobalKey();

  /// 统一复用内容卡的 key，同时服务内部连线和外层画布测量。
  GlobalKey get contentKey => widget.contentKey ?? internalContentKey;

  @override
  Widget build(BuildContext context) {
    final String tipText = _findTipText();
    return _EtymologyCanvasLinkedCardWidget(
      tipKey: tipKey,
      contentKey: contentKey,
      tipText: tipText,
      tipChild: tipText.isEmpty
          ? null
          : GestureDetector(
              key: tipKey,
              behavior: HitTestBehavior.translucent,
              onTap: () {},
              child: EtymologyCanvasTipCardWidget(text: tipText),
            ),
      contentChild: _buildContentWidget(),
    );
  }

  Widget _buildContentWidget() {
    final String labelText = _findLanguageText(widget.node.label);
    final String bubbleText = _findLanguageText(widget.node.bubble);
    return Container(
      key: contentKey,
      width: 260.wMin,
      height: 160.wMin,
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: AppTheme.cSurfaceWarning.color.withValues(alpha: widget.isActive ? 0.16 : 0.12),
        border: Border.all(
          color: AppTheme.cSurfaceWarning.color.withValues(alpha: widget.isActive ? 0.38 : 0.2),
          width: widget.isActive ? 1.2.wMin : 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "延伸",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cSurfaceWarning.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                widget.node.nodeId ?? '',
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Text(
            labelText,
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomLeft,
              child: AutoSizeText(
                bubbleText,
                maxLines: 3,
                minFontSize: 4,
                style: TextStyle(
                  fontSize: 12.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _findTipText() {
    final String forkNoteText = _findLanguageText(widget.node.forkNote);
    if (forkNoteText.isNotEmpty) return forkNoteText;
    return _findLanguageText(widget.node.bubble);
  }

  String _findLanguageText(List<LanguageText?>? values) {
    if (values == null) return '';
    for (final LanguageText? item in values) {
      if (item?.lang == 'zh') return item?.text ?? '';
    }
    return '';
  }
}

/// 词源画布的提示说明卡片。
class EtymologyCanvasTipCardWidget extends StatefulWidget {
  const EtymologyCanvasTipCardWidget({
    super.key,
    required this.text,
  });

  final String text;

  @override
  State<EtymologyCanvasTipCardWidget> createState() => _EtymologyCanvasTipCardWidgetState();
}

class _EtymologyCanvasTipCardWidgetState extends State<EtymologyCanvasTipCardWidget> {
  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: AppTheme.cSurfaceWarning.color,
      strokeWidth: 0.5.wMin,
      dashPattern: [3.wMin, 3.wMin],
      borderType: BorderType.RRect,
      padding: EdgeInsets.zero,
      customPath: (size) => Path()
        ..addRRect(
          RRect.fromRectAndCorners(
            Offset.zero & size,
            topLeft: Radius.circular(24.wMin),
            topRight: Radius.circular(4.wMin),
            bottomLeft: Radius.circular(4.wMin),
            bottomRight: Radius.circular(24.wMin),
          ),
        ),
      child: Container(
        width: 260.wMin,
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.wMin),
            topRight: Radius.circular(4.wMin),
            bottomLeft: Radius.circular(4.wMin),
            bottomRight: Radius.circular(24.wMin),
          ),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 14.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// 组合内容卡、悬浮提示卡和连接线的轻量容器。
class _EtymologyCanvasLinkedCardWidget extends StatefulWidget {
  const _EtymologyCanvasLinkedCardWidget({
    required this.tipKey,
    required this.contentKey,
    required this.tipText,
    this.tipChild,
    required this.contentChild,
  });

  /// 提示卡片的定位 key。
  final GlobalKey tipKey;

  /// 内容卡片的定位 key。
  final GlobalKey contentKey;

  /// 悬浮提示卡片。
  final String tipText;
  final Widget? tipChild;

  /// 主内容卡片。
  final Widget contentChild;

  @override
  State<_EtymologyCanvasLinkedCardWidget> createState() => _EtymologyCanvasLinkedCardWidgetState();
}

class _EtymologyCanvasLinkedCardWidgetState extends State<_EtymologyCanvasLinkedCardWidget> {
  /// 连接线画布自身的定位 key，用于坐标换算。
  final GlobalKey canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (widget.tipText.isEmpty || widget.tipChild == null) {
      return widget.contentChild;
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 280.wMin),
          child: widget.contentChild,
        ),
        _buildEtymologyCanvasConnectionWidget(widget.tipKey, widget.contentKey),
        Positioned(left: 0, top: 28.wMin, child: widget.tipChild!),
      ],
    );
  }

  /// 构建两个组件之间的连接线画布，供同文件其他场景复用。
  Widget _buildEtymologyCanvasConnectionWidget(GlobalKey startKey, GlobalKey endKey) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          key: canvasKey,
          painter: _EtymologyCanvasConnectionPainter(
            canvasKey: canvasKey,
            startKey: startKey,
            endKey: endKey,
          ),
        ),
      ),
    );
  }
}

/// 绘制圆点和横线的连接器。
class _EtymologyCanvasConnectionPainter extends CustomPainter {
  const _EtymologyCanvasConnectionPainter({
    required this.canvasKey,
    required this.startKey,
    required this.endKey,
  });

  /// 当前画布 key，用于将全局坐标换算成局部坐标。
  final GlobalKey canvasKey;

  /// 起点组件 key。
  final GlobalKey startKey;

  /// 终点组件 key。
  final GlobalKey endKey;

  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox? canvasBox = canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? startBox = startKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? endBox = endKey.currentContext?.findRenderObject() as RenderBox?;
    if (canvasBox == null || startBox == null || endBox == null) return;
    final Offset startPoint = canvasBox.globalToLocal(startBox.localToGlobal(Offset(startBox.size.width, startBox.size.height / 2)));
    final Offset endPoint = canvasBox.globalToLocal(endBox.localToGlobal(Offset.zero));
    final double circleRadius = 4.wMin;
    final Paint dotPaint = Paint()..color = AppTheme.cSurfaceWarning.color;
    final Paint linePaint = Paint()
      ..color = AppTheme.cSurfaceWarning.color
      ..strokeWidth = 1.wMin
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(startPoint, circleRadius, dotPaint);
    canvas.drawLine(startPoint, Offset(endPoint.dx, startPoint.dy), linePaint);
  }

  @override
  bool shouldRepaint(covariant _EtymologyCanvasConnectionPainter oldDelegate) => true;
}
