# 写作管线管理端 API 文档（course-admin）

受众：Flutter 前端、管理端前端、业务服务器联调同学。  
范围：覆盖 `course-admin` 中本次新增/修改的写作管线接口，以及范文编辑页直连的 `language-admin` 写接口和模块 V3 单元列表里新增的写作字段。
参考资料：

- [writing_lessons.md](./writing_lessons.md)
- [writing_pipeline_api.md](./writing_pipeline_api.md)
- [writing_pipeline_ui.md](./writing_pipeline_ui.md)

这三份参考文档不做改动；本文件的作用是把管理端接口口径补齐到“前端可直接按文档渲染页面”的程度。

---

## 1. 页面与接口对照

| 页面 | 接口 |
| --- | --- |
| 单元课时页（上方写作管线统计、下方 `WRITING_TASK` 课时卡） | `GET /course/module/{uid}/unit/lesson/list/v3` |
| 写作管线（单元挂载页） | `GET /unit/{unitId}/writing/stage/detail` |
| 写作管线（保存单元挂载） | `POST /unit/{unitId}/writing/mount/save` |
| 写作任务页 | `GET /unit/{unitId}/writing/task/list` |
| 任务编辑器初始化 | `GET /unit/{unitId}/writing/task/editor` |
| 新建任务 | `POST /unit/{unitId}/writing/task/create` |
| 编辑任务 | `POST /unit/{unitId}/writing/task/edit` |
| 从单元移除任务 | `POST /unit/{unitId}/writing/task/remove?taskId=...` |
| 范文新增/编辑页初始化（language-admin） | `GET /write/en/composition/write/exemplar/editor` |
| 范文保存（language-admin） | `POST /write/en/composition/write/exemplar/save` |
| 图片详情查询（language-admin） | `POST /admin/content/review/image/query` |
| 音频详情查询（language-admin） | `POST /admin/audio/review/audio/query` |
| 视频详情查询（language-admin） | `POST /admin/video/review/video/query` |
| AI 写文字范文 | `POST /unit/{unitId}/writing/task/exemplar/generate` |
| 反向处理文字范文 | `POST /unit/{unitId}/writing/task/exemplar/structure` |

注意：

- 删除任务接口当前路由是 `/task/remove`，`taskId` 是 **query param**，不是 path 变量。
- 范文接口分两类：
  - `generate` / `structure`：`course-admin` 对文字题发起异步任务
  - `exemplar/editor` / `exemplar/save`：管理端范文编辑页直连的 `language-admin` 接口；多媒体题支持新建和编辑，文字题当前仅支持编辑已有范文
- 多媒体题如果页面手里只有媒体 uid，需要再调用对应的 `image/query` / `audio/query` / `video/query` 接口换取媒体详情。

---

## 2. 通用约定

### 2.1 返回包装

Controller 统一返回：

```json
{
  "code": 0,
  "message": "OK",
  "data": {}
}
```

本文档主要描述 `data` 里的业务字段。

### 2.2 多语言字段

`LanguageTextDTO`

```json
{
  "lang": "ZH",
  "text": "写作任务"
}
```

常见用法：

- `name`：任务短名
- `stem`：题干
- `stageName`：阶梯名称
- `blueprintName` / `genreName`：蓝图名 / 文类名
- `title`：范文标题

前端通常按当前界面语言取一条；拿不到时可回退第一条非空文本。

### 2.3 作答类型

`answerKind` 当前可见值：

- `text`：文字作答
- `image`：图片作答
- `audio`：音频作答
- `video`：视频作答

`answerKindLable` 是后端直接给前端展示的文案，字段名按当前代码保持这个拼写，不要改名猜测成 `answerKindLabel`。

示例：

- `text` -> `文字作答`
- `image` + `answerMinCount=2` -> `图片 ×2`
- `video` + `answerMinCount=1` -> `视频 ×1`

### 2.4 媒体字段

任务和范文里都会同时出现两套媒体字段：

- `stemImages` / `stemAudios` / `stemVideos`
- `answerImageKeys` / `answerAudioKeys` / `answerVideoKeys`

这些字段存的是**媒体 key**。

如果接口同时返回了 `stemImageUrls` / `stemAudioUrls` / `stemVideoUrls`，则这些是可直接预览的 URL，前端优先用 URL 渲染，保存时仍提交 key。

### 2.5 空值规则

- 列表字段优先返回 `[]`，尽量不返回 `null`
- 单对象不存在时返回 `null`
- `compositionId = null` 表示当前单元没有可直接打开的范文
- `writingId = null` 表示当前单元还没有写作挂载
- `stage = null` 表示当前单元没有挂载阶梯

---

## 3. 单元课时页接口

## 3.1 获取单元课时列表 V3

`GET /course/module/{uid}/unit/lesson/list/v3`

用途：

- 单元课时页顶部“写作管线”统计
- 单元卡上的 `WRITING_TASK` 课时卡

外层结构：

```json
{
  "courseModuleInfo": {},
  "courseUnitList": [
    {
      "uid": 14140,
      "lessonDTOList": [],
      "lessonPlanList": [],
      "writingPipeline": {},
      "writingTaskCard": {}
    }
  ]
}
```

这里只展开本次新增的两个字段。

### 3.1.1 `courseUnitList[].writingPipeline`

类型：`CourseUnitWritingPipelineDTO`

| 字段 | 类型 | 含义 | UI 用途 |
| --- | --- | --- | --- |
| `taskCount` | `Integer` | 当前单元写作任务数 | 课时页上方“任务 n” |
| `compositionTaskCount` | `Integer` | 当前单元**已挂到 join 上**的范文任务数 | 课时页上方“范文 m/n”与进度条 |

说明：

- 这里的 `compositionTaskCount` 统计口径是单元 join 上的 `compositionId`，代表“本单元真正挂上的范文数”。
- 若任务目录里有默认范文，但当前单元 join 没挂，**这里不会计数**。

### 3.1.2 `courseUnitList[].writingTaskCard`

类型：`CourseUnitWritingTaskCardDTO`

| 字段 | 类型 | 含义 | UI 用途 |
| --- | --- | --- | --- |
| `lessonId` | `Long` | `WRITING_TASK` 课时 id | 点击卡片时用于跳转 |
| `type` | `String` | 课时类型，固定为 `WRITING_TASK` | 前端分支渲染写作任务卡 |
| `taskId` | `Long` | 首个任务 id | 管理台进入任务/范文页时可复用 |
| `stageNid` | `String` | 当前展示阶梯 id | 页面状态、跳转蓝图时可用 |
| `stageName` | `List<LanguageTextDTO>` | 当前展示阶梯名称 | 卡片副标题 |
| `stem` | `List<LanguageTextDTO>` | 首任务题干 | 卡片右侧摘要，两行截断 |
| `answerKind` | `String` | 作答类型 | 决定图标和入口 |
| `answerKindLable` | `String` | 作答类型展示文案 | 卡片角标 / 胶囊 |
| `answerMinCount` | `Integer` | 最少作答数量 | 展示“图片 ×N / 视频 ×N” |
| `answerMaxCount` | `Integer` | 最多作答数量 | 当页面要显示区间时可用 |
| `cover` | `String` | 蓝图封面 key | 备用资源标识 |
| `coverUrl` | `String` | 蓝图封面 URL | 卡片左侧封面图 |
| `coverMd5` | `String` | 蓝图封面 md5 | 资源校验/缓存辅助 |
| `taskCount` | `Integer` | 当前单元写作任务数 | 卡片底部“N 个任务” |
| `compositionTaskCount` | `Integer` | 当前单元 join 上已挂范文数 | 管理台卡片底部“范文 m/n” |

说明：

- 该对象的内容来自**当前单元第一个任务**，用于生成 `WRITING_TASK` 课时卡。
- 当前实现里，`writingTaskCard` 只有在“该单元至少有一个任务”时才会返回。
- 所以“已挂阶梯但还没有任务”的空态，前端不能只依赖这个字段，要结合：
  - `lessonDTOList` 中是否存在 `type = WRITING_TASK`
  - `writingPipeline.taskCount == 0`
  - 写作管线详情接口中的 `stage`

---

## 4. 单元挂载接口

## 4.1 获取单元写作挂载详情

`GET /unit/{unitId}/writing/stage/detail`

用途：

- 写作管线第一页整体渲染
- 页头 `任务 n · 范文 m/n`
- 左侧阶梯卡
- 右侧时体语态区

返回：`CourseUnitWritingDetailDTO`

| 字段 | 类型 | 含义 | UI 用途 |
| --- | --- | --- | --- |
| `unitId` | `Long` | 单元 id | 页面上下文 |
| `writingId` | `Long` | 写作挂载 id，可空 | 调试、后续写库上下文 |
| `lessonId` | `Long` | 写作任务课时 id，可空 | 返回课时页、路由拼接 |
| `lessonType` | `String` | 课时类型，可空 | 一般为 `WRITING_TASK` |
| `stage` | `EnCompositionStageItemDTO` | 当前单元挂载阶梯，可空 | 左侧阶梯卡、空态提示 |
| `taskCount` | `Integer` | 当前单元任务数 | 页头统计、“任务 N”按钮 |
| `compositionTaskCount` | `Integer` | 当前页可打开范文的任务数 | 页头“范文 m/n” |
| `grammarScope` | `CourseUnitWritingGrammarScopeDTO` | 当前已选时体语态 code | 右侧胶囊高亮态 |
| `grammarScopeMeta` | `CourseUnitWritingGrammarScopeMetaDTO` | 时体语态展示元数据 | 右侧胶囊中文和完整选项 |
| `source` | `CourseUnitWritingSourceDTO` | 挂载来源，可空 | 页头下方 `project · theme · topic · subTopic` |

说明：

- 这个接口里的 `taskCount`、`compositionTaskCount` 与任务列表页保持同口径，便于前端复用页头统计。
- `grammarScope` 只表达“当前选中了哪些 code”，不带中文。
- `grammarScopeMeta` 用于渲染全部固定选项及中文，当前是后端固定下发，不查业务表。

### 4.1.1 `grammarScope`

`CourseUnitWritingGrammarScopeDTO`

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `time` | `List<String>` | 已选时态 code，如 `present` |
| `aspect` | `List<String>` | 已选体 code，如 `simple` |
| `voice` | `List<String>` | 已选语态 code，如 `active` |

数据来源：

- 读取 `course_unit_writings.grammarScope`

### 4.1.2 `grammarScopeMeta`

`CourseUnitWritingGrammarScopeMetaDTO`

```json
{
  "time": {
    "code": "time",
    "name": "时",
    "options": [
      { "code": "present", "name": "现在" },
      { "code": "past", "name": "过去" },
      { "code": "future", "name": "将来" }
    ]
  },
  "aspect": {
    "code": "aspect",
    "name": "体",
    "options": [
      { "code": "simple", "name": "一般" },
      { "code": "continuous", "name": "进行" },
      { "code": "perfect", "name": "完成" },
      { "code": "perfect_continuous", "name": "完成进行" }
    ]
  },
  "voice": {
    "code": "voice",
    "name": "态",
    "options": [
      { "code": "active", "name": "主动" },
      { "code": "passive", "name": "被动" }
    ]
  }
}
```

说明：

- `time` / `aspect` / `voice` 三个轴都是固定枚举。
- 前端应使用：
  - `grammarScopeMeta` 渲染全部按钮和中文
  - `grammarScope` 判断哪些按钮高亮

### 4.1.3 `source`

`CourseUnitWritingSourceDTO`

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `level` | `String` | 级别来源 |
| `project` | `String` | 项目来源 |
| `theme` | `String` | 主题来源 |
| `topic` | `String` | 话题来源 |
| `subTopic` | `String` | 子话题来源 |

数据来源：

- 读取 `course_unit_writings.source`

## 4.2 保存单元写作挂载

`POST /unit/{unitId}/writing/mount/save`

请求体：`CourseUnitWritingMountSaveRequest`

| 字段 | 必填 | 含义 | 说明 |
| --- | --- | --- | --- |
| `stageNid` | 否 | 目标阶梯 id | 不传时沿用当前挂载 |
| `grammarScope` | 否 | 时体语态范围 | 不传时沿用当前值；传了则按传入覆盖 |

`grammarScope` 结构：

```json
{
  "time": ["present"],
  "aspect": ["simple"],
  "voice": ["active"]
}
```

返回：`CourseUnitWritingDetailDTO`

保存规则：

- 当前单元没有挂载时：新建 `course_unit_writings`
- `stageNid` 不变时：只更新 `grammarScope`，不动任务 join
- `stageNid` 变更时：
  - 更新 `course_unit_writings.stageNid`
  - 当前单元全部非 `DELETED` 的 `course_unit_writing_tasks` 置为 `DELETED`
  - 不删除任务目录
  - 不删除范文目录

说明：

- 这就是“更换阶梯”按钮最终调用的保存接口。
- 阶梯选择列表页本身不依赖这里的读接口，前端拿到目标 `stageNid` 后提交到这里即可。

---

## 5. 写作任务页接口

## 5.1 获取任务列表

`GET /unit/{unitId}/writing/task/list`

用途：

- 写作任务页整体渲染
- 顶部 `任务 n · 范文 m/n`
- 两列任务卡列表

返回：`CourseUnitWritingTaskListDTO`

| 字段 | 类型 | 含义 | UI 用途 |
| --- | --- | --- | --- |
| `unitId` | `Long` | 单元 id | 页面上下文 |
| `writingId` | `Long` | 写作挂载 id，可空 | 调试、后续写库时的挂载上下文 |
| `lessonId` | `Long` | 写作任务课时 id，可空 | 返回课时页、路由拼接 |
| `lessonType` | `String` | 课时类型，可空 | 一般为 `WRITING_TASK` |
| `taskCount` | `Integer` | 列表任务数 | 页头统计 |
| `compositionTaskCount` | `Integer` | 当前页可打开范文的任务数 | 页头“范文 m/n” |
| `taskList` | `List<CourseUnitWritingTaskItemDTO>` | 任务列表 | 任务卡列表 |

说明：

- 这个接口里的 `compositionTaskCount` 是按任务项里的 `compositionId` 统计。
- 任务项 `compositionId` 的口径是：优先当前单元 join 上的 `compositionId`，如果没有，再回退到任务目录默认范文。
- 因此，它和 V3 接口里的 `writingPipeline.compositionTaskCount` 可能不同。  
  前者更接近“这个页面能不能点开范文”，后者更接近“当前单元是否显式挂上了范文”。

### 5.1.1 `taskList[].*`

类型：`CourseUnitWritingTaskItemDTO`

| 字段 | 类型 | 含义 | UI 用途 |
| --- | --- | --- | --- |
| `uid` | `Long` | 当前任务 id | 列表主键、编辑任务、进入范文页 |
| `taskId` | `Long` | 任务 id | 与 `uid` 同值，保留给旧页面兼容读取 |
| `compositionId` | `Long` | 当前页面应打开的范文 id，可空 | 决定显示“写范文”还是“范文” |
| `order` | `Double` | 单元内排序值 | 当前页按接口顺序渲染即可 |
| `cover` | `String` | 蓝图封面 key | 卡片封面资源标识 |
| `coverUrl` | `String` | 蓝图封面 URL | 卡片左侧封面图 |
| `coverMd5` | `String` | 蓝图封面 md5 | 资源缓存辅助 |
| `name` | `List<LanguageTextDTO>` | 任务短名 | 任务卡标题 |
| `stem` | `List<LanguageTextDTO>` | 任务题干 | 任务卡正文 |
| `stageNid` | `String` | 任务所属阶梯 id | 页面状态、筛选或跳转辅助 |
| `stage` | `EnCompositionInstanceStageCardDTO` | 任务所属阶梯轻量结构 | 卡片底部结构条、难度信息 |
| `blueprint` | `EnSentenceSimpleNidDTO` | 所属蓝图轻量信息 | 蓝图角标 |
| `genreNid` | `String` | 所属文类 id | 标签展示 |
| `exemplarCompositionId` | `Long` | 任务目录默认范文 id，可空 | 调试、回退口径说明 |
| `difficulty` | `SubDifficulty` | 任务难度 | 标签展示 |
| `status` | `String` | 学习状态，可空 | 兼容卡片状态渲染 |
| `access` | `String` | 访问权限 | 调试或状态展示 |
| `updated` | `Date` | 更新时间 | 管理端排序/展示辅助 |
| `answerCount` | `Integer` | 当前任务作答份数 | 卡片和编辑页回填 |

说明：

- `task/list` 这条接口返回的是任务卡列表数据，不会下发编辑态才需要的这些字段：
  - `stemImages` / `stemImageUrls`
  - `stemAudios` / `stemAudioUrls`
  - `stemVideos` / `stemVideoUrls`
  - `knowledgePoints`
  - `grammarTargetUids`
- 这些字段请从任务编辑器初始化接口或新建 / 编辑任务的返回值里读取。

---

## 6. 阶梯对象

当前文档里会出现两种阶梯结构，字段不要混用。

### 6.1 挂载页 / 编辑器顶部阶梯

类型：`EnCompositionStageItemDTO`

| 字段 | 类型 | 含义 | UI 用途 |
| --- | --- | --- | --- |
| `nid` | `String` | 阶梯 id | 页面状态、跳蓝图 |
| `name` | `List<LanguageTextDTO>` | 阶梯名称 | 页头、顶部只读卡片 |
| `description` | `List<LanguageTextDTO>` | 阶梯说明 | 说明文案 |
| `cover` | `String` | 封面 key | 资源标识 |
| `coverUrl` | `String` | 封面 URL | 阶梯卡封面 |
| `coverMd5` | `String` | 封面 md5 | 资源缓存辅助 |
| `compositionBlueprintNid` | `String` | 蓝图 id | “蓝图”按钮 |
| `compositionBlueprint` | `CompositionBlueprintDTO` | 蓝图轻量对象 | 蓝图名和补充说明 |
| `genreNid` | `String` | 文类 id | 标签展示 |
| `difficulty` | `SubDifficulty` | 难度 | 标签展示 |
| `answerKind` | `String` | 作答类型 | 控制任务编辑器、范文入口类型 |
| `answerMinCount` | `Integer` | 最少作答数量 | 份数选择默认值和下限 |
| `answerMaxCount` | `Integer` | 最多作答数量 | 份数选择上限 |
| `headFill` | `String` | 文首填法 | 结构展示 |
| `tailFill` | `String` | 文尾填法 | 结构展示 |
| `slots` | `List<EnCompositionStageSlotDTO>` | 阶梯槽位定义 | 起承转合结构展示 |

### 6.2 任务卡里的轻量阶梯

类型：`EnCompositionInstanceStageCardDTO`

| 字段 | 类型 | 含义 | UI 用途 |
| --- | --- | --- | --- |
| `nid` | `String` | 阶梯 id | 卡片状态 |
| `name` | `List<LanguageText>` | 阶梯名称 | 卡片底部说明 |
| `compositionBlueprintNid` | `String` | 蓝图 id | 蓝图跳转辅助 |
| `difficulty` | `SubDifficulty` | 难度 | 卡片标签 |
| `answerKind` | `String` | 作答类型 | 答案形式图标与文案 |
| `answerMinCount` | `Integer` | 最少作答数量 | “1-3 份”区间下限 |
| `answerMaxCount` | `Integer` | 最多作答数量 | “1-3 份”区间上限 |
| `headFill` | `String` | 文首填法 | 结构条展示 |
| `tailFill` | `String` | 文尾填法 | 结构条展示 |
| `hasHead` | `Boolean` | 是否存在文首 | 前端结构分支 |
| `headName` | `List<LanguageText>` | 文首名称 | 结构条展示 |
| `hasTail` | `Boolean` | 是否存在文尾 | 前端结构分支 |
| `tailName` | `List<LanguageText>` | 文尾名称 | 结构条展示 |
| `slots` | `List<EnCompositionInstanceStageSlotDTO>` | 轻量槽位列表 | 卡片结构预览 |

---

## 7. 任务编辑器接口

## 7.1 获取任务编辑页初始化数据

`GET /unit/{unitId}/writing/task/editor`

query:

| 参数 | 必填 | 含义 |
| --- | --- | --- |
| `taskId` | 否 | 传了表示编辑，不传表示新建 |

返回：`CourseUnitWritingTaskEditorPageDTO`

| 字段 | 类型 | 含义 | UI 用途 |
| --- | --- | --- | --- |
| `unitId` | `Long` | 单元 id | 页面上下文 |
| `writingId` | `Long` | 写作挂载 id，可空 | 页面上下文 |
| `stage` | `EnCompositionStageItemDTO` | 当前挂载阶梯，可空 | 第一步顶部只读阶梯卡 |
| `pendingTargetCount` | `Integer` | 待审核语法 Target 数 | 提示“还有多少待审核 target” |
| `task` | `CourseUnitWritingTaskItemDTO` | 正在编辑的任务数据 | 表单回填 |
| `knowledgeList` | `List<CourseUnitWritingKnowledgeItemDTO>` | 当前单元可选知识点 | 第三步知识点选择区 |
| `grammarTargetList` | `List<CourseUnitWritingGrammarTargetItemDTO>` | 当前单元已审核 Target | 第三步语法选择区 |
| `unitWriting` | `CourseUnitWritingDetailDTO` | 当前单元写作挂载详情 | 编辑页顶部统计、来源、时体语态窗口复用 |

说明：

- 编辑模式：`task` 为真实任务数据。
- 新建模式：`task` 不是 `null`，而是一份空对象，便于前端直接绑定表单。
- 新建模式下，如果当前阶梯不是 `text`，后端会给 `task.answerCount` 一个默认值：
  - 优先取 `stage.answerMinCount`
  - 若取不到则默认 `1`
- `task` 在这个接口里是“编辑态任务对象”，实际返回字段以表单回填所需为主，主要包括：
  - `uid` / `taskId` / `compositionId` / `order`
  - `name` / `stem` / `answerCount`
  - `stemImages` / `stemImageUrls`
  - `stemAudios` / `stemAudioUrls`
  - `stemVideos` / `stemVideoUrls`
  - `knowledgePoints` / `grammarTargetUids`
- 这里不会额外返回任务列表卡里的 `cover` / `stage` / `blueprint` / `genreNid` / `status` / `access` / `updated`。

### 7.1.1 `knowledgeList[].*`

`CourseUnitWritingKnowledgeItemDTO`

| 字段 | 类型 | 含义 | UI 用途 |
| --- | --- | --- | --- |
| `uid` | `Long` | 单元知识点行 id | 调试定位 |
| `contentType` | `String` | 内容类型 | 区分单词 / 短语 |
| `contentId` | `Long` | 词典内容 id | 与任务已选 `knowledgePoints` 对齐 |
| `semanticId` | `Long` | 义项 id | 与任务已选 `knowledgePoints` 对齐 |
| `content` | `String` | 展示文案 | 选择器主文案 |
| `definition` | `String` | 释义 | 选择器副文案 |

### 7.1.2 `grammarTargetList[].*`

`CourseUnitWritingGrammarTargetItemDTO`

| 字段 | 类型 | 含义 | UI 用途 |
| --- | --- | --- | --- |
| `uid` | `Long` | Target id | 勾选值 |
| `title` | `List<LanguageTextDTO>` | Target 标题 | 语法 Target 展示 |
| `kindTitle` | `String` | 语法资产类型中文名 | 前端直接展示类型标签，如“句型蓝图” |

## 7.2 新建任务

`POST /unit/{unitId}/writing/task/create`

请求体：`CourseUnitWritingTaskSaveRequest`

| 字段 | 必填 | 含义 | 说明 |
| --- | --- | --- | --- |
| `taskId` | 否 | 新建时不传 | 可留空 |
| `name` | 是 | 任务名称 | 中文至少一条有效文本 |
| `stem` | 是 | 任务题干 | 中文至少一条有效文本 |
| `stageNid` | 否 | 阶梯 id | 只有当前单元还没挂阶梯时，才作为兜底建挂载使用 |
| `answerCount` | 视阶梯而定 | 作答份数 | 非文字题通常需要 |
| `stemImages` | 否 | 题面图片 key 列表 | 保存 key，不传 URL |
| `stemAudios` | 否 | 题面音频 key 列表 | 同上 |
| `stemVideos` | 否 | 题面视频 key 列表 | 同上 |
| `knowledgePoints` | 否 | 已勾选知识点 | 不传或空数组表示不单独圈定 |
| `grammarTargetUids` | 否 | 已勾选语法 Target | 不传或空数组表示不单独圈定 |
| `dropExemplar` | 否 | 是否解除当前单元挂载范文 | 新建时通常传 `false` 或不传 |

返回：`CourseUnitWritingTaskItemDTO`

补充说明：

- 如果当前单元还没挂写作阶梯，后端会用 `stageNid` 兜底创建挂载。
- 如果当前单元已经有挂载，保存任务时不会改挂载阶梯。
- 返回体是“编辑态任务对象”，字段口径与 `GET /unit/{unitId}/writing/task/editor` 里的 `task` 一致，
  用于前端保存后直接回填表单，不是任务列表卡完整结构。

## 7.3 编辑任务

`POST /unit/{unitId}/writing/task/edit`

请求体仍为 `CourseUnitWritingTaskSaveRequest`，但：

- `taskId` 必填

返回：`CourseUnitWritingTaskItemDTO`

`dropExemplar` 说明：

- 当前端已明确要解除当前单元挂载范文时，可主动传 `true`
- 当前实现不会再额外做“读取旧范文详情后自动判失效再清理”的回填校验，是否解除挂载以本次保存入参和语言侧任务保存结果为准
- 返回体同样是“编辑态任务对象”，字段口径与任务编辑器里的 `task` 一致。

---

## 8. 删除任务接口

`POST /unit/{unitId}/writing/task/remove`

query:

| 参数 | 必填 | 含义 |
| --- | --- | --- |
| `taskId` | 是 | 要从当前单元移除的任务 id |

返回：

```json
"OK"
```

语义：

- 这是“**从当前单元移除任务**”，不是删除任务目录数据
- 实际行为是把当前单元对应 join 标记为 `DELETED`
- 不删除任务本身
- 不删除范文本身
- 如果任务本来就不在当前单元，或已经删过，接口直接返回 `OK`

前端按钮文案应按“删除任务 / 从本单元移除任务”理解，不要理解成永久删除。

---

## 9. 范文接口

## 9.1 获取范文新增/编辑页初始化数据

`GET /write/en/composition/write/exemplar/editor`

query:

| 参数 | 必填 | 含义 | 说明 |
| --- | --- | --- | --- |
| `taskId` | 是 | 写作任务 id | 不传会报 `taskId不能为空` |
| `unitId` | 否 | 单元 id | 文字题且传了 `unitId` 时，后端会补充单元维度知识点、语法 Target 和 `unitWriting` |
| `exemplarCompositionId` | 否 | 要编辑的范文 id | 不传表示新增页；传了表示编辑已有范文 |

返回：`EnCompositionExemplarEditorDTO`

| 字段 | 类型 | 含义 | UI 用途 |
| --- | --- | --- | --- |
| `unitId` | `Long` | 单元 id，可空 | 页面上下文 |
| `taskId` | `Long` | 任务 id | 页面上下文 |
| `data` | `EnCompositionDetailDTO` | 当前页面主数据 | 新增时作为任务基线数据，编辑时作为范文详情 |
| `knowledgeList` | `List<CourseUnitWritingKnowledgeItemDTO>` | 单元维度可选知识点，可空 | 文字题范文页知识点选择区 |
| `grammarTargetList` | `List<CourseUnitWritingGrammarTargetItemDTO>` | 单元维度可选语法 Target，可空 | 文字题范文页语法选择区 |
| `unitWriting` | `CourseUnitWritingDetailDTO` | 当前单元写作挂载详情，可空 | 顶部统计、来源、时体语态窗口复用 |

说明：

- `data` 字段统一复用 `EnCompositionDetailDTO`。
- 不传 `exemplarCompositionId` 时，`data` 返回当前任务详情，用来给新增页做默认回填。
- 传了 `exemplarCompositionId` 时，`data` 返回当前范文详情；若该范文不在当前任务上，会直接报错。
- 只有在 `unitId` 有值且任务是 `text` 时，后端才会补 `knowledgeList`、`grammarTargetList`、`unitWriting`。
- `knowledgeList`、`grammarTargetList` 的字段口径与 [7.1.1](#711-knowledgelist) / [7.1.2](#712-grammartargetlist) 一致；`unitWriting` 的字段口径与 [4.1](#41-获取单元写作挂载详情) 一致。

`data` 里前端最常用的字段如下：

| 字段 | 类型 | 含义 | UI 用途 |
| --- | --- | --- | --- |
| `uid` | `Long` | 当前详情对象 id | 编辑已有范文时可作为 `compositionId` |
| `taskId` | `Long` | 关联任务 id | 保存时回传 |
| `title` | `List<LanguageTextDTO>` | 范文标题 | 多媒体范文页标题输入框回填 |
| `name` | `List<LanguageTextDTO>` | 任务短名 | 页头任务名 |
| `stem` | `List<LanguageTextDTO>` | 任务题干 | 左侧题干区 |
| `stageNid` | `String` | 阶梯 id | 页面状态 |
| `stage` | `EnCompositionStageDTO` | 阶梯详情 | 读取 `answerKind`、份数窗口等 |
| `answerCount` | `Integer` | 作答份数 | 多媒体范文上传数量提示 |
| `stemImages` / `stemImageUrls` | `List<String>` | 题面图片 key / URL | 题面素材展示 |
| `stemAudios` / `stemAudioUrls` | `List<String>` | 题面音频 key / URL | 题面素材展示 |
| `stemVideos` / `stemVideoUrls` | `List<String>` | 题面视频 key / URL | 题面素材展示 |
| `answerImageKeys` | `List<String>` | 图片型范文答案 key | 编辑已有图片范文时回填 |
| `answerAudioKeys` | `List<String>` | 音频型范文答案 key | 编辑已有音频范文时回填 |
| `answerVideoKeys` | `List<String>` | 视频型范文答案 key | 编辑已有视频范文时回填 |
| `knowledgePoints` | `List<KnowledgePoint>` | 任务当前勾选知识点 | 文字题默认勾选态 |
| `grammarTargetUids` | `List<Long>` | 任务当前勾选语法 Target | 文字题默认勾选态 |

## 9.2 根据 uid 查询媒体详情

这 3 条接口都来自 `language-admin` 的审核模块，作用一致：

- 根据媒体 uid 查询对应媒体详情
- 适用于多媒体范文编辑页里“已选媒体回填 / 预览”
- 这里的 `imageId` / `audioId` / `videoId` 就是对应媒体 uid，只是沿用了审核模块原有参数命名

### 9.2.1 查询图片信息

`POST /admin/content/review/image/query`

query:

| 参数 | 必填 | 含义 | 说明 |
| --- | --- | --- | --- |
| `imageId` | 是 | 图片 uid | 用 uid 查询单张图片详情 |

返回：`ImageDTO`

说明：

- 适用于图片型范文，按图片 uid 回查图片详情。
- 返回体是通用图片 DTO，前端按现有图片模块口径读取即可。

### 9.2.2 查询音频信息

`POST /admin/audio/review/audio/query`

query:

| 参数 | 必填 | 含义 | 说明 |
| --- | --- | --- | --- |
| `audioId` | 是 | 音频 uid | 用 uid 查询单条音频详情 |

返回：`AudioDTO`

说明：

- 适用于音频型范文，按音频 uid 回查音频详情。
- 返回体是通用音频 DTO，前端按现有音频模块口径读取即可。

### 9.2.3 查询视频信息

`POST /admin/video/review/video/query`

query:

| 参数 | 必填 | 含义 | 说明 |
| --- | --- | --- | --- |
| `videoId` | 是 | 视频 uid | 用 uid 查询单条视频详情 |

返回：`VideoDTO`

说明：

- 适用于视频型范文，按视频 uid 回查视频详情。
- 返回体是通用视频 DTO，前端按现有视频模块口径读取即可。

## 9.3 保存范文

`POST /write/en/composition/write/exemplar/save`

请求体：`EnCompositionExemplarSaveRequest`

| 字段 | 必填 | 含义 | 说明 |
| --- | --- | --- | --- |
| `unitId` | 否 | 单元 id | 传了则保存成功后会自动挂到当前单元任务上 |
| `compositionId` | 按题型 | 范文 id | 多媒体题不传表示新建；文字题必传，且只支持编辑已有范文 |
| `taskId` | 是 | 关联任务 id | 不传会报 `taskId不能为空` |
| `title` | 是 | 范文标题 | 至少要有一条有效多语言文本 |
| `headText` | 文字题按需 | 范文文首 | 仅 `text` 题使用；关卡要求文首时不能为空 |
| `tailText` | 文字题按需 | 范文文尾 | 仅 `text` 题使用；关卡要求文尾时不能为空 |
| `paragraphs` | 文字题是 | 正文段列表 | 仅 `text` 题使用，`index` 必须从 `0` 连续，数量必须与当前范文成员段一致 |
| `answerImageKeys` | 按题型 | 图片答案 key 列表 | 仅 `image` 题使用，数量必须等于任务 `answerCount` |
| `answerAudioKeys` | 按题型 | 音频答案 key 列表 | 仅 `audio` 题使用，数量必须等于任务 `answerCount` |
| `answerVideoKeys` | 按题型 | 视频答案 key 列表 | 仅 `video` 题使用，数量必须等于任务 `answerCount` |

返回：`EnCompositionDetailDTO`

说明：

- 多媒体题：
  - 支持 `image` / `audio` / `video`
  - 后端只会读取与当前 `answerKind` 对应的那一组媒体 key，其他组即使传了也不会生效
  - 编辑时如果 `compositionId` 不属于当前 `taskId`，接口会报 `范文不属于当前任务`
  - 如果任务目录当前还没有默认范文，首次保存成功后会把这篇范文写回任务的 `exemplarCompositionId`
- 文字题：
  - 当前只支持编辑已有范文，不支持在这条接口里新建
  - `compositionId` 必须等于当前任务已挂的范文，否则会报 `文字范文仅支持编辑当前任务已挂范文`
  - 段落正文改动后，后端会清空该段现有的 `beatSpans` 和 `anchors`，由后续链路再处理结构化标注
- 如果传了 `unitId`，保存成功后会自动把当前范文重新挂到本单元任务上。

## 9.4 AI 写文字范文

`POST /unit/{unitId}/writing/task/exemplar/generate`

请求体：`CourseUnitWritingExemplarGenerateRequest`

| 字段 | 必填 | 含义 | 说明 |
| --- | --- | --- | --- |
| `taskId` | 是 | 任务 id | 必须属于当前单元，且任务作答类型必须为 `text` |
| `knowledgePoints` | 否 | 本次 AI 写范文指定知识点范围 | 不传则沿用任务配置；传空数组表示显式不圈定 |
| `grammarTargetUids` | 否 | 本次 AI 写范文指定语法点范围 | 不传则沿用任务配置；传空数组表示显式不圈定 |

返回：`String`

返回文案口径：

- 成功发起后返回类似：`AI写范文任务已发起，taskID:123456`

说明：

- 这是异步任务启动接口，不会同步返回范文正文。
- 仅文字题可调用；图片 / 音频 / 视频题型请走 [9.1](#91-获取范文新增编辑页初始化数据) / [9.3](#93-保存范文)。

## 9.5 反向处理文字范文

`POST /unit/{unitId}/writing/task/exemplar/structure`

请求体：`CourseUnitWritingExemplarStructureRequest`

| 字段 | 必填 | 含义 | 说明 |
| --- | --- | --- | --- |
| `taskId` | 是 | 任务 id | 必须属于当前单元，且任务作答类型必须为 `text` |
| `text` | 是 | 教研贴入的英文原文 | 长度不能超过 `20000` |

返回：`String`

返回文案口径：

- 成功发起后返回类似：`反向处理范文任务已发起，taskID:123456`

说明：

- 这同样是异步任务启动接口。
- 接口只负责发起结构化任务，不同步返回解析结果。


---

## 10. 前端落地建议

## 10.1 单元课时页

调用 `GET /course/module/{uid}/unit/lesson/list/v3` 后：

1. 顶部“写作管线”统计取 `courseUnitList[].writingPipeline`
2. 下方 `WRITING_TASK` 卡片取 `courseUnitList[].writingTaskCard`
3. `writingTaskCard == null` 且 `writingPipeline.taskCount == 0` 时，按“还没有写作任务”空态处理

## 10.2 写作管线页

调用 `GET /unit/{unitId}/writing/stage/detail` 后：

1. 页头统计取 `taskCount`、`compositionTaskCount`
2. 左侧阶梯卡取 `stage`
3. 右侧当前高亮取 `grammarScope`
4. 右侧全部按钮和中文取 `grammarScopeMeta`
5. 页头来源文案取 `source`

保存时调：

`POST /unit/{unitId}/writing/mount/save`

场景：

- 只改时体语态：`stageNid` 传当前值，`grammarScope` 传最新值
- 更换阶梯：`stageNid` 传新值，`grammarScope` 一般沿用当前值或传前端当前态

## 10.3 写作任务页

调用 `GET /unit/{unitId}/writing/task/list` 后：

1. 页头统计取 `taskCount`、`compositionTaskCount`
2. 每张任务卡取 `taskList[]`
3. `taskItem.compositionId` 有值则显示“范文”，没有值则显示“写范文”
4. 若页面还需要展示当前挂载阶梯，请复用挂载详情接口或编辑器初始化里的 `stage / unitWriting.stage`，不要假设任务列表外层会返回 `stage`

## 10.4 任务编辑器

先调 `GET /task/editor`：

- 新建：不传 `taskId`
- 编辑：传 `taskId`

页面如果需要顶部统计、来源、时体语态窗口，可直接复用返回里的 `unitWriting`，不需要再额外拼装。

保存：

- 新建调 `POST /task/create`
- 编辑调 `POST /task/edit`

## 10.5 删除任务

点击“删除任务”后调：

`POST /unit/{unitId}/writing/task/remove?taskId={taskId}`

成功后刷新任务列表。

## 10.6 范文动作

根据任务作答类型分流调用：

- 多媒体题进入新增/编辑页：先调 `GET /write/en/composition/write/exemplar/editor`
- 多媒体题如果只有媒体 uid、还需要拉详情：调对应的 `POST /admin/content/review/image/query`、`POST /admin/audio/review/audio/query`、`POST /admin/video/review/video/query`
- 多媒体题保存：调 `POST /write/en/composition/write/exemplar/save`
- 文字题保存已有范文：调 `POST /write/en/composition/write/exemplar/save`
- 文字题，要让 AI 生成范文：调 `POST /task/exemplar/generate`
- 文字题，要把教研贴入原文做结构化处理：调 `POST /task/exemplar/structure`

其中：

- 多媒体题不要走 `generate` / `structure`
- 文字题不要用这条接口新建范文，只能编辑当前任务已挂范文
- `generate` / `structure` 都是异步任务启动接口，前端应展示“任务已发起”类提示
- `exemplar/save` 是同步保存接口，成功后可直接用返回体回填当前页

---

## 10. 当前实现口径补充

这些点建议前后端联调时特别注意：

1. `answerKindLable` 字段名按当前后端实现就是这个拼写。  
   前端请直接使用这个字段，不要自行改成别的名字。

2. V3 接口里的 `writingPipeline.compositionTaskCount`，和任务列表接口里的 `compositionTaskCount`，统计口径不完全相同。  
   前者偏“当前单元是否已挂范文”，后者偏“当前任务页能否打开范文”。

3. `writingTaskCard` 当前实现依赖“至少有一个任务”。  
   所以“已挂阶梯但暂无任务”时，前端不能假设这个对象一定存在。

4. 删除任务接口是软删除 join。  
   UI 上适合展示“从本单元移除”，不适合展示“永久删除”。

5. 范文接口已经按“文字题异步任务”和“多媒体题同步编辑”两条链路拆开。
   前端联调时先根据 `answerKind` 分流，不要把 `text` 和多媒体题走混。
