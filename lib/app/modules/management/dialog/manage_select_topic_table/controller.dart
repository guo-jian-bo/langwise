import 'package:api/entities/entities.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/data_table_widget/data_table.dart';

class ManageSelectTopicTableController extends BaseController {
  final List<EnEntityTopic> defaultDessert;

  ManageSelectTopicTableController(this.defaultDessert);

  // 选中的TopicEntity
  final RxList<EnEntityTopic> _selectedRows = <EnEntityTopic>[].obs;

  set selectedRows(value) => _selectedRows.value = value;

  List<EnEntityTopic> get selectedRows => _selectedRows;

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
    update(["manage_select_topic_table"]);
  }

  // 获取数据
  Future<DesertsFakeWebServiceResponse<EnEntityTopic>> onFetchPages(
      int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    try {
      final response = await TopicUtil.fetchPages(
          config: RequestConfig(parameters: {
        'offset': startingAt,
        'limit': count,
        "order": "-uid"
      }, data: {
        "uid": uids.isEmpty ? null : uids,
        "title": title,
      }, requireToken: true, cancelToken: cancelToken));

      if (!(response.data?.hasData ?? false)) {
        return DesertsFakeWebServiceResponse<EnEntityTopic>(0, []);
      }
      return DesertsFakeWebServiceResponse<EnEntityTopic>(response.data!.count!, (response.data?.datas ?? []));
    } catch (e) {
      return DesertsFakeWebServiceResponse<EnEntityTopic>(0, []);
    }
  }

  // 添加/移除
  void onAdd() {
    Get.back(result: [...selectedRows]);
  }

  // 选中/未选中行
  void onRowSelectChanged(bool selected, int id, EnEntityTopic value) {
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
