## 目标与验收口径

- 调整“学习规划 > 当前学习单元”列表顺序。
- `待开始` 状态的卡片排到列表后面。
- 其他状态之间保持原有相对顺序不变。

## 改动点列表

- 在 `mission_control_center_controller.dart` 的 `displayCurrentCoursePlanList` getter 中增加轻量排序。

## 关键设计 / 关键决策

- 只基于 `item.isPendingStart` 做排序。
- 使用 getter 出口排序，不改接口原始数据，不改 View 层渲染逻辑。
- 当两个 item 同为 `待开始` 或同为非 `待开始` 时，比较结果返回 `0`，保持现有顺序。

## 兼容性影响与注意事项

- 仅影响“当前学习单元”列表展示顺序。
- 不影响点击逻辑、状态判断和卡片展示样式。
