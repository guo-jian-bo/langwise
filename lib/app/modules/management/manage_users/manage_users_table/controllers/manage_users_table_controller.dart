import 'package:data_table_2/data_table_2.dart';
import 'package:get/get.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../utils/manage_breadcrumb_utils.dart';

class ManageUsersTableController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageUsersTableController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_USERS_TABLE;

  @override
  String get breadcrumbTitle => '用户管理';

  AsyncDataTableSource? _dataSource;

  List<int> uids = <int>[];
  String? name;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
  }

  void onSetDataSourceAsync(AsyncDataTableSource source) {
    _dataSource = source;
  }

  void onRefresh() {
    _dataSource?.refreshDatasource();
  }

  void onSetUserId(String value, {bool isSubmit = false}) {
    uids = value
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .where((e) => e > 0)
        .toList();
    if (isSubmit) {
      onRefresh();
    }
  }

  void onSetName(String value, {bool isSubmit = false}) {
    name = value.trim().isEmpty ? null : value.trim();
    if (isSubmit) {
      onRefresh();
    }
  }

  Future<DesertsFakeWebServiceResponse<ManageUserTableEntity>> onFetchPages(
    int currentPage,
    int startingAt,
    int count,
    String sortedBy,
    bool sortedAsc,
    bool noData,
  ) async {
    Map<String, dynamic> reqData = {
      "offset": startingAt,
      "limit": count,
    };
    ListResponseEntity<ManageUserTableEntity>? userList = await AccountConsoleRequest.getUserList(data: reqData);
    if (userList == null) {
      return DesertsFakeWebServiceResponse<ManageUserTableEntity>(0, <ManageUserTableEntity>[]);
    }

    return DesertsFakeWebServiceResponse<ManageUserTableEntity>(userList.datas?.length??0, userList.datas??[]);
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
