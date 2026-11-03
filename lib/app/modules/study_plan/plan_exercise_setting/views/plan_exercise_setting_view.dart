import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../theme/theme_quiz_utils.dart';
import '../bindings/plan_exercise_setting_binding.dart';
import '../controllers/plan_exercise_setting_controller.dart';

class PlanExerciseSettingView extends GetView<PlanExerciseSettingController> {
  final String tagText;
  const PlanExerciseSettingView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      PlanExerciseSettingView(tagText: tag),
      binding: PlanExerciseSettingBinding(tagText: tag),
      routeName: Routes.PLAN_EXERCISE_SETTING,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Container(
        width: double.infinity,
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(
          bottom: 10.wMin + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BreadcrumbWidget(
              actionWidget: _buildTitleStatisticsWidget(),
            ),
            _buildTitleDescWidget(),
            SizedBox(height: 20.wMin),
            Expanded(child: _buildExerciseListWidget(context)),
          ],
        ),
      ),
      bottomNavigationBar: _buildButtonWidget(),
    );
  }

  Widget _buildButtonWidget(){
    return Container(
      margin: EdgeInsets.only(bottom: 10.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ButtonWidget(
            text: "确认",
            height: 60.wMin,
            width: 800.wMin,
            borderRadius: 10.wMin,
            color: AppTheme.cSurfaceBrand.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            sclae: 1.01,
            onTap: () {
              controller.confirmSelect();
            },
          ),
        ],
      ),
    );
  }



  Widget _buildTitleStatisticsWidget() {
    return Obx((){
      int enabledCount = 0;
      List<CourseDirectionExerciseEntityExerciseCategoryList?> exerciseCategoryList = controller.exerciseEntity.value.exerciseCategoryList??[];
      for(int i = 0; i < exerciseCategoryList.length; i++){
        List<CourseDirectionExerciseEntityExerciseCategoryListExerciseList?> exerciseList = exerciseCategoryList[i]?.exerciseList??[];
        for(int j = 0; j < exerciseList.length; j++){
          if(!controller.selectedExerciseTypes.contains(exerciseList[j]?.exerciseType)){
            enabledCount++;
          }
        }
      }

      int disabledCount = controller.selectedExerciseTypes.length;
      return Row(
        children: [
          Text(
            "启用 $enabledCount",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cSurfaceSuccess.color,
            ),
          ),
          Text(
            " · ",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          Text(
            "已禁用 $disabledCount",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cSurfaceError.color,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTitleDescWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Obx((){
        List<LessonTypeEntityList?> directionList = controller.exerciseEntity.value.directionList??[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.exerciseEntity.value.description??"",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            SizedBox(height: 20.wMin),
            Wrap(
              spacing: 6.wMin,
              runSpacing: 6.wMin,
              children: [
                _buildLessonItemWidget("已开启课时 ${directionList.length}"),
                ...List.generate(directionList.length, (index){
                  return _buildLessonItemWidget(LearningLangUtils.getLocalLang(directionList[index]?.title)?.text??"");
                }),
              ],
            ),
            
          ],
        );
      }),
    );
  }

  Widget _buildLessonItemWidget(String text){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 6.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
        color: AppTheme.cSurfaceTertiary.color,
        border: Border.all(
          color: AppTheme.cSurfaceSearchBackground.color,
          width: 0.8.wMin,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextSecondary.color,
        ),
      ),
    );
  }

  Widget _buildExerciseListWidget(BuildContext context){
    return Obx((){
      List<CourseDirectionExerciseEntityExerciseCategoryList?> exerciseCategoryList = controller.exerciseEntity.value.exerciseCategoryList??[];
      return ListView.separated(
        itemCount: exerciseCategoryList.length,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20.wMin),
        separatorBuilder: (context, index){
          return SizedBox(height: 20.wMin);
        },
        itemBuilder: (context, index) {
          return _buildExerciseListItemWidget(exerciseCategoryList[index]);
        },
      );
    });
  }

  Widget _buildExerciseListItemWidget(CourseDirectionExerciseEntityExerciseCategoryList? exerciseCategory){
    if(exerciseCategory == null){
      return Container();
    }
    List<CourseDirectionExerciseEntityExerciseCategoryListExerciseList?> exerciseList = exerciseCategory.exerciseList??[];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                exerciseCategory.title??"",
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SizedBox(width: 8.wMin),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: 1.wMin,
                  color: AppTheme.cBorderDefault.color,
                ),
              ),
            ],
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              const int columnCount = 4;
              final double totalSpacing = 16.wMin * (columnCount - 1);
              final double itemWidth = (constraints.maxWidth - totalSpacing) / columnCount;
              return Wrap(
                spacing: 16.wMin,
                runSpacing: 16.wMin,
                alignment: WrapAlignment.start,
                children: List.generate(exerciseList.length, (index){
                  return _buildExerciseItemWidget(exerciseList[index], itemWidth);
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItemWidget(CourseDirectionExerciseEntityExerciseCategoryListExerciseList? exercise, double width){
    return Obx((){
      bool isSelected = controller.selectedExerciseTypes.contains(exercise?.exerciseType??"");
      return Opacity(
        opacity: isSelected ? 0.6 : 1,
        child: SizedBox(
          width: width,
          height: 400.wMin,
          child: Container(
            width: width,
            padding: EdgeInsets.all(12.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cSurfaceLayerBase2.color,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise?.name??"",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 34.wMin,
                      child: Visibility(
                        visible: isSelected,
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 4.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.wMin),
                            color: AppTheme.cSurfaceTertiary.color,
                            border: Border.all(
                              color: AppTheme.cBorderSecondary.color,
                              width: 0.8.wMin,
                            ),
                          ),
                          child: Text(
                            "已禁用",
                            style: TextStyle(
                              fontSize: 16.wMin,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.cTextSecondary.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.wMin),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      exercise?.brief??"",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 230.wMin,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.wMin),
                    color: AppTheme.cBgSolid.color,
                  ),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      QuizPublicQuizWidget(
                        borderRadius: 10.wMin,
                        data: exercise?.exercise,
                        quizPlayStyle: ThemeQuizUtils.getQuizPlayStyle(),
                        bgColor: AppTheme.cBgSolid.color,
                      ),
                      Visibility(
                        visible: exercise?.required == true,
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.all(8.wMin),
                          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.wMin),
                            color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                          ),
                          child: Text(
                            exercise?.requiredBriefs?.join("\n").toString()??"",
                            style: TextStyle(
                              fontSize: 16.wMin,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.cSurfaceWarning.color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6.wMin),
                Row(
                  spacing: 8.wMin,
                  children: [
                    Expanded(
                      child: ButtonWidget(
                        text: "预览",
                        height: 40.wMin,
                        borderRadius: 6.wMin,
                        color: AppTheme.cSurfaceLayerElevated.color,
                        fontColor: AppTheme.cTextSecondary.color,
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        sclae: 1.03,
                        onTap: () {
                          controller.previewExercise(exercise?.exercise);
                        },
                      ),
                    ),
          
                    _buildExerciseItemButtonWidget(exercise),
                  ],
                ),
          
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildExerciseItemButtonWidget(CourseDirectionExerciseEntityExerciseCategoryListExerciseList? exercise){
    if(exercise?.required == true){
      return Expanded(
        child: ButtonWidget(
          text: "必备",
          height: 40.wMin,
          borderRadius: 6.wMin,
          color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
          fontColor: AppTheme.cSurfaceWarning.color,
          fontSize: 18.wMin,
          fontWeight: FontWeight.w500,
          sclae: 1.03,
          onTap: () {
            controller.selectExerciseType(exercise);
          },
        ),
      );
    }
    
    return Expanded(
      child: Obx((){
        bool isSelected = controller.selectedExerciseTypes.contains(exercise?.exerciseType??"");
        return ButtonWidget(
          text: isSelected ? "取消禁用" : "禁用",
          height: 40.wMin,
          borderRadius: 6.wMin,
          color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
          fontColor: AppTheme.cSurfaceError.color,
          fontSize: 18.wMin,
          fontWeight: FontWeight.w500,
          sclae: 1.03,
          onTap: () {
            controller.selectExerciseType(exercise);
          },
        );
      }),
    );
  }



}
