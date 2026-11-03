import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../controllers/intelligent_search_controller.dart';

class IntelligentSearchRecommendationWidget extends StatelessWidget {
  final IntelligentSearchController controller;
  const IntelligentSearchRecommendationWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    double sysPaddingLeft = MediaQuery.of(context).padding.left;
    double sysPaddingRight = MediaQuery.of(context).padding.right;
    double paddingLeft = sysPaddingLeft > 90.wMin ? sysPaddingLeft : 90.wMin;
    double paddingRight = sysPaddingRight > 90.wMin ? sysPaddingRight : 90.wMin;

    return Expanded(
      child: Obx((){
        if(controller.learnIntentionList.isEmpty){
          return _buildNotDataWidget();
        }
        return SingleChildScrollView(
          controller: controller.learnIntentionController,
          padding: EdgeInsets.only(
            left: paddingLeft,
            right: paddingRight,
            top: 12.wMin,
            bottom: 12.wMin,
          ),
          child: Column(
            children: [
              _buildTitleWidget(),
              _buildAttemptWidget(),
              SizedBox(height: 24.wMin),
              _buildListWidget(),
              SizedBox(height: 150.wMin),
            ],
          ),
        );
      }),
    );
  }

  /// 没有计划的情况下 把 尝试搜索放大
  Widget _buildNotDataWidget(){
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NotDataWidget(
            message: "搜你想学的，也帮你找到下一步值得学的",
          ),
          SizedBox(height: 24.wMin),

          Obx((){
            if(controller.trySearchText.isEmpty) return Container();

            return Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.wMin,
                      height: 8.wMin,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.cTextBrand.color,
                      ),
                    ),
                    SizedBox(width: 8.wMin),
                    Text(
                      "尝试搜索",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cTextBrand.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.wMin),
                Wrap(
                  spacing: 8.wMin,
                  runSpacing: 6.wMin,
                  alignment: WrapAlignment.center,
                  children: List.generate(controller.trySearchText.length, (index){
                    return _buildAttemptItemWidget(controller.trySearchText[index]);
                  }),
                ),
              ],
            );
          }),

          
          SizedBox(height: 150.wMin),

        ],
      ),
    );
  }


  Widget _buildTitleWidget(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "搜你想学的，也帮你找到下一步值得学的",
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        const Spacer(),
        Text(
          "可以直接搜索，也可以从当前单元一键展开，继续找到更适合你的内容。",
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      ],
    );
  }

  /// 尝试搜索
  Widget _buildAttemptWidget(){
    return Obx((){
      if(controller.trySearchText.isEmpty) return Container();
      return Container(
        margin: EdgeInsets.only(top: 12.wMin),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 4.wMin),
              child: Row(
                children: [
                  Container(
                    width: 8.wMin,
                    height: 8.wMin,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cTextBrand.color,
                    ),
                  ),
                  SizedBox(width: 8.wMin),
                  Text(
                    "尝试搜索",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextBrand.color,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.wMin),
            Expanded(
              child: Wrap(
                spacing: 8.wMin,
                runSpacing: 6.wMin,
                children: List.generate(controller.trySearchText.length, (index){
                  return _buildAttemptItemWidget(controller.trySearchText[index]);
                }),
              ),
            ),
        
          ],
        ),
      );
    });
  }

  Widget _buildAttemptItemWidget(String text){
    return TapScaleWidget(
      onTap: () {
        controller.onClickTrySearch(text);
      },
      sclae: 1.02,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerElevated2.color,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppTheme.cBorderDefault.color,
            width: 1.wMin,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
      ),
    );
  }


  Widget _buildListWidget(){
    return Obx((){
      return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: controller.learnIntentionList.length,
        separatorBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 32.wMin),
            height: 1.wMin,
            color: AppTheme.cBorderDefault.color,
          );
        },
        itemBuilder: (context, index) {
          return _buildListItemWidget(controller.learnIntentionList[index], index);
        },
      );
    });
  }
  

  Widget _buildListItemWidget(SearchLearnIntentionEntityList intention, int index){
    List<SearchLearnIntentionEntityListIntentCards?> intentCards = intention.intentCards??[];

    return Column(
      children: [
        _buildListItemBookWidget(intention),
        SizedBox(height: 16.wMin),
        GridView.builder(
          itemCount: intentCards.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 12.wMin,
            crossAxisSpacing: 12.wMin,
            mainAxisExtent: 370.wMin,
            // childAspectRatio: 334 / 392,
          ),
          itemBuilder: (context, kindIndex){
            return _buildListExpandItemWidget(context, intentCards[kindIndex], kindIndex, index);
          },
        ),
      ],
    );
  }

  Widget _buildListItemBookWidget(SearchLearnIntentionEntityList intention){

    final configEntity = Get.find<ConfigController>().appConfig.value;

    DifficultieEntity? currentMinDifficulty = DifficultieUtils.getLanguageDifficultieLevel(configEntity, "en", intention.moduleDifficulty?.min??0);
    DifficultieEntity? currentMaxDifficulty = DifficultieUtils.getLanguageDifficultieLevel(configEntity, "en", intention.moduleDifficulty?.max??0);
    
    final minDifficultyColor = StatusUtils.getDifficultyBackgroundColor(intention.moduleDifficulty?.min??0);
    final maxDifficultyColor = StatusUtils.getDifficultyBackgroundColor(intention.moduleDifficulty?.max??0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    
        SizedBox(
          width: 100.wMin,
          height: 133.wMin,
          child: CachedImageWidget(
            intention.moduleCoverUrl??"",
            borderRadius: BorderRadius.circular(12.wMin),
            errorWidget: buildEmptyWidget(fit: BoxFit.cover),
            placeholder: buildEmptyWidget(fit: BoxFit.cover),
          ),
        ),
    
        SizedBox(width: 16.wMin),
    
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
    
              Row(
                spacing: 6.wMin,
                children: [
    
                  _buildListItemBookTagItemWidget(
                    tagText: intention.courseTypeName??"",
                    textColor: SpecialtyEnum.getCourseColor(intention.courseType??"").color1,
                    backgroundColor: SpecialtyEnum.getCourseColor(intention.courseType??"").color1.withValues(alpha: 0.12),
                    borderColor: SpecialtyEnum.getCourseColor(intention.courseType??"").color1.withValues(alpha: 0.3),
                  ),
    
                  Row(
                    children: [
                      _buildListItemBookTagItemWidget(
                        tagText: currentMinDifficulty?.name?.text??"",
                        textColor: minDifficultyColor.color1,
                        backgroundColor: minDifficultyColor.color1.withValues(alpha: 0.12),
                        borderColor: minDifficultyColor.color1.withValues(alpha: 0.3),
                      ),
                      Visibility(
                        visible: intention.moduleDifficulty?.max != null && intention.moduleDifficulty?.min != intention.moduleDifficulty?.max,
                        child: Text(
                          " - ",
                          style: TextStyle(
                            fontSize: 14.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextSecondary.color,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: intention.moduleDifficulty?.max != null && intention.moduleDifficulty?.min != intention.moduleDifficulty?.max,
                        child: _buildListItemBookTagItemWidget(
                          tagText: currentMaxDifficulty?.name?.text??"",
                          textColor: maxDifficultyColor.color1,
                          backgroundColor: maxDifficultyColor.color1.withValues(alpha: 0.12),
                          borderColor: maxDifficultyColor.color1.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
    
                ],
              ),
    
              SizedBox(height: 6.wMin),
    
              Text(
                "${intention.courseTypeName??""} · ${intention.moduleName??""}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
    
              SizedBox(height: 6.wMin),
    
              Text(
                intention.unitName??"",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 32.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
    
              SizedBox(height: 6.wMin),
    
              Text(
                intention.unitDescription??"",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
    
            ],
          ),
        ),
    
      ],
    );
  }

  Widget _buildListItemBookTagItemWidget({
    required String tagText,
    Color? borderColor,
    Color? backgroundColor,
    Color? textColor,
  }){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: backgroundColor ?? AppTheme.cSurfaceLayerElevated2.color,
        border: Border.all(
          color: borderColor ?? AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Text(
        tagText,
        style: TextStyle(
          fontSize: 12.wMin,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppTheme.cTextSecondary.color,
        ),
      ),
    );
  }

  Widget _buildListExpandItemWidget(BuildContext context, SearchLearnIntentionEntityListIntentCards? intentCard, int kindIndex, int index){

    Color kindColor = intentCard?.kindEnum?.color ?? AppTheme.cSurfaceBrand.color;

    return TapScaleWidget(
      onTap: () {
        controller.onClickCardSearch(intentCard, index, kindIndex);
      },
      sclae: 1.01,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderNone.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.wMin),
                            color: kindColor,
                          ),
                          child: Text(
                            intentCard?.kindTitle??"",
                            style: TextStyle(
                              fontSize: 20.wMin,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Visibility(
                          visible: intentCard?.priorityTitle != null,
                          child: Text(
                            "· ${intentCard?.priorityTitle??""}",
                            style: TextStyle(
                              fontSize: 14.wMin,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.cTextTertiary.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.wMin),
                    Obx((){
                      return Text(
                        LearningLangUtils.getShowLList(intentCard?.title)?.text??"",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      );
                    }),
                    SizedBox(height: 8.wMin),
                    Obx((){
                      return Text(
                        LearningLangUtils.getShowLList(intentCard?.subtitle)?.text??"",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextSecondary.color,
                        ),
                      );
                    }),
                    SizedBox(height: 8.wMin),
                    Expanded(
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final style = TextStyle(
                              height: 1.3,
                              fontSize: 16.wMin,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.cTextTertiary.color,
                            );

                            final lineHeight = (style.fontSize ?? 14) * (style.height ?? 1.0);
                            final calculatedLines = (constraints.maxHeight / lineHeight).floor();
                            final maxLines = calculatedLines < 1 ? 1 : calculatedLines;

                            return Container(
                              padding: EdgeInsets.only(left: 10.wMin),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: kindColor.withValues(alpha: 0.22),
                                    width: 2.wMin,
                                  ),
                                ),
                              ),
                              child: Obx((){
                                return Text(
                                  LearningLangUtils.getShowLList(intentCard?.explanation)?.text??"",
                                  maxLines: maxLines,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16.wMin,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.cTextTertiary.color,
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 8.wMin),
                    ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        scrollbars: false, // 隐藏滚动条
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildListExpandItemTagsWidget(intentCard),
                      ),
                    ),
                
                  ],
                ),
              ),
            ),
            Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 10.wMin),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 40.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.wMin),
                      color: kindColor.withValues(alpha: 0.15),
                    ),
                    child: Obx((){
                      return Text(
                        LearningLangUtils.getShowLList(intentCard?.cta)?.text??"",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      );
                    }),
                  ),
                  Positioned(
                    right: 12.wMin,
                    child: SvgPicture.asset(
                      "assets/svg/public/icon_arrow_right.svg",
                      width: 18.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
            ),
      
          ],
        ),
      ),
    );
  }

  Widget _buildListExpandItemTagsWidget(SearchLearnIntentionEntityListIntentCards? intentCard){
    List<SearchLearnIntentionEntityListIntentCardsFilters?> filters = intentCard?.filters ?? [];
    if(filters.isEmpty) return Container();
    
    List<String?> difficultys = intentCard?.difficultyValues ?? [];
    List<String?> contentTypes = intentCard?.contentTypeValues ?? [];

    final configEntity = Get.find<ConfigController>().appConfig.value;

    List<Widget> tagWidgets = [];

    for(String? difficulty in difficultys){
      int? difficultyLevel = int.tryParse(difficulty??"");
      if(difficultyLevel == null) continue;
      DifficultieEntity? difficultyModel = DifficultieUtils.getLanguageDifficultieLevel(configEntity, "en", difficultyLevel);
      final difficultyColor = StatusUtils.getDifficultyBackgroundColor(difficultyLevel);

      tagWidgets.add(_buildListItemBookTagItemWidget(
        tagText: difficultyModel?.name?.text??"",
        textColor: difficultyColor.color1,
        backgroundColor: difficultyColor.color1.withValues(alpha: 0.12),
        borderColor: difficultyColor.color1.withValues(alpha: 0.3),
      ));
    }

    for(String? contentType in contentTypes){
      if(contentType == null) continue;
      KnowledgeTypeEnum? contentTypeModel = KnowledgeTypeEnum.fromRawValue(contentType);
      if(contentTypeModel == null) continue;

      tagWidgets.add(_buildListItemBookTagItemWidget(
        tagText: contentTypeModel.name1,
      ));
    }

    return Row(
      spacing: 4.wMin,
      children: tagWidgets,
    );


  }




}