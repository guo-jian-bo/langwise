import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../controllers/zhenxie_composition_stages_controller.dart';
import '../models/zhenxie_composition_discourse_models.dart';

/// 一竖列放几张瓦片
const int _shelfRows = 5;

/// 封面边长 / 瓦片宽 / 瓦片间距（设计像素，对外按 wMin 缩放）
const double _shelfCover = 120;
const double _shelfTileWidth = 120;
const double _shelfColumnGap = 12;
const double _shelfRowGap = 8;

/// 一格大关：通常一道大关；不新增文类的大关并入前一格，共享一格。
class _ZhenxieShelfSection {
  _ZhenxieShelfSection({required this.gates, required this.blueprints, required this.columns, this.note});

  /// 本格承载的大关，并入时多于一道
  final List<CompositionShelfGateModel> gates;

  /// 本格瓦片，按接口返回序
  final List<CompositionShelfBlueprintModel> blueprints;

  /// 竖列数 = ceil(张数 / 每列张数)
  final int columns;

  /// 并入本格的空大关说明
  String? note;

  /// 展示时把说明瓦片也算进来，避免最后一列被挤出布局
  int get displayColumns => math.max(1, ((blueprints.length + (note == null ? 0 : 1)) / _shelfRows).ceil());

}

/// 书架分格：一张蓝图放在它开始教的那一关（difficulty），空关并入前一格。
List<_ZhenxieShelfSection> _buildShelfSections(
  List<CompositionShelfGateModel> gates,
  List<CompositionShelfBlueprintModel> blueprints,
) {
  if (gates.isEmpty) return <_ZhenxieShelfSection>[];
  final int lastDifficulty = gates.last.difficulty;
  final List<_ZhenxieShelfSection> sections = <_ZhenxieShelfSection>[];
  for (final CompositionShelfGateModel gate in gates) {
    final List<CompositionShelfBlueprintModel> own = blueprints
        .where((row) => math.min(row.difficulty ?? 0, lastDifficulty) == gate.difficulty)
        .toList();
    // 这一关不新增文类：并进前一格，只留一句说明
    if (own.isEmpty && sections.isNotEmpty) {
      sections.last.gates.add(gate);
      sections.last.note = '${gate.title}：不新增文类，只加难度';
      continue;
    }
    sections.add(
      _ZhenxieShelfSection(
        gates: <CompositionShelfGateModel>[gate],
        blueprints: own,
        columns: math.max(1, (own.length / _shelfRows).ceil()),
        note: own.isEmpty ? '${gate.title}：不新增文类，只加难度' : null,
      ),
    );
  }
  return sections;
}

/// 皮的线稿图标：React 用 lucide，项目无该图标库，这里映射到 Material 图标。
IconData _skinIcon(String skinNid) {
  switch (skinNid) {
    case 'sticky_note':
      return Icons.sticky_note_2_outlined;
    case 'name_tag':
      return Icons.sell_outlined;
    case 'form_blank':
      return Icons.assignment_outlined;
    case 'picture_page':
      return Icons.image_outlined;
    case 'profile_card':
      return Icons.badge_outlined;
    case 'email_client':
      return Icons.mail_outline;
    case 'letter_paper':
      return Icons.edit_note;
    case 'message_slip':
      return Icons.chat_bubble_outline;
    case 'diary_notebook':
      return Icons.auto_stories_outlined;
    case 'textbook_page':
      return Icons.book_outlined;
    case 'report_paper':
      return Icons.description_outlined;
    case 'bulletin_board':
      return Icons.push_pin_outlined;
    case 'speech_card':
      return Icons.mic_none;
    case 'newspaper_column':
      return Icons.article_outlined;
    case 'storybook_spread':
      return Icons.collections_bookmark_outlined;
    case 'chart_sheet':
      return Icons.insert_chart_outlined;
    default:
      return Icons.description_outlined;
  }
}

/// 大关书架：一格一道考试大关，每竖列四张，格宽按竖列数分。
class ZhenxieCompositionShelfWidget extends StatelessWidget {
  /// 书架数据源：大关来自 discourse/home 的 milestones，瓦片来自 blueprint/list
  final ZhenxieCompositionStagesController controller;

  const ZhenxieCompositionShelfWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => _buildShelfWidget());
  }

  /// 大关书架整体：一格一道大关，数据到位后自动刷新
  Widget _buildShelfWidget() {
    final List<_ZhenxieShelfSection> sections = _buildShelfSections(
      controller.shelfGateList,
      controller.shelfBlueprintList,
    );
    if (sections.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int index = 0; index < sections.length; index++) ...<Widget>[
          if (index > 0) SizedBox(width: 20.wMin),
          IntrinsicWidth(child: _buildSectionWidget(sections[index])),
        ],
      ],
    );
  }

  /// 一格大关：关名横条 + 瓦片网格 + 并入说明
  Widget _buildSectionWidget(_ZhenxieShelfSection section) {
    final List<Widget> tiles = <Widget>[
      for (final CompositionShelfBlueprintModel blueprint in section.blueprints)
        _ZhenxieShelfTileWidget(
          blueprint: blueprint,
          name: controller.getLangText(blueprint.name, 'zh'),
          genreColor: controller.getGenreColor(blueprint.genreNid),
          onTap: controller.openShelfBlueprintPage,
        ),
      if (section.note != null) _ZhenxieShelfNoteTileWidget(text: section.note!),
    ];
    final int displayColumns = section.displayColumns;
    final double gridWidth = displayColumns * _shelfTileWidth + (displayColumns - 1) * _shelfColumnGap;
    final List<List<Widget>> columns = <List<Widget>>[
      for (int col = 0; col < displayColumns; col++)
        tiles.sublist(col * _shelfRows, math.min((col + 1) * _shelfRows, tiles.length)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildSectionHeaderWidget(section),
        Padding(
          padding: EdgeInsets.only(top: 16.wMin),
          child: SizedBox(
            width: gridWidth.wMin,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int col = 0; col < columns.length; col++) ...<Widget>[
                  if (col > 0) SizedBox(width: _shelfColumnGap.wMin),
                  Column(
                    children: <Widget>[
                      for (int row = 0; row < columns[col].length; row++) ...<Widget>[
                        if (row > 0) SizedBox(height: _shelfRowGap.wMin),
                        columns[col][row],
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 关名横条：多道大关（并格）时中间插一条竖线
  Widget _buildSectionHeaderWidget(_ZhenxieShelfSection section) {
    return Container(
      padding: EdgeInsets.only(bottom: 10.wMin),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.cBorderThin.color, width: 1.wMin)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int index = 0; index < section.gates.length; index++) ...<Widget>[
            if (index > 0) ...<Widget>[
              SizedBox(width: 20.wMin),
              Container(
                width: 1.wMin,
                height: 32.wMin,
                margin: EdgeInsets.only(top: 4.wMin),
                color: AppTheme.cBorderThin.color,
              ),
              SizedBox(width: 20.wMin),
            ],
            Column(
              children: <Widget>[
                Text(
                  section.gates[index].title,
                  style: TextStyle(
                    fontSize: 21.wMin,
                    height: 1,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                SizedBox(height: 4.wMin),
                Text(
                  section.gates[index].alias,
                  style: TextStyle(
                    fontSize: 12.wMin,
                    height: 1,
                    fontFamily: AppFontValue.robotoMono,
                    color: AppTheme.cTextSecondary.color.withValues(alpha: 0.38),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 书架瓦片：有封面用封面，没封面退回文类色块 + 皮的线稿图标。
class _ZhenxieShelfTileWidget extends StatelessWidget {
  final CompositionShelfBlueprintModel blueprint;

  /// 蓝图名（本地语）
  final String name;

  /// 文类色，跟着当前主题
  final Color genreColor;

  final ValueChanged<CompositionShelfBlueprintModel> onTap;

  const _ZhenxieShelfTileWidget({
    required this.blueprint,
    required this.name,
    required this.genreColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String coverUrl = blueprint.coverUrl ?? '';
    final bool hasCover = coverUrl.isNotEmpty;
    return GestureDetector(
      onTap: () => onTap(blueprint),
      child: SizedBox(
        width: _shelfTileWidth.wMin,
        child: Column(
          children: <Widget>[
            Container(
              width: _shelfCover.wMin,
              height: _shelfCover.wMin,
              decoration: BoxDecoration(
                color: hasCover ? AppTheme.cSurfaceLayerBase.color : genreColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16.wMin),
                border: Border.all(color: genreColor.withValues(alpha: 0.55), width: 2.wMin),
              ),
              child: Stack(
                children: <Widget>[
                  if (hasCover)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.wMin),
                        child: CachedImageWidget(
                          coverUrl,
                          fit: BoxFit.cover,
                          errorWidget: _buildSkinIconWidget(),
                        ),
                      ),
                    )
                  else
                    Center(child: _buildSkinIconWidget()),
                  // 有文首 / 文尾的角标
                  if (blueprint.hasHead || blueprint.hasTail)
                    Positioned(right: 6.wMin, top: 6.wMin, child: _buildFrameDotWidget()),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.wMin, left: 4.wMin, right: 4.wMin),
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5.wMin,
                  height: 1.3,
                  color: AppTheme.cTextSecondary.color.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkinIconWidget() {
    return Icon(_skinIcon(blueprint.skinNid ?? ''), size: (_shelfCover * 0.42).round().wMin, color: genreColor);
  }

  Widget _buildFrameDotWidget() {
    return Container(
      width: 8.wMin,
      height: 8.wMin,
      decoration: BoxDecoration(
        color: AppTheme.cTextSecondary.color,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.cBgPrimary.color, width: 1.wMin),
      ),
    );
  }
}

/// 并入说明瓦片：作为列表末尾的一个说明格，跟随网格一起排布。
class _ZhenxieShelfNoteTileWidget extends StatelessWidget {
  final String text;

  const _ZhenxieShelfNoteTileWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _shelfTileWidth.wMin,
      child: Container(
        width: _shelfCover.wMin,
        height: _shelfCover.wMin,
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 10.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase.color,
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(color: AppTheme.cZhenxieColorPrimary.withValues(alpha:  0.72), width: 2.wMin),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5.wMin,
            height: 1.5,
            color: AppTheme.cTextSecondary.color.withValues(alpha: 0.72),
          ),
        ),
      ),
    );
  }
}
