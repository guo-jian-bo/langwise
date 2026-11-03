# 真题列表页重建说明

## 目标与验收口径

- 将真题列表页切换为后端接口直驱，不再依赖旧首页 controller、本地假数据和本地筛选排序。
- 页面底部直接复用 `FilterStripWidget`，接入：
  - `GET /languages/write/zhenxie/exam/task/query/meta/group/list`
  - `POST /languages/write/zhenxie/exam/task/pages`
- 列表按两列网格渲染，分页固定每次 30 条，支持下拉刷新和上拉加载更多。
- 卡片业务文案固定取中文；业务色从后端 `milestoneColors / familyColors` 里按当前 `LIGHT / DARK` 主题取值。
- 真题详情暂不接入，列表卡片当前不响应点击。

## 改动点列表

- `controllers/zhenxie_exam_tasks_controller.dart`
  - 删除旧的本地任务数据、地区弹层、本地筛选排序逻辑。
  - 新增真题列表元数据加载、分页加载、搜索/筛选/排序状态管理。
  - 兼容路由里已有的旧 query key，并映射到新接口的 filter code。
- `views/zhenxie_exam_tasks_view.dart`
  - 重写为 `Scaffold + BreadcrumbWidget + Expanded body + bottomNavigationBar` 结构。
  - 列表主体改为两列真题网格。
  - 底部改为通用 `FilterStripWidget`，不再自造筛选 UI。
  - 卡片直接使用接口 DTO 渲染，业务色按后端颜色索引取值。
- `bindings/zhenxie_exam_tasks_binding.dart`
  - 移除对 `ZhenxieExamController` 的注入依赖。
- `../zhenxie_exam/models/zhenxie_exam_models.dart`
  - 新增真题列表相关原始 DTO：meta、page、card、label、color。
- `../../../common/https/zhenxie.dart`
  - 新增真题列表元数据和分页请求方法。

## 关键设计 / 关键决策

- 保留现有 `ZhenxieExamTaskQuery`，只作为路由入参兼容层；真题列表实际渲染数据改用新的原始 DTO。
- 排序元数据虽然是按组返回，但接口只接受单个 `order`，因此在 view 里拍平成单一排序列表展示。
- `topic / stageNid` 这类元数据接口不下发的隐藏筛选项，仍支持通过路由参数透传到分页请求。
- 考段色优先使用接口返回的 `textColor / color / backgroundColor / borderColor`；家族色若只返回背景色，则直接以该色作为主色参与卡片渲染。

## 兼容性影响与注意事项

- 当前重置操作会同时清空隐藏筛选项（如 `topic / stageNid`），行为与旧页面整体清空保持一致。
- 旧的真题详情跳转链路本次未接；如果后续需要从对比页或其他入口联动到真题列表，可再补路由跳转实现。
- 当前只做静态检查，未执行真机/浏览器联调。

## 待确认问题 / TODO

- 若后续需要完全从对比页进入真题列表，需补 `zhenxie_exam_compare_controller.dart` 中 `openTasks(...)` 的实际跳转。
- 若卡片 UI 还需要继续贴浏览器版视觉稿，可基于当前接口链路继续微调样式，不需要再改数据层。
