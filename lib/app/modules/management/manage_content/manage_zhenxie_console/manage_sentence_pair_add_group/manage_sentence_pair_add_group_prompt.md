# 页面实现提示词

## 页面目标

- 完成 `manage_sentence_pair_add_group` 页面功能。
- 当前阶段只实现“配对”模式，对应入口：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/zhenxie/zhenxie_sentence_pair_details/controllers/zhenxie_sentence_pair_details_controller.dart#L348-L350`
- 页面现有 UI 结构、样式、布局不要动，只补控制器状态、数据流、显隐、交互和接口调用。
- 参考实现：
  - `/Users/langwise/Desktop/ns/project/ui_ux/src/pages/zhenxie/sentence/components/AddRealizationSetModal.tsx`
- 直接参考已完成页面：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/manage_sentence_paradigm_add_group`

## 强约束

- 只做“配对”功能，不实现 blueprint / paradigm / fork / pyramid 其他模式。
- 不改现有 UI 树结构，不顺手重排版，不改视觉文案。
- 接口统一补到：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/common/https/language_console.dart`
- 接口说明来源：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/manage_sentence_pair_add_group/manage_sentence_pair_add_group.md`
- 控制器里尽量少用 `Get` 语法：
  - 仅保留页面生命周期、路由入参、返回关闭等必要 GetX 框架用法
  - 不要到处写 `Get.find()`、`Get.context`
  - 优先显式参数传递、局部状态、普通方法组织
- “挑一句”必须复用现有弹窗：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/common/manage_sentence_add_select_dialog.dart`
- 但弹窗内部候选句接口不能写死成 blueprint / paradigm 版本，必须继续扩展到支持 pair。
- 页面类型统一使用：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/common/enum/zhenxie_en_sentence_type.dart`
  - 本页固定使用 `ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR`

## 当前页面现状

- 页面壳子已存在：
  - `views/manage_sentence_pair_add_group_view.dart`
  - `controllers/manage_sentence_pair_add_group_controller.dart`
- 路由已存在：
  - `Routes.MANAGE_SENTENCE_PAIR_ADD_GROUP`
- 注册入口已接好。
- 当前 View 还只是一个纯文本占位：
  - `ManageScaffold -> Center -> Text('添加一组')`
- 当前入口页：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/zhenxie/zhenxie_sentence_pair_details/controllers/zhenxie_sentence_pair_details_controller.dart#L348-L350`
  - 这里不能空跳转，必须把本页所需参数显式传入 `ManagePageRegistry.jumpTo`
- 页面实现时，公共添加组件优先复用：
  - `manage_sentence_add_widgets.dart`
  - `manage_sentence_add_select_dialog.dart`

## 需要完成的功能范围

### 1. 页面入参与初始化

- 从页面入口接收并解析完成“配对”功能所需参数。
- 入口页跳转时必须传参，不允许页面内部再依赖模糊上下文猜测。
- 优先直接传：
  - `pairDetail.value`
- 单元 Target 入口额外支持传：
  - `presetSentenceId`
- 不建议单独重复传：
  - `nid`
  - `isManagement`
  - `realizationSetId`
- `nid` 直接从传入的 `pairDetail` 中读取。
- 当入口带了 `presetSentenceId` 时：
  - 先用 `querySentenceStructure` 按 `contents: [{ type, uid }]` 查询这句的结构化摘要
  - 查回后直接预填到 `from`
  - 同时视为 `fromPinned = true`
  - `from` 不允许再挑句、手输 uid、清空
- 初始化时完成：
  - 页面标题/副标题依赖的数据准备
  - `from / to` 两个格位的数据准备
  - 默认样句准备
  - 已绑定句状态初始化

### 2. 配对格位构建

- 本页只处理“配对”模式，因此页面固定只有两个格位：
  - `from`
  - `to`
- 每个格位需要具备：
  - 当前格位标识 `cell`
  - 当前格位名称或标签
  - 默认样句
  - 已绑定句信息
  - 候选句请求所需参数
- `from` 格位额外需要支持：
  - 预填锁定态 `fromPinned`
  - 当 `fromPinned` 为 `true` 时，展示“已选定”而不是“换一句”
- 页面 UI 可以继续复用“第 1 句 / 第 2 句”这套公共卡片，不要求重做视觉结构。

### 3. 样句展示

- 顶部样句区沿用 `ManageSentenceAddExampleWidget`。
- 如果 pair 页面没有对照高亮所需结构，不强行接 `SameGroupCompareHighlightTextWidget` 的高亮能力。
- 样句至少要能正确展示默认句面，并保证后续如果补充结构化字段时可扩展。
- `pairDetail` 里如果带有 `teachingExampleFromZh / teachingExampleToZh`，要映射到句子摘要的 `definition` 作为中文兜底。
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
  - pair 页面新增走 `manage_sentence_pair_add_group.md` 中“对照按格候选”接口
- pair 候选接口请求体为：
  - `cell`
  - `boundSentenceIds`
- “手输 uid”走 pair 的 bind-check 接口，请求体为：
  - `cell`
  - `sentenceId`
- 接口成功后把句子摘要写回当前格位。
- 已绑定句需要展示在 `ManageSentenceAddBingSentenceWidget`。

### 5. 候选句池与过滤

- 候选句只服务“配对”模式。
- 已经绑定过的句子不能重复绑定到另一个格位。
- 如果候选为空，要有明确空态提示。
- pair 页面不需要套用 blueprint / paradigm 那种 `baseSlotKeys / dialSlotKeys / valueNid` 模式。
- `to` 格位仍然需要保持“等 from 已经有句子后才允许操作”的交互约束。

### 6. 校验与提交

- 实现当前页面需要的 pair 版：
  - 候选查询
  - bind-check
  - match-check
  - create
- 提交参数按 pair 文档严格组装：
  - `fromSentenceId`
  - `toSentenceId`
  - `matchFirst`
- 底部按钮逻辑参考 paradigm 页面：
  - “补句落库”：至少已绑 1 句
  - “满句落库”：两个格位都绑满
- 底部 `ManageSentenceAddButtonsWidget` 需要完整接入：
  - `bindCount`
  - `totalCount`
  - `addSentence`
  - `fullSentence`
  - `isAddSentenceEnabled`
  - `isFullSentenceEnabled`
- pair 的 `match-check` 请求体不是 `bindings`，而是：
  - `fromSentenceId`
  - `toSentenceId`
- pair 的 `create` 请求体不是 `bindings`，而是：
  - `fromSentenceId`
  - `toSentenceId`
  - `matchFirst`
- 提交成功后：
  - toast 提示
  - `Get.back(result: true)`

## 接口接入要求

- 先严格按 `manage_sentence_pair_add_group.md` 补接口到 `language_console.dart`
- 命名贴近现有项目风格，并与现有 pattern / paradigm add-set 命名平行
- 本次至少要覆盖文档中的这些接口能力：
  - pair 按格候选
  - pair bind-check
  - pair 整套校验
  - pair 创建例句组合
- pair 候选接口：
  - `/language-console/en/sentence/pair/state_sentence_type_contrast/sentence/realization/set/pair/cell/candidates`
  - 结果用 `PatternRealizationSetPatternCellCandidatesEntity` 接收
- pair bind-check：
  - `/language-console/en/sentence/pair/state_sentence_type_contrast/sentence/realization/set/pair/bind/check`
- pair match-check：
  - `/language-console/en/sentence/pair/state_sentence_type_contrast/sentence/realization/set/pair/match/check`
  - 结果用 `PatternRealizationSetPatternMatchCheckEntity` 接收
- pair create：
  - `/language-console/en/sentence/pair/$nid/sentence/realization/set/pair/create`
  - 返回风格参考 `createPatternRealizationSetPattern`
  - 按 `Future<bool>` 处理
- 请求前后统一：
  - `ToastUtils.showLoading()`
  - 完成后 `ToastUtils.hideLoading()`
- 校验失败、空数据、业务提示统一走 toast

## 控制器建议状态

- `SentencePairEntity? pairDetail`
- `int? presetSentenceId`
- `bool fromPinned`
- 固定两个格位的展示模型列表
- `RxMap<String, PatternBlueprintSentenceBriefEntity> boundSentenceMap`
  - key 建议直接用：
    - `from`
    - `to`
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

- 从“句间配链详情”页点击“添加一组”能正确进入本页
- 入口能正确传入 `pairDetail.value`
- 当入口带了 `presetSentenceId` 时，`from` 能自动回填且锁定
- 页面能展示 `from / to` 两个格位
- 每个格位能挑句、手输 uid、清空
- 已绑定信息能正确回显
- 补句落库 / 满句落库按钮状态正确
- 提交成功后能返回上一页并触发上一页刷新

## 非本次范围

- 不处理其他 realization set 模式
- 不做 UI 重构
- 不扩展无关公共组件能力，除非当前页面功能接不进去

## 实现前需特别留意

- `ManageSentenceAddSelectDialog` 之前已经支持 pattern / paradigm，本次要继续扩到 pair，但不能影响前两者。
- pair 页面和 paradigm 页面虽然都属于“成组添加”，但请求体结构不同，不能照抄：
  - paradigm 用 `bindings`
  - pair 用 `fromSentenceId / toSentenceId`
- 入口页 `zhenxie_sentence_pair_details_controller.dart#L348-L350` 需要补传参，不能继续空跳转。
