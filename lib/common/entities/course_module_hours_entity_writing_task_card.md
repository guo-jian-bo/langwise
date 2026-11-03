## 目标与验收口径

- `CourseModuleHoursEntityUnits` 需要严格对齐后端新增返回的 `writingTaskCard` 字段。

## 改动点列表

- 在 `CourseModuleHoursEntityUnits` 中新增 `writingTaskCard` 字段。
- 在 `fromJson` / `toJson` 中补齐该字段的解析与回写。

## 关键设计/关键决策

- 直接复用现有的 `CourseUnitWritingTaskCardEntity`，不新增中间 DTO。

## 兼容性影响与注意事项

- 页面展示直接依赖该字段，若后端字段结构变化，需要优先同步实体。

## TODO

- 无。
