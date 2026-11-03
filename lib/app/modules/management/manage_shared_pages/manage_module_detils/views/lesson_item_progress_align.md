# Lesson Item Progress Align

## 目标与验收口径
- 对齐后台模块详情页 lesson item 与前台课程详情页的进度表达方式。
- 仅修改 `manage_module_detils_view.dart` 中实际渲染 lesson 的 `_buildLessonCircleItem(...)`。
- 不改点击行为、不改接口实体、不动中部五卡区域。

## 改动点列表
- 去掉 lesson `name` 下方的时间占位文本。
- 底部入口文案改为 `题目列表 exerciseNormalCount/exerciseCount >`。
- 复用 `LessonCircleWidget` 的圆环进度表达：
  - `0/total` 视为未开始
  - `0 < normal < total` 视为进行中
  - `normal >= total` 视为完成
- 对 `TEST` 类型课时继续隐藏圆环进度，保持与前台一致。

## 数据口径
- 已完成题数：`exerciseNormalCount`
- 总题数：`exerciseCount`
- 进度值：`exerciseNormalCount / exerciseCount`

## 兼容性影响与注意事项
- 当前只改后台 lesson item 的展示逻辑，不修改前台页面代码。
- 当 `exerciseCount <= 0` 时，进度按 `0` 处理，底部文案展示为 `题目列表 0/0 >`。
