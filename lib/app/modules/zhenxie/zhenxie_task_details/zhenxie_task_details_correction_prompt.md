# zhenxie_task_details 批改右栏填充提示词

## 本次目标

先完成 `views/zhenxie_task_correction_widget.dart` 和 `views/zhenxie_task_details_view.dart` 的真实数据填充，让右栏和批改记录下拉都不再依赖假文案。

这次只做右栏批改区：

- 接 `detailsData.memberWriting.review`
- 处理 `queued / running / failed / done`
- 文字题展示分数卡、总评、题目要点、逐条批注、每段点评、要求用上了吗、下次先改、批改提示
- 非文字题展示老师评语、转写、批改提示
- 页头「批改记录 N」下拉展示真实历史，并支持按 `writingId` 切换当前批改详情

## 数据来源

统一从当前页面已经拿到的详情数据读取，不额外新接接口：

- `pageController.detailsData.value.memberWriting`
- `pageController.detailsData.value.memberWriting?.review`
- `pageController.taskController.taskKnowledgePointsList`
- `pageController.taskController.taskGrammarTargetList`
- `pageController.paragraphRhetoricalList`
- `pageController.detailsData.value.memberReviewHistory`
- `study-app GET /composition/tasks/{taskId}/member/detail?writingId={writingId}`

## 状态要求

### 1. 批改中

当 `review.status in ['queued', 'running']` 时：

- 右栏显示 loading 卡
- 不显示分数卡和正式批改内容
- 文案区分：
  - `queued`：排队中
  - `running`：正在逐句看

### 2. 批改失败

当 `review.status == 'failed'` 时：

- 显示失败卡
- 展示失败原因
- 保留“重新批改”按钮占位
- 如果当前模块还没接重批接口，不要写假请求，先给清晰占位反馈

### 3. 批改完成

当 `review.status == 'done'` 时：

- 文字题走完整批改内容
- 图片 / 音频 / 视频题不显示分数卡，只显示评语、转写、批改提示

## UI 范围

### 文字题右栏

需要真实填充这些模块：

1. 分数卡
2. 总评
3. 题目要点
4. 逐条批注
5. 每段点评
6. 要求用上了吗
7. 下次先改
8. 批改提示

### 非文字题右栏

需要真实填充这些模块：

1. 一行概览：按 `{level}` 要求 · `{answerKind}`
2. 老师评语
3. 听到的内容 / 转写（音频、视频）
4. 批改提示

## 后端已提供 / 尚未提供的展示字段

### 已提供，可直接使用

- `memberReviewHistory[].score`
- `memberReviewHistory[].grade`：中文评级文案
- `memberReviewHistory[].seq`
- `memberReviewHistory[].reviewedAt`
- `memberWriting.review.level`
- `memberWriting.review.dimensions[].comment`
- `memberWriting.review.taskPoints[].point / status / note`
- `memberWriting.review.issues[].dimension / category / severity / correction / explanation`
- `memberWriting.review.highlights[].comment`

### 量规口径来源

批改分数卡里的量规展开说明，**以产品文档 `04.review.md` 和 Web 原型 `ui_ux/src/pages/zhenxie/write/review/reviewRubric.ts` 为准**。

以下内容允许前端按这两份共享配置实现，不要求后端在当前 JSON 里重复返回：

- 评分维度中文名（如“任务完成 / 连贯与衔接 / 词汇资源 / 语法”）
- 评分维度的 IELTS 英文名
- 评分维度的“看什么”说明
- 各级别的“8 分长什么样”说明
- 分数档位说明（如 8 分 / 6 分 / 4 分各自代表什么）

要求：

- Flutter 与 `ui_ux` 必须共用同一套量规口径
- 改一处要同步另一处，不能各自维护两套说法
- 如果后续后端补了同名字段，再评估是否切回接口下发

### 本轮实现后确认仍缺的字段 / 约束

以下内容已经影响到 Flutter 右栏继续对齐 Web 原型，先记在这里：

- `memberWriting.review.dimensions[].title`
  - 用于分数卡展示中文维度名，避免直接显示 `taskAchievement / lexical` 这类内部 key
- `memberWriting.review.dimensions[].shortTitle`
  - 用于逐条批注卡片里展示维度短名，避免直接显示内部 key
- `memberWriting.review.issues[].categoryTitle`
  - 用于逐条批注卡片展示“拼写 / 搭配 / 标点”这类中文细类名
- `memberWriting.review.gradeText`
  - 当前详情里只有 `review.grade` 原始枚举，中文评级文案只能绕到 `memberReviewHistory[].grade`
  - 如果后续详情页允许直接打开某次批改详情，建议 review 自己返回当前记录的中文评级文案
- `memberWriting.review.knowledgeUses[] / grammarUses[]` 需要继续保证：
  - 不只是“已命中项”
  - 还要把“本题要求但这次没用上”的项一起返回，并且通过 `anchors=[]` 明确表达未命中
  - 右栏“要求用上了吗”已经按这套契约渲染

当前 Flutter 里已经先按现有契约处理：

- `dimensions[].score == null` 显示“不评”
- `dimensions[].weight` 用于单句题折算提示
- 分数卡量规展开按文档 / Web 原型共享静态配置渲染
- 批注 / 亮点按 `anchor.partKey + start + end` 做统一排序和统一编号
- `issues[].grammarTargetUid` / `issues[].knowledge` 用来显示关联标签

仍然不能靠前端随意自造的，是 `issues[].category` 中文展示名这类**未在文档 / Web 原型共享配置里定义**的字段。

## 明确不做

这次不要顺手扩范围：

- 不接真正的“重新批改”接口
- 不改左侧稿纸的批注锚点、订正稿套用、升格 diff
- 不做卡片和左侧稿纸的联动跳转
- 不为了右栏填充去重构整个 correction 架构

## 实现约束

- 优先复用当前实体和页面已有状态
- `CorrectionController` 只补最小读取和占位行为，不承接完整业务流
- 不写假数据
- 保持改动集中在 `correction` 相关文件
- 样式尽量贴近当前已画好的 UI，不做无关重排
