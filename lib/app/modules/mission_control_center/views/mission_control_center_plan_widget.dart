
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../theme/theme.dart';
import '../../../routes/routes.dart';
import '../common/mission_control_center_hexagon_paint.dart';
import '../common/mission_control_center_plan_menu_dialog.dart';

class MissionControlCenterPlanWidget extends StatefulWidget {
  final TaskMissionEntityMissionUnits planCourse;
  const MissionControlCenterPlanWidget({super.key, required this.planCourse});

  @override
  State<MissionControlCenterPlanWidget> createState() => _MissionControlCenterPlanWidgetState();
}

class _MissionControlCenterPlanWidgetState extends State<MissionControlCenterPlanWidget> with TickerProviderStateMixin{

  late final AnimationController _progressController;

  double _progress = 0.0;

  @override
  void initState(){
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    ); 


    _progress = (widget.planCourse.unitProgress ?? 0);
    setProgress(_progress);
  }

  @override
  void didUpdateWidget(covariant MissionControlCenterPlanWidget oldWidget){
    super.didUpdateWidget(oldWidget);
    if(oldWidget.planCourse.unitProgress != widget.planCourse.unitProgress){
      _progress = (widget.planCourse.unitProgress ?? 0);
      setProgress(_progress);
    }
  }


  Future<void> setProgress(double progress) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if(!mounted) return;
    await _progressController.animateTo(
      progress, 
      duration: const Duration(milliseconds: 800),
    );
    if(mounted) setState(() {});
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }


  void showPlanMenuDialog(BuildContext ctx){
    MissionControlCenterPlanMenuDialog.show(
      ctx: ctx,
      onPreview: toPreviewPage,
      onDictation: toDictationPage,
      onBrowseCourse: toBrowseCoursePage,
    );
  }

  /// 跳转计划列表页
  Future<void> toPlanListPage() async{
    await TagRoutes.toNamed(Routes.STUDY_PLAN);
    
  }

  /// 去预习
  Future<void> toPreviewPage() async{
    try {
      ToastUtils.showLoading();
      int? courseId = widget.planCourse.courseId;
      int? levelId = widget.planCourse.levelId;
      int? moduleId = widget.planCourse.moduleId;
      int? unitId = widget.planCourse.unitId;
      if(courseId == null || levelId == null || moduleId == null || unitId == null) return;
      UnitKnowledgePointsEntity? entity = await OfficialCourseDetailsRequest.getUnitTarget(
        courseId,
        moduleId,
        unitId,
      );
      if(entity == null) return;

      List<UnitKnowledgePointsEntityKnowledgeList?>? list = entity.knowledgeList;
      if (list == null) return;
      List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = [];

      for (int i = 0; i < list.length; i++) {
        UnitKnowledgePointsEntityKnowledgeList? item = list[i];
        if (item == null) continue;
        if (item.isWord) knowledgeList.add(item);
        if (item.isPhrase) knowledgeList.add(item);
        if (item.isSentence) knowledgeList.add(item);
        if (item.isText) knowledgeList.add(item);
      }
      
      if (knowledgeList.isEmpty) return;

      TagRoutes.toNamed(Routes.OFFICIAL_COURSE_DETAILS_PREVIEW, arguments: {
        "unitName": widget.planCourse.unitName,
        "knowledgeList": knowledgeList,
      });

    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 去听写
  Future<void> toDictationPage() async{
    try {
      ToastUtils.showLoading();
      int? courseId = widget.planCourse.courseId;
      int? levelId = widget.planCourse.levelId;
      int? moduleId = widget.planCourse.moduleId;
      int? unitId = widget.planCourse.unitId;
      if(courseId == null || levelId == null || moduleId == null || unitId == null) return;
      UnitKnowledgePointsEntity? entity = await OfficialCourseDetailsRequest.getUnitTarget(
        courseId,
        moduleId,
        unitId,
      );
      if(entity == null) return;

      List<UnitKnowledgePointsEntityKnowledgeList?>? list = entity.knowledgeList;
      if (list == null) return;
      List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = [];

      for (int i = 0; i < list.length; i++) {
        UnitKnowledgePointsEntityKnowledgeList? item = list[i];
        if (item == null) continue;
        if (item.isWord) knowledgeList.add(item);
        if (item.isPhrase) knowledgeList.add(item);
        if (item.isSentence) knowledgeList.add(item);
        if (item.isText) knowledgeList.add(item);
      }
      
      if (knowledgeList.isEmpty) return;

      TagRoutes.toNamed(Routes.OFFICIAL_COURSE_DETAILS_DICTATION, arguments: {
        "unitName": widget.planCourse.unitName,
        "knowledgeList": knowledgeList,
      });

    } finally {
      ToastUtils.hideLoading();
    }
  }
  
  /// 浏览课程
  Future<void> toBrowseCoursePage() async{
    TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS,
      arguments: {
        "courseId": widget.planCourse.courseId,
        "levelId": widget.planCourse.levelId,
        "moduleId": widget.planCourse.moduleId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500.wMin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHexagonWidget(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                TapScaleWidget(
                  onTap: () {
                    toPlanListPage();
                  },
                  sclae: 1.01,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: 250.wMin,
                        ),
                        child: Text(
                          widget.planCourse.courseName??"",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 22.wMin,
                            color: AppTheme.cTextPrimary.color,
                          ),
                        ),
                      ),
                      SvgPicture.asset(
                        "assets/svg/public/icon_w_arrow_right.svg",
                        width: 32.wMin,
                        colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                      ),
                    ],
                  ),
                ),
            
                SizedBox(height: 2.wMin),
                
                Text(
                  "当前进度 ${widget.planCourse.levelIndex ?? 0} / ${widget.planCourse.levelCount ?? 0}",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            
                SizedBox(height: 16.wMin),
            
                Text(
                  widget.planCourse.moduleName??'',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                
              ],
            ),
          ),
          
        ],
      ),
    );
  }

  /// 六角形
  Widget _buildHexagonWidget(){
    return Builder(
      builder: (ctx) {
        return TapScaleWidget(
          onTap: () => showPlanMenuDialog(ctx),
          sclae: 1.01,
          child: SizedBox(
            width: 160.wMin,
            height: 160.wMin,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(160.wMin, 160.wMin),
                  painter: MissionControlCenterHexagonPaint(
                    borderWidth: 8.wMin,
                    progressAnimation: _progressController,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                      child: Text(
                        widget.planCourse.unitName??"",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20.wMin,
                          color: AppTheme.cStaticWhite.color,
                        ),
                      ),
                    ),
                    Text(
                      "${(_progress * 100).toInt()}%",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 24.wMin,
                        color: AppTheme.cStaticWhite.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }


}
