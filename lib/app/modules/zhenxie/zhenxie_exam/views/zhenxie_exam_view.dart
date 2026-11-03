import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/entities/language_config_color_entity.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/common/widgets/platform_backdrop_filter_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../bindings/zhenxie_exam_binding.dart';
import '../controllers/zhenxie_exam_controller.dart';
import '../models/zhenxie_exam_models.dart';
import 'widgets/zhenxie_exam_donut_chart.dart';
import 'widgets/zhenxie_exam_marquee.dart';

/// 考点首页（对齐 React ExamHomePage.tsx）：
/// 一个阶段 2×2——① 文章 ② 主题 ③ 能力 ④ 阶梯；底栏浮条只切考段。
/// 顶部用 Flutter 面包屑，不做 React 的 ExamShell 顶栏。
class ZhenxieExamView extends GetView<ZhenxieExamController> {
  final String tagText;
  const ZhenxieExamView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieExamView(tagText: tag),
      binding: ZhenxieExamBinding(tagText: tag),
      routeName: Routes.ZHENXIE_EXAM,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    controller;
    return Scaffold(
        backgroundColor: AppTheme.cBgPrimary,
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.wMin, 0, 24.wMin, 16.wMin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStagePillBarWidget(),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            const BreadcrumbWidget(),
            Expanded(child: Obx(() {
              return controller.isLoading.value
                  ? const Center()
                  : Padding(
                      padding: EdgeInsets.fromLTRB(90.wMin, 0, 90.wMin, 12.wMin),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeadlineRowWidget(),
                          SizedBox(height: 12.wMin),
                          Expanded(child: _buildGridWidget()),
                        ],
                      ),
                    );
            })),
          ],
        ));
  }

  /* ------------------------------------------------------------------ 顶栏一句 + meta */

  Widget _buildHeadlineRowWidget() {
    return Row(
      children: [
        Expanded(
          child: Text(
            controller.buildHeadlineText(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: _zxInk2Color,
            ),
          ),
        ),
        SizedBox(width: 16.wMin),
        Text(
          controller.buildMetaText(),
          maxLines: 1,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w500,
            fontFamily: AppFontValue.robotoMono,
            color: _zxInk2Color,
          ),
        ),
      ],
    );
  }

  /* ------------------------------------------------------------------ 2×2 画布 */

  /// 2×2 铺满可用高度（React grid auto-rows-[minmax(280px,1fr)] + h-full）；
  /// 每行 flex-1 平分，主体不滚。
  Widget _buildGridWidget() {
    final double gap = 16.wMin;
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildGenreCellWidget()),
              SizedBox(width: gap),
              Expanded(child: _buildTopicCellWidget()),
            ],
          ),
        ),
        SizedBox(height: gap),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildGoalCellWidget()),
              SizedBox(width: gap),
              Expanded(child: _buildLadderCellWidget()),
            ],
          ),
        ),
      ],
    );
  }

  /* ------------------------------------------------------------------ 卡壳 */

  /// 一格卡片：① 序号 + 模块名 + 结论句 + 图形区。
  /// React 里整卡点进三阶段对比页；Flutter 改为只响应饼图切片点击。
  Widget _buildCellWidget({
    required String index,
    required String title,
    required String conclusion,
    required Widget child,
    required String moduleId,
  }) {
    return _HoverBgWidget(
      borderRadius: 16.wMin,
      builder: (hovered) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => TagRoutes.toNamed(
            Routes.ZHENXIE_EXAM_COMPARE,
            arguments: <String, dynamic>{
              'stage': controller.currentStage.value,
              'module': moduleId,
            },
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(20.wMin, 16.wMin, 20.wMin, 16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              border: Border.all(color: AppTheme.cZhenxieBorderPrimary.color, width: 1.wMin),
              color: hovered ? AppTheme.cZhenxieBackgroundPrimary.color.withValues(alpha: 0.08) : AppTheme.cZhenxieBackgroundPrimary.color,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // React `flex items-baseline gap-2`：序号与标题按基线对齐。
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      index,
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        fontFamily: AppFontValue.robotoMono,
                        color: _zxGoldColor,
                      ),
                    ),
                    SizedBox(width: 8.wMin),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFontValue.sourceHanSerifCN,
                        color: _zxInkColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.wMin),
                Text(
                  conclusion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    height: 1.375,
                    fontWeight: FontWeight.w400,
                    color: _zxInk2Color,
                  ),
                ),
                SizedBox(height: 12.wMin),
                Expanded(child: child),
              ],
            ),
          ),
        );
      },
    );
  }

  /* ------------------------------------------------------------------ ① 文章 */

  Widget _buildGenreCellWidget() {
    final ZhenxieExamHomeBlockData? block = controller.findCurrentBlock('genres');
    return _buildCellWidget(
      index: '①',
      title: controller.buildBlockTitleText('genres'),
      conclusion: controller.buildGenreHeadline(),
      moduleId: 'genres',
      child: ZxDonutBlock(
        items: block?.items ?? const <ZhenxieExamHomeBlockItemData>[],
        emptyText: '没有符合卷别的真题',
        colorBuilder: _buildBlockItemPrimaryColor,
        onSliceTap: (id) => TagRoutes.toNamed(
          Routes.ZHENXIE_EXAM_COMPARE,
          arguments: <String, dynamic>{
            'stage': controller.currentStage.value,
            'module': 'genres',
            'highlight': id,
          },
        ),
      ),
    );
  }

  /* ------------------------------------------------------------------ ② 主题 */

  Widget _buildTopicCellWidget() {
    final ZhenxieExamHomeBlockData? block = controller.findCurrentBlock('topics');
    return _buildCellWidget(
      index: '②',
      title: controller.buildBlockTitleText('topics'),
      conclusion: controller.buildTopicHeadline(),
      moduleId: 'topics',
      child: ZxDonutBlock(
        items: block?.items ?? const <ZhenxieExamHomeBlockItemData>[],
        emptyText: '主题标签待补',
        colorBuilder: _buildBlockItemPrimaryColor,
        onSliceTap: (id) => TagRoutes.toNamed(
          Routes.ZHENXIE_EXAM_COMPARE,
          arguments: <String, dynamic>{
            'stage': controller.currentStage.value,
            'module': 'topics',
            'highlight': id,
          },
        ),
      ),
    );
  }

  /* ------------------------------------------------------------------ ③ 能力 */

  Widget _buildGoalCellWidget() {
    final ZhenxieExamHomeBlockData? block = controller.findCurrentBlock('goals');
    final List<ZhenxieExamHomeBlockItemData> items = block?.items.take(5).toList() ?? const <ZhenxieExamHomeBlockItemData>[];
    return _buildCellWidget(
      index: '③',
      title: controller.buildBlockTitleText('goals'),
      conclusion: controller.buildGoalHeadline(),
      moduleId: 'goals',
      child: items.isEmpty
          ? Center(
              child: Text(
                '能力标签待补',
                style: TextStyle(fontSize: 16.wMin, fontWeight: FontWeight.w500, color: _zxInk3Color),
              ),
            )
          : Column(
              children: [
                Expanded(child: _ZxRankBarsWidget(items: items, controller: controller)),
                SizedBox(height: 8.wMin),
                _buildGoalLegendWidget(block),
              ],
            ),
    );
  }

  Widget _buildGoalLegendWidget(ZhenxieExamHomeBlockData? block) {
    if (block == null || block.legends.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        for (int index = 0; index < block.legends.length; index++) ...[
          _buildLegendDotWidget(
            _buildThemeBackgroundColor(block.legends[index].colors, fallback: _zxGoldColor),
            pickLocalizedText(block.legends[index].name.map((text) => text.toJson()).toList()),
          ),
          if (index != block.legends.length - 1) SizedBox(width: 14.wMin),
        ],
        if (block.legendDescription.isNotEmpty) ...[
          const Spacer(),
          Text(
            block.legendDescription,
            style: TextStyle(fontSize: 16.wMin, fontWeight: FontWeight.w400, color: _zxInk3Color),
          ),
        ],
      ],
    );
  }

  Widget _buildLegendDotWidget(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8.wMin,
          height: 8.wMin,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.wMin), color: color),
        ),
        SizedBox(width: 6.wMin),
        Text(label, style: TextStyle(fontSize: 16.wMin, fontWeight: FontWeight.w400, color: _zxInk3Color)),
      ],
    );
  }

  /* ------------------------------------------------------------------ ④ 阶梯 */

  Widget _buildLadderCellWidget() {
    final ZhenxieExamHomeBlockData? block = controller.findCurrentBlock('ladder');
    final String summary = pickLocalizedText(block?.summary.map((text) => text.toJson()).toList());
    final ({String rate, String description}) ladderSummary = _splitLeadingRate(summary);
    final Color tone = _buildStagePrimaryColor(controller.findStageData(controller.currentStage.value));
    return _buildCellWidget(
      index: '④',
      title: controller.buildBlockTitleText('ladder'),
      conclusion: controller.buildLadderHeadline(),
      moduleId: 'ladder',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // React `flex items-baseline gap-3.5`：大数字与说明按基线对齐。
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (ladderSummary.rate.isNotEmpty) ...[
                Text(
                  ladderSummary.rate,
                  style: TextStyle(
                    fontSize: 48.wMin,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFontValue.robotoMono,
                    letterSpacing: -1,
                    color: tone,
                  ),
                ),
                SizedBox(width: 14.wMin),
              ],
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: ladderSummary.description.isNotEmpty ? ladderSummary.description : summary,
                        style: TextStyle(fontSize: 16.wMin, height: 1.375, fontWeight: FontWeight.w400, color: _zxInk2Color),
                      ),
                      if (block != null) ...[
                        WidgetSpan(child: SizedBox(width: 8.wMin)),
                        TextSpan(
                          text: '${block.coveredCount}/${block.total}',
                          style: TextStyle(
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppFontValue.robotoMono,
                            color: _zxInk3Color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.wMin),
          Expanded(child: _buildStageMarqueeWidget(block?.items ?? const <ZhenxieExamHomeBlockItemData>[], tone)),
        ],
      ),
    );
  }

  /// 关阶横滚：文类色缩略块 + 阶名 + 落在这一阶的题数；复制两份循环，悬停暂停。
  Widget _buildStageMarqueeWidget(List<ZhenxieExamHomeBlockItemData> items, Color tone) {
    if (items.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '还没有题挂上写作课阶',
          style: TextStyle(fontSize: 16.wMin, fontWeight: FontWeight.w500, color: _zxInk3Color),
        ),
      );
    }
    final Widget strip = Row(
      mainAxisSize: MainAxisSize.min,
      children: items.map((item) => _buildStageThumbWidget(item, tone)).toList(),
    );
    final double duration = (items.length * 4.5).clamp(18.0, double.infinity);
    return ShaderMask(
      // 两端淡出（React mask-image: linear-gradient(90deg, transparent, #000 7%, #000 93%, transparent)）。
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const <Color>[Colors.transparent, Colors.white, Colors.white, Colors.transparent],
          stops: const <double>[0, 0.07, 0.93, 1],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstIn,
      child: ZxMarqueeSizerWidget(strip: strip, durationSeconds: duration),
    );
  }

  Widget _buildStageThumbWidget(ZhenxieExamHomeBlockItemData item, Color tone) {
    return Container(
      width: 154.wMin,
      margin: EdgeInsets.only(right: 16.wMin),
      padding: EdgeInsets.symmetric( vertical: 6.wMin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildStageThumbIconWidget(item, tone),
          SizedBox(height: 6.wMin),
          SizedBox(
            width: double.infinity,
            height: 24.wMin,
            child:Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
              pickLocalizedText(item.name.map((text) => text.toJson()).toList()),
     
             
              style: TextStyle(fontSize: 16.wMin, fontWeight: FontWeight.w400, color: _zxBoneColor.withValues(alpha: 0.85)),
                )
              ],
            )),
          
          SizedBox(height: 6.wMin),
          Text(
            '${item.count}',
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              fontFamily: AppFontValue.robotoMono,
              color: tone,
            ),
          ),
        ],
      ),
    );
  }

  /// React MapNodeThumb：有蓝图封面走照片（白描边、无光晕、object-cover）；
  /// 没封面退回文类色径向渐变 + 皮图标。
  Widget _buildStageThumbIconWidget(ZhenxieExamHomeBlockItemData item, Color tone) {
    if (item.coverUrl.isNotEmpty) {
      return Container(
        width: 150.wMin,
        height: 150.wMin,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cBgPrimary.color,
          border: Border.all(color: AppTheme.cZhenxieBorderPrimary.color, width: 2.wMin),
        ),
        child: Image.network(
          item.coverUrl,
          width: 150.wMin,
          height: 150.wMin,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildThumbFallbackWidget(tone),
        ),
      );
    }
    return _buildThumbFallbackWidget(tone);
  }

  Widget _buildThumbFallbackWidget(Color tone) {
    return Container(
      width: 76.wMin,
      height: 76.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: <Color>[tone.withValues(alpha: 0.55), tone.withValues(alpha: 0.18)],
        ),
        border: Border.all(color: tone.withValues(alpha: 0.9), width: 2.wMin),
        boxShadow: <BoxShadow>[
          BoxShadow(color: tone.withValues(alpha: 0.35), blurRadius: 12.wMin),
        ],
      ),
      child: Icon(Icons.description_outlined, size: 40.wMin, color: tone),
    );
  }

  /* ------------------------------------------------------------------ 底栏：三枚胶囊切考段 */

  Widget _buildStagePillBarWidget() {
    return Obx(() {
      return ClipRRect(
        borderRadius: BorderRadius.circular(999.wMin),
        child: PlatformBackdropFilterWidget(
          sigmaX: 4.wMin,
          sigmaY: 4.wMin,
          child: Container(
            height: 56.wMin,
            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceSearchBackground.color,
              borderRadius: BorderRadius.circular(999.wMin),
              border: Border.all(color: AppTheme.cBgTertiary.color, width: 1.wMin),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: controller.buildStageList().map((stage) {
                return _buildStagePillWidget(stage);
              }).toList(),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStagePillWidget(ZhenxieExamHomeStageData stage) {
    final bool active = controller.currentStage.value == stage.stage;
    final LanguageConfigColorEntityThemeColors? themeColors = controller.findCurrentThemeColors(stage.colors);
    final Color tone = _buildThemePrimaryColor(stage.colors, fallback: _zxGoldColor);
    final Color textTone = themeColors?.textColorC ?? tone;
    final Color backgroundTone = themeColors?.backgroundColorC ?? AppTheme.cZhenxieBackgroundPrimary.color;
    final Color borderTone = themeColors?.borderColorC ?? tone.withValues(alpha: 0.69);
    final int count = controller.buildStageTaskCount(stage.stage);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.wMin),
      child: _HoverBgWidget(
        borderRadius: 999.wMin,
        builder: (hovered) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => controller.switchStage(stage.stage),
            child: Container(
              height: 40.wMin,
              padding: EdgeInsets.symmetric(horizontal: 14.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999.wMin),
                color: active ? backgroundTone : Colors.transparent,
                border: Border.all(
                  color: active ? borderTone : Colors.transparent,
                  width: 1.wMin,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8.wMin,
                    height: 8.wMin,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.wMin), color: tone),
                  ),
                  SizedBox(width: 6.wMin),
                  Text(
                    pickLocalizedText(stage.name.map((text) => text.toJson()).toList()),
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFontValue.sourceHanSerifCN,
                      color: active || hovered ? textTone : _zxBoneColor.withValues(alpha: 0.62),
                    ),
                  ),
                  SizedBox(width: 6.wMin),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      fontFamily: AppFontValue.robotoMono,
                      color: active ? tone : _zxBoneColor.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  ({String rate, String description}) _splitLeadingRate(String text) {
    final RegExpMatch? match = RegExp(r'^(\d+%)\s*(.*)$').firstMatch(text);
    if (match == null) return (rate: '', description: text);
    return (
      rate: match.group(1) ?? '',
      description: match.group(2) ?? '',
    );
  }

  Color _buildThemePrimaryColor(List<LanguageConfigColorEntityThemeColors> colors, {required Color fallback}) {
    if (colors.isEmpty) return fallback;
    final LanguageConfigColorEntityThemeColors themeColors = controller.findCurrentThemeColors(colors) ?? colors.first;
    return themeColors.colorC ?? themeColors.textColorC ?? themeColors.borderColorC ?? themeColors.backgroundColorC ?? fallback;
  }

  Color _buildThemeBackgroundColor(List<LanguageConfigColorEntityThemeColors> colors, {required Color fallback}) {
    if (colors.isEmpty) return fallback;
    final LanguageConfigColorEntityThemeColors themeColors = controller.findCurrentThemeColors(colors) ?? colors.first;
    return themeColors.backgroundColorC ?? themeColors.colorC ?? themeColors.textColorC ?? themeColors.borderColorC ?? fallback;
  }

  Color _buildBlockItemPrimaryColor(ZhenxieExamHomeBlockItemData item) {
    return _buildThemePrimaryColor(item.colors, fallback: _zxGoldColor);
  }

  Color _buildStagePrimaryColor(ZhenxieExamHomeStageData? stage) {
    if (stage == null) return _zxGoldColor;
    return _buildThemePrimaryColor(stage.colors, fallback: _zxGoldColor);
  }
}

/* ------------------------------------------------------------------ 排行柱 */

/// 横向排行柱（对齐 React RankBars）：名 · 柱 · 数。
/// 主能力实段 + 副能力淡段；hover 行高亮、异组压暗。
class _ZxRankBarsWidget extends StatefulWidget {
  final List<ZhenxieExamHomeBlockItemData> items;
  final ZhenxieExamController controller;

  const _ZxRankBarsWidget({required this.items, required this.controller});

  @override
  State<_ZxRankBarsWidget> createState() => _ZxRankBarsWidgetState();
}

class _ZxRankBarsWidgetState extends State<_ZxRankBarsWidget> {
  String? _activeId;

  @override
  Widget build(BuildContext context) {
    final int max = widget.items.fold(1, (value, item) {
      final int total = item.totalCount > 0 ? item.totalCount : item.count + item.secondaryCount;
      return total > value ? total : value;
    });
    return MouseRegion(
      onExit: (_) => setState(() => _activeId = null),
      child: Column(
        children: widget.items.map((item) {
          final bool lit = _activeId == item.code;
          final bool dim = _activeId != null && !lit;
          return Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 52.wMin),
              child: MouseRegion(
                onEnter: (_) => setState(() => _activeId = item.code),
                child: Opacity(
                  opacity: dim ? 0.3 : 1,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          pickLocalizedText(item.name.map((text) => text.toJson()).toList()),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.wMin,
                            height: 1.25,
                            fontWeight: FontWeight.w400,
                            color: lit ? _zxInkColor : _zxBoneColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.wMin),
                      SizedBox(
                        width: 300.wMin,
                        child: _buildBarWidget(item, max),
                      ),
                      SizedBox(width: 10.wMin),
                      SizedBox(
                        width: 36.wMin,
                        child: Text(
                          '${item.totalCount > 0 ? item.totalCount : item.count + item.secondaryCount}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppFontValue.robotoMono,
                            color: lit ? _buildGoalItemColor(item) : _zxBoneColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarWidget(ZhenxieExamHomeBlockItemData item, int max) {
    // React RankBars：relative 槽 + absolute 段。主段 width=max(1.5%, value/max)；
    // 副段 left=value/max、width=secondary/max，淡一档。用 Stack+Positioned 按绝对百分比定位，
    // 剩余露出底色轨道（不能用 Row+Expanded，那会把整条宽度按比例瓜分占满）。
    final double ratio = item.count / max;
    final double mainFactor = ratio < 0.015 ? 0.015 : ratio;
    final double secondaryFactor = item.secondaryCount == 0 ? 0 : item.secondaryCount / max;
    final Color color = _buildGoalItemColor(item);
    return Container(
      height: 8.wMin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.wMin),
        color: AppTheme.cZhenxieBackgroundPrimary.color,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double track = constraints.maxWidth;
          return Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: track * mainFactor,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.wMin),
                    color: color,
                  ),
                ),
              ),
              if (secondaryFactor > 0)
                Positioned(
                  left: track * ratio,
                  top: 0,
                  bottom: 0,
                  width: track * secondaryFactor,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(3.wMin),
                        bottomRight: Radius.circular(3.wMin),
                      ),
                      color: color.withValues(alpha: 0.32),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Color _buildGoalItemColor(ZhenxieExamHomeBlockItemData item) {
    final ZhenxieExamCompareLegendData? legend = widget.controller.findGoalLegend(item.groupCode);
    final List<LanguageConfigColorEntityThemeColors> colors = legend?.colors ?? const <LanguageConfigColorEntityThemeColors>[];
    if (colors.isEmpty) return _zxGoldColor;
    final LanguageConfigColorEntityThemeColors themeColors = widget.controller.findCurrentThemeColors(colors) ?? colors.first;
    return themeColors.backgroundColorC ?? themeColors.colorC ?? themeColors.textColorC ?? themeColors.borderColorC ?? _zxGoldColor;
  }
}

/* ------------------------------------------------------------------ hover 底色 */

/// 桌面端 hover 亮一档底色（React hover:bg-white/[0.06]）。
class _HoverBgWidget extends StatefulWidget {
  final double borderRadius;
  final Widget Function(bool hovered) builder;

  const _HoverBgWidget({required this.borderRadius, required this.builder});

  @override
  State<_HoverBgWidget> createState() => _HoverBgWidgetState();
}

class _HoverBgWidgetState extends State<_HoverBgWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: widget.builder(_hovered),
    );
  }
}

/* ------------------------------------------------------------------ 色板 */

/* 甄写页普通文字/边框/背景统一跟随 AppTheme。 */
Color get _zxInkColor => AppTheme.cZhenxieFontPrimary.color;
Color get _zxBoneColor => AppTheme.cZhenxieFontPrimary.color;
Color get _zxGoldColor => AppTheme.cZhenxieColorPrimary.color;
Color get _zxInk2Color => AppTheme.cZhenxieFontSecondary.color;
Color get _zxInk3Color => AppTheme.cZhenxieFontTertiary.color;
