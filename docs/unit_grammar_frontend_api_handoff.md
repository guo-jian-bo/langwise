# 单元语法前端 API 交接文档

## 1. 文档目标

本文只面向前端联调，覆盖：

- `CourseKnowledgeController` 中本次新增的单元语法接口
- Hub 页与 Target 详情页的字段含义
- 前端应该使用哪些字段做判断
- 不明显的边界规则和现状限制

目标是让前端只看这一份文档就能完成接入，减少来回追问。

相关代码入口：

- [CourseKnowledgeController.java](file:///Users/tanrong/Desktop/git/course/course-admin/src/main/java/com/timelywise/course/admin/controller/course/CourseKnowledgeController.java)
- [CourseUnitGrammarService.java](file:///Users/tanrong/Desktop/git/course/course-admin/src/main/java/com/timelywise/course/admin/service/course/CourseUnitGrammarService.java)
- UI 参考：`/Users/tanrong/Downloads/unit_grammar_ui.md`

## 2. 页面与接口总览

当前只有两个主页面：

1. Hub 页：单元语法总览
2. Target 详情页：单个语法 Target 的详情、审核、补句

接口按页面分工如下：

| 页面/动作 | 接口 |
| --- | --- |
| Hub 页整体数据 | `GET /unit/{unitId}/knowledge/grammar/list` |
| Hub 句子列表 | `GET /unit/{unitId}/knowledge/grammar/sentences` |
| Target 详情 | `GET /unit/{unitId}/knowledge/grammar/targets/detail?targetUid=...` |
| 修改 Target 审核状态 | `POST /unit/{unitId}/knowledge/grammar/targets/status` |
| 生成单元语法 | `POST /unit/{unitId}/knowledge/grammar/actions/analyze` |
| 已有句子绑定语法 | `POST /unit/{unitId}/knowledge/grammar/actions/bind-targets` |
| 匹配库里已有句子 | `POST /unit/{unitId}/knowledge/grammar/actions/match-deficit` |
| 自动生成语法句子 | `POST /unit/{unitId}/knowledge/grammar/actions/create-auto` |
| 分析已绑定语法句子 | `POST /unit/{unitId}/knowledge/grammar/actions/analyse-bound-sentences` |
| 生成语法课 | `POST /unit/{unitId}/knowledge/grammar/actions/generate-course` |
| 单点预览匹配库句 | `POST /unit/{unitId}/knowledge/grammar/targets/actions/match-preview` |
| 单点保存勾选句子 | `POST /unit/{unitId}/knowledge/grammar/targets/actions/match-append-selected` |
| 单点按句型生成 | `POST /unit/{unitId}/knowledge/grammar/targets/actions/create-by-pattern` |
| 单点高阶加练 | `POST /unit/{unitId}/knowledge/grammar/targets/actions/create-by-relation` |
| 从当前 Target 移除句子 | `POST /unit/{unitId}/knowledge/grammar/targets/sentences/remove` |
| 从整个单元移除句子 | `POST /unit/{unitId}/knowledge/remove?uid=...&flag=1` |

说明：

- controller 类级路径已存在，以上写的是实际完整业务路径心智。
- 所有接口统一返回 `HttpResult<T>`，前端重点使用 `data`，同时保留 `message` 给 toast。

## 3. 通用判断规则

### 3.1 Target 状态

以 `status` 做逻辑判断，以 `statusLabel` 做展示。

| `status` | `statusLabel` | 含义 |
| --- | --- | --- |
| `candidate` | `备选` | 待审核 |
| `approved` | `通过` | 允许参与后续产线、允许单点补句 |
| `disabled` | `未通过` | 不参与后续产线，不允许单点补句 |

前端规则：

1. 逻辑判断一律看 `status`，不要反过来解析中文文案。
2. 直接展示时优先用 `statusLabel`。
3. 单点补句按钮只在 `status=approved` 时可点击。

### 3.2 句子绑定状态

Hub 句子列表里的 `grammarBindStatus` 用来驱动第二层 tab：

| `grammarBindStatus` | 含义 | 推荐中文 |
| --- | --- | --- |
| `bound` | 已绑定到至少一个 Target | `已绑定` |
| `unchecked` | 未绑定，仍可继续处理 | `未绑定` |
| `not_target` | 不符合当前单元语法 | `不符合单元语法` |

注意：

- `sentenceTabs[].label` 返回的是 `all / bound / unchecked / not_target`，**前端不要直接展示这个 label**。
- 句子 tab 的显示文案建议前端自己按 `code` 映射成中文。

### 3.3 各类 ID 的使用场景

这是前端最容易混的部分。

| 字段 | 含义 | 主要用途 |
| --- | --- | --- |
| `targetUid` | 语法 Target 主键 | 审核、单点动作、详情页路由 |
| `knowledgeUid` / `uid` | 单元知识点表记录主键 | 从语法移除、从单元删除 |
| `contentId` | 句子主键 | 展示层标识、句内容关联 |
| `matches[].sentenceUid` | 算法返回的候选句 ID | 保存勾选时回传到 `contentIds` |

特别说明：

1. 详情页和 Hub 句子列表里的句子操作，一律使用 `knowledgeUid`。
2. 单点“保存勾选句子”接口，前端传的是 `contentIds`，但值来源是 `matches[].sentenceUid`。
3. 不要把 `contentId` 误当成 `knowledgeUid` 去删句子。

## 4. Hub 页读接口

### 4.1 获取 Hub 页数据

`GET /unit/{unitId}/knowledge/grammar/list`

返回 DTO：`CourseUnitGrammarListDTO`

#### 顶部计数 `header`

| 字段 | 类型 | 含义 | 前端用途 |
| --- | --- | --- | --- |
| `targetTotalCount` | number | 当前单元全部 Target 数量 | 顶部总数 |
| `candidateCount` | number | 状态为 `candidate` 的 Target 数量 | 顶部待审数、是否显示“去审核”强调态 |
| `boundSentenceCount` | number | 当前已绑定到至少一个 Target 的句子数 | 顶部已绑句数 |
| `sentenceTotalCount` | number | 当前单元句材总数 | 顶部句总数 |

#### 去审核入口 `reviewEntry`

| 字段 | 类型 | 含义 | 前端用途 |
| --- | --- | --- | --- |
| `hasCandidate` | boolean | 是否仍存在待审核 Target | 是否显示/高亮“去审核”入口 |
| `firstCandidateTargetUid` | number \| null | 第一条待审核 Target | 点击“去审核”时直接跳详情 |
| `candidateTotalCount` | number | 待审核总数 | “备选 i/n”中的 `n` |

跳转规则：

1. `hasCandidate=false` 时，“去审核”应视为不可进入。
2. `hasCandidate=true` 时，跳详情页并带 `targetUid=firstCandidateTargetUid`。
3. 如果产品保留审核队列模式，同时附带 `reviewQueue=true`。

#### 左侧大纲 `outline`

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `outlineId` | number \| null | 大纲 ID；无大纲时可能为空 |
| `summary` | string \| null | 大纲摘要 |
| `points` | array | 大纲要点列表 |

`outline.points[]`

| 字段 | 类型 | 含义 | 前端用途 |
| --- | --- | --- | --- |
| `pointOrder` | number | 要点序号 | 左栏排序、展示编号 |
| `title` | string | 要点标题 | 左栏主标题 |
| `description` | string | 要点说明 | 左栏说明文案 |
| `objective` | string | 要点目标 | 辅助说明 |
| `candidateCount` | number | 该要点下待审核 Target 数量 | 标记优先级 1 |
| `patternDeficitCount` | number | 该要点下已通过 pattern 的总缺口 | 标记优先级 2 |
| `targets` | array | 当前要点下的 Target 卡片列表 | 右侧卡片区直接渲染数据源 |

左侧状态标前端按以下规则推导：

1. 若 `candidateCount > 0`，显示 `N 待审`
2. 否则若 `patternDeficitCount > 0`，显示 `缺 N`
3. 否则显示 `✅`

注意：

- 一次只显示一种标记。
- 优先级固定为“待审 > 缺句 > 完成”。

#### 流水线 `pipeline.steps[]`

| 字段 | 类型 | 含义 | 前端用途 |
| --- | --- | --- | --- |
| `step` | number | 步骤序号 1-8 | 固定排序 |
| `code` | string | 步骤编码 | 前端分支判断应基于此字段 |
| `name` | string | 步骤文案 | 直接展示 |
| `locked` | boolean | 当前是否锁定 | `true` 时禁用点击 |
| `running` | boolean | 当前是否进行中 | 按钮 loading / 进行中态 |
| `done` | boolean | 当前是否已完成 | 完成态样式 |
| `summary` | string \| null | 结果摘要或错误信息 | 灰字说明 |

重点：不同 step 的 `done` 语义并不完全相同，前端不要自己猜。

当前后端口径如下：

| `code` | `done=true` 的含义 |
| --- | --- |
| `analyze` | 最新任务成功，或 `unit.grammarAnalyzed == 2` |
| `review` | 第 1 步已完成，且没有待审核 Target，且至少已有一个 Target |
| `bind_targets` | 第 2 步已完成，且最新异步任务成功 |
| `match_deficit` | 第 3 步已完成，且最近一次同步匹配执行成功 |
| `create_auto` | 第 4 步已完成，且最新异步任务成功 |
| `analyse_bound` | 第 5 步已完成，且最新异步任务成功 |
| `generate_grammar_course` | 第 6 步已完成，且语法课时计划已生成完成 |
| `generate_writing_course` | 固定未实现 |

前端建议：

1. 只信任后端返回的 `done / locked / running`。
2. 不要自己用 `candidateCount` 或 `缺口` 去重算 step 5/6 的 `done`。
3. step 8 若 `summary=暂未实现`，应展示占位态，不可点。
4. step 7 只信任后端返回的 `done / locked / running / summary`，不要前端自行拼课时计划状态。
5. `locked` 口径与 `ui_demo` 一致：第 2-7 步按前一步 `done=true` 串行解锁。

#### Target 页签 `targetTabs[]`

| 字段 | 类型 | 含义 | 前端用途 |
| --- | --- | --- | --- |
| `code` | string | `all / pattern / pair / paradigm / pyramid / grid` | 过滤主键 |
| `label` | string | 中文名称 | 直接展示 |
| `count` | number | 数量 | tab 角标 |

#### 右侧 Target 卡片 `outline.points[].targets[]`

前端直接遍历 `outline.points[].targets[]`。

`targets[]`

| 字段 | 类型 | 含义 | 前端用途 |
| --- | --- | --- | --- |
| `uid` | number | Target 主键 | 点击详情 |
| `order` | number | 组内顺序 | 组内排序 |
| `status` | string | 状态编码 | 逻辑判断 |
| `statusLabel` | string | 状态中文 | 展示 |
| `assetKind` | string | 资产类型 | 标签样式、详情区渲染分支 |
| `assetLabel` | string | 资产类型中文 | 展示 |
| `assetNid` | string | 资产 nid | 辅助信息展示 |
| `title` | string | Target 标题 | 卡片标题 |
| `boundCount` | number | 已绑定句数 | pattern 配额展示 |
| `needCount` | number | 需求句数 | pattern 配额展示 |
| `deficitCount` | number | 当前缺口 | 缺句提醒 |
| `reviewScore` | number \| null | reviewHints.score | 可选辅助信息，不参与流程判断 |

前端规则：

1. 卡片审核态看 `status/statusLabel`。
2. 配额类数字只建议对 `assetKind=pattern` 展示。
3. `deficitCount` 已由后端算好，不要重复用 `boundCount/needCount` 另算不同口径。

### 4.2 获取 Hub 句子列表

`GET /unit/{unitId}/knowledge/grammar/sentences`

返回 DTO：`CourseUnitGrammarSentenceListDTO`

#### 句子 tab `sentenceTabs[]`

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `code` | string | `all / bound / unchecked / not_target` |
| `label` | string | 英文 code；不要直接展示 |
| `count` | number | 数量 |

前端建议的展示文案映射：

| `code` | 建议展示 |
| --- | --- |
| `all` | 全部 |
| `bound` | 已绑定 |
| `unchecked` | 未绑定 |
| `not_target` | 不符合单元语法 |

#### 句子列表 `sentenceView.sentences[]`

| 字段 | 类型 | 含义 | 前端用途 |
| --- | --- | --- | --- |
| `uid` | number | `knowledgeUid` | 删除/解绑操作主键 |
| `content` | string | 句面文本 | 主展示内容 |
| `contentId` | number | 词典句 ID | 调试/跳转时辅助使用 |
| `semanticId` | number \| null | 语义 ID | 辅助信息 |
| `patternNid` | string \| null | 当前 pattern nid | 结构展示辅助 |
| `source` | string | 来源编码 | 建议仅用于逻辑分流 |
| `sourceLabel` | string | 来源中文 | 直接展示 |
| `hasStructure` | boolean | 是否已有结构分析 | “已分析/未分析” 判断 |
| `grammarBindStatus` | string | 绑定状态编码 | 句子 tab 过滤 |
| `targetBadges` | array | 当前绑定到的 Target 列表 | 已绑定标签 |

`targetBadges[]`

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `targetUid` | number | 绑定到的 Target |
| `title` | string | Target 标题 |
| `status` | string | Target 状态编码 |
| `statusLabel` | string | Target 状态中文 |

前端规则：

1. 已绑定标签用 `targetBadges` 渲染，不要自己从 `patternNid` 反推。
2. `sourceLabel` 已经是中文，可直接展示。
3. “已分析/未分析”只看 `hasStructure`。

## 5. Target 详情读接口

### 5.1 获取 Target 详情

`GET /unit/{unitId}/knowledge/grammar/targets/detail?targetUid={id}&reviewQueue={false|true}`

参数：

| 参数 | 必填 | 说明 |
| --- | --- | --- |
| `targetUid` | 是 | 当前 Target 主键 |
| `reviewQueue` | 否 | 是否进入审核队列模式；不传默认 `false` |

返回 DTO：`CourseUnitGrammarTargetDetailDTO`

#### 目标信息 `target`

| 字段 | 类型 | 含义 | 前端用途 |
| --- | --- | --- | --- |
| `uid` | number | Target 主键 | 当前详情主对象 |
| `pointOrder` | number | 所属要点 | 辅助展示 |
| `order` | number | 要点内顺序 | 辅助展示 |
| `status` | string | 状态编码 | 审核按钮状态、是否允许补句 |
| `statusLabel` | string | 状态中文 | 展示 |
| `assetKind` | string | 资产类型 | 详情区渲染分支 |
| `assetNid` | string | 资产 nid | 调试、信息展示 |
| `title` | string | 标题 | 页面标题 |
| `description` | string | 描述 | 页面文案 |
| `objective` | string | 目标 | 页面文案 |
| `instanceCount` | number \| null | 高阶实例数 | pair/paradigm/pyramid/grid 相关说明 |

#### 资产区 `grammarStructInfo`

说明：

- 该字段用于替代旧的 `assetView`
- 后端已不再调用旧的 `/inner/language/grammar/assets/query`
- 当前改为调用 language 侧统一结构接口 `/content/grammar/struct/unified/infos`

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `type` | string | 统一语法结构类型 |
| `nid` | string | 资产 nid |
| `name` | array | 多语言名称 |
| `description` | array | 多语言说明 |
| `payload` | object \| null | 具体类型对应的完整结构数据，原样透传 language 返回 |

当前 `target.assetKind` 与 `grammarStructInfo.type` 的对应关系：

| `target.assetKind` | `grammarStructInfo.type` |
| --- | --- |
| `pattern` | `EN_SENTENCE_PATTERN` |
| `pyramid` | `EN_SENTENCE_PATTERN` |
| `pair` | `EN_SENTENCE_PATTERN_PAIR` |
| `paradigm` | `EN_SENTENCE_PARADIGM` |
| `grid` | `EN_SENTENCE_GRAMMAR_GRID` |

前端规则：

1. 详情页资产区优先使用 `grammarStructInfo`，不要再依赖旧 `assetView`。
2. `name/description` 为多语言数组；如果只展示中文，按项目现有多语言取值逻辑读取。
3. `payload` 为 language 侧原始结构 DTO，前端按 `type` 分支渲染，不要假设不同类型的 `payload` 字段结构一致。
4. `target.assetKind` 仍可继续用于页面上的类型标签和轻量分支判断，但资产详情数据源以 `grammarStructInfo` 为准。

#### 配额 `quota`

| 字段 | 类型 | 含义 | 前端用途 |
| --- | --- | --- | --- |
| `showQuota` | boolean | 当前是否应该展示配额 | 配额整块显隐 |
| `boundCount` | number | 已绑定句数 | 左中区数字 |
| `needCount` | number | 需求句数 | 左中区数字 |
| `isEnough` | boolean | 是否已满足配额 | 红绿样式 |

配额显隐规则已由后端处理：

- 只有 `status=approved` 且 `assetKind=pattern` 时，`showQuota=true`
- 其它类型和未审核通过的 Target，前端应隐藏配额区

#### 词锚 `lexicalAnchors[]`

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `anchorKey` | string | 锚点唯一键 |
| `content` | string | 锚点内容 |
| `bindingMode` | string | `required_slot / preferred_slot / context_only` |
| `bindingModeLabel` | string | `必填槽 / 优先槽 / 语境` |

说明：

- 该列表已经合并了 Target 自身词锚和所属 Outline 要点词锚。
- 展示时优先用 `bindingModeLabel`。

#### 当前已绑句 `sentences[]`

| 字段 | 类型 | 含义 | 前端用途 |
| --- | --- | --- | --- |
| `uid` | number | `knowledgeUid` | 句子操作主键 |
| `content` | string | 句面 | 主展示 |
| `contentId` | number | 词典句 ID | 辅助信息 |
| `semanticId` | number \| null | 语义 ID | 辅助信息 |
| `hasStructure` | boolean | 是否有结构分析 | “已分析/未分析” 判断 |
| `structureChips` | array<string> | 当前仅放 `patternNid` | 有内容就展示 chips |

现状说明：

- 这里的 `structureChips` 目前不是完整结构树，只是一个轻量展示字段。
- 不要把它理解成完整语法分析结果。

#### 审核区 `review`

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `evidences` | array<string> | 当前后端直接返回 `canonicalExamples` |
| `reviewNotes` | string \| null | `reviewHints.notes` |

说明：

- 当前后端没有额外把 `sourceEvidence.excerpt` 回填到 `evidences`。
- 如果 `evidences` 为空，前端允许直接隐藏该块，不要自行虚构文案。

#### 详情导航 `navigator`

| 字段 | 类型 | 含义 | 前端用途 |
| --- | --- | --- | --- |
| `mode` | string | `browse / review` | 决定导航模式说明文案 |
| `prevTargetUid` | number \| null | 上一个 Target | 左翻页 |
| `nextTargetUid` | number \| null | 下一个 Target | 右翻页 |
| `currentIndex` | number | 当前序号，从 1 开始 | `i / n` 展示 |
| `totalCount` | number | 当前模式总数 | `i / n` 展示 |

导航规则：

1. `reviewQueue=true` 时，`mode=review`，只在当前仍为 `candidate` 的 Target 之间导航。
2. `reviewQueue=false` 时，`mode=browse`，在全部 Target 间导航。
3. 若 `prevTargetUid/nextTargetUid` 为空，前端应禁用对应方向按钮。

### 5.2 当前内部依赖说明

这一节不是前端直接调用的接口，而是说明 `course` 详情接口当前内部如何拿语法结构数据。

当前实际口径：

1. `course` 端先查自己的 `target` 和已绑定句子列表
2. 从 `target.assetRef` 里解析出资产类型和资产 nid
3. 把当前 Target 下已绑定的句子知识点列表转成 `contents`
4. 调用 language-app：

`POST /content/grammar/struct/unified/infos`

请求体结构：

```json
{
  "grammarNidList": [
    {
      "type": "EN_SENTENCE_PATTERN",
      "nid": "pat_present_simple_001",
      "contents": [
        {
          "uid": 12345,
          "type": "EN_SENTENCE",
          "semanticId": 67890
        }
      ]
    }
  ]
}
```

说明：

- `contents` 就是当前详情页已绑定句子的知识点列表
- language 会基于 `type + nid + contents` 返回对应 unified 结构
- `course` 再把第一条结果转成详情响应里的 `grammarStructInfo`

### 5.3 `grammarStructInfo` 的使用约定

前端只需要关心这几点：

1. `grammarStructInfo` 是详情页资产区的唯一数据源。
2. `payload` 保持 language 原样返回，`course` 不再做旧 `assetView` 风格的二次拍平。
3. 不同类型下 `payload` 内部字段不同，必须先根据 `type` 决定渲染组件。
4. 如果 `grammarStructInfo=null`，前端按“当前资产结构暂无详情数据”做空态即可。

### 5.4 前端渲染建议

建议按下面方式分支：

1. `type=EN_SENTENCE_PATTERN`
   渲染句型蓝图视图；当前 `pattern` 和 `pyramid` 都会落到这里
2. `type=EN_SENTENCE_PATTERN_PAIR`
   渲染句间配链视图
3. `type=EN_SENTENCE_PARADIGM`
   渲染范式对照视图
4. `type=EN_SENTENCE_GRAMMAR_GRID`
   渲染语法全景视图

注意：

- `target.assetKind` 和 `grammarStructInfo.type` 并不是完全同一个字段，不要强行互相替代。
- 页面标签、徽标、轻量中文仍可继续用 `target.assetKind / assetLabel`。
- 真正的详情结构内容以 `grammarStructInfo` 为准。

### 5.5 实现边界

`grammarStructInfo` 只负责承载语法资产结构本身，不负责：

1. 审核状态
2. 配额 `bound/need`
3. 已绑句列表
4. review notes
5. course 侧按钮显隐

这些字段仍全部由 `course` 详情接口其他部分单独返回。

## 6. 写接口与动作接口

### 6.1 修改 Target 状态

`POST /unit/{unitId}/knowledge/grammar/targets/status`

请求体：

```json
{
  "targetUid": 1001,
  "status": "approved"
}
```

字段：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `targetUid` | number | 是 | 当前审核的 Target |
| `status` | string | 是 | `candidate / approved / disabled` |

返回：

| 字段 | 类型 | 含义 | 前端用途 |
| --- | --- | --- | --- |
| `targetUid` | number | 已修改的 Target | 更新当前卡片/详情 |
| `status` | string | 新状态编码 | 本地状态更新 |
| `remainingCandidateCount` | number | 剩余待审核数 | 审核队列底栏 |
| `nextCandidateTargetUid` | number \| null | 下一条待审 Target | 自动跳下一条 |
| `reviewCompleted` | boolean | 是否已经审完 | 审核结束后回 Hub |

推荐交互：

1. 详情审核模式下提交成功后：
   - 若 `reviewCompleted=true`，回 Hub
   - 否则若 `nextCandidateTargetUid` 有值，自动跳下一条
2. 普通浏览模式下提交成功后，可只刷新当前详情或本地改状态。

### 6.2 流水线异步动作

适用于：

- `analyze`
- `bind-targets`
- `create-auto`
- `analyse-bound-sentences`
- `create-by-pattern`
- `create-by-relation`

当前统一返回字符串：

```text
{message}，taskID:{id}
```

前端处理建议：

1. 把整个字符串直接用于 toast 即可。
2. 不要把返回 200 理解成动作已落库完成。
3. 异步任务完成后，依赖通知或用户刷新重新拉读接口。

### 6.3 生成单元语法

`POST /unit/{unitId}/knowledge/grammar/actions/analyze`

请求体可空。若传入：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `updateExists` | boolean | 否 | 是否覆盖已有结果 |

### 6.4 已有句子绑定语法

`POST /unit/{unitId}/knowledge/grammar/actions/bind-targets`

请求体可空。若传入：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `updateExists` | boolean | 否 | 是否覆盖已有结果 |

### 6.5 匹配库里已有句子

`POST /unit/{unitId}/knowledge/grammar/actions/match-deficit`

同步接口，返回 `CourseUnitGrammarMatchResultDTO`。

请求体：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `candidateMax` | number | 否 | 候选句上限，默认 40 |

返回：

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `mode` | string | 当前固定为 `append_deficit` |
| `preBind` | object \| null | 预绑定信息 |
| `targets` | array | 各 Target 的处理结果 |

`targets[]`

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `targetUid` | number | Target |
| `need` | number | 需要数量 |
| `bound` | number | 已绑数量 |
| `deficit` | number | 缺口 |
| `writeLimit` | number \| null | 算法写入上限 |
| `writtenCount` | number | 本次写入数 |
| `failureCounts` | map | 各类失败计数 |

前端重点：

1. 这是同步动作，请求返回即可结束 loading。
2. 这一步是整 unit 补缺，不是单点弹窗预览。
3. `failureCounts` 是动态 map，不要写死枚举。

### 6.6 自动生成语法句子

`POST /unit/{unitId}/knowledge/grammar/actions/create-auto`

请求体：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `onlyDeficit` | boolean | 否 | 默认 `true`，只处理仍有缺口的 Target |

### 6.7 分析已绑定语法句子

`POST /unit/{unitId}/knowledge/grammar/actions/analyse-bound-sentences`

请求体：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `targetIds` | array<number> | 否 | 为空表示分析当前 unit 的全部已绑定句 |

### 6.8 生成语法课

`POST /unit/{unitId}/knowledge/grammar/actions/generate-course`

请求体：不需要。

前端重点：

1. 这是异步动作，接口返回表示“已发起”，不是最终完成。
2. 第 7 步按钮是否可点，只看 `pipeline.steps[].locked/running`。
3. 第 7 步完成态只看 `pipeline.steps[].done=true`，不要自己组合课时 `planned` 或题目状态。

### 6.9 单点预览匹配库句

`POST /unit/{unitId}/knowledge/grammar/targets/actions/match-preview`

请求体：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `targetUid` | number | 是 | 当前 Target |
| `candidateMax` | number | 否 | 候选上限，默认 40 |

返回：`CourseUnitGrammarMatchResultDTO`

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `mode` | string | 当前固定 `preview` |
| `targetUid` | number | 当前 Target |
| `need` | number | 需求 |
| `bound` | number | 已绑 |
| `deficit` | number | 缺口 |
| `matches` | array | 候选句列表 |
| `failureCounts` | map | 失败计数 |

`matches[]`

| 字段 | 类型 | 含义 | 前端用途 |
| --- | --- | --- | --- |
| `sentenceUid` | number | 算法返回的候选句 ID | 保存勾选时回传到 `contentIds` |
| `content` | string | 句面 | 列表主文案 |
| `score` | number | 词汇契合度 | 右侧分数 |
| `scoreDetail` | object | 细项 | 预留展开 |
| `patternNid` | string | 命中 pattern | 辅助信息 |

前端注意：

1. `score=0` 仍可勾选，不代表禁用。
2. `matches` 为空时应展示空态，不算错误。

### 6.9 单点保存勾选句子

`POST /unit/{unitId}/knowledge/grammar/targets/actions/match-append-selected`

请求体：

```json
{
  "targetUid": 1001,
  "contentIds": [505729, 505734]
}
```

字段：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `targetUid` | number | 是 | 当前 Target |
| `contentIds` | array<number> | 是 | 值来源于 `matches[].sentenceUid` |

返回：

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `targetUid` | number | 当前 Target |
| `writtenCount` | number | 本次写入句数 |
| `boundCount` | number | 更新后的已绑数 |
| `needCount` | number | 当前需求 |
| `deficitCount` | number | 当前缺口 |

### 6.10 单点按句型生成

`POST /unit/{unitId}/knowledge/grammar/targets/actions/create-by-pattern`

请求体：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `targetUid` | number | 是 | 当前 pattern Target |
| `count` | number | 是 | 生成数量，范围 1-6 |

规则：

1. 仅 `status=approved` 且 `assetKind=pattern` 可调用。
2. 返回 200 后只代表任务已发起，不代表句子已经出现在代表句里。

### 6.11 单点高阶加练

`POST /unit/{unitId}/knowledge/grammar/targets/actions/create-by-relation`

请求体：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `targetUid` | number | 是 | 当前高阶 Target |
| `count` | number | 是 | 新增槽位数量，范围 1-3 |

规则：

1. 前端请求体统一使用 `count`。
2. 后端内部会映射到算法的 `add_instance_count`。
3. 仅 `status=approved` 且 `assetKind` 属于 `pair / paradigm / pyramid / grid` 时可调用。
4. 生成结果最终落在关联的 pattern Target 句子上，不落在当前高阶 Target 自身句列表里。

### 6.12 从当前 Target 移除句子

`POST /unit/{unitId}/knowledge/grammar/targets/sentences/remove`

请求体：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `targetUid` | number | 是 | 当前 Target |
| `knowledgeUid` | number | 是 | 当前句子的 `knowledgeUid` |

作用：

1. 只从当前 Target 解绑该句。
2. 不删除句子记录本身。
3. 若解绑后这句已经不属于任何 Target，后端会顺手清掉 `patternNid` 并把 `grammarBindStatus` 置回 `unchecked`。

### 6.13 从整个单元移除句子

复用现有通用删除接口：

`POST /unit/{unitId}/knowledge/remove?uid={knowledgeUid}&flag=1`

请求参数：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `uid` | number[] | 是 | 通用删除接口支持批量删除；单元语法场景固定传当前句子的 `knowledgeUid`，单条时按 `uid=123` 传即可 |
| `flag` | number | 是 | 单元语法场景固定传 `1`。按当前实现，`flag=0` 会尝试联动 language 侧内容状态；grammar 页面删除单元内句子时不走这条分支 |

作用：

1. 直接删除这条 `course_unit_knowledges` 记录。
2. 这是“删句子”，不是“解绑”。
3. 该接口本身支持批量删除，但单元语法页面按单条删除接入即可。
4. 若本次只删 1 条，现有通用删除逻辑还会顺手清理相关课时练习数据，这一点和 grammar 页面之前的专用轻量删除不同，前端无需额外处理。

## 7. 前端落地建议

### 7.1 推荐信任后端、不要自行重算的字段

- `pipeline.steps[].done`
- `pipeline.steps[].locked`
- `pipeline.steps[].running`
- `target.status / statusLabel`
- `quota.showQuota`
- `deficitCount`

### 7.2 推荐前端自行映射/推导的内容

- Hub 左侧要点状态标：根据 `candidateCount`、`patternDeficitCount`
- 句子 tab 中文：根据 `sentenceTabs[].code`
- 需要展示的按钮禁用提示文案

### 7.3 当前已知限制

1. `sentenceTabs[].label` 目前仍是英文 code，不建议直接展示。
2. `review.evidences` 当前只返回 `canonicalExamples`，不会自动补 `sourceEvidence`。
3. `structureChips` 当前只是轻量结构标签，不是完整结构分析详情。
4. 异步动作统一只返回任务启动消息，不直接返回最终结果。

## 8. 交接结论

前端接入时，优先遵守这四条：

1. 逻辑判断以编码字段为准，展示优先用中文 label 字段。
2. 删句和解绑要严格区分：`knowledgeUid` 是句材主键，`targetUid` 是语法 Target 主键。
3. 异步动作返回 200 仅代表已发起，不代表页面数据已落库完成。
4. 如果某个字段语义看起来能自己推，先以本文件约定为准；只有文档明确写“前端自行推导”的内容才自己算。
