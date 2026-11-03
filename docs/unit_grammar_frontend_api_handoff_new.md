
# 单元语法前端 API 交接文档

## 1. 文档目标

本文只面向前端联调，覆盖当前 `course` 端已经落地的单元语法接口口径。

相关入口：

- [CourseKnowledgeController.java](file:///Users/tanrong/Desktop/git/course/course-admin/src/main/java/com/timelywise/course/admin/controller/course/CourseKnowledgeController.java)
- [CourseUnitGrammarService.java](file:///Users/tanrong/Desktop/git/course/course-admin/src/main/java/com/timelywise/course/admin/service/course/CourseUnitGrammarService.java)
- UI 参考：
  - `/Users/tanrong/Downloads/unit_grammar_ui.md`
  - `/Users/tanrong/Downloads/unit_grammar_ui_0820.md`

若两版 UI 文档有冲突，以 `unit_grammar_ui_0820.md` 为准。

## 2. 这次接口变更的过渡说明

这一轮最大的变化，不是“多了几个字段”，而是前后端职责边界收了一次：

1. Target 详情接口不再返回 `navigator`，也不再接 `reviewQueue`。  
   原因是新版 UI 已经把审核队列定义成“进入详情时由前端钉死的一组 `reviewQueueUids`”。如果后端继续按数据库实时状态返回 `navigator`，就会和前端本地队列打架。

2. Hub 流水线从旧的 `locked / running / done` 三布尔，升级成 `status + summary + actionText`。  
   原因是新版页面不仅要知道“能不能点”，还要知道“当前是待开始、运行中、已跳过还是已完成”，以及按钮该显示“开始绑定”“继续匹配”还是“生成”。

3. Target 详情资产区彻底放弃旧 `assetView` 中间层，统一走 `grammarStructInfo`。  
   原因是资产类型已经扩展到 `pair_fork`，继续让 `course` 侧拍平各种资产字段，维护成本会越来越高。现在统一透传 `language` 的 unified 结构，前端按 `type` 分支消费即可。

4. 句子读接口补了 `access`，Target 审核区补了 `reviewScore / evidenceFit`。  
   这是为了支撑新版 UI 的“新创建”标记和更完整的审核展示。

## 3. 页面与接口总览

当前主页面仍然只有两层：

1. Hub 页：单元语法总览
2. Target 详情页：单个 Target 的详情、审核、补句

接口如下：

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

所有接口统一返回 `HttpResult<T>`，前端主用 `data`，`message` 仍可直接 toast。

## 4. 通用判断规则

### 4.1 Target 状态

逻辑判断一律看 `status`，展示优先用 `statusLabel`。

| `status` | `statusLabel` | 含义 |
| --- | --- | --- |
| `candidate` | `备选` | 待审核 |
| `approved` | `通过` | 参与后续产线，可执行补句类动作 |
| `disabled` | `未通过` | 不参与后续产线 |

### 4.2 句子绑定状态

`grammarBindStatus` 用来驱动 Hub 句子 tab：

| `grammarBindStatus` | 含义 |
| --- | --- |
| `bound` | 已绑定到至少一个 Target |
| `unchecked` | 尚未归属 |
| `not_target` | 不属于当前单元语法 |

### 4.3 ID 使用约定

| 字段 | 主要用途 |
| --- | --- |
| `targetUid` | Target 详情、审核、单点动作 |
| `uid` / `knowledgeUid` | 单元句材操作主键 |
| `contentId` | 词典句 ID，仅辅助展示/调试 |
| `matches[].sentenceUid` | 预览匹配结果里保存勾选句子时要回传给 `contentIds` 的值 |

不要把 `contentId` 误当成 `knowledgeUid` 去删句子。

## 5. Hub 页读接口

### 5.1 `GET /unit/{unitId}/knowledge/grammar/list`

返回 DTO：`CourseUnitGrammarListDTO`

#### `header`

| 字段 | 说明 |
| --- | --- |
| `targetTotalCount` | 当前单元全部 Target 数量 |
| `candidateCount` | 待审核 Target 数量 |
| `boundSentenceCount` | 已绑定到至少一个 Target 的句子数 |
| `sentenceTotalCount` | 当前单元句材总数 |

#### `reviewEntry`

| 字段 | 说明 |
| --- | --- |
| `hasCandidate` | 是否仍有待审核 Target |
| `firstCandidateTargetUid` | 默认进入审核流时落到哪一条 |
| `candidateTotalCount` | 当前待审核总数 |

过渡说明：

- 这里现在只负责“是否还能进入审核流”和“默认打开哪一条”。
- 后端不再返回完整审核队列。
- 前端应基于 Hub 页已拿到的全部 `targets`，按 `pointOrder -> order -> uid` 算出 `reviewQueueUids`，进入详情时把这组 uid 放到路由 state。

#### `outline.points[]`

| 字段 | 说明 |
| --- | --- |
| `pointOrder` | 要点序号 |
| `title` | 要点标题 |
| `description` | 要点说明 |
| `objective` | 要点目标 |
| `candidateCount` | 该要点下待审核数 |
| `patternDeficitCount` | 该要点下已通过 pattern 的总缺口 |
| `targets` | 当前要点下的卡片列表 |

左侧状态标仍建议前端自行推导：

1. `candidateCount > 0` 显示 `N 待审`
2. 否则 `patternDeficitCount > 0` 显示 `缺 N`
3. 否则显示完成态

#### `pipeline.steps[]`

过渡说明：

旧字段 `locked / running / done` 已废弃，当前统一看下面三个字段：

| 字段 | 说明 |
| --- | --- |
| `status` | `locked / todo / running / done / skipped / failed` |
| `summary` | 当前步骤展示文案 |
| `actionText` | 当前按钮文案，无按钮时为空 |

其它固定字段：

| 字段 | 说明 |
| --- | --- |
| `step` | 步骤序号，固定 1-8 |
| `code` | 稳定步骤编码 |
| `name` | 展示名称 |

先看 `status` 的通用含义：

| `status` | 含义 | 前端可做的事 | 推荐展示方式 |
| --- | --- | --- | --- |
| `locked` | 当前步骤受前置步骤限制，暂不可执行 | 按钮禁用，不发请求 | 灰态；主文案看 `name`，说明文案看 `summary` |
| `todo` | 当前步骤已解锁，且可以执行 | 可以点击按钮，请求对应接口 | 常态主按钮；按钮文案直接用 `actionText` |
| `running` | 当前步骤正在执行中 | 不要重复发起同一步请求 | loading / disabled；`summary` 作为进行中说明 |
| `done` | 当前步骤本轮已经真实执行过并达成目标 | 通常不需要主操作；若后端给了按钮可允许重试/重跑 | 完成态；`summary` 展示结果 |
| `skipped` | 当前步骤无需执行即可视为完成 | 不需要发请求 | 完成态或“已跳过”态；`summary` 说明为什么不用做 |
| `failed` | 最近一次执行失败 | 可以重试当前步骤 | 错误态；`summary` 直接展示失败原因，按钮文案用 `actionText` |

字段使用约定：

1. `name`：始终作为步骤标题。
2. `summary`：始终作为步骤下方说明文案，不要自己再拼一套副标题。
3. `actionText`：只要有值，就优先直接展示为按钮文案，不要前端再自行推导“开始/继续/重试”。
4. `status` 是唯一主状态来源，前端不要再从 `summary` 关键字倒推状态。

前端规则：

1. 是否可点击，优先看 `status`，不要再自行从旧字段推导。
2. 按钮文案优先直接展示 `actionText`，不要本地再拼“开始/继续”。
3. 后续步骤的解锁口径是“前一步 `status in {done, skipped}`”。

当前各步骤的详细口径如下。

| `code` | 步骤含义 | 常见 `status` | `summary` 口径 | `actionText` / 可做的事 |
| --- | --- | --- | --- | --- |
| `analyze` | 生成单元语法大纲和 Target | `todo / running / done / failed` | 未开始时是 `从单元内容写出大纲和语法`；完成后是 `N 条语法`；失败时直接返回失败原因 | `开始生成`、`重新生成`；可调用 `POST /grammar/actions/analyze` |
| `review` | 审核第 1 步产出的 Target | `locked / todo / done` | 未解锁时是 `先生成语法`；待审核时是 `还有 N 条备选，全部标成通过或未通过`；完成后是 `通过 x · 未通过 y` | `去审核`；前端进入详情审核流，不是直接发一步流水线接口 |
| `bind_targets` | 把当前 unit 里已有句子归属到语法目标 | `locked / todo / running / done / skipped / failed` | 主文案统一围绕 `未归属 N 句`；当 `N=0` 时可能直接 `skipped/done` | `开始绑定` / `继续绑定`；调用 `POST /grammar/actions/bind-targets` |
| `match_deficit` | 用库里已有句子给 pattern 类目标补缺口 | `locked / todo / running / done / skipped / failed` | 主文案统一是 `x/y 个目标满句子`，表示当前 pattern 目标补齐进度 | `开始匹配` / `继续匹配`；调用 `POST /grammar/actions/match-deficit` |
| `create_auto` | 对仍有缺口的目标自动生成句子 | `locked / todo / running / done / skipped / failed` | 主文案同样是 `x/y 个目标满句子`，表示补句后的整体覆盖进度 | `开始生成` / `继续补句`；调用 `POST /grammar/actions/create-auto` |
| `analyse_bound` | 给已绑定句子补结构分析 | `locked / todo / running / done / skipped / failed` | 主文案统一是 `a/b 个句子已分析` | `开始分析` / `继续分析`；调用 `POST /grammar/actions/analyse-bound-sentences` |
| `generate_grammar_course` | 在前 6 步完成后生成语法课计划 | `locked / todo / running / done / failed` | 未就绪或进行中都显示 `a/b 个句子已分析`；若当前 unit 没有语法课时则显示 `当前单元不存在语法课时` | `生成`；调用 `POST /grammar/actions/generate-course` |
| `generate_writing_course` | 写作课占位步骤 | 当前固定 `locked` | 固定为 `暂未实现` | 当前无可做动作 |

几个容易误解的点：

1. `done` 和 `skipped` 都表示“这一关已经过了”，都会解锁下一步。
2. `skipped` 不代表异常，反而表示“当前数据已经满足条件，不需要再执行一次”。
3. `failed` 时 `summary` 会直接带失败原因，前端不要再额外拼统一错误文案覆盖它。
4. 第 4 步和第 5 步的 `summary` 都是 `x/y 个目标满句子`，差别不在文案，而在按钮动作：
   - 第 4 步是先匹配库句
   - 第 5 步是再自动补句
5. 第 7 步如果返回 `locked + 当前单元不存在语法课时`，含义不是前置没做完，而是这个 unit 本身没有可生成的 grammar lesson；前端应展示不可执行说明，不要引导用户重复点前置步骤。

#### `targetTabs[]`

| 字段 | 说明 |
| --- | --- |
| `code` | `all / pattern / pair / pair_fork / paradigm / pyramid / grid` |
| `label` | 中文 tab 文案 |
| `count` | 数量 |

这里新增了 `pair_fork`，前端不要再把 tab 枚举写死成旧版 6 项。

#### `outline.points[].targets[]`

| 字段 | 说明 |
| --- | --- |
| `uid` | Target 主键 |
| `order` | 组内顺序 |
| `status` | 状态编码 |
| `statusLabel` | 状态中文 |
| `assetKind` | 资产类型 |
| `assetLabel` | 资产类型中文 |
| `assetNid` | 资产 nid |
| `title` | Target 标题 |
| `boundCount` | 已绑定句数 |
| `needCount` | 需求句数 |
| `deficitCount` | 当前缺口 |
| `reviewScore` | `reviewHints.score` |

建议：

- 配额数字主要对 `assetKind=pattern` 展示。
- `assetKind=pair_fork` 时，标签文案应显示“配句分叉”。

### 5.2 `GET /unit/{unitId}/knowledge/grammar/sentences`

返回 DTO：`CourseUnitGrammarSentenceListDTO`

#### `sentenceTabs[]`

| 字段 | 说明 |
| --- | --- |
| `code` | `all / bound / unchecked / not_target` |
| `label` | 当前仍等于英文 code，不建议直接展示 |
| `count` | 数量 |

#### `sentenceView.sentences[]`

| 字段 | 说明 |
| --- | --- |
| `uid` | `knowledgeUid` |
| `content` | 句面 |
| `contentId` | 词典句 ID |
| `semanticId` | 语义 ID |
| `patternNid` | 当前 pattern nid |
| `source` | 来源编码 |
| `sourceLabel` | 来源中文 |
| `access` | 词典句 access，用于识别 `INTERNAL` 新创建句 |
| `hasStructure` | 是否已有结构分析 |
| `grammarBindStatus` | 绑定状态 |
| `targetBadges` | 已绑定 Target 标签 |

前端规则：

1. “新创建”优先按 `access=INTERNAL` 判断。
2. “未分析”按钮只看 `hasStructure=false`。
3. `targetBadges` 才是当前绑定关系真相，不要从 `patternNid` 倒推。

## 6. Target 详情读接口

### 6.1 `GET /unit/{unitId}/knowledge/grammar/targets/detail?targetUid={id}`

过渡说明：

- `reviewQueue` 入参已移除。
- `navigator` 返回段已移除。
- 详情接口现在只负责“当前这一条 Target 的展示数据”。

审核流跳转由前端自己负责：

1. 从 Hub 点击卡片进入：只看当前一条，不翻页。
2. 从“去审核”进入：前端基于进入时钉死的 `reviewQueueUids` 自己控制上一条/下一条。

返回 DTO：`CourseUnitGrammarTargetDetailDTO`

#### `target`

| 字段 | 说明 |
| --- | --- |
| `uid` | Target 主键 |
| `pointOrder` | 所属要点 |
| `order` | 组内顺序 |
| `status` | 状态编码 |
| `statusLabel` | 状态中文 |
| `assetKind` | 资产类型 |
| `assetNid` | 资产 nid |
| `title` | 标题 |
| `description` | 描述 |
| `objective` | 目标 |
| `instanceCount` | 高阶实例数 |

#### `grammarStructInfo`

这是详情页资产区的唯一数据源。

| 字段 | 说明 |
| --- | --- |
| `type` | `language` 统一结构类型 |
| `nid` | 资产 nid |
| `name` | 多语言名称数组 |
| `description` | 多语言说明数组 |
| `payload` | 该类型的 unified 原始 payload |

`target.assetKind` 与 `grammarStructInfo.type` 的对应关系：

| `assetKind` | `type` | nid 来源 |
| --- | --- | --- |
| `pattern` | `EN_SENTENCE_PATTERN` | `patternNid` |
| `pyramid` | `EN_SENTENCE_PATTERN` | `patternNid` |
| `pair` | `EN_SENTENCE_PATTERN_PAIR` | `pairNid` |
| `pair_fork` | `EN_SENTENCE_PATTERN_PAIR_FORK` | `forkNid` |
| `paradigm` | `EN_SENTENCE_PARADIGM` | `paradigmNid` |
| `grid` | `EN_SENTENCE_GRAMMAR_GRID` | `gridNid` |

`pair_fork` 特别说明：

1. 这不是 `pair` 的别名，而是独立 unified 类型。
2. 详情内部会走 `language-app` 的 `/content/grammar/struct/unified/infos`。
3. 对 `pair_fork` 来说，必须传 `forkNid`，不能误传 `pairNid`。

内部请求示意：

```json
{
  "grammarNidList": [
    {
      "type": "EN_SENTENCE_PATTERN_PAIR_FORK",
      "nid": "ask_be_yes_no_to_response_word_polarity",
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

前端规则：

1. 页面标签仍可继续使用 `target.assetKind`。
2. 真正的详情结构内容以 `grammarStructInfo.type + payload` 为准。
3. `payload` 是透传值，不同 `type` 的内部结构不要假设一致。

#### `quota`

| 字段 | 说明 |
| --- | --- |
| `showQuota` | 是否展示配额区 |
| `boundCount` | 已绑定句数 |
| `needCount` | 需求句数 |
| `isEnough` | 是否已满足 |

当前只有 `status=approved && assetKind=pattern` 时 `showQuota=true`。

#### `lexicalAnchors[]`

| 字段 | 说明 |
| --- | --- |
| `anchorKey` | 锚点 key |
| `content` | 锚点内容 |
| `bindingMode` | `required_slot / preferred_slot / context_only` |
| `bindingModeLabel` | 中文说明 |

#### `sentences[]`

| 字段 | 说明 |
| --- | --- |
| `uid` | `knowledgeUid` |
| `content` | 句面 |
| `contentId` | 词典句 ID |
| `semanticId` | 语义 ID |
| `access` | 词典句 access |
| `hasStructure` | 是否已有结构 |
| `structureChips` | 当前仅轻量返回 `patternNid` |
| `removeFromTargetAllowed` | 是否可从当前 Target 移除 |
| `removeFromUnitAllowed` | 是否可从整个 unit 移除 |

说明：

1. `hasStructure=false` 时，前端应渲染“分析语法”按钮。
2. `access=INTERNAL` 时，可展示“新创建”标记。
3. `structureChips` 不是完整语法树，只是轻量标签。

#### `review`

| 字段 | 说明 |
| --- | --- |
| `evidences` | 优先 `canonicalExamples`，为空时回退 `sourceEvidence.excerpt` |
| `reviewScore` | `reviewHints.score` |
| `evidenceFit` | `reviewHints.evidenceFit` |
| `reviewNotes` | `reviewHints.notes` 原文 |

`reviewNotes` 当前不做后端裁剪，前端若要去掉 `9:` 这类前缀，请在展示层处理。

## 7. 写接口与动作接口

### 7.1 `POST /unit/{unitId}/knowledge/grammar/targets/status`

请求体：

```json
{
  "targetUid": 1001,
  "status": "approved"
}
```

返回：

| 字段 | 说明 |
| --- | --- |
| `targetUid` | 当前 Target |
| `status` | 更新后状态 |
| `remainingCandidateCount` | 剩余待审核数 |
| `reviewCompleted` | 是否已经审完 |

过渡说明：

- 旧的 `nextCandidateTargetUid` 已移除。
- 审核流跳哪一条，前端自己基于 `reviewQueueUids` 计算。

推荐交互：

1. 提交成功后先本地更新当前详情状态。
2. `reviewCompleted=true` 时回 Hub。
3. 否则从本地 `reviewQueueUids` 找当前 index，跳下一条。

### 7.2 异步动作返回约定

适用于：

- `analyze`
- `bind-targets`
- `create-auto`
- `analyse-bound-sentences`
- `generate-course`
- `create-by-pattern`
- `create-by-relation`

返回统一是字符串，例如：

```text
任务已发起，taskID:12345
```

返回 200 只代表任务已发起，不代表数据已完成落库。

### 7.3 `POST /unit/{unitId}/knowledge/grammar/actions/match-deficit`

同步接口，返回 `CourseUnitGrammarMatchResultDTO`。

请求体可传：

| 字段 | 说明 |
| --- | --- |
| `candidateMax` | 候选句上限，默认 40 |

### 7.4 `POST /unit/{unitId}/knowledge/grammar/actions/analyse-bound-sentences`

请求体可传：

| 字段 | 说明 |
| --- | --- |
| `targetIds` | 不传表示分析当前 unit 下全部已绑定句 |

前端只在 `pipeline.steps[step6].status=todo` 时提供入口即可。

### 7.5 单点动作

#### `POST /unit/{unitId}/knowledge/grammar/targets/actions/match-preview`

请求体：

| 字段 | 说明 |
| --- | --- |
| `targetUid` | 当前 Target |
| `candidateMax` | 候选上限，默认 40 |

`matches[].sentenceUid` 是保存勾选时回传给 `contentIds` 的值。

#### `POST /unit/{unitId}/knowledge/grammar/targets/actions/match-append-selected`

请求体：

```json
{
  "targetUid": 1001,
  "contentIds": [505729, 505734]
}
```

#### `POST /unit/{unitId}/knowledge/grammar/targets/actions/create-by-pattern`

请求体：

| 字段 | 说明 |
| --- | --- |
| `targetUid` | 当前 pattern Target |
| `count` | 生成数量，1-6 |

#### `POST /unit/{unitId}/knowledge/grammar/targets/actions/create-by-relation`

请求体：

| 字段 | 说明 |
| --- | --- |
| `targetUid` | 当前高阶 Target |
| `count` | 加练数量，1-3 |

当前允许的 `assetKind`：

- `pair`
- `pair_fork`
- `paradigm`
- `pyramid`
- `grid`

### 7.6 删除与解绑

#### 从当前 Target 解绑

`POST /unit/{unitId}/knowledge/grammar/targets/sentences/remove`

请求体：

| 字段 | 说明 |
| --- | --- |
| `targetUid` | 当前 Target |
| `knowledgeUid` | 当前句子的 `knowledgeUid` |

#### 从整个单元删除句子

`POST /unit/{unitId}/knowledge/remove?uid={knowledgeUid}&flag=1`

这是真删除句材，不是解绑。

## 8. 前端落地建议

优先按下面几条接：

1. 逻辑判断优先使用编码字段：`status`、`assetKind`、`grammarBindStatus`、`pipeline.steps[].status`。
2. 详情页审核导航由前端自己管理，不要再等待后端 `navigator`。
3. 资产详情只信任 `grammarStructInfo`，不要继续消费旧 `assetView` 心智。
4. `pair_fork` 已经是正式类型，Hub tab、详情渲染、单点关系加练都要把它当成独立分支处理。
