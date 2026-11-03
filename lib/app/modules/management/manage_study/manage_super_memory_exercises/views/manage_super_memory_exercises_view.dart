import 'package:flutter/material.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_super_memory_exercises_binding.dart';
import '../controllers/manage_super_memory_exercises_controller.dart';
import 'manage_super_memory_exercises_card_widget.dart';

class ManageSuperMemoryExercisesView extends GetView<ManageSuperMemoryExercisesController> {
  final String tagText;

  const ManageSuperMemoryExercisesView({
    super.key,
    required this.tagText,
  });

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SUPER_MEMORY_EXERCISES}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      () => ManageSuperMemoryExercisesView(tagText: tag),
      binding: ManageSuperMemoryExercisesBinding(tag: tag),
      arguments: arguments,
      routeName: Routes.MANAGE_SUPER_MEMORY_EXERCISES,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        children: [
          _buildHeardWidget(context),
          Expanded(child: _buildListWidget(context)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFilterWidget(context),
    );
  }


  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context){
    return Obx((){
      return FilterStripWidget(
        sorts: {...controller.filterSorts},
        conditions: {...controller.filterConditions},
        searchs: controller.filterSearchs,
        onSorts: (sorts) {
          controller.filterSorts.value = sorts;
          controller.getSuperMemoryExercises();
        },
        onConditions: (conditions) {
          controller.filterConditions.value = conditions;
          controller.getSuperMemoryExercises();
        },
        onReset: (sorts, conditions) {
          controller.filterSorts.value = sorts;
          controller.filterConditions.value = conditions;
          controller.getSuperMemoryExercises();
        },
        onSearch: () {
          controller.getSuperMemoryExercises();
        },
      );
    });
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

          const Spacer(),

          Obx((){
            return PagerWidget(
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
  Widget _buildListWidget(BuildContext context){
    return Obx((){
      return ListView.separated(
        padding: EdgeInsets.only(
          top: 24.wMin,
          left: 24.wMin,
          right: 24.wMin,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120.wMin,
        ),
        itemCount: controller.exercisesList.length,
        separatorBuilder: (context, index) {
          return SizedBox(height: 16.wMin);
        },
        itemBuilder: (context, index) {
          final entity = controller.exercisesList[index];
          return ManageSuperMemoryExercisesCardWidget(
            key: ValueKey('super_memory_card_${entity.data.id}_${entity.hashCode}'),
            entity: controller.exercisesList[index],
            onToggleExpand: () {
              controller.onToggleExpand(controller.exercisesList[index]);
            },
            // onSwitch: () {
            //   controller.chanageResolved(context, controller.exercisesList[index]);
            // },
            onAdd: !ManageAuthUtils.isAuth(ManageAuthCode.exerciseV2Create) ? null : () {
              controller.addExercise(context, controller.exercisesList[index]);
            },
            onSync: !ManageAuthUtils.isAuth(ManageAuthCode.superMemoExerciseNeedResolveAutoSync) ? null : () {
              controller.syncSuperMemory(controller.exercisesList[index]);
            },
            onExerciseDelete: !ManageAuthUtils.isAuth(ManageAuthCode.superMemoExerciseNeedResolveEdit) ? null :  (QuizModel data) {
              controller.deleteExercise(context, controller.exercisesList[index], data);
            },
            onExerciseEdit: !ManageAuthUtils.isAuth(ManageAuthCode.exerciseEdit) ? null : (QuizModel data) {
              controller.editExercise(context, controller.exercisesList[index], data);
            },
            onExerciseSwitch: !ManageAuthUtils.isAuth(ManageAuthCode.exerciseOperationCode) ? null : (QuizModel data) {
              controller.switchExercise(context, controller.exercisesList[index], data);
            },
            onPreview: (data) {
              controller.previewExercise(context, controller.exercisesList[index], data);
            },
          );
        },
      );
    });
  }

}
