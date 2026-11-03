import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../values/values.dart';
import '../../../app/modules/management/common/commons.dart';

class ZhenxieGrammarPanoramaItemWidget extends StatelessWidget {
  final ManageGrammarPanoramaEntity data;
  final bool isManagement;
  final VoidCallback? onTap;
  /// 是否 为选择模式
  final bool isSelectMode;
  /// 是否 选中
  final bool isSelected;

  /// 语法全景列表卡片
  const ZhenxieGrammarPanoramaItemWidget({
    super.key,
    required this.data,
    this.isManagement = false,
    this.onTap,
    this.isSelectMode = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final LanguageText? name = LearningLangUtils.getLocalLang(data.name);
    final LanguageText? description = LearningLangUtils.getLocalLang(data.description);
    final int cellCount = data.cellCount ?? 0;
    final int setCount = data.realizationSets?.whereType<ZhenxieRealizationSetsEntity>().length ?? 0;
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1,
      backColor: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.08),
      borderRadius: 16.wMin,
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cZhenxieBackgroundPrimary.color,
          border: Border.all(
            color: AppTheme.cZhenxieBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8.wMin,
                            height: 8.wMin,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // color: data.gridKindEnum?.color,
                              color: Color(0xffD9D9D9),
                            ),
                          ),
                          SizedBox(width: 6.wMin),
                          Text(
                            data.gridKindEnum?.name ?? '',
                            style: TextStyle(
                              fontSize: 15.wMin,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.cZhenxieFontTertiary.color,
                              fontFamily: AppFontValue.sourceHanSerifCN,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.wMin),
                      Wrap(
                        spacing: 4.wMin,
                        runSpacing: 4.wMin,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            name?.text ?? '',
                            style: TextStyle(
                              fontSize: 24.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cZhenxieFontPrimary.color,
                              fontFamily: AppFontValue.sourceHanSerifCN,
                            ),
                          ),
                          CopyTagWidget(
                            name: "宫格",
                            value: data.nid ?? '',
                            isShow: isManagement,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildChipWidget(
                      text: "CEFR ${data.difficulty?.min ?? '–'}-${data.difficulty?.max ?? '–'}",
                    ),
                    SizedBox(height: 6.wMin),
                    Text(
                      "$cellCount格${setCount > 0 ? " · $setCount套" : ""}",
                      style: TextStyle(
                        fontSize: 13.5.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cZhenxieFontSecondary.color,
                        fontFamily: AppFontValue.robotoMono,
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: isSelectMode,
                  child: Container(
                    margin: EdgeInsets.only(left: 12.wMin),
                    child: SvgPicture.asset(
                      isSelected? "assets/svg/manage/icon_check_box.svg" : "assets/svg/manage/icon_uncheck_box.svg",
                      width: 24.wMin,
                      height: 24.wMin,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.wMin),
            Text(
              description?.text ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontSecondary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
                height: 1.5,
              ),
            ),
            Container(
              height: 1.wMin,
              color: AppTheme.cZhenxieBorderPrimary.color,
              margin: EdgeInsets.symmetric(vertical: 16.wMin),
            ),
            GrammarPanoramaMinTableWidget(
              axes: data.axes,
              cells: data.cells,
              realizationSets: data.realizationSets,
            ),
          ],
        ),
      ),
    );
  }

  /// 右上角轻量标签。
  Widget _buildChipWidget({required String text}) {
    return Container(
      height: 32.wMin,
      padding: EdgeInsets.symmetric(horizontal: 12.wMin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color.withValues(alpha: 0.2),
          width: 0.5.wMin,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.5.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cZhenxieFontTertiary.color,
          fontFamily: AppFontValue.robotoMono,
        ),
      ),
    );
  }
}
