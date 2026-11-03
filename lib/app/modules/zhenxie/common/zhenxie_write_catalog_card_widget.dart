import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../management/common/commons.dart';

class ZhenxieWriteCatalogCardWidget extends StatelessWidget {
  final double height;
  final String coverUrl;
  final String difficultyLabel;
  final String blueprintLabel;
  final String title;
  final String titleEn;
  final String entityLabel;
  final String entityValue;
  final String genreLabel;
  final Color genreColor;
  final String description;
  final Widget slotStrip;
  final Widget? coverOverlay;
  final Widget? actions;
  final VoidCallback? onTap;
  final bool showCopyTag;

  const ZhenxieWriteCatalogCardWidget({
    super.key,
    required this.height,
    required this.coverUrl,
    required this.difficultyLabel,
    required this.blueprintLabel,
    required this.title,
    required this.titleEn,
    required this.entityLabel,
    required this.entityValue,
    required this.genreLabel,
    required this.genreColor,
    required this.description,
    required this.slotStrip,
    this.coverOverlay,
    this.actions,
    this.onTap,
    this.showCopyTag = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCoverOverlay = coverOverlay != null;
    final Widget card = Container(
      height: height.wMin,
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase,
        borderRadius: BorderRadius.circular(28.wMin),
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 220.wMin,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(16.wMin)),
                      child: SizedBox(
                        width: double.infinity,
                        height: 220.wMin,
                        child: CachedImageWidget(
                          coverUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorWidget: buildEmptyWidget(fit: BoxFit.cover),
                          placeholder: buildEmptyWidget(fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    if (coverOverlay != null) Positioned.fill(child: coverOverlay!),
                    Positioned(
                      left: 8.wMin,
                      top: hasCoverOverlay ? null : 8.wMin,
                      bottom: hasCoverOverlay ? 8.wMin : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (difficultyLabel.isNotEmpty) _buildModuleCoverTextTag(difficultyLabel),
                          if (difficultyLabel.isNotEmpty && blueprintLabel.isNotEmpty) SizedBox(height: 4.wMin),
                          if (blueprintLabel.isNotEmpty) _buildModuleCoverTextTag(blueprintLabel),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.wMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      title,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFontValue.sourceHanSerifCN,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                    if (titleEn.isNotEmpty) SizedBox(height: 6.wMin),
                    if (titleEn.isNotEmpty)
                      AutoSizeText(
                        titleEn,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppFontValue.robotoMono,
                          color: AppTheme.cTextSecondary.color,
                        ),
                      ),
                    SizedBox(height: 6.wMin),
                    CopyTagWidget(
                      name: entityLabel,
                      value: entityValue,
                      isShow: showCopyTag,
                    ),
                    if (description.isNotEmpty) SizedBox(height: 6.wMin),
                    if (description.isNotEmpty)
                      AutoSizeText(
                        description,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextSecondary.color,
                        ),
                      ),
                    if (genreLabel.isNotEmpty) SizedBox(height: 6.wMin),
                    if (genreLabel.isNotEmpty)
                      WordInflectionInfoTagWidget(
                        genreLabel,
                        textColor: genreColor,
                        bgColor: genreColor.withValues(alpha: 0.12),
                        borderColor: genreColor.withValues(alpha: 0.20),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.wMin),
          slotStrip,
          if (actions != null) SizedBox(height: 16.wMin),
          if (actions != null) actions!,
        ],
      ),
    );
    if (onTap == null) {
      return card;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }

  Widget _buildModuleCoverTextTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 6.wMin),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6.wMin),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.wMin,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.wMin,
          color: AppTheme.cStaticWhite.color,
          fontWeight: FontWeight.w500,
          height: 1.0,
        ),
      ),
    );
  }
}
