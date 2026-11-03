import 'dart:math' as math;

import 'package:data_table_2/data_table_2.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../views/manage_product_entity.dart';
import '../views/static_servicepkg.dart';

class ManageProductsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageProductsController({required this.tag});

  final List<ManageProductEntity> _allProducts = <ManageProductEntity>[];
  AsyncDataTableSource? _dataSource;

  List<int> uids = <int>[];
  String? name;
  String? description;

  @override
  String get breadcrumbRoute => Routes.MANAGE_PRODUCTS;

  @override
  String get breadcrumbTitle => '商品管理';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    _allProducts.addAll(_buildProducts());
  }

  void onSetDataSourceAsync(AsyncDataTableSource source) {
    _dataSource = source;
  }

  void onRefresh() {
    _dataSource?.refreshDatasource();
  }

  void onSetUid(String value, {bool isSubmit = false}) {
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

  void onSetDescription(String value, {bool isSubmit = false}) {
    description = value.trim().isEmpty ? null : value.trim();
    if (isSubmit) {
      onRefresh();
    }
  }

  Future<DesertsFakeWebServiceResponse<ManageProductEntity>> onFetchPages(
    int currentPage,
    int startingAt,
    int count,
    String sortedBy,
    bool sortedAsc,
    bool noData,
  ) async {
    final filteredProducts = _sortProducts(
      _filterProducts(),
      sortedBy: sortedBy,
      sortedAsc: sortedAsc,
    );
    if (filteredProducts.isEmpty || startingAt >= filteredProducts.length) {
      return DesertsFakeWebServiceResponse<ManageProductEntity>(filteredProducts.length, <ManageProductEntity>[]);
    }

    final end = math.min(startingAt + count, filteredProducts.length);
    final pageData = filteredProducts.sublist(startingAt, end);
    return DesertsFakeWebServiceResponse<ManageProductEntity>(filteredProducts.length, pageData);
  }

  List<ManageProductEntity> _buildProducts() {
    final List<ManageProductEntity> products = <ManageProductEntity>[];
    final Map<String, dynamic> testJson = staticServicePkg;
    final List<dynamic>? datas = testJson['datas'] as List<dynamic>?;
    if (datas == null) {
      return products;
    }
    for (final dynamic element in datas) {
      if (element is Map<String, dynamic>) {
        products.add(ManageProductEntity.fromJson(element));
      }
    }
    return products;
  }

  List<ManageProductEntity> _filterProducts() {
    return _allProducts.where((item) {
      final bool uidMatch = uids.isEmpty || uids.contains(item.uid);
      final bool nameMatch = _containsText(item.name, name);
      final bool descriptionMatch = _containsText(item.describe, description);
      return uidMatch && nameMatch && descriptionMatch;
    }).toList();
  }

  List<ManageProductEntity> _sortProducts(
    List<ManageProductEntity> products, {
    required String sortedBy,
    required bool sortedAsc,
  }) {
    final List<ManageProductEntity> sortedProducts = List<ManageProductEntity>.from(products);
    final String sortField = sortedBy.isEmpty ? 'uid' : sortedBy;
    sortedProducts.sort((a, b) {
      final int result;
      switch (sortField) {
        case 'name':
          result = _compareString(a.name, b.name);
          break;
        case 'category':
          result = _compareString(a.category, b.category);
          break;
        case 'describe':
          result = _compareString(a.describe, b.describe);
          break;
        case 'payMethod':
          result = _compareString(a.payMethod, b.payMethod);
          break;
        case 'price':
          result = _compareInt(a.price, b.price);
          break;
        case 'created':
          result = _compareString(a.created, b.created);
          break;
        case 'uid':
        default:
          result = _compareInt(a.uid, b.uid);
          break;
      }
      return sortedAsc ? result : -result;
    });
    return sortedProducts;
  }

  bool _containsText(String? source, String? keyword) {
    if (keyword == null || keyword.isEmpty) {
      return true;
    }
    return (source ?? '').toLowerCase().contains(keyword.toLowerCase());
  }

  int _compareString(String? a, String? b) {
    return (a ?? '').compareTo(b ?? '');
  }

  int _compareInt(int? a, int? b) {
    return (a ?? 0).compareTo(b ?? 0);
  }
}
