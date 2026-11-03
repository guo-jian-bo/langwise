class ListResponseEntity<T> {
  final int? offset;
  final int? limit;
  final int? count;
  final List<T>? datas;
  final int? maxCount;

  ListResponseEntity({this.offset, this.limit, this.count, this.datas, this.maxCount});

  factory ListResponseEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    List<T>? list = [];
    if (json['datas'] != null && json['datas'].isNotEmpty) {
      if (fromJson != null) {
        list = json['datas'].map((e) => fromJson(e)).cast<T>().toList();
      } else {
        list = json['datas'] as List<T>?;
      }
    }

    return ListResponseEntity(
      offset: json["offset"],
      limit: json["limit"],
      count: json["count"],
      datas: list,
      maxCount: json['maxCount'],
    );
  }

  Map<String, dynamic> toJson() => {"offset": offset, "limit": limit, "count": count, "datas": datas};

  bool get hasData => count != null && count! > 0;
}
