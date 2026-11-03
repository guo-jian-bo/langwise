# 真题详情页说明

## 目标与验收口径
- 新增甄写真题详情页，接口直接使用 `GET /languages/write/zhenxie/exam/task/detail`
- 页面结构按真题详情浏览器稿实现：左侧题面正文，右侧能力/主题/写作课/同类真题
- 数据模型严格对齐后端原始 DTO，不额外拍平、压缩或改字段语义
- 页面按项目 `tagText` 多实例模板接入路由

## 改动点列表
- `lib/common/https/zhenxie.dart`
  - 新增 `getExamTaskDetail`
- `lib/app/modules/zhenxie/zhenxie_exam/models/zhenxie_exam_models.dart`
  - 新增真题详情 DTO、词数字段 DTO、能力 DTO、同类真题分组 DTO
- `lib/app/modules/zhenxie/zhenxie_exam_task_detail/`
  - 新增 `view / controller / binding`
- `lib/app/routes/`
  - 新增 `Routes.ZHENXIE_EXAM_TASK_DETAIL`
  - 注册 `TagRoutes` 与 `GetPage`

## 关键设计 / 关键决策
- 详情页正文 `fullText` 直接按 Markdown 渲染
- 同类真题分组 `relatedTaskGroups[].items` 直接复用列表卡片 DTO
- 业务色只读取详情接口返回的 `milestoneColors / familyColors`

## 兼容性影响与注意事项
- 未改旧的 `zhenxie_task_details` 模块，两者路由独立
- 未新增后端没有返回的中间结构
- 详情页首版只围绕 `xxx9.json` 已提供字段实现

## 待确认问题 / TODO
- 真题列表卡片是否直接跳当前新详情页
- 右侧能力/主题/写作课模块是否需要补齐点击跳转行为
