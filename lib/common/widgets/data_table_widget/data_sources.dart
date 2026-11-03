import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

/// Keeps track of selected rows, feed the data into DesertsDataSource
// class RestorableDessertSelections extends RestorableProperty<Set<int>> {
//   Set<int> _dessertSelections = {};
//
//   /// Returns whether or not a dessert row is selected by index.
//   bool isSelected(int index) => _dessertSelections.contains(index);
//
//   /// Takes a list of [Dessert]s and saves the row indices of selected rows
//   /// into a [Set].
//   void setDessertSelections(List<Dessert> desserts) {
//     final updatedSet = <int>{};
//     for (var i = 0; i < desserts.length; i += 1) {
//       var dessert = desserts[i];
//       if (dessert.selected) {
//         updatedSet.add(i);
//       }
//     }
//     _dessertSelections = updatedSet;
//     notifyListeners();
//   }
//
//   @override
//   Set<int> createDefaultValue() => _dessertSelections;
//
//   @override
//   Set<int> fromPrimitives(Object? data) {
//     final selectedItemIndices = data as List<dynamic>;
//     _dessertSelections = {
//       ...selectedItemIndices.map<int>((dynamic id) => id as int),
//     };
//     return _dessertSelections;
//   }
//
//   @override
//   void initWithValue(Set<int> value) {
//     _dessertSelections = value;
//   }
//
//   @override
//   Object toPrimitives() => _dessertSelections.toList();
// }

/// Domain model entity
abstract class Dessert {
  final int uid;
  final int? calories;

  // 标识是否选中，默认值为 false
  bool selected;

  Dessert({required this.uid, this.calories, this.selected = false});
}

// 接收数据回调
typedef DataSourceBuilder<T extends Dessert> = List<DataCell>? Function(int index, T value);

typedef DataCellBuilder<T extends Dessert> = List<DataCell> Function(T value, int startIndex);

typedef FetchDataBuilder<T extends Dessert> = Future<DesertsFakeWebServiceResponse<T>> Function(
    int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData);

typedef AsyncDataTableSourceCallback = Function(AsyncDataTableSource source);

typedef SyncDataTableSourceCallback = Function(DessertDataSource source);

// 选择回调
typedef OnRowSelectChanged<T extends Dessert> = void Function(bool selected, int id, T value);

/*
  同步获取表格数据
 */
class DessertDataSource<T extends Dessert> extends DataTableSource {
  final BuildContext context;
  List<T> desserts;

  // 泛型带上
  final DataSourceBuilder<T>? builder;

  // Add row tap handlers and show snackbar
  bool hasRowTaps = false;

  // Override height values for certain rows
  bool hasRowHeightOverrides = false;

  // Color each Row by index's parity
  bool hasZebraStripes = false;

  // 行是否禁用
  final bool Function(T)? dataDisableCallback;

  // 电脑端按下鼠标右键
  final Function(int index, T)? onSecondaryTap;

  // 选中/未选中回调
  final OnRowSelectChanged<T>? onRowSelectChanged;

  // 初始化
  DessertDataSource(this.context,
      {this.desserts = const [],
      this.builder,
      this.hasRowTaps = false,
      this.hasRowHeightOverrides = false,
      this.hasZebraStripes = false,
      this.dataDisableCallback,
      this.onSecondaryTap,
      this.onRowSelectChanged});

  DessertDataSource.empty(this.context, {this.desserts = const [], this.builder, this.onSecondaryTap, this.dataDisableCallback, this.onRowSelectChanged}) {
    desserts.clear();
  }

  // 设置数据
  void setDesserts(final List<T> ds) {
    desserts = ds;
    refresh();
  }

  // 排序
  // void sort(Comparable Function(Dessert d) getField, bool ascending) {
  //   desserts.sort((a, b) {
  //     final aValue = getField(a);
  //     final bValue = getField(b);
  //     return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
  //   });
  //   notifyListeners();
  // }

  void sort<T>(Comparable<T> Function(Dessert d) getField, bool ascending) {
    desserts.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  // 更新选中的行
  // void updateSelectedDesserts(RestorableDessertSelections selectedRows) {
  //   _selectedCount = 0;
  //   // for (var i = 0; i < desserts.length; i += 1) {
  //   //   var dessert = desserts[i];
  //   //   if (selectedRows.isSelected(i)) {
  //   //     dessert.selected = true;
  //   //     _selectedCount += 1;
  //   //   } else {
  //   //     dessert.selected = false;
  //   //   }
  //   // }
  //   notifyListeners();
  // }

  // 配置行
  @override
  DataRow2 getRow(int index, [Color? color]) {
    // final format = NumberFormat.decimalPercentPattern(
    //   locale: 'en',
    //   decimalDigits: 0,
    // );
    assert(index >= 0);
    if (index >= desserts.length) throw 'index > _desserts.length';
    final dessert = desserts[index];
    final bool isDisable = (dataDisableCallback?.call(dessert) ?? false);

    return DataRow2.byIndex(
        index: index,
        selected: dessert.selected,
        color: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            // if (states.contains(WidgetState.hovered)) {
            //   // 悬停变红
            //   return Colors.red.withValues(alpha: 0.3);
            // }
            if (states.contains(WidgetState.selected)) {
              return Colors.transparent;
              // return Colors.blue.withValues(alpha: 0.3); // 选中变蓝
            }

            if (states.contains(WidgetState.pressed)) {
              return Colors.transparent;
              // return Colors.blue.withValues(alpha: 0.3); // 选中变蓝
            }
            return (index % 2 == 0) ? const Color(0xff23283D).withValues(alpha: 0.3) : Colors.transparent; // 默认颜色
          },
        ),
        // onSelectChanged: (value) {
        //   if (dessert.selected != value) {
        //     _selectedCount += value! ? 1 : -1;
        //     assert(_selectedCount >= 0);
        //     dessert.selected = value;
        //     onRowSelectChanged?.call(value, dessert.uid, dessert);
        //     refresh();
        //   }
        // },
        // 禁用某一行(dataDisableCallback?.call(dessert) ?? false)
        onSelectChanged: isDisable
            ? null
            : (value) {
                print('---😆😆选中行uid:${dessert.uid},value: $value😆😆---');
                if (value != null) {
                  dessert.selected = value;
                  onRowSelectChanged?.call(value, dessert.uid, dessert);
                  refresh();
                }
              },
        onTap: hasRowTaps ? () => _showSnackbar(context, 'Tapped on row ${dessert.uid}') : null,
        onDoubleTap: hasRowTaps ? () => _showSnackbar(context, 'Double Tapped on row ${dessert.uid}') : null,
        onLongPress: hasRowTaps ? () => _showSnackbar(context, 'Double Tapped on row ${dessert.uid}') : null,
        onSecondaryTap: () {
          onSecondaryTap?.call(index, dessert);
        },
        onSecondaryTapDown: hasRowTaps ? (d) => _showSnackbar(context, 'Right button down on row ${dessert.uid}') : null,
        // 指定的行高度/由table指定,这里注释
        // specificRowHeight: 48,
        // specificRowHeight: hasRowHeightOverrides && dessert.fat >= 25 ? 100 : null,
        cells: builder?.call(index, dessert) ?? []);
  }

  // 行数
  @override
  int get rowCount => desserts.length;

  // 确定[rowCount]是一个精确的数字还是可能是一个高估。
  @override
  bool get isRowCountApproximate => false;

  // 选中所有行
  void selectAll(bool? checked) {
    for (final dessert in desserts) {
      dessert.selected = checked ?? false;
    }
    refresh();
  }

  // 刷新数据
  void refresh() {
    notifyListeners();
  }

  // 选中的行数(默认为0)
  @override
  int get selectedRowCount => 0;
}

/*
  异步获取表格数据
 */
class DessertDataSourceAsync<T extends Dessert> extends AsyncDataTableSource {
  DessertDataSourceAsync(
      {this.autoSelected = true,
      this.noData = false,
      this.fewerResultsAfterRefresh = false,
      this.defaultDessert,
      this.defaultRowBgColor,
      required this.fetchData,
      required this.dataCellBuilder,
      this.dataDisableCallback,
      this.onRowSelectChanged});

  // 自动选中状态
  final bool autoSelected;
  final bool noData;
  final bool fewerResultsAfterRefresh;

  // 默认数据/回显选中/未选中状态
  final List<T>? defaultDessert;
  final Color? defaultRowBgColor;
  final FetchDataBuilder<T> fetchData;
  final DataCellBuilder<T> dataCellBuilder;
  final bool Function(T)? dataDisableCallback;
  final OnRowSelectChanged<T>? onRowSelectChanged;

  int get generation => _generation;

  int _generation = 0;

  set generation(int value) {
    if (_generation == value) return;
    _generation = value;
    notifyListeners();
  }

  final bool _empty = false;
  int? _errorCounter;

  // 排序字段
  String _sortColumn = "name";
  bool _sortAscending = true;

  void sort(String columnName, bool ascending) {
    _sortColumn = columnName;
    _sortAscending = ascending;
    refreshDatasource();
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    /*
    startIndex: 开始的索引
    count: 每页多少条数据
    todo 每页20/30条数据切换时, 也会执行这个方法, 需要将count参数回调给外部list接口,请求20/30条数据过来,否则下面每行的key会有重复、报错
     */
    final currentPage = (startIndex ~/ count) + 1; // 计算当前页码
    print('---😆😆获取行getRows(currentPage: $currentPage, startIndex:$startIndex,count:$count)');
    if (_errorCounter != null) {
      _errorCounter = _errorCounter! + 1;
      if (_errorCounter! % 2 == 1) {
        await Future.delayed(const Duration(milliseconds: 1000));
        throw 'Error #${((_errorCounter! - 1) / 2).round() + 1} has occured';
      }
    }

    var tempIndex = startIndex;
    assert(tempIndex >= 0);

    late DesertsFakeWebServiceResponse<T> x;
    if (_empty) {
      await Future.delayed(const Duration(milliseconds: 2000), () => DesertsFakeWebServiceResponse(0, <T>[]));
    } else {
      x = await fetchData(currentPage, startIndex, count, _sortColumn, _sortAscending, noData);
    }

    final List<DataRow> rows = List<DataRow>.generate(x.data.length, (int i) {
      final dessert = x.data[i];
      final bool isDisable = (dataDisableCallback?.call(dessert) ?? false);
      // print("---😆😆uid:${dessert.uid}😆😆---");
      return DataRow(
        // todo 默认20条数据/重要,因为Row的key的唯一性跟这个有关
        key: ValueKey<int>(dessert.uid),
        // 直接根据集合设置选中状态
        selected: dessert.selected,
        color: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            // if (states.contains(WidgetState.hovered)) {
            //   // 悬停变红
            //   return Colors.red.withValues(alpha: 0.3);
            // }

            if (states.contains(WidgetState.selected)) {
              // 选中颜色, 暂时设置为透明
              return Colors.transparent;
              // return Colors.blue.withValues(alpha: 0.3); // 选中变蓝
            }

            if (defaultRowBgColor != null) {
              return defaultRowBgColor;
            }

            return (i % 2 == 0) ? const Color(0xff23283D).withValues(alpha: 0.3) : Colors.transparent; // 默认颜色
          },
        ),
        // 禁用某一行(dataDisableCallback?.call(dessert) ?? false)
        onSelectChanged: isDisable
            ? null
            : (value) {
                print('---😆😆选中行uid:${dessert.uid},value: $value😆😆---');
                if (value != null) {
                  // 点击单元格自动改变选中状态
                  if (autoSelected) {
                    dessert.selected = value;
                    setRowSelection(ValueKey<int>(dessert.uid), value);
                  }

                  // 回调id和完整的数据对象
                  onRowSelectChanged?.call(value, dessert.uid, dessert);
                }
              },
        cells: dataCellBuilder.call(dessert, startIndex),
      );
    }).toList();

    // 关键步骤：在下一帧设置默认选中状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (defaultDessert != null) {
        for (final dessert in x.data) {
          final isSelected = defaultDessert!.any((d) => d.uid == dessert.uid);
          if (isSelected) {
            setRowSelection(ValueKey<int>(dessert.uid), true);
          }
        }
      }
    });
    return AsyncRowsResponse(x.totalRecords, rows);
  }

  // 外部改变单元格状态
  void setRowSelect(Dessert dessert, {required bool value}) {
    dessert.selected = value;
    setRowSelection(ValueKey<int>(dessert.uid), value);
  }
}

extension AsyncDataTableSourceExtension on AsyncDataTableSource {
  // 刷新数据
  void refresh() {
    refreshDatasource();
  }
}

class DesertsFakeWebServiceResponse<T extends Dessert> {
  DesertsFakeWebServiceResponse(this.totalRecords, this.data);

  /// THe total ammount of records on the server, e.g. 100
  final int totalRecords;

  /// One page, e.g. 10 reocrds
  final List<T> data;
}

_showSnackbar(BuildContext context, String text, [Color? color]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: color,
    duration: const Duration(seconds: 1),
    content: Text(text),
  ));
}
