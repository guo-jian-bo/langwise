# 单元语法 Target 详情页说明

## 目标与验收口径
- 从单元语法 Hub 页右侧 Target item 点击进入详情页。
- 进入后调用 `GET /course-console/unit/{unitId}/knowledge/grammar/targets/detail?targetUid=...`。
- 当前完整支持 `assetKind=pattern` 的详情展示。
- 当前补上 `assetKind=pair` 的上半区详情展示：头部信息区 + 同组对照区。
- 当前补上 `assetKind=paradigm` 的上半区详情展示：信息区 + 同组对照表 + 共享槽。
- 下半区暂时统一按“代表句”区域展示，不再按 `assetKind` 切换区域类型。

## 改动点
- 新增 Target 详情页模块：
  - `bindings/manage_unit_grammar_target_details_binding.dart`
  - `controllers/manage_unit_grammar_target_details_controller.dart`
  - `views/manage_unit_grammar_target_details_view.dart`
  - `views/manage_unit_grammar_target_detail_widgets.dart`
  - `views/manage_unit_grammar_target_details_dialogs.dart`
- 新增详情实体：
  - `lib/common/entities/unit_grammar_target_detail_entity.dart`
- `UnitUtil` 增加 Target 详情接口封装。
- `UnitUtil` 增加 Target 审核状态更新接口封装。
- Hub 页 Target 卡片点击接入详情页跳转。
- 增加详情页路由与页面注册。
- 本轮继续收 `pattern` 和公共区域：
  - 去掉 `pattern` 资产区里偏开发态的说明/点击
  - 代表句卡片按 `hasStructure / structureChips` 调整展示
  - 底栏人审补上 `通过 / 备选 / 未通过`
  - `pattern` 资产区恢复说明与点击入口
  - 接上“搜索库里已有句子”：
    - `match-preview`
    - `match-append-selected`
  - 接上“生成句子”：
    - `create-by-pattern`
    - 补“生成几句”与“后台生成中”两段弹窗
  - 接上“高阶加练”：
    - `create-by-relation`
    - 仅对 `approved` 的 `pair / pair_fork / paradigm / pyramid / grid` 展示
    - 复用“生成几组”与“后台生成中”两段弹窗
  - `pair` 类型的上半区改为参考句型对照详情页结构：
    - 头部信息区展示对照标题、对照类型、审核状态
    - 资产区展示 `from / to` 两侧对照内容与共享槽
    - 数据来自 `grammarStructInfo.payload` 原始结构
  - `paradigm` 类型的上半区改为参考句型对照详情页结构：
    - 信息区展示维度、变换类型、壳数、对照组数、审核状态
    - 资产区展示同组对照表与共享槽
    - 数据来自 `grammarStructInfo.payload` 原始结构
- 底栏审核改为前端自管审核队列：
  - Hub「去审核」进入时带 `reviewQueue=true + reviewQueueUids`
  - 详情接口不再透传 `reviewQueue`
  - 更新审核状态后，前端按本地队列自动跳下一条仍为 `candidate` 的 Target
  - 下半区统一收口为代表句区域；代表句内容区以 `sentences` 为主列表，再按 `contentId <-> sentenceRealizationList.sentenceId` 匹配结构分析结果；匹配成功时复用 `SentenceSlotExampleWidget`
  - 代表句卡片补上 `access=INTERNAL` 的「新创建」标
  - `hasStructure=false` 时，句面下方改为「分析语法」按钮，点击走 `/grammar/sentence/analyse`
  - 代表句 item 右侧补上：
    - `从语法移除`
    - `从单元移除`
    - `拓展学习`
- 审核信息区改为页面底部固定浮层，并收口为新版审核布局：
  - 左侧展示教材支持点与 LLM 自评
  - 右侧展示状态徽章与两个操作按钮
  - 只有审核队列场景才展示前后切换与「第 i/n 条」「还剩 m 条待审」
  - LLM 自评补充分数徽章、`evidenceFit` 文案与 notes 同行展示
  - notes 若以 `9:` / `8：` 这类与分数重复的前缀开头，会在展示层剥掉前缀

## 关键设计
- 实体字段保持与接口返回一一对应，不在模型里额外包装 getter。
- controller 里把 `target / assetView / quota / sentences / review` 显式落成本地字段，便于直接追数据来源。
- 审核流不再依赖后端 `navigator`，改为 controller 内显式保存 `reviewQueueUids / reviewQueueStatuses`。
- `grammarStructInfo.payload` 额外保留原始 `payloadRaw`，用于 `pair` 这类非蓝图结构的详情渲染。
- `paradigm` 的对照详情直接在 controller 中解析为 `SentencePatternCompareEntity`，避免在 view 层散落数据转换。
- 句型骨架和代表句区域参考现有甄写页面风格，但不改公共组件，改为在本模块内做数据驱动版本。

## 兼容性影响与注意事项
- 当前对 `pattern`、`pair` 和 `paradigm` 做了真实渲染，其他资产类型详情面板后续补齐。
- 当前已接入 `pattern` 的“搜索库里已有句子 / 生成句子”，以及 `pair / pair_fork / paradigm / pyramid / grid` 的“高阶加练”。
- 代表句右侧的“拓展学习”已接入真实跳转：直接用当前句子的 `contentId / semanticId / content` 打开元素详情页。
- 下半区代表句区域统一以 `sentences` 为基准展示，避免已分析句子数量少于待审核句子时造成漏看；只有匹配到结构分析结果的句子，才展示槽位版代表句。
- 代表句卡片现在会按 `sentences[].access == INTERNAL` 渲染「新创建」标。
- 单句分析当前先带当前页 `targetUid` 调用 `POST /grammar/sentence/analyse`；由于接口暂未按句过滤，会分析同一 Target 下尚未齐套的句子。
- “从语法移除”与“从单元移除”当前都使用 `sentences[].uid` 作为删除动作参数来源。
- 底栏审核已接新版交互：
  - `candidate` 显示「通过 / 未通过」
  - `approved` 显示「未通过 / 改回备选」
  - `disabled` 显示「通过 / 改回备选」
  - 若以审核队列进入详情，当前按本地队列继续下一条或返回 Hub。
- “高阶加练”成功后当前只刷新当前页，不额外联动跳转关联 `pattern Target`。

## TODO
- 补齐非 `pattern` 资产详情面板。
