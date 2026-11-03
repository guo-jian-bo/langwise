
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../theme/theme.dart';
import '../../../elements/common/elements_public_widgets.dart';
import '../../../management/common/commons.dart';

class ZhenxiePhraseStructureCardWidget extends StatefulWidget {
  final PhraseStructureEntity data;
  final bool isManagement;
  const ZhenxiePhraseStructureCardWidget({super.key, required this.data, this.isManagement = false});

  @override
  State<ZhenxiePhraseStructureCardWidget> createState() => _ZhenxiePhraseStructureCardWidgetState();
}

class _ZhenxiePhraseStructureCardWidgetState extends State<ZhenxiePhraseStructureCardWidget> {
  int _playingIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerBase.color,
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.wMin),
          _buildStructureWidget(),
          SizedBox(height: 20.wMin),
          _buildTagLineWidget(),
          SizedBox(height: 8.wMin),
          _buildTitleWidget(),
          SizedBox(height: 8.wMin),
          _buildExplanationWidget(),
          const Spacer(),
          Container(height: 1.wMin, color: AppTheme.cBorderDefault.color),
          _buildButtonsWidget(),
        ],
      ),
    );
  }

  /// 顶部结构区域：切块直接渲染，样式对齐词法首页标本，超宽时整行居中缩放。
  Widget _buildStructureWidget(){
    final List<PhraseStructureEntityItems> items = (widget.data.items ?? const <PhraseStructureEntityItems?>[])
        .whereType<PhraseStructureEntityItems>()
        .toList();
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cSurfaceTranslucentBase.color,
          border: Border.all(
            color: AppTheme.cBorderTranslucentThin.color,
            width: 1.wMin,
          ),
        ),
        child: Text(
          "这条短语还没有切块。",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(items.length * 2 - 1, (index) {
            if (index.isOdd) return SizedBox(width: 8.wMin);
            return _buildStructureItemWidget(items[index ~/ 2]);
          }),
        ),
      ),
    );
  }

  /// 单个切块：小角色名 + 切块词
  Widget _buildStructureItemWidget(PhraseStructureEntityItems item){
    ConfigController configController = Get.find<ConfigController>();
    final LanguageConfigColorEntityInfo? roleInfo = (configController.colorConfigs.value.phraseItemRoles ?? <LanguageConfigColorEntityInfo?>[])
        .firstWhereOrNull((element) => element?.code == item.roleNid);
    final LanguageConfigColorEntityThemeColors? themeColors = StatusUtils.resolveThemeColors(roleInfo);
    // 边框
    final Color borderColor = themeColors?.borderColorC ?? AppTheme.cBorderSubtle.color;
    // 背景
    final Color bgColor = themeColors?.backgroundColorC ?? AppTheme.cSurfaceLayerBase.color;
    // 切块词文字
    final Color textColor = themeColors?.textColorC ?? AppTheme.cTextPrimary.color;
    // 角色名：textColor 的 60% 透明度，默认 cTextSecondary
    final Color roleTitleColor = themeColors?.textColorC != null
        ? themeColors!.textColorC!.withValues(alpha: 0.6)
        : AppTheme.cTextSecondary.color;
    final String roleNameZh = (item.roleNameZh ?? '').trim();
    final String roleTitle = roleNameZh.isNotEmpty
        ? roleNameZh
        : (roleInfo?.title ?? (item.roleNid ?? ''));

    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.wMin),
        border: Border.all(
          color: borderColor,
          width: 1.wMin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            roleTitle,
            style: TextStyle(
              fontSize: 14.wMin,
              fontWeight: FontWeight.w500,
              color: roleTitleColor,
            ),
          ),
          SizedBox(height: 16.wMin),
          Text(
            item.text ?? '',
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              fontSize: 28.wMin,
              height: 1,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 标题行：短语内容 + 管理端复制标签
  Widget _buildTitleWidget(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.data.content??'',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ),
        SizedBox(width: 4.wMin),
        CopyTagWidget(
          name: "短语",
          value: widget.data.phraseId?.toString()??'',
          isShow: widget.isManagement,
        ),
      ],
    );
  }

  /// 详情：结构说明
  Widget _buildExplanationWidget(){
    return Text(
      widget.data.explanationZh??'',
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 18.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cTextTertiary.color,
      ),
    );
  }

  /// 标签行：pos 映射词性标签 + mixLabel，方形标签一行
  Widget _buildTagLineWidget(){
    ConfigController configController = Get.find<ConfigController>();
    final posColor = StatusUtils.getConfigColor(configController.colorConfigs.value.pos, widget.data.pos??'');
    final String posTitle = posColor?.title??'';
    final Color posBorderColor = posColor?.color?.borderColor ?? AppTheme.cSurfaceBrand.color;
    final String mixLabel = widget.data.mixLabel??'';

    if (posTitle.isEmpty && mixLabel.isEmpty) return const SizedBox.shrink();

    return Row(
      spacing: 6.wMin,
      children: [
        if (posTitle.isNotEmpty)
          _buildSquareTagWidget(
            tagText: posTitle,
            textColor: posBorderColor,
            bgColor: posBorderColor.withValues(alpha: 0.12),
            borderColor: posBorderColor.withValues(alpha: 0.6),
          ),
        if (mixLabel.isNotEmpty)
          _buildSquareTagWidget(tagText: mixLabel),
      ],
    );
  }

  Widget _buildSquareTagWidget({
    required String tagText,
    Color? textColor,
    Color? bgColor,
    Color? borderColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
        color: bgColor ?? AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: borderColor ?? AppTheme.cBorderThin.color,
          width: 0.5.wMin,
        ),
      ),
      child: Text(
        tagText,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w400,
          color: textColor ?? AppTheme.cTextSecondary.color,
        ),
      ),
    );
  }

  /// 底栏：发音胶囊按钮 + 详情入口
  Widget _buildButtonsWidget(){
    final List<PronunciationsEntity> pronunciations = _resolvePronunciations();

    return Container(
      padding: EdgeInsets.only(top: 12.wMin),
      child: Row(
        children: [
          if (pronunciations.isNotEmpty)
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false, // 隐藏滚动条
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 12.wMin,
                    children: List.generate(pronunciations.length, (index){
                      return ElementsPronunciationCapsuleButton(
                        label: _resolvePronunciationLabel(pronunciations[index]),
                        phonetic: pronunciations[index].phonetic,
                        isPlaying: _playingIndex == index,
                        onTap: () => _togglePlay(index),
                      );
                    }),
                  ),
                ),
              ),
            ),
          Text(
            "详情",
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.wMin),
          SvgPicture.asset(
            "assets/svg/public/icon_w_arrow_right.svg",
            width: 18.wMin,
            colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }

  /// 汇总所有切块的音频
  List<PronunciationsEntity> _resolvePronunciations(){
    return (widget.data.pronunciations ?? const <PronunciationsEntity?>[])
        .whereType<PronunciationsEntity>()
        .where((item) => (item.audioUrl ?? '').trim().isNotEmpty)
        .toList();
  }

  String _resolvePronunciationLabel(PronunciationsEntity item) {
    final String national = (item.national ?? '').trim().toUpperCase();
    if (national.isNotEmpty) return national;
    return (item.nationalTitle ?? '').contains('英') ? 'UK' : 'US';
  }

  Future<void> _togglePlay(int index) async {
    final List<PronunciationsEntity> pronunciations = _resolvePronunciations();
    if (index < 0 || index >= pronunciations.length) return;
    final String audioUrl = (pronunciations[index].audioUrl ?? '').trim();
    if (audioUrl.isEmpty) return;

    if (_playingIndex == index) {
      await PlayAudioUtils.instance.stopAll();
      _playingIndex = -1;
      if (mounted) setState(() {});
      return;
    }

    await PlayAudioUtils.instance.stopAll();
    _playingIndex = index;
    if (mounted) setState(() {});
    await PlayAudioUtils.instance.playSingle(audioUrl);
    _playingIndex = -1;
    if (mounted) setState(() {});
  }
}
