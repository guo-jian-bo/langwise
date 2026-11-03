# 甄写考点首页

## 目标与验收口径
- 首页改为真实接口驱动，不再读取本地 `exam/composition` mock。
- 保持现有页面 UI 和交互不变，只替换数据来源。
- 当前页完整对齐 `GET /languages/write/zhenxie/exam/home?stage={stage}`，支持小升初 / 中考 / 高考三段切换。

## 改动点列表
- `models/zhenxie_exam_models.dart`
  - 新增首页接口 DTO、对比页 DTO、筛选元数据 DTO。
  - 保留原有旧模型，仅作为更深层页面编译兼容。
  - 首页 DTO 补齐后端下发的 `colors`、`groupCode` 原始字段，不再遗漏业务色数据。
- `controllers/zhenxie_exam_controller.dart`
  - 删除读取 `assets/mock/zhenxie/exam/*.json` 的逻辑。
  - 改为显式维护 `homeDataMap`，按 `stage` 请求并缓存首页原始返回。
  - 首页四格全部从 `blocks` 派生，不再依赖本地快照计算。
  - 仅保留原始数据查找与当前主题颜色项选择，不再做本地颜色映射。
- `views/zhenxie_exam_view.dart`
  - 底部三关题数改为读接口 `stages.taskCount`。
  - 阶梯缩略图优先展示后端 `coverUrl`，失败再退回现有占位样式。
  - 四块标题、goal 图例文案、底部 stage 名称改为直接读取首页接口字段。
  - stage / donut / goal legend / ladder 的业务色统一改为读取后端 `colors`，并按项目当前 `LIGHT / DARK` 主题切换。
  - 页面内不再把首页数据二次转成额外的视图结构，直接使用原始 DTO 渲染。

## 关键设计 / 关键决策
- 首页只围绕 `exam/home` 建模，controller 内不再包装“伪字段型 getter”，统一走显式原始数据 + 显式派生方法。
- 顶部 meta 直接使用后端 `summary.summaryText`，不再本地拼接。
- 四格统一按 `block.code` 取数，避免继续依赖数组位置。
- 页面基础底色、正文色、卡片边框底盘继续走 `AppTheme`。
- 业务色只覆盖 `stage / donut / goal legend / ladder`，并严格读接口 `colors[]`。
- `goals` 模块颜色不再靠文案或顺序判断，改为用 `items[].groupCode` 匹配 `legends[].code` 后取对应 `legends[].colors`。

## 兼容性影响与注意事项
- 更深层的 `exam_tasks / task_detail` 本次不在对外范围内，controller 中保留了旧字段声明，仅用于编译兼容，首页和详情页已不再依赖它们。
- 阶梯图片来源从本地 mock 资源改为后端 `coverUrl`，因此网络图片失败时才会退回原占位图。

## TODO
- 当前首页空态文案仍保留本地占位，仅在接口异常或无数据时可见。
