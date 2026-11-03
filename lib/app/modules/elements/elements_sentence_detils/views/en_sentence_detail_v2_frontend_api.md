# `/en/sentence/detail/v2` 前端 API 交接文档

## 1. 接口概览

### 1.1 请求地址

- `GET /en/sentence/detail/v2`

### 1.2 鉴权

- 需要登录态
- 走 `@Authenticate`
- 需要 `@TeamInfo TeamContext`

### 1.3 入参

| 参数 | 类型 | 必填 | 默认值 | 说明 |
| --- | --- | --- | --- | --- |
| `contentId` | `Long` | 是 | - | 句子主键，对应 `en_sentences.uid` |
| `module` | `String` | 否 | `PRONUNCIATION_MEANING` | 保留旧版卡牌模块语义，仅表示当前选中的旧模块，不裁剪返回内容 |
| `layer` | `String` | 否 | `chunks` | 新版四宫格默认分析层，仅表示页面默认落点，不裁剪返回内容 |

### 1.4 `module` 可选值

- `PRONUNCIATION_MEANING`
- `CORE_COMPONENTS`
- `VIEW_LEVEL`
- `MEMORIZE_SENTENCE`

### 1.5 `layer` 可选值

- `chunks`
- `svoca`
- `syntax`
- `relations`

### 1.6 请求示例

```http
GET /en/sentence/detail/v2?contentId=571476&module=PRONUNCIATION_MEANING&layer=chunks
```

---

## 2. 返回结构总览

接口外层仍然是统一的 `HttpResult<T>`，其中 `data` 部分类型为：

```java
HttpResult<EnSentenceDictionaryDetailDTO>
```

`data` 顶层结构：

```json
{
  "contentId": 571476,
  "contentType": "EN_SENTENCE",
  "content": "The mentor with whom I often speak is patient.",
  "definition": "我经常与之交谈的导师很有耐心。",
  "difficulty": 3,
  "module": "PRONUNCIATION_MEANING",
  "layer": "chunks",
  "media": {},
  "study": {},
  "legacy": {},
  "structure": {},
  "analysisEntries": [],
  "analysisData": {}
}
```

---

## 3. 顶层字段说明

| 字段 | 类型 | 说明 | 数据来源 | `ui_demo` 使用位置 |
| --- | --- | --- | --- | --- |
| `contentId` | `Long` | 句子主键 | `en_sentences.uid` | 页面路由、跳转分析子页时复用 |
| `contentType` | `String` | 固定 `EN_SENTENCE` | 后端常量 | 一般不直接展示，供埋点/兼容逻辑使用 |
| `content` | `String` | 句子原文 | `en_sentences.content` | 详情卡片主句文本 |
| `definition` | `String` | 中文释义 | `en_sentences.definition` | 详情卡片副文案 |
| `difficulty` | `Integer` | 难度最小值 | `en_sentences.difficulty.min` | 当前 demo 未直接使用，可做角标或调试信息 |
| `module` | `String` | 当前旧卡牌模块 | 请求参数，后端兜底默认值 | 新 demo 未直接展示，保留旧卡牌能力 |
| `layer` | `String` | 当前四宫格默认层 | 请求参数，后端兜底默认值 `chunks` | 四宫格默认高亮、子页默认入口 |
| `media` | `MediaDTO` | 图片、视频、发音 | 复用旧版句子详情媒体装配 | 上半区媒体区 |
| `study` | `StudyDTO` | 学习状态与权益 | `study-app` | 星级、进度、权益态 |
| `legacy` | `LegacyDTO` | 旧版模块与子知识点 | 旧版句子详情逻辑 | 与新 demo 无直接冲突，兼容旧能力 |
| `structure` | `StructureDTO` | 详情上半区结构信息 | `en_sentence_structures` 体系 + pattern 装配 | 芯片、蓝图、槽位弹窗 |
| `analysisEntries` | `List<ScriptLearnItemDTO>` | 四宫格入口配置 | 后端文案 + 图标色板配置 + 状态判断 | 四宫格卡片 |
| `analysisData` | `AnalysisDataDTO` | 四宫格详情实际数据 | `en_sentence_structures` 体系 | 四个分析详情页 |

---

## 4. `ui_demo` 对应关系

## 4.1 顶部句型标签

`ui_demo` 当前展示：

- `complex · 复杂句`
- `declarative · 陈述句`

前端直接使用：

- `structure.basicType`
- `structure.functionalType`

颜色建议复用已有配置接口：

- `GET /language/config/color/list`
- `basicLevels` 对应 `structure.basicType.nid`
- `functionalLevels` 对应 `structure.functionalType.nid`

这些基础字段对应关系如下：

| 字段 | 说明 | 来源表 |
| --- | --- | --- |
| `structure.basicType.nid` | 如 `complex` | `en_sentence_structures.basicTypeNid -> en_sentence_basic_types` |
| `structure.basicType.name` | 如 `复杂句` 的多语言名称 | `en_sentence_basic_types.name` |
| `structure.functionalType.nid` | 如 `declarative` | `en_sentence_structures.functionalTypeNid -> en_sentence_functional_types` |
| `structure.functionalType.name` | 如 `陈述句` 的多语言名称 | `en_sentence_functional_types.name` |

## 4.2 顶部句子文本与释义

`ui_demo` 当前展示：

- 大号句子原文
- 小号中文释义

直接使用：

| UI | 字段 |
| --- | --- |
| 句子原文 | `content` |
| 中文释义 | `definition` |

数据来源：

- `content` -> `en_sentences.content`
- `definition` -> `en_sentences.definition`

## 4.3 蓝图标题与作用域

截图中这两个信息：

- `用介词加 whom 更正式地补充说明人`
- `跨子句组合`

当前接口不再单独返回 `blueprintTags`，前端直接读取原始字段：

| UI | 字段 | 来源 |
| --- | --- | --- |
| 左侧蓝图标题标签 | `structure.blueprint.patternName` | `en_sentence_patterns.name` |
| 右侧作用域标签 | `structure.blueprint.blueprintScopeName` | 后端基于 `blueprintScope` 转成多语言标签 |
| 作用域逻辑值 | `structure.blueprint.blueprintScope` | `en_sentence_patterns.blueprintScope` |

作用域说明：

- `sentence`：跨子句组合
- `clause`：子句内组合

## 4.4 蓝图对齐行

`ui_demo` 的 `SentenceBlueprintAlign` 组件，核心需要的是：

- 句型 pattern 信息
- `segmentList`
- 槽位名称
- 槽位颜色
- 槽位描述
- 是否有可展开子结构

对应字段：

- `structure.blueprint`

核心字段如下：

| 字段 | 类型 | 说明 | 来源 |
| --- | --- | --- | --- |
| `sentenceId` | `Long` | 当前句子主键 | `en_sentences.uid` |
| `content` | `String` | 整句原文 | `en_sentences.content` |
| `definition` | `String` | 整句释义 | `en_sentences.definition` |
| `patternNid` | `String` | 命中的蓝图主键 | `en_sentence_structures.patternNid`，必要时回退 clause pattern |
| `patternTemplate` | `String` | 蓝图模板字符串 | `en_sentence_patterns.template` |
| `patternName` | `List<LanguageText>` | 蓝图标题多语言文案 | `en_sentence_patterns.name` |
| `patternDescription` | `List<LanguageText>` | 蓝图说明文案 | `en_sentence_patterns.description` |
| `blueprintScope` | `String` | 逻辑作用域，`sentence/clause` | `en_sentence_patterns.blueprintScope` |
| `blueprintScopeName` | `List<LanguageText>` | 展示用作用域标签 | 后端映射 |
| `segmentList` | `List<SentencePatternStructSlotDTO>` | 蓝图最终展示片段列表 | 公共结构装配服务生成 |

### 4.4.1 `segmentList` 字段说明

每个 `segment` 都是蓝图上的一个展示片段，既可能是真实 slot，也可能是模板字面量。

| 字段 | 类型 | 说明 | 前端用途 |
| --- | --- | --- | --- |
| `text` | `String` | 当前片段表层文本 | 直接显示在蓝图句行上 |
| `slotKey` | `String` | 模板槽位键 | 做槽位识别 |
| `slot` | `EnSentenceCategorySimpleNidDTO` | 槽位词表摘要 | 展示槽位名、描述、颜色 |
| `slot.name` | `List<LanguageText>` | 槽位名多语言文案 | 弹窗标题、槽位标签 |
| `slot.description` | `List<LanguageText>` | 槽位描述 | 弹窗正文 |
| `slot.color` | `String` | 槽位颜色值 | 当前片段/芯片颜色来源之一 |
| `renderSlotKey` | `String` | 展示模板上的槽位名 | 做模板渲染时使用 |
| `sourceSlotKey` | `String` | 真实结构槽位键 | 继续关联底层结构 |
| `sourceSlot` | `EnSentenceCategorySimpleNidDTO` | 真实结构槽位词表摘要 | 调试和扩展用途 |
| `slotUid` | `Long` | 结构槽位实例主键 | 点击后继续扩展详情时可用 |
| `semanticIds` | `List<Long>` | 命中语义 ID 列表 | 后续语义抽屉可直接复用 |
| `literal` | `Boolean` | 是否字面量片段 | 字面量可禁用点击样式 |
| `required` | `Boolean` | 是否必填槽 | 控制 UI 标记、提示 |
| `grammarControlling` | `Boolean` | 是否会反向影响语法 | 控制受控槽提示 |
| `growthPriority` | `Integer` | 生长优先级 | 当前 demo 未直接使用，保留 |
| `dependsOn` | `List<String>` | 前置依赖槽位键 | 当前 demo 未直接使用，保留 |
| `hasChildStruct` | `Boolean` | 是否可继续展开子结构 | `ui_demo` 的展开/折叠入口 |
| `childStruct` | `SentencePatternStructChildDTO` | 下钻后的子结构 | 展开内层蓝图时使用 |

### 4.4.2 `childStruct` 字段说明

当 `segment.hasChildStruct = true` 时，前端可以继续读取：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `structType` | `String` | `clause` 或 `clause_group` |
| `rootClauseId` | `Long` | 主承接 clause |
| `clauseIdList` | `List<Long>` | 覆盖的 clause 列表 |
| `content` | `String` | 子结构表层文本 |
| `patternNid` | `String` | 子结构使用的 pattern |
| `patternTemplate` | `String` | 子结构模板 |
| `patternName` | `List<LanguageText>` | 子结构 pattern 名称 |
| `patternDescription` | `List<LanguageText>` | 子结构 pattern 说明 |
| `clauseType` | `String` | clause 类型 |
| `roleInParent` | `String` | 在父结构中的角色 |
| `segmentList` | `List<SentencePatternStructSlotDTO>` | 子结构继续展开后的片段列表 |

## 4.5 槽位弹窗

`ui_demo` 的 `SlotChipPopup` 主要需要：

- 槽位显示名
- 当前命中的表层文本
- 描述列表

推荐直接从当前点击的 `segment` 上取：

| UI | 推荐字段 |
| --- | --- |
| 槽位名 | `segment.slot.name` |
| 当前文本 | `segment.text` |
| 槽位描述 | `segment.slot.description` |
| 颜色 | `segment.slot.color` |

说明：

- 当前后端已经把槽位描述一并下发
- 如果前端还想回退词表，也可以参考：
  - `segment.sourceSlot`
  - `segment.slotKey`

## 4.6 四宫格入口

`ui_demo` 目前是本地写死四宫格配置；真实接口里建议直接以后端返回为准：

- `analysisEntries`

每个入口项：

| 字段 | 类型 | 说明 | 当前 demo 对应 |
| --- | --- | --- | --- |
| `type` | `String` | `chunks/svoca/syntax/relations` | `layer.key` |
| `title` | `List<LanguageText>` | 中英双语标题列表 | `layer.label + layer.sublabel` |
| `description` | `String` | 卡片描述 | `layer.description` |
| `status` | `Integer` | 学习项状态值，复用 `ScriptLearnItemDTO.status` 语义 | `layer.available` 的服务端版 |
| `iconKey` | `String` | OSS 资源 key | 无直接对应，本地静态 icon 的服务端替代 |
| `iconUrl` | `String` | 完整可访问图标地址 | `layer.icon` 的服务端替代 |
| `color` | `SubGradientColor` | 入口渐变色，包含 `from/to` | 替代本地静态色板 |
| `learnTip` | `String` | 不可用时的提示文案，可为 `null` | 卡片禁用态提示 |
| `suitable` | `Boolean` | 是否当前默认焦点入口 | `layer === 当前默认 layer` |
| `index` | `Integer` | 四宫格排序位次，固定 1~4 | 卡片排序 |
| `jump` | `JumpBo` | 预留跳转对象，当前为 `null` | 暂无直接使用 |
| `statusTip` | `Integer` | 预留状态提示码，当前为 `null` | 暂无直接使用 |

### 4.6.1 `status` 取值说明

| 状态 | 含义 | 当前规则 |
| --- | --- | --- |
| `1` | 正常可用 | 有对应分析数据 |
| `2` | 即将开放 | 当前仅占位，未接真实数据，当前用于 `relations` |
| `3` | 暂未开放 | 当前能力已支持，但本句无数据，例如无 chunking、无 svoca、无 constituency parse |

### 4.6.2 四宫格样式来源

四宫格入口图标与色板不是前端本地写死，而是后端统一下发，配置文件为：

- `language-app/src/main/resources/data/sentence_analysis_entry_style.conf`

样式装配服务：

- `SentenceAnalysisEntryStyleService`

前端建议：

- 图标优先使用 `iconUrl`
- 色板优先读取 `color.from` 和 `color.to`
- `title` 直接按当前语言取值，不需要再拆 `title/subTitle`
- 本地静态颜色只作为临时 fallback

## 4.7 四宫格详情数据

### 4.7.1 `analysisData.tokens`

全句公共 token 列表。

| 字段 | 类型 | 说明 | 来源 |
| --- | --- | --- | --- |
| `tokens` | `List<SyntaxTokenDTO>` | 句子 token 列表 | `en_sentence_structures.tokens` |

当前建议用途：

- 语块页定位词级范围
- 成分页定位成分覆盖范围
- 句法页复用同一份 token 数据

### 4.7.2 `analysisData.clauses`

全句公共 clause 列表。

| 字段 | 类型 | 说明 | 来源 |
| --- | --- | --- | --- |
| `clauses` | `List<ClauseDTO>` | 子句列表 | `en_sentence_structure_clauses` |

当前建议用途：

- `clauses[].chunking` 画语块
- `clauses[].svoca` 画成分
- `clauses[].grammaticalFeatures` 和 `clauses[].specialClauseFeatures` 做补充说明

### 4.7.3 `analysisData.svoca` 对应字段

成分页不再有独立对象，直接读取：

- `analysisData.clauses[*].svoca`

`SvocaDTO` 字段：

| 字段 | 类型 | 说明 | 来源 |
| --- | --- | --- | --- |
| `codeNid` | `String` | SVOCA 编码 | `en_sentence_structure_clauses.svoca.codeNid` |
| `code` | `EnSentenceSimpleNidDTO` | SVOCA 词表摘要 | `en_sentence_svoca_codes` |
| `descriptions` | `List<LanguageText>` | 成分描述 | 结构表内嵌字段 |
| `elements` | `List<SvocaElementDTO>` | 成分元素列表 | 结构表内嵌字段 |

`SvocaElementDTO` 字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `typeNid` | `String` | 元素类型码 |
| `type` | `EnSentenceSimpleNidDTO` | 类型词表摘要 |
| `textReference` | `TextReferenceDTO` | 在 clause 中的文本区间 |
| `descriptions` | `List<LanguageText>` | 元素说明 |

### 4.7.4 `analysisData.syntax`

表示“句法”分析页主体数据。

| 字段 | 类型 | 说明 | 来源 |
| --- | --- | --- | --- |
| `constituencyParse` | `String` | constituency parse 原始串 | `en_sentence_structures.constituencyParse` |
| `posForms` | `List<PosFormDTO>` | 当前句子涉及的词性词表 | `pos_forms` |

说明：

- `syntax` 不再重复返回 `tokens`
- 句法页需要的 token 统一从 `analysisData.tokens` 读取
- 句法关系树主要基于 `analysisData.tokens[*].id/head/text/posTitle/posColor` 绘制

`SyntaxTokenDTO` 字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `id` | `Integer` | token 序号 |
| `text` | `String` | 表层文本 |
| `lemma` | `String` | lemma |
| `pos` | `String` | PTB 词性码 |
| `upos` | `String` | Universal POS |
| `head` | `Integer` | 依存 head |
| `deprel` | `String` | 依存关系 |
| `posTitle` | `List<LanguageText>` | 词性标题 |
| `posColor` | `ChunkColor` | 词性色板 |

`PosFormDTO` 字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `ptb` | `String` | PTB 码 |
| `abbr` | `String` | 缩写 |
| `description` | `String` | 说明 |
| `title` | `List<LanguageText>` | 多语言名称 |
| `color` | `ChunkColor` | 词性色板 |

### 4.7.5 `analysisData.relations`

当前只返回占位结构：

```json
{
  "status": 2,
  "title": "关联",
  "description": "当前仅返回入口占位状态，真实关联数据后续接入。"
}
```

前端当前建议：

- 卡片可正常展示
- 点击后可以显示“建设中”或“稍后回来”
- 不要假设已有姐妹句、对照句、问答集等真实数据

---

## 5. `ClauseDTO` 字段说明

`analysisData.clauses` 是语块页和成分页共用的一套 `ClauseDTO`。

| 字段 | 类型 | 说明 | 来源 |
| --- | --- | --- | --- |
| `orderInSentence` | `Integer` | 子句在整句中的顺序 | `en_sentence_structure_clauses.orderInSentence` |
| `parentClauseId` | `Long` | 父子句 ID | `en_sentence_structure_clauses.parentClauseId` |
| `textReference` | `TextReferenceDTO` | 在整句中的文本区间 | `en_sentence_structure_clauses.textReference` |
| `text` | `String` | 子句文本 | `en_sentence_structure_clauses.text` |
| `type` | `String` | 子句类型 | `en_sentence_structure_clauses.type` |
| `roleInParent` | `String` | 在父结构中的角色 | `en_sentence_structure_clauses.roleInParent` |
| `conjunctions` | `List<ConjunctionDTO>` | 连接词信息 | `en_sentence_structure_clauses.conjunctions` |
| `chunking` | `List<ChunkingDTO>` | 语块切分结果 | `en_sentence_structure_clauses.chunking` |
| `svoca` | `SvocaDTO` | 成分分析 | `en_sentence_structure_clauses.svoca` |
| `grammaticalFeatures` | `List<GrammarFeatureDTO>` | 语法特征 | `en_sentence_structure_clauses.grammaticalFeatures` |
| `specialClauseFeatures` | `List<SpecialClauseFeatureDTO>` | 特殊子句特征 | `en_sentence_structure_clauses.specialClauseFeatures` |

### 5.1 `textReference`

```json
{
  "start": 17,
  "end": 31
}
```

说明：

- 表示字符串切片区间
- 前端高亮、hover 定位、局部描边时可直接使用

### 5.2 `conjunctions`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `typeNid` | `String` | 连接词类型 |
| `text` | `String` | 表层文本 |
| `textReference` | `TextReferenceDTO` | 对应文本位置 |
| `linkedClauseId` | `Long` | 关联到的 clause |
| `descriptions` | `List<LanguageText>` | 说明文案 |

### 5.3 `chunking`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `type` | `String` | 语块类型 |
| `textReference` | `TextReferenceDTO` | 对应文本位置 |
| `descriptions` | `List<LanguageText>` | 语块说明 |

### 5.4 `grammaticalFeatures`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `category` | `String` | 特征分类 |
| `featureNid` | `String` | 特征码 |
| `feature` | `EnSentenceSimpleNidDTO` | 词表摘要 |
| `descriptions` | `List<LanguageText>` | 说明 |

### 5.5 `specialClauseFeatures`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `featureNid` | `String` | 特征码 |
| `textReference` | `TextReferenceDTO` | 对应文本位置 |
| `descriptions` | `List<LanguageText>` | 说明 |

---

## 6. `media / study / legacy` 说明

## 6.1 `media`

| 字段 | 类型 | 说明 | 来源 |
| --- | --- | --- | --- |
| `imageUrl` | `String` | 句子配图 URL | 复用旧版媒体装配 |
| `imageKey` | `String` | 资源 key | 复用旧版媒体装配 |
| `imageMd5` | `String` | 图像 md5 | 复用旧版媒体装配 |
| `video` | `ContentCardVideoDTO` | 配套视频 | 复用旧版媒体装配 |
| `pronunciations` | `List<EnWordCardPronunciationDTO>` | 发音列表 | 媒体公共服务 |

说明：

- 这部分故意沿用旧版口径，避免同一句子在 v1/v2 媒体信息不一致

## 6.2 `study`

| 字段 | 类型 | 说明 | 来源 |
| --- | --- | --- | --- |
| `cardStar` | `ContentCardStarDTO` | 当前句子卡牌星级 | `study-app` |
| `stat` | `ContentStatScoreDTO` | 当前句子学习统计 | `study-app` |
| `rights` | `RightsBO` | 扩展卡片权益 | 权益服务 |

说明：

- 子知识点的 `cardStar` 会单独回填到 `legacy.subContents[*].cardStar`

## 6.3 `legacy`

| 字段 | 类型 | 说明 | 来源 |
| --- | --- | --- | --- |
| `moduleItems` | `List<EnContentCardModuleItemDTO>` | 旧版模块入口 | 旧卡牌模块逻辑 |
| `subContents` | `List<ContentCardSimpleDTO>` | 子知识点卡片 | `en_sentences.subContentIds` + 内容公共服务 |

说明：

- `moduleItems` 动态规则：
  - 有子知识点才返回 `CORE_COMPONENTS`
  - 一定返回 `VIEW_LEVEL`
  - 一定返回 `MEMORIZE_SENTENCE`
- 这部分是为了兼容旧句子卡牌功能，不是新 demo 的主体

---

## 7. 多语言字段说明

接口中的多语言字段统一使用：

```json
[
  { "lang": "en", "text": "..." },
  { "lang": "zh", "text": "..." }
]
```

当前前端建议：

1. 优先按当前语言取对应项
2. 如果没有当前语言，取列表第一项作为 fallback

典型多语言字段包括：

- `structure.basicType.name`
- `structure.functionalType.name`
- `structure.blueprint.patternName`
- `structure.blueprint.patternDescription`
- `structure.blueprint.blueprintScopeName`
- `analysisData.tokens[*].posTitle`
- `analysisData.syntax.posForms[*].title`

---

## 8. 后端真实数据来源

## 8.1 主表与结构表

| 表 / 集合 | 用途 |
| --- | --- |
| `en_sentences` | 句子主数据、原文、释义、难度、子知识点 |
| `en_sentence_structures` | 新结构真相表，token、parse、basicType、functionalType、pattern |
| `en_sentence_structure_clauses` | clause、chunking、svoca、语法特征等 |
| `en_sentence_structure_slots` | 蓝图对齐真实槽位 |

## 8.2 词表与样式表

| 表 / 集合 | 用途 |
| --- | --- |
| `en_sentence_basic_types` | 基础句型词表 |
| `en_sentence_functional_types` | 功能句型词表 |
| `en_sentence_patterns` | 蓝图定义、模板、name、description、scope |
| `en_sentence_slot_keys` | 槽位词表 |
| `en_sentence_slot_categories` | 槽位分类、颜色 |
| `en_sentence_grammar_features` | 语法特征词表 |
| `en_sentence_svoca_codes` | SVOCA code 词表 |
| `en_sentence_svoca_element_types` | SVOCA element type 词表 |
| `pos_forms` | 词性标题与颜色 |

## 8.3 跨服务

| 服务 | 用途 |
| --- | --- |
| `study-app` | 学习状态、星级、统计 |
| 内容媒体公共服务 | 图片、视频、发音 |
| OSS | 四宫格 icon 资源地址 |

---

## 9. 前端接入建议

## 9.1 能直接循环渲染的字段

这些字段已经是后端为了前端渲染整理好的，不建议前端再手写文案：

- `analysisEntries`

说明：

- 顶部句型芯片直接读 `structure.basicType / structure.functionalType`
- 蓝图标题与作用域直接读 `structure.blueprint.patternName / blueprintScopeName`

## 9.2 需要逻辑判断时优先用原始字段

这些字段适合做判断和路由，而不是直接展示：

- `module`
- `layer`
- `structure.blueprint.blueprintScope`
- `analysisEntries[*].status`
- `analysisEntries[*].type`

## 9.3 当前最稳的页面渲染方式

### 句子详情顶部卡片

- 句型标签：`structure.basicType` + `structure.functionalType`
- 句子文本：`content`
- 句子释义：`definition`
- 蓝图标题/作用域：`structure.blueprint.patternName` + `structure.blueprint.blueprintScopeName`
- 蓝图对齐：`structure.blueprint.segmentList`

### 四宫格

- 卡片列表：`analysisEntries`
- 默认激活项：`layer`

### 详情子页

- 语块：`analysisData.clauses[*].chunking`
- 成分：`analysisData.clauses[*].svoca`
- 句法：`analysisData.syntax`
- 关联：`analysisData.relations`

## 9.4 当前需要注意的边界

1. `relations` 目前只有占位状态，没有真实关联数据
2. `legacy` 是兼容旧功能，不是这次新 demo 的主渲染来源
3. 入口图标与渐变色由后端统一下发，前端不建议继续长期维护一套平行静态色板
4. 如果当前句子没有结构真相数据：
   - 顶部基础句子信息仍然可用
   - 四宫格入口可能出现 `status = 3`

## 9.5 颜色获取建议

当前接口已经直接返回一部分颜色数据，例如：

- `analysisEntries[*].color`
- `analysisData.tokens[*].posColor`
- `analysisData.syntax.posForms[*].color`

其余业务颜色建议优先复用前端已有的配置接口：

- `GET /language/config/color/list`

建议映射关系：

| 场景 | 配置字段 |
| --- | --- |
| 顶部基础句型芯片 | `basicLevels` |
| 顶部功能句型芯片 | `functionalLevels` |
| 子句类型颜色 | `clauseTypes` |
| 语法特征颜色 | `grammaticalFeatures` |

使用建议：

1. 先按详情接口里的业务 code 取值，例如 `structure.basicType.nid`、`clauses[*].type`、`grammaticalFeatures[*].featureNid`
2. 再到 `color/list` 返回中按 `code` 匹配颜色
3. 如果详情接口已经直接给色值，优先以详情接口为准

---

## 10. 推荐前端字段映射

如果要把现在的 `ui_demo` mock 结构平滑切到真实接口，建议按下面映射：

| `ui_demo` mock 字段 | 真实接口字段 |
| --- | --- |
| `bundle.sentence.uid` | `contentId` |
| `bundle.sentence.text` | `content` |
| `bundle.sentence.translationZh` | `definition` |
| `bundle.structure.basicTypeNid` | `structure.basicType.nid` |
| `bundle.structure.functionalTypeNid` | `structure.functionalType.nid` |
| `pattern.name` | `structure.blueprint.patternName` |
| `pattern.blueprintScope` | `structure.blueprint.blueprintScope` |
| `pattern.segmentList / slots` | `structure.blueprint.segmentList` |
| `SENTENCE_ANALYSIS_LAYERS` | `analysisEntries` |

推荐落地顺序：

1. 先把详情页顶部和四宫格切到真实接口
2. 再把蓝图对齐行切到 `structure.blueprint`
3. 再把三个分析详情页逐步切到 `analysisData`

---

## 11. 总结

这个接口的设计目标不是只服务某一个分析页，而是：

1. 一次返回完整句子详情页数据
2. 保留旧卡牌能力，避免现网功能丢失
3. 把新结构真相表体系整理成前端可直接消费的结构
4. 尽量减少前端自己拼标签、拼文案、拼样式的工作量

如果前端以本文件中的推荐字段作为主读取路径，当前已经可以完整支撑：

- 句子详情上半区
- 蓝图对齐展示
- 槽位弹窗
- 四宫格入口
- `chunks / svoca / syntax` 三个详情页

当前唯一明确仍处于占位阶段的是：

- `relations`
