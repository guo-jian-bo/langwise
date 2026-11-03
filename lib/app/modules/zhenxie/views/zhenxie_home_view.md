# 甄写首页说明

## 目标与验收口径
- 基于 `ui_ux/src/pages/zhenxie/ZhenXieUserHome.tsx` 还原 Flutter 版甄写首页的整体骨架与视觉层级。
- 接入 `GET /languages/write/zhenxie/home`，首页主要展示数据改为以后端返回为准。
- 接口成功或失败都不再做本地兜底；接口里有值才显示，没有值就不显示。

## 改动点列表
- `zhenxie_controller.dart` 新增首页接口请求和首页数据解析模型，请求 loading 改为使用项目统一 `ToastUtils.showLoading / hideLoading`。
- `zhenxie_view.dart` 改为从 controller 读取首页数据，并按“有就显示，没有就不显示”的规则渲染标题、统计、里程碑和各卡片内容。
- 考点卡片改为复用与词法 / 句法 / 章法一致的卡片骨架。
- 写作课卡片接入 `writeCourseInfo`：标题取 `levelName · moduleName`，副标题取当前单元（`units` 中 `current=true`，无则第一个），进度取 `moduleProgress`（0~1 小数），单元方块按 `units` 渲染并最少补足四个占位块。
- 新增 `lib/common/https/zhenxie.dart`，收敛甄写首页接口请求。

## 关键设计与关键决策
- controller 中原始首页数据保持与接口字段一一对应，避免为首页再包一层额外“业务模型”。
- 页面只对你明确说明的异常数据做局部保留策略：章法卡片槽位区继续使用旧本地示意。
- 句法槽位区按接口数据渲染，每一行中 `content` 不含英文字母时使用虚线边框。
- 写作课卡片单元方块三态：占位块最淡（虚线）、`units` 内单元为中间色、`current=true` 的当前单元最深；方块内显示单元名。
- 底部按钮文案由 `units` 是否存在 `current=true` 决定：有则「继续学习」，无则「开始学习」。
- 写作课卡片右上角「当前目标」暂不展示。
- 写作课卡片整卡与底部按钮都跳转 `Routes.OFFICIAL_COURSE_DETAILS_LEVEL`，参数取 `writeCourseInfo` 的 `courseId / levelId / moduleId`，`units` 中存在 `current=true` 时额外带 `unitId`，否则不带。

## 兼容性影响与注意事项
- 接口失败时不再额外维护页面级失败状态，保留项目既有失败处理。
- 接口成功但字段缺失时，相关标题、描述、chips、里程碑、卡片会直接隐藏，不补默认文案。
- 页面其他卡片点击行为仍保持当前 Toast 逻辑，写作课卡片已接真实跳转。

## 待确认问题或 TODO
- 后端修正章法 `slotCombinationItems` 和写作课内容区字段后，可再把对应本地占位内容移除。
