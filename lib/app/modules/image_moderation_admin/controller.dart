import 'package:api/entities/entities.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/widgets/data_table_widget/data_sources.dart';
import 'state.dart';

/// 审核人管理控制器
class ImageModerationAdminController extends GetxController {
  /// 获取控制器实例
  static ImageModerationAdminController get to {
    if (!Get.isRegistered<ImageModerationAdminController>()) {
      Get.put(ImageModerationAdminController());
    }
    return Get.find<ImageModerationAdminController>();
  }

  /// 状态对象
  final state = ImageModerationAdminState();

  // table控制器
  AsyncDataTableSource? dessertDataSourceAsync;

  @override
  void onReady() {
    super.onReady();
    update();
  }

  /// 设置搜索关键词
  void setSearchTerm(String value, {bool isSubmit = false}) {
    state.searchTerm = value;
    if (isSubmit) {
      _onRefresh();
    }
    update([ImageModerationAdminState.searchId, ImageModerationAdminState.reviewersListId]);
  }

  /// 设置排序字段和方向
  void setSort(String field) {
    if (state.sortField == field) {
      // 如果点击的是当前排序字段，则切换排序方向
      state.sortDirection = state.sortDirection == 'asc' ? 'desc' : 'asc';
    } else {
      // 如果点击的是新字段，默认降序排列
      state.sortField = field;
      state.sortDirection = 'desc';
    }

    _onRefresh();
    update([ImageModerationAdminState.sortId, ImageModerationAdminState.reviewersListId]);
  }

  /// 获取分页数据
  Future<DesertsFakeWebServiceResponse<ReviewerEntity>> onFetchPages(
      int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    /*
     todo 每次调取接口, 服务器都将总数50 * kDesserts.length返回, 并且也返回本次请求的数据list
     count: 每页条数, 默认20条
     调取接口时, 将每页请求的条数告诉服务器, 否则每行会有相同的key, 页面报错
     */
    try {
      // 构建排序参数，如果是降序则添加负号前缀
      final String orderPrefix = state.sortDirection == 'desc' ? '-' : '';
      final String orderField = state.sortField.isNotEmpty ? state.sortField : 'reviewedImageCount';

      final response = await AdminUtil.fetchReviewers(
          config: RequestConfig(parameters: {
        'offset': startingAt,
        'limit': count,
        'order': '$orderPrefix$orderField',
      }, requireToken: true));

      if (!(response.data?.hasData ?? false)) {
        return DesertsFakeWebServiceResponse<ReviewerEntity>(0, []);
      }

      return DesertsFakeWebServiceResponse<ReviewerEntity>(response.data!.count!, response.data?.datas ?? []);
    } catch (e) {
      print('Error fetching reviewers: $e');
      return DesertsFakeWebServiceResponse<ReviewerEntity>(0, []);
    }
  }

  Future<DesertsFakeWebServiceResponse<ReviewerEntity>> onFetchSearchPages(
      int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    /*
     todo 每次调取接口, 服务器都将总数50 * kDesserts.length返回, 并且也返回本次请求的数据list
     count: 每页条数, 默认20条
     调取接口时, 将每页请求的条数告诉服务器, 否则每行会有相同的key, 页面报错
     */
    try {
      // 构建排序参数，如果是降序则添加负号前缀
      final String orderPrefix = state.sortDirection == 'desc' ? '-' : '';
      final String orderField = state.sortField.isNotEmpty ? state.sortField : 'reviewedImageCount';

      final response = await AdminUtil.search(
          config: RequestConfig(parameters: {
        'content': state.searchTerm,
        'order': '$orderPrefix$orderField',
      }, requireToken: true));

      if (!(response.data?.hasData ?? false)) {
        return DesertsFakeWebServiceResponse<ReviewerEntity>(0, []);
      }

      return DesertsFakeWebServiceResponse<ReviewerEntity>(response.data!.count!, response.data?.datas ?? []);
    } catch (e) {
      print('Error fetching reviewers: $e');
      return DesertsFakeWebServiceResponse<ReviewerEntity>(0, []);
    }
  }

  /// 查看审核人详情
  void toReviewerDetail(ReviewerEntity? reviewer) {
    Get.toNamed(Routes.IMAGE_MODERATION_ADMIN_DETAIL, arguments: {'inspectorId': reviewer?.userId})?.then((value) {
      _onRefresh();
    });
  }

  // 异步数据处理器
  void onSetDataSourceAsync(AsyncDataTableSource? source) {
    dessertDataSourceAsync = source;
  }

  /// 刷新数据
  void _onRefresh() {
    if (dessertDataSourceAsync != null) {
      dessertDataSourceAsync!.refreshDatasource();
    }
  }

  @override
  void onClose() {
    state.clear();
    super.onClose();
  }
}
