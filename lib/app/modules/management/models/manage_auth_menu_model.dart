



class ManageAuthMenuModel{

  String name;
  String subtitle;
  String authCode;
  String route;
  Map<String, dynamic>? params;

  ManageAuthMenuModel({
    required this.name,
    required this.subtitle,
    required this.authCode,
    required this.route,
    this.params,
  });

}