# Lesson Filter And Initial Scroll Fix

## 目标与验收口径
- 后台模块详情页的 lesson 列表不再展示“单元测试”项。
- 从课程详情页携带 `unitId` 进入模块详情时，底部 unit tab 与主列表滚动位置保持一致。

## 改动点列表
- 在 `_buildDisplayLessons(...)` 中追加过滤 `isUnitTEST`。
- 在 `_onFetchPages(...)` 首次命中外部传入的 `unitId` 时：
  - 保持 tab 切换到对应 unit
  - 在首帧渲染后触发 `_scrollToUnitSectionByIndex(...)`

## 兼容性影响与注意事项
- 仅修改 `manage_module_detils_controller.dart`。
- 只在首次消费外部传入 `unitId` 时执行自动滚动，不影响页内手动切 tab 的现有行为。
