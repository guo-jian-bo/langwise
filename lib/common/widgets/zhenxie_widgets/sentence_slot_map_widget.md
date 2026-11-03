# SentenceSlotMapWidget 复刻提示词

## 目标

请将 Web 端 `PatternTemplateChips.tsx` 的核心逻辑复刻到 Flutter 组件 `SentenceSlotMapWidget` 中，但注意这里复刻的是“数据组织和 UI 表达逻辑”，不是逐行照搬 React 实现。

这个组件本质上不是“把槽位数组平铺出来”，而是：

1. 先读取 `pattern.template`
2. 按模板中的 `{slotKey}` 和普通字面量切成 token
3. 把 token 转成统一的 segment 列表
4. 再把 segment 渲染成一条横向可滚动的标注行
5. 如有依赖关系，再在底部补一行 `dependsOn` 关系展示

也就是说，UI 的数据源以 `template` 为主，而不是单纯遍历 `controlledGrammarSlots` / `openSlots`。

### 边界声明

这份提示词只覆盖“蓝图骨架行”的复刻，目标对齐 Web 端 `PatternTemplateChips.tsx`。

它**不**负责实现 `/docs/write/ui/admin/sentence/01.pattern&pyramid.md` 中“组装算法（外层 chips）”那套实例级逻辑。尤其不要把下面这些能力混进 `SentenceSlotMapWidget`：

- `root / children` clause 判定
- `structure_slots` 对齐
- `clause_content` 绑定 child clause 文本
- `solution_clause` / `result_clause` 的句首 `so` 剥离
- `embedded_clause` / `known_fact` 的句首 `that` 剥离
- 必填缺口 `缺` 占位
- residual / 余文插入

换句话说，`SentenceSlotMapWidget` 展示的是“模板骨架上的槽位名称”，不是“某个真实句子被组装出来后的表层文本”。

---

## React 原组件逻辑拆解

对应文件：

- `ui_ux/src/pages/zhenxie/sentence/components/PatternTemplateChips.tsx`
- `ui_ux/src/pages/zhenxie/sentence/utils/templateParse.ts`
- `ui_ux/src/pages/zhenxie/sentence/utils/slotLabel.ts`
- `ui_ux/src/pages/zhenxie/sentence/utils/slotColor.ts`

其中真正的算法主链是：

- `PatternTemplateChips.tsx`
- `templateParse.ts`
- `slotLabel.ts`

`AnnotatedSentenceRow.tsx` / `annotatedSegment.ts` 属于“实例句面标注行”范畴，只能借其 UI segment 组织思路，**不能**把它当成 `SentenceSlotMapWidget` 的数据算法来源。

### 1. 模板解析

输入是 `pattern.template`，例如：

```text
{subject} {aux_have_marking} {predicate} {object}
```

解析规则：

- 形如 `{xxx}` 的内容识别为槽位 token
- 其他普通文本识别为字面量 token
- 保留原顺序

React 里用正则：

```ts
/(\{[^}]+\}|[^{}]+)/g
```

所以 Flutter 也应该复刻同样的切分语义。

### 2. 槽位 token 补充信息

每个槽位 token 不是只有 `slotKey`，还会补齐：

- `role`
- `growthIndex`
- `dependsOn`
- `isRenderAlias`
- `sourceControlledKeys`

这些信息来自：

- `controlledGrammarSlots`
- `openSlots`
- growth 排序规则

### 3. role 判定规则

React 中 role 只有三类：

- `controlled`
- `required_open`
- `optional_open`

判定优先级：

1. 如果当前 `slotKey` 命中任一 `controlledGrammarSlots.slotKey`，或者命中任一 `controlledGrammarSlots.rendersAs`，则是 `controlled`
2. 否则在 `openSlots` 中找同名 `slotKey`
3. 找不到时默认按 `optional_open`
4. 找到且 `required == false`，则是 `optional_open`
5. 找到且 `required != false`，则是 `required_open`

### 4. segment 组装规则

最终 UI 不直接渲染 token，而是渲染 `segment`。

segment 的最小必要字段可以理解为：

```text
key
slotKey
label
text
title
selected
showCtrl
growthIndex
onTap / onClick
```

#### 字面量 token 转成 segment

- `slotKey` 固定为 `__literal__`
- `label` 固定为 `固定`
- `text` 为字面量文本，需先做空白压缩
- 连续空白折叠为一个空格
- 首尾空白去掉
- 如果清理后为空，则直接忽略，不生成 segment

React 在 `PatternTemplateChips.tsx` 里内部先给 literal 写的是 `label: '·'`，但真正渲染行组件里遇到 `__literal__` 会显示成“固定”，所以 Flutter 复刻时建议直接统一成“固定”语义，不必保留这个中间态差异。

#### 槽位 token 转成 segment

- `slotKey` = token.slotKey
- `label` 取 role 对应文案：
  - `controlled` -> `受控`
  - `required_open` -> `必填`
  - `optional_open` -> `可选`
- `text` 是槽位展示名，不是 slotKey 原文
- `title` 可用 `slotKey`
- `showCtrl = role == controlled`
- `growthIndex` 按配置决定是否显示
- 若外部支持点击，则把当前 `slotKey` 回传
- 若外部传了选中槽位或高亮槽位，需要带上选中态

### 5. 槽位展示名 resolve 规则

`text` 不是直接显示 `slotKey`，而是通过 `resolveSlotDisplayName(...)` 解析。

解析优先级：

1. 先看当前 `slotKey` 是否命中某个受控槽，或者是否是某个受控槽的 `rendersAs`
2. 如果命中受控槽：
   - 优先取“源受控槽”的名字
   - 名字来源是 `slotKeysByNid[sourceSlotKey].name`
3. 如果没有取到，再尝试直接读取 `slotKeysByNid[slotKey].name`
4. 如果还是没有，就把 `slotKey` 做 humanize：
   - 去掉 `_marking`
   - 按 `_` 拆分
   - 用空格拼回去

典型含义：

- 模板里出现的可能是 `aux_have_marking`
- 但展示时不一定叫这个 raw key
- 它可能要显示成受控源槽的规范中文名，例如“句首操作词（肯定）”

所以 Flutter 侧必须保留 `rendersAs -> source slotKey` 的回溯能力，不能只按模板里的 key 直接查名字。

### 6. dependsOn 展示逻辑

React 中不是所有槽位都画依赖，只处理槽位 token 中的 `dependsOn`。

组装方式：

- 遍历所有 slot token
- 对每个 token 的 `dependsOn` 数组展开
- 每个依赖关系都转成一条 edge：
  - `from = dep`
  - `to = token.slotKey`

UI 形式是底部横向一排：

```text
[依赖槽展示名] →dependsOn→ [当前槽展示名]
```

注意这里显示的也不是 raw key，而是同样走 `resolveSlotDisplayName(...)`。

### 7. fit / 缩放逻辑

React 外层用了 `SyncedFitScale`，本质是：

- 根据容器可用宽度
- 计算整行内容自然宽度
- 在一个最小缩放比例和最大正文大小之间做自适应缩放
- 尽量让一整行内容在列表卡或详情区里完整展示

Flutter 侧这部分不一定要一比一复刻。

当前 Flutter 版本优先级建议：

1. 第一阶段先保证横向滚动正确、视觉语义正确
2. 先不强依赖“整行自适应缩放”
3. 如果后续需要做卡片内自动缩放，再单独补

所以本次实现提示里，缩放逻辑是“可选增强项”，不是核心主链。

---

## 需要哪些字段

这里分成“直接输入给组件的字段”和“组件运行中需要的辅助映射”。

### 一、主输入字段

建议 `SentenceSlotMapWidget` 至少接收下面这些数据：

```text
pattern: PatternBlueprintEntity
lang: String
selectedSlotKey: String?
highlightSlotKeys: List<String>
showGrowth: bool
showDependsOn: bool
onSlotTap: void Function(String slotKey)?
fitContext: enum / String（可选，Flutter 第一版可先忽略）
```

其中最核心的是 `pattern`。

这里的输入故意只到 `PatternBlueprintEntity` 为止；首版**不需要**引入 sentence realization 级别的数据。

### 二、pattern 上会用到的字段

来自 `PatternBlueprintEntity`：

- `template`
- `controlledGrammarSlots`
- `openSlots`
- `controlledGrammarSlotList`
- `openSlotList`
- `nid`

这里真正的主干字段是：

#### `template`

字符串模板，是整个渲染顺序的唯一真源。

#### `controlledGrammarSlots`

至少会用到：

- `slotKey`
- `rendersAs`
- `activationFeatureNids`
- `options`

用途：

- 判定 `role == controlled`
- 识别模板里的 render alias
- 回溯原始受控源槽位

#### `openSlots`

至少会用到：

- `slotKey`
- `required`
- `growthPriority`
- `dependsOn`

用途：

- 判定开放槽是必填还是可选
- 生成 growth 序号
- 生成 dependsOn 关系

### 三、推荐使用的详情字段

为了正确显示中文槽位名，建议优先使用已经带详情的列表字段：

#### `controlledGrammarSlotList`

每项建议用到：

- `slotKey`
- `rendersAs`
- `slot?.name`

#### `openSlotList`

每项建议用到：

- `slotKey`
- `slot?.name`
- `slot?.categoryNid`
- `required`
- `growthPriority`
- `dependsOn`
- `dependsOnSlots`

这两个 list 字段的价值是：

- 它们已经把槽位详情展开好了
- Flutter 侧不用强依赖额外的 `slotKeysByNid`、`categoriesByNid` 全局表也能完成大部分 UI

如果列表接口里这两个字段稳定存在，Flutter 实现优先直接吃这两个展开字段，会比 React 那种“额外传 map”更适合当前工程。

### 四、这次明确不用的字段

本提示词对应的组件不消费下面这些实例级数据：

- `sentenceRealizations`
- `sentenceRealizationList`
- `sentence / clause / structure / structureSlot` 相关结构化句子数据
- `root clause`、`child clause`、`parentClauseId`

如果后续要做“代表句实例行”或“外层 chips 组装行”，请新开独立组件 / 实体工厂，不要继续往 `SentenceSlotMapWidget` 里塞。

---

## Flutter 侧建议的数据组装方式

建议在 Flutter 里不要把所有逻辑塞在 `build` 里，而是拆成 3 层：

1. `parseTemplateTokens(pattern)`
2. `buildSlotMapSegments(pattern, lang, ...)`
3. `buildDependEdges(pattern, lang, ...)`

### 1. parseTemplateTokens(pattern)

职责：

- 从 `pattern.template` 切出 token 列表
- literal 和 slot 分开建模

建议 token 结构：

```text
SentenceSlotTemplateToken
  - type: literal / slot
  - text
  - slotKey
  - role
  - growthIndex
  - dependsOn
  - isRenderAlias
  - sourceControlledKeys
```

### 2. buildSlotMapSegments(pattern, lang, ...)

职责：

- 把 token 转成最终 UI 可渲染的 segment

建议 segment 结构：

```text
SentenceSlotMapSegment
  - key
  - slotKey
  - label
  - text
  - title
  - selected
  - showCtrl
  - growthIndex
  - role
  - isLiteral
  - onTapEnabled
```

说明：

- Flutter 不一定非要完全对齐 React 的 segment 结构
- 但语义要与 `PatternTemplateChips` 的蓝图骨架展示一致

### 3. buildDependEdges(pattern, lang, ...)

职责：

- 基于 token 列表中的 slot token
- 把每个 `dependsOn` 展开成边列表

建议 edge 结构：

```text
SentenceSlotDependEdge
  - fromSlotKey
  - toSlotKey
  - fromLabel
  - toLabel
```

这样 UI 层不再关心查名逻辑，只负责渲染。

---

## 槽位展示名怎么组装

建议在 Flutter 里单独做一个方法，例如：

```text
resolveSlotDisplayName(pattern, slotKey, lang)
```

内部逻辑建议如下：

### 优先级 1：先查受控源槽

从 `controlledGrammarSlotList` 或 `controlledGrammarSlots` 中找：

- `slot.slotKey == slotKey`
- 或 `slot.rendersAs == slotKey`

如果命中：

- 优先显示源受控槽自己的 `slot.name` 本地化文本
- 不是直接显示 `rendersAs`

### 优先级 2：查 open slot 详情

从 `openSlotList` 中按 `slotKey` 找：

- `slot?.name` 的本地化文案

### 优先级 3：fallback humanize

如果都没有：

- 去掉 `_marking`
- 按 `_` 切分
- 空格拼接

### 本地化文本读取

本项目里应复用已有语言工具，例如 `LearningLangUtils.getLocalLang(...)` 思路，不要自己散写。

---

## growthIndex 怎么组装

React 是通过 `buildGrowthIndexMap(pattern)` 算的，当前我们虽然没直接展开源码，但从字段和使用方式可以确认：

- growthIndex 主要给开放槽使用
- 来源核心是 `openSlots.growthPriority`
- 最终显示为一个小圆角序号 badge

Flutter 建议：

1. 从 `openSlots` 里筛出有 `growthPriority` 的槽
2. 按 `growthPriority` 升序排序
3. 再映射成连续的 `1 / 2 / 3 / ...`
4. 最终生成 `Map<String, int>`
5. token/segment 通过 `slotKey` 去取对应的 growthIndex

不要直接把原始 `growthPriority` 文案裸显示到 UI 上，React 展示的是“增长序号”，不是数据库原值本身。

---

## UI 填充规则

## 一、整体布局

建议与当前 Flutter 示例保持一致，继续使用：

- 外层横向滚动
- 中间一行 Row / Wrap 风格的 segment 卡片
- 底部一行 dependsOn 关系

整体结构建议：

```text
Column
  - SingleChildScrollView(horizontal)
    - Row(segments)
  - if dependEdges.isNotEmpty
    - SizedBox(height: ...)
    - SingleChildScrollView(horizontal)
      - Row(edges)
```

## 二、每个槽位卡片的显示文案

### 上标签

由 `label` 决定：

- 受控 -> `受控`
- 必填开放槽 -> `必填`
- 可选开放槽 -> `可选`
- 字面量 -> `固定`

如果是受控槽，可以额外在标签右侧显示 `C`

如果有 growthIndex，可以在标签前方显示一个数字 badge

### 主体文本

由 `text` 决定：

- literal 显示字面量文本
- slot 显示槽位展示名

注意：

- 这里展示的是“槽位名称”，不是教学例句里的真实词面
- 所以 `SentenceSlotMapWidget` 复刻的是蓝图骨架行
- 不是 `SentenceSlotExampleWidget` 那种“槽位 -> 实际填入文本”的实例行

## 三、颜色和边框语义

React 语义如下：

- `controlled`：固定琥珀色系高强调
- `required_open`：按 category 映射颜色，实线边框
- `optional_open`：按 category 映射颜色，虚线边框
- `literal`：白字/浅边框，表示固定字面量

Flutter 第一版建议继续沿用现有视觉规则：

- 受控：琥珀色
- 必填开放槽：实线
- 可选开放槽：虚线
- 固定字面量：中性白灰色

### 颜色映射表

请直接把颜色映射做成一份统一 palette，不要散落在各个 UI 分支里硬编码。

React 侧 `slotColor.ts` 当前语义如下，Flutter 复刻时建议保持同一套主色：

#### 固定角色颜色

- `controlled`
  - 主色：`#f59e0b`
  - 语义：统一琥珀色高强调
  - 表现：浅琥珀背景 + 琥珀边框 + 琥珀文字

- `literal`
  - 主色：中性白灰
  - 语义：固定字面量，不属于语义槽位
  - 表现：深底 + 浅色边框 + 白字

#### 开放槽 category 颜色

- `subject_entity`
  - 主色：`#0ea5e9`
  - 常见含义：主语、施事、身份主体

- `object_entity`
  - 主色：`#8b5cf6`
  - 常见含义：宾语、对象实体

- `verb_predicate`
  - 主色：`#f43f5e`
  - 常见含义：动作、谓语核心

- `time_expression`
  - 主色：`#10b981`
  - 常见含义：时间表达

- `place_expression`
  - 主色：`#14b8a6`
  - 常见含义：地点表达

- `reason_expression`
  - 主色：`#f97316`
  - 常见含义：原因表达

- `purpose_expression`
  - 主色：`#65a30d`
  - 常见含义：目的表达

- `manner_expression`
  - 主色：`#d946ef`
  - 常见含义：方式表达

- `clause_content`
  - 主色：`#6366f1`
  - 常见含义：从句内容

- `noun_phrase`
  - 主色：`#06b6d4`
  - 常见含义：名词短语

- `prepositional_phrase`
  - 主色：`#0891b2`
  - 常见含义：介词短语

- `connector`
  - 主色：`#78716c`
  - 常见含义：连接成分、连接词

#### 默认 fallback 颜色

如果某个开放槽的 `categoryNid` 没命中 palette：

- fallback 主色：`#0ea5e9`
- 语义：按默认开放槽展示
- 表现：偏冷青蓝色

### 边框规则

- `controlled`：实线边框
- `required_open`：实线边框
- `optional_open`：虚线边框
- `literal`：实线浅色边框

### Flutter 落地建议

建议封装一个统一方法，例如：

```text
resolveSlotVisual(role, categoryNid)
```

返回统一视觉对象，例如：

```text
bgColor
borderColor
textColor
isDashed
accentColor
```

这样 `SentenceSlotMapWidget`、后续可能的 `SentenceSlotExampleWidget`、详情弹窗里的槽位标签，都能复用同一份颜色规则。

## 四、选中态 / 高亮态

React 规则：

- `selectedSlotKey === slotKey` 时高亮
- `highlightKeys.includes(slotKey)` 时也高亮

Flutter 可以合并为：

```text
isSelected = selectedSlotKey == slotKey || highlightSlotKeys.contains(slotKey)
```

表现方式建议：

- 外层描边加粗
- 或外层高亮 ring / glow

## 五、点击行为

仅槽位卡片支持点击，literal 一般不需要交互。

点击回调：

```text
onSlotTap(slotKey)
```

---

## dependsOn 区域怎么填充

当 `showDependsOn == true` 且存在依赖边时，底部展示。

每条边显示：

```text
[fromLabel] →dependsOn→ [toLabel]
```

建议视觉：

- 左侧普通浅色 tag
- 中间用弱化文字 `→dependsOn→`
- 右侧用带强调色的 tag

这部分可以直接参考 `SentenceSkeletonWidget` 目前已有那行依赖示意 UI。

---

## Flutter 实现时的推荐入参设计

建议不要继续保留当前无数据输入的静态写法，改成真正的数据驱动。

建议组件签名方向：

```text
SentenceSlotMapWidget({
  required PatternBlueprintEntity pattern,
  String? lang,
  String? selectedSlotKey,
  List<String> highlightSlotKeys = const [],
  bool showGrowth = true,
  bool showDependsOn = true,
  void Function(String slotKey)? onSlotTap,
})
```

注意：

- `pattern` 必须是必传
- 不建议只传若干平铺字符串，因为这样会丢失模板驱动关系

---

## 当前 Flutter 工程里建议优先利用的字段

结合 `PatternBlueprintEntity`，建议优先这样用：

### 名称来源

- 先用 `controlledGrammarSlotList[i].slot?.name`
- 再用 `openSlotList[i].slot?.name`
- 再 fallback 到 raw key

### role 判定来源

- `controlledGrammarSlots`
- `openSlots`

### dependsOn 来源

- `openSlots[i].dependsOn`
- 或 `openSlotList[i].dependsOn`

### growth 来源

- `openSlots[i].growthPriority`
- 或 `openSlotList[i].growthPriority`

这样能尽量减少组件外额外传参。

---

## 与当前 Flutter 静态版本的差异

当前 `sentence_slot_map_widget.dart` 里的版本是“演示组件”，问题是：

1. 卡片顺序是手写的，不来自 `template`
2. 文案是写死的，不来自 pattern 数据
3. dependsOn 是写死示例，不来自 `openSlots.dependsOn`
4. 颜色和角色没有通过统一 role/category 规则推导
5. 没有处理 `rendersAs`

真正复刻时，这几个点都要改成数据驱动。

---

## 实现边界和注意事项

### 1. 以 template 为唯一顺序源

不要直接先渲染 `controlledGrammarSlots` 再渲染 `openSlots`，那样顺序会错。

### 2. 不要忽略 rendersAs

这是 React 版本里很关键的一层。模板里的 key 可能是 render alias，不一定是受控槽的真实源键。

### 3. literal 要做空白清理

不是所有字面量 token 都应该显示，空白 token 要过滤掉。

### 4. dependsOn 只来自 slot token

literal 不参与 dependsOn。

### 5. 先做蓝图骨架版，不掺代表句实例逻辑

当前目标对应 React 的 `PatternTemplateChips`，它是“句型模板骨架”。

不要把 `SentenceSlotExampleWidget` 那种真实句面文本填充值混进这次实现里，否则职责会乱。

### 6. 不要误接“外层 chips 组装算法”

`01.pattern&pyramid.md` 里的“组装算法（外层 chips）”服务的是实例句面装配，它依赖 sentence/clause/structureSlots 等运行时数据。

`SentenceSlotMapWidget` 没有这些输入，也不应该为了复刻蓝图骨架去推导这些数据。若出现以下关键词，说明需求已经超出本提示词边界，应拆出新能力：

- `root / children`
- `clause_content`
- `surfaceFromSlotKeys` 对齐真实表层
- `that / so` 剥离
- `缺` 占位
- `余文 / residual`

---

## 可直接给实现同学的执行要求

请在 Flutter 中实现一个数据驱动版 `SentenceSlotMapWidget`，复刻 Web 端 `PatternTemplateChips.tsx` 的核心逻辑，要求如下：

1. 输入必须是 `PatternBlueprintEntity pattern`
2. 渲染顺序必须完全来自 `pattern.template`
3. 先把 template 解析为 literal / slot token
4. 每个 slot token 需要补齐：
   - role
   - growthIndex
   - dependsOn
   - isRenderAlias
   - sourceControlledKeys
5. 再将 token 转成 segment，用统一的卡片 UI 渲染
6. literal 显示“固定”标签和字面量正文
7. slot 显示“受控 / 必填 / 可选”标签，以及解析后的槽位展示名
8. 槽位展示名必须支持 `rendersAs -> 受控源槽` 回溯
9. 可选开放槽使用虚线边框，必填开放槽使用实线边框，受控槽使用固定琥珀色强调
10. 若开启 `showGrowth`，则开放槽按 `growthPriority` 计算并显示增长序号 badge
11. 若开启 `showDependsOn`，则在底部追加依赖边展示行
12. 先保持横向滚动正确，不强求首版做自动缩放
13. 逻辑拆分为“模板解析 / segment 组装 / dependsOn 组装 / UI 渲染”四层，不要把所有逻辑堆进 `build`
14. 明确只实现蓝图骨架展示，不引入 sentence realization / clause assembly / residual coverage 逻辑

---

## 本次复刻建议优先顺序

1. 先完成模板解析和 segment 数据结构
2. 再完成静态 UI 渲染接线
3. 再补 dependsOn
4. 最后再处理选中态 / 点击态 / growth badge

这样最稳，也最容易逐步验证。
