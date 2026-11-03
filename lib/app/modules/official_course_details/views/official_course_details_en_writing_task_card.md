## 目标与验收口径

- 课程详情页在单元数据包含 `writingTaskCard` 时，单元内容区需要渲染写作任务卡片。
- 课时圆卡仍然只渲染 `type == LEARN_PRACTICE` 的 lessons。
- 写作任务卡片 UI 参考用户端写作卡的视觉骨架，不额外引入新的本地数据结构。

## 改动点列表

- 在单元课时区上方插入写作任务卡片。
- 卡片文案直接读取后端返回的 `stageName`、`stem`、`answerKind`、`answerMinCount`、`answerMaxCount`、`taskCount`、`compositionTaskCount`。
- 当 `taskId` 存在时，点击卡片进入任务详情页；缺失时仅展示卡片，不新增兜底跳转。

## 关键设计/关键决策

- 继续沿用用户端现有的 `ZhenxieWriteCatalogCardWidget`，只做当前页面需要的轻量映射。
- 不再通过“跳过第一条 lesson”控制显示，统一以 `LEARN_PRACTICE` 过滤普通课时。
- 写作任务卡片与普通课时拆开展示，避免把写作任务混进圆卡列表。

## 兼容性影响与注意事项

- 新增渲染依赖于 `CourseModuleHoursEntityUnits.writingTaskCard` 正确解析。
- 如果后端只返回 `writingTaskCard`、不返回 `taskId`，页面仍可展示，但不可进入详情。

## TODO

- 如后续需要完全对齐用户端写作任务详情链路，可继续补充更完整的跳转参数。
