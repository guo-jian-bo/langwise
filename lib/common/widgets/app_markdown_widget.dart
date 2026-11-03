import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:markdown_widget/widget/all.dart';

import '../../theme/theme.dart';
import '../../utils/utils.dart';
import 'widgets.dart';

class AppMarkdownWidget extends StatelessWidget {
  final String data;
  final bool selectable;
  const AppMarkdownWidget({
    super.key,
    required this.data,
    this.selectable = true,
  });

  @override
  Widget build(BuildContext context) {
    final paragraphStyle = TextStyle(
      fontSize: 26.wMin,
      height: 1.8,
      letterSpacing: 0.1.wMin,
      color: AppTheme.cTextSecondary.color,
    );
    final inlineCodeStyle = TextStyle(
      fontSize: 23.wMin,
      height: 1.45,
      fontFamily: 'monospace',
      color: AppTheme.cTextPrimary.color,
      backgroundColor: AppTheme.cSurfaceLayerElevated.color,
    );

    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: MarkdownWidget(
        data: data,
        selectable: selectable,
        padding: EdgeInsets.symmetric(
          horizontal: 8.wMin,
          vertical: 6.wMin,
        ),
        shrinkWrap: true, // 使 Widget 高度随内容自适应
        physics: const NeverScrollableScrollPhysics(), // 禁止内部滚动
        config: MarkdownConfig(
          configs: [
            PConfig(
              textStyle: paragraphStyle,
            ),
            _AppHeadingConfig(
              tag: MarkdownTag.h1.name,
              style: TextStyle(
                fontSize: 48.wMin,
                height: 1.18,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w700,
              ),
              padding: EdgeInsets.only(top: 20.wMin, bottom: 14.wMin),
              divider: HeadingDivider(
                space: 12.wMin,
                color: AppTheme.cBorderPrimary.color,
                height: 1.wMin,
              ),
            ),
            _AppHeadingConfig(
              tag: MarkdownTag.h2.name,
              style: TextStyle(
                fontSize: 40.wMin,
                height: 1.24,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
              padding: EdgeInsets.only(top: 18.wMin, bottom: 12.wMin),
              divider: HeadingDivider(
                space: 10.wMin,
                color: AppTheme.cBorderSecondary.color,
                height: 1.wMin,
              ),
            ),
            _AppHeadingConfig(
              tag: MarkdownTag.h3.name,
              style: TextStyle(
                fontSize: 34.wMin,
                height: 1.3,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
              padding: EdgeInsets.only(top: 16.wMin, bottom: 10.wMin),
              divider: HeadingDivider(
                space: 8.wMin,
                color: AppTheme.cBorderSubtle.color,
                height: 1.wMin,
              ),
            ),
            _AppHeadingConfig(
              tag: MarkdownTag.h4.name,
              style: TextStyle(
                fontSize: 30.wMin,
                height: 1.35,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
              padding: EdgeInsets.only(top: 14.wMin, bottom: 8.wMin),
            ),
            _AppHeadingConfig(
              tag: MarkdownTag.h5.name,
              style: TextStyle(
                fontSize: 28.wMin,
                height: 1.35,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
              padding: EdgeInsets.only(top: 12.wMin, bottom: 6.wMin),
            ),
            _AppHeadingConfig(
              tag: MarkdownTag.h6.name,
              style: TextStyle(
                fontSize: 24.wMin,
                height: 1.35,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w600,
              ),
              padding: EdgeInsets.only(top: 12.wMin, bottom: 6.wMin),
            ),
            LinkConfig(
              style: TextStyle(
                fontSize: 26.wMin,
                height: 1.8,
                color: AppTheme.cTextLink.color,
                decoration: TextDecoration.underline,
                decorationColor:
                    AppTheme.cTextLink.color.withValues(alpha: 0.72),
                decorationThickness: 1.wMin,
              ),
              onTap: (value){
                BotToast.cleanAll();
                WebViewUtils.openWebView(url: value);
              },
            ),
            HrConfig(
              height: 1.wMin,
              color: AppTheme.cBorderPrimary.color.withValues(alpha: 0.55),
            ),
            ListConfig(
              marginLeft: 40.wMin,
              marginBottom: 12.wMin,
              marker: (isOrdered, depth, index) {
                if (isOrdered) {
                  return Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.wMin),
                      child: Text(
                        '${index + 1}.',
                        style: TextStyle(
                          fontSize: 24.wMin,
                          height: 1.8,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextTertiary.color,
                        ),
                      ),
                    ),
                  );
                }

                final markerSize = depth == 0 ? 10.wMin : 8.wMin;
                final markerColor = depth == 0
                    ? AppTheme.cTextSecondary.color
                    : AppTheme.cTextTertiary.color;

                return Padding(
                  padding: EdgeInsets.only(top: 18.wMin),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: markerSize,
                      height: markerSize,
                      decoration: BoxDecoration(
                        color: depth == 1
                            ? AppTheme.cStaticTransparent.color
                            : markerColor,
                        borderRadius: BorderRadius.circular(
                          depth == 2 ? 2.wMin : markerSize,
                        ),
                        border: Border.all(
                          color: markerColor,
                          width: 1.wMin,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            TableConfig(
              border: TableBorder.all(
                color: AppTheme.cBorderSecondary.color,
                width: 1.wMin,
              ),
              defaultColumnWidth: const FlexColumnWidth(),
              headerRowDecoration: BoxDecoration(
                color: AppTheme.cSurfaceSecondary.color,
              ),
              bodyRowDecoration: BoxDecoration(
                color: AppTheme.cSurfacePrimary.color,
              ),
              headPadding: EdgeInsets.symmetric(
                horizontal: 16.wMin,
                vertical: 12.wMin,
              ),
              bodyPadding: EdgeInsets.symmetric(
                horizontal: 16.wMin,
                vertical: 12.wMin,
              ),
              headerStyle: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: AppTheme.cTextPrimary.color,
              ),
              bodyStyle: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                height: 1.7,
                color: AppTheme.cTextSecondary.color,
              ),
              wrapper: (child) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 14.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfacePrimary.color,
                    border: Border.all(
                      color: AppTheme.cBorderSecondary.color,
                      width: 1.wMin,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppTheme.cShadowLight.color.withValues(alpha: 0.08),
                        blurRadius: 16.wMin,
                        offset: Offset(0, 4.wMin),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: LayoutBuilder(
                    builder: (context, constraints) => ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                        maxWidth: constraints.maxWidth,
                      ),
                      child: child,
                    ),
                  ),
                );
              },
            ),
            BlockquoteConfig(
              sideColor: AppTheme.cBorderBrand.color,
              textColor: AppTheme.cTextSecondary.color,
              sideWith: 4.wMin,
              margin: EdgeInsets.symmetric(vertical: 10.wMin),
              padding: EdgeInsets.symmetric(
                horizontal: 18.wMin,
                vertical: 10.wMin,
              ),
            ),
            CodeConfig(
              style: inlineCodeStyle,
            ),
            PreConfig(
              padding: EdgeInsets.fromLTRB(
                18.wMin,
                16.wMin,
                18.wMin,
                18.wMin,
              ),
              margin: EdgeInsets.symmetric(vertical: 14.wMin),
              decoration: BoxDecoration(
                color: AppTheme.cSurfaceLayerDarken.color,
                borderRadius: BorderRadius.circular(14.wMin),
                border: Border.all(
                  color: AppTheme.cBorderDark.color,
                  width: 1.wMin,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.cShadowLight.color.withValues(alpha: 0.1),
                    blurRadius: 20.wMin,
                    offset: Offset(0, 6.wMin),
                  ),
                ],
              ),
              textStyle: TextStyle(
                fontSize: 23.wMin,
                height: 1.6,
                color: AppTheme.cTextPrimary.color,
                fontFamily: 'monospace',
              ),
              styleNotMatched: TextStyle(
                fontSize: 23.wMin,
                height: 1.6,
                color: AppTheme.cTextPrimary.color,
                fontFamily: 'monospace',
              ),
              theme: _codeTheme,
              wrapper: _buildCodeBlock,
            ),
            ImgConfig(
              builder: _buildImage,
            ),
            CheckBoxConfig(
              builder: (checked) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: 8.wMin,
                    right: 6.wMin,
                  ),
                  child: Container(
                    width: 28.wMin,
                    height: 28.wMin,
                    decoration: BoxDecoration(
                      color: checked
                          ? AppTheme.cTextBrand.color
                          : AppTheme.cStaticTransparent.color,
                      borderRadius: BorderRadius.circular(8.wMin),
                      border: Border.all(
                        color: checked
                            ? AppTheme.cTextBrand.color
                            : AppTheme.cBorderDefault.color,
                        width: 1.wMin,
                      ),
                    ),
                    child: checked
                        ? Icon(
                            Icons.check_rounded,
                            size: 18.wMin,
                            color: AppTheme.cStaticWhite.color,
                          )
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static final Map<String, TextStyle> _codeTheme = {
    'root': TextStyle(color: AppTheme.cTextPrimary.color),
    'subst': TextStyle(color: AppTheme.cTextPrimary.color),
    'comment': TextStyle(
      color: AppTheme.cTextTertiary.color,
      fontStyle: FontStyle.italic,
    ),
    'quote': TextStyle(
      color: AppTheme.cTextTertiary.color,
      fontStyle: FontStyle.italic,
    ),
    'keyword': TextStyle(color: AppTheme.cFeedbackInfoText.color),
    'selector-tag': TextStyle(color: AppTheme.cFeedbackInfoText.color),
    'built_in': TextStyle(color: AppTheme.cFeedbackInfoText.color),
    'type': TextStyle(color: AppTheme.cFeedbackInfoText.color),
    'literal': TextStyle(color: AppTheme.cFeedbackWarningText.color),
    'number': TextStyle(color: AppTheme.cFeedbackWarningText.color),
    'attr': TextStyle(color: AppTheme.cFeedbackWarningText.color),
    'attribute': TextStyle(color: AppTheme.cFeedbackWarningText.color),
    'string': TextStyle(color: AppTheme.cFeedbackSuccessText.color),
    'regexp': TextStyle(color: AppTheme.cFeedbackSuccessText.color),
    'title': TextStyle(color: AppTheme.cTextBrand.color),
    'section': TextStyle(color: AppTheme.cTextBrand.color),
    'symbol': TextStyle(color: AppTheme.cTextBrand.color),
    'bullet': TextStyle(color: AppTheme.cFeedbackDefaultText.color),
    'meta': TextStyle(color: AppTheme.cTextQuaternary.color),
    'meta-keyword': TextStyle(color: AppTheme.cTextQuaternary.color),
    'params': TextStyle(color: AppTheme.cTextSecondary.color),
    'variable': TextStyle(color: AppTheme.cTextPrimary.color),
    'operator': TextStyle(color: AppTheme.cTextPrimary.color),
    'emphasis': const TextStyle(fontStyle: FontStyle.italic),
    'strong': const TextStyle(fontWeight: FontWeight.w700),
  };

  static Widget _buildCodeBlock(Widget child, String code, String language) {
    final normalizedLanguage =
        language.trim().isEmpty ? 'plain text' : language;

    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 12.wMin),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.wMin,
                      vertical: 5.wMin,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfaceLayerElevated.color,
                      borderRadius: BorderRadius.circular(999.wMin),
                      border: Border.all(
                        color: AppTheme.cBorderSubtle.color,
                        width: 1.wMin,
                      ),
                    ),
                    child: Text(
                      normalizedLanguage,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cTextTertiary.color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TapScaleWidget(
                    sclae: 1.01,
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: code));
                      if (!context.mounted) return;
                      ToastUtils.showToast(
                          text: "复制成功", type: ToastType.success);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.wMin,
                        vertical: 8.wMin,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cSurfaceLayerElevated.color,
                        borderRadius: BorderRadius.circular(10.wMin),
                        border: Border.all(
                          color: AppTheme.cBorderSubtle.color,
                          width: 1.wMin,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.content_copy_rounded,
                            size: 18.wMin,
                            color: AppTheme.cTextTertiary.color,
                          ),
                          SizedBox(width: 6.wMin),
                          Text(
                            'Copy',
                            style: TextStyle(
                              fontSize: 20.wMin,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextTertiary.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            child,
          ],
        );
      },
    );
  }

  static Widget _buildImage(String url, Map<String, String> attributes) {
    final width = _parseImageDimension(attributes['width']);
    final height = _parseImageDimension(attributes['height']);
    final alt = attributes['alt'] ?? '';
    final image = url.startsWith('http')
        ? CachedImageWidget(
            url,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorWidget: _buildBrokenImage(alt),
          )
        : Image.asset(
            url,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildBrokenImage(alt),
          );

    return Builder(
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.wMin),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(
                color: AppTheme.cBorderSecondary.color,
                width: 1.wMin,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cShadowLight.color.withValues(alpha: 0.08),
                  blurRadius: 20.wMin,
                  offset: Offset(0, 6.wMin),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                image,
                // if (alt.isNotEmpty)
                //   Container(
                //     padding: EdgeInsets.symmetric(
                //       horizontal: 14.wMin,
                //       vertical: 10.wMin,
                //     ),
                //     color: AppTheme.cSurfacePrimary.color,
                //     child: Text(
                //       alt,
                //       style: TextStyle(
                //         fontSize: 22.wMin,
                //         height: 1.5,
                //         color: AppTheme.cTextTertiary.color,
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildBrokenImage(String alt) {
    return Container(
      width: 240.wMin,
      height: 160.wMin,
      alignment: Alignment.center,
      color: AppTheme.cSurfaceSecondary.color,
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 36.wMin,
            color: AppTheme.cFeedbackErrorIcon.color,
          ),
          SizedBox(height: 8.wMin),
          Text(
            alt.isEmpty ? 'Image load failed' : alt,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.wMin,
              height: 1.5,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ],
      ),
    );
  }

  static double? _parseImageDimension(String? rawValue) {
    final value = double.tryParse(rawValue ?? '');
    if (value == null || value <= 0) {
      return null;
    }
    return value.wMin;
  }
}

class _AppHeadingConfig extends HeadingConfig {
  @override
  final String tag;

  @override
  final TextStyle style;

  final EdgeInsets _padding;
  final HeadingDivider? _divider;

  const _AppHeadingConfig({
    required this.tag,
    required this.style,
    required EdgeInsets padding,
    HeadingDivider? divider,
  })  : _padding = padding,
        _divider = divider;

  @override
  EdgeInsets get padding => _padding;

  @override
  HeadingDivider? get divider => _divider;
}
