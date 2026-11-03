class ManageExpandModel<T>{
  T data;
  bool isExpanded;

  ManageExpandModel({
    required this.data,
    this.isExpanded = false,
  });

}