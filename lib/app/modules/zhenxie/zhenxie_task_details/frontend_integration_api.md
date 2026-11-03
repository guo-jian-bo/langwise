# 写作前端对接 API

本文档只描述当前代码实现，供前端联调用。  
不修改也不替代 [`api.md`](file:///Users/tanrong/Desktop/git/docs/study/writing_review/api.md)，如与初始设计稿存在差异，以当前代码行为为准。

覆盖接口：

### language-app 接口

1. `GET /write/zhenxie/composition/task/detail`

### course-app 接口

1. `POST /course/write/target/list`

### study-app 接口

1. `POST /composition/tasks/{taskId}/draft`
2. `POST /composition/tasks/{taskId}/submit`
3. `POST /composition/tasks/{taskId}/review/{writingId}/retry`
4. `POST /composition/tasks/{taskId}/rewrite`

---

## 1. 通用约定

### 1.1 认证

以上接口都需要登录态，使用现有 `@Authenticate` 鉴权。

### 1.2 响应包裹

统一返回：

```json
{
  "code": 200,
  "message": "OK",
  "data": {}
}
```

下文只展开 `data`。

### 1.3 时间字段

文档中的时间字段均按服务端实际序列化结果返回，前端按 ISO 时间字符串处理即可。

### 1.4 多语言文案结构

`LanguageText` 统一结构：

```json
{
  "lang": "en",
  "text": "Low-carbon life"
}
```

常见 `lang` 值：`en`、`zh`。

### 1.5 简单词条结构

`EnSentenceSimpleNidDTO` 统一结构：

```json
{
  "nid": "narrative",
  "name": [{ "lang": "zh", "text": "记叙文" }],
  "description": [{ "lang": "zh", "text": "..." }]
}
```

---

## 2. 接口总览

> 前端联调时请注意区分服务归属：
>
> - `GET /write/zhenxie/composition/task/detail` 是 **language-app** 接口
> - `POST /course/write/target/list` 是 **course-app** 接口
> - `POST /composition/tasks/...` 这一组都是 **study-app** 接口

| 端 | 接口 | 用途 |
| --- | --- | --- |
| language-app | `GET /write/zhenxie/composition/task/detail?taskId={taskId}` | 获取写作任务壳数据，并聚合当前用户的写作/批改数据 |
| course-app | `POST /course/write/target/list` | 按 target ID 列表批量查询语法 Target 简要信息 |
| study-app | `POST /composition/tasks/{taskId}/draft` | 暂存当前作答 |
| study-app | `POST /composition/tasks/{taskId}/submit` | 提交并发起批改 |
| study-app | `POST /composition/tasks/{taskId}/review/{writingId}/retry` | 对指定提交记录重新发起批改 |
| study-app | `POST /composition/tasks/{taskId}/rewrite` | 从批改页进入重写态 |

---

## 3. language-app：写作任务详情

### 3.1 接口

`GET /write/zhenxie/composition/task/detail`

### 3.2 查询参数

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `taskId` | `number` | 是 | 写作任务 ID |

### 3.3 返回说明

这个接口返回的是一个聚合 DTO：

- language 侧返回任务壳、关卡、蓝图、题干、资料等固定信息
- study 侧聚合当前用户的历史批改记录和当前选中习作

当前代码里，study 用户态是通过 `study-app` 的 `member/detail` 接口聚合进来的。  
如果 study 侧查询失败，`memberReviewHistory` 和 `memberWriting` 可能为 `null`。

### 3.4 返回字段

#### 顶层字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `uid` | `number` | 当前写作任务对应的篇章实例/详情主键 |
| `title` | `LanguageText[]` | 范文标题 |
| `compositionBlueprintNid` | `string` | 蓝图 nid |
| `blueprint` | `CompositionBlueprintDTO` | 蓝图完整信息 |
| `compositionFamilyNid` | `string` | 写作目标 nid |
| `compositionFamily` | `EnCompositionInstanceFamilyDTO` | 写作目标信息 |
| `frameworkNid` | `string` | 文类壳 nid |
| `framework` | `EnSentenceSimpleNidDTO` | 文类壳信息 |
| `skinNid` | `string` | 皮肤 nid |
| `skin` | `EnSentenceSimpleNidDTO` | 皮肤信息 |
| `topicNid` | `string` | 主题 nid |
| `difficulty` | `object` | 难度区间对象 |
| `tier` | `number` | 档位 |
| `headText` | `LanguageText[]` | 题面/范文文首文本 |
| `tailText` | `LanguageText[]` | 题面/范文文尾文本 |
| `members` | `object[]` | 原始成员段数据，偏排查用 |
| `memberList` | `EnCompositionInstanceMemberDTO[]` | 前端展示用段落成员列表 |
| `taskId` | `number` | 写作任务 ID |
| `exemplarCompositionId` | `number` | 任务挂载的范文 ID |
| `name` | `LanguageText[]` | 写作任务名称 |
| `stem` | `LanguageText[]` | 题干文本 |
| `stemImages` | `string[]` | 题干图片 key 列表 |
| `stemImageUrls` | `string[]` | 题干图片 URL 列表 |
| `stemVideos` | `string[]` | 题干视频 key 列表 |
| `stemVideoUrls` | `string[]` | 题干视频 URL 列表 |
| `stemAudios` | `string[]` | 题干音频 key 列表 |
| `stemAudioUrls` | `string[]` | 题干音频 URL 列表 |
| `answerCount` | `number` | 多媒体题要求提交份数；文字题通常为 `null` |
| `knowledgePoints` | `object[]` | 任务绑定的知识点列表 |
| `grammarTargetUids` | `number[]` | 任务绑定的语法目标 UID 列表 |
| `stageNid` | `string` | 关卡 nid |
| `stage` | `EnCompositionStageDTO` | 关卡详情 |
| `answerImageKeys` | `string[]` | 范文图片答案 key |
| `answerImageUrls` | `string[]` | 范文图片答案 URL |
| `answerVideoKeys` | `string[]` | 范文视频答案 key |
| `answerVideoUrls` | `string[]` | 范文视频答案 URL |
| `answerAudioKeys` | `string[]` | 范文音频答案 key |
| `answerAudioUrls` | `string[]` | 范文音频答案 URL |
| `access` | `string` | 访问权限 |
| `in_course` | `boolean` | 是否已入课 |
| `in_course_cnt` | `number` | 入课次数 |
| `source` | `string` | 来源标记 |
| `created` | `string` | 创建时间 |
| `updated` | `string` | 更新时间 |
| `memberReviewHistory` | `ReviewHistoryDTO[]` | 当前成员批改历史 |
| `memberWriting` | `MemberCompositionWritingDTO` | 当前成员当前选中的作答详情 |

#### `stage` 字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `nid` | `string` | 关卡 nid |
| `name` | `LanguageText[]` | 关卡名称 |
| `description` | `LanguageText[]` | 关卡说明 |
| `compositionBlueprintNid` | `string` | 关联蓝图 nid |
| `cover` | `string` | 封面资源 key |
| `coverUrl` | `string` | 封面 URL |
| `coverMd5` | `string` | 封面 md5 |
| `compositionBlueprint` | `CompositionBlueprintDTO` | 蓝图详情 |
| `difficulty` | `object` | 难度区间 |
| `answerKind` | `string` | 作答类型：`text` / `image` / `audio` / `video` |
| `answerMinCount` | `number` | 最少作答数量 |
| `answerMaxCount` | `number` | 最多作答数量 |
| `lockBlueprintTab` | `boolean` | 是否锁蓝图说明 |
| `lockExemplarView` | `boolean` | 是否锁范文查看 |
| `slots` | `EnCompositionStageSlotDTO[]` | 关卡槽位列表 |
| `headFill` | `string` | 文首填法：典型值 `write` / `given` / `hidden` |
| `tailFill` | `string` | 文尾填法：典型值 `write` / `given` / `hidden` |
| `order` | `number` | 排序 |
| `milestones` | `string[]` | 里程碑 nid 列表 |
| `milestoneList` | `EnSentenceSimpleNidDTO[]` | 里程碑详情 |
| `learnedCount` | `number` | 已学习数量 |
| `taskCount` | `number` | 任务总数 |
| `system` | `boolean` | 是否系统内置 |
| `enabled` | `boolean` | 是否启用 |
| `created` | `string` | 创建时间 |
| `updated` | `string` | 更新时间 |

#### `stage.slots[]` 字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `order` | `number` | 槽位顺序 |
| `beatNid` | `string` | 拍位 nid |
| `paragraphTypeNid` | `string` | 段型 nid |
| `paragraphType` | `EnSentenceSimpleNidDTO` | 段型详情 |
| `fill` | `string` | 填法：`given` / `write` / `hidden` |

#### `blueprint` 字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `nid` | `string` | 蓝图 nid |
| `coverUrl` | `string` | 蓝图封面 URL |
| `name` | `LanguageText[]` | 蓝图名称 |
| `description` | `LanguageText[]` | 蓝图说明 |
| `compositionFamilyNid` | `string` | 写作目标 nid |
| `frameworkNid` | `string` | 文类壳 nid |
| `framework` | `EnSentenceSimpleNidDTO` | 文类壳详情 |
| `skinNid` | `string` | 皮肤 nid |
| `skin` | `EnSentenceSimpleNidDTO` | 皮肤详情 |
| `difficulty` | `object` | 难度区间 |
| `order` | `number` | 排序 |
| `minParagraphCount` | `number` | 最少段数 |
| `maxParagraphCount` | `number` | 最多段数 |
| `frame` | `CompositionBlueprintFrameDTO` | 文首/文尾框架信息 |
| `slots` | `CompositionBlueprintSlotDTO[]` | 蓝图拍位列表 |
| `system` | `boolean` | 是否系统内置 |
| `enabled` | `boolean` | 是否启用 |
| `created` | `string` | 创建时间 |
| `updated` | `string` | 更新时间 |

#### `blueprint.frame` 字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `hasHead` | `boolean` | 是否有文首 |
| `hasTail` | `boolean` | 是否有文尾 |
| `hasHeadings` | `boolean` | 正文是否允许小标题 |
| `headName` | `LanguageText[]` | 文首名称 |
| `headDescription` | `LanguageText[]` | 文首说明 |
| `tailName` | `LanguageText[]` | 文尾名称 |
| `tailDescription` | `LanguageText[]` | 文尾说明 |

#### `blueprint.slots[]` 字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `order` | `number` | 拍位顺序 |
| `beatNid` | `string` | 拍位 nid |
| `required` | `boolean` | 是否必写 |
| `repeatMin` | `number` | 最少重复次数 |
| `repeatMax` | `number` | 最多重复次数 |
| `allowedParagraphs` | `CompositionAllowedParagraphDTO[]` | 当前拍允许的段型列表 |

#### `allowedParagraphs[]` 字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `paragraphTypeNid` | `string` | 段型 nid |
| `paragraphType` | `EnSentenceSimpleNidDTO` | 段型详情 |
| `usageName` | `LanguageText[]` | 用途短名 |
| `usageDescription` | `LanguageText[]` | 用途说明 |

#### `memberList[]` 字段

> 注意：当前 `task/detail` 里 `memberList` 是按任务壳和关卡槽位组的结构数据，不是用户当前作答正文。  
> 用户当前实际写了什么请看 `memberWriting.parts`。

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `index` | `number` | 成员顺序 |
| `beatNid` | `string` | 拍位 nid |
| `paragraphTypeNid` | `string` | 段型 nid |
| `paragraphType` | `EnSentenceSimpleNidDTO` | 段型详情 |
| `paragraphId` | `number` | 段落实例 ID |
| `usageName` | `LanguageText[]` | 用途名称 |
| `usageDescription` | `LanguageText[]` | 用途说明 |
| `paragraph` | `EnParagraphInstanceContentDTO` | 段落对象；当前任务详情里通常只有结构，正文内容可能为空 |
| `translate` | `string` | 译文，允许为空 |

#### `memberReviewHistory` / `memberWriting`

这两个字段结构与下文 study-app 返回完全一致，可直接复用前端类型。

---

## 4. study-app：暂存

### 4.1 接口

`POST /composition/tasks/{taskId}/draft`

### 4.2 路径参数

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `taskId` | `number` | 是 | 写作任务 ID |

### 4.3 请求体

```json
{
  "source": "typed",
  "unitId": 14238,
  "headText": "Hello everyone,",
  "tailText": "Thank you.",
  "parts": [
    {
      "key": "develop",
      "beatNid": "develop",
      "text": "I go to school by bike."
    }
  ],
  "mediaKeys": [],
  "duration": 36.5
}
```

#### 请求字段

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `source` | `string` | 否 | 当前只支持 `typed`；不传默认 `typed` |
| `unitId` | `number` | 否 | 课上作答单元 ID；非课上作答传 `null` |
| `headText` | `string` | 否 | 文首文本 |
| `tailText` | `string` | 否 | 文尾文本 |
| `parts` | `Part[]` | 否 | 正文块列表 |
| `parts[].key` | `string` | 否 | 前端块标识，仅前端本地可读 |
| `parts[].beatNid` | `string` | 条件必填 | 拍位 nid；只要传 `parts[]`，每项必须有 |
| `parts[].text` | `string` | 否 | 当前块正文 |
| `mediaKeys` | `string[]` | 否 | 多媒体资源 key 列表 |
| `duration` | `number` | 否 | 当前累计做题时长，单位秒；不传默认 `0` |

### 4.4 暂存校验规则

#### 通用

- `source` 非 `typed` 会报错
- `duration < 0` 会报错
- `unitId <= 0` 会报错
- `parts[].beatNid` 不能为空

#### 文字题

- 不允许上传 `mediaKeys`
- 如果关卡 `headFill != write`，则 `headText` 不能填写
- 如果关卡 `tailFill != write`，则 `tailText` 不能填写
- `parts[].beatNid` 必须属于当前任务允许填写的拍位
- 不检查“是否填满全部正文块”，因为暂存允许半成品

#### 图片/音频/视频题

- `headText` / `tailText` / 正文文本都必须为空
- `mediaKeys.length` 不能超过 `answerMaxCount`
- 暂存时不校验最少份数

### 4.5 返回

返回当前最新草稿，结构为 `MemberCompositionWritingDTO`。

---

## 5. study-app：提交并发起批改

### 5.1 接口

`POST /composition/tasks/{taskId}/submit`

### 5.2 路径参数

同暂存接口。

### 5.3 请求体

与 `draft` 完全一致。

### 5.4 提交校验规则

在暂存校验基础上，增加更严格约束：

#### 文字题

- 如果关卡要求文首填写，则 `headText` 不能为空
- 如果关卡要求文尾填写，则 `tailText` 不能为空
- 所有允许填写的正文拍位都必须有内容

#### 图片/音频/视频题

- `mediaKeys.length` 必须 `>= answerMinCount`
- `mediaKeys.length` 仍然必须 `<= answerMaxCount`

### 5.5 返回

```json
{
  "writingId": 101,
  "status": "queued",
  "taskId": 7031,
  "note": null
}
```

#### 返回字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `writingId` | `number` | 当前习作记录 ID |
| `status` | `string` | 算法动作状态，当前常见值：`queued` / `duplicate` / `failed` |
| `taskId` | `number` | 算法批改任务 ID；前端轮询任务状态时使用 |
| `note` | `string` | 预留字段，当前实现通常为 `null` |

### 5.6 前端交互建议

- 提交成功后切到批改页
- 使用返回的 `taskId` 轮询统一任务状态接口
- 轮询结果到 `finished` / `failed` 后，再重新请求写作详情或 language 详情接口

---

## 6. study-app：重新批改

### 6.1 接口

`POST /composition/tasks/{taskId}/review/{writingId}/retry`

### 6.2 路径参数

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `taskId` | `number` | 是 | 写作任务 ID |
| `writingId` | `number` | 是 | 要重新批改的习作记录 ID |

### 6.3 请求体

无请求体。

### 6.4 当前代码规则

> 这里描述的是当前代码实现，不是旧设计稿里带 `force` 的版本。

- 只有 `status = submitted` 的记录允许重批
- `review.status = failed`：允许直接重试
- `review.status = done`：当前实现也允许直接重跑
- `review.status in [queued, running]`：拦截，报错 `"当前批改仍在进行中"`
- 其他情况：拦截，报错 `"当前记录不支持重新批改"`
- 发给算法侧的 `force` 当前固定为 `true`

### 6.5 返回

与提交接口一致：

```json
{
  "writingId": 101,
  "status": "queued",
  "taskId": 7032,
  "note": null
}
```

---

## 7. study-app：从批改页进入重写态

### 7.1 接口

`POST /composition/tasks/{taskId}/rewrite`

### 7.2 路径参数

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `taskId` | `number` | 是 | 写作任务 ID |

### 7.3 请求体

无请求体。

### 7.4 当前代码行为

1. 先查任务详情，拿到 `answerKind`、`stage` 等壳数据
2. 再查当前任务最近一条作答记录
3. 如果最近一条就是草稿，直接返回该草稿
4. 如果最近一条是提交记录：
   - 文字题：用最近一次提交内容组装一个新的草稿请求
   - 图片/音频/视频题：新建空草稿
5. 通过算法侧 `draft` 接口落一条新草稿，再返回最新草稿详情

### 7.5 返回

返回 `MemberCompositionWritingDTO`。

---

## 8. `MemberCompositionMemberDetailDTO`

`GET /composition/tasks/{taskId}/member/detail` 与 language 详情里的 `memberReviewHistory`、`memberWriting` 复用这套结构。

```json
{
  "reviewHistory": [],
  "compositionWriting": {}
}
```

#### 顶层字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `reviewHistory` | `ReviewHistoryDTO[]` | 当前任务下所有提交记录的批改历史，按最新优先 |
| `compositionWriting` | `MemberCompositionWritingDTO` | 当前选中的作答详情；默认优先最新提交，没有提交则返回草稿 |

---

## 9. `ReviewHistoryDTO`

```json
{
  "writingId": 101,
  "seq": 2,
  "reviewedAt": "2026-10-14T19:05:00Z",
  "score": 83,
  "grade": "良好",
  "selected": true
}
```

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `writingId` | `number` | 习作记录 ID |
| `seq` | `number` | 第几次提交 |
| `reviewedAt` | `string` | 批改时间；优先取 `review.reviewedAt`，没有则退回 `submittedAt` |
| `score` | `number` | 总分 |
| `grade` | `string` | 中文评级：`优秀` / `良好` / `达标` / `再练练`；没有评级时返回 `null` |
| `selected` | `boolean` | 当前是否选中 |

---

## 10. `MemberCompositionWritingDTO`

### 10.1 顶层字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `uid` | `number` | 习作记录 ID |
| `teamId` | `number` | 团队 ID；language 侧聚合对象里通常不返回 |
| `memberId` | `number` | 成员 ID；language 侧聚合对象里通常不返回 |
| `compositionTaskId` | `number` | 写作任务 ID；language 侧聚合对象里通常不返回 |
| `unitId` | `number` | 课上作答单元 ID；非课上为空 |
| `stageNid` | `string` | 关卡 nid；language 侧聚合对象里通常不返回 |
| `exemplarCompositionId` | `number` | 参考范文 ID；language 侧聚合对象里通常不返回 |
| `answerKind` | `string` | 作答类型：`text` / `image` / `video` / `audio` |
| `source` | `string` | 作答来源：当前实际只会是 `typed` |
| `status` | `string` | 作答状态：`draft` / `submitted` |
| `seq` | `number` | 第几次提交；草稿通常为空 |
| `parts` | `Part[]` | 正文分块；文字题核心字段 |
| `mediaKeys` | `string[]` | 媒体 key 列表 |
| `mediaUrls` | `string[]` | 媒体可访问 URL 列表，按 `answerKind` 自动拼 bucket |
| `duration` | `number` | 做题时长，单位秒 |
| `score` | `number` | 分数 |
| `review` | `Review` / `object` | 批改详情；仅提交后才可能有 |
| `submittedAt` | `string` | 提交时间 |
| `created` | `string` | 创建时间 |
| `updated` | `string` | 更新时间 |

### 10.2 `parts[]`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `key` | `string` | 块唯一标识：`head` / `tail` / 具体拍位 key |
| `role` | `string` | 块角色：`head` / `beat` / `tail` |
| `beatNid` | `string` | 拍位 nid |
| `fill` | `string` | 填法：`write` / `given` / `hidden` |
| `index` | `number` | 同拍位内序号 |
| `text` | `string` | 当前块正文 |

### 10.3 `review`

#### 顶层

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `status` | `string` | `queued` / `running` / `done` / `failed` |
| `jobId` | `number` | 算法任务 ID |
| `error` | `string` | 批改失败原因 |
| `warnings` | `string[]` | 批改提示/降级提示 |
| `attempts` | `number` | 批改尝试次数 |
| `rubricVersion` | `string` | 量规版本 |
| `level` | `string` | 批改等级，例如 `A1` |
| `reviewedAt` | `string` | 批改完成时间 |
| `total` | `number` | 总分 |
| `grade` | `string` | 原始评级值：`excellent` / `good` / `pass` / `retry` |
| `errorFree` | `ErrorFree` | 无错句统计 |
| `dimensions` | `Dimension[]` | 维度评分 |
| `summary` | `string` | 总结 |
| `priorities` | `string[]` | 优先改进项 |
| `taskPoints` | `TaskPoint[]` | 任务点命中情况 |
| `issues` | `Issue[]` | 错误/建议项 |
| `highlights` | `Highlight[]` | 亮点项 |
| `parts` | `ReviewPart[]` | 各正文块对应的批注、订正稿、升格稿 |
| `improvedNotes` | `string[]` | 升格说明 |
| `knowledgeUses` | `KnowledgeUse[]` | 知识点使用情况 |
| `grammarUses` | `GrammarUse[]` | 语法点使用情况 |
| `comment` | `string` | 老师评语，媒体题更常见 |
| `transcript` | `string` | 音视频转写文本 |

#### `errorFree`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `clean` | `number` | 无错句数量 |
| `total` | `number` | 句子总数 |

#### `dimensions[]`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `dimension` | `string` | 维度标识 |
| `score` | `number` | 维度分数 |
| `weight` | `number` | 维度权重 |
| `comment` | `string` | 维度说明 |

#### `taskPoints[]`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `point` | `string` | 任务点名称 |
| `status` | `string` | 命中状态 |
| `note` | `string` | 说明 |

#### `issues[]`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `id` | `string` | 问题 ID |
| `anchor` | `Anchor` | 锚点信息 |
| `dimension` | `string` | 所属评分维度 |
| `category` | `string` | 问题分类 |
| `severity` | `string` | 严重程度 |
| `correction` | `string` | 建议改正结果 |
| `explanation` | `string` | 解释说明 |
| `grammarTargetUid` | `number` | 关联语法目标 UID |
| `knowledge` | `Knowledge` | 关联知识点 |

#### `highlights[]`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `id` | `string` | 亮点 ID |
| `anchor` | `Anchor` | 锚点信息 |
| `comment` | `string` | 亮点说明 |

#### `review.parts[]`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `key` | `string` | 对应正文块 key |
| `comment` | `string` | 当前块批注 |
| `correctedText` | `string` | 当前块订正稿 |
| `improvedText` | `string` | 当前块升格稿 |

#### `knowledgeUses[]`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `contentType` | `string` | 内容类型 |
| `uid` | `number` | 内容 UID |
| `semanticId` | `number` | 语义 ID |
| `content` | `string` | 展示内容 |
| `anchors` | `UseAnchor[]` | 命中位置列表 |

#### `grammarUses[]`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `uid` | `number` | 语法目标 UID |
| `title` | `string` | 语法标题 |
| `anchors` | `UseAnchor[]` | 命中位置列表 |

#### `anchor` / `useAnchor`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `partKey` | `string` | 所属正文块 key |
| `sentenceId` | `string` | 句子 ID |
| `start` | `number` | 起始偏移 |
| `end` | `number` | 结束偏移，不含尾 |
| `quote` | `string` | 命中的原文片段 |

#### `knowledge`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `contentType` | `string` | 知识点内容类型 |
| `uid` | `number` | 知识点 UID |
| `semanticId` | `number` | 语义 ID |

---

## 11. 常见业务报错

以下为当前代码里前端较容易遇到的业务提示：

| 场景 | 提示 |
| --- | --- |
| `taskId` 为空或非法 | `写作任务ID不能为空` |
| `writingId` 为空或非法 | `习作ID不能为空` |
| 任务不存在 | `写作任务不存在` |
| 非文字题却传了正文文本 | `当前任务只支持媒体作答` |
| 文字题却传了媒体 | `文字题不支持上传媒体作答` |
| 文首/文尾不允许填却传了内容 | `当前任务文首不支持填写` / `当前任务文尾不支持填写` |
| 正文拍位非法 | `正文拍位不正确` |
| 正文拍位重复 | `正文拍位不能重复` |
| 提交时正文未填满 | `文首内容不能为空` / `文尾内容不能为空` / `正文内容不能为空` |
| 媒体数量超过上限 | `作答数量超过上限` |
| 提交时媒体数量不足 | `作答数量未达到最少要求` |
| 当前批改中又点重批 | `当前批改仍在进行中` |
| 当前记录不允许重批 | `当前记录不支持重新批改` |
| 算法未正常返回动作结果 | `网络错误，请稍后再试！` |

---

## 12. 前端落地建议

1. 页面初始化先调 language 侧 `GET /write/zhenxie/composition/task/detail?taskId=...`
2. 写作态保存时调 study 侧 `draft`
3. 提交后使用返回的 `taskId` 轮询任务状态
4. 轮询完成后重新拉 language 详情接口，统一刷新壳数据和用户态
5. 批改页历史切换如果后续需要按指定 `writingId` 查看，仍然要通过 study 侧 `member/detail` 能力扩展，不建议前端自己拼数据

---

## 13. course-app：批量查询语法 Target 简要信息

### 13.1 接口

`POST /course/write/target/list`

### 13.2 使用场景

当前接口用于前端拿一组语法 Target 的轻量展示信息，适合：

- 根据 `grammarTargetUids` 批量回填标题
- 在写作详情页、资料区、标签区展示简要语法目标信息
- 避免前端为每个 target 单独发详情请求

### 13.3 请求体

```json
{
  "targetIds": [101, 102, 103]
}
```

#### 请求字段

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `targetIds` | `number[]` | 否 | 要查询的语法 Target UID 列表 |

### 13.4 当前代码规则

- `request` 可以为 `null`
- `targetIds` 可以为空或空数组
- 服务端会自动过滤非法 ID（`null`、`<=0`）
- 服务端会自动去重
- 返回顺序按前端传入顺序保留
- 已删除或不存在的 target 不会报错，直接跳过不返回

### 13.5 返回

返回 `CourseUnitWritingGrammarTargetItemDTO[]`

```json
[
  {
    "uid": 101,
    "title": [
      {
        "lang": "zh",
        "text": "一般过去时"
      }
    ],
    "kindTitle": "语法"
  }
]
```

#### 返回字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `uid` | `number` | Target 主键 |
| `title` | `LanguageText[]` | Target 标题，多语言结构 |
| `kindTitle` | `string` | 语法资产类型中文名，供前端直接展示 |

### 13.6 适合前端怎么用

- 如果 language 详情接口里返回了 `grammarTargetUids`，前端可以把这一组 UID 直接传给本接口
- 返回后以 `uid` 建映射表，回填到页面上
- 这个接口只适合展示轻量信息，不返回详细资产内容，也不返回 editSlots 或例句
