import 'package:get/get.dart';
import 'package:langwise/app/modules/management/utils/utils.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';


class ManageZhenduGenerateTaskController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageZhenduGenerateTaskController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_ZHENDU_GENERATE_TASK;

  @override
  String get breadcrumbTitle => '创建记录';

  /// 传进来的参数
  String? taskType;

  final RxInt totalCount = 0.obs;
  int offset = 0;
  int limit = 20;
  final PagerController pagerController = PagerController();
  final RxList<ManageZhenduGenerateTaskEntity> dataList = <ManageZhenduGenerateTaskEntity>[].obs;


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    if(Get.arguments != null){
      taskType = Get.arguments["taskType"];
      refreshListData();
    }
  }

  /// 刷新列表数据
  Future<void> refreshListData() async{
    totalCount.value = 0;
    offset = 0;
    dataList.clear();
    await getDataList();
  }

  /// 分页器回调
  void pagerCallback(int page, int pageSize) {
    offset = (page - 1) * pageSize;
    limit = pageSize;
    refreshListData();
  }

  /// 查询记录列表
  Future<void> getDataList() async{
    if(taskType == null) return;
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> parameters = {
        "offset": offset,
        "limit": limit,
        "order": "-created",
      };
      Map<String, dynamic> reqData = {
        "taskType": [taskType],
      };

      ListResponseEntity<ManageZhenduGenerateTaskEntity>? listResponseEntity = await LanguageConsoleDramaRequest.getZhenduGenerateTaskList(
        parameters: parameters,
        data: reqData,
      );

      if(listResponseEntity == null) return;

      totalCount.value = listResponseEntity.count ?? 0;
      
      dataList.value = listResponseEntity.datas ?? [];

    } finally{
      ToastUtils.hideLoading();
    }
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
