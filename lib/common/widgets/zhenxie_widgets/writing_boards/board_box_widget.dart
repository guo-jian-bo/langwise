import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../entities/entities.dart';
import '../../../enum/enum.dart';
import '../../widgets.dart';
import 'writing_boards.dart';

class BoardBoxWidget extends StatefulWidget {
  final WritingBoardData data;
  final bool isManagement;
  final WritingBoardRuntimeState? runtimeState;
  final WritingBoardControllers? controllers;
  final WritingBoardFrameSectionType? highlightedFrameSection;
  final void Function(WritingBoardFrameSectionType type)? onTapFrameSection;
  final void Function(String beatNid)? onTapStep;
  final void Function(String beatNid)? onSelectBeatNid;
  final void Function(String beatNid)? onRequestStepFocus;
  final void Function(String beatNid, String text)? onStepTextChanged;
  final void Function(String text)? onHeadChanged;
  final void Function(String text)? onTailChanged;
  final void Function(List<WritingBoardMediaItemData> items)? onImageItemsChanged;
  final void Function(List<WritingBoardMediaItemData> items)? onVideoItemsChanged;
  final void Function(List<WritingBoardMediaItemData> items)? onAudioItemsChanged;
  const BoardBoxWidget({
    super.key,
    required this.data,
    this.isManagement = false,
    this.runtimeState,
    this.controllers,
    this.highlightedFrameSection,
    this.onTapFrameSection,
    this.onTapStep,
    this.onSelectBeatNid,
    this.onRequestStepFocus,
    this.onStepTextChanged,
    this.onHeadChanged,
    this.onTailChanged,
    this.onImageItemsChanged,
    this.onVideoItemsChanged,
    this.onAudioItemsChanged,
  });

  @override
  State<BoardBoxWidget> createState() => _BoardBoxWidgetState();
}

class _BoardBoxWidgetState extends State<BoardBoxWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: _buildBodyWidget(),
    );
  }

  Widget _buildBodyWidget() {
    // 媒体作答优先走上传板，不再被文本皮肤板式截断成正文输入。
    if (!widget.data.answerKindEnum.isText) {
      return WritLookImageWidget(
        data: widget.data,
        isManagement: widget.isManagement,
        controllers: widget.controllers,
        highlightedFrameSection: widget.highlightedFrameSection,
        onTapFrameSection: widget.onTapFrameSection,
        onTapStep: widget.onTapStep,
        onSelectBeatNid: widget.onSelectBeatNid,
        onRequestStepFocus: widget.onRequestStepFocus,
        onStepTextChanged: widget.onStepTextChanged,
        onHeadChanged: widget.onHeadChanged,
        onTailChanged: widget.onTailChanged,
        onImageItemsChanged: widget.onImageItemsChanged,
        onVideoItemsChanged: widget.onVideoItemsChanged,
        onAudioItemsChanged: widget.onAudioItemsChanged,
      );
    }

    if (widget.data.writingBoardTextMode == ZhenxieTaskTextSubmitModeEnum.paper) {
      return BoardBoxPaperPhotoWidget(
        mediaData: widget.data.paperImageAnswer,
        materials: widget.data.materials,
        mode: widget.data.mode,
        onItemsChanged: widget.onImageItemsChanged,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardBody = _buildBoxWidget(viewportHeight: constraints.maxHeight);
        return _buildScrollableTextBoard(boardBody, viewportHeight: constraints.maxHeight);
      },
    );
  }

  Widget _buildBoxWidget({double? viewportHeight}) {
    SkinNidEnum skinNid = SkinNidEnum.fromSkinNid(widget.data.skinNid ?? '');
    Widget textContentWidget = _buildTextContentWidget();
    Widget? boardWidget;

    if (skinNid == SkinNidEnum.sticky_note) {
      boardWidget = BoardNoteWidget(child: textContentWidget);
    } else if (skinNid == SkinNidEnum.name_tag) {
      boardWidget = BoardLabelPaperWidget(child: textContentWidget);
    } else if (skinNid == SkinNidEnum.form_blank) {
      boardWidget = BoardTablePaperWidget(child: textContentWidget); // 标签(填写)
    } else if (skinNid == SkinNidEnum.profile_card) {
      boardWidget = BoardTitleBandPaper(child: textContentWidget);
    } else if (skinNid == SkinNidEnum.email_client) {
      boardWidget = BoardNowMessangeWidget(child: textContentWidget);
    } else if (skinNid == SkinNidEnum.letter_paper) {
      boardWidget = BoardNoisePaperWidget(
        showRuleLines: true,
        child: textContentWidget,
      );
    } else if (skinNid == SkinNidEnum.message_slip) {
      boardWidget = BoardMessageNotePaperWidget(child: textContentWidget);
    } else if (skinNid == SkinNidEnum.diary_notebook) {
      boardWidget = BoardDiaryPaperWidget(child: textContentWidget);
    } else if (skinNid == SkinNidEnum.textbook_page) {
      boardWidget = BoardUnitPaperWidget(
        child: textContentWidget,
      );
    } else if (skinNid == SkinNidEnum.report_paper) {
      boardWidget = BoardReportPaperWidget(child: textContentWidget);
    } else if (skinNid == SkinNidEnum.bulletin_board) {
      boardWidget = BoardNoisePaperWidget(
        showPin: true,
        child: textContentWidget,
      );
    } else if (skinNid == SkinNidEnum.speech_card) {
      boardWidget = BoardSpeechWidget(child: textContentWidget);
    } else if (skinNid == SkinNidEnum.newspaper_column) {
      boardWidget = BoardSchoolTimesWidget(child: textContentWidget);
    } else if (skinNid == SkinNidEnum.storybook_spread) {
      boardWidget = BoardNoisePaperWidget(child: textContentWidget);
    } else if (skinNid == SkinNidEnum.picture_page) {
      boardWidget = BoardNoisePaperWidget(child: textContentWidget);
    } else {
      boardWidget = BoardNoisePaperWidget(child: textContentWidget);
    }

    return _buildBoardWithMaterials(boardWidget, viewportHeight: viewportHeight);
  }

  /// 给文本皮肤稿纸补上顶部题干素材区。
  Widget _buildBoardWithMaterials(Widget child, {double? viewportHeight}) {
    if (widget.data.materials.isEmpty) return child;
    return WritingBoardMaterialsFillLayout(
      viewportHeight: viewportHeight ?? 0,
      materials: widget.data.materials,
      child: child,
    );
  }

  /// 文本稿纸统一由外层接管滚动和键盘避让，皮肤壳子只负责样式展示。
  Widget _buildScrollableTextBoard(Widget child, {required double viewportHeight}) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(left: MediaQuery.of(context).padding.left),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: viewportHeight),
            child: IntrinsicHeight(
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// 根据渲染数据决定正文区使用纯正文还是首尾结构。
  Widget _buildTextContentWidget() {
    final useHeadTailWidget = widget.data.showHead || widget.data.showTail;
    if (!useHeadTailWidget) {
      return WritJustTextWidget(
        data: widget.data,
        isManagement: widget.isManagement,
        runtimeState: widget.runtimeState,
        controllers: widget.controllers,
        onTapStep: widget.onTapStep,
        onSelectBeatNid: widget.onSelectBeatNid,
        onRequestStepFocus: widget.onRequestStepFocus,
        onStepTextChanged: widget.onStepTextChanged,
      );
    }

    final headLabel = widget.data.headLabel ?? '';
    bool isTitleHeadStyle = widget.data.showHead && (headLabel.contains('标题') || headLabel.toLowerCase().contains('title'));

    return WritHeadTailWidget(
      data: widget.data,
      isManagement: widget.isManagement,
      controllers: widget.controllers,
      highlightedFrameSection: widget.highlightedFrameSection,
      useTitleHeadStyle: isTitleHeadStyle,
      onTapFrameSection: widget.onTapFrameSection,
      onTapStep: widget.onTapStep,
      onSelectBeatNid: widget.onSelectBeatNid,
      onRequestStepFocus: widget.onRequestStepFocus,
      onStepTextChanged: widget.onStepTextChanged,
      onHeadChanged: widget.onHeadChanged,
      onTailChanged: widget.onTailChanged,
    );
  }
}

/// 根据素材条真实高度为稿纸壳子补齐剩余最小高度。
class WritingBoardMaterialsFillLayout extends StatefulWidget {
  final double viewportHeight;
  final List<WritingBoardMaterialData> materials;
  final Widget child;

  const WritingBoardMaterialsFillLayout({
    super.key,
    required this.viewportHeight,
    required this.materials,
    required this.child,
  });

  @override
  State<WritingBoardMaterialsFillLayout> createState() => _WritingBoardMaterialsFillLayoutState();
}

class _WritingBoardMaterialsFillLayoutState extends State<WritingBoardMaterialsFillLayout> {
  /// 素材条节点 key，用来回读真实渲染高度。
  final GlobalKey _materialsKey = GlobalKey();

  /// 当前素材条真实高度。
  double _materialsHeight = 0;

  @override
  void initState() {
    super.initState();
    _scheduleMeasureMaterialsHeight();
  }

  @override
  void didUpdateWidget(covariant WritingBoardMaterialsFillLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewportHeight != widget.viewportHeight || oldWidget.materials != widget.materials) {
      _scheduleMeasureMaterialsHeight();
    }
  }

  @override
  Widget build(BuildContext context) {
    final minBoardHeight = (widget.viewportHeight - _materialsHeight).clamp(0.0, double.infinity).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        KeyedSubtree(
          key: _materialsKey,
          child: WritingBoardMaterialsStripWidget(materials: widget.materials),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: minBoardHeight),
          child: widget.child,
        ),
      ],
    );
  }

  /// 等素材条布局完成后读取真实高度。
  void _scheduleMeasureMaterialsHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final currentContext = _materialsKey.currentContext;
      if (currentContext == null) return;
      final renderBox = currentContext.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) return;
      final nextHeight = renderBox.size.height;
      if ((_materialsHeight - nextHeight).abs() < 0.5) return;
      setState(() {
        _materialsHeight = nextHeight;
      });
    });
  }
}

class BoardBoxPaperPhotoWidget extends StatefulWidget {
  final WritingBoardMediaAnswerData? mediaData;
  final WritingBoardModeEnum mode;

  /// 当前题干顶部素材列表。
  final List<WritingBoardMaterialData> materials;
  final void Function(List<WritingBoardMediaItemData> items)? onItemsChanged;

  /// 写在纸上
  const BoardBoxPaperPhotoWidget({
    super.key,
    this.mediaData,
    this.mode = WritingBoardModeEnum.task,
    this.materials = const [],
    this.onItemsChanged,
  });

  @override
  State<BoardBoxPaperPhotoWidget> createState() => _BoardBoxPaperPhotoWidgetState();
}

class _BoardBoxPaperPhotoWidgetState extends State<BoardBoxPaperPhotoWidget> {
  /// 是否展开说明
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    double leftPadding = MediaQuery.of(context).padding.left;
    EdgeInsets increasePadding = EdgeInsets.only(left: leftPadding);
    return Container(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: increasePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (widget.materials.isNotEmpty) WritingBoardMaterialsStripWidget(materials: widget.materials),
            _buildTipWidget(),
            WritImageUploadWidget(
              mediaData: widget.mediaData ??
                  WritingBoardMediaAnswerData(
                    kind: ZhenxieTaskAnswerKindEnum.image.value,
                    maxCount: 3,
                    minCount: 1,
                  ),
              title: '纸面照片',
              subTitle: widget.mode == WritingBoardModeEnum.correction ? '' : '作业本、白纸都行',
              mode: widget.mode,
              onItemsChanged: widget.onItemsChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.wMin, vertical: 40.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        children: [
          _buildTipTitleWidget(),
          AnimatedCrossFade(
            duration: Duration(milliseconds: 200),
            crossFadeState: _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            secondChild: Container(),
            firstChild: Container(
              padding: EdgeInsets.only(
                left: 16.wMin,
                right: 16.wMin,
                bottom: 16.wMin,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTipTextsWidget(),
                  ),
                  _buildTipImageWidget(
                    svg: 'assets/svg/public/zhenxie_write_demo1.svg',
                    text: '这样拍',
                    text2: ' 整页放平，字都在里面',
                    color: AppTheme.cZhenxieColorPrimary.color,
                  ),
                  SizedBox(width: 24.wMin),
                  _buildTipImageWidget(
                    svg: 'assets/svg/public/zhenxie_write_demo2.svg',
                    text: '别这样拍',
                    text2: ' 拍斜了，字被切掉',
                    color: AppTheme.cZhenxieColorSecondary.color,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipTitleWidget() {
    Widget rightWidget = Text(
      '照着做批改更准，不照做也能交',
      style: TextStyle(
        fontSize: 18.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cZhenxieFontSecondary.color,
      ),
    );
    if (widget.mode == WritingBoardModeEnum.correction) {
      rightWidget = Row(
        children: [
          Text(
            _isExpanded ? "收起" : "展开",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary.color,
            ),
          ),
          SizedBox(width: 8.wMin),
          AnimatedRotation(
            duration: Duration(milliseconds: 200),
            turns: _isExpanded ? 0.5 : 0,
            child: SvgPicture.asset(
              'assets/svg/public/icon_arrow_down.svg',
              width: 24.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cZhenxieFontTertiary.color, BlendMode.srcIn),
            ),
          ),
        ],
      );
    }

    bool isCorrectionMode = widget.mode == WritingBoardModeEnum.correction;

    return TapScaleWidget(
      onTap: !isCorrectionMode
          ? null
          : () {
              _isExpanded = !_isExpanded;
              if (mounted) setState(() {});
            },
      sclae: 1,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.all(16.wMin),
        child: Row(
          children: [
            Text(
              '纸上怎么写',
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cZhenxieFontTertiary.color,
              ),
            ),
            Spacer(),
            rightWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildTipTextsWidget() {
    List<String> texts = [
      '照平时的习惯分段写。写什么、写几句，看右边的蓝图',
      '题目里已经给出的字不用抄',
      '写错了划掉就行，不用涂掉重写',
      '一页拍不下就按顺序再拍',
    ];
    return Column(
      spacing: 12.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(texts.length, (index) {
        return Row(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8.wMin),
              width: 6.wMin,
              height: 6.wMin,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cZhenxieFontTertiary.color,
              ),
            ),
            Text(
              texts[index],
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontTertiary.color,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTipImageWidget({
    required String svg,
    required String text,
    required String text2,
    required Color color,
  }) {
    return Column(
      children: [
        SvgPicture.asset(
          svg,
          width: 160.wMin,
        ),
        SizedBox(height: 24.wMin),
        Text.rich(TextSpan(
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontTertiary.color,
          ),
          children: [
            TextSpan(
                text: text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 18.wMin,
                )),
            TextSpan(text: text2),
          ],
        )),
      ],
    );
  }
}
