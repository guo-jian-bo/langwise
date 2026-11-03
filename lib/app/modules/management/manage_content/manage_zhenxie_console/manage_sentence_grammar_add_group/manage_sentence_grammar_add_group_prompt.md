# 页面实现提示词

## 页面目标

- 完成 `manage_sentence_grammar_add_group` 页面功能。
- 当前阶段只实现“语法全景 / grammar grid”模式，对应入口：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/zhenxie/zhenxie_grammar_panorama_details/controllers/zhenxie_grammar_panorama_details_controller.dart#L383-L387`
- 页面现有 UI 结构、样式、布局不要动，只补控制器状态、数据流、显隐、交互和接口调用。
- 参考实现：
  - `/Users/langwise/Desktop/ns/project/ui_ux/src/pages/zhenxie/sentence/components/AddRealizationSetModal.tsx`
- 直接参考已完成页面：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/manage_sentence_paradigm_add_group`
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/manage_sentence_pair_add_group`
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/manage_sentence_fork_add_group`
- 额外对齐前端参考文件里的交互节奏：
  - grid 模式直接使用 `gridMembers` 作为格位列表来源
  - 不做 pattern / pyramid 那种“先改形态、再生成格位”的一层编辑流程
  - 页面核心是“展示既有盘面 -> 每格绑句 -> 整盘校验 -> 提交”

## 强约束

- 只做“语法全景 / grammar grid”功能，不实现 blueprint / paradigm / pair / fork 其他模式。
- 不改现有 UI 树结构，不顺手重排版，不改视觉文案。
- 接口统一补到：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/common/https/language_console.dart`
- 接口说明来源：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/manage_sentence_grammar_add_group/manage_sentence_grammar_add_group.md`
- 控制器里尽量少用 `Get` 语法：
  - 仅保留页面生命周期、路由入参、返回关闭等必要 GetX 框架用法
  - 不要到处写 `Get.find()`、`Get.context`
  - 优先显式参数传递、局部状态、普通方法组织
- “挑一句”必须复用现有弹窗：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/common/manage_sentence_add_select_dialog.dart`
- 但弹窗内部候选句接口不能写死成 blueprint / paradigm / pair / fork 版本，必须继续扩展到支持 grammar grid。
- 页面类型统一使用：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/common/enum/zhenxie_en_sentence_type.dart`
  - 本页固定使用 `ZhenxieEnSentenceType.EN_SENTENCE_GRAMMAR_GRID`

## 当前页面现状

- 页面壳子已存在：
  - `views/manage_sentence_grammar_add_group_view.dart`
  - `controllers/manage_sentence_grammar_add_group_controller.dart`
- 路由已存在：
  - `Routes.MANAGE_SENTENCE_GRAMMAR_ADD_GROUP`
- 注册入口已接好。
- 当前 View 还只是一个纯文本占位：
  - `ManageScaffold -> Center -> Text('添加一组')`
- 当前入口页：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/zhenxie/zhenxie_grammar_panorama_details/controllers/zhenxie_grammar_panorama_details_controller.dart#L383-L387`
  - 这里不能空跳转，必须把本页所需参数显式传入 `ManagePageRegistry.jumpTo`
- 页面实现时，公共添加组件优先复用：
  - `manage_sentence_add_widgets.dart`
  - `manage_sentence_add_select_dialog.dart`
- 参考 TSX 后，本页应优先理解为：
  - 已有全景盘面
  - 直接遍历格位
  - 每格执行挑句 / 手输 uid / 清空
  - 最后统一校验和提交
- 不要给 grammar grid 页面额外造一层不存在的“形态编辑器”。

## 需要完成的功能范围

### 1. 页面入参与初始化

- 从页面入口接收并解析完成“语法全景 / grammar grid”功能所需参数。
- 入口页跳转时必须传参，不允许页面内部再依赖模糊上下文猜测。
- 优先直接传：
  - `detailData.value`
- 不建议单独重复传：
  - `nid`
  - `isManagement`
  - `realizationSetId`
- `nid` 直接从传入的详情实体中读取。
- 初始化时完成：
  - 页面标题/副标题依赖的数据准备
  - 全景格位数据准备
  - 轴值映射 `axisValues` 准备
  - 默认样句准备
  - 已绑定句状态初始化
- 参考 `AddRealizationSetModal.tsx`，初始化还要满足这些行为：
  - 进入页面时清空本地草稿态
  - 清空手输输入草稿
  - 清空当前错误提示
  - 清空挑句弹窗的目标格位和搜索词
  - 清空整盘校验错误

### 2. 全景格位构建

- 本页不是固定双格位，也不是 `from + 多个 to`。
- 需要根据 grammar grid 详情里的盘面结构生成格位列表，不能写死格位数量。
- 参考 `AddRealizationSetModal.tsx` 的 grid 分支：
  - 本页的格位列表应当等价于前端的 `gridMembers`
  - 也就是“页面拿到什么盘面格位，就按那个顺序渲染什么格位”
  - 不再额外推导 `from / to / fork` 那一套结构
- 每个格位需要具备：
  - 当前格位标识 `cell`
  - 当前格位 `valueNid`
  - 当前轴值映射 `axisValues`
  - 默认样句
  - 已绑定句信息
  - 候选句请求所需参数
- 每个格位的页面态要尽量对齐 TSX 里的 `SheetMember` / `DraftBinding` 语义：
  - `cell`
  - `label`
  - `sentenceId`
  - `text`
- 页面 UI 可以继续复用公共绑句卡片结构，不要求重做视觉结构。

### 3. 样句展示

- 顶部样句区沿用 `ManageSentenceAddExampleWidget`。
- 如果 grammar grid 当前没有对照高亮所需结构，不强行接复杂高亮逻辑。
- 样句至少要能正确展示默认句面，并保证后续如果补充结构化字段时可扩展。
- 没有样句时保留空态兜底，不能报错。

### 4. 挑一句 / 手输 uid

- 每个格位支持：
  - 挑一句
  - 手输 uid
  - 清空已绑定句
- “挑一句”复用 `ManageSentenceAddSelectDialog`，不要新写一套弹窗。
- `ManageSentenceAddSelectDialog` 需要继续扩展“页面类型”入参，并在内部根据 `ZhenxieEnSentenceType` 决定调用哪个候选句接口：
  - blueprint 页面继续走现有 pattern 接口
  - paradigm 页面继续走现有 paradigm 接口
  - pair 页面继续走现有 pair 接口
  - fork 页面继续走现有 fork 接口
  - grammar 页面新增走 `manage_sentence_grammar_add_group.md` 中的 grid 候选接口
- grammar grid 候选接口请求体至少涉及：
  - `cell`
  - `valueNid`
  - `axisValues`
  - `boundSentenceIds`
- 挑句弹窗的交互节奏要参考 `AddRealizationSetModal.tsx`：
  - 打开弹窗时只拉当前格位候选
  - 弹窗内支持本地按 `sentenceId / text` 搜索过滤
  - 选中候选后立刻回写当前格位
  - 关闭弹窗时清空弹窗态
- 文档里还提供了一个全景候选接口：
  - `/sentence/realization/set/grid/candidates`
  - 请求体只有 `sentenceId`
- 实现前要先判断这个接口在页面中的职责：
  - 是全局候选入口
  - 还是已知句子后反推候选
  - 不要未经确认就和按格候选混用
- “手输 uid”要走 grammar grid 对应的 bind-check 接口。
- 但当前文档中 bind-check / match-check / create 路径看起来还是 fork 的复制内容，实现前必须先按 grammar grid 实际语义校对接口路径和请求体。
- 接口成功后把句子摘要写回当前格位。
- 已绑定句需要展示在 `ManageSentenceAddBingSentenceWidget`。
- 手输 uid 的交互也要贴近 TSX：
  - 输入后立刻触发 bind-check
  - 校验通过则写回当前格位
  - 校验失败则清掉当前格位绑定并展示错误原因

### 5. 候选句池与过滤

- 候选句只服务“语法全景 / grammar grid”模式。
- 已经绑定过的句子不能重复绑定到其他格位。
- 如果候选为空，要有明确空态提示。
- 空态提示优先沿用现有 `emptyReason -> 文案` 的统一映射方式。
- grammar 页面不能套用 blueprint / paradigm 的 `baseSlotKeys / dialSlotKeys` 模式。
- 也不能直接照搬 pair / fork 的请求体，因为 grammar grid 依赖 `axisValues`。

### 6. 校验与提交

- 实现当前页面需要的 grammar 版：
  - 候选查询
  - bind-check
  - match-check
  - create
- 参考 `AddRealizationSetModal.tsx`，grammar grid 的提交节奏应当是：
  - 页面内先汇总当前所有已绑定格位
  - 点击“补句落库 / 满句落库”时先走整盘 `match-check`
  - `match-check` 失败时展示整盘错误，而不是静默失败
  - `match-check` 通过后再调用 `create`
- 提交参数要严格按 grammar 文档最终版本组装。
- 但当前文档里的 bind-check / match-check / create 仍然像 fork 文档，不能直接照接。
- 在真正写代码前，必须先确认：
  - grammar grid 的 bind-check 路径
  - grammar grid 的 match-check 路径
  - grammar grid 的 create 路径
  - grammar grid 的请求体结构
- 底部按钮逻辑参考其他 add-group 页面：
  - “补句落库”：至少已绑 1 句
  - “满句落库”：所有必需格位都绑满
- 这块也要贴近 TSX 的 `canFill / canFull` 语义：
  - `canFill` 只要求至少已有最小可提交绑定
  - `canFull` 要求当前盘面所有格位都绑满
- 底部 `ManageSentenceAddButtonsWidget` 需要完整接入：
  - `bindCount`
  - `totalCount`
  - `addSentence`
  - `fullSentence`
  - `isAddSentenceEnabled`
  - `isFullSentenceEnabled`
- 提交成功后：
  - toast 提示
  - `Get.back(result: true)`

## 接口接入要求

- 先严格按 `manage_sentence_grammar_add_group.md` 补接口到 `language_console.dart`
- 命名贴近现有项目风格，并与现有 pattern / paradigm / pair / fork add-set 命名平行
- 本次至少要覆盖文档中的这些接口能力：
  - grammar grid 全景候选
  - grammar grid 按格候选
  - grammar grid bind-check
  - grammar grid 整套校验
  - grammar grid 创建例句组合
- 当前文档里可以先确定的接口：
  - `/language-console/en/sentence/grid/$nid/sentence/realization/set/grid/candidates`
  - `/language-console/en/sentence/grid/$nid/sentence/realization/set/grid/cell/candidates`
- 候选结果统一用：
  - `PatternRealizationSetPatternCellCandidatesEntity`
- bind-check / match-check / create 当前文档疑似仍是 fork 路径占位：
  - 实现前必须先校正文档
  - 未校正前不要把 fork 路径接到 grammar 页面上
- create 的返回风格默认参考：
  - `createPatternRealizationSetPattern`
  - 按 `Future<bool>` 处理
- 请求前后统一：
  - `ToastUtils.showLoading()`
  - 完成后 `ToastUtils.hideLoading()`
- 校验失败、空数据、业务提示统一走 toast

## 控制器建议状态

- grammar 详情实体
- 全景格位展示模型列表
- `RxMap<String, PatternBlueprintSentenceBriefEntity> boundSentenceMap`
  - key 建议体现格位身份，例如：
    - `cell:valueNid`
    - 或者更完整的 `cell:valueNid:axisSignature`
- `draftByCell`
  - 记录每个格位当前手输 uid 草稿
- `manualCell`
  - 当前是否处于某个格位的手输态
- `pickerTarget`
  - 当前挑句弹窗对应的格位
- `pickerQuery`
  - 挑句弹窗内本地搜索词
- `boardError`
  - 整盘校验失败提示
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

- 从“语法全景详情”页点击“添加一组”能正确进入本页
- 入口能正确传入详情实体
- 页面能展示全景格位列表
- 每个格位能挑句、手输 uid、清空
- 已绑定信息能正确回显
- 补句落库 / 满句落库按钮状态正确
- 提交成功后能返回上一页并触发上一页刷新

## 非本次范围

- 不处理其他 realization set 模式
- 不做 UI 重构
- 不扩展无关公共组件能力，除非当前页面功能接不进去

## 实现前需特别留意

- `ManageSentenceAddSelectDialog` 之前已经支持 pattern / paradigm / pair / fork，本次要继续扩到 grammar，但不能影响前几者。
- grammar 页面和 pair / fork / paradigm 页面虽然都属于“成组添加”，但请求体结构很可能不同，不能照抄。
- 参考 `AddRealizationSetModal.tsx` 后要特别注意：
  - grammar grid 更接近“直接对现成 cells 做绑句”
  - 不是先做形态锁或生长槽编辑
  - 不要把 pattern / pyramid 那套状态搬进来
- 当前文档最明显的风险点：
  - bind-check / match-check / create 路径看起来仍然是 fork 的复制内容
  - 这些必须先修正文档，再开始正式接接口
- 入口页 `zhenxie_grammar_panorama_details_controller.dart#L383-L387` 需要补传参，不能继续空跳转。
