## 目标与验收口径
- 新增管理端“写作任务编辑页”。
- 从写作任务列表页右下角“新建任务”按钮进入。
- 页面进入后调用 `GET /course-console/unit/{unitId}/writing/task/editor`。
- 按四步页骨架渲染，先完整落第 1 步“编辑写作任务”。
- 第 1 步顶部复用 `ZhenxieWriteCatalogCardWidget` 渲染当前阶梯卡片，下方直接绑定 `task.name` / `task.stem` 的中英文输入框。

## 改动点列表
- 新增 `ManageUnitWritingTaskEditorView / Controller / Binding`。
- 新增 `/course-console/unit/{unitId}/writing/task/editor` 请求方法。
- 新增 editor 初始化接口对应的原始 DTO。
- 新增路由常量与 `TagRoutes` 注册。
- 将写作任务列表页“新建任务”按钮接入 editor 页跳转。
- 第 2 步题面媒体补齐 UID 录入与上传两种展示模式。

## 关键设计 / 关键决策
- editor 页继续严格使用 `tagText` 路由模板。
- 直接保存 editor 接口返回的原始结构，不新增中间 ViewModel。
- 第 1 步顶部卡片直接消费 `stage` 原始 DTO；结构条继续复用 `ZhenxieCompositionSlotStripWidget`。
- 第 2 步媒体保存仍只提交 key：图片取 `imageKey`，音频取 `fileKey`，视频取 `videoKey`。
- 第 2 步媒体展示区统一按“预览态”渲染：UID 录入成功后也直接展示图片 / 音频 / 视频资源，不再单独显示 UID 文本。
- 第 2 步图片 / 音频 / 视频统一使用“输入 UID / 上传媒体”双 Tab 弹窗；点击输入按钮或“替换”按钮进入弹窗，预览区域保持媒体自身交互。
- 第 3 步知识点列表保持原有样式，仅将文案从 `content` 调整为 `content + definition`，语法点列表保持原样。

## 兼容性影响与注意事项
- 当前只新增新建链路，不改原有任务列表卡片的编辑、删除、范文按钮逻辑。
- editor 接口路径本次沿用 `course_console.dart` 现有管理端请求前缀，写成 `/course-console/unit/{unitId}/writing/task/editor`。
- 第 4 步“保存任务”按钮当前仅保留骨架，尚未接 `create / edit` 提交。

## 待确认问题 / TODO
- 第 2 步音频查询接口当前返回字段存在 `audioUrl / fileUrl / fileurl` 三种口径，实体层已兼容解析。
- 第 3 步知识点和语法的选择交互、提交参数回写方式。
- 第 4 步提交时 `create` / `edit` 的入参组装与校验口径。
