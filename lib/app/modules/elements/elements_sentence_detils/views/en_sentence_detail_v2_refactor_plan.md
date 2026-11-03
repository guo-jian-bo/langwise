# Flutter 句子详情页 V2 重构说明

## 1. 目标

本文用于对齐 Flutter 旧版句子详情页与新版产品/接口/前端实现的差异，先明确：

- 这次重构到底要改什么
- 建议按什么顺序落地
- 哪些点必须提前收口，避免边做边返工

当前阶段只产出方案文档，**暂不改业务代码**。

---

## 2. 输入材料

本说明基于以下内容整合：

- 旧版 Flutter 页面
  - `controllers/elements_sentence_detils_controller.dart`
  - `views/elements_sentence_detils_view.dart`
  - `views/elements_sentence_detils_content_widget.dart`
  - `views/elements_structure_widget.dart`
  - `views/elements_syntactic_analysis_widget.dart`
- 新版接口文档
  - `views/en_sentence_detail_v2_frontend_api.md`
- 新版前端实现口径
  - `ui_ux/src/pages/zhenxie/dictionary/sentence/sentenceLayers.ts`
- 新版产品文档
  - `docs_remote/docs/write/ui/user/sentence/02.dictionary.md`

---

## 3. 现状判断

## 3.1 旧版 Flutter 页的结构特点

旧版页面本质上还是“老句子详情页”思路：

- 页面主体是一个长列表详情页
- 左侧是媒体/发音，右侧是释义 + 分析区
- 分析区通过 controller 里的多个 tab 状态切换：
  - `structuralSyntaxTabbarIndex`
  - `structureTabControllerIndex`
  - `gridOrFoldTagIndex`
- 结构分析与句法分析仍然嵌在同一详情页里
- 接口仍走旧接口：
  - `/languages/content/card/en/sentence/detail`

这套结构和 V2 的目标不一致，因为 V2 不是“在旧详情页上加一个更复杂的分析区”，而是：

- 顶层详情页只负责句面、类型、蓝图、4 宫格入口
- 语块 / 成分 / 句法 / 关联是 4 个独立分析层
- 接口一次返回完整详情 + 分析数据

## 3.2 旧版数据模型的问题

当前 `CardSentencesDetilsEntity` 仍是旧口径字段，典型问题：

- 顶部结构信息仍是：
  - `sentenceTypeBasic`
  - `sentenceTypeFunctional`
- 句法仍是旧字段：
  - `constituency`
  - `structs`
- 结构分析仍是旧字段：
  - `clauses`
- 页面默认落点依赖旧 `module`

而 V2 接口已经明确拆成：

- 顶层基础字段：`content`、`definition`、`layer`
- 结构信息：`structure`
- 四宫格入口：`analysisEntries`
- 四宫格详情：`analysisData`

所以这次重构不能只在旧实体上继续堆字段，否则 controller 和 view 会长期处于“双协议混用”状态。

## 3.3 UI 架构不一致

旧版 UI 还是：

- 详情页内嵌结构分析/句法分析
- 结构分析里再切“语块/成分”“网格/折叠”
- 句法分析下面继续挂“词语分析表”

新版产品要求则是：

- 详情页：左侧固定媒体区，右侧上半是句面/类型/蓝图，下半是固定 2x2 宫格入口
- 分析页：独立全屏壳 `SentenceAnalysisShell`
- 底栏 01~04 切换层，不再是旧版那种嵌在详情里的 tab
- `relations` 目前明确是占位态，不是假装可用

结论：**不建议在旧 Widget 上继续补丁式修改，应按“页面壳 + 数据口径 + 分析页路由”三个层面重构。**

---

## 4. 本次重构建议边界

## 4.1 目标范围

建议本次重构范围收敛为以下 4 件事：

1. 句子详情页切到 V2 接口口径
2. 页面骨架改为新版详情页信息架构
3. 分析层入口与默认落点改为 `chunks / svoca / syntax / relations`
4. 为后续独立分析页重构预留稳定数据结构

补充硬边界：

- 左侧媒体区域保持旧版实现与交互，不纳入本次重构范围
- 单词详情页 UI 不改
- 短语详情页 UI 不改

## 4.2 非目标

以下内容建议本轮**不一起做**：

- 旧 `/card/detail` 或其它旧详情页联动改造
- `relations` 真数据接入
- 所有旧组件一次性清理删除
- 公共 `lib/utils` 层面的泛化抽象
- 为所有旧实体做兼容型超大包装
- 左侧媒体区域样式、布局、交互重做
- 单词详情页 UI 联动改造
- 短语详情页 UI 联动改造

## 4.3 兼容性要求

- 现有句子详情跳转入口不要断
- 旧的 `contentId / semanticIds / jumpType` 入参能力先保留
- 在新接口和新页面稳定前，不建议直接删旧结构分析组件
- 若存在无结构数据句子，基础句面仍需可展示
- 左侧媒体区继续复用现有实现，避免引入额外视觉回归
- 本次改动影响面仅限“句子详情页 V2 重构”，不扩散到单词/短语详情页

---

## 5. 核心差异清单

## 5.1 接口层

旧版：

- `GET /languages/content/card/en/sentence/detail`

新版：

- `GET /en/sentence/detail/v2`

关键变化：

- 新接口增加 `layer`
- `module` 退化为兼容旧模块语义，不再决定页面主体结构
- 分析入口配置由后端返回 `analysisEntries`
- 分析详情集中在 `analysisData`

## 5.2 页面结构层

旧版：

- 一个页面里堆释义、结构分析、句法分析

新版：

- 详情页只负责：
  - 类型芯片
  - 句子原文
  - 中文释义
  - 蓝图对齐
  - 2x2 分析入口
- 分析页单独承接：
  - 语块
  - 成分
  - 句法
  - 关联

## 5.3 状态层

旧版 controller 中与页面结构强绑定的状态过多：

- `structuralSyntaxTabbarIndex`
- `structureTabControllerIndex`
- `gridOrFoldTagIndex`
- `sentenceStructureTableSelectIndex`
- `sentenceStructureDetailSelectIndex`
- `graphShowDetils`
- `graphAutoToIndex`

V2 下建议拆分：

- 详情页状态：只保留当前详情展示必需状态
- 分析页状态：各层独立维护
- 路由默认层：由接口 `layer` 或路由参数决定

## 5.4 文案与入口层

旧版分析入口文案和行为分散在多个地方；
新版已在产品文档和 `sentenceLayers.ts` 中明确：

- `chunks`
- `svoca`
- `syntax`
- `relations`

建议 Flutter 端按 V2 接口 `analysisEntries` 为主读取，静态前端配置只作为 fallback，不作为长期真相源。

---

## 6. 建议的重构方向

## 6.1 先重构“数据口径”，不要先重写全 UI

第一优先级不是立刻把所有视觉都做完，而是先解决：

- controller 现在拿到的到底是不是 V2 数据
- view 渲染是不是基于新协议字段
- 页面结构能否支撑独立分析层

如果数据口径不先收口，后面 UI 越改越容易出现：

- 旧字段和新字段并存
- 一个页面里同时维护两套跳转语义
- `module` 和 `layer` 互相覆盖

## 6.2 详情页与分析页解耦

建议拆成两层：

1. `SentenceDetailV2` 详情壳
2. `SentenceAnalysis...` 分析页壳

详情页负责：

- 左侧媒体区
- 右上句面信息
- 右上蓝图对齐
- 右下 2x2 分析入口

分析页负责：

- 顶栏返回
- 当前层标题
- 主分析内容
- 底栏 01~04 切层

## 6.3 旧结构分析组件不要直接硬改成新分析壳

旧的 `ElementsStructureWidget` 和 `ElementsSyntacticAnalysisWidget` 问题在于：

- 默认假设“仍在详情页内部”
- 强依赖旧 controller 中的共享状态
- 结构详情和词语分析表都按旧布局组织

建议：

- 保留旧实现作为迁移参考
- 新版分析层另起 V2 组件
- 待 V2 稳定后再决定是否删除旧组件

---

## 7. 分步骤落地方案

## Step 1：先补 V2 文档化数据模型

目标：

- 明确 Flutter 端要吃的新字段结构
- 不要继续把 V2 数据硬塞进 `CardSentencesDetilsEntity`

建议动作：

- 新建 V2 专用实体，而不是在旧实体上继续横向加字段
- 按接口文档拆为：
  - 顶层详情 DTO
  - `structure`
  - `analysisEntries`
  - `analysisData`

验收口径：

- 能完整表达接口文档中的 V2 返回结构
- controller 不需要再靠旧字段名猜语义

注意点：

- 保持字段名与后端返回一一对应
- 不在实体或 controller 里用 getter 包装“看起来像字段”的透传结果

## Step 2：补一条独立的 V2 请求链路

目标：

- 让旧接口和新接口并行存在，避免一次性替换带来回归

建议动作：

- 在 `ElementsRequest` 中新增 V2 请求方法
- 保留旧 `getSentencesDetils`
- 新增独立 V2 controller 加载流程，先不动旧页面逻辑

验收口径：

- 能独立拿到 `/en/sentence/detail/v2` 返回值
- 失败态、空数据态、无结构态可区分

注意点：

- `module` 和 `layer` 都要按接口文档传参
- `layer` 只决定默认分析层，不裁剪返回内容

## Step 3：先搭新版详情页骨架

目标：

- 只实现新版详情页结构，不先处理所有分析细节

建议动作：

- 新建详情页内容组件
- 页面上半只展示：
  - 句型标签
  - 句子原文
  - 中文释义
  - 蓝图标签 / 蓝图对齐
- 页面下半先实现固定 2x2 入口卡片

验收口径：

- 页面视觉层级已经接近产品文档
- 4 个入口文案、状态、默认层口径正确

注意点：

- 入口状态优先读 `analysisEntries[*].status`
- `relations` 为 `PENDING` 时展示占位，不伪装成可用分析页

## Step 4：蓝图区独立实现

目标：

- 把新版详情页最关键的差异区单独收口

建议动作：

- 单独做“句面 + 蓝图对齐”组件
- 优先消费：
  - `structure.structureTags`
  - `structure.blueprintTags`
  - `structure.blueprint.segmentList`

验收口径：

- 顶部信息区不再依赖旧的 `sentenceTypeBasic` / `sentenceTypeFunctional`
- 蓝图信息不再混用旧结构分析逻辑

注意点：

- 蓝图层和 chunk / svoca / syntax 是四套独立分析，不要混着色、混说明
- 槽位弹窗要直接吃 `segment` 数据，不要回退拼旧字段

## Step 5：拆独立分析页路由与底栏切层

目标：

- 从“详情页内 tab”切到“独立分析页”

建议动作：

- 新增分析页壳
- 路由层明确四个 layer：
  - `chunks`
  - `svoca`
  - `syntax`
  - `relations`
- 底栏切换只切 layer，不再改详情页内部 tab

验收口径：

- 从详情页点 2x2 卡片能进入对应分析页
- 分析页底栏能切层并维持统一壳

注意点：

- 这一层完成后，旧 controller 中多个 tab 状态大概率都可以下沉或删除
- 分析页状态不要继续挂在详情 controller 上

## Step 6：逐层接入分析内容

建议顺序：

1. `chunks`
2. `svoca`
3. `syntax`
4. `relations`

原因：

- `chunks` / `svoca` 数据都来自 `analysisData.clauses`
- `syntax` 需要单独处理 constituency tree
- `relations` 当前本身就是占位态

验收口径：

- 每一层都能独立进入、独立渲染、独立处理空态

---

## 8. 重点风险与注意点

## 8.1 最大风险不是 UI，而是“旧状态模型继续绑新页面”

如果继续沿用当前 controller 里的旧状态模型，会出现：

- 详情页和分析页强耦合
- 一个页面状态控制另一个页面结构
- 后续很难做独立分析页路由

建议尽量避免继续扩展这些旧状态：

- `structuralSyntaxTabbarIndex`
- `structureTabControllerIndex`
- `gridOrFoldTagIndex`

## 8.2 不要把 V2 数据继续塞回旧实体

原因：

- 字段语义已经变了
- 新接口是分层结构，不是旧版扁平字段
- 混装后 controller 会越来越难维护

建议：

- V1 / V2 分实体
- V2 页面只读 V2 实体

## 8.3 文案与样式优先以后端返回为准

特别是：

- `structure.structureTags`
- `structure.blueprintTags`
- `analysisEntries`

Flutter 端只做 fallback，不要重新硬编码一套主文案。

## 8.4 `relations` 不要抢跑

根据产品文档和接口文档：

- 详情页有入口
- 分析页可进入
- 真实关联数据未完成

因此当前正确策略是：

- UI 保留入口和占位页
- 不要前端伪造“姐妹句”“生长链”“对照壳”

## 8.5 句法页不要沿用旧“树 + 词语分析表”组合

新版产品文档强调的是：

- 句法页主角是满屏树
- 叶子顺序必须与 token 顺序一致
- 页面进入时应 fit 到画布

所以旧的 `ElementsSyntacticAnalysisWidget` 只能参考，不建议直接延用为最终结构。

---

## 9. 建议涉及文件

如果按上面的拆法推进，建议优先影响以下文件：

- `lib/common/https/elements.dart`
  - 新增 V2 请求方法
- `lib/common/entities/`
  - 新增 V2 专用实体文件
- `lib/app/modules/elements/elements_sentence_detils/controllers/`
  - 新增或重构 V2 controller
- `lib/app/modules/elements/elements_sentence_detils/views/`
  - 新增详情页 V2 内容组件
  - 新增分析页壳组件
  - 新增 4 宫格入口组件
  - 新增蓝图区组件

当前不建议第一轮就直接大改：

- `lib/utils/`
- 旧通用结构分析工具
- 旧 `/card/detail` 相关页面

---

## 10. 推荐执行顺序

推荐分两段做：

### 第一段：先通数据和壳

1. 建 V2 实体
2. 建 V2 请求
3. 建 V2 controller
4. 建新版详情页壳
5. 跑通顶部信息和 2x2 入口

### 第二段：逐层替换分析页

1. chunks
2. svoca
3. syntax
4. relations 占位
5. 稳定后再评估旧组件删除

---

## 11. 本文给出的结论

这次重构本质上不是“优化旧页面”，而是：

- 从旧接口详情页，迁到新版句子词典信息架构
- 从“一个页内切 tab”，迁到“详情壳 + 独立分析层”
- 从旧扁平实体，迁到 V2 分层协议

因此最稳妥的路线是：

- **先并行建设 V2 数据链路和页面壳**
- **再逐步迁移分析层**
- **最后再决定旧实现如何下线**

---

## 12. 待确认问题

在正式动代码前，建议再确认这几件事：

1. 这次是否接受新增 V2 专用实体，而不是复用旧 `CardSentencesDetilsEntity`
2. 这次是否接受新增一套 V2 页面/组件，而不是直接在旧 Widget 上改
3. 第一阶段是否只做详情页 + 4 宫格入口，不立即完成 3 个分析层全部视觉
4. `relations` 当前是否按占位态验收

如果以上 4 点确认，后续实现会更稳，diff 也会更可控。
