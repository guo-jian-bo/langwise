# 单元目标句法层四个接口 API 文档

本文只覆盖当前句法层页面直接会用到的 4 个接口：

1. `GET /unit/{unitId}/knowledge/grammar/goals/sentence`
2. `POST /unit/{unitId}/knowledge/grammar/goals/sentence/grammar/recall`
3. `POST /unit/{unitId}/knowledge/grammar/goals/sentence/grammar/from-materials`
4. `GET /algorithm/task/status/{taskId}`

对应源码：

- [CourseKnowledgeController.java](file:///Users/tanrong/Desktop/git/course/course-admin/src/main/java/com/timelywise/course/admin/controller/course/CourseKnowledgeController.java#L250-L272)
- [AlgorithmTaskController.java](file:///Users/tanrong/Desktop/git/course/course-admin/src/main/java/com/timelywise/course/admin/controller/course/task/AlgorithmTaskController.java#L14-L31)
- [CourseUnitGrammarService.java](file:///Users/tanrong/Desktop/git/course/course-admin/src/main/java/com/timelywise/course/admin/service/course/CourseUnitGrammarService.java#L230-L325)
- [unit_sentence.md](file:///Users/tanrong/Desktop/git/docs/course/unit/unit_sentence.md)

---

## 1. 使用场景

这 4 个接口对应句法层里的两块页面：

1. 句法页主包
2. 底栏“添加语法”页

页面链路：

```text
进入句法页
  -> GET /unit/{unitId}/knowledge/grammar/goals/sentence

进入“添加语法”页
  -> 继续使用上面的主包数据渲染左侧句子 / 句组材料
  -> POST /unit/{unitId}/knowledge/grammar/goals/sentence/grammar/recall
  -> POST /unit/{unitId}/knowledge/grammar/goals/sentence/grammar/from-materials
  -> 轮询 GET /algorithm/task/status/{taskId}
```

---

## 2. 通用说明

### 2.1 通用返回结构

所有接口统一返回 `HttpResult<T>`：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `code` | Integer | 成功固定为 `200` |
| `message` | String | 错误信息；成功时通常为空 |
| `data` | T | 业务数据 |

成功示例：

```json
{
  "code": 200,
  "message": null,
  "data": {}
}
```

### 2.2 鉴权与隐式参数

- `/unit/{unitId}/knowledge/**` 是管理台接口，要求 admin 登录态。
- `AdminContext` 由服务端注入，前端不传。
- `unitId` 都是路径参数。

### 2.3 两类 ID 不要混用

| 字段 | 含义 |
| --- | --- |
| `knowledgeUids` | 单元句知识点 uid，对应 `course_unit_knowledges.uid` |
| `sentenceIds` / `hitSentenceIds` / `contentId` | 词典句 uid，不是知识点 uid |
| `setUids` | 签发句组 uid |
| `taskId` / `task_id` | 算法任务 id |

`knowledgeUids` 不能传成词典句 `contentId`。

---

## 3. 接口一：句法页主包

### 3.1 接口定义

```http
GET /unit/{unitId}/knowledge/grammar/goals/sentence
```

### 3.2 请求参数

#### Path 参数

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `unitId` | Long | 是 | 单元 uid |

### 3.3 返回类型

`data` 类型：`CourseUnitSentenceGoalDTO`

#### 顶层字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `unitId` | Long | 当前单元 uid |
| `sentence` | Array\<SentenceItem\> | 当前单元句子列表，供句法页和“添加语法”页左侧直接使用 |
| `groups` | Array\<ContentGrammarUnifiedDTO\> | 由本单元句子反查出的签发句组列表 |
| `grammar` | Grammar | 当前单元句法层语法区块 |

#### `sentence[]`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `unitKnowledgeId` | Long | 单元句知识点 uid，后续 `knowledgeUids` 就传它 |
| `content` | String | 句子文本 |
| `contentId` | Long | 词典句 uid |
| `semanticId` | Long | 语义 id，没有时为 `null` |
| `patternNid` | String | 当前句的句型 nid，没有时可为空 |

#### `groups[]`

这部分是 language 侧统一语法资产结构，当前主包直接透传最小字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `type` | String | 资产类型，常见如 `pattern` / `pair` / `pair_fork` / `paradigm` / `grid` / `pyramid` |
| `nid` | String | 资产 nid |
| `name` | Array\<LanguageText\> | 多语言名称 |
| `description` | Array\<LanguageText\> | 多语言描述 |
| `payload` | Object | 资产详情透传，结构随 `type` 变化 |

#### `LanguageText`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `lang` | String | 语言类型，常见 `zh` / `en` |
| `text` | String | 对应文案 |
POST /course-console/unit/12813/knowledge/grammar/goals/sentence/grammar/from-materials HTTP/1.1
gw-user: {"uid":377980632, "group":"OFFICIAL","userId":42735}
Authorization: Bearer eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJEY2ZGWUU3VFU3amVzRVFGZW9hdjQxenFSR256ZXZHM1N2d3dZMzdiQUpRZGdKNUIiLCJleHAiOjE3OTAyMzg4OTAsInMiOiJ1c2VyIiwidWlkIjozNzc5ODA2MzIsImFwcElkIjoiMjAyNDExMTgwOTE4IiwiaWF0IjoxNzg5NjM0MDkwfQ.KejaYJ1QVVIaYayG8dEmtRiQWBcts8H-kl57pKkV2oPrw5-Pm8VYBzDZjkQ_26Rflh6lI74oFllGLd8SakM6Jg
Content-Type: application/json; charset=utf-8
Host: api-demo.timelywise.cn
Connection: close
User-Agent: /4.5.4 (Macintosh; OS X/26.3.0) GCDHTTPRequest
Content-Length: 118

{"knowledgeUids":["440338"],"setUids":["611"],"assetRefs":[{"kind":"pyramid","nid":"preference_entity_love_hate_np"}]}


#### `grammar`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `outlineId` | Long | 语法大纲 uid；没有 outline 时可能为空 |
| `summary` | String | 大纲摘要 |
| `points` | Array\<OutlinePoint\> | 要点列表 |

#### `grammar.points[]`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `pointOrder` | Integer | 要点序号 |
| `title` | String | 要点标题 |
| `description` | String | 要点说明 |
| `objective` | String | 要点目标 |
| `targets` | Array\<TargetCard\> | 当前要点下的语法卡 |

#### `grammar.points[].targets[]`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `uid` | Long | Target uid |
| `order` | Integer | Target 序号 |
| `status` | String | 状态值 |
| `statusLabel` | String | 状态展示文案 |
| `assetKind` | String | 资产类型 |
| `assetLabel` | String | 资产类型中文名 |
| `assetNid` | String | 资产 nid |
| `title` | String | Target 标题 |
| `setCount` | Integer | 当前 Target 下已存在的句组数量 |

### 3.4 返回示例

```json
{
  "code": 200,
  "data": {
    "unitId": 1001,
    "sentence": [
      {
        "unitKnowledgeId": 901,
        "content": "The boy is eating.",
        "contentId": 5001,
        "semanticId": null,
        "patternNid": "sv_be_doing"
      }
    ],
    "groups": [
      {
        "type": "pair",
        "nid": "ask_answer_basic",
        "name": [
          { "lang": "zh", "text": "基础问答对照" }
        ],
        "description": [
          { "lang": "zh", "text": "由当前单元句子反查得到的句组" }
        ],
        "payload": {}
      }
    ],
    "grammar": {
      "outlineId": 7001,
      "summary": "学习基础句法目标。",
      "points": [
        {
          "pointOrder": 1,
          "title": "现在进行时",
          "description": "理解正在发生的动作。",
          "objective": "能识别并使用 be doing。",
          "targets": [
            {
              "uid": 3001,
              "order": 1,
              "status": "approved",
              "statusLabel": "已通过",
              "assetKind": "pattern",
              "assetLabel": "句型",
              "assetNid": "sv_be_doing",
              "title": "be doing 基础用法",
              "setCount": 2
            }
          ]
        }
      ]
    }
  }
}
```

### 3.5 前端注意点

1. `sentence` 字段名是单数，不是 `sentences`。
2. `groups` 是句组反查结果，不是写进单元表的知识点。
3. 当前实现里，`grammar.points[].targets` 只返回 `approved` 的 Target。
   这意味着“从材料追加语法点”异步成功后，新建的 `candidate` 不会出现在这个接口里，前端不能只刷新这个主包来判断追加结果。

---

## 4. 接口二：从句子与句组召回语法点

### 4.1 接口定义

```http
POST /unit/{unitId}/knowledge/grammar/goals/sentence/grammar/recall
Content-Type: application/json
```

### 4.2 请求体

`data` 类型：`CourseUnitGrammarRecallRequest`

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `knowledgeUids` | Array\<Long\> | 否 | 已选句子的知识点 uid 列表 |
| `setUids` | Array\<Long\> | 否 | 已选句组 uid 列表 |

请求示例：

```json
{
  "knowledgeUids": [901, 902],
  "setUids": [1201]
}
```

### 4.3 约束

按句法层需求：

- `knowledgeUids` 与 `setUids` 不能同时为空。

当前 BFF 行为：

- 会去重并过滤掉 `null`
- 不在本地做“不能都空”的显式校验，而是透传给算法侧处理

所以前端仍应在页面上提前拦截“两路都空”。

### 4.4 返回类型

`data` 类型：`CourseUnitGrammarRecallDTO`

#### 顶层字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `unitId` | Long | 当前单元 uid |
| `selected` | Selected | 本次实际提交的材料 |
| `sentenceIds` | Array\<Long\> | 本次命中的词典句 uid 列表 |
| `assets` | Array\<AssetItem\> | 本次召回出的可追加资产 |

#### `selected`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `knowledgeUids` | Array\<Long\> | 本次使用的知识点 uid |
| `setUids` | Array\<Long\> | 本次使用的句组 uid |

#### `assets[]`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `kind` | String | 资产类型，如 `pattern` / `pair` / `pair_fork` / `paradigm` / `grid` / `pyramid` |
| `nid` | String | 资产 nid |
| `name` | String | 资产显示名；若算法未返回名称，则兜底为 `nid` |
| `hitSentenceIds` | Array\<Long\> | 命中该资产的词典句 uid 列表 |
| `alreadyPresent` | Boolean | 当前单元里是否已存在同 `kind + nid` 的 candidate/approved Target |

### 4.5 返回示例

```json
{
  "code": 200,
  "data": {
    "unitId": 1001,
    "selected": {
      "knowledgeUids": [901, 902],
      "setUids": [1201]
    },
    "sentenceIds": [5001, 5002, 5003],
    "assets": [
      {
        "kind": "pattern",
        "nid": "rel_clause_whom",
        "name": "用 whom 作关系词",
        "hitSentenceIds": [5001, 5002],
        "alreadyPresent": false
      },
      {
        "kind": "pair",
        "nid": "ask_answer_basic",
        "name": "基础问答对照",
        "hitSentenceIds": [5002],
        "alreadyPresent": true
      }
    ]
  }
}
```

### 4.6 前端注意点

1. `sentenceIds` / `hitSentenceIds` 是词典句 uid，不是 `knowledgeUid`。
2. `assets: []` 也是成功态，表示这次没有可追加资产。
3. `alreadyPresent = true` 的资产前端应置灰，不要默认勾选。

---

## 5. 接口三：从材料追加语法点

### 5.1 接口定义

```http
POST /unit/{unitId}/knowledge/grammar/goals/sentence/grammar/from-materials
Content-Type: application/json
```

### 5.2 请求体

`data` 类型：`CourseUnitGrammarFromMaterialsRequest`

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `knowledgeUids` | Array\<Long\> | 否 | 已选句子的知识点 uid 列表 |
| `setUids` | Array\<Long\> | 否 | 已选句组 uid 列表 |
| `assetRefs` | Array\<AssetRef\> | 是 | 本次确认追加的语法资产 |

#### `assetRefs[]`

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `kind` | String | 是 | 资产类型 |
| `nid` | String | 是 | 资产 nid |

请求示例：

```json
{
  "knowledgeUids": [901, 902],
  "setUids": [1201],
  "assetRefs": [
    { "kind": "pattern", "nid": "rel_clause_whom" }
  ]
}
```

### 5.3 当前实现约束

这是前端联调时最重要的一段：

1. `knowledgeUids` 与 `setUids` 不能同时为空
2. `assetRefs` 不能为空
3. `assetRefs` 中每一项都必须同时带 `kind` 和 `nid`
4. `knowledgeUids` 里只能传当前单元的句子知识点 uid
5. 如果本次勾选的资产全都已在本单元存在，接口直接报错 `所选资产已在本单元`

补充说明：

- 句法需求文档里提到“若召回结果恰好只有 1 条，可不传 `asset_refs` 走默认值”，但**当前 BFF 实现没有这个兜底**。
- 所以前端现在必须显式传 `assetRefs`，不要依赖后端自动补默认值。

### 5.4 返回类型

`data` 类型：`AlgorithmTaskStartDTO`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `task_id` | Integer | 算法任务 id，后续轮询就用它 |
| `task_name` | String | 任务名 |
| `status` | String | 启动状态，常见为 `started`，下游已在跑时可能为 `duplicate` |
| `message` | String | 算法返回的提示文案 |

返回示例：

```json
{
  "code": 200,
  "data": {
    "task_id": 88421,
    "task_name": "unit_grammar_from_materials_1001",
    "status": "started",
    "message": "任务已发起"
  }
}
```

### 5.5 这不是最终成功结果

这个接口返回 `200` 只表示：

- 任务启动请求成功到达算法侧
- 或命中了同名运行中任务

它**不代表**：

- Target 已经落库成功
- 句法页已经能看到结果

前端必须继续调用任务状态接口轮询。

### 5.6 常见失败文案

这些是当前 BFF 已经明确抛出的错误，前端可以直接 toast `message`：

| 场景 | 可能返回文案 |
| --- | --- |
| 两路材料都没选 | `knowledgeUids 与 setUids 不能都为空` |
| 没传资产 | `assetRefs不能为空` |
| `assetRefs` 某项缺字段 | `assetRefs不能为空` |
| `knowledgeUids` 里混入非法句子 | `knowledgeUids 中存在非法句子` |
| 勾选资产全都已存在 | `所选资产已在本单元` |

---

## 6. 接口四：查询算法任务状态

### 6.1 接口定义

```http
GET /algorithm/task/status/{taskId}
```

### 6.2 请求参数

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `taskId` | Integer | 是 | 任务 id，必须大于 0 |

### 6.3 返回类型

`data` 类型：`AlgorithmTaskStatusDTO`

#### 顶层字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `uid` | Integer | 任务主键 |
| `task_name` | String | 任务名 |
| `status` | String | 当前任务状态 |
| `started_at` | Date | 开始时间 |
| `finished_at` | Date | 结束时间；未结束时通常为空 |
| `error_message` | String | 失败原因 |
| `task_status` | Map\<String, Integer\> | 子步骤统计，结构由算法侧决定 |
| `extra` | Extra | 任务补充信息 |

#### `extra`

这是通用任务扩展字段，并不是每次都会全部返回。当前 DTO 里已定义的字段如下：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `exercise_id` | Long | 其它任务通用字段，本接口大多不关心 |
| `texts_created` | Integer | 其它任务通用字段 |
| `created_text_uids` | Array\<Long\> | 其它任务通用字段 |
| `created_course_unit_knowledge_uids` | Array\<Long\> | 其它任务通用字段 |
| `errors` | Object | 失败详情 |
| `songs_created` | Long | 其它任务通用字段 |
| `created_song_uids` | Array\<Long\> | 其它任务通用字段 |
| `unitId` | Long | 当前单元 uid |
| `mode` | String | 任务模式 |
| `skipped` | Boolean | 是否被跳过 |
| `onlyDeficit` | Boolean | 是否只处理缺口 |
| `targetCount` | Integer | 目标数量 |
| `createdCount` | Integer | 创建数量 |
| `skippedNoDeficit` | Integer | 因无缺口被跳过的数量 |
| `sentenceCount` | Integer | 句子数量 |
| `maxConcurrency` | Integer | 并发数 |
| `completed` | Integer | 已完成数 |
| `partial` | Integer | 部分完成数 |
| `skippedExisting` | Integer | 因已存在跳过的数量 |
| `failed` | Integer | 失败数量 |

### 6.4 返回示例

```json
{
  "code": 200,
  "data": {
    "uid": 88421,
    "task_name": "unit_grammar_from_materials_1001",
    "status": "finished",
    "started_at": "2026-09-22T15:10:00.000+08:00",
    "finished_at": "2026-09-22T15:10:12.000+08:00",
    "error_message": null,
    "task_status": {
      "completed": 1,
      "failed": 0
    },
    "extra": {
      "unitId": 1001,
      "targetCount": 1,
      "createdCount": 1,
      "completed": 1,
      "failed": 0
    }
  }
}
```

### 6.5 当前前端建议判断逻辑

结合当前服务端回调逻辑，前端按下面规则处理最稳妥：

| `status` | 前端含义 |
| --- | --- |
| `started` | 已启动，继续轮询 |
| `running` | 执行中，继续轮询 |
| `finished` | 成功结束，可以刷新业务页面 |
| 其它状态且带 `error_message` | 视为失败，停止轮询并提示错误 |

服务端现在是按 `status == "finished"` 才认定任务成功。

---

## 7. “添加语法”页异步轮询时序

推荐时序：

```text
1. 进入页面
   -> 读取句法页主包

2. 用户勾选句子 / 句组
   -> 调 recall

3. 用户勾选资产
   -> 调 from-materials

4. 收到 task_id
   -> 轮询 /algorithm/task/status/{taskId}

5. 轮询结果：
   - status = started / running -> 继续轮询
   - status = finished -> 视为成功
   - 其它失败态 -> 停止轮询，toast error_message
```

### 7.1 轮询建议

- 第 1 次轮询：提交成功后 `1s` 发起
- 执行中轮询间隔：`2s`
- 单次页面停留建议超时：`60s`

前端伪代码：

```ts
const startResp = await api.appendGrammarFromMaterials(body);
const taskId = startResp.data.task_id;

while (true) {
  const taskResp = await api.queryAlgorithmTaskStatus(taskId);
  const task = taskResp.data;

  if (task.status === 'finished') {
    break;
  }

  if (task.error_message && task.status !== 'started' && task.status !== 'running') {
    throw new Error(task.error_message);
  }

  await sleep(2000);
}
```

### 7.2 轮询成功后刷新什么

当前实现下，建议这样处理：

1. 若页面要确认任务完成，可先停止 loading
2. 再跳转或刷新语法 Hub 相关页面
3. 不要只刷新 `GET /unit/{unitId}/knowledge/grammar/goals/sentence`

原因：

- 当前主包里的 `grammar.points[].targets` 只包含 `approved`
- `from-materials` 产出的新增 Target 按需求是 `candidate`
- 所以仅刷新句法主包，前端可能会误以为“任务成功了但没有结果”

---

## 8. 前端联调结论

这 4 个接口里，最关键的口径有 3 条：

1. `knowledgeUids` 传的是单元句知识点 uid，不是词典句 uid
2. `from-materials` 返回的是任务启动结果，不是最终落库结果
3. 当前 BFF 实现要求显式传 `assetRefs`，并且句法主包只展示 `approved` Target

如果前端按这 3 条接，联调基本不会跑偏。
