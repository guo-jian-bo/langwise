import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';

/// 选择课时 (课程 -> 等级 -> 模块 -> 课时)
class ManageSelectExerciseLessonDialog {
  static Future<bool> show({
    required BuildContext context,
    required int exerciseId,
    required int uid,
    required String type,
    int? semanticId,
  }) async {
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return ManageSelectExerciseLessonDialogWidget(
          exerciseId: exerciseId,
          uid: uid,
          type: type,
          semanticId: semanticId,
        );
      },
    );
    return res??false;
  }
}

class ManageSelectExerciseLessonDialogWidget extends StatefulWidget {
  final int exerciseId;
  final int uid;
  final String type;
  final int? semanticId;
  const ManageSelectExerciseLessonDialogWidget({
    super.key,
    required this.exerciseId,
    required this.uid,
    required this.type,
    this.semanticId,
  });

  @override
  State<ManageSelectExerciseLessonDialogWidget> createState() => _ManageSelectExerciseLessonDialogWidgetState();
}

class _ManageSelectExerciseLessonDialogWidgetState extends State<ManageSelectExerciseLessonDialogWidget> {


  List<ExerciseLessonEntity> allDataList = [];

  List<ExerciseLessonEntity> courseList = [];
  int selectedCourseId = -1;

  List<ExerciseLessonEntity> levelList = [];
  int selectedLevelId = -1;

  List<ExerciseLessonEntity> moduleList = [];
  int selectedModuleId = -1;

   List<ExerciseLessonEntity> unitList = [];
  int selectedUnitId = -1;

  List<ExerciseLessonEntity> lessonList = [];

  /// 鼠标悬浮的课时
  String hoverCLMLessonId = "";

  /// 选择的课时
  List<_SelectLessonModel> selectedLessonList = [];


  /// 是否显示选择的课时列表
  bool showSelectedLessonList = false;

  /// 鼠标悬浮的选择课时
  int hoverSelectLessonIndex = -1;
  


  @override
  void initState() {
    super.initState();
    fetchCourseList();
  }

  /// 查询 (课程 -> 等级 -> 模块 -> 课时) 列表
  Future<void> fetchCourseList() async {
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "subContent": {
          "type": widget.type,
          "uid": widget.uid,
          "semanticId": widget.semanticId,
        },
        "exerciseId": widget.exerciseId,
      };

      List<ExerciseLessonEntity>? list = await ExercisesRequest.getExerciseLessonList(reqData);
      if (list == null) return;
      allDataList = list;
      courseList.add(ExerciseLessonEntity(
        courseId: -1,
        courseName: "全部",
      ));
      // 去重课程
      for(int i = 0; i < list.length; i++){
        bool courseExist = courseList.any((e) => e.courseId == list[i].courseId);
        if(!courseExist){
          courseList.add(list[i]);
        }

        // 默认选择
        List<ExerciseLessonEntityLessonInfos?> lessonInfos = list[i].lessonInfos??[];
        for(int j = 0; j < lessonInfos.length; j ++){
          bool select = lessonInfos[j]?.exerciseExists??false;
          if(select){
            selectedLessonList.add(_SelectLessonModel(
              entity: list[i],
              lesson: lessonInfos[j],
            ));
          }
        }

      }

      if(courseList.isEmpty) return;

      courseList.sort((a, b) => (a.courseId??-1).compareTo(b.courseId??-1));

      selectedCourseId = courseList.first.courseId??-1;
      findLevel(selectedCourseId);

      if (mounted) setState(() {});
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 查找等级 并去重
  void findLevel(int? courseId) {
    levelList.clear();
    levelList.add(ExerciseLessonEntity(
      courseLevelId: -1,
      courseLevelName: "全部",
    ));

    for(int i = 0; i < allDataList.length; i++){
      if(courseId != -1){
        if(allDataList[i].courseId != courseId) continue;
      }
      
      bool levelExist = levelList.any((e) => e.courseLevelId == allDataList[i].courseLevelId);
      if(!levelExist){
        levelList.add(allDataList[i]);
      }
    }
    
    if (mounted) setState(() {});
    if(levelList.isEmpty) {
      moduleList.clear();
      unitList.clear();
      lessonList.clear();
      if (mounted) setState(() {});
      return;
    }
    levelList.sort((a, b) => (a.courseLevelId??-1).compareTo(b.courseLevelId??-1));
    selectedLevelId = levelList.first.courseLevelId??-1;
    findModule(selectedCourseId, selectedLevelId);
  }

  /// 查找模块 并去重
  void findModule(int? courseId, int? levelId) {
    moduleList.clear();
    moduleList.add(ExerciseLessonEntity(
      courseModuleId: -1,
      courseModuleName: "全部",
    ));

    for(int i = 0; i < allDataList.length; i++){
      if(courseId != -1){
        if(allDataList[i].courseId != courseId) continue;
      }
      if(levelId != -1){
        if(allDataList[i].courseLevelId != levelId) continue;
      }
      
      bool moduleExist = moduleList.any((e) => e.courseModuleId == allDataList[i].courseModuleId);
      if(!moduleExist){
        moduleList.add(allDataList[i]);
      }
    }

    if (mounted) setState(() {});
    if(moduleList.isEmpty) {
      unitList.clear();
      lessonList.clear();
      if (mounted) setState(() {});
      return;
    }
    moduleList.sort((a, b) => (a.courseModuleId??-1).compareTo(b.courseModuleId??-1));
    selectedModuleId = moduleList.first.courseModuleId??-1;
    findUnit(selectedCourseId, selectedLevelId, selectedModuleId);
  }

  /// 查找单元
  void findUnit(int courseId, int? levelId, int? moduleId) {
    unitList.clear();
    unitList.add(ExerciseLessonEntity(
      courseUnitId: -1,
      courseUnitName: "全部",
    ));
    
    for(int i = 0; i < allDataList.length; i++){
      if(courseId != -1){
        if(allDataList[i].courseId != courseId) continue;
      }
      if(levelId != -1){
        if(allDataList[i].courseLevelId != levelId) continue;
      }

      if(moduleId != -1){
        if(allDataList[i].courseModuleId != moduleId) continue;
      }

      bool unitExist = unitList.any((e) => e.courseUnitId == allDataList[i].courseUnitId);
      if(!unitExist){
        unitList.add(allDataList[i]);
      }
    }

    if (mounted) setState(() {});

    if(unitList.isEmpty) {
      lessonList.clear();
      if (mounted) setState(() {});
      return;
    }
    unitList.sort((a, b) => (a.courseUnitId??-1).compareTo(b.courseUnitId??-1));
    selectedUnitId = unitList.first.courseUnitId??-1;

    findLesson(selectedCourseId, selectedLevelId, selectedModuleId, selectedUnitId);
  }

  /// 查找课时
  void findLesson(int courseId, int? levelId, int? moduleId, int? unitId) {
    lessonList.clear();

    for(int i = 0; i < allDataList.length; i++){
      if(courseId != -1){
        if(allDataList[i].courseId != courseId) continue;
      }
      if(levelId != -1){
        if(allDataList[i].courseLevelId != levelId) continue;
      }
      if(moduleId != -1){
        if(allDataList[i].courseModuleId != moduleId) continue;
      }
      if(unitId != -1){
        if(allDataList[i].courseUnitId != unitId) continue;
      }

      lessonList.add(allDataList[i]);
    }

    if (mounted) setState(() {});
  }


  /// 确定发送
  Future<void> confirmSend() async {
    // 获取 已存在课程 但是取消选择的课时 需要删除
    List<_SelectLessonModel> cancelLessonList = [];
    for(int i = 0; i < allDataList.length; i++){
      List<ExerciseLessonEntityLessonInfos?> lessonInfos = allDataList[i].lessonInfos??[];
      for(int j = 0; j < lessonInfos.length; j++){
        if(lessonInfos[j]?.exerciseExists != true) continue;
        // 判断选择的课时里面是否有这个课时
        bool exists = selectedLessonList.any((e) {
          return e.entity?.courseId == allDataList[i].courseId 
          && e.entity?.courseLevelId == allDataList[i].courseLevelId 
          && e.entity?.courseModuleId == allDataList[i].courseModuleId
           && e.entity?.courseUnitId == allDataList[i].courseUnitId 
           && e.lesson?.courseLessonId == lessonInfos[j]?.courseLessonId;
        });
        if(exists) continue;
        // 说明这个课时没有选择，但是存在
        cancelLessonList.add(_SelectLessonModel(
          entity: allDataList[i],
          lesson: lessonInfos[j],
        ));
      }
    }

    try {
      ToastUtils.showLoading(); 

      if(cancelLessonList.isNotEmpty){
        // 删除
        List<int> canLessonIds = [];
        for(int i = 0; i < cancelLessonList.length; i++){
          if(cancelLessonList[i].lesson?.courseLessonId == null) continue;
          canLessonIds.add(cancelLessonList[i].lesson!.courseLessonId!);
        }

        Map<String, dynamic> canReqData = {
          "exerciseIds": [widget.exerciseId],
          "lessonIds": canLessonIds,
        };
        bool canRes = await ManageSelectQuziKnowledge.quizOperation(canReqData, "course_delete");
        if (!canRes) return;
      }
      

      // 绑定
      List<int> lessonIds = [];

      for(int i = 0; i < selectedLessonList.length; i++){
        if(selectedLessonList[i].lesson?.courseLessonId == null) continue;
        if(selectedLessonList[i].lesson!.exerciseExists == true) continue;
        lessonIds.add(selectedLessonList[i].lesson!.courseLessonId!);
      }

      if(lessonIds.isNotEmpty){
        Map<String, dynamic> reqData = {
          "exerciseIds": [widget.exerciseId],
          "lessonIds": lessonIds,
        };

        bool res = await ManageSelectQuziKnowledge.exerciseLessonBind(reqData);
        if (!res) return;
      }

      ToastUtils.showToast(text: "绑定成功", type: ToastType.success);
      Get.back(result: true);
     
      
    } finally {
      ToastUtils.hideLoading();
    }

  }


  @override
  Widget build(BuildContext context) {
    return DialogBoxWidget(
      onCancel: () => Get.back(),
      width: 1800.wMin,
      title: "发送到课程",
      showOther: true,
      other: "已选择${selectedLessonList.length}个课时",
      onOther: () {
        showSelectedLessonList = !showSelectedLessonList;
        if (mounted) setState(() {});
      },
      onDefine: () {
        confirmSend();
      },
      child: Container(
        height: 800.wMin,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseList(),
            _buildLevelList(),
            _buildModuleList(),
            _buildUnitList(),
            _buildLessonList(),
          ],
        ),
      ),
    );
  }

  /// 课程
  Widget _buildCourseList() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 6.wMin),
        child: Row(
          children: List.generate(courseList.length, (index){
            return _buildTabItemWidget(
              name: courseList[index].courseName,
              selected: selectedCourseId == courseList[index].courseId,
              onTap: () {
                selectedCourseId = courseList[index].courseId??-1;
                findLevel(selectedCourseId);
              },
            );
          }),
        ),
      ),
    );
  }

  /// 等级
  Widget _buildLevelList() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 6.wMin),
        child: Row(
          children: List.generate(levelList.length, (index){
            return _buildTabItemWidget(
              name: levelList[index].courseLevelName,
              selected: selectedLevelId == levelList[index].courseLevelId,
              onTap: () {
                selectedLevelId = levelList[index].courseLevelId??-1;
                findModule(selectedCourseId, selectedLevelId);
              },
            );
          }),
        ),
      ),
    );
  }

  /// 模块
  Widget _buildModuleList() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 6.wMin),
        child: Row(
          children: List.generate(moduleList.length, (index){
            return _buildTabItemWidget(
              name: moduleList[index].courseModuleName,
              selected: selectedModuleId == moduleList[index].courseModuleId,
              onTap: () {
                selectedModuleId = moduleList[index].courseModuleId??-1;
                findUnit(selectedCourseId, selectedLevelId, selectedModuleId);
              },
            );
          }),
        ),
      ),
    );
  }

  /// 单元
  Widget _buildUnitList() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 6.wMin),
        child: Row(
          children: List.generate(unitList.length, (index){
            return _buildTabItemWidget(
              name: unitList[index].courseUnitName,
              selected: selectedUnitId == unitList[index].courseUnitId,
              onTap: () {
                selectedUnitId = unitList[index].courseUnitId??-1;
                findLesson(selectedCourseId, selectedLevelId, selectedModuleId, selectedUnitId);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabItemWidget({
    required String? name,
    bool selected = false,
    void Function()? onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.wMin),
          color: selected ? const Color(0xff2388FF) : Colors.transparent,
        ),
        child: Text(
          name??"",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.wMin,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }



  /// 课时列表
  Widget _buildLessonList() {
    return SizedBox(
      height: 600.wMin,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.wMin),
              child: Column(
                children: List.generate(lessonList.length, (index){
                  return _buildLessonListWidget(lessonList[index]);
                }),
              ),
            ),
          ),
          _buildSelectedLessonListWidget(),
        ],
      ),
    );
  }

  /// 课时列表item
  Widget _buildLessonListWidget(ExerciseLessonEntity entity){
    List<ExerciseLessonEntityLessonInfos?> lessonInfos = entity.lessonInfos??[];
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0xff353E5C).withValues(alpha: 0.6),
            width: 2.wMin,
          ),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: lessonInfos.length,
        separatorBuilder: (context, index) {
          return Container(height: 1.wMin, color: const Color(0xff353E5C).withValues(alpha: 0.6));
        },
        itemBuilder: (context, index) {
          return _buildLessonItemWidget(entity, lessonInfos[index]);
        },
      ),
    );
  }

  /// 课时item
  Widget _buildLessonItemWidget(ExerciseLessonEntity entity, ExerciseLessonEntityLessonInfos? info){
    bool selected = selectedLessonList.any((e) {
      return e.entity?.courseId == entity.courseId &&
        e.entity?.courseLevelId == entity.courseLevelId &&
        e.entity?.courseModuleId == entity.courseModuleId &&
        e.entity?.courseUnitId == entity.courseUnitId &&
        e.lesson?.courseLessonId == info?.courseLessonId;
    });

    String hoverLessonId = "${entity.courseId}_${entity.courseLevelId}_${entity.courseModuleId}_${entity.courseUnitId}_${info?.courseLessonId}";

    return MouseRegion(
      onHover: (event) {
        hoverCLMLessonId = hoverLessonId;
        if(mounted) setState(() {});
      },
      onExit: (event) {
        hoverCLMLessonId = "";
        if(mounted) setState(() {});
      },
      child: TapScaleWidget(
        onTap: () {
      
          if(!selected){
            selectedLessonList.add(_SelectLessonModel(
              entity: entity,
              lesson: info,
            ));
          }else{
            selectedLessonList.removeWhere((e) {
              return e.entity?.courseId == entity.courseId &&
                e.entity?.courseLevelId == entity.courseLevelId &&
                e.entity?.courseModuleId == entity.courseModuleId &&
                e.entity?.courseUnitId == entity.courseUnitId &&
                e.lesson?.courseLessonId == info?.courseLessonId;
            });
      
          }
      
          if(mounted) setState(() {});
          
        },
        sclae: 1,
        child: Container(
          color: hoverCLMLessonId == hoverLessonId ? const Color(0xff22293C) : Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 10.wMin),
          child: Row(
            children: [
                
              Container(
                padding: EdgeInsets.all(8.wMin),
                child: SvgPicture.asset(
                  selected ? "assets/svg/manage/icon_check_box.svg" : "assets/svg/manage/icon_uncheck_box.svg",
                  width: 24.wMin,
                  height: 24.wMin,
                ),
              ),
                
              Visibility(
                visible: info?.exerciseExists == true,
                child: Container(
                  margin: EdgeInsets.only(right: 10.wMin),
                  padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 2.wMin),
                  color: const Color(0xff44AF5C),
                  child: Text(
                    "已存在",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
                
              Expanded(
                child: Text.rich(TextSpan(
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(text: entity.courseName??""),
                    TextSpan(text: "  >  ", style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                    TextSpan(text: entity.courseLevelName??""),
                    TextSpan(text: "  >  ", style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                    TextSpan(text: entity.courseModuleName??""),
                    TextSpan(text: "  >  ", style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                    TextSpan(text: entity.courseUnitName??""),
                    TextSpan(text: "  >  ", style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                    TextSpan(text: info?.courseLessonName??""),
                  ],
                )),
              ),
          
            ],
          ),
        ),
      ),
    );
  }


  /// 已经选择的课时列表
  Widget _buildSelectedLessonListWidget() {
    if(!showSelectedLessonList) return Container();
    if(selectedLessonList.isEmpty) return Container();
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.wMin),
      padding: EdgeInsets.symmetric(horizontal: 20.wMin),
      constraints: BoxConstraints(
        maxHeight: 250.wMin,
      ),
      decoration: BoxDecoration(
        color: const Color(0xff19213D).withValues(alpha: 0.5),
        border: Border.all(color: const Color(0xff353E5C), width: 1.wMin),
        borderRadius: BorderRadius.circular(10.wMin),
      ),
      child: SingleChildScrollView(
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: selectedLessonList.length,
          separatorBuilder: (context, index) {
            return Container(height: 1.wMin, color: const Color(0xff353E5C).withValues(alpha: 0.6));
          },
          itemBuilder: (context, index) {
            return _buildSelectLessonItemWidget(selectedLessonList[index], index);
          },
        ),
      ),
    );
  }

  /// 已经选择的课时item
  Widget _buildSelectLessonItemWidget(_SelectLessonModel data, int index){

    return MouseRegion(
      onHover: (event) {
        hoverSelectLessonIndex = index;
        if(mounted) setState(() {});
      },
      onExit: (event) {
        hoverSelectLessonIndex = -1;
        if(mounted) setState(() {});
      },
      child: TapScaleWidget(
        onTap: () {
          selectedCourseId = data.entity?.courseId??-1;
          findLevel(selectedCourseId);
          selectedLevelId = data.entity?.courseLevelId??-1;
          findModule(selectedCourseId, selectedLevelId);
          selectedModuleId = data.entity?.courseModuleId??-1;
          findUnit(selectedCourseId, selectedLevelId, selectedModuleId);
          selectedUnitId = data.entity?.courseUnitId??-1;
          findLesson(selectedCourseId, selectedLevelId, selectedModuleId, selectedUnitId);
        },
        sclae: 1,
        child: Container(
          color: hoverSelectLessonIndex == index ? const Color(0xff22293C) : Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 20.wMin),
          child: Row(
            children: [
        
              Visibility(
                visible: data.lesson?.exerciseExists == true,
                child: Container(
                  margin: EdgeInsets.only(right: 10.wMin),
                  padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 2.wMin),
                  color: const Color(0xff44AF5C),
                  child: Text(
                    "已存在",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
        
              Expanded(
                child: Text.rich(TextSpan(
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(text: data.entity?.courseName??""),
                    TextSpan(text: "  >  ", style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                    TextSpan(text: data.entity?.courseLevelName??""),
                    TextSpan(text: "  >  ", style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                    TextSpan(text: data.entity?.courseModuleName??""),
                    TextSpan(text: "  >  ", style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                    TextSpan(text: data.entity?.courseUnitName??""),
                    TextSpan(text: "  >  ", style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                    TextSpan(text: data.lesson?.courseLessonName??""),
                  ],
                )),
              ),
          
              TapScaleWidget(
                onTap: () {
                  selectedLessonList.removeWhere((e) {
                    return e.entity?.courseId == data.entity?.courseId &&
                      e.entity?.courseLevelId == data.entity?.courseLevelId &&
                      e.entity?.courseModuleId == data.entity?.courseModuleId &&
                      e.entity?.courseUnitId == data.entity?.courseUnitId &&
                      e.lesson?.courseLessonId == data.lesson?.courseLessonId;
                  });
                  if(mounted) setState(() {});
                },
                sclae: 1.1,
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(10.wMin),
                  child: SvgPicture.asset(
                    "assets/svg/manage/icon_close.svg",
                    width: 24.wMin,
                    height: 24.wMin,
                  ),
                ),
              ),
          
          
          
            ],
          ),
        ),
      ),
    );
  }


}


class _SelectLessonModel{
  ExerciseLessonEntity? entity;
  ExerciseLessonEntityLessonInfos? lesson;

  _SelectLessonModel({
    this.entity,
    this.lesson,
  });
}