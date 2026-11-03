# Unit Middle Panel Refactor

## 目标与验收口径
- 将 `manage_module_detils_view.dart` 中 unit 区域的 `_buildUnitMiddlePanel(unit)` 调整为与截图一致的纯 UI 版本。
- 保持最小 diff，只修改当前 view，不扩散到 controller、entity 或其他模块。
- 当前阶段以视觉对齐为目标，不处理真实数据口径和业务联动。

## 改动点列表
- 将原来的中部卡片重构为截图样式的 5 张横向状态卡：
  - 单元计划
  - 课时计划
  - 单元语法
  - 文章
  - 歌曲
- 顶部信息改为截图式布局：
  - 标题左侧细色条
  - 标签紧跟在标题右侧，统计信息再放到最右侧
- 底部按钮改为截图式扁平胶囊按钮，按文案自然占位，不再使用固定宽度制造额外留白。
- 恢复到正常尺寸比例，避免因过度缩小导致与截图偏离。
- 新增私有 helper：
  - `_buildUnitMiddlePanelCard`
  - `_buildMiddlePanelTag`
  - `_buildMiddlePanelInfoText`
  - `_buildMiddlePanelButtonWrap`

## 当前数据口径
- 单元计划：使用 `unitPlan` 判断，`true` 时显示 `已审核计划` 标签。
- 课时计划：使用 `lessonPlanList`
  - 列表长度 = 计划总数
  - `lessonPlan == true` = 有计划数量
  - `exercise == true` = 有题目数量
- 文章：使用 `articleStatistic.totalCount / normalCount`
- 歌曲：使用 `songStatistic.totalCount / normalCount`
- 单元语法仍保留当前静态 UI

## 兼容性影响与注意事项
- 当前 UI 结构不变，已按模块详情返回值接入 `unitPlan / lessonPlanList / articleStatistic / songStatistic`。
- 文章和歌曲面板的“查看”已接入单元目标页跳转，并通过 `initialKnowledgeType` 定位到对应 tab。
- 文章面板的“关联”会直接弹出知识点选择弹窗，并默认切到文章 tab。
- 歌曲面板的“关联”会直接进入学习探索页，并按歌曲类型预设筛选。
- 两种“关联”在关闭弹窗或从目标页面返回后，都会刷新当前模块详情页数据。
- “进入审核” 当前同样仅保留 UI 入口样式，未接实际跳转。
- `已审核计划` 与 `待审核` 统一为同类标签样式，并放在标题右侧。

## 非目标 / TODO
- 不调整单元语法的统计口径
- 不新增“进入审核”业务跳转
