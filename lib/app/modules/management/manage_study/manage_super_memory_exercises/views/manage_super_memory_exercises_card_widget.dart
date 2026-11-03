

import 'package:flutter/material.dart';

import 'package:langwise/common/enum/elements_card_type.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../../utils/utils.dart';
import 'package:langwise/app/modules/management/common/manage_cross_fade_widget.dart';
import 'package:langwise/app/modules/management/common/manage_exercises_card_widget.dart';
import 'package:langwise/app/modules/management/common/manage_tag_widget.dart';
import '../../../models/manage_open_model.dart';

class ManageSuperMemoryExercisesCardWidget extends StatelessWidget {
  final ManageExpandModel<SuperMemoryExercisesEntity> entity;
  final void Function()? onToggleExpand;
  final void Function()? onSwitch;
  final void Function()? onAdd;
  final void Function()? onSync;

  final void Function(QuizModel data)? onExerciseDelete;
  final void Function(QuizModel data)? onExerciseSwitch;
  final void Function(QuizModel data)? onExerciseEdit;
  final void Function(QuizModel data)? onPreview;

  const ManageSuperMemoryExercisesCardWidget({
    super.key, 
    required this.entity, 
    this.onToggleExpand,
    this.onSwitch,
    this.onAdd,
    this.onSync,

    this.onExerciseDelete,
    this.onExerciseSwitch,
    this.onExerciseEdit,
    this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: AppTheme.cSurfaceSecondary.color,
        border: Border.all(
          color: AppTheme.cBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardTagsWidget(),
                SizedBox(height: 4.wMin),
                _buildKnowledgeContentWidget(),
                SizedBox(height: 4.wMin),
                _buildDefinitionWidget(),
                SizedBox(height: 4.wMin),
                _buildDateWidget(),
              ],
            ),
          ),
          _buildCandidateExercisesWidget(),
        ],
      ),
    );
  }

  /// 卡片标签栏
  Widget _buildCardTagsWidget(){

    ElementsCardType type = ElementsCardType.fromRawValue(entity.data.type??'');
    ElementsCardColor? statusColor = StatusUtils.getElementsCardColor(entity.data.type);

    List<ElementsCardEntityDatasags?> tags = entity.data.tags??[];
    tags.removeWhere((element) => element == null);

    return Row(
      children: [

        ManageTagFS14Widget(
          tag: type.name,
          bgColor: statusColor?.color1?? Colors.transparent,
        ),
        

        SizedBox(width: 8.wMin),

        Visibility(
          visible: tags.isNotEmpty,
          child: Container(
            margin: EdgeInsets.only(right: 8.wMin),
            child: Row(
              spacing: 8.wMin,
              children: List.generate(tags.length, (index){
                ThemeTextStyleEntity? themeText = StyleUtils.getCurrentThemeText(tags[index]?.style);
                Color? fontColor = ColorUtils.parseColor(themeText?.color);
                Color? backgroundColor = ColorUtils.parseColor(themeText?.backgroundColor);
                return ManageTagFS14Widget(
                  tag: tags[index]?.gloss?.map((e) => e?.text).join(" ")??'',
                  fontColor: fontColor??AppTheme.cTextPrimary.color,
                  bgColor: backgroundColor??AppTheme.cBorderTertiary.color,
                );
            
              }),
            ),
          ),
        ),

        ManageTagFS14Widget(
          tag: "contentId: ${entity.data.uid??''}",
          fontColor: AppTheme.cTextPrimary.color,
        ),

        SizedBox(width: 8.wMin),

        ManageTagFS14Widget(
          tag: "SID: ${entity.data.semanticId??''}",
          fontColor: AppTheme.cTextPrimary.color,
        ),


        SizedBox(width: 8.wMin),

        ManageTagFS14Widget(
          tag: "搜索次数：${entity.data.cnt??0}",
          fontColor: AppTheme.cTextPrimary.color,
        ),
        SizedBox(width: 8.wMin),

        ManageTagFS14Widget(
          tag: entity.data.isResolvedText,
          bgColor: entity.data.isResolvedColor,
        ),

        SizedBox(width: 8.wMin),

        Visibility(
          visible: (entity.data.missingCnt??0) != 0,
          child: ManageTagFS14Widget(
            tag: "缺少题目数：${entity.data.missingCnt??0}",
            bgColor: AppTheme.cSurfaceError.color,
          ),
        ),


        const Spacer(),

        Visibility(
          visible: onSync != null,
          child: ButtonWidget(
            text: "同步",
            width: 80.wMin,
            height: 38.wMin,
            borderRadius: 6.wMin,
            color: AppTheme.cFeedbackSuccessBackground.color,
            fontColor: AppTheme.cFeedbackSuccessText.color,
            fontSize: 18.wMin,
            sclae: 1.05,
            onTap: onSync,
          ),
        ),

        // Visibility(
        //   visible: onSwitch != null,
        //   child: CardSwitchWidget(
        //     width: 50.wMin,
        //     height: 26.wMin,
        //     value: entity.data.isResolved == true,
        //     switchActiveColor: AppTheme.cSurfaceSuccess.color,
        //     switchInactiveColor: AppTheme.cSurfaceQuaternary.color,
        //     onChanged: (value) {
        //       onSwitch?.call();
        //     },
        //   ),
        // ),

        // SizedBox(width: 8.wMin),
        
        // Text(
        //   entity.data.isResolvedText,
        //   style: TextStyle(
        //     color: AppTheme.cTextPrimary.color,
        //     fontSize: 16.wMin,
        //     fontWeight: FontWeight.w400,
        //   ),
        // ),

      ],
    );
  }

  /// 知识点栏
  Widget _buildKnowledgeContentWidget() {

    // List<EnKnowledgeEntityIpaList?> ipaList = entity.data.ipaList??[];

    List<PronunciationsEntity?> pronunciations = entity.data.pronunciations??[];

    return Row(
      spacing: 8.wMin,
      children: [
        
        SelectableText(
          entity.data.content??"",
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),

        Row(
          spacing: 8.wMin,
          children: List.generate(pronunciations.length, (index){
            return AnimationPlayIconTextWidget(
              iconSize: 24.wMin,
              audioUrl: pronunciations[index]?.audioUrl,
              national: pronunciations[index]?.national,
              phonetic: pronunciations[index]?.phonetic,
              nationalTitle: pronunciations[index]?.nationalTitle,
              backgroundImageUrl: pronunciations[index]?.nationalIconUrl,
              childPadding: 4.wMin,
            );
          }),
        ),

      ],
    );
  }

  /// 释义栏
  Widget _buildDefinitionWidget() {
    List<LanguageText?> gloss = entity.data.gloss??[];
    gloss = LearningLangUtils.sortLearningLangFirst(gloss);

    gloss.removeWhere((element) => element?.text == entity.data.content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(gloss.length, (index){
        return SelectableText(
          gloss[index]?.text ?? "",
          style: TextStyle(
            fontSize: index == 0 ? 24.wMin : 18.wMin,
            fontWeight: FontWeight.w400,
            color: index == 0 ? AppTheme.cTextSecondary.color : AppTheme.cTextTertiary.color,
          ),
        );
      }),
    );

  }


  /// 时间栏
  Widget _buildDateWidget(){

    String created = DateFormatUtil.formatStrtoStr(entity.data.created??"", newPattern: "yyyy-MM-dd HH:mm:ss");
    String updated = DateFormatUtil.formatStrtoStr(entity.data.updated??"", newPattern: "yyyy-MM-dd HH:mm:ss");

    return Row(
      spacing: 40.wMin,
      children: [
        Text(
          "创建时间：$created",
          style: TextStyle(
            fontSize: 14.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
        Text(
          "更新时间：$updated",
          style: TextStyle(
            fontSize: 14.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      ],
    );
  }

  /// 包含内容列表
  Widget _buildCandidateExercisesWidget() {
    return ManageCrossFadeWidget(
      isExpanded: entity.isExpanded,
      title: "包含题目 (${entity.data.candidateExercises?.length??0})",
      firstChild: _buildContainListWidget(),
      onToggleExpand: onToggleExpand,
      buttonText: "新建题目",
      onButton: onAdd,
    );
    
  }


  /// 包含的列表
  Widget _buildContainListWidget(){
    List<QuizModel?> candidateExercises = entity.data.candidateExercises??[];
    return GridView.builder(
      itemCount: candidateExercises.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(left: 18.wMin, right: 18.wMin, bottom: 18.wMin),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20.wMin,
        mainAxisSpacing: 20.wMin,
        childAspectRatio: 902 / 458,
      ), 
      itemBuilder: (context, index) {
        final exercise = candidateExercises[index];
        if(exercise == null) return const SizedBox.shrink();
        return ManageExercisesCardWidget(
          exercise: exercise,
          showExercise: entity.isExpanded,
          onDelete: () => onExerciseDelete?.call(exercise),
          onSwitch: () => onExerciseSwitch?.call(exercise),
          onEdit: () => onExerciseEdit?.call(exercise),
          onPreview: () => onPreview?.call(exercise),
        );
      },
    );
  }

  
}
