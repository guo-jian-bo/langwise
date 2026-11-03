## 目标与验收

- `mission_special` 在 `taskType == writing` 时，不再使用通用 `KnowledgeCardWidget`。
- 写作场景改为三列网格，并复用 `CourseUnitTargetWritingCardWidget` 展示。
- 非写作场景保持现有列表展示与交互不变。

## 改动点

- 在 `mission_special_view.dart` 的列表渲染处增加 `writing` 分支判断。
- 写作场景下：
  - 网格列数调整为 3 列
  - 网格比例对齐课程目标页写作卡片
  - 列表项改为 `CourseUnitTargetWritingCardWidget`
- 详情返回后继续调用 `refreshPageData(syncDailyTask: true)` 刷新页面与任务中心数据。

## 关键设计

- 仅在视图层分支，不改接口实体与 Controller 数据结构。
- 继续直接消费 `KnowledgeCommonEntityList`，不做额外数据转换。
- `unitId` 在 `mission_special` 侧暂无来源，当前按 `null` 透传。

## 兼容性影响

- 仅影响专项训练页中的写作任务展示样式。
- 课程目标页原有写作卡片逻辑保持不变。

## 非目标

- 不调整其他类型任务的卡片样式。
- 不改写作任务接口返回结构。
