# 写作阶梯编辑页对齐 React 说明

## 目标与验收口径

- 将 `zhenxie_composition_stage_edit_view.dart` 的页面骨架和字段排布收敛到 React `CompositionStageEditPage.tsx` 的结构。
- 保留现有 Flutter 管理端公共组件与既有保存逻辑，不改接口、不改提交 payload。
- 去掉当前 Flutter 页面里 React 没有的多余区域，避免页面信息过重。

## 改动点列表

- 保留顶部 `BreadcrumbWidget`，不额外增加返回按钮。
- 页面主体改为 React 同款双栏：
  - 左侧封面、封面说明、蓝图名、蓝图 ID
  - 右侧标题、阶梯 ID、基础表单、规则、拍位、水平档、底部按钮
- 去掉原来的：
  - 规则配置卡片壳
  - 拍位配置卡片壳
  - 里程碑卡片壳
  - 统计区
- 拍位区域改成 React 同款单行结构：
  - 左侧拍名
  - 中间段型下拉
  - 右侧 fill 下拉
- 文首/文末也改成和 React 一致的单行下拉结构。
- 输入框和下拉继续复用现有 `CardInputWidget`、`IconDropdownSelectWidget`、`CopyTagWidget`、`ManageButton`。

## 关键设计 / 关键决策

- 这次只改 view，不动 controller 的数据同步、校验、保存逻辑，确保行为兼容。
- `CopyTagWidget` 继续承担 React `AdminEntityId` 的角色，避免新增一套只为视觉存在的薄壳组件。
- React 中展示的家族名，Flutter 当前详情数据里没有直接可用字段；本次不伪造、不兜底，直接不展示。

## 兼容性影响与注意事项

- 取消了统计区后，页面信息更接近 React，但不再在编辑页展示 `learnedCount / taskCount`。
- `CardInputWidget` 与 `IconDropdownSelectWidget` 的视觉仍会保留 Flutter 管理端现有控件风格，因此是“结构对齐 React、组件风格跟随项目”的实现。
- 保存成功后的返回逻辑保持现状，不做额外改动。

## 待确认问题 / TODO

- 若后续需要和 React 完全一致地展示蓝图家族名，需要确认详情接口是否补该字段，或额外补一次家族信息查询。
- 若后续希望连顶部返回按钮也完全对齐 React，可以在面包屑下方再补一个轻量返回入口。
