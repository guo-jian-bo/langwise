
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:langwise/app/modules/elements/common/elements_card_search_widget.dart';
import 'package:langwise/app/modules/elements/dialog/elements_card_sort_dialog.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:themed/themed.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../utils/utils.dart';
import '../../common/elements_card_groove.dart';
import '../../common/elements_list_model_widget.dart';
import '../../dialog/elements_card_filter_dialog.dart';
import '../../elements_enums/elements_card_mode.dart';
import '../../model/elements_detils_data_model.dart';
import '../controllers/elements_detils_controller.dart';

class ElementsDetilsView extends GetView<ElementsDetilsController> {
  const ElementsDetilsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GestureDetector(
        onTap: controller.isSearchClick.value ? null : () => FocusScope.of(context).requestFocus(FocusNode()),
        child: LockOverlayWidget(
          rights: controller.rights.value,
          showBack: false,
          child: Scaffold(
            backgroundColor: AppTheme.cBgPrimary.color,
            body: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 24.wMin),
                    Obx(() {
                      if (controller.isLoading.value) return const SizedBox();
                      return buildTabViewWidget();
                    }),
                    SizedBox(height: 12.wMin),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) return const SizedBox();
                        return TabBarView(
                          controller: controller.tabController,
                          children: List.generate(controller.tabListData.length, (index) {
                            return ElementsDetilsCardListWidget(
                              tabData: controller.tabListData[index],
                              key: ValueKey(index),
                            );
                          }),
                        );
                      }),
                    ),
                  ],
                ),
                _buildModeWidget(context),
              ],
            ),
          ),
        ),
      );
    });
  }



  /// 模式切换
  // Widget _buildModeSwitchWidget(){
  //   return Obx((){
  //     if(controller.dictModeList.isEmpty) return const SizedBox();

  //     LinearGradient? currentGradient;
  //     String? dictModeTitle;
  //     for(int i = 0; i < controller.dictModeList.length; i++){
  //       CardDictModeEntityList item = controller.dictModeList[i];
  //       if(item.module == controller.mode.value){
  //         ThemeColorEntity? colors = StyleUtils.getCurrentThemeColors(item.moduleBgColors);
  //         currentGradient = StyleUtils.parseCssLinearGradient(colors?.color);
  //         dictModeTitle = item.title;
  //         break;
  //       }
  //     }

  //     return TapScaleWidget(
  //       onTap: () {
  //         if(controller.mode.value == ElementsCardMode.studyCard){
  //           controller.changeMode(ElementsCardMode.searchCard);
  //         }else{
  //           controller.changeMode(ElementsCardMode.studyCard);
  //         }
  //       },
  //       sclae: 1.02,
  //       child: AnimatedContainer(
  //         duration: const Duration(milliseconds: 300),
  //         width: 128.wMin,
  //         height: 128.wMin,
  //         alignment: Alignment.center,
  //         decoration: BoxDecoration(
  //           shape: BoxShape.circle,
  //           gradient: currentGradient,
  //         ),
  //         child: Text(
  //           dictModeTitle??"",
  //           style: TextStyle(
  //             color: AppTheme.cInverseTextLight.color,
  //             fontSize: 28.wMin,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ),
  //     );

  //   });
  // }

  Widget _buildModeWidget(BuildContext context) {
    return Obx(() {
      if (controller.tabListData.isEmpty) return const SizedBox();
      bool isStudyCard = controller.mode.value == ElementsCardMode.studyCard;
      bool isNotEmpty = true;
      
      if(isStudyCard){
        if(controller.tabListData.length > controller.currentTabIndex.value){
          isNotEmpty = controller.tabListData[controller.currentTabIndex.value].data?.isNotEmpty == true;
        }
      }


      
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        bottom: MediaQuery.of(context).padding.bottom + 10.wMin,
        right: 70.wMin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: isStudyCard && isNotEmpty,
              child: CardLearningButtonsWidget(
                showPreview: false,
                showFlash: false,
                showDownload: false,
                onDictation: () {
                  controller.goDictate();
                },
              ),
            ),
            SizedBox(height: 10.wMin),
            CardLearningStyleButtonWidget(
              onSubmit: () {
                controller.refreshListData(showLoading: false);
              },
            ),
            SizedBox(height: 10.wMin),

            // _buildModeSwitchWidget(),

            ElementsListModelWidget(
              mode: controller.mode.value,
              modeList: controller.dictModeList.toList(),
              filter: controller.startEndCalenderData,
              count: controller.tabListData[controller.currentTabIndex.value].count,
              cardTotal: controller.cardTotal.value,
              dictIsFilter: controller.filterDifficultyList.isNotEmpty || controller.searchInput.text.isNotEmpty,
              dictModeSort: controller.dictModeSort,
              initIsAsc: controller.sortIsAsc,
              initSort: controller.sortData.value,
              onSort: (sort, isAsc) {
                controller.sortCard(sort, isAsc);
              },
              onFilterConfirm: (data) {
                controller.startEndCalenderData = data;
                controller.refreshListData();
              },
              onModeChange: (mode) {
                controller.changeMode(mode);
              },
            ),
          ],
        ),
      );
    });
  }

  Widget buildTabWidget(int index) {
    return TapScaleWidget(
      onTap: () {
        controller.tabController?.animateTo(index);
      },
      sclae: 1,
      child: AnimatedBuilder(
        animation: controller.tabController?.animation ?? const AlwaysStoppedAnimation(0),
        builder: (context, child) {
          int tabIndex = controller.tabController?.index ?? 0;
          double opacity = 0.0;
          Color backgroundColor = AppTheme.cBgQuaternary.color;
          Color textColor = AppTheme.cTextTertiary.color;

          if (tabIndex == index) {
            opacity = 1.0;
            textColor = AppTheme.cTextPrimary.color;
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 10.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: backgroundColor.addOpacity(opacity),
            ),
            child: Text(
              controller.tabListData[index].name,
              style: TextStyle(
                fontSize: 24.wMin,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildTabViewWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.wMin),
      child: Row(
        children: [
          Row(
            spacing: 16.wMin,
            children: List.generate(controller.tabListData.length, (index) {
              return buildTabWidget(index);
            }),
          ),
          // Expanded(
          //   child: _buildFilterWidget(),
          // ),
          const Spacer(),
          _buildFilterWidget(),
          Obx(() {
            String? helpVideoUrl;
            for (int i = 0; i < controller.dictModeList.length; i++) {
              if (controller.mode.value == controller.dictModeList[i].module) {
                helpVideoUrl = controller.dictModeList[i].helpVideoUrl;
                break;
              }
            }
            if (helpVideoUrl == null) return Container();
            return Container(
              margin: EdgeInsets.only(left: 24.wMin),
              child: HelpIVideoIconWidget(helpVideoUrl: helpVideoUrl),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        controller.mode.value == ElementsCardMode.studyCard ? _buildReviewModeFilterWidget() : _buildDictionaryModeFilterWidget(),
        SizedBox(width: 24.wMin),
        const DisplayLanguageFilteringIconWidget(
          isIosAwait: true,
          excludeHiddenText: true,
        ),
        SizedBox(width: 24.wMin),
        ElementsCardSearchWidget(
          controller: controller.searchInput,
          onSearch: (value) {
            controller.searchCard(value);
          },
          onChange: (value) {
            controller.dictModeIsFilter.value = value.isNotEmpty;
          },
          onTap: () {
            if (controller.isSearchClick.value) return;
            controller.isSearchClick.value = true;
            Future.delayed(const Duration(milliseconds: 350), () {
              controller.isSearchClick.value = false;
            });
          },
        ),
      ],
    );
  }

  /// 回顾模式 排序
  Widget _buildReviewModeFilterWidget() {
    return Row(
      key: const ValueKey(0),
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElementsCardSortDialogIconWidget(
          initSort: controller.sortData.value,
          initIsAsc: controller.sortIsAsc,
          sortList: controller.reviewModeSort,
          onSort: (sort, isAsc) {
            controller.sortCard(sort, isAsc);
          },
        ),
      ],
    );
  }

  /// 词典模式 筛选
  Widget _buildDictionaryModeFilterWidget() {
    return Obx(() {
      if (controller.dictModeIsFilter.value) return Container();
      return ElementsCardFilterDialogIconWidget(
        key: const ValueKey(1),
        showDifficulty: controller.mode.value == ElementsCardMode.searchCard,
        showStarRating: controller.mode.value == ElementsCardMode.studyCard,
        initDifficultys: controller.filterDifficultyList.toList(),
        initStarRatings: controller.filterStarRatingList.toList(),
        onFilter: (result) {
          controller.filterDifficultyList = result.difficultyList;
          controller.filterStarRatingList = result.starRatingList;
          controller.refreshListData(showRightCountToast: true);
        },
      );
    });
  }
}

class ElementsDetilsCardListWidget extends StatefulWidget {
  final ElementsDetilsTabModel tabData;
  const ElementsDetilsCardListWidget({super.key, required this.tabData});

  @override
  State<ElementsDetilsCardListWidget> createState() => ElementsDetilsCardListWidgetState();
}

class ElementsDetilsCardListWidgetState extends State<ElementsDetilsCardListWidget> with AutomaticKeepAliveClientMixin {
  final ElementsDetilsController _detilsController = Get.find<ElementsDetilsController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      if (widget.tabData.isNotData.value) {
        return const NotDataWidget(
          message: "这里还没有卡片哦",
        );
      }

      return LockOverlayWidget(
        rights: widget.tabData.rights,
        showBack: false,
        child: GridView.builder(
          itemCount: widget.tabData.data?.length ?? 0,
          controller: widget.tabData.scrollController,
          padding: EdgeInsets.only(
            top: 12.wMin,
            bottom: 150.wMin + MediaQuery.of(context).padding.bottom,
            left: 40.wMin,
            right: 40.wMin,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 24.wMin,
            crossAxisSpacing: 24.wMin,
            childAspectRatio: 346 / 546,
          ),
          itemBuilder: (context, index) {
            return ElementsCardGroove(
              index: index,
              data: widget.tabData.data?[index],
              onPageBack: (type) {
                _detilsController.getDictMode();
              },
              onLongPress: (data, cardKey) {
                data?.key = cardKey;
                _detilsController.showDeleteMask(context, data);
              },
            );
          },
        ),
      );
    });
  }
}
