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
  }) async {
    return await showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return PatternSlotDetailsDialogWidget(item: item);
      },
    );
  }
}

class PatternSlotDetailsDialogWidget extends StatelessWidget {
  final SentenceSlotMapItemEntity item;

  const PatternSlotDetailsDialogWidget({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final SentenceSlotMapBlueprintDetailsEntity? details = item.details?.blueprint;
    final String title = details?.displayName??'';

    return DialogUserWidget(
      title: title,
      width: 1680.wMin,
      physics: const ClampingScrollPhysics(),
      titlePadding: EdgeInsets.only(
        left: 32.wMin,
        right: 32.wMin,
        top: 32.wMin,
        bottom: 12.wMin,
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 520.wMin,
          maxHeight: 780.wMin,
        ),
        padding: EdgeInsets.fromLTRB(32.wMin, 0, 32.wMin, 32.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(details),
            SizedBox(height: 24.wMin),
            Container(
              height: 1.wMin,
              color: AppTheme.cBorderSubtle.color,
            ),
            _buildContentTagsWidget(details),
            SizedBox(height: 24.wMin),
            Expanded(
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

  Color _resolvePrimaryColor() {
    if (item.isLiteral) {
      return AppTheme.cTextPrimary.color;
    }
    return ColorUtils.parseColor(item.color) ?? AppTheme.cSurfaceBrand.color;
  }

  Widget _buildTitleWidget(SentenceSlotMapBlueprintDetailsEntity? details) {
    final List<Widget> tags = [];
    if (details?.slot?.nid != null) {
      tags.add(
        CopyTagWidget(
          name: "槽",
          value: details?.slot?.nid??'',
        ),
      );
    }
    if (details?.patternNid != null) {
      tags.add(
        CopyTagWidget(
          name: "句型",
          value: details?.patternNid??'',
        ),
      );
    }

    final String categoryName = LearningLangUtils.getLocalLang(details?.category?.name)?.text?? '';
    final String categoryText = categoryName.isNotEmpty ? categoryName : details?.slot?.categoryNid?.trim() ?? '';
    final String categoryTagText = categoryText.isNotEmpty ? "类别 · $categoryText" : "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12.wMin,
          runSpacing: 8.wMin,
          children: tags,
        ),
        Visibility(
          visible: categoryTagText.isNotEmpty,
          child: Container(
            margin: EdgeInsets.only(top: 8.wMin),
            child: Text(
              categoryTagText,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentTagsWidget(SentenceSlotMapBlueprintDetailsEntity? details) {
    final Color primaryColor = _resolvePrimaryColor();

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

    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: 24.wMin),
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
    if (variants.length == 1) {
      return _buildControlledVariantCardWidget(variants.first);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(variants.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Container(
            width: 72.wMin,
            alignment: Alignment.center,
            child: _buildTagWidget(tagText: "对比"),
          );
        }
        final SentenceSlotMapControlledVariantEntity variant = variants[index ~/ 2];
        return Expanded(
          child: _buildControlledVariantCardWidget(variant),
        );
      }),
    );
  }

  Widget _buildControlledVariantCardWidget(
    SentenceSlotMapControlledVariantEntity variant,
  ) {
    final Color primaryColor = _resolvePrimaryColor();

    final String title = sentenceSlotMapLocalText(variant.slot?.name);
    final String description = sentenceSlotMapLocalText(variant.slot?.description);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: primaryColor.withValues(alpha: 0.12),
            border: Border.all(
              width: 0.8.wMin,
              color: primaryColor.withValues(alpha: 0.2),
            ),
          ),
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
                            textColor: primaryColor,
                            bgColor: primaryColor.withValues(alpha: 0.12),
                            borderColor: primaryColor.withValues(alpha: 0.2),
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
                    return _buildOptionChipWidget(text: text, primaryColor: primaryColor);
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          top: 24.wMin,
          left: -1.5.wMin,
          child: Container(
            width: 3.wMin,
            height: 32.wMin,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOpenSlotWidget(SentenceSlotMapBlueprintDetailsEntity details) {
    final Color primaryColor = _resolvePrimaryColor();

    final String description = sentenceSlotMapLocalText(details.slot?.description);
    final String categoryTitle = sentenceSlotMapLocalText(details.category?.name);
    final String categoryDescription = sentenceSlotMapLocalText(details.category?.description);

    if (description.isEmpty && categoryDescription.isEmpty) {
      return _buildPlaceholderWidget("当前开放槽位暂无详情说明。");
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: primaryColor.withValues(alpha: 0.12),
        border: Border.all(
          width: 0.8.wMin,
          color: primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description.isNotEmpty)
            Text(
              description,
              style: TextStyle(
                fontSize: 22.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary.color,
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
                children: [
                  if (categoryTitle.isNotEmpty)
                    Text(
                      categoryTitle,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                  if (categoryTitle.isNotEmpty) SizedBox(height: 8.wMin),
                  Text(
                    categoryDescription,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
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
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
        color: primaryColor.withValues(alpha: 0.12),
        border: Border.all(
          width: 0.5.wMin,
          color: primaryColor.withValues(alpha: 0.2),
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
