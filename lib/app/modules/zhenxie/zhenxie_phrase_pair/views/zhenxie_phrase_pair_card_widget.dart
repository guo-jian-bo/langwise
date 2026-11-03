
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../theme/theme.dart';
import '../../common/zhenxie_phrase_pair_item_widget.dart';
import '../../../management/common/commons.dart';

class ZhenxiePhrasePairCardWidget extends StatelessWidget {
  final PhrasePairEntity data;
  final bool isManagement;
  const ZhenxiePhrasePairCardWidget({super.key, required this.data, this.isManagement = false});

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
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildContentWidget(),
              ),
              _buildTagsWidget(),
            ],
          ),
          SizedBox(height: 16.wMin),
          IntrinsicHeight(
            child: Row(
              spacing: 8.wMin,
              children: List.generate(data.slots?.length??0, (index){
                return ZhenxiePhrasePairItemWidget(
                  slot: data.slots?[index],
                  isManagement: isManagement,
                );
              }),
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildContentWidget(){
    final name = LearningLangUtils.getLocalLang(data.name);
    final description = LearningLangUtils.getLocalLang(data.description);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.pairTypeNameZh??'',
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        SizedBox(height: 8.wMin),
        Wrap(
          spacing: 4.wMin,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              name?.text??'',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            CopyTagWidget(
              name: "配对",
              value: data.nid??'',
              isShow: isManagement,
            ),
          ],
        ),
        SizedBox(height: 6.wMin),
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

  Widget _buildTagsWidget(){
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
    int pairCount = data.pairCount??0;
    
    return Column(
      spacing: 6.wMin,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildTagWidget(tagText: data.relationDirection??''),
        Row(
          spacing: 10.wMin,
          children: [
            _buildTagWidget(
              tagText: "${min?.name?.text??''} - ${max?.name?.text??''}",
            ),
            _buildTagWidget(
              tagText: "$pairCount对",
              textColor: pairCount == 0 ? AppTheme.cTextSecondary.color : AppTheme.cSurfaceSuccess.color,
              bgColor: pairCount == 0 ? AppTheme.cSurfaceLayerBase.color : AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12), 
              borderColor: pairCount == 0 ? AppTheme.cBorderThin.color : AppTheme.cBorderSubtle.color.withValues(alpha: 0.2),
            ),
          ],
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
