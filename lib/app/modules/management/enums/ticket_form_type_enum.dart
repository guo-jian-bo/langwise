import 'package:get/get.dart';

/// 工单模版表单类型
enum TicketFormTypeEnum {
  /// 单行文本
  TEXT("TEXT", "单行文本", "assets/svg/manage/icon_single_line_text.svg"),
  /// 多行文本
  TEXTAREA("TEXTAREA", "多行文本", "assets/svg/manage/icon_multi_line_text.svg"),
  /// 数字
  NUMBER("NUMBER", "数字", "assets/svg/manage/icon_number.svg"),
  /// 手机号
  PHONE("PHONE", "手机号", "assets/svg/manage/icon_phone.svg"),
  /// ISBN
  ISBN("ISBN", "ISBN", "assets/svg/manage/icon_single_line_text.svg"),

  /// 单选框
  RADIO("RADIO", "单选", "assets/svg/manage/icon_radio_box.svg"),
  /// 多选框
  CHECKBOX("CHECKBOX", "多选", "assets/svg/manage/icon_checkbox.svg"),
  /// 下拉菜单
  SELECT("SELECT", "下拉菜单", "assets/svg/manage/icon_dropdown.svg"),
  /// 年级
  GRADE_LIST("GRADE_LIST", "年级", "assets/svg/manage/icon_radio_box.svg"),

  /// 日期选择
  DATE("DATE", "日期", "assets/svg/manage/icon_date_choose.svg"),

  /// 图片上传
  IMAGE("IMAGE", "图片上传", "assets/svg/manage/icon_image_upload.svg"),
  /// 文件上传
  FILE("FILE", "文件上传", "assets/svg/manage/icon_file_upload.svg"),
  /// 教材封面
  TEXTBOOK_IMG("TEXTBOOK_IMG", "教材封面上传", "assets/svg/manage/icon_image_upload.svg"),
  
  ;


  const TicketFormTypeEnum(this.value, this.name, this.iconPath);

  final String value;
  final String name;
  final String iconPath;

  /// 是否有选项
  bool get hasOptions => this == RADIO || this == CHECKBOX || this == SELECT || this == GRADE_LIST;

  static TicketFormTypeEnum? fromValue(String? value) => TicketFormTypeEnum.values.firstWhereOrNull((element) => element.value == value);

}