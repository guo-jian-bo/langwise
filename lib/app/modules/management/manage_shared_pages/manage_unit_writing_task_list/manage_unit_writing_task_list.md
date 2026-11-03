# 写作任务页说明

## 目标与验收口径
- 新增管理端“写作任务页”。
- 从模块详情页的写作任务卡片点击进入。
- 页面进入后调用 `GET /course-console/unit/{unitId}/writing/task/list`。
- 列表每行展示 3 个任务卡片。
- 卡片复用 `ZhenxieWriteCatalogCardWidget`。
- 右下角展示“新建任务”浮动按钮，仅做 UI，不处理点击逻辑。

## 改动点列表
- 新增 `ManageUnitWritingTaskListView / Controller / Binding`。
- 新增 `/course-console/unit/{unitId}/writing/task/list` 请求方法。
- 新增与接口原字段一一对应的写作任务列表 DTO。
- 在模块详情页写作任务卡片处接入跳转。
- 新增路由常量与 `TagRoutes` 注册。
- 当列表项返回 `role = given` 时，底部额外显示“写给拍范文 / 给拍范文”按钮。

## 关键设计 / 关键决策
- 直接使用接口原始 DTO 渲染页面，不新增中间结构，不做拍平映射。
- 任务卡片直接喂给 `ZhenxieWriteCatalogCardWidget`，不复用旧的 `CompositionTaskModel` 链路。
- `slotStrip` 使用当前接口里的 `stage` 原始字段直接渲染，未额外转换到甄写旧模型。
- 当前接口未提供答案形式展示文案时，沿用通用卡片默认值。
- 当 `givenCompositionId` 为空时，按钮显示“写给拍范文”，样式与“写范文”一致，点击进入范文编辑页并透传 `role = given`。
- 当 `givenCompositionId` 有值时，按钮显示“给拍范文”，样式与“范文”一致，点击链路与普通“范文”一致，但 `compositionUid` 改为 `givenCompositionId`，并额外透传 `role = given`。

## 兼容性影响与注意事项
- 当前仅新增管理端页面，不改已有 `zhenxie-composition-writing` 页面逻辑。
- 卡片底部按钮当前仅展示 UI，未接业务动作。
- 当前未额外请求文类名称，卡片标签仅展示难度与蓝图。
- 普通“范文”按钮仍保持原链路，只有 `role = given` 的 item 才会新增给拍范文入口。

## 待确认问题 / TODO
- “新建任务”按钮后续跳转目标页与参数。
- 卡片底部“删除任务 / 编辑任务 / 范文”三个按钮的交互链路。
