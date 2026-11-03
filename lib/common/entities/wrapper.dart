/// 数据包装实体
///
/// 用于封装API响应中的数据对象
/// 当前包含list字段，未来可扩展更多字段
/// 泛型参数T表示列表中的项目类型
class ResponseWrapper<T> {
  /// 数据列表
  final List<T>? list;

  /// 构造函数
  ResponseWrapper({this.list});

  /// 从JSON创建实例
  factory ResponseWrapper.fromJson(
    Map<String, dynamic> json, {
    Function? fromJson,
  }) {
    List<T>? list;

    if (json['list'] != null && json['list'].isNotEmpty) {
      if (fromJson != null) {
        list = json['list'].map((e) => fromJson(e)).cast<T>().toList();
      } else {
        list = json['list'] as List<T>?;
      }
    }

    return ResponseWrapper<T>(
      list: list,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
        'list': list,
      };
}
