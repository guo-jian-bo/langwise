import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';

class PlanDetailsRecommendLessonDialog{

  static Future<List<LessonTypeEntityList>?> show({
    required BuildContext context,
    required int courseId,
    String? specialty,
    List<String>? initDirections,
  }) async{
    return await showCupertinoDialog<List<LessonTypeEntityList>?>(
      context: context,
      builder: (context) {
        return PlanDetailsRecommendLessonDialogWidget(courseId: courseId, initDirections: initDirections, specialty: specialty);
      },
    );
  }

}


class PlanDetailsRecommendLessonDialogWidget extends StatefulWidget {
  final int courseId;
  final String? specialty;
  final List<String>? initDirections;
  const PlanDetailsRecommendLessonDialogWidget({super.key, required this.courseId, this.specialty, this.initDirections});

  @override
  State<PlanDetailsRecommendLessonDialogWidget> createState() => _PlanDetailsRecommendLessonDialogWidgetState();
}

class _PlanDetailsRecommendLessonDialogWidgetState extends State<PlanDetailsRecommendLessonDialogWidget> {

  /// 课时推荐列表
  List<LessonTypeEntityList> moduleList = <LessonTypeEntityList>[];
  /// 课时推荐选项列表
  List<LessonTypeEntityChoices> choicesList = <LessonTypeEntityChoices>[];

  /// 选择的推荐的索引
  int selectTipsIndex = 0;
  /// 选择的课时
  List<String> selectDirections = <String>[];

  @override
  void initState(){
    super.initState();
    if(widget.initDirections != null){
      selectDirections.addAll(widget.initDirections!);
    }
    getModuleList();
  }

  Future<void> getModuleList() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> params = {
        "courseId": widget.courseId,
      };
      LessonTypeEntity? entity = await StudyPlanRequest.getLessonTypeList(params);
      if(entity == null) return;
      List<LessonTypeEntityList?> list = entity.list??[];
      List<LessonTypeEntityChoices?> choices = entity.choices??[];
      for(var item in list){
        if(item == null) continue;
        moduleList.add(item);
      }
      for(var item in choices){
        if(item == null) continue;
        choicesList.add(item);
      }

      if(selectDirections.isEmpty) {
        selectTips(0);
      }

      checkSelectTipsIndex();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 判断用户选择的是哪个推荐
  void checkSelectTipsIndex(){
    // 默认设置为0
    selectTipsIndex = 0;
    
    // 遍历所有推荐选项
    for(int i = 0; i < choicesList.length; i++){
      // 获取当前推荐选项的方向列表
      List<String> directions = [];
      for(String? item in choicesList[i].directions ?? []){
        if(item == null) continue;
        directions.add(item);
      }
      
      // 检查当前选择的方向列表是否与推荐选项完全匹配
      if(directions.length == selectDirections.length && 
         directions.every((element) => selectDirections.contains(element)) &&
         selectDirections.every((element) => directions.contains(element))){
        // 找到匹配项，设置索引并退出循环
        selectTipsIndex = i;
        break;
      }
    }

    if(mounted) setState(() {});
  }

  /// 选择推荐
  void selectTips(int index){
    selectTipsIndex = index;

    selectDirections.clear();
    for(String? item in choicesList[index].directions??[]){
      if(item == null) continue;
      selectDirections.add(item);
    }
    if(mounted) setState(() {});
  }

  /// 选择课时
  void selectModule(LessonTypeEntityList item){
    if(item.direction == null) return;
    if(item.forceSelect) {
      if(!selectDirections.contains(item.direction)){
        selectDirections.add(item.direction!);
      }
      return;
    }
    if(selectDirections.contains(item.direction)){
      selectDirections.remove(item.direction);
    } else {
      selectDirections.add(item.direction!);
    }
    checkSelectTipsIndex();
  }

  void confirm(){
    if(selectDirections.isEmpty){
      ToastUtils.showToast(text: "请选择课时类型");
      return;
    }
    List<LessonTypeEntityList> list = [];
    for(var item in moduleList){
      if(selectDirections.contains(item.direction)){
        item.exclude = false;
        list.add(item);
      }else{
        item.exclude = true;
        list.add(item);
      }
    }
    Get.back(result: list);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 1200.wMin,
              height: 840.wMin,
              decoration: BoxDecoration(
                color: AppTheme.cSurfaceSecondary.color,
                borderRadius: BorderRadius.circular(20.wMin),
                border: Border.all(color: AppTheme.cBorderPrimary.color, width: 1.wMin),
              ),
              child: Column(
                children: [
                  _buildTitleWidget(),
                  Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildRecommendListWidget(),
                          Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
                          Expanded(
                            child: _buildLessonListWidget(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
                  _buildButtonsWidget(),
                ],
              ),
            ),
            Positioned(
              top: 24.wMin,
              right: 24.wMin,
              child: _buildCloseWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseWidget(){
    return TapScaleWidget(
      sclae: 1.05,
      onTap: () => Get.back(),
      child: Container(
        width: 42.wMin,
        height: 42.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.cSurfaceTertiary.color,
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderDefault.color),
        ),
        child: SvgPicture.asset(
          "assets/svg/public/x.svg",
          width: 24.wMin,
          height: 24.wMin,
          colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    LanguageText? title;
    if(choicesList.isNotEmpty && selectTipsIndex != -1) {
      title = LearningLangUtils.getLocalLang(choicesList[selectTipsIndex].title);
    }
    return Container(
      padding: EdgeInsets.only(top: 32.wMin, bottom: 12.wMin, left: 32.wMin, right: 32.wMin),
      child: Text(
        title?.text??"",
        style: TextStyle(
          fontSize: 32.wMin,
          color: AppTheme.cTextPrimary.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRecommendListWidget(){
    return SizedBox(
      width: 336.wMin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "推荐场景",
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.wMin),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(right: 16.wMin),
              child: Column(
                spacing: 8.wMin,
                children: List.generate(choicesList.length, (index){
                  return _buildRecommendListItemWidget(choicesList[index], index);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendListItemWidget(LessonTypeEntityChoices item, int index){

    LanguageText? title = LearningLangUtils.getLocalLang(item.title);
    LanguageText? tips = LearningLangUtils.getLocalLang(item.tips);

    bool selected = selectTipsIndex == index;

    return TapScaleWidget(
      onTap: () {
        selectTips(index);
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: selected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.1) : AppTheme.cSurfaceLayerElevated2.color,
          border: Border.all(
            width: 1.wMin, 
            color: selected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: selected ? 2.wMin : 0,
              height: 68.wMin,
              margin: EdgeInsets.only(right: selected ? 8.wMin : 0),
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: selected ? 1 : 0),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title?.text??"",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: selected ? AppTheme.cTextPrimary.color : AppTheme.cTextTertiary.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.wMin),
                  Text(
                    tips?.text??"",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: selected ? AppTheme.cTextBrand.color : AppTheme.cTextTertiary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonListWidget(){

    LanguageText? description;
    if(choicesList.isNotEmpty && selectTipsIndex != -1 && choicesList.length > selectTipsIndex){
      description = LearningLangUtils.getLocalLang(choicesList[selectTipsIndex].description);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "课时选择",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text.rich(TextSpan(
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(text: "已选用"),
                  TextSpan(
                    text: " ${selectDirections.length}",
                    style: TextStyle(
                      color: AppTheme.cTextPrimary.color,
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: " / ${moduleList.length} 个课时"),
                ],
              )),
            ],
          ),
          SizedBox(height: 8.wMin),
          Expanded(
            child: GridView.builder(
              itemCount: moduleList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.wMin,
                crossAxisSpacing: 8.wMin,
                mainAxisExtent: 115.wMin,
              ),
              itemBuilder: (context, index) {
                return _buildLessonListItemWidget(moduleList[index]);
              },
            ),
          ),
          
          Visibility(
            visible: description != null,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 8.wMin),
              padding: EdgeInsets.all(8.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: AppTheme.cSurfaceLayerBase.color,
              ),
              child: Text(
                description?.text??"",
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

  Widget _buildLessonListItemWidget(LessonTypeEntityList item){

    bool selected = selectDirections.contains(item.direction);
    LanguageText? title = LearningLangUtils.getLocalLang(item.title);
    LanguageText? subtitle = LearningLangUtils.getLocalLang(item.subtitle);

    return Opacity(
      opacity: selected ? 1 : 0.6,
      child: Container(
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: Colors.transparent,
          border: Border.all(
            width: 1.wMin, 
            color: AppTheme.cBorderSubtle.color,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title?.text??"",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  selected ? "assets/svg/public/icon_check_g.svg" : "assets/svg/public/icon_uncheck_box.svg",
                  width: 20.wMin,
                  colorFilter: !selected ? ColorFilter.mode(AppTheme.cBorderDefault.color, BlendMode.srcATop) : null,
                ),
              ],
            ),
            SizedBox(height: 8.wMin),
            Text(
              subtitle?.text??"",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsWidget(){

    SpecialtyColor courseColor = SpecialtyEnum.getCourseColor(widget.specialty ?? "");
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
      child: Row(
        children: [
          ButtonWidget(
            text: "返回",
            width: 112.wMin,
            height: 56.wMin,
            borderRadius: 8.wMin,
            color: AppTheme.cSurfaceLayerElevated.color,
            sclae: 1.03,
            onTap: () {
              Get.back();
            },
          ),
          const Spacer(),
          ButtonWidget(
            text: "使用该场景",
            width: 184.wMin,
            height: 56.wMin,
            borderRadius: 8.wMin,
            color: courseColor.color1,
            sclae: 1.03,
            onTap: () {
              confirm();
            },
          ),
        ],
      ),
    );
  }


}