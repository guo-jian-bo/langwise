# 页面实现提示词

## 页面目标

- 完成 `manage_sentence_fork_add_group` 页面功能。
- 当前阶段只实现“分叉 / pair-fork”模式，对应入口：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/zhenxie/zhenxie_sentence_pair_fork_details/controllers/zhenxie_sentence_pair_fork_details_controller.dart#L289-L291`
- 页面现有 UI 结构、样式、布局不要动，只补控制器状态、数据流、显隐、交互和接口调用。
- 参考实现：
  - `/Users/langwise/Desktop/ns/project/ui_ux/src/pages/zhenxie/sentence/components/AddRealizationSetModal.tsx`
- 直接参考已完成页面：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/manage_sentence_paradigm_add_group`
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/manage_sentence_pair_add_group`

## 强约束

- 只做“分叉 / pair-fork”功能，不实现 blueprint / pair / paradigm / pyramid 其他模式。
- 不改现有 UI 树结构，不顺手重排版，不改视觉文案。
- 接口统一补到：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/common/https/language_console.dart`
- 接口说明来源：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/manage_sentence_fork_add_group/manage_sentence_fork_add_group.md`
- 控制器里尽量少用 `Get` 语法：
  - 仅保留页面生命周期、路由入参、返回关闭等必要 GetX 框架用法
  - 不要到处写 `Get.find()`、`Get.context`
  - 优先显式参数传递、局部状态、普通方法组织
- “挑一句”必须复用现有弹窗：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/common/manage_sentence_add_select_dialog.dart`
- 但弹窗内部候选句接口不能写死成 blueprint / paradigm / pair 版本，必须继续扩展到支持 fork。
- 页面类型统一使用：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/common/enum/zhenxie_en_sentence_type.dart`
  - 本页固定使用 `ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR_FORK`

## 当前页面现状

- 页面壳子已存在：
  - `views/manage_sentence_fork_add_group_view.dart`
  - `controllers/manage_sentence_fork_add_group_controller.dart`
- 路由已存在：
  - `Routes.MANAGE_SENTENCE_FORK_ADD_GROUP`
- 注册入口已接好。
- 当前 View 还只是一个纯文本占位：
  - `ManageScaffold -> Center -> Text('添加一组')`
- 当前入口页：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/zhenxie/zhenxie_sentence_pair_fork_details/controllers/zhenxie_sentence_pair_fork_details_controller.dart#L289-L291`
  - 这里不能空跳转，必须把本页所需参数显式传入 `ManagePageRegistry.jumpTo`
- 页面实现时，公共添加组件优先复用：
  - `manage_sentence_add_widgets.dart`
  - `manage_sentence_add_select_dialog.dart`

## 需要完成的功能范围

### 1. 页面入参与初始化

- 从页面入口接收并解析完成“分叉 / pair-fork”功能所需参数。
- 入口页跳转时必须传参，不允许页面内部再依赖模糊上下文猜测。
- 优先直接传：
  - `forkDetail.value`
- 单元 Target 入口额外支持传：
  - `presetSentenceId`
- 不建议单独重复传：
  - `nid`
  - `isManagement`
  - `realizationSetId`
- `nid` 直接从传入的 `forkDetail` 中读取。
- 当入口带了 `presetSentenceId` 时：
  - 先用 `querySentenceStructure` 按 `contents: [{ type, uid }]` 查询这句的结构化摘要
  - 查回后直接预填到 `from`
  - 同时视为 `fromPinned = true`
  - `from` 不允许再挑句、手输 uid、清空
- 初始化时完成：
  - 页面标题/副标题依赖的数据准备
  - `from` 主格位准备
  - 多个 `to` 分支格位准备
  - 默认样句准备
  - 已绑定句状态初始化

### 2. 分叉格位构建

- 本页不是固定双格位，而是：
  - 1 个 `from`
  - N 个 `to` 分支格位
- `to` 分支格位需要来自详情页里的分支值数据，不能写死。
- 每个格位需要具备：
  - 当前格位标识 `cell`
  - 当前分支 `valueNid`（`to` 分支必需）
  - 当前格位名称或标签
  - 默认样句
  - 已绑定句信息
  - 候选句请求所需参数
- `from` 格位额外需要支持：
  - 预填锁定态 `fromPinned`
  - 当 `fromPinned` 为 `true` 时，展示“已选定”而不是“换一句”
- 页面布局要尽量贴近 Web：
  - 左侧单列展示 `from`
  - 右侧纵向展示多个 `to` 分支
  - 不再沿用“所有格位一列竖排”的通用列表结构

### 3. 样句展示

- 顶部样句区沿用 `ManageSentenceAddExampleWidget`。
- 如果 fork 页面当前没有对照高亮所需完整结构，不强行接复杂高亮逻辑。
- 样句至少要能正确展示默认句面，并保证后续如果补充结构化字段时可扩展。
- `forkDetail.boardExample.fromText / matches[].toText` 需要作为默认样句兜底来源接入。
- 当前 Flutter 实体里未发现稳定的 `fromTextZh / toTextZh / teachingExampleToZh` 字段，实现时不要伪造中文样句。
- 没有样句时保留空态兜底，不能报错。

### 4. 挑一句 / 手输 uid

- 每个格位支持：
  - 挑一句
  - 手输 uid
  - 清空已绑定句
- 但当 `fromPinned` 为 `true` 时：
  - `from` 不允许挑一句
  - `from` 不允许手输 uid
  - `from` 不允许清空
- “挑一句”复用 `ManageSentenceAddSelectDialog`，不要新写一套弹窗。
- `ManageSentenceAddSelectDialog` 需要继续扩展“页面类型”入参，并在内部根据 `ZhenxieEnSentenceType` 决定调用哪个候选句接口：
  - blueprint 页面继续走现有 pattern 接口
  - paradigm 页面继续走现有 paradigm 接口
  - pair 页面继续走现有 pair 接口
  - fork 页面新增走 `manage_sentence_fork_add_group.md` 中“按格候选”接口
- fork 候选接口请求体为：
  - `cell`
  - `valueNid`
  - `boundSentenceIds`
- “手输 uid”走 fork 的 bind-check 接口，请求体为：
  - `cell`
  - `sentenceId`
  - `valueNid`
- `from` 格位如果没有 `valueNid`，实现时要按真实详情结构判断是否传空或不传；不要擅自伪造字段。
- 接口成功后把句子摘要写回当前格位。
- 已绑定句需要展示在 `ManageSentenceAddBingSentenceWidget`。

### 5. 候选句池与过滤

- 候选句只服务“分叉 / pair-fork”模式。
- 已经绑定过的句子不能重复绑定到其他格位。
- 如果候选为空，要有明确空态提示。
- fork 页面不需要套用 blueprint / paradigm 那种 `baseSlotKeys / dialSlotKeys` 模式。
- 但也不能按 pair 双格位逻辑硬编码，因为 fork 的 `to` 是多分支绑定。
- `to` 分支仍然需要保持“等 from 已经有句子后才允许操作”的交互约束。

### 6. 校验与提交

- 实现当前页面需要的 fork 版：
  - 候选查询
  - bind-check
  - match-check
  - create
- 提交参数按 fork 文档严格组装：
  - `fromSentenceId`
  - `bindings: [{ valueNid, sentenceId }]`
  - `matchFirst`
- 底部按钮逻辑参考 pair / paradigm 页面：
  - “补句落库”：至少已绑 1 句
  - “满句落库”：所有必需格位都绑满
- 底部 `ManageSentenceAddButtonsWidget` 需要完整接入：
  - `bindCount`
  - `totalCount`
  - `addSentence`
  - `fullSentence`
  - `isAddSentenceEnabled`
  - `isFullSentenceEnabled`
- fork 的 `match-check` 请求体不是 pair 的双字段，也不是 paradigm 的纯 `bindings`，而是：
  - `fromSentenceId`
  - `bindings`
- fork 的 `create` 请求体为：
  - `fromSentenceId`
  - `bindings`
  - `matchFirst`
- 提交成功后：
  - toast 提示
  - `Get.back(result: true)`

## 接口接入要求

- 先严格按 `manage_sentence_fork_add_group.md` 补接口到 `language_console.dart`
- 命名贴近现有项目风格，并与现有 pattern / paradigm / pair add-set 命名平行
- 本次至少要覆盖文档中的这些接口能力：
  - fork 按格候选
  - fork bind-check
  - fork 整套校验
  - fork 创建例句组合
- fork 候选接口：
  - `/language-console/en/sentence/pair/fork/$nid/sentence/realization/set/pair-fork/cell/candidates`
  - 结果用 `PatternRealizationSetPatternCellCandidatesEntity` 接收
- fork bind-check：
  - `/language-console/en/sentence/pair/fork/$nid/sentence/realization/set/pair-fork/bind/check`
- fork match-check：
  - `/language-console/en/sentence/pair/fork/$nid/sentence/realization/set/pair-fork/match/check`
  - 结果用 `PatternRealizationSetPatternMatchCheckEntity` 接收
- fork create：
  - `/language-console/en/sentence/pair/fork/$nid/sentence/realization/set/pair-fork/create`
  - 返回风格参考 `createPatternRealizationSetPattern`
  - 按 `Future<bool>` 处理
- 请求前后统一：
  - `ToastUtils.showLoading()`
  - 完成后 `ToastUtils.hideLoading()`
- 校验失败、空数据、业务提示统一走 toast

## 控制器建议状态

- `forkDetail` 对应的详情实体
- `int? presetSentenceId`
- `bool fromPinned`
- 分叉格位的展示模型列表
- `RxMap<String, PatternBlueprintSentenceBriefEntity> boundSentenceMap`
  - key 建议体现格位身份，例如：
    - `from`
    - `to:<valueNid>`
- `bindCount`
- `totalCount`
- `isAddSentenceEnabled`
- `isFullSentenceEnabled`

## 代码组织要求

- Controller：
  - 变量定义放生命周期前
  - 生命周期只做初始化编排
  - 业务逻辑拆成独立私有方法
- View：
  - `build` 放最上面
  - 复杂区域拆方法，不在 `build` 里堆逻辑
- 注释：
  - 核心状态变量、公共方法、复杂私有方法都补简短注释
- 保持当前文件现有排版习惯，不做无关格式化

## 验证目标

- 从“句间配链分叉详情”页点击“添加一组”能正确进入本页
- 入口能正确传入 `forkDetail.value`
- 当入口带了 `presetSentenceId` 时，`from` 能自动回填且锁定
- 页面能展示 `from + 多个 to 分支格位`
- 每个格位能挑句、手输 uid、清空
- 已绑定信息能正确回显
- 补句落库 / 满句落库按钮状态正确
- 提交成功后能返回上一页并触发上一页刷新

## 非本次范围

- 不处理其他 realization set 模式
- 不做 UI 重构
- 不扩展无关公共组件能力，除非当前页面功能接不进去

## 实现前需特别留意

- `ManageSentenceAddSelectDialog` 之前已经支持 pattern / paradigm / pair，本次要继续扩到 fork，但不能影响前 3 者。
- fork 页面和 pair / paradigm 页面虽然都属于“成组添加”，但请求体结构不同，不能照抄：
  - paradigm 用 `bindings`
  - pair 用 `fromSentenceId / toSentenceId`
  - fork 用 `fromSentenceId + bindings`
- `valueNid` 在 fork 页面是关键维度，`to` 分支候选、校验、提交都依赖它。
- 入口页 `zhenxie_sentence_pair_fork_details_controller.dart#L289-L291` 需要补传参，不能继续空跳转。
- 当前页面现状中的“纯文本占位”描述已经过期；实现时以现有 controller / view 文件为准，不要按旧提示误判。
