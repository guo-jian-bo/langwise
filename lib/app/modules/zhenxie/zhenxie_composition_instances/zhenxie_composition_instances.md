# 篇章范文列表页

## 目标与验收口径
- 接入 Flutter 管理端“篇章范文”列表页。
- 页面字段口径对齐产品文档、React `CompositionInstancesPage` 和 `instance/pages` 接口。
- 管理台入口和写作阶梯卡片里的“范文”按钮都能进入该列表页。

## 改动点列表
- 新增 `zhenxie_composition_instances` 模块的 `binding / controller / model / view`。
- 新增篇章范文列表接口与筛选元数据接口封装。
- 注册路由、tag route、管理台入口和管理端页面注册。
- 将写作阶梯卡片“范文”按钮接到列表页，并传 `stageNid`。

## 关键设计 / 关键决策
- 只做列表页，不扩展范文详情页。
- 复用现有 `ZhenxieWriteCatalogCardWidget` 和 `ZhenxieCompositionSlotStripWidget`。
- 范文卡标题使用 `title`，不展示单独描述文案。
- CEFR 标签优先使用 `stage.difficulty`，没有 `stage` 时回退到顶层 `difficulty`。
- 封面优先使用 `coverUrl`，其次回退 `imageReview.image.imageUrl`。

## 兼容性影响与注意事项
- 保持任务列表和阶梯列表现有实现不变，只新增范文列表链路。
- `CompositionStageModel` 仍复用当前轻量 stage 结构，拍条优先读取接口显式字段。

## 待确认问题或 TODO
- 范文详情页、编辑链路、返回阶梯行为后续再接。
