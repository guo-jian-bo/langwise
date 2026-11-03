// ignore_for_file: constant_identifier_names

/// 工作人员操作台购买状态筛选枚举。
///
/// - [value]：接口 `purchaseStatus` 使用的枚举值。
/// - [name]：筛选组件展示文案。
/// - [label]：完整标签文案，便于和原型及协议字段对照。
enum ManageEmployeeConsolePurchaseStatusEnum {

  /// 购买: 已购买
  PAID(value: "PAID", name: "已购买", label: "购买: 已购买"),

  /// 购买: 未购买
  UNPAID(value: "UNPAID", name: "未购买", label: "购买: 未购买");

  final String value;
  final String name;
  final String label;

  const ManageEmployeeConsolePurchaseStatusEnum({
    required this.value,
    required this.name,
    required this.label,
  });
}
