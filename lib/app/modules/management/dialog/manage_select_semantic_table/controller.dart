import 'package:api/entities/entities.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/data_table_widget/data_table.dart';

class ManageSelectSemanticTableController extends BaseController {
  final List<EnEntitySemantics> defaultDessert;

  ManageSelectSemanticTableController(this.defaultDessert);

  // 选中的SemanticEntity
  final RxList<EnEntitySemantics> _selectedRows = <EnEntitySemantics>[].obs;

  set selectedRows(value) => _selectedRows.value = value;

  List<EnEntitySemantics> get selectedRows => _selectedRows;

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
    update(["manage_select_semantic_table"]);
  }

  // 获取数据
  Future<DesertsFakeWebServiceResponse<EnEntitySemantics>> onFetchPages(
      int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    /*
     todo 每次调取接口, 服务器都将总数50 * kDesserts.length返回, 并且也返回本次请求的数据list
     count: 每页条数, 默认20条
     调取接口时, 将每页请求的条数告诉服务器, 否则每行会有相同的key, 页面报错
     */
    try {
      final response = await SemanticUtil.fetchPages(
          config: RequestConfig(parameters: {
        'offset': startingAt,
        'limit': count,
        "order": "difficulty,-uid"
      }, data: {
        "uid": uids.isEmpty ? null : uids,
        "descriptions": des,
      }, requireToken: true, cancelToken: cancelToken));
      if (!(response.data?.hasData ?? false)) {
        return DesertsFakeWebServiceResponse<EnEntitySemantics>(0, []);
      }
      return DesertsFakeWebServiceResponse<EnEntitySemantics>(response.data!.count!, (response.data?.datas ?? []));
    } catch (e) {
      return DesertsFakeWebServiceResponse<EnEntitySemantics>(0, []);
    }
  }

  // 添加/移除
  void onAdd() {
    Get.back(result: [...selectedRows]);
  }

  // 选中/未选中行
  void onRowSelectChanged(bool selected, int id, EnEntitySemantics value) {
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
