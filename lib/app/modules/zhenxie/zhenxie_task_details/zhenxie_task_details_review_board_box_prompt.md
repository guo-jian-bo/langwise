# zhenxie_task_details ReviewBoardBoxWidget 落地提示词

## 本次目标

在 `lib/common/widgets/zhenxie_widgets/writing_boards/` 下新增一个专门服务批改稿纸的组件：

- `ReviewBoardBoxWidget`

它的视觉外观要继续沿用现有写作板皮肤体系，和 `BoardBoxWidget` 看起来保持同一套稿纸 / 板式语言；
但正文区域的渲染逻辑不再走当前编辑态的 `WritJustTextWidget / WritHeadTailWidget`，而是改为面向批改页的只读展示逻辑。

这次先聚焦文字题批改稿纸，不顺手扩到媒体题批改展示。

---

## 设计依据

- Flutter 现有写作板入口：
  - `views/zhenxie_task_writing_board_widget.dart`
  - `common/widgets/zhenxie_widgets/writing_boards/board_box_widget.dart`
- Web 对齐参考：
  - `ui_ux/src/pages/zhenxie/write/review/ReviewPaper.tsx`
  - `ui_ux/src/pages/zhenxie/write/review/TextReviewPanel.tsx`
  - `ui_ux/src/pages/zhenxie/write/review/reviewMarks.ts`
- 产品口径：
  - `docs/write/ui/admin/paragraph_composition/04.review.md`

---

## 核心目标

### 1. 组件职责拆分

`ReviewBoardBoxWidget` 的职责是：

- 根据 `skinNid` 复用现有稿纸皮肤
- 根据是否有文首 / 文尾，决定走“纯正文批改稿纸”还是“首尾结构批改稿纸”
- 承接批改态的正文渲染组件
- 不承接右栏评分卡、批注列表、题目要点等右栏逻辑

`ReviewBoardBoxWidget` 不负责：

- 编辑输入
- TextEditingController / FocusNode 管理
- 提交态运行时状态
- 媒体上传
- 批改右栏逻辑

### 2. 和现有 BoardBoxWidget 的边界

现有 `BoardBoxWidget` 继续服务：

- 写作任务态
- 范文态
- 范文编辑态

新增的 `ReviewBoardBoxWidget` 只服务：

- 文字题批改完成态下的左侧稿纸展示

不要把批改逻辑塞回 `WritJustTextWidget`，也不要在 `BoardBoxWidget` 里用 `if (mode == correction)` 硬切一大坨逻辑。

---

## 推荐分层

### 1. 皮肤层

优先抽一层可复用的“板式皮肤壳”能力，让：

- `BoardBoxWidget`
- `ReviewBoardBoxWidget`

共用同一套 `skinNid -> 纸张外壳` 的映射关系。

这层只负责：

- sticky note / label / report / speech / diary / textbook 等皮肤选择
- 把 child 挂进对应皮肤容器

这层不要知道：

- child 是编辑态输入框
- 还是批改态富文本稿纸

### 2. 正文层

批改稿纸建议新增自己的正文组件，例如：

- `review_just_text_widget.dart`
- `review_head_tail_widget.dart`
- `review_step_text_widget.dart`

它们只吃“批改稿纸显示数据”，不吃编辑态 controller bundle。

### 3. 数据层

不要直接复用 `WritingBoardRuntimeState` 作为批改稿纸数据源。

建议单独整理一套只读显示模型，例如：

- `WritingReviewBoardData`
- `WritingReviewBoardPartData`
- `WritingReviewBoardMarkerData`

来源统一收口到：

- `detailsData.memberWriting.parts`
- `detailsData.memberWriting.review.issues`
- `detailsData.memberWriting.review.highlights`
- `detailsData.memberWriting.review.parts`

如果当前阶段不想新建完整实体，也至少要有独立 mapper / helper，把批改稿纸用的数据整理干净，不要在 Widget 里直接边读实体边拼算法。

---

## UI 对齐要求

### 1. 总体外观

左侧稿纸整体要继续保持现有写作板视觉：

- 同样的皮肤
- 同样的拍印
- 同样的文首 / 正文 / 文尾布局
- 同样的段间节奏

也就是说，变化只发生在正文展示逻辑，不发生在整体板式结构。

### 2. 视图模式

批改稿纸默认需要支持三种正文视图：

- `annotation` 批注
- `correct` 订正
- `upgrade` 升格

这三种模式已经由页面上的批改模式切换条控制，稿纸组件只负责根据当前模式显示不同内容。

新增补充：

- 当当前批改记录属于 `paper` 模式时，批改模式切换条需要额外显示第四个选项：
  - `original` 原稿

也就是说：

1. 普通文字题批改稿纸仍是 `annotation / correct / upgrade`
2. 只有当前作答 `source == paper` 时，才额外显示 `original`
3. `original` 不参与批改富文本渲染，它表达的是“纸上原稿照片回显”
4. 默认选中规则补充：
   - 如果当前记录已经批改完成，保持现有批改页默认模式，不因为 `paper` 作答强制切到 `original`
   - 如果当前记录是刚提交、尚未进入正式批改展示阶段，则优先显示 `original`

### 3. 批注视图

参考 Web 端 `ReviewPaper.tsx`：

- `error`：红色波浪线
- `suggestion`：橙色虚线
- `highlight`：绿色底色
- 编号按统一顺序显示，和右栏卡片编号一致

### 4. 订正视图

只套用 `severity == error` 的改法：

- 删除内容用删除线
- 补上内容用绿色强调
- `suggestion` 不套用
- 编号仍然和原始批注保持一致

套用策略要对齐文档和 Web：

- 重叠改动跳过
- 同一起点保留范围更大的那条
- 删除词时可按 Web 规则吞掉相邻空格

订正视图的实现口径进一步明确为：

- `correct` 不沿用 `annotation` 的 `markers -> text segments -> painter` 渲染链
- 它本质上是“原文 + applied edits”的重组结果，应该单独走订正渲染逻辑
- `error issue` 先按 `start asc + end desc` 排序，再生成最终参与展示的 applied edits
- applied edit 的点击 id 仍然回到原始 `issue.id`
- 订正后的角标编号继续复用统一的 marker 编号结果，保证和右栏卡片一致

如果要兼顾后端 `correctedText`：

- 渲染定位、点击和编号仍然必须以 `issues` 为准
- `review.parts[].correctedText` 更适合作为后端结果参考或兜底，而不是直接替代前端的交互式订正渲染
- 不允许为了直接展示 `correctedText` 丢失局部订正片段和编号的映射关系

替换片段的显示规则对齐 Web `EditView`：

- `correction == ''`：仅显示原文删除线
- `correction` 以前缀方式包含原文：原文保留，新增尾部内容高亮
- `correction` 以后缀方式包含原文：新增前部内容高亮，原文保留
- 原文和订正文案仅大小写不同：直接显示绿色强调的新词
- 其他情况：`del(original) + ins(correction)` 并列展示

### 5. 升格视图

- 用原文和 `review.parts[].improvedText` 做词级 diff
- 新增内容高亮
- 删除内容灰色删除线
- 给定段不做升格 diff

升格视图的实现口径进一步明确为：

- `upgrade` 也不复用 `annotation` 的 marker 切片模型
- 它本质上是“原文 vs improvedText”的词级 diff 结果，应该单独走升格渲染逻辑
- diff 的输入以 `memberWriting.parts[].text` 和 `review.parts[].improvedText` 为准
- 如果当前 part 没有有效的 `improvedText`，直接回退显示原文
- 首版只要求文本展示，不强求为升格稿额外构造 marker id 或选中态

词级 diff 规则对齐 Web `wordDiff`：

- 先按“非空白词 + 后缀空白”切 token
- token 比较时按 `trim()` 后的词做 LCS
- `same`：原样输出
- `del`：灰色删除线
- `ins`：绿色高亮
- token 自带的尾部空白要跟着 token 一起输出，避免词间距错乱

### 6. 给定段规则

`fill == given` 的段落：

- 灰字只读
- 不加批注
- 不套用订正
- 不做升格 diff

### 7. 头尾规则

文首 / 文尾也是稿纸组成部分，不能只处理正文拍位。

如果当前题有：

- `showHead == true`
- `showTail == true`

那么批改稿纸同样要覆盖 head / tail 的显示和标记逻辑。

### 8. paper 原稿模式

当当前批改记录的作答来源是：

- `memberWriting.source == paper`

批改区要新增一条特殊渲染分支：

1. 右上方批改模式切换条显示 `original`
2. 点到 `original` 后，左侧不再走文字批改稿纸
3. 左侧要直接显示 `BoardBoxPaperPhotoWidget`
4. 纸面照片回填来源对齐任务作答态：
   - `paperImageKeys`
   - `paperImageUrls`

也就是说，`original` 的左稿纸不是：

- `ReviewJustTextWidget`
- `ReviewHeadTailWidget`
- `ReviewStepTextWidget`

而是直接复用现有纸面照片板：

- `lib/common/widgets/zhenxie_widgets/writing_boards/board_box_widget.dart`
- `BoardBoxPaperPhotoWidget`

并且回填口径要和任务作答态 `paper` 模式保持一致，不允许批改态另算一套照片展示协议。

补充约束：

1. `original` 只在 `paper` 作答下出现，不给 `typed` 作答显示
2. `original` 只负责显示纸面照片，不承接 `annotation / correct / upgrade` 的文本富文本算法
3. `original` 里不走 `ReviewBoardBoxWidget` 当前的文本皮肤壳分支
4. `original` 需要直接吃当前批改记录对应的纸面照片回填数据
5. 纸面照片展示仍然沿用 `BoardBoxPaperPhotoWidget` 的现有 UI，不重新发明一个批改专用照片板

---

## 交互要求

### 1. 左右联动目标

最终目标要支持：

- 点右栏卡片，左稿纸定位并高亮
- 点左稿纸标记，右栏切到对应卡片
- 点每段点评，对应拍位闪一下
- 点核心词 / 语法点命中标签，高亮稿纸上的全部命中位置

### 2. 本轮实现边界

如果本轮先不做完整联动，也要提前留出状态边界，不要把状态写死在局部 Widget 的 `State` 里。

建议后续统一放到 `ZhenxieTaskDetailsCorrectionController` 的状态包括：

- 当前批改稿纸模式
- 当前选中的 marker id
- 当前 flash marker id
- 当前 flash part key
- 当前 focus anchors

这些状态不应该放进 `BoardController`，因为它们属于批改域，不属于写作输入域。

补充对齐 Web / 文档的联动口径：

- `correct` 视图里只展示和点击“真正被套用的 error edits”
- `suggestion` 和 `highlight` 在 `correct` 视图里不保留局部交互命中
- 如果当前右栏点中的是 `suggestion` 或 `highlight`，而左栏正处于 `correct` 或 `upgrade`，左栏应切回 `annotation` 再定位
- `upgrade` 视图首版按纯展示处理，不承接 marker 选中、编号点击或局部定位

补充对 `original` 的边界要求：

- `original` 不承接 marker 点击
- `original` 不承接左右批注联动
- `original` 不承接 `correct / upgrade` 的局部编辑片段命中
- `original` 首版按“纯照片原稿展示”处理

---

## 排序与编号规则

批注和亮点必须统一排序并统一编号。

排序口径：

1. 按 part 在当前作答中的书写顺序
2. 再按 `anchor.start`
3. 再按 `anchor.end`
4. 最后按 id 兜底

编号结果必须保证：

- 左稿纸上的圆号
- 右栏逐条批注卡片编号

完全一致。

不要在左边和右边各算一套。

---

## 状态要求

### 1. review.status == done

只有 `done` 时进入正式批改稿纸：

- 批注
- 订正
- 升格

如果当前作答是 `paper`，还允许进入：

- 原稿 `original`

### 2. review.status == queued / running

左稿纸仍走 `ReviewBoardBoxWidget`，但先只显示原文，不显示批改富文本效果。

### 3. review.status == failed

左稿纸仍走 `ReviewBoardBoxWidget`，但先只显示原文，不显示批改富文本效果。

也就是说：

- 只要页面处于批改模式，就走 `ReviewBoardBoxWidget`
- 是否显示批改富文本效果，再额外判断 `review.status` 和批改数据是否齐备

补充：

- `original` 不依赖批改富文本是否齐备，只依赖当前记录是否存在 `paperImageKeys / paperImageUrls`
- 也就是说，即使批改态没有可渲染的 `annotation / correct / upgrade` 富文本，`paper` 原稿照片仍可以单独显示
- 默认进入规则补充：
  - `review.status == done` 时，保持当前批改完成态的默认模式口径，不额外强制跳到 `original`
  - 刚提交、批改未完成，且当前作答 `source == paper` 时，左稿纸默认优先展示 `original`

---

## 明确不做

这次不要顺手扩以下范围：

- 不改媒体题稿纸
- 不把批改稿纸和编辑稿纸强行合并成一个巨型组件
- 不把批改算法直接堆进页面 View
- 不重构整个 `writing_boards` 目录
- 不为了复用而提炼过度抽象
- 不为 `original` 单独新做一套纸面照片 UI

---

## 后续演进需求

首版虽然先不做左右联动，但提示词里要提前保留后续演进方向，避免后面继续开发时重新拆边界。

### 1. 和右栏逐条批注联动

后续需要支持：

- 点右栏批注卡片，左稿纸滚动到对应 marker
- 左稿纸上对应 marker 闪一下
- 如果当前是别的筛选态，右栏自动切回能看到该卡片的状态

### 2. 和左稿纸 marker 反向联动

后续需要支持：

- 点左稿纸上的 marker
- 右栏滚动到对应批注卡片
- 右栏当前卡片同步切到选中态

### 3. 和“每段点评”联动

后续需要支持：

- 点右栏某条段评
- 左稿纸对应拍位 / 文首 / 文尾闪一下

### 4. 和“要求用上了吗”联动

后续需要支持：

- 点核心词命中标签
- 左稿纸高亮该知识点全部 anchors
- 点语法点命中标签
- 左稿纸高亮该语法点全部 anchors

### 5. 和批改模式切换联动

后续需要支持：

- 右栏切换 `annotation / correct / upgrade`
- 左稿纸同步切换视图
- 当前选中的 marker id 尽量保留，避免视图切换后上下文丢失

### 6. 和批改记录切换联动

后续需要支持：

- 切换不同 `writingId / review history`
- 左稿纸重建当前记录对应的 marker / 编号 / 选中态
- 旧记录残留的选中 id / focus anchors / flash 状态要同步清空

### 7. 状态归属要求

上述联动相关状态建议统一收口在 `ZhenxieTaskDetailsCorrectionController`，不要塞到 `BoardController`：

- 当前批改稿纸模式
- 当前选中的 marker id
- 当前 flash marker id
- 当前 flash part key
- 当前 focus anchors

这样可以保持：

- `BoardController` 继续只负责写作板输入运行时
- `CorrectionController` 专门负责批改稿纸和右栏的联动状态

### 8. 数据联动要求

后续所有联动都必须建立在同一套“批改稿纸显示数据”之上，不允许左稿纸和右栏各自重新算一套。

至少要统一这些结果：

- marker 排序结果
- marker 编号结果
- marker -> partKey / anchor 的映射
- partKey -> 段评 / 订正 / 升格内容的映射
- 核心词 / 语法点 -> anchors 的映射

如果后续要下沉 helper / mapper，优先抽：

- `review_board_mapper.dart`
- `review_board_mark_helper.dart`

不要把这些联动算法散在多个 View 里各写一遍。

---

## 代码组织建议

建议新增文件：

- `lib/common/widgets/zhenxie_widgets/writing_boards/review_board_box_widget.dart`
- `lib/common/widgets/zhenxie_widgets/writing_boards/review_just_text_widget.dart`
- `lib/common/widgets/zhenxie_widgets/writing_boards/review_head_tail_widget.dart`
- `lib/common/widgets/zhenxie_widgets/writing_boards/review_step_text_widget.dart`

如需要抽共享皮肤层，再补：

- `lib/common/widgets/zhenxie_widgets/writing_boards/board_skin_shell_widget.dart`

如需要整理批改稿纸算法，再补：

- `lib/common/widgets/zhenxie_widgets/writing_boards/utils/review_board_mapper.dart`
- `lib/common/widgets/zhenxie_widgets/writing_boards/utils/review_board_mark_helper.dart`

---

## 实现约束

- 优先局部改动，避免波及现有写作输入链路
- 注释要清楚说明：哪些是批改态、哪些是编辑态
- 不要新增嵌套三元表达式
- 不要为了判空到处加一次性中转变量
- Widget 的职责边界要清晰
- 算法类逻辑尽量下沉到 helper / mapper，不要堆在 View build 树里

---

## 开工前仍需确认的点

如果用户没有补充，默认按下面口径推进：

1. `ReviewBoardBoxWidget` 首版只接文字题批改模式
2. 首版允许先做左稿纸展示，不强求一次性接完左右联动
3. `correct` 视图的交互式渲染优先基于 `issues` 生成 applied edits；`review.parts[].correctedText` 视为同一套规则产出的结果字段，不单独作为另一套展示来源
4. `upgrade` 直接基于原文和 `improvedText` 做词级 diff，不在 Flutter 侧额外重算“升格稿正文”
5. 如果现有 `writing_boards.dart` 需要导出新组件，要保持最小改动，不顺手整理全目录

---

## 当前已确认

1. 首版先不做左右联动，左稿纸先只负责展示
2. 文首 / 文尾一起纳入批注标记渲染范围
3. 首版当前已完成 `annotation`，下一步补 `correct / upgrade`
4. 保留“点中某个标记后的选中描边态”
5. 只要当前页面处于批改模式，就走新的 `ReviewBoardBoxWidget`
6. 是否显示批注富文本效果，除了判断 `review.status`，还要判断当前是否真的有可显示的批注数据
7. `annotation` 的可显示条件按“`review.status == done` 且 `issues/highlights` 至少一项有有效锚点数据”收口
8. 文首 / 文尾如果当前没有任何 marker，不需要保留和正文一致的可点击选中外框行为
9. 不抽共享皮肤壳，`ReviewBoardBoxWidget` 直接独立维护所需的皮肤分支
10. `correct / upgrade` 不强行复用 `annotation` 的 marker 切片和 painter，改为各自独立的文本渲染链
11. `correct` 只套用 `error`，并继续复用统一编号结果
12. `upgrade` 首版只做文本 diff 展示，不额外引入新的选中态协议
13. `correctedText` 的业务含义就是“代码把 error 改法套回原文后的结果”，和 applied edits 属于同一套口径
14. `correct` 视图只允许命中被实际套用的 `error issue`
15. 右栏点中 `suggestion / highlight` 时，如果左栏当前视图看不见它，左栏应切回 `annotation`
16. 如果当前批改记录是 `paper` 作答，批改模式切换条需要额外显示 `original`
17. `original` 左稿纸不走 `ReviewBoardBoxWidget` 当前的文本皮肤壳与文字批改渲染链，直接复用 `BoardBoxPaperPhotoWidget`
18. `original` 的照片回填口径和任务作答态 `paper` 模式一致，直接吃 `paperImageKeys / paperImageUrls`
19. `original` 首版按纯展示处理，不承接 marker 联动与富文本命中
20. `paper` 作答的默认进入规则是：
    - 已批改完成：保持现状
    - 刚提交 / 未批改完成：默认显示 `original`

---

## 当前还建议补充的信息

如果后面要直接开写代码，最好再明确这几个点：

1. 首版 `annotation` 的选中描边只保留在文本命中的 marker 上，不让对应拍位外层容器同步加选中态

---

## 本轮新增补充：文字作答的“打字输入 / 写在纸上”双模式

> 这部分是当前 `zhenxie_task_details` 页面新增的写作态需求补充，和 `ReviewBoardBoxWidget` 批改稿纸属于并行链路。
> 本轮实现目标是补齐任务作答链路，不是扩批改稿纸 UI。

### 1. 需求背景

当前任务详情页里，文字题已经有一套文字提交模式枚举：

- `ZhenxieTaskTextSubmitModeEnum.typing`
- `ZhenxieTaskTextSubmitModeEnum.paper`

对应状态当前由：

- `lib/app/modules/zhenxie/zhenxie_task_details/controllers/zhenxie_task_details_board_controller.dart`

里的 `writingBoardTextMode` 维护。

页面标题区也已经有模式切换 UI：

- `lib/app/modules/zhenxie/zhenxie_task_details/views/zhenxie_task_writing_board_widget.dart`

写作板正文区在 `typing` 下走现有文字稿纸，在 `paper` 下走：

- `lib/common/widgets/zhenxie_widgets/writing_boards/board_box_widget.dart`
- `BoardBoxPaperPhotoWidget`

但当前这条链路还不完整：

1. 提交请求里的 `source` 仍然写死为 `"typed"`
2. 文字题“写在纸上”还没有独立的图片上传提交数据
3. 页面的“是否有修改 / 退出对比基线 / 草稿态持久化 / 重建写作板状态”还没有把纸上拍照数据纳入比较

### 2. 本轮核心目标

本轮要把文字题的写作态明确拆成两种提交模式：

1. `typing`
   - 打字输入
   - 继续走当前 `headText / tailText / parts`

2. `paper`
   - 写在纸上后拍照上传
   - 走纸面照片资源提交

注意：

- 这里只作用于 `answerKindEnum.isText == true` 的文字题
- 图片题 / 视频题 / 音频题继续走原本媒体作答链路，不复用这套 `paper` 语义
- 这次不要改 `BoardBoxPaperPhotoWidget` 的 UI 表现

### 3. 请求体协议要求

当前任务提交 / 暂存请求体构建入口在：

- `lib/app/modules/zhenxie/zhenxie_task_details/controllers/zhenxie_task_details_task_controller.dart`
- `_buildSubmitRequestData`

本轮协议补充要求：

1. `source` 不能再写死 `"typed"`
   - `typing` 模式传 `"typed"`
   - `paper` 模式传 `"paper"`

2. 请求体新增：
   - `paperImageKeys`

3. `paperImageKeys` 的语义是：
   - 仅承接“文字题 + paper 模式”下上传后的纸面照片资源 key 列表
   - 不和媒体题的 `mediaKeys` 混用

4. 默认提交口径按下面收口：
   - `typing`：继续提交 `headText / tailText / parts`，`paperImageKeys` 传空列表
   - `paper`：提交 `paperImageKeys`，正文文本字段按协议最小化处理，避免把纸上作答和打字正文混在同一次协议里

如果后端最终要求 `paper` 模式下仍保留部分正文辅助字段，再单独补协议，不要先在 Flutter 侧自作主张混提两套正文。

### 3.1 服务端返回字段补充

服务端会为成员草稿 / 提交记录额外返回：

- `paperImageKeys`
- `paperImageUrls`

这两个字段的语义是：

1. 只服务于“文字题 + paper 模式”的纸面照片
2. 不和媒体题原有的 `mediaKeys / mediaUrls` 混用
3. 用于草稿回显、已保存数据恢复、退出基线重建

因此本轮实现时，实体层、运行时状态、提交快照和详情转写作板数据的 mapper，都要能承接这两个字段。

### 4. 状态设计要求

这次不要把“纸上照片”强行塞进现有媒体题的 `answerImages` 语义里。

原因：

1. `answerImages` 当前表达的是“图片题作答结果”
2. 文字题 `paper` 模式表达的是“纸上书写后的照片凭证”
3. 两者虽然都是图片资源，但业务含义完全不同，后续提交字段也不同

因此要给文字题 `paper` 模式维护独立状态，至少覆盖：

1. 当前纸面照片列表
2. 已上传拿到的资源 key / url
3. 本地待上传路径
4. 和 `typing` 模式并存时的草稿态保留

也就是说：

- 从 `typing` 切到 `paper`，之前输入的正文内容不能丢
- 从 `paper` 切回 `typing`，之前选好的纸面照片也不能丢
- 两套数据应该共同挂在当前任务草稿态里，而不是互相覆盖

### 4.1 草稿回显要求

显示草稿时，必须先判断当前文字提交模式，再决定把哪套数据回填到页面：

1. 当前是 `typing`
   - 正文区继续使用 `memberWriting.parts`
   - 不把 `paperImageUrls` 强行展示到文字输入稿纸里

2. 当前是 `paper`
   - 纸面照片区使用 `paperImageKeys / paperImageUrls` 回填
   - 需要把服务端返回的 `url` 正确填充到页面展示项里
   - 如果同时带有 `key`，要一起保留，避免再次提交时重复上传

3. 模式判断优先依据当前草稿自己的 `source`
   - `typed` 对应 `typing`
   - `paper` 对应 `paper`

4. 如果当前详情里同时存在正文内容和纸面照片：
   - `typing` 只回显正文草稿
   - `paper` 只回显纸面照片草稿
   - 两套数据都要保存在运行时，切模式时可以互相切回，不允许互相覆盖

### 5. 写作板状态链路必须同步补齐

以下方法本轮都要纳入“纸上拍照”状态：

1. `buildExitCompareBaselineRuntimeState`
2. `persistCurrentEditableRuntimeState`
3. `rebuildWritingBoardState`
4. `hasPendingExitChanges`
5. 当前草稿提交快照构建逻辑

补齐要求：

1. 退出对比基线不仅要比较正文内容，也要比较：
   - `writingBoardTextMode`
   - `paper` 模式下的纸面照片列表

2. “是否有修改”判断必须覆盖：
   - 从 `typing` 切到 `paper`
   - 从 `paper` 切到 `typing`
   - 纸面照片新增 / 删除 / 上传完成后 key 变化

3. 重建写作板状态时，要能把当前草稿里的：
   - 文字输入结果
   - 纸面照片结果
   - 当前文字提交模式

一起恢复出来，避免切模式或切页面态后丢失

4. 服务端草稿回显时，如果 `source == paper`：
   - 写作板要恢复到 `ZhenxieTaskTextSubmitModeEnum.paper`
   - 并把 `paperImageUrls` 映射成可展示的图片项

5. 服务端草稿回显时，如果 `source == typed`：
   - 写作板要恢复到 `ZhenxieTaskTextSubmitModeEnum.typing`
   - 并继续按正文 parts 构建运行时文本状态

### 6. UI 边界要求

`BoardBoxPaperPhotoWidget` 已经存在，本轮实现时：

1. 不能改它的视觉样式
2. 不能顺手重做它的布局
3. 不能把当前标题区的模式切换 UI 改掉

如果需要把真实上传逻辑接进去，应当通过：

- `BoardBoxWidget` 参数透传
- `BoardController` 状态维护
- 写作板运行时状态 / 提交快照扩展

来完成，而不是改动现有 UI 结构。

### 7. 页面边界要求

本轮需求发生在 `zhenxie_task_details` 的任务作答链路，重点影响：

- `ZhenxieTaskDetailsTaskController`
- `ZhenxieTaskDetailsBoardController`
- `zhenxie_task_writing_board_widget.dart`
- `board_box_widget.dart`
- 写作板运行时 / 提交数据模型

这次不要顺手把逻辑扩到：

- `ReviewBoardBoxWidget`
- 批改稿纸富文本渲染
- 右栏批改卡片联动

也不要为了这次需求去重构整个 `writing_boards` 目录。

### 8. 默认实现口径

如果用户没有进一步补充，这轮默认按下面口径推进：

1. 仅文字题支持 `typing / paper` 双模式
2. `paper` 模式的上传结果使用独立状态字段，不复用媒体题 `answerImages`
3. 提交 / 暂存时都统一带上正确的 `source`
4. 提交 / 暂存时都支持 `paperImageKeys`
5. 退出未保存判断必须把 `writingBoardTextMode` 和纸面照片都纳入比较
6. 不修改 `BoardBoxPaperPhotoWidget` 的 UI，只补齐状态和提交逻辑
7. 草稿回显必须按 `source` 分流：
   - `typed` 回显正文
   - `paper` 回显纸面照片
8. 服务端返回的 `paperImageUrls` 必须填充到 `paper` 模式展示数据里
