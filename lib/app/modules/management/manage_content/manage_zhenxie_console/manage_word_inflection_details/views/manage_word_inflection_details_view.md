# 屈折变化详情页底部 TabBar 自适应宽度说明

## 目标与验收口径
- 目标：让屈折变化详情页底部语义切换 TabBar 不再固定撑满整行，而是随内容宽度自适应。
- 验收：Tab 数量较少时，底部胶囊容器按内容收缩并保持居中；Tab 数量较多时，仍可横向滚动，不影响选中项切换。

## 改动点列表
- 移除 `_buildSemanticTabsWidget` 外层对 TabBar 的 `double.infinity` 宽度约束。
- 增加 `Align(alignment: Alignment.center)`，让 TabBar 在可用区域内居中展示。
- 移除 `_ManageWordInflectionSemanticTabsBar` 内部 `LayoutBuilder + ConstrainedBox(minWidth: constraints.maxWidth)` 的强制撑满逻辑。
- 保留 `SingleChildScrollView`，确保内容过宽时仍支持横向滚动。

## 关键设计 / 关键决策
- 这次只调整底部 TabBar 的宽度约束，不改选中态、滚动定位和交互逻辑。
- 采用最小 diff 方案，避免引入额外公共组件或重构周边结构。

## 兼容性影响与注意事项
- 少量 Tab 时，视觉效果会从“整行铺满”变为“内容宽度胶囊居中”。
- 多个 Tab 超出可用宽度时，容器会受父级宽度限制，内部继续横向滚动。

## 待确认问题 / TODO
- 若后续希望底部 TabBar 改为左对齐而非居中，可在当前结构上继续做局部调整。
