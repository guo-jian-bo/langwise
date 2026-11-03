## 目标与验收口径
- 为 `ZhenxieWriteCatalogCardWidget` 增加整卡覆盖层扩展口，能力上与现有 `coverOverlay` 区分开：`coverOverlay` 只覆盖左侧封面，`cardOverlay` 覆盖整张卡片。
- 验收以专项训练写作卡片可挂载整卡锁态浮层为准，且不影响现有封面覆盖层场景。

## 改动点列表
- 在 `ZhenxieWriteCatalogCardWidget` 中新增 `cardOverlay` 可选参数。
- 卡片最终返回结构改为支持在最外层叠加整卡覆盖层，并裁切到原卡片圆角。

## 关键设计/关键决策
- 保持最小 diff，不改现有 `coverOverlay` 行为。
- 整卡覆盖层放在点击层之上，覆盖态下可直接拦住底部卡片点击。

## 兼容性影响与注意事项
- 未传 `cardOverlay` 时，组件行为与原来保持一致。
- 现有管理端封面浮层仍继续使用 `coverOverlay`。

## 待确认问题或 TODO
- 当前锁态浮层文案与视觉按专项训练写作场景接入，若后续其他页面也要复用，再决定是否继续上提为公共锁态组件。
