import 'package:bot_toast/bot_toast.dart';
import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/theme/theme_utils.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

Color _themeTextSecondary([double alpha = 1]) =>
    AppTheme.cTextSecondary.color.withValues(alpha: alpha);
Color _themeTextTertiary([double alpha = 1]) =>
    AppTheme.cTextTertiary.color.withValues(alpha: alpha);
Color _themeBorderPrimary([double alpha = 1]) =>
    AppTheme.cBorderPrimary.color.withValues(alpha: alpha);
Color _themeBorderSecondary([double alpha = 1]) =>
    AppTheme.cBorderSecondary.color.withValues(alpha: alpha);
Color _themeSurfacePrimary([double alpha = 1]) =>
    AppTheme.cSurfacePrimary.color.withValues(alpha: alpha);
Color _themeSurfaceSecondary([double alpha = 1]) =>
    AppTheme.cSurfaceSecondary.color.withValues(alpha: alpha);
Color _themeSurfaceTertiary([double alpha = 1]) =>
    AppTheme.cSurfaceTertiary.color.withValues(alpha: alpha);
Color _staticWhite([double alpha = 1]) =>
    AppTheme.cStaticWhite.color.withValues(alpha: alpha);
Color _staticBlack([double alpha = 1]) =>
    AppTheme.cStaticBlack.color.withValues(alpha: alpha);

class ZhenduScriptCardWidget extends StatelessWidget {
  final ZhenduScriptEntity item;
  final VoidCallback onTap;
  final String coverUrl;
  final String? thumbUrl;
  final String? theaterCategory;

  const ZhenduScriptCardWidget({
    super.key,
    required this.item,
    required this.onTap,
    required this.coverUrl,
    this.thumbUrl,
    this.theaterCategory,
  });

  bool get _isSemantic {
    final sourceType = (item.source?.type ?? '').trim().toUpperCase();
    if (sourceType == 'SEMANTIC') return true;
    return (theaterCategory ?? '').trim().toLowerCase() == 'semantic';
  }

  String get _resolvedCategory {
    final category = (theaterCategory ?? '').trim().toLowerCase();
    if (category.isNotEmpty) return category;
    if (_isSemantic) return 'semantic';
    return 'context';
  }

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.01,
      child: Container(
        padding: EdgeInsets.all(10.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.wMin),
          border: Border.all(color: _themeBorderPrimary(0.92)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _themeSurfaceSecondary(0.96),
              _themeSurfacePrimary(0.98),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCover(),
            SizedBox(height: 12.wMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildInfo()),
                      SizedBox(width: 10.wMin),
                      _buildThumb(),
                    ],
                  ),
                  SizedBox(height: 12.wMin),
                  _buildSourceLine(),
                  SizedBox(height: 12.wMin),
                  Wrap(
                    spacing: 8.wMin,
                    runSpacing: 8.wMin,
                    children: _buildTagChips(),
                  ),
                  const Spacer(),
                  _buildSceneDurationRow(),
                ],
              ),
            ),
            SizedBox(height: 12.wMin),
            Container(
              padding: EdgeInsets.only(top: 10.wMin, left: 2.wMin, right: 2.wMin),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: _themeBorderPrimary(0.90))),
              ),
              child: Row(
                children: [
                  Text(
                    _isSemantic ? 'ENTER SCENE' : 'NOW SHOWING',
                    style: TextStyle(
                      fontSize: 16.wMin,
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w600,
                      color: _themeTextTertiary(0.86),
                    ),
                  ),
                  const Spacer(),
                  AccessActionButtonWidget(
                    showIcon: true,
                    text: item.cardRights?.rights == 'NO_RIGHTS' ? '去解锁' : '进入剧场',
                    isUnlocked: item.cardRights?.rights != 'NO_RIGHTS',
                    onTap: onTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.wMin),
      child: SizedBox(
        height: 300.wMin,
        child: Stack(
          children: [
            Positioned.fill(
              child: coverUrl.isEmpty
                  ? Container(color: AppTheme.cBgTertiary.color)
                  : CachedImageWidget(
                      coverUrl,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration.zero,
                      placeholder: buildLoadingWidget(fit: BoxFit.cover),
                      errorWidget: buildNetworkWidget(fit: BoxFit.cover),
                    ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  widthFactor: 0.64,
                  heightFactor: 0.42,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topCenter,
                        radius: 1.0,
                        colors: [
                          const Color(0xFFFFF8DC).withValues(alpha: 0.16),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.72],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              start: 12.wMin,
              top: 8.wMin,
              child: _buildLocateStyleDialectBadge(),
            ),
            Positioned(
              right: 10.wMin,
              top: 10.wMin,
              child: StatusTagDifficultyWidget(
                isIcon: true,
                defaultColor: _staticBlack(0.28),
                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 5.wMin),
                borderRadius: 4.wMin,
                fontSize: 16.wMin,
                difficulty: item.difficulty?.min,
                language: Get.find<ConfigController>().userSetting.value.learningLang,
              ),
            ),
            Positioned(
              right: 10.wMin,
              bottom: 10.wMin,
              child: VideoImageInnerButtonWidget(
                leadingIcon: Icons.schedule,
                text: _getDurationLabel(),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      _staticWhite(0.32),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocateStyleDialectBadge() {
    final parts = <String>[
      _pickLocaleText(item.locateTitle),
      _pickLocaleText(item.styleTitle),
      _pickLocaleText(item.dialectTitle),
    ].where((e) => e.trim().isNotEmpty).toList();
    if (parts.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8.wMin,
      runSpacing: 4.wMin,
      children: parts.map((title) => VideoImageInnerButtonWidget(text: title)).toList(),
    );
  }

  Widget _buildInfo() {
    final sceneCount = item.sceneCount ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (item.isRead == true) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 6.wMin),
                decoration: BoxDecoration(
                  color: AppTheme.cSurfaceSuccess,
                  borderRadius: BorderRadius.circular(6.wMin),
                ),
                child: Text(
                  '已看',
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
              SizedBox(width: 10.wMin),
            ],
            Flexible(
              child: _OverflowBubbleText(
                text: _isSemantic ? 'PLAYBILL' : 'FEATURED SHOW',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 18.wMin,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w600,
                  color: _themeTextTertiary(0.86),
                ),
              ),
            ),
            SizedBox(width: 6.wMin),
            Container(
              width: 5.wMin,
              height: 5.wMin,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _themeTextTertiary(0.58),
              ),
            ),
            SizedBox(width: 6.wMin),
            _OverflowBubbleText(
              text: '$sceneCount 幕',
              maxLines: 1,
              style: TextStyle(
                fontSize: 18.wMin,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w600,
                color: _themeTextTertiary(0.86),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.wMin),
        _OverflowBubbleText(
          text: _getDisplayTitle(),
          maxLines: 1,
          style: TextStyle(
            fontSize: 26.wMin,
            fontWeight: FontWeight.w700,
            color: AppTheme.cTextPrimary.color,
            height: 1.05,
          ),
        ),
        SizedBox(height: 14.wMin),
        _OverflowBubbleText(
          text: _getDisplaySubtitle(),
          maxLines: 1,
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: _themeTextSecondary(0.90),
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildSourceLine() {
    final baseStyle = TextStyle(
      fontSize: 20.wMin,
      height: 1.45,
      color: _themeTextTertiary(0.86),
    );

    if (!_isSemantic) {
      return _OverflowBubbleText(
        text: _getSourceLine(),
        maxLines: 2,
        style: baseStyle,
      );
    }

    final content = _getSemanticContent();
    final pronunciations = _parseSemanticPronunciations();
    final translate = _getSemanticTranslate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _OverflowBubbleText(
              text: content,
              maxLines: 1,
              style: baseStyle.copyWith(
                fontSize: 24.wMin,
                color: _themeTextSecondary(0.96),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 10.wMin),
            Expanded(
              child: pronunciations.isEmpty
                  ? _OverflowBubbleText(
                      text: _getSemanticPronunciations(),
                      maxLines: 1,
                      style: baseStyle.copyWith(
                        fontSize: 20.wMin,
                        color: _themeTextSecondary(0.8),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _buildPronunciationWidgets(pronunciations),
                      ),
                    ),
            ),
          ],
        ),
        SizedBox(height: 4.wMin),
        _OverflowBubbleText(
          text: translate,
          maxLines: 1,
          style: baseStyle.copyWith(
            fontSize: 20.wMin,
            color: _themeTextSecondary(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSceneDurationRow() {
    final sceneCount = item.sceneCount ?? 0;
    final style = TextStyle(
      fontSize: 18.wMin,
      color: _themeTextSecondary(0.82),
    );
    return Row(
      children: [
        SvgPicture.asset(
          'assets/svg/public/Storyboard.svg',
          width: 18.wMin,
          colorFilter: ColorFilter.mode(
            AppTheme.cTextTertiary.color,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: 6.wMin),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 140.wMin),
          child: _OverflowBubbleText(
            text: '$sceneCount 幕分镜',
            maxLines: 1,
            style: style,
          ),
        ),
        SizedBox(width: 10.wMin),
        Container(
          width: 3.wMin,
          height: 3.wMin,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _themeTextTertiary(0.58),
          ),
        ),
        SizedBox(width: 10.wMin),
        Flexible(
          child: _OverflowBubbleText(
            text: _getDurationLabel(),
            maxLines: 1,
            style: style,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTagChips() {
    final tags = item.tags;
    if (tags == null || tags.isEmpty) {
      return <Widget>[
        _infoChip(_getThemeLabel()),
        _infoChip(_getGenreLabel()),
      ];
    }

    return tags.map((tag) {
      final text = _getTagText(tag);
      final style = _pickThemeStyle(tag.style);
      return _infoChip(
        text,
        textColor: ColorUtils.parseColor(style?.color),
        bgColor: ColorUtils.parseColor(style?.backgroundColor),
        borderColor: ColorUtils.parseColor(style?.borderColor),
      );
    }).toList();
  }

  Widget _buildThumb() {
    final category = _resolvedCategory;
    final imageUrls = _readImageUrls();
    final resolvedThumbUrl = (thumbUrl ?? '').trim().isNotEmpty
        ? thumbUrl!.trim()
        : (coverUrl.isNotEmpty ? coverUrl : (imageUrls.isNotEmpty ? imageUrls.first : ''));
    if (category == 'semantic') {
      final urls = imageUrls.isNotEmpty
          ? imageUrls
          : (resolvedThumbUrl.isNotEmpty ? <String>[resolvedThumbUrl] : const <String>[]);
      final count = urls.length;
      return SizedBox(
        width: 132.wMin,
        height: 106.wMin,
        child: Stack(
          children: [
            for (var index = 0; index < count; index++)
              Positioned(
                left: () {
                  final center = (count - 1) / 2;
                  final rawOffset = (index - center) * 7.wMin;
                  final offsetX = rawOffset.clamp(-20.wMin, 20.wMin);
                  return 24.wMin + offsetX;
                }(),
                top: 0,
                child: Transform.rotate(
                  angle: () {
                    final center = (count - 1) / 2;
                    final rawRotation = (index - center) * 8.0;
                    final rotationDeg = rawRotation.clamp(-24.0, 24.0);
                    return rotationDeg * 3.1415926 / 180;
                  }(),
                  child: Container(
                    width: 90.wMin,
                    height: 90.wMin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.wMin),
                      border: Border.all(color: _themeBorderSecondary(0.95)),
                      boxShadow: [
                        BoxShadow(
                          color: _staticBlack(0.28),
                          blurRadius: 35,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: urls.isEmpty
                        ? Container(color: AppTheme.cBgTertiary.color)
                        : CachedImageWidget(
                            urls[index],
                            fit: BoxFit.cover,
                            fadeInDuration: Duration.zero,
                            placeholder: buildLoadingWidget(fit: BoxFit.cover),
                            errorWidget: buildNetworkWidget(fit: BoxFit.cover),
                          ),
                  ),
                ),
              ),
            if (count > 1)
              Positioned(
                left: 22.wMin,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999.wMin),
                    border: Border.all(
                      color: AppTheme.cReadPrimary.color.withValues(alpha: 0.30),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.cReadBg1.color.withValues(alpha: 0.48),
                        AppTheme.cReadBg2.color.withValues(alpha: 0.34),
                      ],
                    ),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 12.wMin,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (category == 'picture_book') {
      return Container(
        width: 104.wMin,
        height: 104.wMin,
        padding: EdgeInsets.all(3.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.wMin),
          border: Border.all(color: _themeBorderPrimary(0.90)),
          color: _themeSurfaceTertiary(0.90),
        ),
        child: resolvedThumbUrl.isEmpty
            ? const SizedBox.shrink()
            : CachedImageWidget(
                resolvedThumbUrl,
                fit: BoxFit.contain,
                fadeInDuration: Duration.zero,
                placeholder: buildLoadingWidget(fit: BoxFit.cover),
                errorWidget: buildNetworkWidget(fit: BoxFit.cover),
              ),
      );
    }

    return Container(
      width: 104.wMin,
      height: 104.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.wMin),
        border: Border.all(color: _themeBorderPrimary(0.90)),
      ),
      clipBehavior: Clip.antiAlias,
      child: resolvedThumbUrl.isEmpty
          ? Container(color: AppTheme.cBgTertiary.color)
          : CachedImageWidget(
              resolvedThumbUrl,
              fit: BoxFit.cover,
              fadeInDuration: Duration.zero,
              placeholder: buildLoadingWidget(fit: BoxFit.cover),
              errorWidget: buildNetworkWidget(fit: BoxFit.cover),
            ),
    );
  }

  List<String> _readImageUrls() {
    final raw = item.source?.data?['imageUrls'];
    if (raw is! List) return const <String>[];
    return raw
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _getDisplayTitle() {
    final learning = LearningLangUtils.getLearningLang(item.title)?.text;
    if (learning != null && learning.trim().isNotEmpty) return learning.trim();
    final local = LearningLangUtils.getLocalLang(item.title)?.text;
    if (local != null && local.trim().isNotEmpty) return local.trim();
    return '';
  }

  String _getDisplaySubtitle() {
    final local = LearningLangUtils.getLocalLang(item.title)?.text;
    final learning = LearningLangUtils.getLearningLang(item.title)?.text;
    if (local != null &&
        local.trim().isNotEmpty &&
        local.trim() != learning?.trim()) {
      return local.trim();
    }
    final semanticContent = _getSemanticContent();
    if (semanticContent.isNotEmpty) return semanticContent;
    return item.source?.name?.trim() ?? '';
  }

  String _getSourceLine() {
    final semanticContent = _getSemanticContent();
    if (semanticContent.isNotEmpty) return semanticContent;
    final source = item.source?.name?.trim() ?? '';
    if (source.isNotEmpty) return source;
    return 'LangWise Official Course';
  }

  String _getSemanticContent() {
    final content = item.source?.data?['content']?.toString().trim() ?? '';
    if (content.isNotEmpty) return content;
    return item.source?.name?.trim() ?? '';
  }

  String _getSemanticPronunciations() {
    return _normalizeSourceValue(item.source?.data?['pronunciations']);
  }

  String _getSemanticTranslate() {
    return _normalizeSourceValue(item.source?.data?['translate']);
  }

  String _normalizeSourceValue(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is List) {
      final parts = value
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      return parts.join(' / ');
    }
    if (value is Map<String, dynamic>) {
      final parts = value.values
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      return parts.join(' / ');
    }
    return value.toString().trim();
  }

  String _getDurationLabel() {
    final seconds = _durationWeight();
    final minutes = seconds ~/ 60;
    final remain = seconds % 60;
    return '$minutes:${remain.toString().padLeft(2, '0')}';
  }

  int _durationWeight() {
    if (item.duration != null && item.duration! > 0) {
      return item.duration!.round();
    }
    final sceneCount = item.sceneCount ?? 1;
    return sceneCount * 35;
  }

  String _getThemeLabel() {
    return _pickTagText(0, fallback: '课堂主题');
  }

  String _getGenreLabel() {
    return _pickTagText(1, fallback: _isSemantic ? '语义演绎' : '剧情故事');
  }

  String _pickTagText(int index, {required String fallback}) {
    final tags = item.tags;
    if (tags == null || tags.length <= index) return fallback;
    return _getTagText(tags[index]);
  }

  String _getTagText(ZhenduTagEntity tag) {
    final local = LearningLangUtils.getLocalLang(tag.gloss)?.text;
    if (local != null && local.trim().isNotEmpty) return local.trim();
    final learning = LearningLangUtils.getLearningLang(tag.gloss)?.text;
    if (learning != null && learning.trim().isNotEmpty) return learning.trim();
    return '';
  }

  ThemeTextStyleEntity? _pickThemeStyle(List<ThemeTextStyleEntity>? styles) {
    if (styles == null || styles.isEmpty) return null;
    for (final style in styles) {
      final theme = (style.theme ?? '').trim();
      if (theme.isEmpty) continue;
      if (ThemeUtils.isCurrentTheme(theme)) return style;
    }
    return styles.first;
  }

  Widget _infoChip(
    String text, {
    Color? textColor,
    Color? bgColor,
    Color? borderColor,
  }) {
    final resolvedTextColor = textColor ?? AppTheme.cTextPrimary.color;
    final resolvedBgColor =
        bgColor ?? AppTheme.cSurfaceSecondary.color.withValues(alpha: 0.35);
    final resolvedBorderColor =
        borderColor ?? resolvedTextColor.withValues(alpha: 0.14);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        border: Border.all(color: resolvedBorderColor),
        color: resolvedBgColor,
      ),
      child: _OverflowBubbleText(
        text: text,
        maxLines: 1,
        style: TextStyle(
          fontSize: 20.wMin,
          color: resolvedTextColor,
        ),
      ),
    );
  }

  String _pickLocaleText(List<LanguageText>? list) {
    if (list == null || list.isEmpty) return '';
    String? chineseText;
    for (final item in list) {
      final code = (item.lang ?? '').trim().toLowerCase();
      final text = (item.text ?? '').trim();
      if (text.isEmpty) continue;
      if (code == 'zh') return text;
      if (chineseText == null &&
          (code.startsWith('zh-') || code.startsWith('zh_'))) {
        chineseText = text;
      }
    }
    if (chineseText != null) return chineseText;
    for (final item in list) {
      final text = (item.text ?? '').trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  List<_SemanticPronunciationData> _parseSemanticPronunciations() {
    final raw = item.source?.data?['pronunciations'];
    if (raw is! List) return const [];
    final resp = <_SemanticPronunciationData>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final ipaTags = _parseSemanticIpaTags(e['ipa']);
      if (ipaTags.isEmpty) continue;
      final posRaw = e['pos'];
      final posList = <String>[];
      if (posRaw is List) {
        for (final p in posRaw) {
          final text = _normalizePosText(p?.toString());
          if (text.isNotEmpty) posList.add(text);
        }
      } else if (posRaw != null) {
        final text = _normalizePosText(posRaw.toString());
        if (text.isNotEmpty) posList.add(text);
      }
      resp.add(_SemanticPronunciationData(
        ipaTags: ipaTags,
        posTags: posList,
      ));
    }
    return resp;
  }

  List<Widget> _buildPronunciationWidgets(List<_SemanticPronunciationData> items) {
    final widgets = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      if (i > 0) {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.wMin),
            child: Container(
              width: 4.wMin,
              height: 4.wMin,
              decoration: BoxDecoration(
                color: _themeTextTertiary(0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }
      widgets.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(items[i].ipaTags.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == items[i].ipaTags.length - 1 ? 0 : 8.wMin,
                  ),
                  child: Text(
                    items[i].ipaTags[index],
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: _themeTextSecondary(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }),
            ),
            if (items[i].posTags.isNotEmpty) ...[
              SizedBox(width: 10.wMin),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(items[i].posTags.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == items[i].posTags.length - 1 ? 0 : 8.wMin,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin),
                        border: Border.all(color: _themeBorderPrimary(0.9)),
                        color: _themeSurfaceSecondary(0.75),
                      ),
                      child: Text(
                        items[i].posTags[index],
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: _themeTextSecondary(0.95),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      );
    }
    return widgets;
  }

  String _normalizePosText(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return '';
    return text.replaceAll(RegExp(r'^/+|/+$'), '');
  }

  List<String> _parseSemanticIpaTags(dynamic value) {
    final resp = <String>[];

    void addValue(dynamic item) {
      if (item == null) return;
      if (item is List) {
        for (final sub in item) {
          addValue(sub);
        }
        return;
      }
      var text = item.toString().trim();
      if (text.isEmpty) return;
      if (text.startsWith('[') && text.endsWith(']')) {
        text = text.substring(1, text.length - 1).trim();
      }
      final parts = text
          .split(RegExp(r'\s+/\s+|[,;|、，；]+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);
      for (final part in parts) {
        final normalized = _normalizePosText(part);
        if (normalized.isEmpty) continue;
        resp.add('/$normalized/');
      }
    }

    addValue(value);
    return resp;
  }
}

class _OverflowBubbleText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLines;

  const _OverflowBubbleText({
    required this.text,
    required this.style,
    this.maxLines = 1,
  });

  @override
  State<_OverflowBubbleText> createState() => _OverflowBubbleTextState();
}

class _OverflowBubbleTextState extends State<_OverflowBubbleText> {
  final GlobalKey _anchorKey = GlobalKey();
  CancelFunc? _cancel;

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  void _show() {
    if (_cancel != null) return;
    final ctx = _anchorKey.currentContext;
    if (ctx == null) return;
    _cancel = BotToast.showAttachedWidget(
      targetContext: ctx,
      backgroundColor: Colors.transparent,
      onlyOne: true,
      preferDirection: PreferDirection.topCenter,
      attachedBuilder: (cancelFunc) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: cancelFunc,
          child: Container(
            constraints: BoxConstraints(
              minWidth: 200.wMin,
              maxWidth: 520.wMin,
            ),
            child: BubbleBox(
              backgroundColor: AppTheme.cSurfaceSecondary.color,
              padding: EdgeInsets.all(12.wMin),
              shape: BubbleShapeBorder(
                direction: BubbleDirection.bottom,
                arrowQuadraticBezierLength: 1,
                radius: BorderRadius.circular(16.wMin),
                arrowHeight: 18.wMin,
                arrowAngle: 12.wMin,
                smooth: 0,
                border: BubbleBoxBorder(
                  width: 1.wMin,
                  color: AppTheme.cBorderPrimary.color,
                ),
              ),
              child: Text(
                widget.text,
                style: widget.style.copyWith(
                  color: widget.style.color ?? AppTheme.cTextPrimary.color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _hide() {
    _cancel?.call();
    _cancel = null;
  }

  void _toggle() {
    if (_cancel != null) {
      _hide();
      return;
    }
    _show();
  }

  bool _didExceedMaxLines(BoxConstraints constraints) {
    if (!constraints.maxWidth.isFinite) return false;
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: widget.maxLines,
      textDirection: Directionality.of(context),
      ellipsis: '…',
    )..layout(maxWidth: constraints.maxWidth);
    return painter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final overflowed = _didExceedMaxLines(constraints);
        return MouseRegion(
          onEnter: (_) {
            if (!overflowed) return;
            _show();
          },
          onExit: (_) => _hide(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: overflowed ? _toggle : null,
            child: Container(
              key: _anchorKey,
              child: Text(
                widget.text,
                maxLines: widget.maxLines,
                overflow: TextOverflow.ellipsis,
                style: widget.style,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SemanticPronunciationData {
  final List<String> ipaTags;
  final List<String> posTags;

  const _SemanticPronunciationData({
    required this.ipaTags,
    required this.posTags,
  });
}
