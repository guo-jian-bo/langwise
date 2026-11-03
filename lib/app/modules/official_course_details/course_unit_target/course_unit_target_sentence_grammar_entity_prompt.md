# course_unit_target_sentence_grammar_entity 提示词

请基于以下要求，实现 `/Users/langwise/Desktop/ns/project/langwise/lib/common/entities/course_unit_target_sentence_grammar_entity.dart`，把 `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/official_course_details/course_unit_target/course_unit_target_grammar.json` 转成正式实体类。

本次目标是“先把 JSON 结构正确落成实体”，不要顺手改页面、控制器或接口层，也不要做无关重构。

## 目标文件

1. 实现：
   - `lib/common/entities/course_unit_target_sentence_grammar_entity.dart`
2. 同步补充导出：
   - `lib/common/entities/entities.dart`
3. 新增 unified type 枚举：
   - `lib/common/enum/zhenxie_en_sentence_type.dart`
4. 同步补充导出：
   - `lib/common/enum/enum.dart`

## 顶层 JSON 结构

当前 JSON 顶层结构如下：

```json
{
  "code": 200,
  "data": {
    "unitId": 12813,
    "sentence": [...],
    "groups": [...],
    "grammar": {...}
  }
}
```

但本次实现里，`"code"` 和 `"data"` 这一层不用进实体。

也就是说：

1. `CourseUnitTargetSentenceGrammarEntity` 直接对应 `data` 节点
2. 调用方如果拿到的是完整接口响应，需要先取 `json['data']` 再传入实体

因此实体建议至少拆成以下层级：

1. `CourseUnitTargetSentenceGrammarEntity`
2. `CourseUnitTargetSentenceGrammarSentenceEntity`
3. `CourseUnitTargetSentenceGrammarGroupEntity`
4. `CourseUnitTargetSentenceGrammarGrammarEntity`
5. `CourseUnitTargetSentenceGrammarPointEntity`
6. `CourseUnitTargetSentenceGrammarTargetEntity`

命名可以微调，但必须保持语义稳定，且一眼能看出层级关系。

## 普通字段怎么建

以下字段不用复用现成复杂实体，直接在当前文件内定义轻量实体即可：

### 1. `sentence`

对应 JSON `#L4-L97`，每项字段为：

```json
{
  "unitKnowledgeId": 440338,
  "content": "I love my mum.",
  "contentId": 532252,
  "semanticId": 1149733,
  "patternNid": "preference_entity_love_hate_np"
}
```

这里直接建轻量句子实体：

- `int? unitKnowledgeId`
- `String? content`
- `int? contentId`
- `int? semanticId`
- `String? patternNid`

### 2. `grammar`

对应 JSON `#L17246-L17341`，建议结构：

- `int? outlineId`
- `String? summary`
- `List<CourseUnitTargetSentenceGrammarPointEntity?>? points`

`points` 每项字段：

- `int? pointOrder`
- `String? title`
- `String? description`
- `String? objective`
- `List<CourseUnitTargetSentenceGrammarTargetEntity?>? targets`

`targets` 每项字段：

- `int? uid`
- `int? order`
- `String? status`
- `String? statusLabel`
- `String? assetKind`
- `String? assetLabel`
- `String? assetNid`
- `String? title`
- `int? setCount`

这里先只保留轻量元数据，不要把 `targets` 再额外嵌成复杂 payload。

## 复杂字段处理原则

真正复杂的是 `groups[].payload`。

这里不要自己重写一套大而全的嵌套实体，必须优先复用现有卡片对应实体，因为后续卡片展示就是吃这些模型：

1. `PatternBlueprintItemWidget`
   - 对应实体：`PatternBlueprintEntity`
2. `ZhenxieGrammarPanoramaItemWidget`
   - 对应实体：`ManageGrammarPanoramaEntity`
3. `ZhenxieSentenceForkItemWidget`
   - 对应实体：`SentenceForkEntity`
4. `ZhenxieSentencePairItemWidget`
   - 对应实体：`SentencePairEntity`
5. `ZhenxieSentencePatternCompareCardWidget`
   - 对应实体：`SentencePatternCompareEntity`

## 当前 JSON 已确认的事实

通过当前 `course_unit_target_grammar.json` 实际扫描，以及交接文档
`docs/unit_grammar_frontend_api_handoff_new.md` 已知：

1. unified `type` 的完整枚举范围要先定义好，即使当前 JSON 没全部出现：
   - `EN_SENTENCE_PATTERN`
   - `EN_SENTENCE_PATTERN_PAIR`
   - `EN_SENTENCE_PATTERN_PAIR_FORK`
   - `EN_SENTENCE_PARADIGM`
   - `EN_SENTENCE_GRAMMAR_GRID`
2. 当前 JSON 里实际出现的 `groups[].type` 只有两种：
   - `EN_SENTENCE_PATTERN`
   - `EN_SENTENCE_PATTERN_PAIR`
3. `grammar.points[].targets[].assetKind` 目前只出现三种：
   - `pattern`
   - `pair`
   - `pyramid`
4. 交接文档里已明确 `assetKind -> type` 的统一映射关系：
   - `pattern` -> `EN_SENTENCE_PATTERN`
   - `pyramid` -> `EN_SENTENCE_PATTERN`
   - `pair` -> `EN_SENTENCE_PATTERN_PAIR`
   - `pair_fork` -> `EN_SENTENCE_PATTERN_PAIR_FORK`
   - `paradigm` -> `EN_SENTENCE_PARADIGM`
   - `grid` -> `EN_SENTENCE_GRAMMAR_GRID`
5. 当前文件里没有实际出现 `pair_fork` / `paradigm` / `grid` 的目标项，但实体设计要为这几类复用留好入口。

## `type` enum 要求

请先新增 unified type 枚举文件：

- `lib/common/enum/zhenxie_en_sentence_type.dart`

建议命名：

- `ZhenxieEnSentenceType`

枚举值固定为：

1. `EN_SENTENCE_PATTERN`
2. `EN_SENTENCE_PATTERN_PAIR`
3. `EN_SENTENCE_PATTERN_PAIR_FORK`
4. `EN_SENTENCE_PARADIGM`
5. `EN_SENTENCE_GRAMMAR_GRID`

实现要求：

1. 每个枚举项都保留 `rawValue`
2. 提供 `fromRawValue(String? rawValue)` 解析方法
3. 补到 `lib/common/enum/enum.dart` 导出
4. 后续页面显示不同卡片时，统一依据这个 enum，而不是直接到处写字符串

## `groups[].payload` 的复用映射

请把 `groups[].payload` 设计成“联合承载”结构，不要平铺成一大坨字段。

建议新增一个 payload 包装实体，例如：

- `CourseUnitTargetSentenceGrammarGroupPayloadEntity`

内部保留 5 个可空 typed field：

1. `PatternBlueprintEntity? patternBlueprint`
2. `ManageGrammarPanoramaEntity? grammarPanorama`
3. `SentenceForkEntity? sentenceFork`
4. `SentencePairEntity? sentencePair`
5. `SentencePatternCompareEntity? sentencePatternCompare`

当前 JSON 的解析规则优先按 `groups[].type` 路由，且建议先转成
`ZhenxieEnSentenceType` 再分发：

1. `EN_SENTENCE_PATTERN`
   - 解析到 `patternBlueprint`
2. `EN_SENTENCE_PATTERN_PAIR`
   - 解析到 `sentencePair`
3. `EN_SENTENCE_PATTERN_PAIR_FORK`
   - 解析到 `sentenceFork`
4. `EN_SENTENCE_PARADIGM`
   - 解析到 `sentencePatternCompare`
5. `EN_SENTENCE_GRAMMAR_GRID`
   - 解析到 `grammarPanorama`

## `pattern` 和 `pyramid` 的处理

`PatternBlueprintItemWidget` 注释已经说明它承接的是“句型蓝图 / 金字塔 卡片”，因此：

1. `assetKind == pattern`
   - 对应 unified `type == EN_SENTENCE_PATTERN`
   - 最终复用 `PatternBlueprintEntity`
2. `assetKind == pyramid`
   - 对应 unified `type == EN_SENTENCE_PATTERN`
   - 最终也复用 `PatternBlueprintEntity`
3. `assetKind == pair`
   - 对应 unified `type == EN_SENTENCE_PATTERN_PAIR`
   - 最终复用 `SentencePairEntity`
4. `assetKind == pair_fork`
   - 对应 unified `type == EN_SENTENCE_PATTERN_PAIR_FORK`
   - 最终复用 `SentenceForkEntity`
5. `assetKind == paradigm`
   - 对应 unified `type == EN_SENTENCE_PARADIGM`
   - 最终复用 `SentencePatternCompareEntity`
6. `assetKind == grid`
   - 对应 unified `type == EN_SENTENCE_GRAMMAR_GRID`
   - 最终复用 `ManageGrammarPanoramaEntity`

不要为了 `pyramid` 再新建一套独立 payload 实体。

原因是当前 JSON 中 `pyramid` 目标对应的 `assetNid` 仍然是同一个 pattern blueprint nid，且 payload 结构本质上仍是蓝图实体，卡片也复用同一个 widget。

## `groups` 自身字段怎么建

`groups[]` 除了 `payload` 之外，本身还有这些字段，仍要保留：

- `String? type`
- `String? nid`
- `List<LanguageText?>? name`
- `List<LanguageText?>? description`
- `CourseUnitTargetSentenceGrammarGroupPayloadEntity? payload`

注意：

1. `groups[].name/description` 与 `payload.name/description` 可能重复，但不要省略，也不要从 payload 反推。
2. `nid` 和 `payload.nid` 也不要强行合并。
3. 建议额外保留：
   - `ZhenxieEnSentenceType? typeEnum`

## 推荐的 payload 包装写法

建议为 payload 包装实体补一组便于使用的只读 getter，例如：

1. `PatternBlueprintEntity? get patternBlueprintData`
2. `SentencePairEntity? get sentencePairData`
3. `ManageGrammarPanoramaEntity? get grammarPanoramaData`
4. `SentenceForkEntity? get sentenceForkData`
5. `SentencePatternCompareEntity? get sentencePatternCompareData`

也可以补一个统一 getter：

1. `Object? get displayEntity`

但如果会让类型变差，就不要强上。

核心原则只有一个：**解析时明确，使用时低心智负担。**

## `toJson` 处理要求

`payload.toJson()` 不要输出五个并列字段，而是要恢复成原始接口需要的单个 JSON 对象：

1. 如果 `patternBlueprint != null`
   - 返回 `patternBlueprint!.toJson()`
2. 如果 `sentencePair != null`
   - 返回 `sentencePair!.toJson()`
3. 如果 `grammarPanorama != null`
   - 返回 `grammarPanorama!.toJson()`
4. 如果 `sentenceFork != null`
   - 返回 `sentenceFork!.toJson()`
5. 如果 `sentencePatternCompare != null`
   - 返回 `sentencePatternCompare!.toJson()`
6. 如果都为空
   - 返回 `null`

不要把 payload 包成：

```json
{
  "patternBlueprint": {...},
  "sentencePair": null
}
```

这会破坏原始协议结构。

## 代码风格要求

严格跟随项目现有实体风格：

1. 文件顶部直接 `import 'entities.dart';`
2. 使用现有 `LanguageText`
3. 复用已有实体：
   - `PatternBlueprintEntity`
   - `ManageGrammarPanoramaEntity`
   - `SentenceForkEntity`
   - `SentencePairEntity`
   - `SentencePatternCompareEntity`
4. 注释要补齐，尤其是：
   - 顶层实体
   - `groups`
   - `payload` 包装实体
   - `grammar` / `points` / `targets`
5. 不要引入无关抽象，不要额外拆多个文件
6. 不要全文件格式化其他无关文件

## 实现时的具体注意点

1. `CourseUnitTargetSentenceGrammarEntity` 不要保留 `code`
2. `CourseUnitTargetSentenceGrammarEntity` 不要再包一层 `data`
3. `unitId` 用 `int?`
4. `order` 在 `grammar.points.targets[]` 里是整数，用 `int?`
5. `setCount` 用 `int?`
6. `groups[].type` 建议同时保留：
   - `String? type`
   - `ZhenxieEnSentenceType? typeEnum`
7. `groups[].payload` 的解析优先依赖 `typeEnum`，不要靠字段猜测
8. 如果遇到未知 `type`
   - 不要崩
   - 可以先全部留空，或兜底按 `patternBlueprint` / `sentencePair` 之外不解析
   - 但不要擅自把未知类型塞进错误实体

## 本次实现范围

只做以下事情：

1. 把 `course_unit_target_grammar.json` 建成实体
2. 让复杂 `payload` 复用现有卡片实体
3. 把新实体补到 `entities.dart` 导出

不要做以下事情：

1. 不改页面
2. 不改 controller
3. 不补接口调用
4. 不顺手重构其他 entity 文件

## 验收标准

完成后至少满足：

1. `CourseUnitTargetSentenceGrammarEntity.fromJson(...)` 直接解析 `data` 节点
2. `sentence` 能拿到轻量句子列表
3. `grammar.points.targets` 能拿到轻量目标列表
4. `groups` 能拿到分组列表
5. `groups[i].typeEnum` 能正确解析 unified type
6. `groups[i].payload` 会按类型复用现有卡片实体
   - `EN_SENTENCE_PATTERN` 能正确转成 `PatternBlueprintEntity`
   - `EN_SENTENCE_PATTERN_PAIR` 能正确转成 `SentencePairEntity`
7. `pattern` 与 `pyramid` 的语义最终都能落到 `PatternBlueprintEntity` 体系
8. 后续如果接口返回：
   - `EN_SENTENCE_PATTERN_PAIR_FORK`
   - `EN_SENTENCE_PARADIGM`
   - `EN_SENTENCE_GRAMMAR_GRID`
   也有明确的 enum 和 payload 承接入口
9. `entities.dart` 与 `enum.dart` 都已补充导出

## 额外提醒

当前 JSON 的 `grammar.points.targets[]` 只是“教学目标元数据”，不是完整 payload 本体；真正的大对象在 `groups[]` 里。实现时不要把两者混成同一层结构。
