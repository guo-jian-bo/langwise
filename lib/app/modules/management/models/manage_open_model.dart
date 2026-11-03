class ManageExpandModel<T>{
  T data;
  bool isExpanded;

  /// 资源类型 0=图片 1=视频
  int assetType;

  ManageExpandModel({
    required this.data,
    this.isExpanded = false,
    this.assetType = 0,
  });

}