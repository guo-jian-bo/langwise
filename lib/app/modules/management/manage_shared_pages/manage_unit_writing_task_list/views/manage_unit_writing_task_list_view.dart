import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_data.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_widget.dart';
import 'package:langwise/common/widgets/zhenxie_widgets/writing_boards/model/writing_board_data.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../routes/routes.dart';
import '../../../../../routes/tag_routes.dart';
import '../../../common/commons.dart';
import '../bindings/manage_unit_writing_task_list_binding.dart';
import '../controllers/manage_unit_writing_task_list_controller.dart';

class ManageUnitWritingTaskListView extends GetView<ManageUnitWritingTaskListController> {
  static const double _manageCardHeight = 491;
  static const double _defaultCardHeight = 437;

  final String tagText;
  const ManageUnitWritingTaskListView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ManageUnitWritingTaskListView(tagText: tag),
      binding: ManageUnitWritingTaskListBinding(tagText: tag),
      routeName: Routes.MANAGE_UNIT_WRITING_TASK_LIST,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.fetchData(showLoading: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: controller.isManagement ? _buildCreateTaskButton() : null,
      body: Column(
        children: [
          BreadcrumbWidget(
            isCompatibleManage: true,
            // actionWidget: GeneralSettingButtonWidget(
            //   isManagement: controller.isManagement,
            // ),
          ),
          Expanded(
            child: Obx(() {
              final List<ContentCardData> taskList = controller.detailData.value?.taskList ?? const <ContentCardData>[];
              if (taskList.isEmpty && controller.isLoading.value) {
                return const SizedBox.shrink();
              }
              if (taskList.isEmpty) {
                return const NotDataWidget(message: '暂无写作任务');
              }
              return GridView.builder(
                padding: EdgeInsets.fromLTRB(90.wMin, 24.wMin, 90.wMin, 140.wMin),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 24.wMin,
                  mainAxisSpacing: 24.wMin,
                  mainAxisExtent: _getCardHeight().wMin,
                ),
                itemCount: taskList.length,
                itemBuilder: (context, index) {
                  return _buildTaskCardWidget(taskList[index]);
                },
              );
            }),
          ),
          ],
        ),
    );
  }

  Widget _buildTaskCardWidget(ContentCardData item) {
    final bool hasGivenComposition = item.givenCompositionId != null;
    return ZhenxieWriteCatalogCardWidget(
      contentData: item,
      height: _getCardHeight(),
      copyLabel: '任务',
      showCopyTag: true,
      isManagement: controller.isManagement,
      onTap: () async {
        final bool? result = await TagRoutes.toNamed<bool>(
          Routes.ZHENXIE_TASK_DETAILS,
          arguments: {
            'unitId': controller.unitId,
            'taskUid': item.taskId,
            'compositionUid': item.compositionId,
            'isManagement': controller.isManagement,
            "mode": WritingBoardModeEnum.task.value,
          },
        );
        if (result == true) {
          controller.fetchData(showLoading: true);
        }
      },
      actions: controller.isManagement
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8.wMin,
              children: [
                _buildCardActionButton(
                  '删除任务',
                  backgroundColor: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                  borderColor: const Color(0xFFF43F5E).withValues(alpha: 0.20),
                  textColor: const Color(0xFFF43F5E),
                  onTap: () {
                    controller.removeTask(Get.context!, item);
                  },
                ),
                _buildCardActionButton(
                  '编辑任务',
                  backgroundColor: AppTheme.cZhenxieBackgroundPrimary.color,
                  borderColor: AppTheme.cZhenxieBorderPrimary.color,
                  textColor: AppTheme.cZhenxieFontTertiary.color,
                  onTap: () async {
                    final bool? result = await TagRoutes.toNamed<bool>(
                      Routes.MANAGE_UNIT_WRITING_TASK_EDITOR,
                      arguments: {
                        'unitId': controller.unitId,
                        'taskId': item.taskId,
                        'isManagement': controller.isManagement,
                      },
                    );
                    if (result == true) {
                      controller.fetchData(showLoading: true);
                    }
                  },
                ),
                if (item.role == 'given')
                  _buildCardActionButton(
                    hasGivenComposition ? '给拍范文' : '写给拍范文',
                    backgroundColor: hasGivenComposition
                        ? AppTheme.cZhenxieBackgroundPrimary.color
                        : AppTheme.cZhenxieColorPrimary.color.withValues(alpha: 0.12),
                    borderColor: hasGivenComposition
                        ? AppTheme.cZhenxieBorderPrimary.color
                        : AppTheme.cZhenxieColorPrimary.color.withValues(alpha: 0.20),
                    textColor: hasGivenComposition
                        ? AppTheme.cZhenxieFontTertiary.color
                        : AppTheme.cZhenxieColorPrimary.color,
                    onTap: () async {
                      final bool? result = hasGivenComposition
                          ? await TagRoutes.toNamed<bool>(
                              Routes.ZHENXIE_TASK_DETAILS,
                              arguments: {
                                'unitId': controller.unitId,
                                'taskUid': item.taskId,
                                'compositionUid': item.givenCompositionId,
                                'isManagement': controller.isManagement,
                                'role': 'given',
                                "mode": WritingBoardModeEnum.exemplar.value,
                              },
                            )
                          : await TagRoutes.toNamed<bool>(
                              Routes.MANAGE_UNIT_WRITING_TASK_EXEMPLAR,
                              arguments: {
                                'unitId': controller.unitId,
                                'taskId': item.taskId,
                                'role': 'given',
                                'isManagement': controller.isManagement,
                              },
                            );
                      if (result == true) {
                        controller.fetchData(showLoading: true);
                      }
                    },
                  ),
                _buildCardActionButton(
                  controller.getActionText(item),
                  backgroundColor: item.compositionId == null
                      ? AppTheme.cZhenxieColorPrimary.color.withValues(alpha: 0.12)
                      : AppTheme.cZhenxieBackgroundPrimary.color,
                  borderColor: item.compositionId == null
                      ? AppTheme.cZhenxieColorPrimary.color.withValues(alpha: 0.20)
                      : AppTheme.cZhenxieBorderPrimary.color,
                  textColor: item.compositionId == null
                      ? AppTheme.cZhenxieColorPrimary.color
                      : AppTheme.cZhenxieFontTertiary.color,
                  onTap: () async {
                    final bool? result = item.compositionId == null
                        ? await TagRoutes.toNamed<bool>(
                            Routes.MANAGE_UNIT_WRITING_TASK_EXEMPLAR,
                            arguments: {
                              'unitId': controller.unitId,
                              'taskId': item.taskId,
                              'exemplarCompositionId': item.compositionId,
                              'isManagement': controller.isManagement,
                            },
                          )
                        : await TagRoutes.toNamed<bool>(
                            Routes.ZHENXIE_TASK_DETAILS,
                            arguments: {
                              'unitId': controller.unitId,
                              'taskUid': item.taskId,
                              'compositionUid': item.compositionId,
                              'isManagement': controller.isManagement,
                              "mode": WritingBoardModeEnum.exemplar.value,
                            },
                          );
                    if (result == true) {
                      controller.fetchData(showLoading: true);
                    }
                  },
                ),
              ],
            )
          : null,
    );
  }

  double _getCardHeight() {
    return controller.isManagement ? _manageCardHeight : _defaultCardHeight;
  }

  Widget _buildCardActionButton(
    String text, {
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 17.wMin, vertical: 10.wMin),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(9999.wMin),
          border: Border.all(
            color: borderColor,
            width: 1.wMin,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: textColor,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateTaskButton() {
    return GestureDetector(
      onTap: () async {
        final bool? result = await TagRoutes.toNamed<bool>(
          Routes.MANAGE_UNIT_WRITING_TASK_EDITOR,
          arguments: {
            'unitId': controller.unitId,
            'isManagement': controller.isManagement,
          },
        );
        if (result == true) {
          controller.fetchData(showLoading: true);
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(15.wMin, 17.wMin, 19.wMin, 17.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cBorderTranslucentDefault.color,
          borderRadius: BorderRadius.circular(99.wMin),
          border: Border.all(
            color: AppTheme.cBorderTranslucentThin.color,
            width: 1.wMin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 28.wMin,
              color: AppTheme.cTextPrimary.color,
            ),
            SizedBox(width: 4.wMin),
            Text(
              '新建任务',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
