
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/zhenxie_widgets/phrase_enter_sentence_phrase_widget.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../management/common/commons.dart';

/// 入句画像列表卡片。
class ZhenxieEnterSentenceCardWidget extends StatelessWidget {
  /// 当前短语卡片数据。
  final EnterSentenceEntity data;

  /// 是否展示管理台复制标记。
  final bool isManagement;

  const ZhenxieEnterSentenceCardWidget({super.key, required this.data, this.isManagement = false});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _buildHeaderWidget(),
          _buildPhraseInfoWidget(),
          _buildSentencePhraseWidget(),
          _buildSentenceWidget(),
        ],
      ),
    );
  }

  Widget _buildSentencePhraseWidget(){
    if(data.preview?.governedSlots != null){
      return Container(
        margin: EdgeInsets.only(top: 16.wMin),
        child: PhraseEnterSentencePhraseWidget(governedSlots: data.preview?.governedSlots, content: data.content),
      );
    }
    return Container(
      margin: EdgeInsets.only(top: 16.wMin),
      child: Text(
        "这条短语还没有入句画像。",
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextTertiary.color,
        ),
      ),
    );
  }

  Widget _buildSentenceWidget(){
    if(data.preview?.sentence == null) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.wMin),
        Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
        SizedBox(height: 16.wMin),
        PhraseEnterSentenceSentenceWidget(
          sentence: data.preview?.sentence,
          content: data.content,
        ),
      ],
    );
  }

  /// 顶部门楣：类型、句槽标签、管理标记、形式数量。
  Widget _buildHeaderWidget() {
    final preview = data.preview;
    final slotLabelList = preview?.sentenceSlotCategoryNamesZh??[];
    final countText = (data.profileCount ?? 0) > 0 ? "${data.profileCount ?? 0}种入句形式" : "待标";
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            spacing: 4.wMin,
            runSpacing: 4.wMin,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                preview?.grammaticalTypeNameZh?.isNotEmpty == true ? preview?.grammaticalTypeNameZh ?? '' : '入句画像待标',
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
              _buildTagWidget(
                tagText: slotLabelList.isNotEmpty ? "能放在 ${slotLabelList.join('、')}" : "句槽待标",
                textColor: slotLabelList.isNotEmpty ? AppTheme.cSurfaceWarning.color : AppTheme.cTextSecondary.color,
                bgColor: slotLabelList.isNotEmpty
                    ? AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12)
                    : AppTheme.cSurfaceLayerBase.color,
                borderColor: slotLabelList.isNotEmpty
                    ? AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2)
                    : AppTheme.cBorderThin.color,
              ),
              CopyTagWidget(
                name: "nid",
                value: preview?.grammaticalTypeNid ?? "",
                isShow: isManagement,
              ),
            ],
          ),
        ),
        SizedBox(width: 12.wMin),
        _buildTagWidget(
          tagText: countText,
        ),
      ],
    );
  }

  /// 标题区：短语表面、词性、说明。
  Widget _buildPhraseInfoWidget() {
    final configController = Get.find<ConfigController>();
    final posColor = StatusUtils.getConfigColor(configController.colorConfigs.value.pos, data.pos ?? '');
    Color posBorderColor = posColor?.color?.borderColor ?? AppTheme.cSurfaceBrand.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.wMin),
        Wrap(
          spacing: 4.wMin,
          runSpacing: 4.wMin,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              data.content ?? "",
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            CopyTagWidget(
              name: "短语",
              value: data.phraseId?.toString() ?? '',
              isShow: isManagement,
            ),
            _buildTagWidget(
              tagText: posColor?.title ?? '',
              textColor: posBorderColor,
              bgColor: posBorderColor.withValues(alpha: 0.12),
              borderColor: posBorderColor.withValues(alpha: 0.6),
            ),
          ],
        ),
        SizedBox(height: 10.wMin),
        Text(
          data.preview?.descriptionZh ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      ],
    );
  }

  /// 通用标签。
  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
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
