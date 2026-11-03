
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../theme/theme.dart';
import '../../common/zhenxie_phrase_contrast_item_widget.dart';
import '../../../management/common/commons.dart';


class ZhenxiePhraseContrastCardWidget extends StatelessWidget {
  final PhraseParadigmEntity data;
  final bool isManagement;
  const ZhenxiePhraseContrastCardWidget({super.key, required this.data, this.isManagement = false});

  @override
  Widget build(BuildContext context) {

    List<PhraseParadigmEntitySlots?> slots = data.slots??[];

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
          _buildTitleWidget(),
          _buildContentWidget(),
          SizedBox(height: 16.wMin),
          LayoutBuilder(
            builder: (context, constraints) {
              double spacing = 10.wMin * 3;
              double itemWidth = (constraints.maxWidth - spacing) / 4;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(
                    spacing: 10.wMin,
                    children: List.generate(slots.length, (index){
                      return SizedBox(
                        width: itemWidth,
                        child: ZhenxiePhraseContrastItemWidget(
                          slot: slots[index],
                          isManagement: isManagement,
                        ),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(){
    ConfigController configController = Get.find<ConfigController>();
    DifficultieEntity? min = DifficultieUtils.getLanguageDifficultieLevel(
      configController.appConfig.value,
      "en",
      data.difficulty?.min,
    );
    DifficultieEntity? max = DifficultieUtils.getLanguageDifficultieLevel(
      configController.appConfig.value,
      "en",
      data.difficulty?.max,
    );
    return Row(
      children: [
        Text(
          data.dimensionNameZh??'',
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        SizedBox(width: 16.wMin),
        CopyTagWidget(
          name: "维度",
          value: data.dimensionNid??'',
          isShow: isManagement,
        ),
        Spacer(),
        _buildTagWidget(
          tagText: "${min?.name?.text??''} - ${max?.name?.text??''}",
        ),
        SizedBox(width: 6.wMin),
        _buildTagWidget(
          tagText: "${data.filledSlots??0}/${data.totalSlots??00}槽·${data.issuedCount??0}条",
          textColor: (data.filledSlots??0) == 0 ? AppTheme.cTextSecondary.color : AppTheme.cSurfaceSuccess.color,
          bgColor: (data.filledSlots??0) == 0 ? AppTheme.cSurfaceLayerBase.color : AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12),
          borderColor: (data.filledSlots??0) == 0 ? AppTheme.cBorderThin.color : AppTheme.cBorderSubtle.color.withValues(alpha: 0.2),
        ),
      ],
    );
  }

  Widget _buildContentWidget(){
    LanguageText? name = LearningLangUtils.getLocalLang(data.name);
    LanguageText? description = LearningLangUtils.getLocalLang(data.description);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.wMin),
        Row(
          children: [
            Text(
              name?.text??'',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            SizedBox(width: 4.wMin),
            CopyTagWidget(
              name: "对照",
              value: data.nid??'',
              isShow: isManagement,
            ),
          ],
        ),
        SizedBox(height: 10.wMin),
        Text(
          description?.text??'',
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      ],
    );
  }

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
          color: borderColor.withValues(alpha: 0.2),
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
