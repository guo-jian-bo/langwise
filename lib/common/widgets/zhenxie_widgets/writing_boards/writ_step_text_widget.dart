import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../entities/zhenxie_task_details_entity.dart';
import '../../widgets.dart';
import '../zhenxie_knowledge_card_helper.dart';
import 'model/writing_board_data.dart';

class WritStepTextWidget extends StatefulWidget {
  final WritingBoardStepData data;
  final bool showKnowledgeAnchors;
  final bool isManagement;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function(String beatNid)? onTapStep;
  final void Function(String beatNid)? onSelectBeatNid;
  final void Function(String beatNid)? onRequestStepFocus;
  final void Function(String beatNid, String text)? onStepTextChanged;

  /// 单个拍位正文输入 / 展示组件
  const WritStepTextWidget({
    super.key,
    required this.data,
    this.showKnowledgeAnchors = false,
    this.isManagement = false,
    this.controller,
    this.focusNode,
    this.onTapStep,
    this.onSelectBeatNid,
    this.onRequestStepFocus,
    this.onStepTextChanged,
  });

  @override
  State<WritStepTextWidget> createState() => _WritStepTextWidgetState();
}

class _WritStepTextWidgetState extends State<WritStepTextWidget> {
  /// 不同知识点类型对应的下划线颜色。
  static const Map<String, Color> _anchorDecorationColorMap = {
    'EN_WORD': Color(0xFF0EA5E9),
    'EN_PHRASE': Color(0xFFF59E0B),
    'EN_SENTENCE': Color(0xFF8B5CF6),
  };

  /// 当前富文本点击手势集合，重建前需要主动释放。
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];

  /// 当前拍位是否应展示输入框。
  bool get _showInput {
    return widget.data.editable && widget.controller != null && widget.focusNode != null;
  }

  /// 展示态下如果当前拍位被选中，则显示外层描边。
  bool get _showSelectedBorder => widget.data.selected && (!_showInput || !widget.data.focused);

  /// 当前拍位是否需要按知识点锚点渲染下划线。
  bool get _showKnowledgeText {
    return widget.showKnowledgeAnchors && widget.data.knowledgeAnchors.isNotEmpty && (widget.data.text?.isNotEmpty ?? false);
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepWidget(),
        SizedBox(width: 8.wMin),
        Expanded(
          child: _showInput ? _buildInputWidget() : _buildContentWidget(),
        ),
      ],
    );
  }

  Widget _buildStepWidget() {
    final beatColor = widget.data.beatColor ?? const Color(0xff500724);
    final beatTextColor = widget.data.beatTextColor ?? Colors.white;
    return Container(
      margin: EdgeInsets.only(top: 10.wMin),
      child: TapScaleWidget(
        onTap: () {
          widget.onSelectBeatNid?.call(widget.data.beatNid);
          widget.onTapStep?.call(widget.data.beatNid);
        },
        sclae: 1.03,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 49.wMin,
          height: 49.wMin,
          alignment: Alignment.center,
          padding: EdgeInsets.all(2.wMin),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: beatColor.withValues(alpha: widget.data.focused ? 1 : 0),
              width: 2.wMin,
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: beatColor,
            ),
            child: Text(
              widget.data.beatLabel,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                color: beatTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentWidget() {
    final text = widget.data.text ?? '';
    final content = AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(color: const Color(0xff9A3412).withValues(alpha: _showSelectedBorder ? 1 : 0), width: 1.wMin),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.wMin),
        child: _showKnowledgeText ? _buildKnowledgeTextWidget(text) : _buildPlainTextWidget(text),
      ),
    );
    if (_showKnowledgeText) {
      return content;
    }
    return TapScaleWidget(
      onTap: () {
        widget.onSelectBeatNid?.call(widget.data.beatNid);
      },
      sclae: 1,
      child: content,
    );
  }

  /// 构建普通展示态正文。
  Widget _buildPlainTextWidget(String text) {
    String displayText = text;
    if (displayText.isEmpty) {
      displayText = '(范文未挂)';
    }
    return Text(
      displayText,
      style: _buildTextStyle(),
    );
  }

  /// 构建带知识点下划线的富文本。
  Widget _buildKnowledgeTextWidget(String text) {
    final spanList = _buildAnchorSpanList(text);
    if (spanList.isEmpty) {
      return _buildPlainTextWidget(text);
    }
    return RichText(
      text: TextSpan(
        children: spanList,
        style: _buildTextStyle(),
      ),
    );
  }

  /// 生成知识点下划线富文本切片。
  List<InlineSpan> _buildAnchorSpanList(String text) {
    _disposeRecognizers();
    final points = <int>{0, text.length};
    for (final anchor in widget.data.knowledgeAnchors) {
      for (final range in anchor?.ranges ?? const <ZhenxieTaskDetailsEntitySurfaceRange?>[]) {
        final start = range?.start;
        final end = range?.end;
        if (start == null || end == null || end <= start) continue;
        if (start < 0 || end > text.length) continue;
        points.add(start);
        points.add(end);
      }
    }
    final cutList = points.toList()..sort();
    final spanList = <InlineSpan>[];
    for (int index = 0; index < cutList.length - 1; index++) {
      final start = cutList[index];
      final end = cutList[index + 1];
      if (end <= start) continue;
      final sliceText = text.substring(start, end);
      final anchor = _findCoverAnchor(start, end);
      spanList.add(_buildSliceSpan(sliceText, anchor));
    }
    return spanList;
  }

  /// 构建单个文本切片的展示样式。
  InlineSpan _buildSliceSpan(
    String text,
    ZhenxieTaskDetailsEntityContentAnchor? anchor,
  ) {
    final decorationColor = _anchorDecorationColorMap[anchor?.contentType ?? ''];
    TapGestureRecognizer? recognizer;
    if (anchor != null) {
      recognizer = TapGestureRecognizer()
        ..onTap = () async {
          widget.onSelectBeatNid?.call(widget.data.beatNid);
          if (!mounted) return;
          await ZhenxieKnowledgeCardHelper.showKnowledgeCard(
            context: context,
            contentType: anchor.contentType,
            uid: anchor.uid,
            semanticId: anchor.semanticId,
            isManagement: widget.isManagement,
          );
        };
      _recognizers.add(recognizer);
    } else if (widget.showKnowledgeAnchors) {
      recognizer = TapGestureRecognizer()
        ..onTap = () {
          widget.onSelectBeatNid?.call(widget.data.beatNid);
        };
      _recognizers.add(recognizer);
    }
    return TextSpan(
      text: text,
      style: _buildTextStyle().copyWith(
        decoration: anchor == null ? TextDecoration.none : TextDecoration.underline,
        decorationColor: decorationColor,
        decorationThickness: anchor == null ? null : 1.5.wMin,
      ),
      recognizer: recognizer,
    );
  }

  /// 找到完整覆盖当前切片区间的知识点锚点，优先取更短的范围。
  ZhenxieTaskDetailsEntityContentAnchor? _findCoverAnchor(int start, int end) {
    final anchorList = <ZhenxieTaskDetailsEntityContentAnchor>[];
    for (final anchor in widget.data.knowledgeAnchors) {
      if (anchor == null) continue;
      final isCover = (anchor.ranges ?? const <ZhenxieTaskDetailsEntitySurfaceRange?>[]).any((range) {
        final rangeStart = range?.start;
        final rangeEnd = range?.end;
        if (rangeStart == null || rangeEnd == null) return false;
        return rangeStart <= start && end <= rangeEnd;
      });
      if (isCover) {
        anchorList.add(anchor);
      }
    }
    if (anchorList.isEmpty) return null;
    anchorList.sort((a, b) => _calculateAnchorLength(a).compareTo(_calculateAnchorLength(b)));
    return anchorList.first;
  }

  /// 计算锚点总长度，重叠时优先匹配更精确的范围。
  int _calculateAnchorLength(ZhenxieTaskDetailsEntityContentAnchor anchor) {
    int length = 0;
    for (final range in anchor.ranges ?? const <ZhenxieTaskDetailsEntitySurfaceRange?>[]) {
      final start = range?.start;
      final end = range?.end;
      if (start == null || end == null || end <= start) continue;
      length += end - start;
    }
    return length;
  }

  /// 统一的正文文字样式。
  TextStyle _buildTextStyle() {
    return TextStyle(
      fontSize: 28.wMin,
      fontWeight: FontWeight.w400,
      color: const Color(0xff131617),
    );
  }

  /// 释放当前缓存的富文本点击手势，避免重复 build 泄漏。
  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  Widget _buildInputWidget() {
    return TapScaleWidget(
      onTap: () {
        widget.onRequestStepFocus?.call(widget.data.beatNid);
      },
      sclae: 1,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        constraints: BoxConstraints(minHeight: 120.wMin),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(
            color: const Color(0xff9A3412).withValues(alpha: widget.data.focused && _showInput ? 1 : 0),
            width: 1.wMin,
          ),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          maxLines: null,
          minLines: null,
          scrollPhysics: const NeverScrollableScrollPhysics(),
          textAlignVertical: TextAlignVertical.top,
          onTap: () {
            widget.onRequestStepFocus?.call(widget.data.beatNid);
          },
          onChanged: (text) {
            widget.onStepTextChanged?.call(widget.data.beatNid, text);
          },
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w400,
            color: const Color(0xff131617),
          ),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: widget.data.placeholder ?? "写这一拍...",
            contentPadding: EdgeInsets.all(14.wMin),
            hintStyle: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w400,
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
