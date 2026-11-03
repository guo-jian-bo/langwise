import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/platform_backdrop_filter_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../../utils/utils.dart';


class RadarWidget extends StatefulWidget {
  final String lsrwType;
  final AssessmentHistoryItemEntity item;
  const RadarWidget({super.key, required this.lsrwType, required this.item});

  @override
  State<RadarWidget> createState() => _RadarWidgetState();
}

class _RadarWidgetState extends State<RadarWidget> {

  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
      List<AssessmentResultDetailEntityTierSkills?> tierSkills = widget.item.tierSkills??[];

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
  }


  Widget _buildBodyWidget(AssessmentResultDetailEntityTierSkills? skillData){
    if(skillData == null) return Container();

    LSRWStatusColor colors = StatusUtils.getLSRWStatusColor(widget.lsrwType);

    LanguageText? titleLocal = LearningLangUtils.getLocalLang(skillData.title);
    LanguageText? titleLear = LearningLangUtils.getLearningLang(skillData.title);

    LanguageText? comments = LearningLangUtils.getLocalLang(skillData.comments);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.wMin),
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
          PlatformBackdropFilterWidget(
            sigmaX: 5.wMin,
            sigmaY: 5.wMin,
            child: Container(
              width: 407.wMin,
              height: 306.wMin,
              padding: EdgeInsets.all(6.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
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
                          width: 60.wMin,
                          height: 60.wMin,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(4.wMin),
                          ),
                          child: SvgPicture.asset(
                            colors.svg,
                            width: 30.wMin,
                            height: 30.wMin,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.wMin),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleLocal?.text??"",
                            style: TextStyle(
                              fontSize: 30.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextPrimary.color,
                            ),
                          ),
                          Text(
                            titleLear?.text??"",
                            style: TextStyle(
                              fontSize: 20.wMin,
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
                                fontSize: 20.wMin,
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
                  SizedBox(height: 20.wMin),
                  LinearProgressIndicator(
                    value: ((skillData.score??0) / (skillData.maxScore??0)).toDouble(),
                    backgroundColor: AppTheme.cWhiteAlpha10.color,
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(999),
                    minHeight: 12.wMin,
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                  ),
                  SizedBox(height: 20.wMin),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cBlackAlpha20.color,
                        borderRadius: BorderRadius.circular(8.wMin),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 3.wMin, vertical: 3.wMin),
                        child: Text(
                          comments?.text??"",
                          style: TextStyle(
                            fontSize: 20.wMin,
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
