# 添加一组页面修复提示词

## 目标

- 修复真写控制台下 6 个“添加一组”页面与 React 参考实现 `AddRealizationSetModal.tsx` 的关键行为差异。
- 本次只处理真实漏掉或对齐不足的功能，不做无关 UI 重构，不顺手改视觉样式。
- 修复范围覆盖：
  - `manage_sentence_blueprint_add_group`
  - `manage_sentence_pyramid_add_group`
  - `manage_sentence_paradigm_add_group`
  - `manage_sentence_grammar_add_group`
  - `manage_sentence_pair_add_group`
  - `manage_sentence_fork_add_group`

参考文件：

- React 参考：
  - `/Users/langwise/Desktop/ns/project/ui_ux/src/pages/zhenxie/sentence/components/AddRealizationSetModal.tsx`
- 公共弹窗：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/common/manage_sentence_add_select_dialog.dart`
- 单元 Target 入口：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_shared_pages/manage_unit_grammar_target_details/controllers/manage_unit_grammar_target_details_controller.dart`

## 本次确认存在的缺口

### 1. 单元入口候选句范围丢失

- 当前从“单元 Target”跳到以下页面时，没有继续把 `unitId` 往下传：
  - `paradigm`
  - `pair`
  - `fork`
  - `grammar(grid)`
- 导致这些页面进入“挑一句”后，候选句不再限制为“当前单元内的句子”，而是退回到更大的候选范围。
- React 参考实现保留了这层语义：单元入口下，候选句池只在本单元句里召回。

### 2. pair 页面缺少“先绑 from，再绑 to”的约束

- 当前 `pair` 页面：
  - `to` 格位在 `from` 未绑定前仍可直接挑句 / 手输 uid
  - 只绑 `to` 也可以点“补句落库”
- React 参考实现里：
  - `from` 未绑定前，`to` 应处于等待状态
  - “补句落库”至少要求 `from` 已绑定

### 3. fork 页面缺少“先绑 from，再绑分支”的约束

- 当前 `fork` 页面：
  - `from` 未绑定前，各 `to` 分支仍可直接挑句 / 手输 uid
  - 只绑某个 `to` 分支也可以点“补句落库”
- React 参考实现里：
  - 必须先钉共用端 `from`
  - `from` 没绑前，分支格位应处于等待状态

### 4. paradigm / pair / fork 的补句落库未先做整盘校验

- 当前这 3 类页面：
  - “满句落库”前会做 `match-check`
  - “补句落库”直接创建，不先跑整盘 `match-check`
- React 参考实现里：
  - 不论 `fill` 还是 `full`
  - 提交前都先做整盘 `match-check`
- 注意：
  - `grammar(grid)` 当前已经会先做 `match-check`
  - `blueprint` / `pyramid` 当前也已经先做校验
  - 这一条只修 `paradigm / pair / fork`

## 修复优先级

### P0

- 单元入口下 `paradigm / pair / fork / grid` 的 `unitId` 透传与候选句范围限制
- `pair` 的 `from` 前置约束
- `fork` 的 `from` 前置约束

### P1

- `paradigm / pair / fork` 的“补句落库”补齐整盘 `match-check`

### P2

- 统一空态文案、按钮禁用态、提示语与 React 行为对齐
- 统一“等待 from 先绑定”时的交互禁用表现，避免页面间体验漂移

## 明确修复要求

### A. 单元入口参数传递

- 从 `ManageUnitGrammarTargetDetailsController.onTapAddGroup` 开始修：
  - `paradigm / pair / fork / grid` 入口要补传 `unitId`
- 对应页面控制器要补接 `unitId`
- 打开 `ManageSentenceAddSelectDialog` 时，要把 `unitId` 继续传入弹窗 model
- `ManageSentenceAddSelectDialog` 组装请求体时：
  - 对需要受单元限制的页面类型，必须把 `unitId` 带下去
- 不要只改页面控制器，不改入口
- 不要只改入口，不改弹窗请求体
- 这条必须整链路打通

### B. pair 的 from 前置约束

- 页面交互要与 React 对齐：
  - `from` 未绑定前，`to` 的“挑一句 / 手输 uid”不可用
  - “补句落库”至少要求 `from` 已绑定，不是“任意已绑 1 句”
- “满句落库”仍要求两个格位都绑满
- 文案已经写着“只能先钉这一端”，行为必须跟上，不能只有文案没有约束

### C. fork 的 from 前置约束

- 页面交互要与 React 对齐：
  - `from` 未绑定前，各 `to` 分支的“挑一句 / 手输 uid”不可用
  - “补句落库”至少要求 `from` 已绑定，不是“任意已绑 1 句”
- “满句落库”仍要求：
  - `from` 已绑定
  - 所有分支都绑满
- 文案已经写着“先钉共用端”，行为必须跟上

### D. paradigm / pair / fork 的补句前整盘校验

- `addSentence()` 最终走到提交时：
  - 不能直接 `create`
  - 必须先跑各自页面对应的 `match-check`
- 若 `match-check` 失败：
  - 统一 toast 提示
  - 不发起 `create`
- 若 `match-check` 通过：
  - 再继续 `create`
- 这里要与 React 的提交流程对齐，而不是继续沿用当前“只有满句才校验”的简化逻辑

## 实现约束

- 不做无关格式化。
- 不改现有页面的大体 UI 结构。
- 优先复用已有公共组件与公共弹窗。
- 不新增无意义抽象层。
- 注释要保留当前项目风格，核心状态和关键分支继续写清楚。
- 不要因为修这几个行为，顺手把 6 个页面全部重写。
- 修改应以局部、稳定、可验证为主。

## 建议修改点

### 入口链路

- `manage_shared_pages/manage_unit_grammar_target_details/controllers/manage_unit_grammar_target_details_controller.dart`

### 公共弹窗

- `common/manage_sentence_add_select_dialog.dart`

### 受影响页面

- `manage_sentence_paradigm_add_group/controllers/manage_sentence_paradigm_add_group_controller.dart`
- `manage_sentence_pair_add_group/controllers/manage_sentence_pair_add_group_controller.dart`
- `manage_sentence_fork_add_group/controllers/manage_sentence_fork_add_group_controller.dart`
- `manage_sentence_grammar_add_group/controllers/manage_sentence_grammar_add_group_controller.dart`
- 如有必要，再补对应 view 的按钮禁用态

## 验证清单

### 1. 单元入口验证

- 从单元 Target 进入 `paradigm / pair / fork / grid`
- 打开“挑一句”
- 候选句只来自当前单元，不再是全库兜底
- 当单元里没有可用句时，空态文案正确

### 2. pair 验证

- `from` 未绑时：
  - `to` 不能挑句
  - `to` 不能手输 uid
  - “补句落库”不可点
- 只绑 `from` 时：
  - “补句落库”可点
- `from + to` 都绑完时：
  - “满句落库”可点

### 3. fork 验证

- `from` 未绑时：
  - 所有 `to` 分支不能挑句
  - 所有 `to` 分支不能手输 uid
  - “补句落库”不可点
- 只绑 `from` 时：
  - “补句落库”可点
- `from + 全部分支` 都绑完时：
  - “满句落库”可点

### 4. 提交流程验证

- `paradigm / pair / fork` 点击“补句落库”时：
  - 会先走 `match-check`
  - 校验失败不会创建
  - 校验通过才创建
- `grid / blueprint / pyramid` 原有提交流程不能回归

## 非本次范围

- 不处理新的页面模式拆分
- 不新增新的业务接口
- 不重做样式
- 不调整 React 文案本身
- 不扩展与本次缺口无关的公共组件能力

## 最终目标

- 让 Flutter 版 6 个“添加一组”页面在关键业务行为上重新对齐 React 原版。
- 尤其保证：
  - 单元入口范围不丢
  - `pair / fork` 的 `from` 前置约束不丢
  - `paradigm / pair / fork` 的补句前整盘校验不丢
