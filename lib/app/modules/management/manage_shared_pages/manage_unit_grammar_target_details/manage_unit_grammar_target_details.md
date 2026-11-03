# 单元语法 Target 详情页说明

## 目标与验收口径
- 从单元语法 Hub 页右侧 Target item 点击进入详情页。
- 进入后按 `isManagement` 分流接口：
  - 管理端：`GET /course-console/unit/{unitId}/knowledge/grammar/targets/detail/v2?targetUid=...`
  - 用户端：`GET /course/course/write/unit/{unitId}/target/{targetUid}/detail`
- 页面结构按最新产品文档收口为三块：
  - 顶部信息区
  - 中部资产展示区 / 锁模板骨架区
  - 底部按审核态切换：`candidate / disabled` 为待审核区，`approved` 为未归组句 + 已归组句工作台
- 顶部信息区默认展示 `target.title / description`、资产类型、审核状态、要点号以及复制标签；`approved` 的 `pattern / pyramid` 改为复用接近 `zhenxie-pattern-blueprint-details` 的头部表达。
- 中部资产区继续按项目现有最新组件渲染，不另起一套资产详情样式。
- `approved` 时底部不再显示旧的“代表句”大区块，而是通过独立句组接口拆成：
  - 未归组句
  - 已归组
- 页面首次进入时先请求详情接口，确认 Target 状态后再按需请求句组列表接口，请求顺序对齐 `zhenxie-pattern-blueprint-details`。
- 句组后续分页加载只刷新列表接口，不重复请求详情接口。
- 句组分页接口在 `offset=0` 时会返回“全部未归组 + limit 条已归组”，因此前端分页 offset 只能按“当前已归组数量”推进，不能直接按混合列表总长度推进。
- `approved` 时动作区按文档展示：
  - `pattern`：`搜索库里已有句子`、`强制绑定句子`、`生成句子`
  - `pair / paradigm / grid / pyramid`：`高阶加练`
  - 任意 `approved` Target：`添加一组`
- 本轮只对 `EN_SENTENCE_PATTERN` 的未归组工作台补充“选句后再添加一组”的交互：
  - 未归组区按“组 -> 组内句子”两层结构选择
  - 组头支持 `全选 / 全不选`
  - 组内句子支持单独勾选
  - 首次进入未归组数据默认全选
  - 若当前没有选中任何未归组句，`添加一组` 按钮置灰
  - 点击 `添加一组` 时携带 `presetSentences`

## 改动点
- 新增 Target 详情页模块：
  - `bindings/manage_unit_grammar_target_details_binding.dart`
  - `controllers/manage_unit_grammar_target_details_controller.dart`
  - `views/manage_unit_grammar_target_details_view.dart`
  - `views/manage_unit_grammar_target_detail_widgets.dart`
  - `views/manage_unit_grammar_target_details_dialogs.dart`
- 新增详情实体：
  - `lib/common/entities/unit_grammar_target_detail_entity.dart`
- `UnitUtil` 增加 Target 详情接口封装，并按 `isManagement` 分流管理端 / 用户端路径。
- `UnitUtil` 增加 Target 底部句组分页接口封装，并按 `isManagement` 分流管理端 / 用户端路径。
- `UnitUtil` 增加 Target 审核状态更新接口封装。
- Hub 页 Target 卡片点击接入详情页跳转。
- 增加详情页路由与页面注册。
- 本轮围绕新版三段式结构做了收口：
  - 顶部信息区统一改为 Figma 对应的信息卡样式，标题 / 描述使用项目字体常量对齐。
  - 中部资产区保留当前项目里的最新资产组件，不在 Target 详情里重复造 UI。
  - 审核区不再使用旧的页面底部固定浮层，改为页面正文内的待审核卡片。
- `approved` 时底部改为两个区块：
    - 未归组句：展示句组分页接口里 `isSet != true` 的内容
    - 已归组：展示句组分页接口里 `isSet == true` 的内容
  - 用户端进入同一详情页时，不展示“未归组句”区块，只保留“已归组”签发组内容。
  - 未归组句与已归组统一走同一套资产卡 UI，不再拆成逐句小卡。
  - 已归组区新增组卡入口，按资产类型带 `realizationSetId / uid` 跳到对应甄写详情页。
  - 未归组区打开资产详情时不绑定 `realizationSetId`，只按资产本身进入对应详情页。
  - 接上 `添加一组` 入口；当前复用项目已有 `MANAGE_SENTENCE_BLUEPRINT_ADD` 页面承接。
- 审核流继续由前端自管审核队列：
  - Hub「去审核」进入时带 `reviewQueue=true + reviewQueueUids`
  - 详情接口不再透传 `reviewQueue`
  - 更新审核状态后，前端按本地队列自动跳下一条仍为 `candidate` 的 Target
- 待审核区改为新版正文卡片布局：
  - 上半区展示教材支持点
  - 下半区展示 `LLM 自评`、notes 与审核按钮
  - 只有审核队列场景才展示前后切换与「第 i/n 条」「还剩 m 条待审」
  - notes 若以 `9:` / `8：` 这类与分数重复的前缀开头，会在展示层剥掉前缀

## 关键设计
- 实体字段保持与接口返回一一对应，只保留 class / `fromJson` / `toJson`，不再额外包装中间层。
- controller 里直接保存 `detailData`、`grammarUnifiedInfo.payload` 与各类详情实体，便于直接追数据来源。
- 审核流不再依赖后端 `navigator`，改为 controller 内显式保存 `reviewQueueUids / reviewQueueStatuses`。
- `grammarUnifiedInfo.type` 直接作为页面类型分发依据，不再额外穿透 `assetKind` 这类派生字段。
- 首屏 `fetchData()` 先拉详情，再拉首屏列表；后续 `loadMoreSentenceSetPages()` 只负责追加列表分页数据。
- 已归组卡片和打开详情逻辑优先使用列表项自身的 `assetType / assetNid / uid`，不要再强绑当前 Target 的 `grammarUnifiedInfo.type`。
- controller 额外把 `qa_pair` 解析为显式 `SentencePairEntity`，避免在 view 层从原始 map 临时取值。
- `paradigm` 的对照详情直接在 controller 中解析为 `SentencePatternCompareEntity`，避免在 view 层散落数据转换。
- Target 页当前暂不展示 `paradigm` 的资产区域，保留底部未归组 / 已归组工作台交互。
- `grid` 的全景详情直接在 controller 中解析为 `ManageGrammarPanoramaEntity`，避免在 view 层临时拼装轴和格子数据。
- 顶部信息区、待审核区和工作台按钮样式按 Figma 收口，但字体统一通过 `AppFontValue` 取值，不直写字体名。
- 工作台里未归组 / 已归组都优先复用现有资产卡组件；当前 `pattern / pyramid` 复用 `PatternBlueprintItemWidget`。
- `pattern` 的未归组勾选状态只在当前详情页 controller 内维护，不影响已归组卡片，也不改 add-group 页面内部绑定逻辑。
- `pyramid` 的未归组句当前支持单选，默认不选；选中后只在跳转“添加一组”时透传 `presetSentenceId`，不改 add-group 页面内部消费逻辑。
- `paradigm` 的未归组区当前按 `contents[].sentenceStruct.patternNid` 做前端分组：
  - `patternNid` 有值且 `patternName` 可读时，按该组展示标题
  - 无法形成稳定组标题时，直接按“单条一组”渲染，且不显示组标题
  - 每个分组额外补一层边框和背景色，提升组与组之间的视觉区分
  - 每组内部单选，组间可同时选择多组
  - 点击“添加一组”透传 `presetSentenceIds`
- `pattern / pyramid / paradigm` 的未归组区不再额外包一层“蓝图 n / 金字塔 n / 对照 n”外壳，直接在“未归组句”区域内平铺内容；蓝图原来的“全选 / 全不选”入口上移到区块标题右侧。

## 兼容性影响与注意事项
- 当前对 `pattern`、`pyramid`、`pair.qa_pair`、`pair_fork` 和 `grid` 做了真实渲染；`paradigm` 在 Target 页暂不展示资产区域，其他资产类型详情面板后续补齐。
- 当前已接入 `pattern` 的“搜索库里已有句子 / 强制绑定句子 / 生成句子”，以及 `pair / pair_fork / paradigm / pyramid / grid` 的“高阶加练”。
- 工作台底部列表当前优先按 `assetType` 分发 UI；本轮已先接入 `pattern` 的未归组 / 已归组卡片统一复用 `PatternBlueprintItemWidget`，并保留其他类型的兜底卡片。
- 单句分析当前先带当前页 `targetUid` 调用 `POST /grammar/sentence/analyse`；由于接口暂未按句过滤，会分析同一 Target 下尚未齐套的句子。
- “强制绑定句子”当前复用 `MANAGE_SELECT_UNIT_VOCABULAY` 页面作为句子选择器，通过 `contentTypes: ['EN_SENTENCE']` 切换到句子模式；确认后提取 `knowledgeId` 调 `POST /course-console/unit/{unitId}/knowledge/grammar/targets/actions/force-bind`。
- 待审核卡片已接新版交互：
  - `candidate` 显示「通过 / 未通过」
  - `disabled` 显示「通过 / 改回备选」
  - 若以审核队列进入详情，当前按本地队列继续下一条或返回 Hub。
- “添加一组”入口当前先复用项目既有页面，`shapeLock` 专用编辑能力后续再与该页面打通。
- 当前 `presetSentences` 只负责从 Target 详情页透传到蓝图 add-group 路由参数，add-group 页面内部暂不消费这批预置句。
- 未归组句右侧“删除”走产品要求的二选一弹窗：
  - 从单元移除：`POST /course-console/unit/{unitId}/knowledge/remove/contents?flag=0`
  - 从语法移除：`POST /course-console/unit/{unitId}/knowledge/remove/contents?flag=2&targetId={targetUid}`
  - 请求体统一走 `contents: [{ type: EN_SENTENCE, uid }]`；当前详情页先使用句行里的 `sentenceId` 作为 `uid`
- 分叉资产区当前不再走原来的表格示例，先基于 `members[].teachingExampleFrom / teachingExampleTo` 渲染“左问右答”的棋盘式布局；中文释义待后端补齐后再加。

## TODO
- 把 Target 工作台里的“添加一组”进一步对齐到文档里的 `shapeLock` 专用流程。
