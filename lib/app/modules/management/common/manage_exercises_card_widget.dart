import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme_quiz_utils.dart';
import '../../../../utils/utils.dart';
import 'manage_tag_widget.dart';

class ManageExercisesCardWidget extends StatelessWidget {
  final QuizModel? exercise;
  final String? exerciseName;
  final String? description;
  /// 是否显示题目的UID
  final bool showUid;
  /// 是否显示题目的上下架
  final bool showAccess;
  /// 是否选中
  final bool selected;
  /// 选择框回调
  final void Function()? onSelect;
  /// 是否是单选
  final bool single;

  final void Function()? onDelete;
  final void Function()? onSwitch;
  /// 编辑按钮的显示是否遵循题目数据的字段editable
  final bool followEditable;
  final void Function()? onEdit;
  final void Function()? onPreview;

  /// 是否显示题目
  final bool showExercise;

  /// 题目卡片
  const ManageExercisesCardWidget({
    super.key, 
    this.exercise, 
    this.onSelect, 
    this.onDelete, 
    this.onSwitch, 
    this.followEditable = true, 
    this.onEdit, 
    this.onPreview,
    this.exerciseName,
    this.description,
    this.showUid = true,
    this.showAccess = true,
    this.selected = false,
    this.single = false,
    this.showExercise = true,
  });

  void showTips(BuildContext ctx) {
    BotToast.showAttachedWidget(
      targetContext: ctx,
      backgroundColor: Colors.transparent,
      onlyOne: true,
      preferDirection: PreferDirection.bottomCenter,
      verticalOffset: 4.wMin,
      attachedBuilder: (cancelFunc) {
        return Container(
          padding: EdgeInsets.all(16.wMin),
          constraints: BoxConstraints(
            minWidth: 200.wMin,
            maxWidth: 900.wMin,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cSurfaceQuaternary.color,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
          ),
          child: Container(
              margin: EdgeInsets.only(top: 8.wMin),
              child: Text(
                description ?? "",
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.cBorderPrimary.color,
          width: 1.wMin,
        ),
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: Column(
        children: [
          _buildHeardWidget(context),
          Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
          Expanded(child: _buildExerciseWidget()),
        ],
      ),
    );
  }


  Widget _buildHeardWidget(BuildContext context){

    // 是否上架
    bool normal = exercise?.accessNormal??false;

    // 选择的svg
    String selectSvg = selected ? "assets/svg/manage/icon_check_box.svg" : "assets/svg/manage/icon_uncheck_box.svg";
    if(single){
      selectSvg = selectSvg = selected ? "assets/svg/manage/icon_radio.svg" : "assets/svg/manage/icon_unradio.svg";
    }

    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Visibility(
                visible: showUid,
                child: Container(
                  margin: EdgeInsets.only(right: 8.wMin),
                  child: ManageTagFS14Widget(
                    tag: "UID: ${exercise?.uid??''}",
                    fontColor: AppTheme.cTextPrimary.color,
                  ),
                ),
              ), 

              ManageTagFS14Widget(
                tag: "configId: ${exercise?.config?.uid??''}",
                fontColor: AppTheme.cTextPrimary.color,
              ),  
              SizedBox(width: 8.wMin),

              Visibility(
                visible: showAccess,
                child: ManageTagFS14Widget(
                  tag: normal ? "上架" : "下架",
                  bgColor: normal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceError.color,
                ),
              ),

              const Spacer(),

              Visibility(
                visible: onSwitch != null,
                child: Row(
                  spacing: 8.wMin,
                  children: [
                    CardSwitchWidget(
                      width: 50.wMin,
                      height: 26.wMin,
                      value: normal,
                      switchActiveColor: AppTheme.cSurfaceSuccess.color,
                      switchInactiveColor: AppTheme.cSurfaceQuaternary.color,
                      onChanged: (value) {
                        onSwitch?.call();
                      },
                    ),
                    Text(
                      normal ? "上架" : "下架",
                      style: TextStyle(
                        color: AppTheme.cTextPrimary.color,
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              Visibility(
                visible: onEdit != null && (exercise?.editable == true || !followEditable),
                child: TapScaleWidget(
                  onTap: onEdit,
                  sclae: 1.1,
                  borderRadius: 4.wMin,
                  backColor: AppTheme.cSurfaceTertiary.color,
                  child: Container(
                    width: 32.wMin,
                    height: 32.wMin,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      "assets/svg/public/icon_edit.svg",
                      width: 20.wMin,
                    ),
                  ),
                ),
              ),

              Visibility(
                visible: onDelete != null,
                child: TapScaleWidget(
                  onTap: onDelete,
                  sclae: 1.1,
                  borderRadius: 4.wMin,
                  backColor: AppTheme.cSurfaceTertiary.color,
                  child: Container(
                    width: 32.wMin,
                    height: 32.wMin,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      "assets/svg/public/icon_delete.svg",
                      width: 20.wMin,
                    ),
                  ),
                ),
              ),

              Visibility(
                visible: onSelect != null,
                child: TapScaleWidget(
                  onTap: onSelect,
                  sclae: 1.1,
                  borderRadius: 4.wMin,
                  backColor: AppTheme.cSurfaceTertiary.color,
                  child: Container(
                    width: 32.wMin,
                    height: 32.wMin,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      selectSvg,
                      width: 20.wMin,
                    ),
                  ),
                ),
              ),
              
            ],
          ),

          SizedBox(height: 4.wMin),

          Text(
            exerciseName ?? (exercise?.type??""),
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),

          Visibility(
            visible: description != null,
            child: Builder(
              builder: (ctx) {
                return MouseRegion(
                  onEnter: (event) {
                    showTips(ctx);
                  },
                  onExit: (event) {
                    BotToast.cleanAll();
                  },
                  child: Text(
                    description ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                );
              },
            ),
          ),


        ],
      ),
    );
  }


  /// 题目
  Widget _buildExerciseWidget(){
    String? stemName = QuizDeformationUtils.typeNameMap[exercise?.config?.stemDisplay ?? ""];
    String? optionName = QuizDeformationUtils.typeNameMap[exercise?.config?.optionDisplay ?? ""];
    String? inputModel = QuizDeformationUtils.typeNameMap[exercise?.config?.inputMode ?? ""];
    String? breakdownLevel = QuizDeformationUtils.typeNameMap[exercise?.config?.breakdownLevel ?? ""];
    int? optionCount = exercise?.config?.optionCount;

    String? preTeaching;
    if(exercise?.config?.preTeaching != null){
      preTeaching = exercise?.config?.preTeaching == true ? "是" : "否";
    }

    String? stemAudio;
    if(exercise?.config?.stemAudio != null){
      stemAudio = exercise?.config?.stemAudio == true ? "是" : "否";
    }

    String? optionAudio;
    if(exercise?.config?.optionAudio != null){
      optionAudio = exercise?.config?.optionAudio == true ? "是" : "否";
    }

    String? questionAudio;
    if(exercise?.config?.questionAudio != null){
      questionAudio = exercise?.config?.questionAudio == true ? "是" : "否";
    }

    String? followSentence;
    if(exercise?.config?.followSentence != null){
      followSentence = exercise?.config?.followSentence == true ? "是" : "否";
    }

    String? highlight;
    if(exercise?.config?.highlight != null){
      highlight = exercise?.config?.highlight == true ? "是" : "否";
    }
    
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Row(
        spacing: 20.wMin,
        children: [
          

          Column(
            spacing: 8.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "预览模式",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),

              Expanded(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Visibility(
                    visible: showExercise,
                    child: TapScaleWidget(
                      onTap: onPreview,
                      sclae: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.cBorderPrimary.color,
                            width: 1.wMin,
                          ),
                          borderRadius: BorderRadius.circular(8.wMin),
                        ),
                        child: QuizPublicQuizWidget(
                          borderRadius: 8.wMin,
                          data: exercise,
                          quizPlayStyle: ThemeQuizUtils.getQuizPlayStyle(),
                          bgColor: AppTheme.cBgSolid.color,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "配置项信息",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        _buildRowText("显示模式", "题干=$stemName,选项=$optionName"),
                        _buildRowText("选项数", optionCount?.toString()),
                        _buildRowText("输入方式", inputModel),
                        _buildRowText("拆分等级", breakdownLevel),
                        _buildRowText("预先学习", preTeaching),
                        _buildRowText("题干发音", stemAudio),
                        _buildRowText("选项发音", optionAudio),
                        _buildRowText("问题发音", questionAudio),
                        _buildRowText("逐句显示", followSentence),
                        _buildRowText("是否高亮", highlight),

                      ],
                    ),
                  ),
                ),



              ],
            ),
          ),



        ],
      ),
    );
  }

  Widget _buildRowText(String name, String? value) {
    if(value == null) return Container();
    return Container(
      margin: EdgeInsets.only(top: 10.wMin),
      child: Row(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}