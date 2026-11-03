# Zhenxie Write Catalog Card Refactor

## 目标与验收口径

- 将 `ZhenxieWriteCatalogCardWidget` 从“外部传大量已拆分字段”的方式收敛为“直接接收两种通用数据模型”。
- 起承转合区域不再通过 `slotStrip` 对外暴露，统一在卡片内部复用 `ZhenxieCompositionSlotStripWidget`。
- `entityLabel` 与 `coverOverlay` 继续保留为对外参数。
- 外层调用点不再手动组装 `difficultyLabel`、`blueprintLabel`、`genreLabel`、`answerTypeText`、`answerDetailText`、`infoTags`、`slotStrip`。

## 改动点列表

- 新增 `zhenxie_write_catalog_card_data.dart`
  - `StageCardData`
  - `ContentCardData`
  - `StageCardSlotData`
- 新增 `zhenxie_beat_utils.dart`
  - 提供全局起承转合数据变量
  - 提供 `ensureZhenxieBeatData()` 统一补数
  - 当前服务于卡片内部与直接使用 `ZhenxieCompositionSlotStripWidget` 的页面
  - 同时通过 `/languages/write/zhenxie/composition/discourse/home` 预加载四文类名称与主题色，供卡片直接消费
- 改造 `zhenxie_write_catalog_card_widget.dart`
  - 对外改为 `stageData` / `contentData` 二选一
  - 组件内部统一计算标题、描述、标签、答案形式、起承转合
- 改造现有 wrapper / 页面调用
  - `ZhenxieCompositionTaskCardWidget`
  - `ZhenxieCompositionInstanceCardWidget`
  - `ZhenxieCompositionStageCardWidget`
  - 管理端写作管线 / 任务编辑 / 任务列表 / 更换阶梯页

## 关键设计与关键决策

- 数据模型按当前讨论结果采用“全量字段挂载”方式，不做轻量裁剪。
- `StageCardData` 与 `ContentCardData` 允许直接通过后端原始数据 `toJson()` 构建，减少外层映射成本。
- `ContentCardData` 兼容任务与范文：
  - `name` / `title` 同时保留
  - 渲染时优先 `name`，为空再取 `title`
- `coverOverlay` 继续保留为外部扩展口，用于范文封面管理态浮层等场景。
- 起承转合数据通过全局变量 + `ensureZhenxieBeatData()` 方式统一获取，不再引入额外 service。
- 文类标签文案与颜色不再在 `ZhenxieWriteCatalogCardWidget` 内写死四文类映射，统一改为读取 `ensureZhenxieBeatData()` 预加载的章法页 `genres` 元数据。

## 兼容性影响与注意事项

- `ZhenxieWriteCatalogCardWidget` 的旧参数已收口，旧调用方式不再适用。
- 目前卡片内部会优先使用 `stage` 上的数据渲染答案形式与 slot strip；`content` 根字段仅作为补充。
- 相关页面在进入时统一调用 `ensureZhenxieBeatData()`；卡片与 slot strip 直接读取全局起承转合数据。
- 相关页面在进入时统一调用 `ensureZhenxieBeatData()`；卡片与 slot strip 直接读取全局起承转合数据，文类标签也直接读取全局 `genres` 元数据。

## 待确认问题 / TODO

- 后续可以继续把各 controller 中残留的 beat 相关字段与方法进一步清理，统一收口到全局起承转合工具。
- 如需进一步减少 wrapper 层，可以继续讨论是否让更多页面直接传 `StageCardData` / `ContentCardData`，不再保留单独 wrapper。
