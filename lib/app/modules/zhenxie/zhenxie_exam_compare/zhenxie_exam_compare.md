## 目标与验收口径
- `zhenxie_exam_compare` 改为真实接口驱动，不再依赖首页 controller 的 mock 数据。
- 保持现有 UI 和页面内交互不变，只替换数据来源。
- 当前范围只保证两层页面：
  - 首页 `zhenxie_exam`
  - 对比页 `zhenxie_exam_compare`

## 改动点列表
- `controllers/zhenxie_exam_compare_controller.dart`
  - 删除对 `ZhenxieExamController` mock 数据的依赖。
  - 新增 `metaData / compareDataMap / goalSankeyData / selectedRegionValues` 原始接口字段。
  - `genres / topics` 不再把 compare 返回压缩映射成 `FlowData / FlowSeries`。
  - `goals` 不再把 `goals/sankey` 返回压缩映射成 `GoalSankeyData / GoalSankeyNodeData / FlowColumn`。
  - 切换地区筛选时清空 compare 缓存，避免切 tab 时沿用旧筛选结果。
  - 首次进入、切换模块、确认筛选刷新时统一使用 `ToastUtils.showLoading()` / `hideLoading()`。
- `views/zhenxie_exam_compare_view.dart`
  - 加载态改为读取 compare controller 自身的 `isLoading`。
  - 阶梯节点封面优先展示后端 `coverUrl`，失败再退回现有占位样式。
  - 底部筛选条与弹层改为直接消费 `region/group/list` 返回的 `fixedOptions + groups`。
  - 地区筛选弹窗使用“本地草稿 + 取消/确认”模式，只有点击确认后才真正更新筛选并请求接口。
  - `自主命题卷` 组内省市继续可单选；全国卷组内省市只展示，点击整组区域直接整组切换。
  - 弹窗内移除“已选/全选”状态标签，保留右上角关闭入口与底部“取消 / 确认”操作按钮。
  - 地区筛选至少保留一个选项，最后一个已选项不可取消。
  - 面包屑右侧通过 `BreadcrumbWidget.actionWidget` 直接展示当前模块返回的 `title.zh / description.zh`。
  - `genres / topics` 的 legend、说明卡片和 explain 面板改为直接消费原始 DTO。
  - `goals` 的节点色、底部图例、说明文案、列头和节点名称改为直接消费 `goals/sankey` 原始 DTO 与 `legends[].colors[]`。
  - 底部模块 tab 文案继续本地写死为 `文章 / 主题 / 能力 / 阶梯`，不通过接口获取。
- `views/widgets/zhenxie_ribbon_flow.dart`
  - 改为直接接收 `ZhenxieExamCompareData` 原始 DTO 绘制 flow，不再依赖本地 `FlowData / FlowSeries`。
  - 列头文案直接使用接口 `name / summaryText`，系列颜色直接使用 `legends[].colors[]` 并按 `LIGHT / DARK` 取值。
- `models/zhenxie_exam_models.dart`
  - `ZhenxieExamCompareData / ZhenxieExamGoalSankeyApiData` 的 `title / description` 改回原始 `List<LanguageText>`，不再在模型层拍扁。
  - `ZhenxieExamGoalSankeyNodeApiData` 的 `name / members` 保持原始结构，不再压成字符串。

## 关键设计
- `goals` 直接走 `POST /languages/write/zhenxie/exam/compare/goals/sankey`，能力区只保留布局计算，不再自建业务镜像结构。
- `genres / topics / ladder` 走通用 `POST /languages/write/zhenxie/exam/compare/{module}`。
- 筛选请求体统一按接口文档中的 `filters` 结构发送，不再本地过滤真题快照。
- `genres / topics` 的业务文案与业务颜色统一直接读取 compare 接口，不再保留本地写死标题、说明和调色板。
- 页面基础底色、正文色、边框底盘继续走 `AppTheme`；`genres / topics / goals` 的业务色只读取接口 `colors[]`。

## 兼容性与注意事项
- 当前筛选元数据改为 `fixedOptions + groups` 结构；底部固定按钮直接使用 `fixedOptions`，弹层里的省市项通过 `fixedValue` 回标到外层固定值。
- 真题列表页 / 真题详情页本次仍未接真接口，对比页里的 deeper jump 继续关闭。
- 地区筛选区域本次暂未处理文案来源，仍保持现状。
