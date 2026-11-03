

import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/public_controller/config_controller.dart';
import '../../../../utils/utils.dart';


class ElementsCardFilterResult{
  final List<int> starRatingList;
  final List<int> difficultyList;
  ElementsCardFilterResult({required this.starRatingList, required this.difficultyList});
}

class ElementsCardFilterDialogIconWidget extends StatefulWidget {
  final bool showDifficulty;
  final bool showStarRating;
  final List<int>? initDifficultys;
  final List<int>? initStarRatings;
  final void Function(ElementsCardFilterResult result)? onFilter;
  const ElementsCardFilterDialogIconWidget({
    super.key, 
    this.showDifficulty = true, 
    this.showStarRating = true,
    this.initDifficultys, 
    this.initStarRatings, 
    this.onFilter,
  });

  @override
  State<ElementsCardFilterDialogIconWidget> createState() => _ElementsCardFilterDialogIconWidgetState();
}

class _ElementsCardFilterDialogIconWidgetState extends State<ElementsCardFilterDialogIconWidget> {
  
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return TapScaleWidget(
          sclae: 1.1,
          onTap: () async{
            if(Platform.isIOS){
              await Future.delayed(const Duration(milliseconds: 350));
            }
            BotToast.showAttachedWidget(
              targetContext: context,
              preferDirection: PreferDirection.bottomLeft,
              attachedBuilder: (cancelFunc) {
                return ElementsCardFilterDialogIconBodyWidget(
                  showDifficulty: widget.showDifficulty,
                  showStarRating: widget.showStarRating,
                  cancelFunc: cancelFunc,
                  initDifficultys: widget.initDifficultys,
                  initStarRatings: widget.initStarRatings,
                  onFilter: widget.onFilter,
                );
              },
            );
          },
          child: Container(
            width: 54.wMin,
            height: 54.wMin,
            color: Colors.transparent,
            alignment: Alignment.center,
            child: Stack(
              children: [
                SvgPicture.asset(
                  "assets/svg/elements/icon_filter.svg",
                  width: 40.wMin,
                  height: 40.wMin,
                  colorFilter: const ColorFilter.mode(AppTheme.cTextPrimary, BlendMode.srcIn),
                ),
                Visibility(
                  visible: (widget.initDifficultys?.isNotEmpty??false) || (widget.initStarRatings?.isNotEmpty??false),
                  child: Positioned(
                    bottom: 2.wMin,
                    right: 4.wMin,
                    child: Container(
                      width: 6.wMin,
                      height: 6.wMin,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.cFeedbackSuccessIcon.color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  
}

class ElementsCardFilterDialogIconBodyWidget extends StatefulWidget {
  final bool showDifficulty;
  final bool showStarRating;
  final List<int>? initDifficultys;
  final List<int>? initStarRatings;
  final void Function(ElementsCardFilterResult result)? onFilter;
  final void Function() cancelFunc;
  const ElementsCardFilterDialogIconBodyWidget({
    super.key, 
    this.showDifficulty = true, 
    this.showStarRating = true,
    required this.cancelFunc, 
    this.initDifficultys, 
    this.initStarRatings, 
    this.onFilter,
  });

  @override
  State<ElementsCardFilterDialogIconBodyWidget> createState() => _ElementsCardFilterDialogIconBodyWidgetState();
}

class _ElementsCardFilterDialogIconBodyWidgetState extends State<ElementsCardFilterDialogIconBodyWidget> with WidgetsBindingObserver{
  List<int> selectStarRatingList = [];
  List<int> selectDifficultyList = [];

  final ConfigController configController = Get.find<ConfigController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if(widget.initDifficultys != null){
      selectDifficultyList.addAll(widget.initDifficultys!);
    }
    if(widget.initStarRatings != null){
      selectStarRatingList.addAll(widget.initStarRatings!);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if(Platform.isLinux || Platform.isWindows || Platform.isMacOS){
      widget.cancelFunc();
    }
  }


  @override
  Widget build(BuildContext context) {
    
    final configEntity = configController.appConfig.value;
    List<DifficultieEntity>? difficultyList = DifficultieUtils.getDifficultieList(configEntity, configController.userSetting.value.learningLang);
    
    // 对于卡片难度等级来说 没有pro a1
    if((difficultyList??[]).isNotEmpty){
      for(int i = 0; i < difficultyList!.length; i++){
        if(difficultyList[i].level == 0){
          difficultyList.removeAt(i);
          break;
        }
      }
    }


    return Container(
      width: 550.wMin,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgTertiary,
        borderRadius: BorderRadius.circular(16.wMin),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cDark.color,
            blurRadius: 4.wMin,
            offset: Offset(0, 2.wMin),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "条件筛选",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Visibility(
            visible: widget.showStarRating,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.wMin),
                Text(
                  "星级",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 8.wMin),
                Wrap(
                  spacing: 12.wMin,
                  runSpacing: 12.wMin,
                  children: List.generate(5, (index){
                    return _buildStarRatingItemWidget(index);
                  }),
                ),
              ],
            ),
          ),
          Visibility(
            visible: widget.showDifficulty,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.wMin),
                Visibility(
                  visible: difficultyList != null && difficultyList.isNotEmpty,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "难度",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4.wMin),
                      Wrap(
                        spacing: 12.wMin,
                        runSpacing: 12.wMin,
                        children: List.generate(difficultyList!.length, (index){
                          return _buildDifficultyItemWidget(difficultyList[index]);
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.wMin),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ButtonWidget(
                text: "重置",
                sclae: 1.03,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 8.wMin),
                color: AppTheme.cFeedbackDefaultBackground,
                borderRadius: 8.wMin,
                fontColor: AppTheme.cFeedbackDefaultText,
                fontSize: 24.wMin,
                onTap: () {
                  selectStarRatingList.clear();
                  selectDifficultyList.clear();
                  if(mounted) setState(() {});
                },
              ),
              ButtonWidget(
                text: "确定",
                sclae: 1.03,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 8.wMin),
                color: AppTheme.cBgBrand,
                borderRadius: 8.wMin,
                fontColor: AppTheme.cStaticWhite,
                fontSize: 24.wMin,
                onTap: () {
                  widget.onFilter?.call(ElementsCardFilterResult(starRatingList: selectStarRatingList, difficultyList: selectDifficultyList));
                  widget.cancelFunc();
                },
              ),
            ],
          ),

          
          
        ],
      ),
    );
  }

  Widget _buildDifficultyItemWidget(DifficultieEntity item){
    return TapScaleWidget(
      onTap: () {
        if(item.level == null) return;
        if(selectDifficultyList.contains(item.level)){
          selectDifficultyList.remove(item.level);
        }else{
          selectDifficultyList.add(item.level!);
        }
        if(mounted) setState(() {});
      },
      sclae: 1,
      child: StatusTagDifficultyWidget(
        difficulty: item.level,
        fontSize: 28.wMin,
        language: item.name?.lang,
        padding: EdgeInsets.symmetric(horizontal: 10.9.wMin, vertical: 2.wMin),
        defaultColor: selectDifficultyList.contains(item.level) ? null : AppTheme.cFeedbackDefaultBackground,
        fontColor: selectDifficultyList.contains(item.level) ? null : AppTheme.cFeedbackDefaultText,
      ),
    );
  }


  Widget _buildStarRatingItemWidget(int index){
    return TapScaleWidget(
      onTap: () {
        if(selectStarRatingList.contains(index + 1)){
          selectStarRatingList.remove(index + 1);
        }else{
          selectStarRatingList.add(index + 1);
        }
        if(mounted) setState(() {});
      },
      sclae: 1,
      child: Container(
        width: 94.wMin,
        height: 46.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.cFeedbackDefaultBackground,
          borderRadius: BorderRadius.circular(4.wMin),
        ),
        child: Row(
          spacing: 8.wMin,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${index + 1}",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cFeedbackDefaultText,
                fontWeight: FontWeight.w500,
              ),
            ),
            SvgPicture.asset(
              selectStarRatingList.contains(index + 1) ? "assets/svg/elements/icon_y_sart.svg" : "assets/svg/elements/icon_g_sart.svg",
              width: 24.wMin,
              height: 24.wMin,
            ),
          ],
        ),
      ),
    );
  }
}