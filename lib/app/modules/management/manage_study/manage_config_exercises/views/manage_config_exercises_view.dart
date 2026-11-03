import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_config_exercises_binding.dart';
import '../controllers/manage_config_exercises_controller.dart';

class ManageConfigExercisesView extends GetView<ManageConfigExercisesController> {
  final String tagText;
  const ManageConfigExercisesView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CONFIG_EXERCISES}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageConfigExercisesView(tagText: tag),
      binding: ManageConfigExercisesBinding(tag: tag),
      routeName: Routes.MANAGE_CONFIG_EXERCISES,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    double bottom = MediaQuery.of(context).padding.bottom + 16;
    return ManageScaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeardWidget(context),
              Expanded(child: _buildContainListWidget(context)),
            ],
          ),
          Positioned(
            right: 16.wMin,
            bottom: bottom,
            child: _buildSelectWidget(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFilterWidget(context),
    );
  }

    /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context){
    
    return Obx((){
      Map<String, FilterConditionData> filterConditionDatas = {...controller.filterConditionDatas};
      Map<String, FilterInputData> filterInputDatas = {...controller.filterInputDatas};
      return FilterFloatWidget(
        conditions: filterConditionDatas,
        inputs: filterInputDatas,
        onChange: (datas) {
          controller.changeFilterConditionData(datas);
        },
        onSubmitted: () {
          controller.searchSubmitted();
        },

      );
    });
  }


  /// 确定选择的按钮
  Widget _buildSelectWidget(){
    if(controller.pageType != "select" && controller.pageType != "single") return const SizedBox.shrink();
    return Container(
      height: 72.wMin,
      padding: EdgeInsets.symmetric(horizontal: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppTheme.cSurfaceSecondary.color,
        border:  Border.all(width: 1.wMin, color: AppTheme.cTextPrimary.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        spacing: 16.wMin,
        mainAxisSize: MainAxisSize.min,
        children: [
          ButtonWidget(
            text: "取消",
            width: 100.wMin,
            height: 56.wMin,
            color: AppTheme.cSurfaceTertiary.color,
            fontSize: 22.wMin,
            borderRadius: 999,
            sclae: 1,
            onTap: () {
              controller.back();
            },
          ),
          ButtonWidget(
            text:  "确定选择",
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            width: 210.wMin,
            height: 56.wMin,
            color: AppTheme.cSurfaceBrand.color,
            fontSize: 22.wMin,
            borderRadius: 999,
            sclae: 1,
            onTap: () {
              controller.confirmSelect();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeardWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.cBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Row(
        children: [

          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.courseLessonTemplateConfigCreate],
            child: ButtonWidget(
              text: "添加",
              padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
              borderRadius: 6.wMin,
              color: Colors.transparent,
              fontColor: AppTheme.cTextSecondary.color,
              tapColor: AppTheme.cTextSecondary.color.withValues(alpha: 0.1),
              sclae: 1.05,
              fontSize: 18.wMin,
              leftIcon: Container(
                margin: EdgeInsets.only(right: 4.wMin),
                child: SvgPicture.asset(
                  "assets/svg/public/icon_add.svg",
                  width: 24.wMin,
                  height: 24.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextQuaternary.color, BlendMode.srcIn),
                ),
              ),
              onTap: (){
                controller.addExerciseConfig(context);
              },
            ),
          ),

          const Spacer(),

          Obx((){
            return PagerWidget(
              controller: controller.pagerController,
              dataCount: controller.totalCount.value,
              visiblePageCount: 3,
              activeColor: AppTheme.cTextPrimary.color,
              onPage: (page, pageSize) {
                controller.pagerCallback(page, pageSize);
              },
            );
          }),
      
        ],
      ),
    );
  }

  /// 列表
  Widget _buildContainListWidget(BuildContext context){
    return Obx((){
      List<int> selectedConfigIds = controller.selectedConfigIds.toList();
      return GridView.builder(
        itemCount: controller.exercisesList.length,
        padding: EdgeInsets.only(
          left: 18.wMin,
          right: 18.wMin,
          top: 18.wMin,
          bottom: 18.wMin + 80.wMin,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20.wMin,
          mainAxisSpacing: 20.wMin,
          childAspectRatio: 902 / 458,
        ), 
        itemBuilder: (context, index) {
          final exercise = controller.exercisesList[index];
          return ManageExercisesCardWidget(
            key: ValueKey('config_exercise_${exercise.config?.uid}_${index}'),
            exercise: exercise.exercise,
            showUid: false,
            showAccess: false,
            exerciseName: exercise.template?.name,
            description: exercise.description,
            onPreview: () => controller.previewExercise(exercise.exercise),
            onDelete: !ManageAuthUtils.isAuth(ManageAuthCode.courseLessonTemplateConfigDelete) ? null : () {
              controller.deleteExerciseConfig(context, exercise.config?.uid);
            },
            followEditable: false,
            onEdit: !ManageAuthUtils.isAuth(ManageAuthCode.courseLessonTemplateConfigEdit) ? null : () {
              controller.editExerciseConfig(context, exercise);
            },
            single: controller.pageType == "single",
            selected: selectedConfigIds.contains(exercise.config?.uid),
            onSelect: controller.pageType != "select" && controller.pageType != "single" ? null : () {
              controller.selectExercise(exercise.config?.uid);
            },
          );
        },
      );
    });
  }


  
}
