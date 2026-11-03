import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/activity_console_task_entities.dart';
import 'package:langwise/common/https/activity_console_task.dart';

import '../../../utils/manage_breadcrumb_utils.dart';

class ManageTaskController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageTaskController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_TASK;

  @override
  String get breadcrumbTitle => '任务管理';

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ActivityConsoleTaskItem> taskList = <ActivityConsoleTaskItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    fetchTaskList();
  }

  Future<void> fetchTaskList() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final res = await ActivityConsoleTaskRequest.list();
      if (res == null) {
        taskList.clear();
        errorMessage.value = '请求失败';
        return;
      }
      final data = res.data;
      if (data?.list == null) {
        taskList.clear();
        return;
      }

      taskList.assignAll(data!.list!);
    } catch (_) {
      errorMessage.value = '请求失败';
    } finally {
      isLoading.value = false;
    }
  }
}
