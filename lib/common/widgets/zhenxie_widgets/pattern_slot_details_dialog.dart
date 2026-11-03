import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../../../utils/utils.dart';
import '../../entities/entities.dart';
import '../../../theme/theme.dart';
import '../widgets.dart';

/// 槽位详情
class PatternSlotDetailsDialog {
  static Future<void> show({
    required BuildContext context,
    required SentenceSlotMapItemEntity item,
    bool isManagement = false,
  }) async {
    return await showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return PatternSlotDetailsDialogWidget(item: item, isManagement: isManagement);
      },
    );
  }
}

enum _ControlledVariantTone {
  affirmative,
  negative,
  neutral,
}

class _ControlledVariantTheme {
  final Color primaryColor;
  final Color accentColor;

  const _ControlledVariantTheme({
    required this.primaryColor,
    required this.accentColor,
  });
}

class PatternSlotDetailsDialogWidget extends StatelessWidget {
  final SentenceSlotMapItemEntity item;
  final bool isManagement;

  const PatternSlotDetailsDialogWidget({
    super.key,
    required this.item,
    this.isManagement = false,  
  });

  @override
  Widget build(BuildContext context) {
    final SentenceSlotMapBlueprintDetailsEntity? details = item.details?.blueprint;
    final bool hasControlVariants = details?.controlledVariants.isNotEmpty ?? false;

    return DialogUserWidget(
      title: "槽位详情",
      width: !hasControlVariants ? 720.wMin : 1200.wMin,
      physics: const ClampingScrollPhysics(),
      titlePadding: EdgeInsets.only(
        left: 32.wMin,
        right: 32.wMin,
        top: 32.wMin,
        bottom: 12.wMin,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(32.wMin, 0, 32.wMin, 32.wMin),
        constraints: BoxConstraints(
          minHeight: 300.wMin,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitleWidget(details),
            _buildContentTagsWidget(details),
            SizedBox(height: 16.wMin),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                border: Border.all(
                  color: AppTheme.cBorderSubtle.color,
                  width: 1.wMin,
                ),
              ),
              child: _buildContentWidget(details),
            ),
          ],
        ),
      ),
    );
  }

  String sentenceSlotMapLocalText(List<LanguageText?>? values) {
    return LearningLangUtils.getLocalLang(values)?.text?.trim() ?? '';
  }

  Widget _buildTitleWidget(SentenceSlotMapBlueprintDetailsEntity? details) {
    final SentenceSlotMapBlueprintDetailsEntity? details = item.details?.blueprint;
    final String title = details?.displayName??'';

    final Color primaryColor = ColorUtils.parseColor(details?.slot?.color) ?? AppTheme.cSurfaceBrand.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 10.wMin,
          children: [

            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 8.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: primaryColor.withValues(alpha: 0.2),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.45),
                  width: 0.8.wMin,
                ),
              ),
              child: SuperpositionTextWidget(
                text: title,
                foregroundColor: primaryColor.withValues(alpha: 0.3),
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            ),

            CopyTagWidget(
              name: "槽",
              value: details?.slot?.nid??'',
              isShow: isManagement,
            )

          ],
        ),
        SizedBox(height: 10.wMin),
        CopyTagWidget(
          name: "句型",
          value: details?.patternNid??'',
          isShow: isManagement,
        ),
      ],
    );
  }

  Widget _buildContentTagsWidget(SentenceSlotMapBlueprintDetailsEntity? details) {
    final Color primaryColor = ColorUtils.parseColor(details?.slot?.color) ?? AppTheme.cSurfaceBrand.color;

    final List<Widget> tags = [];
    if (details?.roleLabel != null) {
      tags.add(_buildRoleTagWidget(details?.roleLabel??'', primaryColor));
    }

    if (details?.growthIndex != null) {
      tags.add(_buildRoleTagWidget("生长 ${details?.growthIndex??''}", primaryColor));
    }

    for (final PatternBlueprintNamedInfoEntity? dep in details?.dependsOnSlots ?? []) {
      final String depName = sentenceSlotMapLocalText(dep?.name);
      if (depName.isEmpty) continue;
      tags.add(_buildRoleTagWidget("依赖 $depName", primaryColor));
    }

    final String categoryName = LearningLangUtils.getLocalLang(details?.category?.name)?.text?? '';
    final String categoryText = categoryName.isNotEmpty ? categoryName : details?.slot?.categoryNid?.trim() ?? '';
    final String categoryTagText = categoryText.isNotEmpty ? "类别 · $categoryText" : "";
    if (categoryTagText.isNotEmpty) {
      tags.add(Text(
        categoryTagText,
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextTertiary.color,
        ),
      ));
    }

    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: 12.wMin),
      child: Wrap(
        spacing: 8.wMin,
        runSpacing: 8.wMin,
        children: tags,
      ),
    );
  }

  Widget _buildContentWidget(SentenceSlotMapBlueprintDetailsEntity? details) {
    if (item.isLiteral) {
      return _buildPlaceholderWidget("固定字面量没有槽位详情。");
    }
    if (details == null) {
      return _buildPlaceholderWidget("当前槽位详情数据未准备好。");
    }
    if (details.controlledVariants.isNotEmpty) {
      return _buildControlledVariantsWidget(details.controlledVariants);
    }
    return _buildOpenSlotWidget(details);
  }

  Widget _buildControlledVariantsWidget(
    List<SentenceSlotMapControlledVariantEntity> variants,
  ) {
    final List<SentenceSlotMapControlledVariantEntity> orderedVariants = [...variants]
      ..sort((a, b) => _compareControlledVariant(a, b));

    if (orderedVariants.length == 1) {
      return _buildControlledVariantCardWidget(orderedVariants.first);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(orderedVariants.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Container(
            height: 600.wMin,
            width: 72.wMin,
            alignment: Alignment.center,
            child: _buildTagWidget(tagText: "对比"),
          );
        }
        final SentenceSlotMapControlledVariantEntity variant = orderedVariants[index ~/ 2];
        return Expanded(
          child: _buildControlledVariantCardWidget(variant),
        );
      }),
    );
  }

  Widget _buildControlledVariantCardWidget(
    SentenceSlotMapControlledVariantEntity variant,
  ) {
    final _ControlledVariantTheme theme = _resolveControlledVariantTheme(variant);
    final String title = sentenceSlotMapLocalText(variant.slot?.name);
    final String description = sentenceSlotMapLocalText(variant.slot?.description);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 600.wMin,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: theme.primaryColor.withValues(alpha: 0.12),
            border: Border.all(
              width: 0.8.wMin,
              color: theme.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                if (variant.activationFeatures?.isNotEmpty ?? false) ...[
                  SizedBox(height: 12.wMin),
                  Wrap(
                    spacing: 8.wMin,
                    runSpacing: 8.wMin,
                    children: variant.activationFeatures!
                        .map((feature) => _buildTagWidget(
                              tagText: sentenceSlotMapLocalText(feature?.name),
                              textColor: Colors.white,
                              bgColor: theme.primaryColor.withValues(alpha: 0.16),
                              borderColor: theme.accentColor.withValues(alpha: 0.32),
                            ))
                        .where((widget) => widget is! SizedBox)
                        .toList(),
                  ),
                ],
                if (description.isNotEmpty) ...[
                  SizedBox(height: 12.wMin),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                ],
                if (variant.options.isNotEmpty) ...[
                  SizedBox(height: 24.wMin),
                  Wrap(
                    spacing: 8.wMin,
                    runSpacing: 8.wMin,
                    children: variant.options.map((option) {
                      final String text =
                          sentenceSlotMapLocalText(option.label).isNotEmpty
                              ? sentenceSlotMapLocalText(option.label)
                              : (option.value ?? "");
                      return _buildOptionChipWidget(
                        text: text,
                        primaryColor: theme.primaryColor,
                        accentColor: theme.accentColor,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        Positioned(
          top: 24.wMin,
          left: -1.5.wMin,
          child: Container(
            width: 3.wMin,
            height: 32.wMin,
            decoration: BoxDecoration(
              color: theme.accentColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOpenSlotWidget(SentenceSlotMapBlueprintDetailsEntity details) {

    final String description = sentenceSlotMapLocalText(details.slot?.description);
    final String categoryTitle = sentenceSlotMapLocalText(details.category?.name);
    final String categoryDescription = sentenceSlotMapLocalText(details.category?.description);

    if (description.isEmpty && categoryDescription.isEmpty) {
      return _buildPlaceholderWidget("当前开放槽位暂无详情说明。");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: description.isNotEmpty,
          child: Text(
            description,
            style: TextStyle(
              fontSize: 22.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ),
        if (categoryDescription.isNotEmpty) ...[
          if (description.isNotEmpty) SizedBox(height: 24.wMin),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 20.wMin),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 0.8.wMin,
                  color: AppTheme.cBorderSubtle.color,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (categoryTitle.isNotEmpty)
                  Text(
                    categoryTitle,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                if (categoryTitle.isNotEmpty) SizedBox(height: 8.wMin),
                Text(
                  categoryDescription,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  int _compareControlledVariant(
    SentenceSlotMapControlledVariantEntity a,
    SentenceSlotMapControlledVariantEntity b,
  ) {
    final int toneCompare = _controlledVariantToneRank(a).compareTo(_controlledVariantToneRank(b));
    if (toneCompare != 0) {
      return toneCompare;
    }
    return (a.slotKey ?? '').compareTo(b.slotKey ?? '');
  }

  int _controlledVariantToneRank(SentenceSlotMapControlledVariantEntity variant) {
    switch (_resolveControlledVariantTone(variant)) {
      case _ControlledVariantTone.affirmative:
        return 0;
      case _ControlledVariantTone.negative:
        return 1;
      case _ControlledVariantTone.neutral:
        return 2;
    }
  }

  _ControlledVariantTheme _resolveControlledVariantTheme(
    SentenceSlotMapControlledVariantEntity variant,
  ) {
    final Color semanticColor;
    switch (_resolveControlledVariantTone(variant)) {
      case _ControlledVariantTone.affirmative:
        semanticColor = const Color(0xFF34D399);
        break;
      case _ControlledVariantTone.negative:
        semanticColor = const Color(0xFFFB7185);
        break;
      case _ControlledVariantTone.neutral:
        semanticColor = const Color(0xFFFBBF24);
        break;
    }

    final Color slotColor = ColorUtils.parseColor(variant.slot?.color) ?? semanticColor;
    return _ControlledVariantTheme(
      primaryColor: semanticColor,
      accentColor: Color.lerp(semanticColor, slotColor, 0.45) ?? semanticColor,
    );
  }

  _ControlledVariantTone _resolveControlledVariantTone(
    SentenceSlotMapControlledVariantEntity variant,
  ) {
    final List<String> featureNids = (variant.activationFeatures ?? [])
        .map((feature) => feature?.nid ?? '')
        .where((nid) => nid.isNotEmpty)
        .toList();
    if (featureNids.contains('negative') || (variant.slotKey ?? '').endsWith('_negative')) {
      return _ControlledVariantTone.negative;
    }
    if (featureNids.contains('affirmative')) {
      return _ControlledVariantTone.affirmative;
    }
    return _ControlledVariantTone.neutral;
  }

  Widget _buildPlaceholderWidget(String text) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          width: 0.8.wMin,
          color: AppTheme.cBorderThin.color,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextTertiary.color,
        ),
      ),
    );
  }

  Widget _buildRoleTagWidget(String tagText, Color primaryColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: primaryColor.withValues(alpha: 0.8),
        border: Border.all(
          width: 0.8.wMin,
          color: primaryColor,
        ),
      ),
      child: Text(
        tagText,
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOptionChipWidget({
    required String text,
    required Color primaryColor,
    Color? accentColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
        color: primaryColor.withValues(alpha: 0.12),
        border: Border.all(
          width: 0.5.wMin,
          color: (accentColor ?? primaryColor).withValues(alpha: 0.24),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextPrimary.color,
        ),
      ),
    );
  }

  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }) {
    if (tagText.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: borderColor.withValues(alpha: 0.7),
          width: 0.5.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tagText,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

}
