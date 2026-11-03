# 页面实现提示词

## 页面目标

- 完成 `manage_sentence_paradigm_add_group` 页面功能。
- 当前阶段只实现“对照”模式，对应入口：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/zhenxie/zhenxie_sentence_pattern_compare_details/controllers/zhenxie_sentence_pattern_compare_details_controller.dart#L343-L345`
- 页面现有 UI 结构、样式、布局不要动，只补控制器状态、数据流、显隐、交互和接口调用。
- 参考实现：
  - `/Users/langwise/Desktop/ns/project/ui_ux/src/pages/zhenxie/sentence/components/AddRealizationSetModal.tsx`
- 可参考相似页面：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/manage_sentence_blueprint_add_group`

## 强约束

- 只做“对照”功能，不实现 blueprint / pair / fork / pyramid 其他模式。
- 不改现有 UI 树结构，不顺手重排版，不改视觉文案。
- 接口统一补到：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/common/https/language_console.dart`
- 接口说明来源：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/manage_sentence_paradigm_add_group/manage_sentence_paradigm_add_group.md`
- 控制器里尽量少用 `Get` 语法：
  - 仅保留页面生命周期、路由入参、返回关闭等必要 GetX 框架用法
  - 不要到处写 `Get.find()`、`Get.context`
  - 优先显式参数传递、局部状态、普通方法组织
- “挑一句”必须复用现有弹窗：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/common/manage_sentence_add_select_dialog.dart`
- 但弹窗内部候选句接口不能写死成 blueprint 版本，必须根据页面类型分流。
- 页面类型统一使用：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/common/enum/zhenxie_en_sentence_type.dart`
  - 本页固定使用 `ZhenxieEnSentenceType.EN_SENTENCE_PARADIGM`

## 当前页面现状

- 页面壳子已存在：
  - `views/manage_sentence_paradigm_add_group_view.dart`
  - `controllers/manage_sentence_paradigm_add_group_controller.dart`
- 路由已存在：
  - `Routes.MANAGE_SENTENCE_PARADIGM_ADD_GROUP`
- 注册入口已接好：
  - `manage_page_registry.dart`
- 绑句卡片区域已经预留：
  - `ManageSentenceAddBingWidget`
  - `ManageSentenceAddExampleWidget`
- 样句高亮区域必须改用：
  - `SameGroupCompareHighlightTextWidget`
  - 位置：`/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/common/manage_sentence_add_widgets.dart#L390`
- 底部按钮区域已经加上：
  - `views/manage_sentence_paradigm_add_group_view.dart#L76`
  - 这里的 `ManageSentenceAddButtonsWidget` 不是占位，显示、计数、可点击状态、点击事件都要完整接好
- 当前入口页：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/zhenxie/zhenxie_sentence_pattern_compare_details/controllers/zhenxie_sentence_pattern_compare_details_controller.dart#L343-L345`
  - 这里不能空跳转，必须把本页所需参数显式传入 `ManagePageRegistry.jumpTo`

## 需要完成的功能范围

### 1. 页面入参与初始化

- 从页面入口接收并解析完成“对照”功能所需参数。
- 入口页跳转时必须传参，不允许页面内部再依赖模糊上下文猜测。
- 不需要单独传：
  - `isManagement`
  - `nid`
  - `realizationSetId`
- `nid` 直接从传入的 `detailData` 中读取。
- 入口最小传参集合优先直接传：
  - `detailData.value`
  - 以及页面初始化真正必需、但 `detailData` 内没有的少量补充字段（若后续实现确认存在）
- 单元 Target 入口额外支持传：
  - `presetSentenceIds`
- 当入口带了 `presetSentenceIds` 时：
  - 先用 `querySentenceStructure` 按 `contents: [{ type, uid }]` 批量补查句子结构
  - 再按句子的 `patternNid` 和当前成员的 pattern 对应关系自动预绑到各格位
  - 未匹配上的句子直接跳过，不额外报错
- 优先从 `zhenxie_sentence_pattern_compare_details_controller.dart` 的详情数据和当前上下文推导最小入参集合。
- 初始化时完成：
  - 页面标题/副标题依赖的数据准备
  - 对照成员列表准备
  - anchor / members / 候选句池准备
  - 默认绑句状态初始化

### 2. 对照成员表构建

- 根据接口返回的 `anchor + members` 构建页面展示所需的卡片列表。
- 每个成员需要具备：
  - 当前格位标识
  - 当前成员标签/名称
  - patternNid / valueNid
  - 默认样句
  - 对照高亮所需信息
  - 已绑定句信息
- 预绑时成员匹配规则固定为：
  - 预填句 `patternNid`
  - 对成员 `member.realizationInfo?.pattern?.nid ?? member.realization?.patternNid`
  - 同一个成员只占 1 句，按 `presetSentenceIds` 原顺序优先命中
- 页面中“第 x 句”的现有 UI 不动，但底层数据要映射到“对照成员格位”。

### 3. 样句展示

- `ManageSentenceAddExampleWidget` 内部改用 `SameGroupCompareHighlightTextWidget`。
- 高亮数据必须基于当前成员对应的样句和对照证据生成。
- 没有样句时保留空态兜底，不能报错。
- 这里仅替换展示组件和所需入参，不调整容器样式。

### 4. 挑一句 / 手输 uid

- 每个格位支持：
  - 挑一句
  - 手输 uid
  - 清空已绑定句
- “挑一句”复用 `ManageSentenceAddSelectDialog`，不要新写一套弹窗。
- `ManageSentenceAddSelectDialog` 需要扩展“页面类型”入参，并在内部根据 `ZhenxieEnSentenceType` 决定调用哪个候选句接口：
  - blueprint 页面继续走现有 pattern blueprint 候选接口
  - paradigm 页面改走 `manage_sentence_paradigm_add_group.md` 中“对照按格候选”接口
- 弹窗要做到对旧 blueprint 页面无回归。
- “手输 uid”走校验接口。
- 接口成功后把句子摘要写回当前格位。
- 已绑定句需要展示在 `ManageSentenceAddBingSentenceWidget`。

### 5. 候选句池与过滤

- 候选句只服务“对照”模式。
- 候选句列表需要按当前格位所属成员、pattern、valueNid、anchor 或接口规定参数来查询。
- 已经绑定过的句子不能重复绑定到其他格位。
- 如果候选为空，要有 toast 或明确提示。

### 6. 校验与提交

- 实现当前页面需要的 match-check / bind-check / create 或文档中对应接口。
- `manage_sentence_paradigm_add_group.md` 里已经补了接口名字，实现时直接按文档命名和职责接入 `language_console.dart`。
- 提交时只组装“对照”模式所需参数。
- 底部按钮逻辑参考 blueprint 页面：
  - “补句落库”：至少已绑 1 句
  - “满句落库”：全部格位绑满
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

## 实体与结构要求

- 能复用现有 entity 就复用，不新增重复模型。
- 如果页面确实需要专用展示 model：
  - 优先定义在对应 widget 文件中
  - 不要散落到 view / controller 外的无关位置
- 不要为了简单判空或展示包装过多一次性中转变量。
- 状态命名要直接表达业务含义。

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

## 接口接入要求

- 先严格按 `manage_sentence_paradigm_add_group.md` 补接口到 `language_console.dart`
- 命名贴近现有项目风格
- 对照模式本次至少要覆盖文档中的这些接口能力：
  - 查询候选
  - 对照按格候选
  - 对照 bind-check
  - 对照整套校验
  - 对照创建例句组合
- “对照创建例句组合”接口路径已确认修正为：
  - `/language-console/en/sentence/paradigm/$nid/sentence/realization/set/paradigm/create`
- “对照创建例句组合”接口返回类型参考：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/common/https/language_console.dart#L3499`
  - 与 `createPatternRealizationSetPattern` 一致，按 `Future<bool>` 处理
- “对照整套校验”的请求体已明确为：
  - `bindings: [{ valueNid, sentenceId }]`
- “对照创建例句组合”实现时，提交请求体优先按文档里已补齐的字段直接组装，不额外猜字段。
- 请求前后统一：
  - `ToastUtils.showLoading()`
  - 完成后 `ToastUtils.hideLoading()`
- 校验失败、空数据、业务提示统一走 toast

## 验证目标

- 从“句型对照详情”页点击“添加一组”能正确进入本页
- 页面能基于对照接口拉起成员与样句
- 样句区域能正确使用 `SameGroupCompareHighlightTextWidget`
- 每个格位能挑句、手输 uid、清空
- 已绑定信息能正确回显
- 补句落库 / 满句落库按钮状态正确
- 提交成功后能返回上一页并触发上一页刷新

## 非本次范围

- 不处理其他 realization set 模式
- 不做 UI 重构
- 不扩展无关公共组件能力，除非当前页面功能接不进去

## 实现前需特别留意

- `ManageSentenceAddSelectDialog` 当前在 `#L226-L230` 处写死调用 blueprint 候选接口，实现时必须改成按页面类型分流，但不能影响原有 blueprint 页面。
- `SameGroupCompareHighlightTextWidget` 的关键入参包括：
  - `sentenceStruct`
  - `contrastFocus`
  - `sentenceId`
  - `isManagement`
  - `isNormal`
  - 需要按当前对照成员的样句数据正确映射
- 文档里的创建接口路径已经修正，不再按 `match/check` 误判处理。
- 当前前置信息已经基本齐全，可以直接开始实现；除非后续发现文档字段和真实接口返回不一致，再回头校对。
