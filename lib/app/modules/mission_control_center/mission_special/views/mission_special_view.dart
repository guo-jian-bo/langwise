import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../../official_course_details/course_unit_target/views/course_unit_target_writing_card_widget.dart';
import '../../../../routes/routes.dart';
import '../bindings/mission_special_binding.dart';
import '../controllers/mission_special_controller.dart';

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
    final activeAccent = const Color(0xFFE2B93B);
    final copy = _buildDiamondCopy(diamondCount);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgSecondary.color,
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(
          color: activeAccent.withValues(alpha: 0.18),
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
                copy.title,
                style: TextStyle(
                  fontSize: 22.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 2.wMin),
              Text(
                copy.subtitle,
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextSecondary.color,
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

  _MissionSpecialDiamondCopy _buildDiamondCopy(int diamondCount) {
    final nextDiamondNeedMinutes = _buildNextDiamondNeedMinutes();
    if (diamondCount <= 0) {
      return _MissionSpecialDiamondCopy(
        title: '蓄势待发',
          subtitle: '$nextDiamondNeedMinutes分钟就能拿下首钻',
      );
    }
    if (diamondCount == 1) {
      return _MissionSpecialDiamondCopy(
        title: '乘胜追击',
          subtitle: '再练$nextDiamondNeedMinutes分钟，就能完美双钻',
      );
    }
    return const _MissionSpecialDiamondCopy(
      title: '完美双钻',
      subtitle: '你真的太棒啦，坚持就有所获',
    );
  }

  int _buildNextDiamondNeedMinutes() {
    final nextDiamondNeedSec = controller.nextDiamondNeedSec;
    if (nextDiamondNeedSec <= 0) return 1;
    return (nextDiamondNeedSec / 60).ceil();
  }

  Widget _buildDiamondCircle({required bool active}) {
    final backgroundColor = active ? const Color(0xFFE2B93B).withValues(alpha: 0.14) : AppTheme.cSurfaceLayerBase.color;
    final borderColor = active ? const Color(0xFFE2B93B) : AppTheme.cBorderPrimary.color;
    final assetPath = active ? 'assets/images/mission/icon_diamond_yes.png' : 'assets/images/mission/icon_diamond.png';
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

  Widget _buildBodyWidget(BuildContext context) {
    return Obx(() {
      if (controller.dataStatus.value == -1) {
        return const SizedBox.shrink();
      }
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
            if (controller.taskType != LSRWEnum.overall) _buildOverviewWidget(items),
            if (showExpansion) ...[
              SizedBox(height: 18.wMin),
              Text(
                '拓展内容',
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 14.wMin),
              _buildListWidget(context, items),
              
            ],
            SizedBox(height: 14.wMin),
            _buildTipsWidget(),
          ],
        ),
      );
    });
  }

  Widget _buildOverviewWidget(List<KnowledgeCommonEntityList> items) {
    final taskSpecial = controller.taskSpecial.value;
    final title = taskSpecial.title?.trim();
    final description = taskSpecial.description?.trim();
    final accentColor = ColorUtils.parseColor(taskSpecial.color) ?? const Color(0xFF8B5CF6);
    final pageTitle = (title == null || title.isEmpty) ? '今日必读' : title;
    final pageDescription = (description == null || description.isEmpty) ? '先读懂今天，再向更真实的内容迈一步。' : description;
    final itemCount = items.length;
    final knowledgeList = controller.specialKnowledgeList;
    final newList = knowledgeList.where((item) => item.isNewKnowledge).toList();
    final reviewList = knowledgeList.where((item) => item.isOldKnowledge).toList();
    final totalKnowledge = knowledgeList.length;
    final overviewCard = Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: accentColor.withValues(alpha: 0.10),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.12),
          width: 1.wMin,
        ),
      ),
      child: Row(
        children: [
          _buildOverviewIcon(taskSpecial.iconUrl?.trim(), accentColor),
          SizedBox(width: 16.wMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TODAY CORE',
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: accentColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4.wMin),
                Text(
                  pageTitle,
                  style: TextStyle(
                    fontSize: 40.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.wMin),
                Text(
                  pageDescription,
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
    if (controller.isSpeakingTask) {
      return overviewCard;
    }
    return TapScaleWidget(
      onTap: controller.onTapSelectContent,
      sclae: 1,
      child: overviewCard,
    );
  }

  Widget _buildOverviewIcon(String? iconUrl, Color accentColor) {
    if (iconUrl == null || iconUrl.isEmpty) {
      return _buildOverviewIconFallback();
    }
    return Image.network(
      iconUrl,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _buildOverviewIconFallback(),
      height: 120.wMin,
    );
  }

  Widget _buildOverviewIconFallback() {
    return Center(
      child: Icon(
        Icons.menu_book_rounded,
        size: 44.wMin,
        color: AppTheme.cTextPrimary.color,
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
        color: AppTheme.cSurfaceLayerBase,
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
            spacing: 6.wMin,
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
        color: AppTheme.cSurfaceLayerDarken,
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
              color: AppTheme.cTextPrimary,
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
      width: 260.wMin,
      height: 130.wMin,
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerBase,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '总数',
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.wMin),
              Text(
                '$totalKnowledge 个知识点',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (hasKnowledge) _buildTotalActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTotalActionButtons() {
    if (controller.isSpeakingTask) {
      return Row(
        children: [
          Expanded(
            child: _buildContentActionButton(
              label: '自拼音标',
              onTap: controller.onTapSelectSpeakingSoundBlock,
              expand: true,
            ),
          ),
          SizedBox(width: 8.wMin),
          Expanded(
            child: _buildContentActionButton(
              label: '影子跟读',
              onTap: controller.onTapSelectSpeakingPronunciation,
              expand: true,
            ),
          ),
        ],
      );
    }
    return _buildContentActionButton(
      label: _buildPrimaryContentActionLabel(),
      onTap: controller.onTapSelectContent,
      expand: true,
    );
  }

  String _buildPrimaryContentActionLabel() {
    switch (controller.taskType) {
      case LSRWEnum.listening:
        return '进入情景';
      case LSRWEnum.reading:
        return '开始认读';
      case LSRWEnum.writing:
        return '开始听写';
      case LSRWEnum.overall:
      default:
        return '挑选内容';
    }
  }

  Widget _buildContentActionButton({
    required String label,
    required VoidCallback onTap,
    bool expand = false,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      child: Container(
        width: expand ? double.infinity : null,
        height: 32.wMin,
        padding: EdgeInsets.symmetric(horizontal: 8.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cTextPrimary.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6.wMin),
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 6.wMin),
            SvgPicture.asset(
              'assets/svg/mission/icon_right.svg',
              height: 15.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
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

  Widget _buildListWidget(BuildContext context, List<KnowledgeCommonEntityList> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: controller.taskType == LSRWEnum.writing ? 3 : 4,
        mainAxisSpacing: 24.wMin,
        crossAxisSpacing: 24.wMin,
        childAspectRatio: controller.taskType == LSRWEnum.writing ? 580 / 410 : 417 / 639,
        mainAxisExtent: controller.taskType == LSRWEnum.writing ? 430.wMin : null,
      ),
      itemBuilder: (context, index) {
        if (controller.taskType == LSRWEnum.writing) {
          return CourseUnitTargetWritingCardWidget(
            isManagement: false,
            unitId: null,
            data: items[index],
            rights: items[index].rights,
            onReturned: () => controller.refreshPageData(syncDailyTask: true),
          );
        }
        return KnowledgeCardWidget(
          knowledgeData: items[index],
          onReturned: () => controller.refreshPageData(syncDailyTask: true),
        );
      },
    );
  }

  Widget _buildTipsWidget() {
    final taskSpecial = controller.taskSpecial.value;
    final accentColor =
        ColorUtils.parseColor(taskSpecial.color) ?? const Color(0xFF8B5CF6);
    final displayTexts = _resolveLearnDirectionTexts(taskSpecial);
    if (displayTexts.isEmpty) {
      return const SizedBox.shrink();
    }
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
                color: accentColor,
              ),
              SizedBox(width: 8.wMin),
              Text(
                '这个方向有什么内容',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary.color,
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

  List<String> _resolveLearnDirectionTexts(MissionSpecialV3Entity taskSpecial) {
    final rawTexts = taskSpecial.learnDirections?.isNotEmpty == true
        ? taskSpecial.learnDirections!
        : <String>[taskSpecial.direction?.trim() ?? ''];
    return rawTexts
        .expand(
          (text) => text.split(RegExp(r'(?<=[。！？])\s*[,，]\s*|[\n;；]+')),
        )
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}

class _MissionSpecialDiamondCopy {
  final String title;
  final String subtitle;

  const _MissionSpecialDiamondCopy({
    required this.title,
    required this.subtitle,
  });
}
