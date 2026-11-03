# 模块详情页 v3 产线 UI 接入说明

## 目标与验收口径
- 将 `manage_module_detils_view.dart` 中单元中部面板改为 v3 接口对应的四列产线 UI。
- 单元标题下方新增 `单词 / 短语 / 句子` 数量标签。
- 第 1 列使用 `grammarStatistic` 渲染语法管线状态。
- 第 3 列使用 `lessonPlanList` 渲染课时计划与题目按钮及状态标签。
- 第 4 列固定展示“写作课管线 / 待实现”，不接业务逻辑。

## 改动点列表
- `manage_module_detils_view.dart`
  - 替换 `_buildUnitMiddlePanel` 为四列产线结构。
  - 在单元标题下新增知识点数量标签。
  - 新增语法进度条、产线按钮、课时标签等局部渲染方法。
- `lib/common/entities/unit.dart`
  - `NewUnitResponseEntity` 新增 `knowledgeTypeCountList` 解析。
  - `UnitLessonPlanStatisticEntity` 新增 `lessonName`。
  - `UnitGrammarStatisticEntity` 新增 `totalStepCount`、`finishedStepCount`。
  - 新增 `UnitKnowledgeTypeCountEntity`。

## 关键设计与关键决策
- 第 3 列不再依赖 `lessonDTOList.type` 过滤课时，直接使用后端给出的 `lessonPlanList`。
- 第 1 列标题状态文案按当前已确认口径处理：
  - `grammarAnalyze != true` -> `未生成`
  - `candidateTargetCount > 0` -> `N 待审`
  - 否则显示 `finishedStepCount/totalStepCount`
- “单元计划”当前按 `finishedStepCount >= 6 && 有单词/短语/句子` 解锁，这是基于现有产品口径的前端判断。

## 兼容性影响与注意事项
- 当前单课“计划”标签点击仍复用已有 `refreshOneLessonPlan` 逻辑，后续如果后端补单课生成专用接口，可再切换。
- 第 4 列仍是纯占位，不影响现有业务。
- 旧的文章/歌曲中部卡片已从该区域移除，本次未迁移到其他位置。

## 待确认问题 / TODO
- `grammarStatistic.finishedStepCount` 是否已经包含“已跳过”步骤。
- 单课计划标签是否需要单独的“生成指定课时计划”接口，而不是复用刷新。
- 后端若后续补充 `direction`，可进一步统一课时相关口径。
