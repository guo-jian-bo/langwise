import 'package:flutter/material.dart';

import 'manage_admin_console_menu_enum.dart';

class ManageAdminConsoleMenuModel{
  ManageAdminConsoleMenuEnum menu;

  String title;
  String desc;
  Color iconBgColor;
  String svg;
  List<String>? tags;

  ManageAdminConsoleMenuModel({
    required this.menu,
    required this.title,
    required this.desc,
    required this.iconBgColor,
    required this.svg,
    this.tags,
  });


}