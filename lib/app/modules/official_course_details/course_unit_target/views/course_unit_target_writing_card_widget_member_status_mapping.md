## 目标与验收

- `CourseUnitTargetWritingCardWidget` 在构建 `ContentCardData` 时，映射专项训练 writing 数据里的 `memberWritingStatus`。

## 改动点

- 引入 `CompositionTaskMemberWritingStatusModel`
- 在 `_buildContentCardData()` 中从 `data.params?.data?.memberWritingStatus` 映射 `memberWritingStatus`
- 通过 `issueTimeText` 将 `data.created` 格式化后传给 `ZhenxieWriteCatalogCardWidget`

## 关键设计

- `memberWritingStatus` 由 `KnowledgeCommonEntityListParamsData` 的原始 Map 转成 `CompositionTaskMemberWritingStatusModel`，复用甄写卡片已有展示逻辑。
- `created` 使用 `MM/dd HH:mm` 格式渲染为下发时间文案，不进入 `ContentCardData`。

## 兼容性影响

- 没有状态数据时保持原样，不影响现有卡片渲染。
