import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/activity_console_task_entities.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../common/commons.dart';
import '../bindings/manage_task_binding.dart';
import '../controllers/manage_task_controller.dart';
import 'manage_task_create_dialog.dart';

class ManageTaskView extends GetView<ManageTaskController> {
  final String tagText;
  const ManageTaskView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_TASK}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageTaskView(tagText: tag),
      binding: ManageTaskBinding(tag: tag),
      routeName: Routes.MANAGE_TASK,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      backgroundColor: const Color(0xFF050916),
      body: Padding(
        padding: EdgeInsets.all(24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '任务管理',
                  style: TextStyle(color: Colors.white, fontSize: 28.wMin, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    ManageTaskCreateDialog.show(context: context);
                  },
                  child: Container(
                    height: 40.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 14.wMin),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2388FF),
                      borderRadius: BorderRadius.circular(6.wMin),
                    ),
                    alignment: Alignment.center,
                    child: Text('创建任务', style: TextStyle(color: Colors.white, fontSize: 14.wMin)),
                  ),
                ),
                SizedBox(width: 12.wMin),
                GestureDetector(
                  onTap: controller.fetchTaskList,
                  child: Container(
                    height: 40.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 14.wMin),
                    decoration: BoxDecoration(
                      color: const Color(0xFF353E5C),
                      borderRadius: BorderRadius.circular(6.wMin),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    alignment: Alignment.center,
                    child: Text('刷新', style: TextStyle(color: Colors.white, fontSize: 14.wMin)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.wMin),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(controller.errorMessage.value, style: TextStyle(color: Colors.white70, fontSize: 14.wMin)),
                        SizedBox(height: 12.wMin),
                        GestureDetector(
                          onTap: controller.fetchTaskList,
                          child: Container(
                            height: 40.wMin,
                            padding: EdgeInsets.symmetric(horizontal: 14.wMin),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2388FF),
                              borderRadius: BorderRadius.circular(6.wMin),
                            ),
                            alignment: Alignment.center,
                            child: Text('重试', style: TextStyle(color: Colors.white, fontSize: 14.wMin)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final list = controller.taskList;
                if (list.isEmpty) {
                  return Center(child: Text('暂无任务', style: TextStyle(color: Colors.white70, fontSize: 14.wMin)));
                }

                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.wMin),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _taskCard(item);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskCard(ActivityConsoleTaskItem item) {
    final title = (item.name ?? '').trim();
    final code = (item.taskCode ?? '').trim();
    final type = (item.taskType ?? '').trim();
    final groupCode = (item.groupCode ?? '').trim();
    final groupMode = (item.groupMode ?? '').trim();
    final access = (item.access ?? '').trim();
    final startDate = (item.startDate ?? '').trim();
    final endDate = (item.endDate ?? '').trim();
    final priority = item.priority;
    final sequenceOrder = item.sequenceOrder;
    final stepCount = item.steps?.length ?? 0;

    Widget buildLine(String label, String value) {
      return Padding(
        padding: EdgeInsets.only(top: 6.wMin),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 92.wMin,
              child: Text(label, style: TextStyle(color: Colors.white54, fontSize: 12.wMin)),
            ),
            Expanded(child: Text(value, style: TextStyle(color: Colors.white, fontSize: 12.wMin))),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(14.wMin),
      decoration: BoxDecoration(
        color: const Color(0xFF22293C),
        borderRadius: BorderRadius.circular(10.wMin),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.isNotEmpty ? title : (code.isNotEmpty ? code : '未命名任务'),
                  style: TextStyle(color: Colors.white, fontSize: 16.wMin, fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ToastUtils.showManageToast(text: '编辑任务（待实现）', type: ManageToastType.defaultType);
                },
                child: Container(
                  height: 32.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                  decoration: BoxDecoration(
                    color: const Color(0xFF353E5C),
                    borderRadius: BorderRadius.circular(6.wMin),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  alignment: Alignment.center,
                  child: Text('编辑', style: TextStyle(color: Colors.white, fontSize: 12.wMin)),
                ),
              ),
            ],
          ),
          if (code.isNotEmpty) buildLine('TaskCode', code),
          if (type.isNotEmpty) buildLine('任务类型', type),
          if (groupCode.isNotEmpty) buildLine('分组', groupCode),
          if (groupMode.isNotEmpty) buildLine('分组模式', groupMode),
          if (sequenceOrder != null) buildLine('顺序', sequenceOrder.toString()),
          if (priority != null) buildLine('优先级', priority.toString()),
          if (access.isNotEmpty) buildLine('访问', access),
          if (startDate.isNotEmpty || endDate.isNotEmpty) buildLine('有效期', '${startDate.isNotEmpty ? startDate : '-'} ~ ${endDate.isNotEmpty ? endDate : '-'}'),
          if (stepCount > 0) buildLine('步骤数', stepCount.toString()),
        ],
      ),
    );
  }
}
