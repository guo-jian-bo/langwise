
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../elements/utils/elements_page_utils.dart';

class ZhenxieTaskMaterialsWidget extends StatefulWidget {
  final List<ElementsCardEntityDatas> knowledgePointsList;
  final bool isManagement;
  /// 资料
  const ZhenxieTaskMaterialsWidget({
    super.key,
    required this.knowledgePointsList,
    this.isManagement = false,
  });

  @override
  State<ZhenxieTaskMaterialsWidget> createState() => _ZhenxieTaskMaterialsWidgetState();
}

class _ZhenxieTaskMaterialsWidgetState extends State<ZhenxieTaskMaterialsWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 18.wMin),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          child: Text(
            "文章的核心知识点列表",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ),
        Expanded(
          child: _buildKnowledgePointsWidget(),
        ),
      ],
    );
  }

  Widget _buildKnowledgePointsWidget(){
    if(widget.knowledgePointsList.isEmpty){
      return Center(
        child: Text(
          "本文没有列出核心知识点",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: widget.knowledgePointsList.length,
      padding: EdgeInsets.all(24.wMin),
      separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
      itemBuilder: (context, index) {
        final item = widget.knowledgePointsList[index];
        return _buildKnowledgeItemWidget(item);
      },
    );
  }

  Widget _buildKnowledgeItemWidget(ElementsCardEntityDatas data){

    ConfigController configController = Get.find<ConfigController>();
    final posColor = StatusUtils.getConfigColor(configController.colorConfigs.value.pos, data.pos??'');
    Color posBgColor = posColor?.color?.bgColor ?? (AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2));
    Color posTextColor = posColor?.color?.textColor ?? (AppTheme.cSurfaceBrand.color);

    return TapScaleWidget(
      onTap: () {
        ElementsPageUtils.jumpElementsPage(
          contentId: data.contentId, 
          contentType: data.contentType, 
          semanticId: data.semanticId, 
          content: data.content,
          styleId: null, 
          dialect: null,
          isManagement: widget.isManagement,
        );
      },
      sclae: 1.01,
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderThin.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.wMin),
                color: posBgColor,
              ),
              child: Text(
                data.posTitle ?? "",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: posTextColor,
                ),
              ),
            ),
            SizedBox(height: 6.wMin),
            Text(
              data.content??"",
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            SizedBox(height: 6.wMin),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    data.definition??"",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                ),
                SizedBox(width: 12.wMin),
                Text(
                  "查看详情",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                SizedBox(width: 8.wMin),
                SvgPicture.asset(
                  "assets/svg/public/icon_w_arrow_right.svg",
                  width: 24.wMin,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
