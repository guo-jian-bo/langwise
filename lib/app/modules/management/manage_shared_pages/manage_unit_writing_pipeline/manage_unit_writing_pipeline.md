# 写作管线页说明

## 目标与验收口径
- 新增管理端“写作管线页”。
- 从课程页中部的“写作管线”入口点击进入。
- 页面进入后调用 `GET /course-console/unit/{unitId}/writing/stage/detail`。
- 左侧展示当前单元挂载的写作阶梯卡片，右侧展示“时体语态”保存卡片。
- 点击“保存时体语态”后调用 `POST /course-console/unit/{unitId}/writing/mount/save`。
- 左侧底部“更换 / 蓝图 / 任务 x”按钮需可点击。

## 改动点列表
- 新增 `ManageUnitWritingPipelineView / Controller / Binding`。
- 新增 `/course-console/unit/{unitId}/writing/stage/detail`、`/course-console/unit/{unitId}/writing/mount/save` 请求方法。
- 新增路由常量与 `TagRoutes` 注册。
- 在课程页“写作管线”入口接入新页面跳转。
- 接入左侧底部三个按钮的点击逻辑：
  - `更换`：进入独立的“更换单元写作阶梯”页，选中后回写当前单元挂载。
  - `蓝图`：进入当前阶梯对应的文章蓝图详情页。
  - `任务 x`：进入当前单元的写作任务列表页。

## 关键设计 / 关键决策
- 页面继续严格使用 `tagText` 路由模板。
- 直接消费接口原始 DTO 渲染，不新增页面中间结构，不做拍平映射。
- 左侧阶梯卡复用 `ZhenxieWriteCatalogCardWidget`，起承转合结构条继续复用 `ZhenxieCompositionSlotStripWidget`。
- 右侧“时 / 体 / 态”按钮文案与可选项直接取 `grammarScopeMeta`，当前选中态直接取 `grammarScope`。
- 课程页入口不再依赖 `taskCount > 0` 才可点击，保证“已挂阶梯但暂无任务”时也能进入写作管线页。
- `更换` 保存时沿用当前页草稿态的 `grammarScope`，并调用 `mount/save` 一次性更新 `stageNid + grammarScope`。

## 兼容性影响与注意事项
- 本次只新增管理端写作管线页，不改已有任务列表页与任务编辑页逻辑。
- 右侧卡片字体统一保持 `16` 及以上。
- `更换` 依赖新增的专用页面 `manage_unit_writing_stage_pick`，不再复用原“写作阶梯页”。

## 待确认问题 / TODO
- 若后续要支持“未挂载阶梯”时直接选阶梯，需要补空态下的选择动作。
