# PatternSlotDetailsDialog 提示词

## 目标

请参考 Web 端 `ui_ux/src/pages/zhenxie/sentence/components/SlotInspectorDrawer.tsx`，为 Flutter 端设计一个“句型槽位详情弹窗”。

这次**先不要写代码**，只输出实现该弹窗时必须遵守的数据模型、信息架构、字段要求和实现边界，供后续开发直接照着填充。

这个弹窗的目标不是简单显示一个 `slotKey`，而是尽量对齐 Web 端的两类详情能力：

1. 蓝图槽位详情 `blueprint`
2. 代表句实例槽位详情 `realization`

但当前 Flutter 里你首先要面对的是：

- `SentenceSkeletonWidget` 点击的是“蓝图骨架槽位”
- 它目前回传的数据非常轻，只够做高亮，不够直接做完整详情弹窗

所以本提示词的重点是：

1. 先判断当前 Flutter 点击回调拿到的数据是否足够
2. 明确哪些字段必须补
3. 补充的数据必须是**完整结构**，不能为了快退化成纯字符串

---

## 参考来源

参考实现：

- `ui_ux/src/pages/zhenxie/sentence/components/SlotInspectorDrawer.tsx`

当前 Flutter 入口：

- `lib/common/widgets/zhenxie_widgets/sentence_skeleton_widget.dart`
- `lib/common/widgets/zhenxie_widgets/sentence_slot_map_widget.dart`
- `lib/common/widgets/zhenxie_widgets/sentence_slot_map_model.dart`
- `lib/common/entities/pattern_blueprint_entity.dart`

---

## 当前 Flutter 点击链路现状

### 1. 当前点击入口

`SentenceSkeletonWidget` 里现在这样处理点击：

```dart
onSlotTap: (item) {
  onTap?.call();
}
```

这意味着：

1. `SentenceSlotMapWidget` 实际已经拿到了 `SentenceSlotMapItemEntity item`
2. 但 `SentenceSkeletonWidget` 把这个 `item` 丢掉了
3. 页面层最终只能知道“点了”，不知道“点了哪个槽、这个槽的细节是什么”

### 2. 当前 `SentenceSlotMapItemEntity` 能提供什么

它目前只有这些骨架展示字段：

- `key`
- `slotKey`
- `label`
- `text`
- `title`
- `role`
- `categoryNid`
- `showCtrl`
- `growthIndex`
- `isRenderAlias`
- `sourceControlledKeys`
- `dependsOnSlotKeys`

这些字段适合“骨架行展示”和“简单选中态”，但**不够支撑 Web 端详情弹窗**。

---

## 结论：当前点击返回的数据不能满足完整弹窗

### 一、勉强能满足的内容

当前 `SentenceSlotMapItemEntity` 只能勉强支持以下弹窗头部信息：

- 当前点击的是哪个 `slotKey`
- 当前槽位在骨架行上的展示文本 `text`
- 当前槽位角色 `role`
- 当前槽位的 `growthIndex`
- 当前槽位依赖了哪些 `dependsOnSlotKeys`
- 当前槽位的分类 id `categoryNid`

### 二、明确不能满足的内容

当前点击返回数据**无法直接满足**下面这些 Web 弹窗内容：

1. 槽位名称的完整多语言信息
2. 槽位描述 `description`
3. 类别名称与类别描述
4. 开放槽 `dependsOn` 对应的完整槽位对象
5. 受控槽对照卡中的完整受控变体信息
6. `activationFeatureNids` 对应的人类可读名称与描述
7. 受控槽 `options` 的结构化来源说明
8. 代表句实例模式下的：
   - `surfaceText`
   - 实例说明 `descriptions`
   - `grammarValue`
   - `semanticIds` 对应的完整语义卡片数据
   - 图片 / 音频 / 中英释义

换句话说，当前的点击项只是一个“渲染 segment”，不是一个“详情实体”。

---

## 一个关键判断

`PatternBlueprintEntity` 顶层这两个字段已经是完整结构，不需要降级，也不需要再改成字符串：

```dart
List<LanguageText?>? name;
List<LanguageText?>? description;
```

也就是说：

- `pattern_blueprint_entity.dart#L6-7` 这两个字段**现在是对的**
- 后续弹窗补数据时，应该继续沿用这种 `List<LanguageText?>?` 结构
- 不能为了弹窗方便改成 `String`

真正不够完整的，不是这里，而是下面这些仍然过轻的字段。

---

## 哪些现有字段过轻，必须补成完整结构

下面这些字段如果要支撑详情弹窗，不建议只保留原始字符串或 id。

### 1. `PatternBlueprintControlledGrammarSlotEntity`

当前轻量字段：

- `slotKey`
- `rendersAs`
- `options: List<String?>?`
- `activationFeatureNids: List<String?>?`

问题：

- `options` 只是字符串数组，看不到每个选项的语言、说明、排序、别名
- `activationFeatureNids` 只有 id，没有 feature 的名称和说明
- `slotKey` 对应的槽位详情也不在这个结构里

因此详情弹窗场景下，优先使用或补齐为：

- `PatternBlueprintControlledGrammarSlotListItemEntity`
- 并确保里面的 `slot`、`activationFeatures` 都存在

如果后端或本地数据还不够，建议补成完整结构，而不是继续传裸字符串。

### 2. `PatternBlueprintOpenSlotEntity`

当前轻量字段：

- `slotKey`
- `required`
- `grammarControlling`
- `growthPriority`
- `dependsOn: List<String?>?`

问题：

- `dependsOn` 只有 key，没有被依赖槽位的名称与说明
- 当前槽位本身也没有附带 `slot` 详情对象

因此详情弹窗场景下，优先使用或补齐为：

- `PatternBlueprintOpenSlotListItemEntity`

并确保：

- `slot` 存在
- `dependsOnSlots` 存在

### 3. `PatternBlueprintSentenceRealizationEntity`

当前字段过轻：

- `sentenceId`
- `order`

这只能表示“关联了哪条句子”，完全不能支撑实例槽位弹窗。

如果后续 Flutter 也要做 `realization` 模式，不能只靠这个实体，必须依赖已展开的详情结构。

### 4. `PatternBlueprintSentenceBriefEntity`

当前有几个字段还是纯字符串：

- `content: String?`
- `definition: String?`
- `patternTemplate: String?`

对于简单列表展示这没问题，但如果要作为弹窗长期主数据源，建议按下面原则处理：

1. `content` 和 `definition` 若服务端本来就是单语纯文本，可以暂时保留字符串
2. 但若后续需要多语言、释义切换、解释来源，应该升级为完整结构，而不是继续堆字符串
3. `patternTemplate` 是协议表达式，本质是模板源码，可以保留字符串，不必强行对象化

也就是说，不是所有字符串都必须改对象，但**用于展示文案的业务字段**，只要未来有多语言/说明扩展可能，就不应该锁死成单字符串。

### 5. `PatternBlueprintSentenceBriefSegmentEntity`

当前字段：

- `slotKey`
- `slot`
- `required`
- `grammarControlling`
- `growthPriority`
- `dependsOn`
- `dependsOnSlots`
- `text`
- `renderSlotKey`
- `sourceSlotKey`
- `sourceSlot`
- `slotUid`
- `semanticIds`
- `literal`

这个结构已经比 `SentenceSlotMapItemEntity` 丰富很多，但仍然不足以完整对齐 Web 的实例弹窗，因为还缺：

- `descriptions`
- `grammarValue`
- `contentType`
- `semantics` 完整对象

所以如果 Flutter 后续要实现实例槽位弹窗，应该在这个实体基础上继续补，而不是把实例弹窗建立在 `SentenceSlotMapItemEntity` 上。

---

## 结合当前详情 JSON 的新结论

基于：

- `manage_pattern_blueprint_details.json`
- `SentenceSlotMapEntity.fromPatternBlueprint(...)`
- `SentenceSkeletonWidget` 是公用组件

新的收口方向应当调整为：

**不要把详情查找逻辑放进 `PatternSlotDetailsDialog`，也不要让页面层在点击后再临时拼一大堆数据。**

更合适的做法是：

1. 在 `SentenceSlotMapEntity.fromPatternBlueprint(...)` 阶段，把弹窗所需数据就近组装好
2. 把这些详情数据挂到 `SentenceSlotMapItemEntity` 上
3. `SentenceSlotMapWidget` 继续只负责渲染
4. `SentenceSkeletonWidget` 点击时把当前 `item` 往外传
5. 弹窗只消费 `item` 上已经准备好的详情数据

这样做的好处：

- `SentenceSkeletonWidget` 继续保持公用
- 其他页面复用 `SentenceSlotMapWidget` 时不需要感知弹窗逻辑
- 弹窗不会承担查表、兜底、协议纠偏
- 详情页 / 列表页如果都用 `fromPatternBlueprint`，拿到的是同一套可点击数据模型

---

## 当前详情 JSON 能支持到什么程度

### 一、蓝图槽位弹窗：大部分主内容可以支持

当前详情 JSON 已经包含：

- `controlledGrammarSlotList`
- `openSlotList`
- `activationFeatures`
- `dependsOnSlots`
- `slot.name`
- `slot.description`

因此蓝图弹窗里的这些内容，原则上都可以在 `fromPatternBlueprint(...)` 阶段直接灌进 `items`：

- 槽位显示名
- 槽位说明
- 角色
- growthIndex
- dependsOn 槽位对象
- 当前槽位是否为 render alias
- 当前槽位对应的受控变体列表
- 受控变体里的激活特征

### 二、蓝图槽位弹窗：仍有两个明显缺口

#### 1. 类别对象缺失

当前详情 JSON 只有：

- `slot.categoryNid`

但没有和 Web `slotCategoriesByNid` 对应的完整类别对象，因此暂时缺：

- 类别名称
- 类别描述

也就是说，如果 Flutter 要完全对齐 Web 弹窗里的：

- `类别 · xxx`
- 类别说明

还需要额外补充类别详情来源。不能只靠这份详情 JSON。

#### 2. 受控 options 仍然是字符串数组

当前：

- `options: List<String?>?`

足够先展示选项文本，但还不足以承载：

- 多语言 label
- option 说明
- 排序 / 别名 / 扩展属性

所以如果只是当前这版弹窗，可以先显示字符串选项；
但从模型设计上，最好预留完整 option 结构。

### 三、实例槽位弹窗：当前详情 JSON 还不够

`sentenceRealizationList.segmentList` 当前能提供：

- `slot`
- `sourceSlot`
- `text`
- `renderSlotKey`
- `sourceSlotKey`
- `slotUid`
- `semanticIds`

但仍然缺 Web 实例弹窗所使用的关键字段：

- `descriptions`
- `grammarValue`
- `contentType`
- `semantics` 完整对象

所以目前这份详情 JSON：

1. 足够支撑“蓝图槽位弹窗”的主内容
2. 不足以完整支撑“例句实例弹窗”

---

## 本次弹窗建议的输入模型

本次应该把“弹窗可消费的数据”收口到 `SentenceSlotMapItemEntity`，而不是新开一层页面专用组装逻辑。

推荐方式不是把所有字段都平铺到 item 顶层，而是在 item 上增加一个可选详情对象，例如：

```dart
class SentenceSlotMapItemEntity {
  ...
  final SentenceSlotMapItemDetailsEntity? details;
}
```

这样可以同时满足两个目标：

1. `SentenceSlotMapWidget` 仍然只关心渲染字段
2. 点击弹窗时，`item.details` 足够直接填充弹窗

推荐结构：

```dart
class SentenceSlotMapItemDetailsEntity {
  final String? mode;
  final SentenceSlotMapBlueprintDetailsEntity? blueprint;
  final SentenceSlotMapRealizationDetailsEntity? realization;
}
```

当前阶段如果只做蓝图槽位弹窗，可以只填 `blueprint`，`realization` 留空。

如果后续补到了类别详情来源，建议类别结构至少统一成：

```dart
class SentenceSlotMapCategoryDetailsEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
}
```

---

## 蓝图模式必须具备的完整数据

这是对齐 Web `BlueprintBody` 的最小完整数据集。

### 推荐实体：`SentenceSlotMapBlueprintDetailsEntity`

```dart
class SentenceSlotMapBlueprintDetailsEntity {
  String? slotKey;
  PatternBlueprintNamedInfoEntity? slot;
  String? displayName;
  String? role;
  int? growthIndex;
  bool? isRenderAlias;
  List<String?>? sourceControlledKeys;
  List<PatternBlueprintNamedInfoEntity?>? sourceControlledSlots;
  List<PatternBlueprintNamedInfoEntity?>? dependsOnSlots;
  PatternBlueprintOpenSlotListItemEntity? openSlot;
  List<SentenceSlotMapControlledVariantEntity?>? controlledVariants;
  SentenceSlotMapCategoryDetailsEntity? category;
}
```

### 说明

#### 1. `slot`

必须是完整对象，不要只传 `slotKey`。

至少应包含：

- `nid`
- `name`
- `description`
- `categoryNid`

#### 2. `category`

设计上应该是完整对象，不要只传 `categoryNid`。

至少应包含：

- `nid`
- `name`
- `description`

但是要注意：

- 当前 `manage_pattern_blueprint_details.json` **并没有这个对象**
- 所以这里应该是可选字段
- 若当前拿不到，先允许为空，不能在弹窗里临时硬编码
- 后续补齐类别数据源后，再在 `fromPatternBlueprint(...)` 阶段灌进 item.details

#### 3. `dependsOnSlots`

不要只保留 `List<String?>? dependsOn`。

弹窗里展示“依赖 xxx”时，需要被依赖槽位的：

- 名称
- 描述
- 可能的类别

所以这里应该传完整对象列表。

#### 4. `controlledVariants`

如果当前槽位属于受控槽，弹窗需要展示“受控对照卡”。

这部分不能只传 `slotKey + options + activationFeatureNids`，建议单独补成完整对象：

```dart
class SentenceSlotMapControlledVariantEntity {
  String? slotKey;
  String? rendersAs;
  PatternBlueprintNamedInfoEntity? slot;
  List<PatternBlueprintNamedInfoEntity?>? activationFeatures;
  List<SentenceSlotMapControlledOptionEntity?>? options;
}
```

其中 `options` 不要继续只用 `List<String?>?`，建议至少升级为：

```dart
class SentenceSlotMapControlledOptionEntity {
  String? value;
  List<LanguageText?>? label;
  List<LanguageText?>? description;
  int? order;
}
```

当前接口只返回字符串数组时，可先在 `fromPatternBlueprint(...)` 中做一次本地包装：

- `value = 原字符串`
- `label = null`
- `description = null`
- `order = 原顺序`

这样弹窗仍然可以直接消费结构化数据，但不会把协议锁死成字符串数组。

---

## 实例模式必须具备的完整数据

这是对齐 Web `RealizationBody` 的最小完整数据集。

如果当前阶段只做蓝图槽位弹窗，可以先不实现 UI，但数据结构要提前想清楚。

### 推荐实体：`SentenceSlotMapRealizationDetailsEntity`

```dart
class SentenceSlotMapRealizationDetailsEntity {
  int? sentenceId;
  int? slotUid;
  String? slotKey;
  String? renderSlotKey;
  String? sourceSlotKey;
  PatternBlueprintNamedInfoEntity? slot;
  PatternBlueprintNamedInfoEntity? sourceSlot;
  SentenceSlotMapCategoryDetailsEntity? category;
  String? surfaceText;
  String? grammarValue;
  String? contentType;
  List<LanguageText?>? descriptions;
  List<int?>? semanticIds;
  List<SentenceSlotMapSemanticBriefEntity?>? semantics;
  bool? required;
  bool? grammarControlling;
  int? growthPriority;
  List<PatternBlueprintNamedInfoEntity?>? dependsOnSlots;
}
```

### 说明

#### 1. `surfaceText`

这是实例弹窗头部的大字，不等于蓝图槽位名。

#### 2. `descriptions`

必须用 `List<LanguageText?>?`，不要退化成一个 `String description`。

Web 里实例说明本身就有主副语言切换逻辑，Flutter 也应该保留这个扩展能力。

#### 3. `semantics`

不要只传 `semanticIds`。

如果弹窗要展示：

- 图片
- lemma
- 中英文解释
- 音频入口

那就必须补完整语义摘要对象。

建议定义：

```dart
class SentenceSlotMapSemanticBriefEntity {
  int? semanticId;
  String? lemma;
  String? image;
  String? audio;
  List<LanguageText?>? explanations;
}
```

如果未来需要更强表达，可以继续扩展，但不能只靠 id。

---

## 当前工程里建议直接复用的完整结构

下面这些结构已经是“完整对象”思路，优先复用，不要重新降级：

1. `LanguageText`
2. `PatternBlueprintNamedInfoEntity`
3. `PatternBlueprintControlledGrammarSlotListItemEntity`
4. `PatternBlueprintOpenSlotListItemEntity`

尤其是：

- `PatternBlueprintEntity.name`
- `PatternBlueprintEntity.description`
- `PatternBlueprintNamedInfoEntity.name`
- `PatternBlueprintNamedInfoEntity.description`

这些都应该继续保持多语言数组。

---

## 当前工程里不建议直接拿来当弹窗主数据的结构

### 1. `SentenceSlotMapItemEntity`

裸的 `SentenceSlotMapItemEntity` 仍然只是“渲染模型”。

适合：

- 骨架行展示
- 选中态
- 点击定位

不适合：

- 不带详情扩展时直接驱动弹窗

但如果按本提示词新增 `details` 字段，并由 `fromPatternBlueprint(...)` 负责填充，那么：

- `item` 可以继续承担渲染职责
- `item.details` 可以承担弹窗数据职责

也就是说，不建议“页面层再单独组装另一套详情模型”，而是建议把详情能力收口在 item 内部。

### 2. `PatternBlueprintControlledGrammarSlotEntity`

它更像“协议轻量版”。

适合：

- 基础算法
- 受控判定

不适合直接做详情卡。

### 3. `PatternBlueprintOpenSlotEntity`

它也更像“协议轻量版”。

适合：

- required / growth / dependsOn 的基础判定

不适合直接做详情卡。

---

## 推荐的页面组装策略

页面层点击骨架槽位时，不应该再临时查数。

推荐的真正组装位置是：

1. `SentenceSlotMapEntity.fromPatternBlueprint(pattern)`
2. `SentenceSlotMapUtils._buildItems(...)`

也就是在生成 `items` 时，就把详情数据补好。

建议流程：

1. 解析模板 token
2. 生成基础渲染 item
3. 同时根据当前 token 的 `slotKey`：
   - 去 `openSlotList` 找开放槽详情
   - 去 `controlledGrammarSlotList` 找受控详情
   - 回填 `slot`
   - 回填 `dependsOnSlots`
   - 回填 `controlledVariants`
   - 回填可选 `category`
4. 把这些信息打包进 `item.details`
5. `SentenceSlotMapWidget` 点击时原样回传 `item`
6. `SentenceSkeletonWidget` 不要吞掉 `item`
7. 弹窗只读取 `item.details`

注意：

- 页面层负责打开弹窗
- `SentenceSlotMapEntity` 负责准备数据
- 弹窗只负责展示

这更符合你现在的约束：

- `SentenceSkeletonWidget` 是公用组件
- `PatternSlotDetailsDialog` 不承接业务逻辑
- `items` 自身就能满足弹窗内容填充

---

## 弹窗信息架构建议

参考 Web `SlotInspectorDrawer.tsx`，蓝图模式建议分成下面几块：

### 1. 头部

- 模式标题：蓝图槽位 / 例句实例
- 槽位显示名
- 管理 id（如需要）
- 类别名
- 实例模式下的 surfaceText

### 2. 标签区

- 角色：受控 / 必填 / 可选
- 生长序号
- 依赖标签
- 实例模式下的 grammarValue

### 3. 主体区

#### 蓝图模式

- 若是受控槽：
  - 显示受控对照卡
  - 每个卡片展示：
    - 槽位名
    - 激活特征
    - 描述
    - options
- 若是开放槽：
  - 展示当前槽位描述
  - 展示类别说明

#### 实例模式

- 实例说明
- 语义卡片列表
- 图片 / 播放入口 / 中英释义

---

## 非目标

这份提示词不要求现在就实现：

1. 弹窗 UI 代码
2. 动画
3. 音频播放逻辑
4. 真实语义接口请求
5. 页面跳转

它只要求把“实现前必须明确的数据结构和边界”定义清楚。

---

## 给后续实现者的执行要求

1. `PatternSlotDetailsDialog` 内不能承担查找、映射、兜底逻辑
2. 不能把多语言字段降级成 `String`
3. 不能只传 id，再在弹窗内部临时猜名称
4. `SentenceSkeletonWidget` 要继续保持公用，不能因为详情页弹窗把组件写死成页面私有逻辑
5. 弹窗所需数据应在 `SentenceSlotMapEntity.items` 上准备完成，推荐挂在 `item.details`
6. 若后端只有轻量字段，Flutter 本地组装时也要先补成完整对象，再交给 `item.details`
7. 当前详情 JSON 不包含类别完整对象，因此 `category` 必须允许为空，不能伪造
8. 当前详情 JSON 不足以完整支撑实例弹窗，因此不要把“蓝图弹窗可做”误判成“实例弹窗也可直接做”

---

## 本次最核心的结论

一句话总结：

当前 `sentence_skeleton_widget.dart` 点击返回的数据**本来不够**直接支撑 `SlotInspectorDrawer.tsx` 级别的详情弹窗，但这次更合适的方向不是新开页面层组装逻辑，而是把详情能力前置收口到 `SentenceSlotMapEntity.items`。

正确的补法是：

1. 保留 `LanguageText` 这类完整多语言结构
2. 优先使用 `...ListItemEntity` 这类已展开对象
3. 在 `SentenceSlotMapItemEntity` 上增加可选详情结构 `details`
4. 在 `SentenceSlotMapEntity.fromPatternBlueprint(...)` 阶段把蓝图详情灌进 `items`
5. 把字符串数组型字段升级成能承载名称、说明、排序的完整对象
6. 明确认知当前详情 JSON 只够蓝图弹窗主内容，不够完整实例弹窗和类别说明

尤其是：

- `name`
- `description`
- `activationFeatures`
- `dependsOnSlots`
- `semantics`
- `options`

这些都不应该在详情弹窗场景下继续停留在“只有字符串 / 只有 id”的层级。
