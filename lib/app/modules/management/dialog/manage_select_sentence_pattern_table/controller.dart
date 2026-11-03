import 'package:api/entities/entities.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/data_table_widget/data_table.dart';

class ManageSelectSentencePatternTableController extends BaseController {
  final List<SentencePatternEntity> defaultDessert;

  ManageSelectSentencePatternTableController(this.defaultDessert);

  // 选中的SentencePatternEntity
  final RxList<SentencePatternEntity> _selectedRows = <SentencePatternEntity>[].obs;

  set selectedRows(value) => _selectedRows.value = value;

  List<SentencePatternEntity> get selectedRows => _selectedRows;

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
    update(["manage_select_sentence_pattern_table"]);
  }

  // 获取数据
  Future<DesertsFakeWebServiceResponse<SentencePatternEntity>> onFetchPages(
      int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    print('---异步获取数据startingAt:$startingAt, count:$count---');
    /*
     todo 每次调取接口, 服务器都将总数50 * kDesserts.length返回, 并且也返回本次请求的数据list
     count: 每页条数, 默认20条
     调取接口时, 将每页请求的条数告诉服务器, 否则每行会有相同的key, 页面报错
     */
    try {
      final response = await SentenceUtil.fetchPatternPages(
          config: RequestConfig(parameters: {
        'offset': startingAt,
        'limit': count,
        "order": "-created"
      }, data: {
        "uid": uids.isEmpty ? null : uids,
        "name": title,
        "description": des,
      }, requireToken: true, cancelToken: cancelToken));
      if (!(response.data?.hasData ?? false)) {
        return DesertsFakeWebServiceResponse<SentencePatternEntity>(0, []);
      }
      final List<SentencePatternEntity> _entities = <SentencePatternEntity>[];
      _entities.addAll(response.data?.datas ?? []);
      return DesertsFakeWebServiceResponse<SentencePatternEntity>(response.data!.count!, _entities);
    } catch (e) {
      return DesertsFakeWebServiceResponse<SentencePatternEntity>(0, []);
    }
  }

  // 添加/移除
  void onAdd() {
    Get.back(result: [...selectedRows]);
  }

  // 选中/未选中行
  void onRowSelectChanged(bool selected, int id, SentencePatternEntity value) {
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
