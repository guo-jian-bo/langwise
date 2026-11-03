import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';

class MissionSpecialCardWidget extends StatefulWidget {
  final int index;
  final TaskMissionMenuListEntityList data;
  final void Function(TaskMissionMenuListEntityList value)? onTap;
  const MissionSpecialCardWidget({super.key, required this.index, required this.data, this.onTap});

  @override
  State<MissionSpecialCardWidget> createState() => _MissionSpecialCardWidgetState();
}

class _MissionSpecialCardWidgetState extends State<MissionSpecialCardWidget> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    LSRWStatusColor colors = StatusUtils.getLSRWStatusColor(widget.data.type ?? "");

    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _hover = true;
        });
      },
      onExit: (event) {
        setState(() {
          _hover = false;
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _hover ? 1.01 : 1,
        child: TapScaleWidget(
          onTap: () => widget.onTap?.call(widget.data),
          sclae: 1.01,
          child: Container(
            height: 500.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cBgSecondary.color,
              border: Border.all(
                color: _hover ? colors.primary.withValues(alpha: 0.5) : AppTheme.cBgTertiary.color,
                width: 1.wMin,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 330.wMin,
                  width: double.infinity,
                  child: _buildCoverWidget(colors),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.wMin),
                      _buildTagListWidget(),
                      const Spacer(),
                      _buildBottomActionWidget(colors),
                      SizedBox(height: 12.wMin),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverWidget(LSRWStatusColor colors) {
    Widget imageWidget = _buildCoverPlaceholder();
    if ((widget.data.iconUrl ?? '').isNotEmpty) {
      imageWidget = CachedImageWidget(
        widget.data.iconUrl ?? "",
        fadeInDuration: Duration.zero,
        fit: BoxFit.cover,
        placeholder: _buildCoverPlaceholder(),
        errorWidget: _buildCoverPlaceholder(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.wMin),
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageWidget,
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  AppTheme.cBgPrimary.color.withValues(alpha: 0.92),
                ],
                stops: const [0, 0.62, 1],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  widget.data.content?.isNotEmpty == true ? widget.data.content! : 'Global View',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: AppTheme.cStaticWhite.color.withValues(alpha: 0.86),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.wMin),
                Text(
                  widget.data.title ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22.wMin,
                    color: AppTheme.cStaticWhite.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.wMin),
                Text(
                  widget.data.describe?.isNotEmpty == true ? widget.data.describe! : 'Good morning, come inside.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: AppTheme.cStaticWhite.color.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cBgSecondary.color,
            AppTheme.cBgTertiary.color,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 44.wMin,
          color: AppTheme.cTextTertiary.color,
        ),
      ),
    );
  }

  Widget _buildTagListWidget() {
    final tags = widget.data.tags ?? [];
    if (tags.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin),
      child: Wrap(
        spacing: 4.wMin,
        runSpacing: 8.wMin,
        children: List.generate(tags.length, (index) {
          return _buildTagItemWidget(tag: tags[index]);
        }),
      ),
    );
  }

  /// 标签item
  Widget _buildTagItemWidget({
    required TaskMissionMenuListEntityListTags? tag,
  }) {
    if (tag == null) return Container();
    final themeText = StyleUtils.getCurrentThemeText(tag.style);
    LanguageText? gloss = LearningLangUtils.getShowLList(tag.gloss);
    final text = gloss?.text ?? "";
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.wMin,
        vertical: 4.wMin,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        color: ColorUtils.parseColor(themeText?.backgroundColor) ?? AppTheme.cTextInverse.color,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: (themeText?.fontsize ?? 16).wMin,
          color: ColorUtils.parseColor(themeText?.color) ?? AppTheme.cInverseTextLight.color,
        ),
      ),
    );
  }

  Widget _buildBottomActionWidget(LSRWStatusColor colors) {
    final ctaText = widget.data.module?.contains('SONG') == true
        ? '播放'
        : widget.data.module?.contains('TEXT') == true
            ? '去看看'
            : '开始';
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.wMin),
          child: Container(
            width: 44.wMin,
            height: 44.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cSurfaceLayerBase.color,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 22.wMin,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ),
        Expanded(
          child: ButtonWidget(
            text: widget.data.isNormal ? ctaText : "未解锁",
            color: widget.data.isNormal ? AppTheme.cSurfaceLayerBase.color : AppTheme.cSurfaceLayerBase.color,
            fontColor: widget.data.isNormal ? AppTheme.cStaticWhite.color : AppTheme.cTextTertiary.color,
            height: 44.wMin,
            borderRadius: 8.wMin,
            fontWeight: FontWeight.w600,
            fontSize: 16.wMin,
            sclae: 1.01,
            onTap: () => widget.onTap?.call(widget.data),
          ),
        ),
        SizedBox(width: 12.wMin),
      ],
    );
  }
}
