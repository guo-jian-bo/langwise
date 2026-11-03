## 目标与验收口径
- 新增管理端“单元写作范文页”。
- 从“单元写作任务”列表页第三个按钮进入。
- 接通多媒体题和文字题两条“写范文 / 范文”链路，进入页后调用 `GET /language-console/write/en/composition/write/exemplar/editor`。
- 多媒体题支持标题编辑、按份数上传或输入多媒体素材，并调用 `POST /language-console/write/en/composition/write/exemplar/save` 保存。
- 文字题进入 React 对齐的页内分支：先选“AI 写”或“反向处理”，再在当前页继续完成对应 section 配置。
- 编辑已有文字范文时，内容区先切到 React 对齐的结构编辑 UI（标题 / 文首 / 段落 / 文尾），并调用 `POST /language-console/write/en/composition/write/exemplar/save` 保存。
- 段落正文未改时，段内 `beatSpans` 支持按蓝图允许拍点顺序点击切换；正文一旦改动，则改为展示句子切片和“保存后重标起承转合”的提示。

## 改动点列表
- 新增 `ManageUnitWritingTaskExemplarView / Controller / Binding`。
- 新增范文 editor 初始化接口与统一范文保存接口。
- 新增文字题范文的 `generate / structure` 接口。
- 新增范文 editor 页对应的原始 DTO。
- 新增路由常量与 `TagRoutes` 注册。
- 将“单元写作任务”列表页第三个按钮接入范文页跳转。
- 支持从任务列表透传 `role = given` 和 `givenCompositionId` 进入同一页面。
- 当 `role = given` 时，在顶部起承转合区域下方追加“给拍范文”提示。
- 当 `role = given` 时，文字题 `generate / structure` 请求体补传 `role: given`。

## 关键设计 / 关键决策
- 页面继续严格使用 `tagText` 路由模板。
- 直接消费接口原始 DTO，不新增中间 ViewModel，不拍平后端结构。
- 顶部任务头复用 `ZhenxieWriteCatalogCardWidget` 与 `ZhenxieCompositionSlotStripWidget`。
- 多媒体题与已有文字范文编辑都走同步保存链路；文字题新建在页内直接展示 React 对齐的 `choose -> ai -> reverse` 分支切换。
- AI 写分支补齐“单词和短语”“语法点”两个 section；反向处理分支补齐“原文” section。
- 已有文字范文不再展示 `choose` 选择卡，而是直接展示结构编辑区，便于对照已有段落和 `beatSpans`。
- 文字题只有在完成当前分支配置后，底部点击“生成范文”才会发起异步任务。

## 兼容性影响与注意事项
- 列表按钮统一走同一个范文页：不传 `exemplarCompositionId` 视为新增，传了视为编辑。
- 多媒体题份数优先按接口返回的 `answerCount`；若为空，再回落到 `stage.answerMinCount / answerMaxCount`。
- 当前素材卡片支持输入 UID 和直接上传；未额外新增本地中间结构。
- 文字题发起 `generate / structure` 成功后，页面会直接返回任务列表，后续结果由异步任务产出。
- 当前文字范文“结构编辑”通过 `exemplar/save` 保存；新建文字范文仍只走 `generate / structure`。
- 给拍范文继续复用同一套“写 / 编辑单元范文”页面，只额外增加提示文案与请求体角色标记，不影响主范文逻辑。
- 文本编辑态的文首 / 文尾显示判断需兼容 `blueprint.frame`：当 `stage` 顶层未拍平 `hasHead / hasTail / headName / tailName` 时，前端回落读取 `stage.compositionBlueprint.frame`，确保“标题 / 文首 / 段落 / 文尾”结构与产品文档一致。

## 待确认问题 / TODO
- 如果后端后续补了可直接预览的多媒体元数据，可以再把音频 / 视频预览增强为实际播放器。
