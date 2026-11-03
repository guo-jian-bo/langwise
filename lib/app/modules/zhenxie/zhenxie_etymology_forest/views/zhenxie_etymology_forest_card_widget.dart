import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/values/values.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';

/// 一片森林一张卡：顶部徽标与统计，中部迷你词源树，底部描述。
class ZhenxieEtymologyForestCardWidget extends StatelessWidget {
  final ZhenxieEtymologyForestEntity data;
  const ZhenxieEtymologyForestCardWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String description = _zxForestZhText(data.descriptions);
    final List<String> branches = (data.branchTexts ?? const <ZhenxieEtymologyForestBranchTextEntity?>[])
        .map((item) => _zxForestZhText(item?.text))
        .where((text) => text.isNotEmpty)
        .toList();
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        color: _zxForestCardColor,
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(color: _zxForestBorderColor, width: 1.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderWidget(),
          Expanded(
            child: Center(
              child: ZxEtymologyMiniTreeWidget(
                headword: data.content ?? "",
                title: _zxForestZhText(data.coreText),
                branches: branches,
              ),
            ),
          ),
          if (description.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.wMin),
              child: Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFontValue.sourceHanSerifCN,
                  fontSize: 16.wMin,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: _zxForestDescColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 顶部：内容类型徽标、词性、右侧分支与义项统计
  Widget _buildHeaderWidget() {
    final ConfigController configController = Get.find<ConfigController>();
    final LanguageConfigColorModel? posColor = StatusUtils.getConfigColor(configController.colorConfigs.value.pos, data.pos);

    return Row(
      children: [
        _buildBadgeWidget(data.contentType == "EN_WORD" ? "单词" : "短语"),
        if ((data.pos ?? "").isNotEmpty) ...[
          SizedBox(width: 6.wMin),
          _buildBadgeWidget(posColor?.title ?? data.pos ?? ""),
        ],
        const Spacer(),
        Text(
          "${data.branchCount ?? 0} 支 · ${data.semanticCount ?? 0} 个义项",
          style: TextStyle(
            fontFamily: AppFontValue.sourceHanSerifCN,
            fontSize: 16.wMin,
            height: 1,
            fontWeight: FontWeight.w400,
            color: _zxForestCountColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeWidget(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        color: _zxForestBadgeBgColor,
        border: Border.all(color: _zxForestBadgeBorderColor, width: 1.wMin),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFontValue.sourceHanSerifCN,
          fontSize: 16.wMin,
          height: 1,
          fontWeight: FontWeight.w400,
          color: _zxForestBadgeTextColor,
        ),
      ),
    );
  }
}

/// 迷你词源树：根在上、枝横着摊开，是详情树的缩小版。
class ZxEtymologyMiniTreeWidget extends StatelessWidget {
  final String headword;
  final String title;
  final List<String> branches;
  final double scale;

  const ZxEtymologyMiniTreeWidget({
    super.key,
    required this.headword,
    required this.title,
    required this.branches,
    this.scale = 1,
  });

  @override
  Widget build(BuildContext context) {
    final double wordPx = _zxMiniWordPx.wMin * scale;
    final double titlePx = _zxMiniTitlePx.wMin * scale;
    final double branchPx = _zxMiniBranchPx.wMin * scale;
    final double headGap = _zxMiniHeadGap.wMin * scale;
    final double anchorPad = _zxMiniAnchorPad.wMin * scale;
    final double curveH = _zxMiniCurveH.wMin * scale;
    final double gapX = _zxMiniGapX.wMin * scale;
    final double colPad = _zxMiniColPad.wMin * scale;

    // 分支过多时留一项位置给 +N
    final List<String> shown = branches.length > _zxMiniMaxBranches ? branches.sublist(0, _zxMiniMaxBranches - 1) : branches;
    final int rest = branches.length - shown.length;
    final List<String> leaves = rest > 0 ? [...shown, "+$rest"] : shown;

    final List<double> colWs = leaves.map((label) {
      return math.max(32.wMin * scale, _zxForestEstimateTextWidth(label, branchPx) + colPad);
    }).toList();
    final double rowW = colWs.fold<double>(0, (sum, width) => sum + width) + gapX * math.max(0, leaves.length - 1);
    final double headwordMaxWidth = 350.wMin * scale;
    final double titleMaxWidth = 350.wMin * scale;
    final TextPainter headwordPainter = TextPainter(
      text: TextSpan(
        text: headword,
        style: TextStyle(
          fontFamily: AppFontValue.robotoMono,
          fontSize: wordPx,
          height: 1,
          fontWeight: FontWeight.w500,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: Directionality.of(context),
    )..layout(maxWidth: headwordMaxWidth);
    final TextPainter titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          fontFamily: AppFontValue.sourceHanSerifCN,
          fontSize: titlePx,
          height: 1,
          fontWeight: FontWeight.w500,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: Directionality.of(context),
    )..layout(maxWidth: titleMaxWidth);
    final double headwordHeight = headword.isEmpty ? wordPx : headwordPainter.size.height;
    final double titleHeight = title.isEmpty ? titlePx : titlePainter.size.height;
    final double treeW = math.max(
      math.max(rowW, headwordMaxWidth),
      titleMaxWidth,
    );
    final double headH = headwordHeight + headGap + titleHeight;
    final double anchorY = headH + anchorPad;
    final double leafTopY = leaves.isEmpty ? headH : anchorY + curveH;
    final double rowLeft = (treeW - rowW) / 2;
    final double treeH = leafTopY + (leaves.isEmpty ? 0 : branchPx + 2.wMin * scale);

    final List<double> leafXs = [];
    double cursor = rowLeft;
    for (final double width in colWs) {
      leafXs.add(cursor + width / 2);
      cursor += width + gapX;
    }

    return SizedBox(
      width: treeW,
      height: treeH,
      child: Stack(
        children: [
          if (leaves.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: _ZxMiniForestTreePainter(
                  rootX: treeW / 2,
                  anchorY: anchorY,
                  leafTopY: leafTopY,
                  leafXs: leafXs,
                ),
              ),
            ),
          Column(
            children: [
              SizedBox(
                width: headwordMaxWidth,
                height: headwordHeight,
                child: Text(
                  headword,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFontValue.robotoMono,
                    fontSize: wordPx,
                    height: 1,
                    fontWeight: FontWeight.w500,
                    color: _zxForestWordColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: headGap),
                child: SizedBox(
                  width: titleMaxWidth,
                  height: titleHeight,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFontValue.sourceHanSerifCN,
                      fontSize: titlePx,
                      height: 1,
                      fontWeight: FontWeight.w500,
                      color: _zxForestTitleColor,
                    ),
                  ),
                ),
              ),
              if (leaves.isNotEmpty) SizedBox(height: anchorPad + curveH),
              if (leaves.isNotEmpty)
                SizedBox(
                  width: rowW,
                  child: Row(
                    spacing: gapX,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(leaves.length, (index) {
                      final bool isMute = leaves[index].startsWith("+");
                      return SizedBox(
                        width: colWs[index],
                        child: Text(
                          leaves[index],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            fontFamily: AppFontValue.sourceHanSerifCN,
                            fontSize: branchPx,
                            height: 1,
                            fontWeight: FontWeight.w500,
                            color: isMute ? _zxForestLeafMuteColor : _zxForestLeafColor,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ZxMiniForestTreePainter extends CustomPainter {
  final double rootX;
  final double anchorY;
  final double leafTopY;
  final List<double> leafXs;

  const _ZxMiniForestTreePainter({
    required this.rootX,
    required this.anchorY,
    required this.leafTopY,
    required this.leafXs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint basePaint = Paint()
      ..color = AppTheme.cZhenxieGold.color.withValues(alpha: 0.16)
      ..strokeWidth = 6.wMin
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint linePaint = Paint()
      ..color = AppTheme.cZhenxieAmberText.color.withValues(alpha: 0.55)
      ..strokeWidth = 1.7.wMin
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final double leafX in leafXs) {
      final double mid = math.max(12.wMin, (leafTopY - anchorY) / 1.7);
      final Path path = Path()
        ..moveTo(rootX, anchorY)
        ..cubicTo(rootX, anchorY + mid, leafX, leafTopY - mid, leafX, leafTopY);
      canvas.drawPath(path, basePaint);
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ZxMiniForestTreePainter oldDelegate) {
    return oldDelegate.rootX != rootX ||
        oldDelegate.anchorY != anchorY ||
        oldDelegate.leafTopY != leafTopY ||
        oldDelegate.leafXs != leafXs;
  }
}

/// 取多语言字段里的中文文案
String _zxForestZhText(List<LanguageText?>? texts) {
  for (final LanguageText? item in texts ?? const <LanguageText?>[]) {
    if (item?.lang == "zh") return item?.text ?? "";
  }
  return "";
}

/// 粗略估算文本宽度：空格窄、非 ASCII 视为一个字号宽
double _zxForestEstimateTextWidth(String text, double fontPx) {
  double width = 0;
  for (final int code in text.codeUnits) {
    if (code == 0x20) {
      width += fontPx * 0.33;
    } else if (code > 0xff) {
      width += fontPx;
    } else {
      width += fontPx * 0.62;
    }
  }
  return width.ceilToDouble();
}

/// 迷你词源树的字号与间距，对齐详情树
const double _zxMiniWordPx = 24;
const double _zxMiniTitlePx = 18;
const double _zxMiniBranchPx = 18;
const double _zxMiniHeadGap = 6;
const double _zxMiniAnchorPad = 8;
const double _zxMiniCurveH = 34;
const double _zxMiniGapX = 16;
const double _zxMiniColPad = 4;
/// 一行最多摊开的分支数，超出收敛为 +N
const int _zxMiniMaxBranches = 4;

Color get _zxForestCardColor => AppTheme.cZhenxieBackgroundPrimary.color;
Color get _zxForestBorderColor => AppTheme.cZhenxieBorderPrimary.color;
Color get _zxForestBadgeBgColor => AppTheme.cZhenxieBackgroundPrimary.color;
Color get _zxForestBadgeBorderColor => AppTheme.cZhenxieBorderPrimary.color;
Color get _zxForestBadgeTextColor => AppTheme.cZhenxieFontTertiary.color;
Color get _zxForestCountColor => AppTheme.cZhenxieFontTertiary.color;
Color get _zxForestDescColor => AppTheme.cZhenxieFontTertiary.color;
Color get _zxForestWordColor => AppTheme.cZhenxieFontPrimary.color;
Color get _zxForestTitleColor => AppTheme.cZhenxieColorPrimary.color;
Color get _zxForestLeafColor => AppTheme.cZhenxieFontPrimary.color;
Color get _zxForestLeafMuteColor => AppTheme.cZhenxieFontTertiary.color.withValues(alpha: 0.55);
