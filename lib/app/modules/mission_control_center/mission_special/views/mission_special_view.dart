import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../routes/routes.dart';
import '../bindings/mission_special_binding.dart';
import '../controllers/mission_special_controller.dart';
import 'mission_special_card_widget.dart';

class MissionSpecialView extends GetView<MissionSpecialController> {
  final String tagText;
  const MissionSpecialView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => MissionSpecialView(tagText: tag),
      binding: MissionSpecialBinding(tagText: tag),
      routeName: Routes.MISSION_SPECIAL,
      arguments: arguments,
      preventDuplicates: false,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BreadcrumbWidget(
            actionWidget: Obx(() => _buildBreadcrumbDiamondWidget()),
          ),
          Expanded(child: _buildBodyWidget(context)),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbDiamondWidget() {
    final diamondMax = controller.specialDiamondMax;
    if (diamondMax <= 0) return const SizedBox.shrink();
    final diamondCount = controller.specialDiamondCount.clamp(0, diamondMax);
    final isFullDiamond = diamondCount >= diamondMax;
    final title = isFullDiamond ? '完美${_diamondLevelText(diamondMax)}' : '乘胜追击';
    final subtitle = _buildDiamondSubtitle(
      diamondCount: diamondCount,
      diamondMax: diamondMax,
      nextNeedSec: controller.nextDiamondNeedSec,
      unlockCount: controller.unlockTaskCount,
      allCount: controller.totalTaskCount,
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        color: const Color(0xFF171B24),
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(
          color: const Color(0xFF3A2F17),
          width: 1.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              diamondMax,
              (index) => Padding(
                padding: EdgeInsets.only(right: index == diamondMax - 1 ? 0 : 8.wMin),
                child: _buildDiamondCircle(active: index < diamondCount),
              ),
            ),
          ),
          SizedBox(width: 12.wMin),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 22.wMin,
                  color: AppTheme.cStaticWhite.color,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 2.wMin),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiamondCircle({required bool active}) {
    final backgroundColor = active ? const Color(0xFF4A3A12) : const Color(0xFF222833);
    final borderColor = active ? const Color(0xFFE2B93B) : const Color(0xFF374151);
    final assetPath =
        active ? 'assets/images/mission/icon_diamond_yes.png' : 'assets/images/mission/icon_diamond.png';
    return Container(
      width: 40.wMin,
      height: 40.wMin,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 1.wMin,
        ),
      ),
      child: Center(
        child: Image.asset(
          assetPath,
          width: 20.wMin,
          height: 20.wMin,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  String _buildDiamondSubtitle({
    required int diamondCount,
    required int diamondMax,
    required int nextNeedSec,
    required int unlockCount,
    required int allCount,
  }) {
    if (diamondCount >= diamondMax) {
      return '已获得全部${_diamondLevelText(diamondMax)}';
    }
    if (nextNeedSec > 0) {
      return '再练 ${_formatMinutes(nextNeedSec)}，就能完美${_diamondLevelText(diamondMax)}';
    }
    if (allCount > 0) {
      return '已解锁 $unlockCount/$allCount 个任务';
    }
    return '继续练习，解锁更多钻石';
  }

  String _diamondLevelText(int count) {
    if (count <= 1) return '单钻';
    if (count == 2) return '双钻';
    if (count == 3) return '三钻';
    return '$count钻';
  }

  String _formatMinutes(int seconds) {
    final minutes = seconds <= 0 ? 0 : ((seconds + 30) ~/ 60);
    return '$minutes 分钟';
  }

  Widget _buildBodyWidget(BuildContext context) {
    return Obx(() {
      if (controller.dataStatus.value == 1) {
        return const NotDataWidget(message: "暂无任务");
      }

      final items = controller.taskSpecialList.toList();
      final showExpansion = items.isNotEmpty;
      return SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 40.wMin,
          right: 40.wMin,
          bottom: MediaQuery.of(context).padding.bottom + 24.wMin,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewWidget(items),
            if (showExpansion) ...[
              SizedBox(height: 18.wMin),
              Text(
                '拓展内容',
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cStaticWhite.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 14.wMin),
              _buildListWidget(context, items),
              SizedBox(height: 14.wMin),
            ],
            _buildTipsWidget(items),
          ],
        ),
      );
    });
  }

  Widget _buildOverviewWidget(List<TaskMissionMenuListEntityList> items) {
    final title = controller.taskSpecial.value.title?.trim();
    final pageTitle = (title == null || title.isEmpty) ? '今日必读' : '今日$title';
    final itemCount = items.length;
    final knowledgeList = controller.specialKnowledgeList;
    final newList = knowledgeList.where((item) => item.isNewKnowledge).toList();
    final reviewList = knowledgeList.where((item) => item.isOldKnowledge).toList();
    final totalKnowledge = knowledgeList.length;
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF120E21),
            Color(0xFF0A0915),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF221A35),
          width: 1.wMin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64.wMin,
            height: 64.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.wMin),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFF4C1D95),
                ],
              ),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 34.wMin,
              color: AppTheme.cStaticWhite.color,
            ),
          ),
          SizedBox(width: 16.wMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TODAY CORE',
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: const Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4.wMin),
                Text(
                  pageTitle,
                  style: TextStyle(
                    fontSize: 40.wMin,
                    color: AppTheme.cStaticWhite.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.wMin),
                Text(
                  '先读懂今天，再向更真实的内容迈一步。',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSummaryGroup(
                title: '旧识',
                accentColor: const Color(0xFFF59E0B),
                total: reviewList.length,
                tiles: _buildKnowledgeTiles(reviewList),
              ),
              SizedBox(width: 10.wMin),
              _buildSummaryGroup(
                title: '新知',
                accentColor: const Color(0xFF84CC16),
                total: newList.length,
                tiles: _buildKnowledgeTiles(newList),
              ),
              SizedBox(width: 10.wMin),
              _buildTotalGroup(itemCount, totalKnowledge),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGroup({
    required String title,
    required Color accentColor,
    required int total,
    required List<String> tiles,
  }) {
    return Container(
      height: 130.wMin,
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cStaticWhite.color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: accentColor,
                ),
              ),
              SizedBox(width: 8.wMin),
              Text(
                '小计 $total 个',
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Spacer(),
          Row(
            spacing:6.wMin,
            children: tiles.map((item) {
              final parts = item.split(' ');
              final label = parts.firstOrNull ?? '单词';
              final value = parts.length > 1 ? parts[1] : '0';
              return _buildMetricTile(label, value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Container(
      width: 90.wMin,
      padding: EdgeInsets.symmetric(vertical: 6.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cStaticWhite.color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextTertiary.color,
         
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cStaticWhite.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalGroup(int itemCount, int totalKnowledge) {
    final hasKnowledge = controller.specialKnowledgeList.isNotEmpty;
    return Container(
      height: 130.wMin,
      padding: EdgeInsets.symmetric(horizontal: 14.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cStaticWhite.color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '共计',
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cStaticWhite.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.wMin),
              Text(
                '知识点',
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
              Text(
                '$totalKnowledge',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cStaticWhite.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (hasKnowledge) ...[
            SizedBox(width: 18.wMin),
            if (controller.isSpeakingTask)
              Wrap(
                spacing: 8.wMin,
                runSpacing: 8.wMin,
                children: [
                  _buildContentActionButton(
                    label: '自拼音标',
                    onTap: controller.onTapSelectSpeakingSoundBlock,
                  ),
                  _buildContentActionButton(
                    label: '影子跟读',
                    onTap: controller.onTapSelectSpeakingPronunciation,
                  ),
                ],
              )
            else
              _buildContentActionButton(
                label: '挑选内容',
                onTap: controller.onTapSelectContent,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildContentActionButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      child: Container(
        height: 52.wMin,
        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cStaticWhite.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.wMin),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cStaticWhite.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6.wMin),
            SvgPicture.asset(
              'assets/svg/mission/icon_right.svg',
              width: 8.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cStaticWhite.color, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _buildKnowledgeTiles(List<TaskMissionEntityMissionKnowledgeItem> items) {
    final wordCount = items.where((item) => item.isWord).length;
    final phraseCount = items.where((item) => item.isPhrase).length;
    final sentenceCount = items.where((item) => item.isSentence).length;
    return [
      '单词 $wordCount',
      '短语 $phraseCount',
      '句子 $sentenceCount',
    ];
  }

  Widget _buildListWidget(BuildContext context, List<TaskMissionMenuListEntityList> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossCount = 5;
        final spacing = 16.wMin;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: 16.wMin,
            mainAxisExtent: 500.wMin,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return MissionSpecialCardWidget(
              index: index,
              data: item,
              onTap: (value) {
                controller.onTapItem(context, value);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTipsWidget(List<TaskMissionMenuListEntityList> items) {
    final texts = items
        .map((e) => e.explanation?.trim())
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .take(4)
        .toList();
    final displayTexts = texts.isEmpty
        ? const ['今日任务复习了新学知识点的理解强化', '甄读中时文文章阅读模式']
        : texts;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.wMin),
        color: AppTheme.cBgSecondary.color,
        border: Border.all(
          color: AppTheme.cBgTertiary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 24.wMin,
                color: const Color(0xFF8B5CF6),
              ),
              SizedBox(width: 8.wMin),
              Text(
                '这个方向有什么内容',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cStaticWhite.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.wMin),
          Wrap(
            spacing: 8.wMin,
            runSpacing: 8.wMin,
            children: displayTexts
                .map(
                  (text) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 8.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.wMin),
                      color: AppTheme.cSurfaceLayerBase.color,
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextSecondary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
