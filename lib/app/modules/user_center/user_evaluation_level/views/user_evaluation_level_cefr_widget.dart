import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../controllers/user_evaluation_level_controller.dart';


class UserEvaluationLevelCefrWidget extends GetView<UserEvaluationLevelController> {
  /// CEFR
  final String tagText;
  const UserEvaluationLevelCefrWidget({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {

    return Obx((){
      String? lastAssessment = controller.resultDetail.value.lastAssessment;
      String date = DateFormatUtil.formatStrtoStr(lastAssessment);
      String? showDate;
      if(date.isNotEmpty){
        showDate = "评测时间：$date";
      }
      
      return Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cBgSecondary.color.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(40.wMin),
        ),
        child: Column(
          children: [
            EvaluationTitleWidget(
              title: "CEFR等级认证", 
              subTitle: "你的英语水平评估结果" + (showDate == null ? "" : "\n$showDate"),
            ),
            SizedBox(height: 24.wMin),
            _buildMemberInfoWidget(),
            SizedBox(height: 24.wMin),
            _buildLevelWidget(),
            SizedBox(height: 50.wMin),
            _buildCefrBarChartWidget(),
          ],
        ),
      );
    });
  }

  /// 用户信息
  Widget _buildMemberInfoWidget(){

    UserInfoEntity userInfo = UserStore.to.userInfo.value;
    String? memberName = userInfo.memberName;
    int? memberGrade = userInfo.memberGrade;
    String? gradeName;
    int? memberAge = userInfo.memberAge;
    if(memberGrade != null){
      gradeName = StaticData.gradeList.firstWhere((element) => element.value == memberGrade.toString()).name;
    }

    TextStyle _style = TextStyle(
      fontSize: 36.wMin,
      fontWeight: FontWeight.w600,
      color: AppTheme.cTextPrimary.color,
    );

    List<Widget> infoWidgets = [];

    if(memberName != null){
      infoWidgets.add(Text(memberName, style: _style));
    }
    
    if(memberAge != null){
      infoWidgets.add(Container(width: 2.wMin, height: 26.wMin, color: AppTheme.cTextQuaternary.color));
      infoWidgets.add(Text("年龄：$memberAge岁", style: _style));
    }
    
    if(gradeName != null){
      infoWidgets.add(Container(width: 2.wMin, height: 26.wMin, color: AppTheme.cTextQuaternary.color));
      infoWidgets.add(Text("年级：$gradeName", style: _style));
    }

    if(infoWidgets.isEmpty){
      return const SizedBox();
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 32.wMin),
      child: Row(
        spacing: 32.wMin,
        mainAxisSize: MainAxisSize.min,
        children: infoWidgets,
      ),
    );
  }
  

  Widget _buildLevelWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 30.wMin,
      children: [
        SvgPicture.asset(
          "assets/svg/public/icon_union_left.svg",
          height: 240.wMin,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: Container(
            constraints: BoxConstraints(
              minHeight: 300.wMin,
            ),
            child: Obx((){
              if(controller.resultDetail.value.tier == null) return const SizedBox();
              return FutureBuilder<bool>(
                initialData: false,
                future: Future.delayed(const Duration(milliseconds: 300), (){
                  return true;
                }),
                builder: (context, snapshot) {
                  if(!(snapshot.data??false)) return const SizedBox();
                  return Column(
                    children: [
                      Text(
                        "Level ${controller.resultDetail.value.tier??0}",
                        style: TextStyle(
                          fontSize: 120.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextPrimary.color,
                          height: 1.15,
                        ),
                      ),
                
                      Text(
                        "CEFR ${controller.resultDetail.value.cefr??""}",
                        style: TextStyle(
                          fontSize: 40.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                      
                      Visibility(
                        visible: controller.resultDetail.value.cambridge?.isNotEmpty??false,
                        child: Column(
                          children: [
                            SizedBox(height: 10.wMin),
                            _buildTBLineWidget(),
                            SizedBox(height: 4.wMin),
                            Column(
                              children: List.generate(controller.resultDetail.value.cambridge?.length??0, (index){
                                if(controller.resultDetail.value.cambridge?[index] == null) return const SizedBox();
                                return Text(
                                  "相当于 ${controller.resultDetail.value.cambridge?[index]??""}",
                                  style: TextStyle(
                                    fontSize: 36.wMin,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.cTextSecondary.color,
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 4.wMin),
                            _buildTBLineWidget(),
                            SizedBox(height: 20.wMin),
                          ],
                        ),
                      ),
                
                    ],
                  );
                },
              );
            }),
          ),
        ),
        SvgPicture.asset(
          "assets/svg/public/icon_union_right.svg",
          height: 240.wMin,
        ),

      ],
    );
  }


  Widget _buildCefrBarChartWidget(){
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        return Obx((){
          List<AssessmentResultDetailEntityTierInfos?> tierInfos = controller.resultDetail.value.tierInfos??[];
          
          List<AssessmentResultDetailEntityTierInfos?> tierInfosList = tierInfos.where((element) => element?.disable == false).toList();
          List<AssessmentResultDetailEntityTierInfos?> tierInfosDisableList = tierInfos.where((element) => element?.disable == true).toList();

          double itemWidth = (width - (tierInfos.length - 1) * 24.wMin) / tierInfos.length;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 24.wMin,
            children: [
              Row(
                spacing: 24.wMin,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(tierInfosList.length, (index){
                  AssessmentResultDetailEntityTierInfosScoreRange? scoreRange = tierInfosList[index]?.scoreRange;
                  return CefrBarChartWidget(
                    height: 350.wMin + index * 50.wMin,
                    width: itemWidth,
                    selected: tierInfosList[index]?.current??false,
                    cefr: tierInfosList[index]?.cefr,
                    subTitle: "L${tierInfosList[index]?.tier?.min??0}-L${tierInfosList[index]?.tier?.max??0}",
                    scoreRange: "${scoreRange?.min??0}-${scoreRange?.max??0}",
                    child: _buildCefrBarChartItemWidget(tierInfosList[index]),
                  );
                }),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    spacing: 24.wMin,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(tierInfosDisableList.length, (index){
                      AssessmentResultDetailEntityTierInfosScoreRange? scoreRange = tierInfosDisableList[index]?.scoreRange;
                      return CefrBarChartWidget(
                        height: 350.wMin + (index + tierInfosList.length) * 50.wMin,
                        width: itemWidth,
                        selected: tierInfosDisableList[index]?.current??false,
                        cefr: tierInfosDisableList[index]?.cefr,
                        subTitle: "L${tierInfosDisableList[index]?.tier?.min??0}-L${tierInfosDisableList[index]?.tier?.max??0}",
                        scoreRange: "${scoreRange?.min??0}-${scoreRange?.max??0}",
                        isDisable: true,
                        child: _buildCefrBarChartItemWidget(tierInfosDisableList[index]),
                        
                      );
                    }),
                  ),
                  Container(
                    width: 90.wMin,
                    height: 90.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cBlackAlpha50.color,
                    ),
                    child: SvgPicture.asset(
                      "assets/svg/public/icon_lock_blank.svg",
                      height: 48.wMin,
                    ),
                  ),
                  
              
                ],
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildCefrBarChartItemWidget(AssessmentResultDetailEntityTierInfos? data){

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCefrBarChartTextItemWidget(data?.cambridgeList),
        _buildCefrBarChartTextItemWidget([data?.ielts]),
        _buildCefrBarChartTextItemWidget([data?.vocabulary]),
      ],
    );
  }

  Widget _buildCefrBarChartTextItemWidget(List<AssessmentResultDetailEntityTierInfosTitleDesc?>? list){
    if(list == null) return Container();
    if(list.isEmpty) return Container();

    return Container(
      margin: EdgeInsets.only(top: 10.wMin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(list.length, (index){
          return Column(
            children: [
              Visibility(
                visible: list[index]?.title != null,
                child: Text(
                  list[index]?.title??"",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cStaticWhite.color,
                  ),
                ),
              ),
              Visibility(
                visible: list[index]?.describe != null,
                child: Text(
                  list[index]?.describe??"",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cStaticWhite.color.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );

  }


  Widget _buildTBLineWidget(){
    return Container(
      width: 212.wMin,
      height: 1.wMin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppTheme.cBgBrand.color.withValues(alpha: 0),
            AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
            AppTheme.cBgBrand.color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

    

}


