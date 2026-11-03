import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/dialog_box_widget.dart';
import '../../../../../common/widgets/tap_scale_widget.dart';
import '../../../../../theme/theme.dart';

class ElementsSentenceSyntaxContentWidget extends StatefulWidget {
  final EnSentenceStructureDetailEntity detils;

  const ElementsSentenceSyntaxContentWidget({
    super.key,
    required this.detils,
  });

  @override
  State<ElementsSentenceSyntaxContentWidget> createState() => _ElementsSentenceSyntaxContentWidgetState();
}

class _ElementsSentenceSyntaxContentWidgetState extends State<ElementsSentenceSyntaxContentWidget> {
  static final Map<String, _SyntaxTreeTitle> _treeOnlyTitles = <String, _SyntaxTreeTitle>{
    'ROOT': const _SyntaxTreeTitle(zh: '根', en: 'Root'),
    'SQ': const _SyntaxTreeTitle(zh: '疑问句', en: 'Wh-question / yes-no question'),
    'SINV': const _SyntaxTreeTitle(zh: '倒装句', en: 'Inverted sentence'),
    'WHNP': const _SyntaxTreeTitle(zh: 'WH名词短语', en: 'WH noun phrase'),
    'WHPP': const _SyntaxTreeTitle(zh: 'WH介词短语', en: 'WH preposition phrase'),
    'WHADVP': const _SyntaxTreeTitle(zh: 'WH副词短语', en: 'WH adverb phrase'),
    'CONJP': const _SyntaxTreeTitle(zh: '连词短语', en: 'Conjunction phrase'),
    '.': const _SyntaxTreeTitle(zh: '句号', en: 'Period'),
    ',': const _SyntaxTreeTitle(zh: '逗号', en: 'Comma'),
    '?': const _SyntaxTreeTitle(zh: '问号', en: 'Question mark'),
    '!': const _SyntaxTreeTitle(zh: '感叹号', en: 'Exclamation mark'),
    ':': const _SyntaxTreeTitle(zh: '冒号', en: 'Colon'),
    ';': const _SyntaxTreeTitle(zh: '分号', en: 'Semicolon'),
  };

  final TransformationController _transformController = TransformationController();
  Matrix4 _initialTransform = Matrix4.identity();
  bool _showInternal = true;
  String _fitSignature = '';

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<ConfigController>()) {
      return Obx(() {
        Get.find<ConfigController>().colorConfigs.value;
        return _buildContent(context);
      });
    }
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    final EnSentenceStructureSyntax? syntax = widget.detils.analysisData?.syntax;
    final String parse = syntax?.constituencyParse ?? '';
    final List<EnSentenceStructureToken> tokens =
        (widget.detils.analysisData?.tokens ?? <EnSentenceStructureToken?>[])
            .whereType<EnSentenceStructureToken>()
            .toList()
          ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    final List<EnSentenceStructurePosForm> posForms =
        (syntax?.posForms ?? <EnSentenceStructurePosForm?>[]).whereType<EnSentenceStructurePosForm>().toList();
    final LanguageConfigColorEntity? colorConfigs = _colorConfigsOrNull();
    if (parse.trim().isEmpty) {
      return _buildEmptyState('此句子没有可用的句法树数据。');
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase,
        borderRadius: BorderRadius.circular(24.wMin),
        border: Border.all(color: AppTheme.cBorderTranslucentThin, width: 1.wMin),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
            return const SizedBox.shrink();
          }
          final _SyntaxTreePosFormResolver resolver = _SyntaxTreePosFormResolver(
            posForms: posForms,
              colorConfigs: colorConfigs,
            treeOnlyTitles: _treeOnlyTitles,
          );
          final _SyntaxTreeLayoutResult? layout = _buildLayout(
            parse: parse,
            tokens: tokens,
            resolver: resolver,
            showInternal: _showInternal,
          );
          if (layout == null) {
            return _buildEmptyState('解析句法树时出错');
          }
          final Size viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
          final double fitScale = _fitScaleFor(viewportSize, layout.contentSize);
          _scheduleFit(viewportSize, layout.contentSize, parse, fitScale);
          return ClipRRect(
            borderRadius: BorderRadius.circular(24.wMin),
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    transformationController: _transformController,
                    minScale: math.min(0.25, fitScale),
                    maxScale: 3,
                    boundaryMargin: EdgeInsets.symmetric(
                      horizontal: layout.contentSize.width,
                      vertical: layout.contentSize.height,
                    ),
                    constrained: false,
                    child: SizedBox(
                      width: layout.contentSize.width,
                      height: layout.contentSize.height,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CustomPaint(
                            size: layout.contentSize,
                            painter: _SyntaxTreePainter(layout: layout),
                          ),
                          ...layout.nodes.where((node) => node.isInternal && _showInternal).map((node) {
                            return Positioned(
                              left: node.labelLeft,
                              top: node.center.dy - 12.wMin,
                              child: Text(
                                node.internalTitleZh,
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  fontWeight: FontWeight.w600,
                                  color: node.chipColor.text,
                                ),
                              ),
                            );
                          }),
                          ...layout.nodes.where((node) => node.isLeaf).map((node) {
                            return Positioned(
                              left: node.chipLeft,
                              top: node.center.dy - _SyntaxTreeLayoutMetrics.chipHeight / 2,
                              child: _buildLeafNode(node, resolver),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16.wMin,
                  bottom: 16.wMin,
                  child: Column(
                    spacing: 12.wMin,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                         TapScaleWidget(
                        sclae: 1.01,
                        onTap: () => setState(() => _showInternal = !_showInternal),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 8.wMin),
                          decoration: BoxDecoration(
                            color: AppTheme.cSurfaceTranslucentElevated.color,
                            borderRadius: BorderRadius.circular(999.wMin),
                            border: Border.all(
                              color: AppTheme.cBorderTranslucentThin.color,
                              width: 1.wMin,
                            ),
                          ),
                          child: Text(
                            _showInternal ? '隐藏短语标签' : '显示短语标签',
                            style: TextStyle(
                              fontSize: 16.wMin,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.cTextPrimary,
                            ),
                          ),
                        ),
                      ),
                   
                      TapScaleWidget(
                    sclae: 1.01,
                    onTap: _resetView,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 8.wMin),
                      decoration: BoxDecoration(
                        color: AppTheme.cSurfaceTranslucentElevated.color,
                        borderRadius: BorderRadius.circular(999.wMin),
                        border: Border.all(
                          color: AppTheme.cBorderTranslucentThin.color,
                          width: 1.wMin,
                        ),
                      ),
                      child: Text(
                        '重置视图',
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextPrimary,
                        ),
                      ),
                    ),
                  )
                    ],
                  ),
                ),
              ],
            ),
          );
      
        },
      ),
    );
  
  }

  Widget _buildEmptyState(String text) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 22.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextPrimary,
        ),
      ),
    );
  }

  Widget _buildLeafNode(
    _SyntaxTreeLayoutNode node,
    _SyntaxTreePosFormResolver resolver,
  ) {
    return TapScaleWidget(
      sclae: 1.01,
      onTap: () => _openTokenDialog(node, resolver),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: _SyntaxTreeLayoutMetrics.chipHeight,
            padding: EdgeInsets.symmetric(horizontal: 14.wMin),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: node.chipColor.background,
              borderRadius: BorderRadius.circular(6.wMin),
              border: Border.all(
                color: node.chipColor.border,
                width: 1.wMin,
              ),
            ),
            child: Text(
              node.posTitleZh,
              style: TextStyle(
                fontSize: 19.wMin,
                fontWeight: FontWeight.w600,
                color: node.chipColor.text,
              ),
            ),
          ),
          if ((node.word ?? '').isNotEmpty) SizedBox(width: 8.wMin),
          if ((node.word ?? '').isNotEmpty)
            Container(
              height: _SyntaxTreeLayoutMetrics.chipHeight,
              padding: EdgeInsets.symmetric(horizontal: 14.wMin),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(6.wMin),
              ),
              child: Text(
                node.word!,
                style: TextStyle(
                  fontSize: 22.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cStaticWhite,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _scheduleFit(Size viewportSize, Size contentSize, String parse, double fitScale) {
    final String signature =
        '${viewportSize.width.floor()}-${viewportSize.height.floor()}-${contentSize.width.floor()}-${contentSize.height.floor()}-${_showInternal ? 1 : 0}-${parse.hashCode}';
    if (_fitSignature == signature) return;
    _fitSignature = signature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final double translateX = (viewportSize.width - contentSize.width * fitScale) / 2;
      final double translateY = (viewportSize.height - contentSize.height * fitScale) / 2;
      final Matrix4 matrix = Matrix4.identity();
      matrix.translateByDouble(translateX, translateY, 0, 1);
      matrix.scaleByDouble(fitScale, fitScale, fitScale, 1);
      _initialTransform = Matrix4.copy(matrix);
      _transformController.value = Matrix4.copy(matrix);
    });
  }

  void _resetView() {
    _transformController.value = Matrix4.copy(_initialTransform);
  }

  double _fitScaleFor(Size viewportSize, Size contentSize) {
    return math.min(
      (viewportSize.width - 56.wMin) / contentSize.width,
      (viewportSize.height - 56.wMin) / contentSize.height,
    ).clamp(0.01, 3.0);
  }

  _SyntaxTreeLayoutResult? _buildLayout({
    required String parse,
    required List<EnSentenceStructureToken> tokens,
    required _SyntaxTreePosFormResolver resolver,
    required bool showInternal,
  }) {
    try {
      final _SyntaxTreeRawNode root = _SyntaxTreeParser(parse).parse();
      final List<_SyntaxTreeLayoutNode> nodes = [];
      int maxDepth = 0;

      void collect(_SyntaxTreeRawNode raw, int depth) {
        maxDepth = math.max(maxDepth, depth);
        final _SyntaxTreeLeafParts parts = _splitNodeName(raw.name);
        nodes.add(
          _SyntaxTreeLayoutNode(
            name: raw.name,
            ptb: parts.ptb,
            word: parts.word,
            depth: depth,
            rawNode: raw,
          ),
        );
        for (final _SyntaxTreeRawNode child in raw.children) {
          collect(child, depth + 1);
        }
      }

      collect(root, 0);
      final Map<_SyntaxTreeRawNode, _SyntaxTreeLayoutNode> byRaw = {
        for (final _SyntaxTreeLayoutNode node in nodes) node.rawNode: node,
      };
      for (final _SyntaxTreeLayoutNode node in nodes) {
        node.children = node.rawNode.children.map((child) => byRaw[child]!).toList();
      }
      final List<_SyntaxTreeLayoutNode> leaves = nodes.where((node) => node.isLeaf).toList();
      for (int index = 0; index < leaves.length; index++) {
        leaves[index].leafIndex = index;
        leaves[index].token = _resolveToken(tokens, index, leaves[index].ptb, leaves[index].word);
      }
      double maxInternalLabelWidth = 0;
      if (showInternal) {
        for (final _SyntaxTreeLayoutNode node in nodes.where((node) => node.isInternal)) {
          final String title = resolver.title(node.ptb, 'zh');
          final double width = _measureText(
            title,
            TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w600,
            ),
          );
          if (width > maxInternalLabelWidth) maxInternalLabelWidth = width;
        }
      }
      final double depthGap = showInternal
          ? math.max(_SyntaxTreeLayoutMetrics.depthGapBare, maxInternalLabelWidth + 32.wMin)
          : _SyntaxTreeLayoutMetrics.depthGapBare;
      final double leftInset = showInternal ? maxInternalLabelWidth + 28.wMin : 24.wMin;

      for (int index = 0; index < leaves.length; index++) {
        final _SyntaxTreeLayoutNode leaf = leaves[index];
        leaf.center = Offset(
          leftInset + leaf.depth * depthGap,
          _SyntaxTreeLayoutMetrics.topInset + index * _SyntaxTreeLayoutMetrics.rowGap,
        );
      }

      void assignInternal(_SyntaxTreeLayoutNode node) {
        for (final _SyntaxTreeLayoutNode child in node.children) {
          assignInternal(child);
        }
        if (node.isInternal) {
          final _SyntaxTreeLayoutNode first = node.children.first;
          final _SyntaxTreeLayoutNode last = node.children.last;
          node.center = Offset(
            leftInset + node.depth * depthGap,
            (first.center.dy + last.center.dy) / 2,
          );
        }
      }

      assignInternal(byRaw[root]!);

      double contentWidth = 0;
      for (final _SyntaxTreeLayoutNode node in nodes) {
        node.internalTitleZh = resolver.title(node.ptb, 'zh');
        node.internalTitleEn = resolver.title(node.ptb, 'en');
        node.chipColor = resolver.color(node.ptb);
        if (node.isLeaf) {
          final double posWidth = _measureChipWidth(
            node.posTitleZh,
            fontSize: 19.wMin,
            fontWeight: FontWeight.w600,
          );
          final double wordWidth = (node.word ?? '').isEmpty
              ? 0
              : _measureChipWidth(
                  node.word!,
                  fontSize: 22.wMin,
                  fontWeight: FontWeight.w600,
                );
          node.chipLeft = node.center.dx + 10.wMin;
          node.chipWidth = posWidth + ((node.word ?? '').isEmpty ? 0 : 8.wMin + wordWidth);
          contentWidth = math.max(contentWidth, node.chipLeft + node.chipWidth + 28.wMin);
          continue;
        }
        final double labelWidth = _measureText(
          node.internalTitleZh,
          TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w600,
          ),
        );
        node.labelLeft = node.center.dx - 12.wMin - labelWidth;
      }

      final double contentHeight =
          _SyntaxTreeLayoutMetrics.topInset + math.max(leaves.length - 1, 0) * _SyntaxTreeLayoutMetrics.rowGap + 80.wMin;
      final double minWidth = leftInset + maxDepth * depthGap + 220.wMin;
      return _SyntaxTreeLayoutResult(
        nodes: nodes,
        root: byRaw[root]!,
        contentSize: Size(math.max(contentWidth, minWidth), contentHeight),
      );
    } catch (_) {
      return null;
    }
  }

  EnSentenceStructureToken? _resolveToken(
    List<EnSentenceStructureToken> tokens,
    int leafIndex,
    String ptb,
    String? word,
  ) {
    final EnSentenceStructureToken? byIndex = leafIndex >= 0 && leafIndex < tokens.length ? tokens[leafIndex] : null;
    if (byIndex != null &&
        ((word ?? '').isEmpty || byIndex.text == word) &&
        (ptb.isEmpty || (byIndex.pos ?? '').isEmpty || byIndex.pos == ptb)) {
      return byIndex;
    }
    if ((word ?? '').isNotEmpty) {
      for (final EnSentenceStructureToken token in tokens) {
        if (token.text == word && token.pos == ptb) return token;
      }
      for (final EnSentenceStructureToken token in tokens) {
        if (token.text == word) return token;
      }
    }
    return byIndex;
  }

  Future<void> _openTokenDialog(
    _SyntaxTreeLayoutNode node,
    _SyntaxTreePosFormResolver resolver,
  ) {
    final EnSentenceStructureToken? token = node.token;
    final String word = token?.text ?? node.word ?? '—';
    final String lemma = token?.lemma ?? '—';
    final String zhTitle = resolver.title(node.ptb, 'zh');
    final String enTitle = resolver.title(node.ptb, 'en');
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return DialogUserWidget(
          title: word,
          width: 720.wMin,
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.fromLTRB(32.wMin, 0, 32.wMin, 32.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogRow('原形', lemma),
                  SizedBox(height: 12.wMin),
                  _buildDialogPosRow(node.ptb, zhTitle, enTitle, node.chipColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72.wMin,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogPosRow(
    String ptb,
    String zhTitle,
    String enTitle,
    _SyntaxTreeChipColor chipColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72.wMin,
          child: Text(
            '词性',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                decoration: BoxDecoration(
                  color: chipColor.background,
                  borderRadius: BorderRadius.circular(6.wMin),
                  border: Border.all(
                    color: chipColor.border,
                    width: 1.wMin,
                  ),
                ),
                child: Text(
                  ptb,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w600,
                    color: chipColor.text,
                  ),
                ),
              ),
              SizedBox(height: 8.wMin),
              Text(
                zhTitle,
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary,
                ),
              ),
              SizedBox(height: 4.wMin),
              Text(
                enTitle,
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SyntaxTreePainter extends CustomPainter {
  final _SyntaxTreeLayoutResult layout;

  const _SyntaxTreePainter({
    required this.layout,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linkPaint = Paint()
      ..color = const Color(0xFF4B5563)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.wMin;
    for (final _SyntaxTreeLayoutNode node in layout.nodes) {
      for (final _SyntaxTreeLayoutNode child in node.children) {
        final Path path = Path()
          ..moveTo(node.center.dx, node.center.dy)
          ..cubicTo(
            (node.center.dx + child.center.dx) / 2,
            node.center.dy,
            (node.center.dx + child.center.dx) / 2,
            child.center.dy,
            child.center.dx,
            child.center.dy,
          );
        canvas.drawPath(path, linkPaint);
      }
    }
    for (final _SyntaxTreeLayoutNode node in layout.nodes) {
      final Paint circlePaint = Paint()
        ..color = node.chipColor.text
        ..style = PaintingStyle.fill;
      canvas.drawCircle(node.center, 7.wMin, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SyntaxTreePainter oldDelegate) {
    return oldDelegate.layout != layout;
  }
}

class _SyntaxTreeLayoutMetrics {
  static double get rowGap => 112.wMin;
  static double get depthGapBare => 104.wMin;
  static double get chipHeight => 38.wMin;
  static double get topInset => 86.wMin;
}

class _SyntaxTreeLayoutResult {
  final List<_SyntaxTreeLayoutNode> nodes;
  final _SyntaxTreeLayoutNode root;
  final Size contentSize;

  const _SyntaxTreeLayoutResult({
    required this.nodes,
    required this.root,
    required this.contentSize,
  });
}

class _SyntaxTreeLayoutNode {
  final String name;
  final String ptb;
  final String? word;
  final int depth;
  final _SyntaxTreeRawNode rawNode;
  List<_SyntaxTreeLayoutNode> children = const [];
  Offset center = Offset.zero;
  int leafIndex = -1;
  double chipLeft = 0;
  double chipWidth = 0;
  double labelLeft = 0;
  String internalTitleZh = '';
  String internalTitleEn = '';
  _SyntaxTreeChipColor chipColor = _SyntaxTreeChipColor.fallback();
  EnSentenceStructureToken? token;

  _SyntaxTreeLayoutNode({
    required this.name,
    required this.ptb,
    required this.word,
    required this.depth,
    required this.rawNode,
  });

  bool get isLeaf => children.isEmpty;
  bool get isInternal => children.isNotEmpty;
  String get posTitleZh => internalTitleZh;
}

class _SyntaxTreeRawNode {
  final String name;
  final List<_SyntaxTreeRawNode> children;

  const _SyntaxTreeRawNode({
    required this.name,
    this.children = const [],
  });
}

class _SyntaxTreeLeafParts {
  final String ptb;
  final String? word;

  const _SyntaxTreeLeafParts({
    required this.ptb,
    this.word,
  });
}

class _SyntaxTreeTitle {
  final String zh;
  final String en;

  const _SyntaxTreeTitle({
    required this.zh,
    required this.en,
  });
}

class _SyntaxTreeChipColor {
  final Color background;
  final Color text;
  final Color border;

  const _SyntaxTreeChipColor({
    required this.background,
    required this.text,
    required this.border,
  });

  factory _SyntaxTreeChipColor.fallback() {
    return const _SyntaxTreeChipColor(
      background: Color(0x3861646A),
      text: Color(0xFF94A3B8),
      border: Color(0xFF61646A),
    );
  }
}

class _SyntaxTreePosFormResolver {
  final Map<String, EnSentenceStructurePosForm> _posFormsByPtb;
  final LanguageConfigColorEntity? colorConfigs;
  final Map<String, _SyntaxTreeTitle> treeOnlyTitles;

  _SyntaxTreePosFormResolver({
    required List<EnSentenceStructurePosForm> posForms,
    required this.colorConfigs,
    required this.treeOnlyTitles,
  }) : _posFormsByPtb = {
          for (final EnSentenceStructurePosForm form in posForms)
            if ((form.ptb ?? '').isNotEmpty) form.ptb!.toUpperCase(): form,
        };

  EnSentenceStructurePosForm? lookup(String? ptb) {
    if ((ptb ?? '').isEmpty) return null;
    return _posFormsByPtb[ptb!.toUpperCase()];
  }

  String title(String? ptb, String lang) {
    final LanguageConfigColorEntityInfo? config = _findSyntaxConfigItem(colorConfigs, ptb);
    if (config != null) {
      if (lang == 'en' && (config.englishName ?? '').isNotEmpty) {
        return config.englishName!;
      }
      if ((config.title ?? '').isNotEmpty) {
        return config.title!;
      }
    }
    final EnSentenceStructurePosForm? row = lookup(ptb);
    if (row != null) {
      for (final LanguageText item in (row.title ?? <LanguageText?>[]).whereType<LanguageText>()) {
        if ((item.lang ?? '').toLowerCase() == lang.toLowerCase()) {
          return (item.text ?? '').trim();
        }
      }
      final LanguageText? first = (row.title ?? <LanguageText?>[]).whereType<LanguageText>().firstOrNull;
      if (first != null) return (first.text ?? '').trim();
    }
    final _SyntaxTreeTitle? fallback = ptb == null ? null : treeOnlyTitles[ptb];
    if (fallback != null) {
      return lang == 'en' ? fallback.en : fallback.zh;
    }
    return ptb ?? '';
  }

  _SyntaxTreeChipColor color(String? ptb) {
    final LanguageConfigColorEntityInfo? config = _findSyntaxConfigItem(colorConfigs, ptb);
    final Color? configColor = ColorUtils.parseColor(config?.color?.textColor);
    if (configColor != null) {
      return _SyntaxTreeChipColor(
        background: configColor.withValues(alpha: 0.22),
        text: configColor,
        border: configColor.withValues(alpha: 0.30),
      );
    }
    final EnSentenceStructurePosForm? row = lookup(ptb);
    if (row == null) return _SyntaxTreeChipColor.fallback();
    final Color primaryColor = ColorUtils.parseColor(row.color?.textColor) ?? const Color(0xFF94A3B8);
    final Color borderColor = ColorUtils.parseColor(row.color?.borderColor) ?? primaryColor;
    return _SyntaxTreeChipColor(
      background: primaryColor.withValues(alpha: 0.22),
      text: primaryColor,
      border: borderColor,
    );
  }
}

class _SyntaxTreeParser {
  final String source;
  int index = 0;

  _SyntaxTreeParser(String raw)
      : source = raw.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

  _SyntaxTreeRawNode parse() {
    _skipSpaces();
    final _SyntaxTreeRawNode node = _parseNode();
    _skipSpaces();
    return node;
  }

  _SyntaxTreeRawNode _parseNode() {
    _skipSpaces();
    if (_currentChar() != '(') {
      throw StateError('Expected "(" at $index');
    }
    index += 1;
    _skipSpaces();
    final String label = _readUntil(<String>{' ', ')', '('});
    _skipSpaces();
    if (_currentChar() == '(') {
      final List<_SyntaxTreeRawNode> children = [];
      while (_currentChar() == '(') {
        children.add(_parseNode());
        _skipSpaces();
      }
      if (_currentChar() != ')') {
        throw StateError('Expected ")" at $index');
      }
      index += 1;
      return _SyntaxTreeRawNode(name: label, children: children);
    }
    final String value = _readUntil(<String>{')'}).trim();
    if (_currentChar() == ')') {
      index += 1;
    }
    return _SyntaxTreeRawNode(name: value.isEmpty ? label : '$label $value');
  }

  void _skipSpaces() {
    while (index < source.length && source[index] == ' ') {
      index += 1;
    }
  }

  String _readUntil(Set<String> chars) {
    final int start = index;
    while (index < source.length && !chars.contains(source[index])) {
      index += 1;
    }
    return source.substring(start, index);
  }

  String? _currentChar() {
    if (index >= source.length) return null;
    return source[index];
  }
}

_SyntaxTreeLeafParts _splitNodeName(String name) {
  final String trimmed = name.trim();
  final int spaceIndex = trimmed.indexOf(' ');
  if (spaceIndex < 0) {
    return _SyntaxTreeLeafParts(ptb: trimmed);
  }
  return _SyntaxTreeLeafParts(
    ptb: trimmed.substring(0, spaceIndex),
    word: trimmed.substring(spaceIndex + 1),
  );
}

double _measureText(String text, TextStyle style) {
  if (text.isEmpty) return 0;
  final TextPainter painter = TextPainter(
    text: TextSpan(
      text: text,
      style: style,
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  return painter.width;
}

double _measureChipWidth(
  String text, {
  required double fontSize,
  required FontWeight fontWeight,
}) {
  return _measureText(
        text,
        TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ) +
      28.wMin;
}

LanguageConfigColorEntity? _colorConfigsOrNull() {
  if (!Get.isRegistered<ConfigController>()) return null;
  return Get.find<ConfigController>().colorConfigs.value;
}

LanguageConfigColorEntityInfo? _findConfigItem(
  List<LanguageConfigColorEntityInfo?>? items,
  String? code,
) {
  if ((code ?? '').isEmpty) return null;
  for (final LanguageConfigColorEntityInfo item in (items ?? <LanguageConfigColorEntityInfo?>[]).whereType<LanguageConfigColorEntityInfo>()) {
    if ((item.code ?? '').toLowerCase() == code!.toLowerCase()) {
      return item;
    }
  }
  return null;
}

LanguageConfigColorEntityInfo? _findSyntaxConfigItem(
  LanguageConfigColorEntity? configs,
  String? code,
) {
  return _findConfigItem(configs?.chunkTypes, code) ;
}
