import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/zhenxie_widgets/phrase_enter_sentence_phrase_widget.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../management/common/commons.dart';

/// 入句画像列表卡片：对齐 ui_ux React 的甄写纸面风格（PhraseProfileListCard）。
/// 结构：眉字（类型 / 句槽 / 形式数）→ 短语与词性 → 描述 → 入句形式例句（最多三条）。
class ZhenxieEnterSentenceCardWidget extends StatelessWidget {
  /// 当前短语卡片数据。
  final EnterSentenceEntity data;

  /// 是否展示管理台复制标记。
  final bool isManagement;

  /// 入句形式例句最多展示条数。
  static const int formLimit = 3;

  const ZhenxieEnterSentenceCardWidget({super.key, required this.data, this.isManagement = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderWidget(),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildSentenceFormWidget(),
            ),
          ),
        ],
      ),
    );
  }

  /// 顶部门楣：类型、句槽、形式数量；标题行：短语、词性、管理标记；描述限两行。
  Widget _buildHeaderWidget() {
    final preview = data.preview;
    final slotLabelList = _buildSlotLabelList(preview?.sentenceSlotCategoryNamesZh);
    final countText = (data.profileCount ?? 0) > 0 ? "${data.profileCount ?? 0} 种入句形式" : "待标";
    final description = preview?.descriptionZh ?? '';
    final posTitle = _buildPosTitle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8.wMin,
                    runSpacing: 4.wMin,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        preview?.grammaticalTypeNameZh?.isNotEmpty == true ? preview?.grammaticalTypeNameZh ?? '' : '入句画像待标',
                        style: _buildSerifStyle(fontSize: 16.wMin, color: AppTheme.cZhenxieFontTertiary.color),
                      ),
                      if (slotLabelList.isNotEmpty)
                        Text(
                          "能放在 ${slotLabelList.join(' / ')}",
                          style: _buildSerifStyle(fontSize: 16.wMin, color: AppTheme.cZhenxieFontTertiary.color),
                        ),
                      CopyTagWidget(
                        name: "nid",
                        value: preview?.grammaticalTypeNid ?? "",
                        isShow: isManagement,
                      ),
                    ],
                  ),
                  SizedBox(height: 6.wMin),
                  Wrap(
                    spacing: 8.wMin,
                    runSpacing: 6.wMin,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        data.content ?? "",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cZhenxieFontPrimary.color,
                          fontFamily: AppFontValue.sourceHanSerifCN,
                          height: 1.35,
                        ),
                      ),
                      CopyTagWidget(
                        name: "短语",
                        value: data.phraseId?.toString() ?? '',
                        isShow: isManagement,
                      ),
                      if (posTitle.isNotEmpty) _buildTagWidget(tagText: posTitle),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.wMin),
            Text(
              countText,
              style: TextStyle(
                fontSize: 15.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontSecondary.color,
              ),
            ),
          ],
        ),
        if (description.isNotEmpty) ...[
          SizedBox(height: 6.wMin),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary.color,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  /// 入句形式例句区：最多三条「类型名 + 例句 + 译义」，超出时提示剩余数量。
  Widget _buildSentenceFormWidget() {
    final List<Widget> rowList = [];
    int total = 0;

    final List<EnterSentenceEntityProfiles?> profileList = data.profiles ?? [];
    if (profileList.isNotEmpty) {
      total = data.profileCount ?? profileList.length;
      for (final profile in profileList.take(formLimit)) {
        rowList.add(
          _buildFormRowWidget(
            typeLabel: profile?.grammaticalTypeNameZh ?? '',
            sentence: _firstSentenceOf(profile?.sentences),
            example: profile?.example,
          ),
        );
      }
    } else if (data.preview != null) {
      total = data.profileCount ?? 1;
      rowList.add(
        _buildFormRowWidget(
          typeLabel: data.preview?.grammaticalTypeNameZh ?? '',
          sentence: data.preview?.sentence,
          example: data.preview?.example,
        ),
      );
    }

    if (rowList.isEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 20.wMin),
        child: Text(
          "这条短语还没有入句画像。",
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontSecondary.color,
          ),
        ),
      );
    }

    final int extra = total - rowList.length;
    return Container(
      margin: EdgeInsets.only(top: 20.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.wMin,
        children: [
          ...rowList,
          if (extra > 0)
            Text(
              "还有 $extra 种入句形式",
              style: _buildSerifStyle(fontSize: 15.wMin, color: AppTheme.cZhenxieFontSecondary.color),
            ),
        ],
      ),
    );
  }

  /// 单条入句形式：类型名 + 例句（金标高亮），无例句时兜底占位。
  Widget _buildFormRowWidget({
    required String typeLabel,
    required EnterSentenceEntityPreviewSentence? sentence,
    String? example,
  }) {
    final resolvedSentence = _resolveSentence(sentence, example);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          typeLabel.isNotEmpty ? typeLabel : '入句画像待标',
          style: _buildSerifStyle(fontSize: 15.wMin, color: AppTheme.cZhenxieFontSecondary.color),
        ),
        SizedBox(height: 2.wMin),
        if (resolvedSentence != null)
          PhraseEnterSentenceSentenceWidget(
            sentence: resolvedSentence,
            content: data.content,
            fontSize: 16.wMin,
            textColor: AppTheme.cZhenxieFontPrimary.color,
            highlightStyle: TextStyle(
              background: Paint()..color = AppTheme.cZhenxieGold.color.withValues(alpha: 0.22),
              decoration: TextDecoration.underline,
              decorationColor: AppTheme.cZhenxieGold.color,
              decorationThickness: 1.wMin,
            ),
            definitionColor: AppTheme.cZhenxieFontSecondary.color,
            definitionMaxLines: 1,
          )
        else
          Text(
            "（尚无例句）",
            style: TextStyle(
              fontSize: 14.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary.color,
            ),
          ),
      ],
    );
  }

  /// 例句兜底：优先入库句子，其次画像示例句。
  EnterSentenceEntityPreviewSentence? _resolveSentence(EnterSentenceEntityPreviewSentence? sentence, String? example) {
    if (sentence?.contentCard?.title?.isNotEmpty == true) return sentence;
    if (example?.isNotEmpty == true) {
      return EnterSentenceEntityPreviewSentence(
        contentCard: KnowledgeCommonEntityList(
          contentType: 'EN_SENTENCE',
          title: example,
          content: KnowledgeCommonEntityListContent(
            type: 'EN_SENTENCE',
          ),
        ),
        ranges: const [],
      );
    }
    return null;
  }

  /// 取画像下第一条入库句子。
  EnterSentenceEntityPreviewSentence? _firstSentenceOf(List<EnterSentenceEntityPreviewSentence?>? sentences) {
    for (final item in sentences ?? const []) {
      if (item?.contentCard?.title?.isNotEmpty == true) return item;
    }
    return null;
  }

  /// 句槽名列表：去掉「槽位」后缀，对齐 React slotCategoryLabel。
  List<String> _buildSlotLabelList(List<String?>? names) {
    return (names ?? const [])
        .whereType<String>()
        .map((name) => name.replaceAll(RegExp(r'槽位$'), ''))
        .where((name) => name.isNotEmpty)
        .toList();
  }

  /// 词性标题。
  String _buildPosTitle() {
    final configController = Get.find<ConfigController>();
    final posColor = StatusUtils.getConfigColor(configController.colorConfigs.value.pos, data.pos ?? '');
    return posColor?.title ?? '';
  }

  /// 衬线样式快捷构造。
  TextStyle _buildSerifStyle({required double fontSize, required Color color}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
      fontFamily: AppFontValue.sourceHanSerifCN,
    );
  }

  /// 通用标签（对齐 React ZX_CHIP 中性胶囊）。
  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cZhenxieFontTertiary,
    Color bgColor = AppTheme.cZhenxieBackgroundPrimary,
    Color borderColor = AppTheme.cZhenxieBorderPrimary,
  }) {
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: borderColor,
          width: 0.5.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tagText,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
