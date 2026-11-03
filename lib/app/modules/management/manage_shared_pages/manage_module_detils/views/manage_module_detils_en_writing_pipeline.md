## 目标与验收口径

- 仅在模块 `specialty == EN_WRITING` 时，将单元中部面板从四列改为三列：`语法管线 > 写作管线 > 课时`。
- 课时区不再把 `WRITING_TASK` 渲染为圆形课时卡，而是在普通课时卡后追加一个横向占 `3` 列宽度的写作课时大卡。
- 本次只做 UI 分支与接口字段消费，不接写作页面跳转。

## 改动点列表

- `manage_module_detils_view.dart`
  - 新增 `EN_WRITING` 分支下的写作管线列。
  - 将课时区从固定 `GridView` 改为 `Wrap`，支持写作大卡占 `3` 列宽度。
  - 写作大卡展示 `writingTaskCard` 的封面、作答类型、阶梯名、题干、任务数、范文数。
- `manage_module_detils_controller.dart`
  - 新增 `isWritingSpecialty` 判断。
  - `EN_WRITING` 下的课时圆卡过滤掉 `WRITING_TASK`。
  - 单元高度估算补入写作大卡占位。
- `lib/common/entities/unit.dart`
  - `NewUnitResponseEntity` 新增 `writingPipeline`、`writingTaskCard` 字段解析。
  - 新增 `CourseUnitWritingPipelineEntity`、`CourseUnitWritingTaskCardEntity`。

## 关键设计与关键决策

- `EN_WRITING` 分支判断直接使用后端原值 `'EN_WRITING'`，不扩公共枚举，控制改动范围。
- 写作管线列沿用现有产线 UI 骨架，使用：
  - 主按钮：`任务列表`
  - 进度条：`compositionTaskCount / taskCount`
  - 标签：`N个任务`、`范文 m/n`
- 写作课时大卡采用 `Wrap` 追加到普通课时卡之后，宽度按 `3` 个网格单元计算，避免重构整套圆卡组件。
- 文案展示优先取 `lang == zh`，拿不到再回退到第一条非空文本。

## 兼容性影响与注意事项

- 非 `EN_WRITING` 模块保持现有四列结构不变。
- 本次未处理 `writingTaskCard == null && writingPipeline.taskCount == 0` 的空态，因为当前需求已确认这种情况先不覆盖。
- “任务列表”按钮和写作管线按钮当前仅保留 UI 表现，不接跳转。

## 待确认问题 / TODO

- 后续若要接写作任务页，需要明确管理端路由入口及参数口径。
- 若设计要求写作大卡与圆卡同高，需要再调整当前 194 高度方案。
