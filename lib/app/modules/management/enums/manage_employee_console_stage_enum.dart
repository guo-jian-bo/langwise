// ignore_for_file: constant_identifier_names

/// 工作人员操作台学习阶段筛选枚举。
///
/// - [value]：接口 `stages` 使用的筛选值。
/// - [name]：筛选组件展示文案。
/// - [label]：完整标签文案，便于和原型及协议字段对照。
///
/// 接口文档说明 `stages` 兼容匹配阶段编码和阶段标题，
/// 当前页面先使用阶段标题作为筛选值，避免引入未确认的阶段编码。
enum ManageEmployeeConsoleStageEnum {

  /// 阶段: 未评测
  UN_ASSESSED(value: "UN_ASSESSED", name: "未评测"),

  /// 阶段: 未设计划
  UN_PLANNED(value: "UN_PLANNED", name: "未设计划"),

  /// 阶段: 未开学
  UN_STARTED(value: "UN_STARTED", name: "未开学"),

  /// 阶段: 学习中
  LEARNING(value: "LEARNING", name: "学习中");

  final String value;
  final String name;

  const ManageEmployeeConsoleStageEnum({
    required this.value,
    required this.name,
  });
}
