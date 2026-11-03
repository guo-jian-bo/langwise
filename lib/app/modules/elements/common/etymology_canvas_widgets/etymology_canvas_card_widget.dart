import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../theme/theme.dart';
import '../elements_cards/elements_public_card.dart';

class EtymologyCanvasCardWidget extends StatefulWidget {
  const EtymologyCanvasCardWidget({
    super.key,
    this.contentKey,
    this.focusCardKey,
    required this.node,
    this.isActive = false,
    this.activeContentId,
    this.activeSemanticId,
  });

  /// 卡片内容容器 key，供外层画布测量顶部锚点。
  final GlobalKey? contentKey;
  final GlobalKey? focusCardKey;
  final CardContentEtymologyNode node;
  final bool isActive;
  final int? activeContentId;
  final int? activeSemanticId;

  @override
  State<EtymologyCanvasCardWidget> createState() => _EtymologyCanvasCardWidgetState();
}

class _EtymologyCanvasCardWidgetState extends State<EtymologyCanvasCardWidget> {
  @override
  Widget build(BuildContext context) {
    final List<KnowledgeCommonEntityList> senseCards =
        widget.node.senseCards?.whereType<KnowledgeCommonEntityList>().toList() ?? <KnowledgeCommonEntityList>[];
    return Container(
      key: widget.contentKey,
      width: 360.wMin,
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfacePrimary.color,
        borderRadius: BorderRadius.circular(24.wMin),
        border: Border.all(
          color: widget.isActive ? AppTheme.cSurfaceWarning.color : AppTheme.cBorderSubtle.color,
          width: widget.isActive ? 1.2.wMin : 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget(),
          SizedBox(height: 12.wMin),
          Column(
            spacing: 12.wMin,
            children: senseCards.map(_buildCardWidget).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWidget() {
    final String labelText = _findLanguageText(widget.node.label, 'zh');
    final String bubbleText = _findLanguageText(widget.node.bubble, 'zh');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '义项',
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
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
        SizedBox(height: 8.wMin),
        Text(
          labelText,
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.wMin),
        if (bubbleText.isNotEmpty)
          Container(
            height: 60.wMin,
            alignment: Alignment.bottomLeft,
            child: AutoSizeText(
              bubbleText,
              maxLines: 3,
              minFontSize: 4,
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCardWidget(KnowledgeCommonEntityList item) {
    final bool isFocusCard = item.contentId == widget.activeContentId && item.content?.semanticId == widget.activeSemanticId;
    return KeyedSubtree(
      key: isFocusCard ? widget.focusCardKey : null,
      child: SizedBox(
        width: double.infinity,
        height: 534.wMin,
        child: ElementsDictReadCard(
          data: item,
        ),
      ),
    );
  }

  String _findLanguageText(List<LanguageText?>? values, String lang) {
    if (values == null) return '';
    for (final LanguageText? item in values) {
      if (item?.lang == lang) return item?.text ?? '';
    }
    return '';
  }
}
