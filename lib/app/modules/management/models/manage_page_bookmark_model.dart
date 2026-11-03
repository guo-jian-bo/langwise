
class ManagePageBookmarkModel{

  String route;
  String name;
  String? remark;
  dynamic arguments;

  ManagePageBookmarkModel({
    required this.route, 
    required this.name, 
    this.arguments,
    this.remark,
  });

}