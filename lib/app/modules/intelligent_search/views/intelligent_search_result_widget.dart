
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../controllers/intelligent_search_controller.dart';

class IntelligentSearchResultWidget extends StatelessWidget {
  final IntelligentSearchController controller;
  const IntelligentSearchResultWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    double sysPaddingLeft = MediaQuery.of(context).padding.left;
    double sysPaddingRight = MediaQuery.of(context).padding.right;
    double paddingLeft = sysPaddingLeft > 90.wMin ? sysPaddingLeft : 90.wMin;
    double paddingRight = sysPaddingRight > 90.wMin ? sysPaddingRight : 90.wMin;

    return Expanded(
      child: ListView(
        controller: controller.scrollController,
        padding: EdgeInsets.only(
          left: paddingLeft,
          right: paddingRight,
        ),
        children: [
          _buildListItemBookWidget(),
          _buildSearchContentWidget(),
          SizedBox(height: 12.wMin),
          _buildListWidget(),
        ],
      ),
    );
  }

  Widget _buildListItemBookWidget(){
    return Obx((){
      if(controller.currentSearchIndex.value == -1 || controller.currentSearchKindIndex.value == -1){
        return Container();
      }

      SearchLearnIntentionEntityList? intentList;
      SearchLearnIntentionEntityListIntentCards? intentCard;

      try {
        intentList = controller.learnIntentionList[controller.currentSearchIndex.value];
        intentCard = intentList.intentCards?[controller.currentSearchKindIndex.value];
      } catch (_) {}
      
      if(intentList == null || intentCard == null) return Container();

      final configEntity = Get.find<ConfigController>().appConfig.value;

      DifficultieEntity? currentMinDifficulty = DifficultieUtils.getLanguageDifficultieLevel(configEntity, "en", intentList.moduleDifficulty?.min??0);
      DifficultieEntity? currentMaxDifficulty = DifficultieUtils.getLanguageDifficultieLevel(configEntity, "en", intentList.moduleDifficulty?.max??0);
      
      final minDifficultyColor = StatusUtils.getDifficultyBackgroundColor(intentList.moduleDifficulty?.min??0);
      final maxDifficultyColor = StatusUtils.getDifficultyBackgroundColor(intentList.moduleDifficulty?.max??0);

      Color kindColor = intentCard.kindEnum?.color ?? AppTheme.cSurfaceBrand.color;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.wMin),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cSurfaceLayerBase2.color,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          
                SizedBox(
                  width: 100.wMin,
                  height: 133.wMin,
                  child: CachedImageWidget(
                    intentList.moduleCoverUrl??"",
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
                            tagText: intentList.courseTypeName??"",
                            textColor: SpecialtyEnum.getCourseColor(intentList.courseType??"").color1,
                            backgroundColor: SpecialtyEnum.getCourseColor(intentList.courseType??"").color1.withValues(alpha: 0.12),
                            borderColor: SpecialtyEnum.getCourseColor(intentList.courseType??"").color1.withValues(alpha: 0.3),
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
                                visible: intentList.moduleDifficulty?.max != null && intentList.moduleDifficulty?.min != intentList.moduleDifficulty?.max,
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
                                visible: intentList.moduleDifficulty?.max != null && intentList.moduleDifficulty?.min != intentList.moduleDifficulty?.max,
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
                        "${intentList.courseTypeName??""} · ${intentList.moduleName??""}",
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
                        intentList.unitName??"",
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
                        intentList.unitDescription??"",
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
          
                Container(
                  padding: EdgeInsets.all(12.wMin),
                  constraints: BoxConstraints(
                    maxWidth: 800.wMin,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.wMin),
                    color: AppTheme.cSurfaceLayerBase2.color,
                    border: Border.all(
                      color: AppTheme.cBorderSubtle.color,
                      width: 1.wMin,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ 
                     Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin),
                        color: kindColor,
                      ),
                      child: Text(
                        intentCard.kindTitle??"",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                      SizedBox(height: 10.wMin),
                      Text(
                        LearningLangUtils.getLocalLang(intentCard.title)?.text??"",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                      SizedBox(height: 8.wMin),
                      Container(
                        padding: EdgeInsets.only(left: 10.wMin),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: kindColor.withValues(alpha: 0.65),
                              width: 2.wMin,
                            ),
                          ),
                        ),
                        child: Text(
                          LearningLangUtils.getLocalLang(intentCard.subtitle)?.text??"",
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextTertiary.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          
              ],
            ),
          ),
          SizedBox(height: 12.wMin),
          Text(
            "已从这条推荐继续展开搜索。你可以改关键词或筛选，继续往下找更合适的内容。",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ],
      );
    });
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


  Widget _buildSearchContentWidget(){

    return Obx((){
      if(controller.currentSearchIndex.value != -1 && controller.currentSearchKindIndex.value != -1){
        return Container();
      }

      SearchResultsEntity searchResults = controller.searchResults.value;

      String searchText = controller.filterSearchs[controller.searchKey]?.controller.text??"";
      String query = "";
      if((searchResults.query??"").isNotEmpty){
        query = "“${searchResults.query}”的搜索结果";
      }else if(searchText.isNotEmpty){
        query = "“$searchText”的搜索结果";
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            query,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 6.wMin),
          Text(
            "共计找到 ${controller.count.value} 条相关内容",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildListWidget(){

    return Obx((){

      if(controller.isSearching.value && controller.count.value <= 0){
        return Container();
      }

      if(controller.count.value <= 0){
        return _buildNotDataWidget();
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: controller.searchResultsList.length,
        padding: EdgeInsets.only(
          bottom: 150.wMin,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 24.wMin,
          crossAxisSpacing: 24.wMin,
          childAspectRatio: 417 / 639,
          // mainAxisExtent: 639.wMin,
        ),
        itemBuilder: (context, index){
          KnowledgeCommonEntityList item = controller.searchResultsList[index];
          if(!controller.isSelectable){
            return KnowledgeCardWidget(
              knowledgeData: item,
            );
          }
          return _buildResultItemWidget(item);
        },
      );
    });
  }

  Widget _buildResultItemWidget(KnowledgeCommonEntityList item){
    return Obx((){
      bool isSelected = controller.isContentSelected(item);
      return TapScaleWidget(
        onTap: () {
          controller.toggleSelectedContent(item);
        },
        sclae: 1,
        child: Stack(
          children: [
            Positioned.fill(
              child: AbsorbPointer(
                child: KnowledgeCardWidget(
                  knowledgeData: item,
                ),
              ),
            ),
            Positioned(
              top: 12.wMin,
              right: 12.wMin,
              child: IgnorePointer(
                child: _buildSelectBadge(isSelected),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSelectBadge(bool isSelected) {
    return Container(
      width: 22.wMin,
      height: 22.wMin,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF22C55E) : AppTheme.cStaticWhite.color.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(6.wMin),
        border: Border.all(
          color: AppTheme.cStaticWhite.color.withValues(alpha: isSelected ? 0 : 0.85),
          width: 1.wMin,
        ),
      ),
      child: isSelected
          ? Icon(
              Icons.check_rounded,
              size: 16.wMin,
              color: AppTheme.cStaticWhite.color,
            )
          : null,
    );
  }


  Widget _buildNotDataWidget(){
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 150.wMin),
      child: NotDataWidget(
        other: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "没有找到相关内容",
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            Text(
              "换个关键词，或调整筛选条件，再试一次。",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  

}
