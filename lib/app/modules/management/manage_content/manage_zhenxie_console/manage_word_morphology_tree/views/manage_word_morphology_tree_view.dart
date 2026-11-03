import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../../elements/common/elements_cards/elements_public_card.dart';
import '../../../../../elements/model/elements_detils_data_model.dart';
import '../bindings/manage_word_morphology_tree_binding.dart';
import '../controllers/manage_word_morphology_tree_controller.dart';

class ManageWordMorphologyTreeView extends GetView<ManageWordMorphologyTreeController> {
  final String tagText;
  const ManageWordMorphologyTreeView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, String? tag}) async {
    final pageTag = tag ?? '${Routes.MANAGE_WORD_MORPHOLOGY_TREE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageWordMorphologyTreeView(tagText: pageTag),
      binding: ManageWordMorphologyTreeBinding(tag: pageTag),
      routeName: Routes.MANAGE_WORD_MORPHOLOGY_TREE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () async {
        await controller.getDetails();
      },
      body: Obx(() {
        WordMorphologyTreeEntity data = controller.detail.value;

        final _MorphologyTreeLayout layout = _buildTreeLayout(data);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BreadcrumbWidget(
              isCompatibleManage: controller.isManagement,
              actionWidget: GeneralSettingButtonWidget(
                isManagement: controller.isManagement,
              ),
            ),
            SizedBox(height: 8.wMin),
            Expanded(
                child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 90.wMin, vertical: 20.wMin),
              child: (controller.isLoading.value) ? Container() : _buildCanvasPanelWidget(data, layout),
            )),
          ],
        );
      }),
    );
  }

  Widget _buildCanvasInfoWidget(WordMorphologyTreeEntity data, _MorphologyTreeLayout layout) {
    final String translate = controller.getLangText(data.translate, 'zh');
    final bool isExpanded = controller.isCanvasInfoExpanded.value;
    if (controller.isLoading.value) {
      return Container();
    }

    return TapScaleWidget(
      sclae: 1.0,
      onTap: controller.toggleCanvasInfoExpanded,
      child: PlatformBackdropFilterWidget(
        sigmaX: 4.wMin,
        sigmaY: 4.wMin,
        child: Container(
          width: 300.wMin,
          padding: EdgeInsets.all(8.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceGhostBgSubtle,
            borderRadius: BorderRadius.circular(16.wMin),
            border: Border.all(
              color: AppTheme.cBorderSubtle,
              width: 1.wMin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '构词树',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                  SizedBox(width: 8.wMin),
                  Expanded(
                    child: Text(
                      data.content ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.wMin),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                    size: 24.wMin,
                    color: AppTheme.cTextSecondary.color,
                  ),
                  SizedBox(width: 10.wMin),
                  if (controller.isManagement && data.contentId != null)
                    CopyTagWidget(
                      name: '词',
                      value: '${data.contentId}',
                    ),
                ],
              ),
              if (isExpanded) ...[
                SizedBox(height: 4.wMin),
                if (translate.isNotEmpty)
                  Text(
                    translate,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                if (translate.isNotEmpty) SizedBox(height: 4.wMin),
                Wrap(
                  spacing: 8.wMin,
                  runSpacing: 8.wMin,
                  children: [
                    if (controller.getPosTitle(data.pos).isNotEmpty)
                      WordInflectionInfoTagWidget(
                        controller.getPosTitle(data.pos),
                        textColor: controller.getPosBorderColor(data.pos),
                        bgColor: controller.getPosBorderColor(data.pos)?.withValues(alpha: 0.12),
                        borderColor: controller.getPosBorderColor(data.pos)?.withValues(alpha: 0.20),
                      ),
                    ...layout.orderedBranches.map((branch) {
                      Color? color = controller.getMorphemeTypeTextColor(branch.type);
                      String typeTitle = controller.getMorphemeTypeTitle(branch.type);
                      bool isFocused = _isFocusedBranch(branch);
                      return WordInflectionInfoTagWidget(
                        typeTitle.isEmpty ? (branch.content ?? '') : '${branch.content ?? ''} · $typeTitle',
                        textColor: color,
                        bgColor: color?.withValues(alpha: isFocused ? 0.18 : 0.12),
                        borderColor: color?.withValues(alpha: isFocused ? 0.36 : 0.20),
                      );
                    }),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCanvasPanelWidget(WordMorphologyTreeEntity data, _MorphologyTreeLayout layout) {
    return Container(
      child: Stack(
        children: [
          Positioned.fill(
            child: _MorphologyTreeCanvasViewport(
              layout: layout,
              resetToken: controller.canvasResetToken.value,
              onInteractionStart: controller.collapseCanvasInfoWidget,
              child: SizedBox(
                width: layout.width,
                height: layout.height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // CustomPaint(
                    //   size: Size(layout.width, layout.height),
                    //   painter: _MorphologyTreeEdgePainter(
                    //     layout: layout,
                    //     getBranchColor: (branch) => controller.getMorphemeTypeTextColor(branch.type),
                    //   ),
                    // ),
                    Positioned.fromRect(
                      rect: layout.rootRect,
                      child: _buildRootCardWidget(data, layout),
                    ),
                    if (layout.explainRect != null)
                      Positioned.fromRect(
                        rect: layout.explainRect!,
                        child: _buildExplainCardWidget(data),
                      ),
                    ...layout.branches.map((branchLayout) => Positioned(
                          left: branchLayout.componentRect.left,
                          top: branchLayout.componentRect.top,
                          width: branchLayout.componentRect.width,
                          height: branchLayout.componentRect.height,
                          child: _buildComponentCardWidget(branchLayout),
                        )),
                    ...layout.branches.where((branchLayout) => branchLayout.leafGroupRect != null).map((branchLayout) => Positioned(
                          left: branchLayout.leafGroupRect!.left,
                          top: branchLayout.leafGroupRect!.top,
                          width: branchLayout.leafGroupRect!.width,
                          height: branchLayout.leafGroupRect!.height,
                          child: _buildLeafGroupWidget(branchLayout),
                        )),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 8.wMin,
            left: 8.wMin,
            child: _buildCanvasInfoWidget(data, layout),
          ),
          Positioned(
            top: 8.wMin,
            right: 8.wMin,
            child: SizedBox(
              width: 200,
              child: Column(
                children: [
                  PlatformBackdropFilterWidget(
                      sigmaX: 4.wMin,
                      sigmaY: 4.wMin,
                      child: ButtonWidget(
                        text: "适应画布",
                        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
                        color: AppTheme.cSurfaceGhostBgSubtle,
                        border: Border.all(
                          color: AppTheme.cBorderSubtle,
                          width: 1.wMin,
                        ),
                        fontSize: 20.wMin,
                        fontColor: AppTheme.cTextSecondary.color,
                        fontWeight: FontWeight.w500,
                        sclae: 1.03,
                        onTap: () {
                          controller.collapseCanvasInfoWidget();
                          controller.requestCanvasReset();
                        },
                      )),
                  SizedBox(height: 12.wMin),
                  Text(
                    '可拖拽移动 · 捏合缩放',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cTextSecondary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRootCardWidget(WordMorphologyTreeEntity data, _MorphologyTreeLayout layout) {
    final String translate = controller.getPreferredText(data.translate);
    final List<_MorphologyHighlightChunk> chunks = _splitByComponents(data.content ?? '', layout.orderedBranches);

    return GestureDetector(
      onTap: () {
        controller.jumpToWordDetail(data.contentId);
      },
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '当前词',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextTertiary,
              ),
            ),
            SizedBox(height: 4.wMin),
            RichText(
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: chunks.map((chunk) => _buildWordChunkSpan(chunk, _rootWordFontSize(data.content ?? ''))).toList(),
              ),
            ),
            if (translate.isNotEmpty) ...[
              SizedBox(height: 4.wMin),
              Text(
                translate,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExplainCardWidget(WordMorphologyTreeEntity data) {
    final String description = controller.getDescription();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(
          color: AppTheme.cBorderTranslucentDefault,
          width: 1.wMin,
        ),
        color: AppTheme.cSurfaceTranslucentElevated,
      ),
      child: Row(
        children: [
          Container(
            height: 32.wMin,
            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999.wMin),
              border: Border.all(
                color: AppTheme.cBorderTranslucentSubtle,
                width: 1.wMin,
              ),
              color: AppTheme.cSurfaceTranslucentElevated,
            ),
            child: Row(
              children: [
                Text(
                  textAlign: TextAlign.center,
                  '拆词',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary,
                  ),
                )
              ],
            ),
          ),
          SizedBox(width: 12.wMin),
          Expanded(
            child: Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentCardWidget(_TreeBranchLayout layout) {
    final Color color = layout.color ?? AppTheme.cTextPrimary;
    return GestureDetector(
      onTap: () {
        controller.jumpToFamilyPage(layout.branch);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 12.wMin),
        decoration: BoxDecoration(
          color: layout.focused ? color.withValues(alpha: 0.12) : AppTheme.cSurfaceTranslucentBase,
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(
            color: color.withValues(alpha: layout.focused ? 0.36 : 0.2),
            width: 1.wMin,
          ),
          boxShadow: layout.focused
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.16),
                    blurRadius: 36.wMin,
                    offset: Offset(0, 16.wMin),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 2.wMin,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(999.wMin),
                    ),
                  ),
                  SizedBox(width: 8.wMin),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          layout.typeTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w400,
                            color: color,
                          ),
                        ),
                        SizedBox(height: 6.wMin),
                        Text(
                          layout.branch.content ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 32.wMin,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.cTextPrimary,
                          ),
                        ),
                        if (layout.blurb.isNotEmpty) ...[
                          SizedBox(height: 10.wMin),
                          Text(
                            layout.blurb,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18.wMin,
                              color: AppTheme.cTextSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            SizedBox(height: 12.wMin),
            Container(
              height: 32.wMin,
              padding: EdgeInsets.symmetric(horizontal: 8.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999.wMin),
                border: Border.all(
                  color: AppTheme.cBorderTranslucentSubtle,
                  width: 1.wMin,
                ),
                color: AppTheme.cSurfaceTranslucentElevated,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '查看更多',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextPrimary,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppTheme.cTextPrimary,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeafGroupWidget(_TreeBranchLayout layout) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        spacing: 14.wMin,
        children: layout.siblings.map((sibling) => _buildLeafCardWidget(layout, sibling)).toList(),
      ),
    );
  }

  Widget _buildLeafCardWidget(_TreeBranchLayout layout, KnowledgeCommonEntityList sibling) {
    final _MorphologyComponentSpan? span = _findMorphemeSpan(
      sibling.title ?? '',
      layout.branch.content ?? '',
      layout.branch.type,
      layout.branch.key,
    );
    return SizedBox(
      width: double.infinity,
      height: 534.wMin,
      child: ElementsDictReadCard(
        data: sibling,
        isManagement: controller.isManagement,
        sentenceHighlights: span == null
            ? null
            : [
                ElementsDetilsDataHighlightModel(
                  start: span.start,
                  end: span.end,
                  highlightColor: layout.color ?? AppTheme.cSurfaceWarning.color,
                ),
              ],
      ),
    );
  }

  TextSpan _buildWordChunkSpan(_MorphologyHighlightChunk chunk, double fontSize) {
    final Color? highlightColor = controller.getMorphemeTypeTextColor(chunk.type);
    final bool isFocused = chunk.key.isNotEmpty && chunk.key == _focusedKey();
    return TextSpan(
      text: chunk.text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: isFocused ? FontWeight.w700 : FontWeight.w500,
        color: highlightColor ?? AppTheme.cTextPrimary,
      ),
    );
  }

  bool _isFocusedBranch(WordMorphologyTreeBranchEntity branch) {
    String focusKey = _focusedKey();
    if (focusKey.isEmpty) return false;
    return branch.key == focusKey;
  }

  String _focusedKey() {
    if ((controller.morphemeNid ?? '').startsWith('r:')) {
      return controller.morphemeNid ?? '';
    }
    if ((controller.detail.value.focusedMorpheme?.nid ?? '').isNotEmpty) {
      return 'm:${controller.detail.value.focusedMorpheme?.nid ?? ''}';
    }
    return '';
  }

  _MorphologyTreeLayout _buildTreeLayout(WordMorphologyTreeEntity data) {
    final List<WordMorphologyTreeBranchEntity> branches =
        data.branches?.whereType<WordMorphologyTreeBranchEntity>().toList() ?? <WordMorphologyTreeBranchEntity>[];
    final List<WordMorphologyTreeBranchEntity> orderedBranches = _componentsInSurfaceOrder(
      data.content ?? '',
      branches,
    );

    final double componentWidth = 340.wMin;
    final double componentHeight = 210.wMin;
    final double componentGap = 28.wMin;
    final double leafWidth = 334.wMin;
    final double leafHeight = 534.wMin;
    final double leafGap = 14.wMin;
    final double rootHeight = _rootHeight(
      data.content ?? '',
      controller.getPreferredText(data.translate),
    );
    final double explainHeight = 80.wMin;
    final double explainGap = 16.wMin;
    final double componentTopGap = 24.wMin;
    final double leafTopGap = 20.wMin;
    final double canvasTop = 40.wMin;
    final double rowWidth =
        orderedBranches.isEmpty ? componentWidth : orderedBranches.length * (componentWidth + componentGap) - componentGap;
    final double width = math.max(1120.wMin, 72.wMin + rowWidth);
    final String description = controller.getDescription();
    final bool showExplain = description.isNotEmpty;
    final double explainWidth = math.max(700.wMin, rowWidth);
    final double rootWidth = _rootWidth(data.content ?? '');
    final Rect rootRect = Rect.fromCenter(
      center: Offset(width / 2, canvasTop + rootHeight / 2),
      width: rootWidth,
      height: rootHeight,
    );
    final Rect? explainRect = showExplain
        ? Rect.fromCenter(
            center: Offset(width / 2, rootRect.bottom + explainGap + explainHeight / 2),
            width: explainWidth,
            height: explainHeight,
          )
        : null;
    final double branchY = (explainRect?.bottom ?? rootRect.bottom) + componentTopGap + componentHeight / 2;
    final double startX = (width - rowWidth) / 2 + componentWidth / 2;
    final List<_TreeBranchLayout> branchLayouts = <_TreeBranchLayout>[];
    double maxLeafSectionHeight = 0;

    for (int i = 0; i < orderedBranches.length; i++) {
      final WordMorphologyTreeBranchEntity branch = orderedBranches[i];
      final List<KnowledgeCommonEntityList> siblings =
          branch.siblings?.whereType<KnowledgeCommonEntityList>().toList() ?? <KnowledgeCommonEntityList>[];
      final double leafGroupHeight = siblings.isEmpty ? 0 : siblings.length * leafHeight + math.max(0, siblings.length - 1) * leafGap;
      maxLeafSectionHeight = math.max(maxLeafSectionHeight, leafGroupHeight);
      final double centerX = startX + i * (componentWidth + componentGap);
      final Rect componentRect = Rect.fromCenter(
        center: Offset(centerX, branchY),
        width: componentWidth,
        height: componentHeight,
      );
      final Rect? leafGroupRect = siblings.isEmpty
          ? null
          : Rect.fromCenter(
              center: Offset(
                centerX,
                componentRect.bottom + leafTopGap + leafGroupHeight / 2,
              ),
              width: leafWidth,
              height: leafGroupHeight,
            );
      branchLayouts.add(_TreeBranchLayout(
        branch: branch,
        componentRect: componentRect,
        color: controller.getMorphemeTypeTextColor(branch.type),
        typeTitle: controller.getMorphemeTypeTitle(branch.type),
        blurb: controller.getPreferredText(branch.summary),
        displayOrder: i + 1,
        focused: _isFocusedBranch(branch),
        leafGroupRect: leafGroupRect,
        siblings: siblings,
      ));
    }

    final double height = canvasTop +
        rootHeight +
        (showExplain ? explainGap + explainHeight : 0) +
        componentTopGap +
        componentHeight +
        (maxLeafSectionHeight > 0 ? leafTopGap + maxLeafSectionHeight : 0) +
        56.wMin;

    return _MorphologyTreeLayout(
      width: width,
      height: height,
      rootRect: rootRect,
      explainRect: explainRect,
      orderedBranches: orderedBranches,
      branches: branchLayouts,
    );
  }

  double _rootWidth(String label) {
    final double dynamicWidth = (64 + label.length * 16).wMin;
    return dynamicWidth.clamp(340.wMin, 640.wMin);
  }

  double _rootHeight(String label, String translate) {
    double height = 136.wMin;
    if (label.length > 12) {
      height += 16.wMin;
    }
    if (label.length > 18) {
      height += 16.wMin;
    }
    if (translate.isNotEmpty && translate.length > 12) {
      height += 12.wMin;
    }
    if (translate.isNotEmpty && translate.length > 20) {
      height += 12.wMin;
    }
    return height;
  }

  double _rootWordFontSize(String label) {
    if (label.length > 18) return 22.wMin;
    if (label.length > 12) return 26.wMin;
    return 32.wMin;
  }
}

class _MorphologyTreeLayout {
  final double width;
  final double height;
  final Rect rootRect;
  final Rect? explainRect;
  final List<WordMorphologyTreeBranchEntity> orderedBranches;
  final List<_TreeBranchLayout> branches;

  const _MorphologyTreeLayout({
    required this.width,
    required this.height,
    required this.rootRect,
    required this.explainRect,
    required this.orderedBranches,
    required this.branches,
  });
}

class _MorphologyTreeCanvasViewport extends StatefulWidget {
  final _MorphologyTreeLayout layout;
  final int resetToken;
  final Widget child;
  final VoidCallback? onInteractionStart;

  const _MorphologyTreeCanvasViewport({
    required this.layout,
    required this.resetToken,
    required this.child,
    this.onInteractionStart,
  });

  @override
  State<_MorphologyTreeCanvasViewport> createState() => _MorphologyTreeCanvasViewportState();
}

class _MorphologyTreeCanvasViewportState extends State<_MorphologyTreeCanvasViewport> {
  final TransformationController _transformController = TransformationController();

  Size? _viewportSize;
  String _lastLayoutIdentity = '';

  @override
  void didUpdateWidget(covariant _MorphologyTreeCanvasViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.layout.width != widget.layout.width || oldWidget.layout.height != widget.layout.height) {
      _scheduleResetView();
      return;
    }
    if (oldWidget.resetToken != widget.resetToken) {
      _scheduleResetView();
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _scheduleResetView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _viewportSize == null) return;
      _resetView();
    });
  }

  void _resetView() {
    if (_viewportSize == null) return;
    final double fitScale = _buildFitScale(_viewportSize!, Size(widget.layout.width, widget.layout.height));
    final double dx = (_viewportSize!.width - widget.layout.width * fitScale) / 2;
    final double dy = (_viewportSize!.height - widget.layout.height * fitScale) / 2;
    _transformController.value = Matrix4.identity()
      ..translateByDouble(dx > 0 ? dx : 0.0, dy > 0 ? dy : 0.0, 0, 1)
      ..scaleByDouble(fitScale, fitScale, 1, 1);
  }

  double _buildFitScale(Size viewportSize, Size canvasSize) {
    final double padding = math.min(viewportSize.width, viewportSize.height) * 0.04;
    final double availableWidth = math.max(viewportSize.width - padding * 2, 1);
    final double availableHeight = math.max(viewportSize.height - padding * 2, 1);
    return math.min(availableWidth / canvasSize.width, availableHeight / canvasSize.height).clamp(0.05, 4.0);
  }

  EdgeInsets _buildBoundaryMargin(Size viewportSize, Size canvasSize) {
    final double viewportLongestSide = math.max(viewportSize.width, viewportSize.height);
    final double canvasLongestSide = math.max(canvasSize.width, canvasSize.height);
    final double freeDragMargin = math.max(viewportLongestSide, canvasLongestSide) * 4;
    return EdgeInsets.all(freeDragMargin);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        final String layoutIdentity = '${widget.layout.width}_${widget.layout.height}_${constraints.maxWidth}_${constraints.maxHeight}';
        if (_lastLayoutIdentity != layoutIdentity) {
          _lastLayoutIdentity = layoutIdentity;
          _scheduleResetView();
        }
        final Size canvasSize = Size(widget.layout.width, widget.layout.height);
        final double fitScale = _buildFitScale(_viewportSize!, canvasSize);

        return ClipRRect(
          borderRadius: BorderRadius.circular(24.wMin),
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _transformController,
                  onInteractionStart: (_) => widget.onInteractionStart?.call(),
                  minScale: fitScale,
                  maxScale: 3,
                  boundaryMargin: _buildBoundaryMargin(_viewportSize!, canvasSize),
                  constrained: false,
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TreeBranchLayout {
  final WordMorphologyTreeBranchEntity branch;
  final Rect componentRect;
  final Rect? leafGroupRect;
  final Color? color;
  final String typeTitle;
  final String blurb;
  final int displayOrder;
  final bool focused;
  final List<KnowledgeCommonEntityList> siblings;

  const _TreeBranchLayout({
    required this.branch,
    required this.componentRect,
    required this.leafGroupRect,
    required this.color,
    required this.typeTitle,
    required this.blurb,
    required this.displayOrder,
    required this.focused,
    required this.siblings,
  });
}

class _MorphologyTreeEdgePainter extends CustomPainter {
  final _MorphologyTreeLayout layout;
  final Color? Function(WordMorphologyTreeBranchEntity branch) getBranchColor;

  const _MorphologyTreeEdgePainter({
    required this.layout,
    required this.getBranchColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (layout.explainRect != null) {
      _drawEdge(
        canvas,
        from: layout.rootRect.center,
        fromBottom: layout.rootRect.bottom,
        to: layout.explainRect!.center,
        toTop: layout.explainRect!.top,
        color: const Color(0xFFFBBF24).withValues(alpha: 0.78),
        strokeWidth: 3.wMin,
      );
    }

    for (int i = 0; i < layout.branches.length; i++) {
      final _TreeBranchLayout branchLayout = layout.branches[i];
      final Rect parentRect = layout.explainRect ?? layout.rootRect;
      final Color color = getBranchColor(branchLayout.branch) ?? AppTheme.cTextPrimary;
      _drawEdge(
        canvas,
        from: parentRect.center,
        fromBottom: parentRect.bottom,
        to: branchLayout.componentRect.center,
        toTop: branchLayout.componentRect.top,
        color: color.withValues(alpha: 0.72),
        strokeWidth: 2.4.wMin,
      );
      if (branchLayout.leafGroupRect != null) {
        _drawEdge(
          canvas,
          from: branchLayout.componentRect.center,
          fromBottom: branchLayout.componentRect.bottom,
          to: branchLayout.leafGroupRect!.center,
          toTop: branchLayout.leafGroupRect!.top,
          color: color.withValues(alpha: 0.58),
          strokeWidth: 1.8.wMin,
        );
      }
    }
  }

  void _drawEdge(
    Canvas canvas, {
    required Offset from,
    required double fromBottom,
    required Offset to,
    required double toTop,
    required Color color,
    required double strokeWidth,
  }) {
    final double mid = math.max(24.wMin, (toTop - fromBottom) / 1.85);
    final Path path = Path()
      ..moveTo(from.dx, fromBottom)
      ..cubicTo(
        from.dx,
        fromBottom + mid,
        to.dx,
        toTop - mid,
        to.dx,
        toTop,
      );
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MorphologyTreeEdgePainter oldDelegate) {
    return oldDelegate.layout != layout;
  }
}

class _MorphologyHighlightChunk {
  final String text;
  final String key;
  final String type;

  const _MorphologyHighlightChunk({
    required this.text,
    this.key = '',
    this.type = '',
  });
}

class _MorphologyComponentSpan {
  final WordMorphologyTreeBranchEntity branch;
  final int start;
  final int end;

  const _MorphologyComponentSpan({
    required this.branch,
    required this.start,
    required this.end,
  });
}

String _morphemeNeedle(String content) {
  return content.replaceAll('-', '').toLowerCase();
}

_MorphologyComponentSpan? _findMorphemeSpan(
  String word,
  String piece,
  String? type,
  String? key,
) {
  final String needle = _morphemeNeedle(piece);
  if (needle.isEmpty || word.isEmpty) return null;
  final String hay = word.toLowerCase();
  final bool preferStart = type == 'prefix' || piece.endsWith('-');
  final bool preferEnd = type == 'suffix' || piece.startsWith('-');
  if (preferStart && hay.startsWith(needle)) {
    return _MorphologyComponentSpan(
      branch: WordMorphologyTreeBranchEntity(key: key, type: type),
      start: 0,
      end: needle.length,
    );
  }
  if (preferEnd && hay.endsWith(needle)) {
    return _MorphologyComponentSpan(
      branch: WordMorphologyTreeBranchEntity(key: key, type: type),
      start: word.length - needle.length,
      end: word.length,
    );
  }
  final int index = hay.indexOf(needle);
  if (index < 0) return null;
  return _MorphologyComponentSpan(
    branch: WordMorphologyTreeBranchEntity(key: key, type: type),
    start: index,
    end: index + needle.length,
  );
}

List<_MorphologyHighlightChunk> _splitByComponents(
  String word,
  List<WordMorphologyTreeBranchEntity> branches,
) {
  final List<_MorphologyComponentSpan> spans = _locateComponentSpans(word, branches);
  if (spans.isEmpty) return <_MorphologyHighlightChunk>[_MorphologyHighlightChunk(text: word)];

  final List<_MorphologyHighlightChunk> chunks = <_MorphologyHighlightChunk>[];
  int cursor = 0;
  for (int i = 0; i < spans.length; i++) {
    final _MorphologyComponentSpan span = spans[i];
    if (span.start > cursor) {
      chunks.add(_MorphologyHighlightChunk(text: word.substring(cursor, span.start)));
    }
    chunks.add(_MorphologyHighlightChunk(
      text: word.substring(span.start, span.end),
      key: span.branch.key ?? '',
      type: span.branch.type ?? '',
    ));
    cursor = span.end;
  }
  if (cursor < word.length) {
    chunks.add(_MorphologyHighlightChunk(text: word.substring(cursor)));
  }
  return chunks.where((chunk) => chunk.text.isNotEmpty).toList();
}

List<WordMorphologyTreeBranchEntity> _componentsInSurfaceOrder(
  String word,
  List<WordMorphologyTreeBranchEntity> branches,
) {
  final List<_MorphologyComponentSpan> located = _locateComponentSpans(word, branches);
  final List<WordMorphologyTreeBranchEntity> ordered = located.map((item) => item.branch).toList();
  return _insertUnlocated(branches, ordered);
}

List<_MorphologyComponentSpan> _locateComponentSpans(
  String word,
  List<WordMorphologyTreeBranchEntity> branches,
) {
  if (word.isEmpty || branches.isEmpty) return <_MorphologyComponentSpan>[];
  final List<bool> taken = List<bool>.filled(word.length, false);
  final List<_MorphologyComponentSpan> located = <_MorphologyComponentSpan>[];

  void take(_MorphologyComponentSpan? span) {
    if (span == null) return;
    located.add(span);
    _markSpan(taken, span.start, span.end);
  }

  final List<WordMorphologyTreeBranchEntity> prefixes = branches.where((item) => item.type == 'prefix').toList();
  final List<WordMorphologyTreeBranchEntity> suffixes = branches.where((item) => item.type == 'suffix').toList()
    ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
  final List<WordMorphologyTreeBranchEntity> others = branches.where((item) => item.type != 'prefix' && item.type != 'suffix').toList();

  for (int i = 0; i < prefixes.length; i++) {
    take(_locateOne(word, prefixes[i], taken, 'start'));
  }
  for (int i = suffixes.length - 1; i >= 0; i--) {
    take(_locateOne(word, suffixes[i], taken, 'end'));
  }
  for (int i = 0; i < others.length; i++) {
    take(_locateOne(word, others[i], taken, 'any'));
  }
  for (int i = 0; i < branches.length; i++) {
    final bool exists = located.any((item) => item.branch.key == branches[i].key);
    if (exists) continue;
    take(_locateOne(word, branches[i], taken, 'any'));
  }
  _assignRemainingStems(word, branches, located, taken);
  located.sort((a, b) => a.start.compareTo(b.start));
  return located;
}

_MorphologyComponentSpan? _locateOne(
  String word,
  WordMorphologyTreeBranchEntity branch,
  List<bool> taken,
  String prefer,
) {
  final String base = _morphemeNeedle(branch.content ?? '');
  if (base.isEmpty) return null;
  final String hay = word.toLowerCase();
  final List<String> needles = prefer == 'end' || branch.type == 'suffix' ? _suffixNeedles(base) : _stemNeedles(base);
  for (int i = 0; i < needles.length; i++) {
    final String needle = needles[i];
    final int lastStart = hay.length - needle.length;
    if (lastStart < 0) continue;

    _MorphologyComponentSpan? claim(int start) {
      final int end = start + needle.length;
      if (!_spanFits(taken, start, end, hay, needle)) return null;
      return _MorphologyComponentSpan(branch: branch, start: start, end: end);
    }

    if (prefer == 'start') {
      final _MorphologyComponentSpan? head = claim(0);
      if (head != null) return head;
    }
    if (prefer == 'end') {
      final _MorphologyComponentSpan? tail = claim(lastStart);
      if (tail != null) return tail;
      for (int start = lastStart; start >= 0; start--) {
        final _MorphologyComponentSpan? hit = claim(start);
        if (hit != null) return hit;
      }
      continue;
    }
    for (int start = 0; start <= lastStart; start++) {
      final _MorphologyComponentSpan? hit = claim(start);
      if (hit != null) return hit;
    }
  }
  return null;
}

void _assignRemainingStems(
  String word,
  List<WordMorphologyTreeBranchEntity> branches,
  List<_MorphologyComponentSpan> located,
  List<bool> taken,
) {
  final Set<String> seen = located.map((item) => item.branch.key ?? '').toSet();
  final List<WordMorphologyTreeBranchEntity> unmatched =
      branches.where((item) => !seen.contains(item.key ?? '') && item.type != 'prefix' && item.type != 'suffix').toList();
  if (unmatched.isEmpty) return;

  final List<_GapSpan> gaps = _unmarkedSpans(taken);
  for (int i = 0; i < gaps.length; i++) {
    for (int j = 0; j < unmatched.length; j++) {
      if (seen.contains(unmatched[j].key ?? '')) continue;
      final _MorphologyComponentSpan? hit = _locateInRange(word, unmatched[j], taken, gaps[i].start, gaps[i].end);
      if (hit == null) continue;
      located.add(hit);
      _markSpan(taken, hit.start, hit.end);
      seen.add(unmatched[j].key ?? '');
    }
  }

  final List<WordMorphologyTreeBranchEntity> still = unmatched.where((item) => !seen.contains(item.key ?? '')).toList();
  final List<_GapSpan> leftover = _unmarkedSpans(taken);
  if (still.length == 1 && leftover.length == 1) {
    located.add(_MorphologyComponentSpan(
      branch: still.first,
      start: leftover.first.start,
      end: leftover.first.end,
    ));
    _markSpan(taken, leftover.first.start, leftover.first.end);
  }
}

_MorphologyComponentSpan? _locateInRange(
  String word,
  WordMorphologyTreeBranchEntity branch,
  List<bool> taken,
  int rangeStart,
  int rangeEnd,
) {
  final String base = _morphemeNeedle(branch.content ?? '');
  if (base.isEmpty) return null;
  final String hay = word.toLowerCase();
  final List<String> needles = _stemNeedles(base);
  for (int i = 0; i < needles.length; i++) {
    final String needle = needles[i];
    final int lastStart = rangeEnd - needle.length;
    for (int start = rangeStart; start <= lastStart; start++) {
      final int end = start + needle.length;
      if (!_spanFits(taken, start, end, hay, needle)) continue;
      return _MorphologyComponentSpan(branch: branch, start: start, end: end);
    }
  }
  return null;
}

bool _spanFits(List<bool> taken, int start, int end, String hay, String needle) {
  if (start < 0 || end > hay.length || hay.substring(start, end) != needle) return false;
  for (int i = start; i < end; i++) {
    if (taken[i]) return false;
  }
  return true;
}

void _markSpan(List<bool> taken, int start, int end) {
  for (int i = start; i < end; i++) {
    taken[i] = true;
  }
}

List<_GapSpan> _unmarkedSpans(List<bool> taken) {
  final List<_GapSpan> spans = <_GapSpan>[];
  int index = 0;
  while (index < taken.length) {
    while (index < taken.length && taken[index]) {
      index++;
    }
    if (index >= taken.length) break;
    final int start = index;
    while (index < taken.length && !taken[index]) {
      index++;
    }
    spans.add(_GapSpan(start: start, end: index));
  }
  return spans;
}

List<WordMorphologyTreeBranchEntity> _insertUnlocated(
  List<WordMorphologyTreeBranchEntity> source,
  List<WordMorphologyTreeBranchEntity> located,
) {
  final Set<String> seen = located.map((item) => item.key ?? '').toSet();
  final List<WordMorphologyTreeBranchEntity> result = <WordMorphologyTreeBranchEntity>[...located];
  for (int i = 0; i < source.length; i++) {
    if (seen.contains(source[i].key ?? '')) continue;
    if (source[i].type == 'prefix') {
      final int index = result.indexWhere((entry) => entry.type != 'prefix');
      result.insert(index < 0 ? 0 : index, source[i]);
    } else if (source[i].type == 'suffix') {
      result.add(source[i]);
    } else {
      final int index = result.indexWhere((entry) => entry.type == 'suffix');
      result.insert(index < 0 ? result.length : index, source[i]);
    }
    seen.add(source[i].key ?? '');
  }
  return result;
}

List<String> _suffixNeedles(String base) {
  final List<String> values = <String>[base];
  if (base.endsWith('e') && base.length > 2) values.add(base.substring(0, base.length - 1));
  if (base == 'tion') values.addAll(<String>['ation', 'ition', 'ution']);
  if (base == 'sion') values.addAll(<String>['ssion', 'asion']);
  return _uniqueLongestFirst(values);
}

List<String> _stemNeedles(String base) {
  final List<String> values = <String>[base];
  if (base.length > 2 && base.endsWith('e')) values.add(base.substring(0, base.length - 1));
  if (base.length > 2 && base.endsWith('y')) values.add('${base.substring(0, base.length - 1)}i');
  if (base.length > 3 && base.endsWith('ie')) values.add('${base.substring(0, base.length - 2)}y');
  return _uniqueLongestFirst(values);
}

List<String> _uniqueLongestFirst(List<String> values) {
  final List<String> result = values.where((item) => item.isNotEmpty).toSet().toList();
  result.sort((a, b) => b.length.compareTo(a.length));
  return result;
}

class _GapSpan {
  final int start;
  final int end;

  const _GapSpan({
    required this.start,
    required this.end,
  });
}
