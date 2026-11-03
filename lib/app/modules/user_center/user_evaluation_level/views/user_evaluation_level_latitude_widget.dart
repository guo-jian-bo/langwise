
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../controllers/user_evaluation_level_controller.dart';

class UserEvaluationLevelLatitudeWidget extends GetView<UserEvaluationLevelController> {
  /// 技能纬度分析
  final String tagText;
  const UserEvaluationLevelLatitudeWidget({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgSecondary.color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(40.wMin),
      ),
      child: Column(
        children: [
          const EvaluationTitleWidget(title: "技能维度分析", subTitle: "四大英语核心技能评估"),

          Row(
            children: [
              Column(
                spacing: 150.wMin,
                children: [
                  UserEvaluationLevelLatitudeCardWidget(lsrwType: LSRWEnum.listening, tagText: tagText),
                  UserEvaluationLevelLatitudeCardWidget(lsrwType: LSRWEnum.speaking, tagText: tagText),
                ],
              ),
              Expanded(
                child: _buildRadarWidget(context),
              ),
              Column(
                spacing: 150.wMin,
                children: [
                  UserEvaluationLevelLatitudeCardWidget(lsrwType: LSRWEnum.reading, tagText: tagText),
                  UserEvaluationLevelLatitudeCardWidget(lsrwType: LSRWEnum.writing, tagText: tagText),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadarWidget(BuildContext context){
    return Obx((){
      List<AssessmentResultDetailEntityTierSkills?> tierSkills = controller.resultDetail.value.tierSkills??[];

      AssessmentResultDetailEntityTierSkills? listeningSkillData = tierSkills.firstWhereOrNull((element) => element?.skill == LSRWEnum.listening);
      AssessmentResultDetailEntityTierSkills? speakingSkillData = tierSkills.firstWhereOrNull((element) => element?.skill == LSRWEnum.speaking);
      AssessmentResultDetailEntityTierSkills? readingSkillData = tierSkills.firstWhereOrNull((element) => element?.skill == LSRWEnum.reading);
      AssessmentResultDetailEntityTierSkills? writingSkillData = tierSkills.firstWhereOrNull((element) => element?.skill == LSRWEnum.writing);
      
      return Container(
        height: 650.wMin,
        alignment: Alignment.center,
        child: GestureDetector(
          onTapUp: (details) {
            print(details.localPosition);
          },
          child: Container(
            color: Colors.transparent,
            child: IgnorePointer(
              ignoring: true,
              child: ChartWidget(
                coordinateRender: ChartCircularCoordinateRender(
                  borderColor: Colors.transparent,
                  animationDuration: const Duration(milliseconds: 500),
                  strokeCap: StrokeCap.round,
                  charts: [
                    CustomizeRadar<int>(
                      startAngle: pi / 0.8,
                      lineWidth: 1.wMin,
                      dataLineWidth: 3.wMin,
                      showPoints: true,
                      pointRadius: 8.wMin,
                      pointBorderWidth: 4.wMin,
                      pointBorderColor: AppTheme.cStaticWhite.color,
                      count: 5,
                      lineTextStyle: TextStyle(
                        fontSize: 16.wMin,
                        color: AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w400,
                      ),
                      onPointData: (_pointHitAreas) {
                        if(_pointHitAreas.isNotEmpty){
                          print(_pointHitAreas.first.first.center);
                        }
                      },
                      max: listeningSkillData?.maxScore??100,
                      data: [
                        listeningSkillData?.score??0,
                        readingSkillData?.score??0,
                        writingSkillData?.score??0,
                        speakingSkillData?.score??0,
                      ], // 听读说写
                      valueFormatter: (item) => [
                        item.toString(),
                      ],
                      values: (item) => [item],
                      lineColor: AppTheme.cBorderSecondary.color,
                      fillColors: [AppTheme.cSurfaceBrand.color.withValues(alpha: 0.3)],
                      legendTextStyle: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }



}

class UserEvaluationLevelLatitudeCardWidget extends StatefulWidget {
  final String lsrwType;
  final String tagText;
  const UserEvaluationLevelLatitudeCardWidget({super.key, required this.lsrwType, required this.tagText});

  @override
  State<UserEvaluationLevelLatitudeCardWidget> createState() => _UserEvaluationLevelLatitudeCardWidgetState();
}

class _UserEvaluationLevelLatitudeCardWidgetState extends State<UserEvaluationLevelLatitudeCardWidget> {
  late final UserEvaluationLevelController controller;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<UserEvaluationLevelController>(tag: widget.tagText);
  }

  @override
  Widget build(BuildContext context) {
    return Obx((){
      List<AssessmentResultDetailEntityTierSkills?> tierSkills = controller.resultDetail.value.tierSkills??[];

      AssessmentResultDetailEntityTierSkills? skillData = tierSkills.firstWhereOrNull((element) => element?.skill == widget.lsrwType);
      
      if(skillData == null) return Container();
      
      return MouseRegion(
        onEnter: (event) {
          _isHovered = true;
          if(mounted) setState(() {});
        },
        onExit: (event) {
          _isHovered = false;
          if(mounted) setState(() {});
        },
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1,
          duration: const Duration(milliseconds: 300),
          child: GestureDetector(
            onTapDown: (details) {
              _isHovered = true;
              if(mounted) setState(() {});
            },
            onTapUp: (details) {
              _isHovered = false;
              if(mounted) setState(() {});
            },
            onTapCancel: () {
              _isHovered = false;
              if(mounted) setState(() {});
            },
            child: _buildBodyWidget(skillData),
          ),
        ),
      );
    });
  }


  Widget _buildBodyWidget(AssessmentResultDetailEntityTierSkills? skillData){
    if(skillData == null) return Container();

    LSRWStatusColor colors = StatusUtils.getLSRWStatusColor(widget.lsrwType);

    LanguageText? titleLocal = LearningLangUtils.getLocalLang(skillData.title);
    LanguageText? titleLear = LearningLangUtils.getLearningLang(skillData.title);

    LanguageText? comments = LearningLangUtils.getLocalLang(skillData.comments);

    return ClipRRect(
      borderRadius: BorderRadius.circular(32.wMin),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: _isHovered ? 0 : 200.wMin,
            top: _isHovered ? 0 : (94.wMin / 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isHovered ? 200.wMin : 94.wMin,
              height: _isHovered ? 200.wMin : 94.wMin,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: _isHovered ? 0.4 : 0),
                    blurRadius: 200.wMin,
                  ),
                ],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.wMin, sigmaY: 5.wMin),
            child: Container(
              width: 557.wMin,
              height: 376.wMin,
              padding: EdgeInsets.all(24.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32.wMin),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.bg1.withValues(alpha: 0.4),
                    colors.bg2.withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      AnimatedScale(
                        scale: _isHovered ? 1.08 : 1,
                        duration: const Duration(milliseconds: 250),
                        child: Container(
                          width: 94.wMin,
                          height: 94.wMin,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(16.wMin),
                          ),
                          child: SvgPicture.asset(
                            colors.svg,
                            width: 48.wMin,
                            height: 48.wMin,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.wMin),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleLocal?.text??"",
                            style: TextStyle(
                              fontSize: 36.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextPrimary.color,
                            ),
                          ),
                          Text(
                            titleLear?.text??"",
                            style: TextStyle(
                              fontSize: 24.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextSecondary.color,
                            ),
                          )
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          AnimatedScale(
                            scale: _isHovered ? 1.15 : 1,
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              "${skillData.score??0}",
                              style: TextStyle(
                                fontSize: 26.wMin,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.cTextPrimary.color,
                              ),
                            ),
                          ),
                          Text(
                            " / ${skillData.maxScore??0}",
                            style: TextStyle(
                              fontSize: 20.wMin,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.cTextSecondary.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24.wMin),
                  LinearProgressIndicator(
                    value: ((skillData.score??0) / (skillData.maxScore??0)).toDouble(),
                    backgroundColor: AppTheme.cWhiteAlpha10.color,
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(999),
                    minHeight: 16.wMin,
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                  ),
                  SizedBox(height: 24.wMin),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cBlackAlpha20.color,
                        borderRadius: BorderRadius.circular(8.wMin),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 12.wMin),
                        child: Text(
                          comments?.text??"",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextPrimary.color,
                          ),
                        ),
                      ),
                    ),
                  ),
            
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}
