
import 'package:flutter/material.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../common/widgets/zhenxie_widgets/article_blueprint_min_table_widget.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../management/common/commons.dart';

class ZhenxieArticleBlueprintDetailsCardWidget extends StatelessWidget {
  final ArticleBlueprintEntityBlueprints? data;
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;
  final bool isManagement;
  const ZhenxieArticleBlueprintDetailsCardWidget({
    super.key,
    required this.data,
    required this.paragraphRhetoricalList,
    required this.isManagement,
  });

  @override
  Widget build(BuildContext context) {
    if(data == null) return Container();
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        borderRadius: BorderRadius.circular(20.wMin),
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 0.8.wMin,
        ),
      ),
      child: Column(
        children: [
          _buildItemTitleWidget(),
          SizedBox(height: 24.wMin),
          _buildItemContentWidget(),
        ],
      ),
    );
  }

  Widget _buildItemTitleWidget(){
    final name = LearningLangUtils.getLocalLang(data?.name);
    final description = LearningLangUtils.getLocalLang(data?.description);
    int minParagraphCount = data?.minParagraphCount??0;
    int maxParagraphCount = data?.maxParagraphCount??0;
    String showCount = "$minParagraphCount-$maxParagraphCount段";
    if(minParagraphCount == maxParagraphCount){
      showCount = "$minParagraphCount段";
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 128.wMin,
          height: 128.wMin,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CachedImageWidget(
                data?.coverUrl??"",
                placeholder: buildEmptyWidget(),
                errorWidget: buildEmptyWidget(),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Visibility(
                  visible: isManagement,
                  child: Container(
                    height: 24.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                    child: Text(
                      "更换封面",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.wMin),
        
        Expanded(
          child: SizedBox(
            height: 128.wMin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.wMin,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      name?.text??'',
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cZhenxieFontPrimary.color,
                        fontFamily: AppFontValue.sourceHanSerifCN,
                      ),
                    ),
                    if(isManagement)...[
                      CopyTagWidget(
                        name: "蓝图",
                        value: data?.nid??'',
                        isShow: isManagement,
                      ),
                      CopyTagWidget(
                        name: "框架",
                        value: data?.frameworkNid??'',
                        isShow: isManagement,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 8.wMin),
                Text(
                  description?.text??'',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontTertiary.color,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    _buildTagWidget(
                      tagText: showCount,
                    ),
                    SizedBox(width: 4.wMin),
                    _buildTagWidget(
                      tagText: "L${data?.difficulty?.min??0}-L${data?.difficulty?.max??0}",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
      ],
    );
  }

  Widget _buildItemContentWidget(){

    return ArticleBlueprintMaxTableWidget(
      paragraphRhetoricalList: paragraphRhetoricalList,
      slots: data?.slots??[],
      frame: data?.frame,
      onTapParagraph: (paragraphs) {
        TagRoutes.toNamed(
          Routes.ZHENXIE_PARAGRAPH_BLUEPRINT_DETAILS,
          arguments: {
            "isManagement": isManagement,
            "nid": paragraphs?.paragraphTypeNid??'',
          },
        );
      },
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