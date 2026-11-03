
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../theme/theme.dart';
import '../../../management/common/commons.dart';

class ZhenxiePhraseStructureCardWidget extends StatelessWidget {
  final PhraseStructureEntity data;
  final bool isManagement;
  const ZhenxiePhraseStructureCardWidget({super.key, required this.data, this.isManagement = false});

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
          _buildContentWidget(),
          SizedBox(height: 16.wMin),
          _buildPhraseWidget(context),
        ],
      ),
    );
  }


  Widget _buildContentWidget(){
    ConfigController configController = Get.find<ConfigController>();
    final posColor = StatusUtils.getConfigColor(configController.colorConfigs.value.pos, data.pos??'');
    Color posBorderColor = posColor?.color?.borderColor ?? AppTheme.cSurfaceBrand.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              data.content??'',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            SizedBox(width: 4.wMin),
            CopyTagWidget(
              name: "短语",
              value: data.phraseId?.toString()??'',
              isShow: isManagement,
            ),
            SizedBox(width: 4.wMin),
            _buildTagWidget(
              tagText: posColor?.title??'',
              textColor: posBorderColor,
              bgColor: posBorderColor.withValues(alpha: 0.12),
              borderColor: posBorderColor.withValues(alpha: 0.6),
            ),
            Spacer(),
            _buildTagWidget(
              tagText: data.mixLabel??'',
            ),
          ],
        ),
        SizedBox(height: 10.wMin),
        Text(
          data.explanationZh??'',
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      ],
    );
  }

  Widget _buildPhraseWidget(BuildContext context){
    List<PhraseStructureEntityItems?> items = data.items??[];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false, // 隐藏滚动条
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.wMin),
          child: IntrinsicHeight(
            child: Row(
              spacing: 6.wMin,
              children: List.generate(items.length, (index){
                return _buildPhraseItemWidget(items[index]);
              }),
            ),
          ),
        ),
      ),
    );
  }

  LanguageConfigColorEntityColors? _getColor(String? roleNid){
    ConfigController configController = Get.find<ConfigController>();
    List<LanguageConfigColorEntityInfo?> phraseItemRoles = configController.colorConfigs.value.phraseItemRoles??[];

    return phraseItemRoles.firstWhereOrNull((element) => element?.code == roleNid)?.color;
  }

  Widget _buildPhraseItemWidget(PhraseStructureEntityItems? item){
    LanguageConfigColorEntityColors? colors = _getColor(item?.roleNid);
    Color bgColor = colors?.bgC??AppTheme.cSurfaceLayerBase.color;
    Color borderColor = colors?.borderC??(AppTheme.cBorderSubtle.color);
    Color textColor = colors?.textC??AppTheme.cTextPrimary.color;

    return Container(
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
        color: bgColor,
        border: Border.all(
          color: borderColor,
          width: 0.5.wMin,
        ),
      ),
      child: Column(
        spacing: 10.wMin,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item?.roleNameZh??'',
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
          Text(
            item?.text??'',
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagWidget({
    required String tagText,
    Color? textColor = AppTheme.cTextSecondary,
    Color? bgColor = AppTheme.cSurfaceLayerBase,
    Color? borderColor = AppTheme.cBorderThin,
  }) {
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: (borderColor??AppTheme.cBorderThin),
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