
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import '../entities/entities.dart';
import '../https/https.dart';
import 'widgets.dart';

enum OperateCoustomCourseDialogType{
  addModule,
  addLevel,
  editCourse,
}

class OperateCoustomCourseDialogResult{
  int? levelId;
  OperateCoustomCourseDialogType type;

  OperateCoustomCourseDialogResult({
    this.levelId,
    required this.type,
  });
}

class OperateCoustomCourseDialog{

  static Future<OperateCoustomCourseDialogResult?> show({
    required BuildContext context,
    required int courseId,
    int? initLevelId,
  }) async{

    return await showCupertinoDialog<OperateCoustomCourseDialogResult?>(
      context: context,
      builder: (context){
        return OperateCoustomCourseDialogWidget(courseId: courseId, initLevelId: initLevelId);
      },
    );

  }

}

class OperateCoustomCourseDialogWidget extends StatefulWidget {
  final int courseId;
  final int? initLevelId;
  
  const OperateCoustomCourseDialogWidget({super.key, required this.courseId, this.initLevelId});

  @override
  State<OperateCoustomCourseDialogWidget> createState() => _OperateCoustomCourseDialogWidgetState();
}

class _OperateCoustomCourseDialogWidgetState extends State<OperateCoustomCourseDialogWidget> {

  List<CourseLevelEntityLevelList> courseLevelList = [];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    getLevleListData();
  }

  Future<void> getLevleListData() async{
    try {
      ToastUtils.showLoading();
      CourseLevelEntity? resp = await OfficialCourseDetailsLevelRequest.getCourseLevelList(widget.courseId);
      if(resp == null) return;
      List<CourseLevelEntityLevelList?>? list = resp.levelList;
      if(list == null || list.isEmpty) return;
      for(int i = 0; i < list.length; i++){
        if(list[i] == null) continue;
        if(list[i]?.levelId == widget.initLevelId){
          selectedIndex = i;
        }
        courseLevelList.add(list[i]!);
      }
      if(mounted) setState(() {});
    } finally{
      ToastUtils.hideLoading();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Container(
          width: 1509.wMin,
          padding: EdgeInsets.all(32.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cBgSecondary,
            borderRadius: BorderRadius.circular(24.wMin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "管理课程",
                      style: TextStyle(
                        fontSize: 32.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TapScaleWidget(
                    sclae: 1.05,
                    onTap: () => Get.back(),
                    child: Container(
                      width: 48.wMin,
                      height: 48.wMin,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.cBgActive,
                      ),
                      child: SvgPicture.asset(
                        "assets/svg/public/x.svg",
                        width: 24.wMin,
                        height: 24.wMin,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.wMin),

              Row(
                spacing: 16.wMin,
                children: [
                  Visibility(
                    visible: courseLevelList.isNotEmpty,
                    child: _buildButtonWidget(
                      OperateCoustomCourseDialogType.addModule,
                      [
                        const TextSpan(text: '在'),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.wMin),
                            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.wMin),
                              color: AppTheme.cFeedbackWarningBackground,
                              border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackWarningBorder),
                            ),
                            child: Text(
                              courseLevelList.isEmpty ? "" : courseLevelList[selectedIndex].name??'',
                              style: TextStyle(
                                fontSize: 28.wMin,
                                color: AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: "中添加新教材"),
                      ],
                    ),
                  ),
                  _buildButtonWidget(
                    OperateCoustomCourseDialogType.editCourse,
                    [const TextSpan(text: "编辑课程信息")],
                  ),
                ],
              ),
              SizedBox(height: 24.wMin),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: AppTheme.cSurfacePrimary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "点击切换到其他年级进行编辑",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 16.wMin),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.topCenter,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          spacing: 16.wMin,
                          children: [
                            _buildAddLevelWidget(),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  spacing: 16.wMin,
                                  children: List.generate(courseLevelList.length, (index){
                                    return _widgetLevelWidget(index);
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddLevelWidget(){
    return TapScaleWidget(
      onTap: () {
        Get.back(result: OperateCoustomCourseDialogResult(
          levelId: courseLevelList[selectedIndex].levelId,
          type: OperateCoustomCourseDialogType.addLevel,
        ));
      },
      sclae: 1.02,
      child: Container(
        height: 60.wMin,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: AppTheme.cFeedbackWarningBackground,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            height: 60.wMin,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8.wMin,
              children: [
                Text(
                  '添加新年级',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SvgPicture.asset(
                  Assets.publicIconAdd,
                  width: 38.wMin,
                  colorFilter: const ColorFilter.mode(AppTheme.cFeedbackWarningIcon, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _widgetLevelWidget(int index){
    return TapScaleWidget(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      sclae: 1.02,
      child: Container(
        height: 60.wMin,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: AppTheme.cBgTertiary,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            height: 60.wMin,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 24.wMin,
              children: [
                Text(
                  courseLevelList[index].name??'',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SvgPicture.asset(
                  selectedIndex == index ? Assets.publicIconRadio: Assets.publicIconRadioUn,
                  width: 32.wMin,
                  colorFilter: selectedIndex == index ? const ColorFilter.mode(AppTheme.cFeedbackWarningIcon, BlendMode.srcIn) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildButtonWidget(OperateCoustomCourseDialogType type, List<InlineSpan> textSpanList){
    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          Get.back(result: OperateCoustomCourseDialogResult(
            levelId: courseLevelList[selectedIndex].levelId,
            type: type,
          ));
        },
        sclae: 1.01,
        child: Container(
          alignment: Alignment.center,
          height: 114.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cBgTertiary,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
          ),
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 28.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w500,
              ),
              children: textSpanList,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ),
    );
  }


}