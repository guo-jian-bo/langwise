import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../controllers/zhenxie_composition_stages_controller.dart';
import '../models/zhenxie_composition_discourse_models.dart';
import '../models/zhenxie_composition_stages_models.dart';

/// 底条里段型项、文类框、视图开关同高，才坐得住。
const double _stripItemHeight = 58;

/// 条高（设计像素，对外按 wMin 缩放）
const double _stripHeight = 96;

/// 起承转合四点，顺序与 React BEAT_LEGEND 一致。
List<Color> get _beatDotColors => <Color>[
      AppTheme.cZhenxieColorSecondary.color,
      const Color(0xFF2F6FAD),
      const Color(0xFFE09A1A),
      AppTheme.cZhenxieFontPrimary.color,
    ];

/// 用户端底条：左「每篇都由这 9 种段拼出来」+ 九段型，右四文类计数 + 书架/地图开关。
class ZhenxieCompositionUserStripWidget extends StatelessWidget {
  /// 数据源：段型 / 文类来自 discourse/home，计数由 controller 按当前视图派生
  final ZhenxieCompositionStagesController controller;

  const ZhenxieCompositionUserStripWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => _buildStripWidget());
  }

  /// 底条整体：段型 / 文类 / 计数 / 开关都跟着 controller 的数据刷新
  Widget _buildStripWidget() {
    final List<CompositionParagraphTypeModel> types = controller.discourseHome.value?.paragraphTypes ?? const <CompositionParagraphTypeModel>[];
    return Container(
      width: double.infinity,
      height: _stripHeight.wMin,
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgPrimary.color,
        border: Border(top: BorderSide(color: AppTheme.cBorderThin.color, width: 1.wMin)),
      ),
      child: Row(
        spacing: 28.wMin,
        children: <Widget>[
          _buildIntroTextWidget(),
          Expanded(child: _buildParagraphTypeListWidget(types)),
          _buildGenreCountListWidget(),
          Container(width: 1.wMin, height: 32.wMin, color: AppTheme.cBorderThin.color),
          _buildViewSwitchWidget(),
        ],
      ),
    );
  }

  /// 段型条文案，直接用接口给的整句，如「每篇都由这 9 种段拼出来」
  Widget _buildIntroTextWidget() {
    final String hint = controller.discourseHome.value?.paragraphTypeHint ?? '';
    if (hint.isEmpty) return const SizedBox.shrink();
    return Text(
      hint,
      style: TextStyle(fontSize: 16.wMin, color: AppTheme.cZhenxieFontSecondary.color),
    );
  }

  /// 九种段型：名字 + 起承转合四点
  Widget _buildParagraphTypeListWidget(List<CompositionParagraphTypeModel> types) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8.wMin,
        children: <Widget>[
          for (final CompositionParagraphTypeModel type in types)
            GestureDetector(
              onTap: () => controller.openShelfParagraphType(type.nid ?? ''),
              child: Container(
                height: _stripItemHeight.wMin,
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      controller.getLangText(type.name, 'zh'),
                      style: TextStyle(
                        fontSize: 18.wMin,
                        height: 1,
                        fontFamily: AppFontValue.sourceHanSerifCN,
                        color: AppTheme.cZhenxieFontPrimary.color,
                      ),
                    ),
                    SizedBox(height: 10.wMin),
                    _buildBeatDotsWidget(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBeatDotsWidget() {
    return Row(
      spacing: 5.wMin,
      children: <Widget>[
        for (final Color color in _beatDotColors)
          Container(width: 9.wMin, height: 9.wMin, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      ],
    );
  }

  /// 四文类计数框
  Widget _buildGenreCountListWidget() {
    final Map<String, int> counts = controller.buildGenreCountMap();
    final String unit = controller.getGenreCountUnit();
    return Row(
      spacing: 10.wMin,
      children: <Widget>[
        for (final CompositionGenreModel genre in controller.genreList) _buildGenreCountBoxWidget(genre, counts, unit),
      ],
    );
  }

  Widget _buildGenreCountBoxWidget(CompositionGenreModel genre, Map<String, int> counts, String unit) {
    final Color color = controller.getGenreColor(genre.nid);
    return Container(
      height: _stripItemHeight.wMin,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 2.wMin),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            controller.getLangText(genre.name, 'zh'),
            style: TextStyle(
              fontSize: 16.wMin,
              height: 1,
              fontFamily: AppFontValue.sourceHanSerifCN,
              color: AppTheme.cZhenxieFontPrimary.color,
            ),
          ),
          SizedBox(height: 6.wMin),
          Text(
            '${counts[genre.nid] ?? 0} $unit',
            style: TextStyle(
              fontSize: 12.wMin,
              height: 1,
              fontFamily: AppFontValue.robotoMono,
              color: AppTheme.cZhenxieFontSecondary.color,
            ),
          ),
        ],
      ),
    );
  }

  /// 书架 ⇄ 地图
  Widget _buildViewSwitchWidget() {
    return Container(
      padding: EdgeInsets.all(2.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(color: AppTheme.cBorderThin.color, width: 1.wMin),
      ),
      child: Row(
        spacing: 2.wMin,
        children: <Widget>[
          _buildViewSwitchItemWidget('shelf', '书架'),
          _buildViewSwitchItemWidget('map', '地图'),
        ],
      ),
    );
  }

  Widget _buildViewSwitchItemWidget(String value, String text) {
    final bool selected = controller.currentView.value == value;
    return GestureDetector(
      onTap: () => controller.switchView(value),
      child: Container(
        height: (_stripItemHeight - 4).wMin,
        padding: EdgeInsets.symmetric(horizontal: 20.wMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppTheme.cTextPrimary.color : Colors.transparent,
          borderRadius: BorderRadius.circular(999.wMin),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15.wMin,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            color: selected ? AppTheme.cBgPrimary.color : AppTheme.cZhenxieFontTertiary.color,
          ),
        ),
      ),
    );
  }
}
