import 'package:api/entities/entities.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/data_table_widget/data_table.dart';

class ManageSelectLevelTableController extends BaseController {
  final List<LevelResponseEntity> defaultDessert;

  ManageSelectLevelTableController(this.defaultDessert);

  // 选中的LevelResponseEntity
  final RxList<LevelResponseEntity> _selectedRows = <LevelResponseEntity>[].obs;

  set selectedRows(value) => _selectedRows.value = value;

  List<LevelResponseEntity> get selectedRows => _selectedRows;

  @override
  onInit() {
    super.onInit();
    selectedRows.addAll(defaultDessert);
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(["manage_select_level_table"]);
  }

  // 获取数据
  Future<DesertsFakeWebServiceResponse<LevelResponseEntity>> onFetchPages(
      int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    print('---异步获取数据startingAt:$startingAt, count:$count😆😆---');
    /*
     todo 每次调取接口, 服务器都将总数50 * kDesserts.length返回, 并且也返回本次请求的数据list
     count: 每页条数, 默认20条
     调取接口时, 将每页请求的条数告诉服务器, 否则每行会有相同的key, 页面报错
     */
    try {
      final response = await LevelUtil.fetchPages(
          config: RequestConfig(parameters: {
        'offset': startingAt,
        'limit': count,
      }, data: {
        "uid": uids.isEmpty ? null : uids,
        "name": title,
      }, requireToken: true, cancelToken: cancelToken));
      if (!(response.data?.hasData ?? false)) {
        return DesertsFakeWebServiceResponse<LevelResponseEntity>(0, []);
      }
      final List<LevelResponseEntity> _entities = <LevelResponseEntity>[];
      _entities.addAll(response.data?.datas ?? []);
      return DesertsFakeWebServiceResponse<LevelResponseEntity>(response.data!.count!, _entities);
    } catch (e) {
      return DesertsFakeWebServiceResponse<LevelResponseEntity>(0, []);
    }
  }

  // 添加/移除
  void onAdd() {
    Get.back(result: [...selectedRows]);
  }

  // 选中/未选中行
  void onRowSelectChanged(bool selected, int id, LevelResponseEntity value) {
    print(value.uid);
    if (selected) {
      selectedRows.add(value);
    } else {
      selectedRows.remove(value);
    }
  }

  @override
  void onClose() {
    super.onClose();
    selectedRows.clear();
  }
}
