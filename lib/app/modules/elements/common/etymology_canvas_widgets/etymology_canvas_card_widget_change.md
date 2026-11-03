## 目标与验收口径

- 将词源记忆页面中，叶子节点内部列表的 item 卡片切换为 `ElementsPublicCard`。
- 保持词源树节点容器、标题区、画布定位与聚焦逻辑不变。
- 点击卡片后仍按 `ElementsPublicCard` 既有行为进入对应详情页。

## 改动点列表

- 在 `etymology_canvas_card_widget.dart` 中，将叶子节点内部 `senseCards` 的单项渲染从 `ElementsTypeCardWidget` 替换为 `ElementsPublicCard`。
- 保留 `KeyedSubtree` 与 `focusCardKey`，避免影响画布聚焦定位。

## 关键设计 / 关键决策

- 只替换列表 item 本身，不调整词源节点外层容器与标题结构，控制 diff 在最小范围内。
- 复用 `ElementsPublicCard` 自带的点击跳转和内容展示，不再在当前场景额外包一层类型卡片逻辑。

## 兼容性影响与注意事项

- 叶子节点 item 的视觉样式会与通用元素卡片保持一致。
- 当前未额外为“选中卡片”增加局部高亮，仍沿用节点级高亮表现。
- 由于 `ElementsPublicCard` 有固定默认高度，词源节点整体高度会随卡片样式自然变化。

## 非目标

- 不调整词源画布布局算法。
- 不修改 controller / view 的选中、切树、切义项逻辑。
- 不改 `ElementsPublicCard` 的通用样式和交互。
