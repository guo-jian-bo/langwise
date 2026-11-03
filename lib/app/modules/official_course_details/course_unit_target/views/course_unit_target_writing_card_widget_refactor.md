## 目标与验收

- 将 `CourseUnitTargetWritingCardWidget` 从 `CourseUnitTargetController` 解耦。
- 保持课程目标页原有写作卡片展示与跳转行为不变。
- 组件改为通过显式入参 `isManagement`、`unitId` 控制管理态行为，便于其他页面复用。

## 改动点

- 移除组件对 `CourseUnitTargetController` 的直接依赖。
- 新增显式入参：
  - `bool isManagement`
  - `int? unitId`
  - `Future<void> Function()? onReturned`
- 管理态按钮与跳转逻辑改为直接使用上述入参。

## 关键设计

- `isManagement` 负责控制复制标记、管理按钮显隐、跳转时的管理态参数。
- `unitId` 继续透传给 `SetExpansionButtonsWidget`，避免影响管理端现有入口。
- `onReturned` 作为可选回调提供给复用方，用于在详情页返回后执行局部刷新。

## 兼容性影响

- 课程目标页需要同步调整调用方式。
- 组件数据结构仍然直接使用 `KnowledgeCommonEntityList`，不新增中间 DTO。

## 注意事项

- 当前组件仍假设写作任务数据符合 `compositionStage` 结构；若后续接入其他写作卡片形态，需要在上游先明确分支口径。
