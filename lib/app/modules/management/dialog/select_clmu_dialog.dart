import 'package:api/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../theme/theme.dart';
import '../common/commons.dart';

class SelectCLMUReslut{
  int? courseId;
  String? courseName;

  int? levelId;
  String? levelName;

  int? moduleId;
  String? moduleName;

  int? unitId;
  String? unitName;

  List<NewUnitResponseEntity>? units;

  SelectCLMUReslut({
    this.courseId,
    this.courseName,
    this.levelId,
    this.levelName,
    this.moduleId,
    this.moduleName,
    this.unitId,
    this.unitName,
    this.units,
  });
}

/// 依次选择课程级别模块单元
class SelectCLMUDialog{

  static Future<SelectCLMUReslut?> show({
    required BuildContext context,
    SelectCLMUReslut? initData,
  }) async {
    return await showCupertinoDialog<SelectCLMUReslut?>(
      context: context,
      builder: (context) {
        return SelectCLMUDialogWidget(initData: initData);
      },
    );
  }
}

class SelectCLMUDialogWidget extends StatefulWidget {
  final SelectCLMUReslut? initData;
  const SelectCLMUDialogWidget({super.key, this.initData});

  @override
  State<SelectCLMUDialogWidget> createState() => _SelectCLMUDialogWidgetState();
}

class _SelectCLMUDialogWidgetState extends State<SelectCLMUDialogWidget> {

  /// 当前步骤
  int currentStop = 0;

  List<CourseResponseEntity> courses = [];
  List<LevelResponseEntity<ModuleResponseEntity>> levels = [];
  List<ModuleResponseEntity> modules = [];
  List<NewUnitResponseEntity> units = [];

  SelectCLMUReslut reslut = SelectCLMUReslut();


  @override
  void initState() {
    super.initState();
    if(widget.initData != null){
      reslut = SelectCLMUReslut(
        courseId: widget.initData!.courseId,
        courseName: widget.initData!.courseName,
        levelId: widget.initData!.levelId,
        levelName: widget.initData!.levelName,
        moduleId: widget.initData!.moduleId,
        moduleName: widget.initData!.moduleName,
        unitId: widget.initData!.unitId,
        unitName: widget.initData!.unitName,
        units: widget.initData!.units,
      );
      initData();
    }else{
      getCourseData();
    }
  }

  Future<void> initData()async{
    try {
      ToastUtils.showLoading();
      await getCourseData(showLoading: false);
      await getlevelData(showLoading: false);
      await getModuleData();
      await getunitData(showLoading: false);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 查询课程
  Future<void> getCourseData({bool showLoading = true}) async{
    try {
      if(showLoading) ToastUtils.showLoading();
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: {
          "offset": 0,
          "limit": 100,
          "order": "uid",
        },
        data: {
          "scope": ["OFFICIAL"],
          "language": ["en"],
        },
      );
      ResponseEntity<ListResponseEntity<CourseResponseEntity>> res = await CourseUtil.fetchCourses(config: config);
      courses = res.data?.datas??[];
      if(mounted) setState(() {});

    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 查询等级
  Future<void> getlevelData({bool showLoading = true}) async{
    if(reslut.courseId == null) return;
    try {
      if(showLoading) ToastUtils.showLoading();
      final response = await CourseUtil.levelModules(
        uid: reslut.courseId.toString(),
        config: RequestConfig(requireToken: true),
      );

      levels = response.data?.courseLevelList ?? [];
      
      if(mounted) setState(() {});

    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 查询模块
  Future<void> getModuleData() async{
    try {
      for(var item in levels){
        if(item.uid == reslut.levelId){
          List<ModuleResponseEntity> list = item.moduleDTOList??[];
          modules = list;
          break;
        }
      }
      
      if(mounted) setState(() {});

    } finally{}
  }

  /// 查询单元
  Future<void> getunitData({bool showLoading = true}) async{
    if(reslut.moduleId == null) return;
    try {
      if(showLoading) ToastUtils.showLoading();
      final response = await ModuleUtil.unitLessons(
        uid: reslut.moduleId.toString(),
        config: RequestConfig(requireToken: true),
      );

      units = response.data?.courseUnitList ?? [];
      
      if(mounted) setState(() {});

    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 选择课程
  Future<void> selectCourse(CourseResponseEntity data) async{
    if(data.uid == null) return;
    
    if(reslut.courseId != data.uid) {
      reslut.levelId = null;
      reslut.levelName = null;
      reslut.moduleId = null;
      reslut.moduleName = null;
      reslut.unitId = null;
      reslut.unitName = null;
      reslut.courseId = data.uid;
      reslut.courseName = data.name;
      if(mounted) setState(() {});
      await getlevelData();
    }
    
    currentStop = 1;
    if(mounted) setState(() {});
  }

  /// 选择级别
  Future<void> selectLevel(LevelResponseEntity data) async{

    if(reslut.levelId != data.uid) {
      reslut.moduleId = null;
      reslut.moduleName = null;
      reslut.unitId = null;
      reslut.unitName = null;
      reslut.levelId = data.uid;
      reslut.levelName = data.name;
      if(mounted) setState(() {});

      await getModuleData();
    }

    
    currentStop = 2;
    if(mounted) setState(() {});
  }

  /// 选择模块
  Future<void> selectModule(ModuleResponseEntity data) async{
    if(reslut.moduleId != data.uid) {
      reslut.unitId = null;
      reslut.unitName = null;
      reslut.moduleId = data.uid;
      reslut.moduleName = data.name;
      if(mounted) setState(() {});
      await getunitData();
    }
    
    currentStop = 3;
    if(mounted) setState(() {});
  }

  /// 选择单元
  Future<void> selectUnit(NewUnitResponseEntity data) async{
    reslut.unitId = data.uid;
    reslut.unitName = data.name;
    if(mounted) setState(() {});
  }

  /// 判断是否全部选择
  bool getSelectAll(){
    return reslut.courseId != null && reslut.levelId != null && reslut.moduleId != null && reslut.unitId != null;
  }

  /// 确认选择
  void confirm(){
    if(!getSelectAll()) return;
    reslut.units = units;
    Get.back(result: reslut);
  }

  @override
  Widget build(BuildContext context) {
    

    return ManageDialogBoxWidget(
      title: "选择课程",
      width: 1200.wMin,
      onCancel: () => Get.back(),
      confirmText: "确认选择",
      confirmColor: AppTheme.cSurfaceBrand.color.withValues(alpha: getSelectAll() ? 1 : 0.6),
      onConfirm: () {
        confirm();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.wMin),
        height: 700.wMin,
        child: Column(
          children: [
            _buildStopWidget(),
            Expanded(
              child: _buildBodyWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyWidget(){
    if(currentStop == 0){
      return _buildCourseWidget();
    }else if(currentStop == 1){
      return _buildLevelWidget();
    }else if(currentStop == 2){
      return _buildModuleWidget();
    } else if(currentStop == 3){
      return _buildUnitWidget();
    }
    return Container();
  }

  Widget _buildStopWidget(){
    return Container(
      height: 72.wMin,
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color)),
      ),
      child: Row(
        children: [
          _buildStopItemWidget(0, "选择课程"),
          Expanded(child: Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color)),
          _buildStopItemWidget(1, "选择级别"),
          Expanded(child: Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color)),
          _buildStopItemWidget(2, "选择模块"),
          Expanded(child: Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color)),
          _buildStopItemWidget(3, "选择单元"),
        ],
      ),
    );
  }

  Widget _buildStopItemWidget(int index, String name){

    bool isSelect = currentStop == index;
    bool isCurrent = false;
    bool isSelectCourse = index == 0 && reslut.courseId != null;
    bool isSelectLevel = index == 1 && reslut.levelId != null;
    bool isSelectModule = index == 2 && reslut.moduleId != null;
    bool isSelectUnit = index == 3 && reslut.unitId != null;
    if(index == 0){
      isCurrent = isSelectCourse;
    }else if(index == 1){
      isCurrent = isSelectLevel;
    }else if(index == 2){
      isCurrent = isSelectModule;
    }else if(index == 3){
      isCurrent = isSelectUnit;
    }

    return TapScaleWidget(
      onTap: () {

        if(index > 0){
          if(reslut.courseId == null) return ToastUtils.showToast(text: "请选择课程");
        }
        if(index > 1){
          if(reslut.levelId == null) return ToastUtils.showToast(text: "请选择级别");
        }
        if(index > 2){
          if(reslut.moduleId == null) return ToastUtils.showToast(text: "请选择模块");
        }

        setState(() {
          currentStop = index;
        });
      },
      sclae: 1.05,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
        
            Container(
              width: 32.wMin,
              height: 32.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelect ? AppTheme.cFeedbackSuccessBackground.color : AppTheme.cBorderPrimary.color,
              ),
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  color: isSelect ? AppTheme.cFeedbackSuccessText.color : AppTheme.cTextSecondary.color,
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            SizedBox(width: 12.wMin),
        
            Text(
              name,
              style: TextStyle(
                fontSize: 18.wMin,
                color: isSelect || isCurrent ? AppTheme.cTextBrand.color : AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w500,
                decoration: isSelect || isCurrent ? TextDecoration.underline : null,
                decorationColor: isSelect || isCurrent ? AppTheme.cTextBrand.color : AppTheme.cTextBrand.color,
              ),
            ),
        
          ],
        ),
      ),
    );
  }

  /// 课程列表
  Widget _buildCourseWidget(){
    return GridView.builder(
      itemCount: courses.length,
      padding: EdgeInsets.all(32.wMin),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12.wMin,
        crossAxisSpacing: 12.wMin,
        childAspectRatio: 30 / 8,
      ),
      itemBuilder: (context, index) {
        return _buildCourseCardItemWidget(index, courses[index]);
      },
    );
  }

  /// 级别列表
  Widget _buildLevelWidget(){
    return GridView.builder(
      itemCount: levels.length,
      padding: EdgeInsets.all(32.wMin),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12.wMin,
        crossAxisSpacing: 12.wMin,
        childAspectRatio: 30 / 8,
      ),
      itemBuilder: (context, index) {
        return _buildLevelCardItemWidget(index, levels[index]);
      },
    );
  }

  /// 模块列表
  Widget _buildModuleWidget(){
    return GridView.builder(
      itemCount: modules.length,
      padding: EdgeInsets.all(32.wMin),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.wMin,
        crossAxisSpacing: 12.wMin,
        childAspectRatio: 30 / 6,
      ),
      itemBuilder: (context, index) {
        return _buildModuleCardItemWidget(index, modules[index]);
      },
    );
  }

  /// 单元列表
  Widget _buildUnitWidget(){
    return GridView.builder(
      itemCount: units.length,
      padding: EdgeInsets.all(32.wMin),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.wMin,
        crossAxisSpacing: 12.wMin,
        childAspectRatio: 30 / 6,
      ),
      itemBuilder: (context, index) {
        return _buildUnitCardItemWidget(index, units[index]);
      },
    );
  }



  /// 课程卡片
  Widget _buildCourseCardItemWidget(int index, CourseResponseEntity data){
    return TapScaleWidget(
      onTap: () {
        selectCourse(data);
      },
      sclae: 1.01,
      backColor: AppTheme.cFeedbackSuccessBackground.color.withValues(alpha: 0.1),
      borderRadius: 12.wMin,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
        decoration: BoxDecoration(
          color:  Colors.transparent,
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(
            width: 1.wMin,
            color: reslut.courseId == data.uid ? AppTheme.cFeedbackSuccessBorder.color : AppTheme.cBorderPrimary.color,
          ),//reslut
        ),
        child: Text(
          data.name??"",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 级别卡片
  Widget _buildLevelCardItemWidget(int index, LevelResponseEntity data){
    return TapScaleWidget(
      onTap: () {
        selectLevel(data);
      },
      sclae: 1.01,
      backColor: AppTheme.cFeedbackSuccessBackground.color.withValues(alpha: 0.1),
      borderRadius: 12.wMin,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 12.wMin),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(
            width: 1.wMin,
            color: reslut.levelId == data.uid ? AppTheme.cFeedbackSuccessBorder.color : AppTheme.cBorderPrimary.color,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2.wMin,
          children: [
            Text(
              data.name??"",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              data.description??"",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 模块卡片
  Widget _buildModuleCardItemWidget(int index, ModuleResponseEntity data){
    return TapScaleWidget(
      onTap: () {
        selectModule(data);
      },
      sclae: 1.01,
      backColor: AppTheme.cFeedbackSuccessBackground.color.withValues(alpha: 0.1),
      borderRadius: 12.wMin,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 12.wMin),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(
            width: 1.wMin,
            color: reslut.moduleId == data.uid ? AppTheme.cFeedbackSuccessBorder.color : AppTheme.cBorderPrimary.color,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.name??"",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              data.description??"",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// 单元卡片
  Widget _buildUnitCardItemWidget(int index, NewUnitResponseEntity data){
    return TapScaleWidget(
      onTap: () {
        selectUnit(data);
      },
      sclae: 1.01,
      backColor: AppTheme.cFeedbackSuccessBackground.color.withValues(alpha: 0.1),
      borderRadius: 12.wMin,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 12.wMin),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(
            width: 1.wMin,
            color: reslut.unitId == data.uid ? AppTheme.cFeedbackSuccessBorder.color : AppTheme.cBorderPrimary.color,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.name??"",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              data.description??"",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }



}