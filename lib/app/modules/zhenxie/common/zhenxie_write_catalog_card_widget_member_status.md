## 目标与验收

- 在 `ZhenxieWriteCatalogCardWidget` 内部为写作卡片补充 `memberWritingStatus` 标签展示。
- 标签位置位于封面右侧内容区顶部右侧。
- 只改组件内部实现，不调整外部调用和其他页面逻辑。

## 改动点

- 在标题行右侧新增状态标签。
- 在状态行左侧新增可选下发时间文案。
- 标签文案使用 `contentData.memberWritingStatus.statusText`。
- 标签颜色使用 `memberWritingStatus.colors`，按当前明暗主题选择对应颜色。
- 下发时间通过对外暴露的 `issueTimeText` 传入，不传则不渲染。

## 关键设计

- 当前主题通过 `ThemeUtils.isCurrentTheme` 判断，优先取匹配主题色，未匹配时退回数组首项。
- 当 `memberWritingStatus` 或 `statusText` 为空时，不渲染标签。
- 当 `issueTimeText` 为空时，不渲染下发时间文案。

## 兼容性影响

- `stageData` 卡片不受影响。
- 旧数据缺少 `memberWritingStatus` 时，组件展示保持原样。
