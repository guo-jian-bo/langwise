# ZhenxieParagraphBlueprintOverviewTableWidget 实现提示词

## 目标与验收口径

- 该文件只维护一个公共组件：`ZhenxieParagraphBlueprintOverviewTableWidget`
- 组件职责是渲染“段落蓝图拍位摘要表”，用于：
  - 段落蓝图列表卡片的摘要预览
  - 写作目标页右侧蓝图摘要区
- 不再保留旧的 `ZhenxieParagraphBlueprintTableWidget`
- 组件必须继续复用 `ParagraphRhetoricalContainerWidget` 的顶部圆点、简称、连线结构
- 组件入参只接收最小必要数据，不整包传 `blueprint`

验收标准：

- 传入 `paragraphRhetoricalList + slotList` 就能正常渲染四拍摘要
- 写作目标页仍支持：
  - `beatSpanList`
  - `selectNid`
  - `onTap`
- 段落蓝图列表卡片可只传基础摘要数据，不必传交互参数
- `flutter analyze` 无报错

## 入参边界

推荐维持以下入参：

```dart
final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;
final List<ParagraphBlueprintEntityBlueprintsSlots?>? slotList;
final List<ParagraphWritingGoalEntityBeatSpan?>? beatSpanList;
final String? selectNid;
final void Function(String nid)? onTap;
```

约束：

- `paragraphRhetoricalList`：提供拍位顺序、拍名、颜色来源
- `slotList`：提供每拍状态、jobName、repeatMin、repeatMax
- `beatSpanList`：仅在写作目标页使用，用于控制是否禁用、是否降透明
- `selectNid`：仅用于高亮当前拍位
- `onTap`：可选；为空时只展示，不可交互

## 颜色规则

### 1. 颜色来源

- 不要再走 `ParagraphRhetoricalEntityList.color`
- 优先使用：

```dart
paragraphRhetorical?.currentThemeColor?.colorValue
```

- fallback 才允许退回主题色，例如 `AppTheme.cInverseOverlay5.color`

### 2. 文字颜色

- 标题统一：`AppTheme.cTextPrimary.color`
- 副标题统一：`AppTheme.cTextTertiary.color`
- 不要再使用数据里的 `textColorValue` 直接作为卡片标题颜色

## 三种状态样式规则

### 一、要写（required）

- 边框颜色：使用当前拍主题色，透明度 `0.3`
- 边框样式：实线
- 背景：使用当前拍主题色渐变
  - 上：`alpha 0.2`
  - 下：`alpha 0.08`
- 标题：`cTextPrimary`
- 副标题：`cTextTertiary`

### 二、可写（optional）

- 边框颜色：使用当前拍主题色，透明度 `0.3`
- 边框样式：虚线
- 背景：`AppTheme.cSurfaceLayerBase.color`
- 标题：`cTextPrimary`
- 副标题：`cTextTertiary`

### 三、空的（empty）

- 边框颜色：`AppTheme.cBorderDark.color`
- 边框样式：虚线
- 背景：`AppTheme.cSurfaceLayerBase.color`
- 标题：`cTextPrimary`
- 副标题：`cTextTertiary`
- 保留中间斜杠遮罩

## 交互规则

### 1. 普通摘要卡场景

- 可只传：
  - `paragraphRhetoricalList`
  - `slotList`
- 不传 `beatSpanList / selectNid / onTap`
- 此时组件只负责静态展示

### 2. 写作目标页场景

- 若传了 `beatSpanList`
  - 当前拍没有对应 `beatSpan` 时，卡片降透明
  - 同时禁用点击
- 若传了 `selectNid`
  - 选中拍位边框改为 `AppTheme.cWritePrimary.color`
  - 选中态边框强制改为实线
- 若传了 `onTap`
  - 点击卡片回传 `beatNid`

## 结构要求

- 外层继续使用 `ParagraphRhetoricalContainerWidget`
- `statusList` 由 `paragraphRhetoricalList + slotList` 派生
- 每个格子的 UI 由 `statusItemWidgetBuilder` 输出
- 不要再新起一套顶部 header / rail 实现

## 非目标

- 不在这里处理页面级滚动、tab 联动、列表布局
- 不在这里处理蓝图详情跳转
- 不在这里处理段型标题区、句数标签、编辑按钮

## 实现提醒

- 保持外科手术式修改，不要顺手改动别的 zhenxie widget
- 新增方法和字段要有简短注释
- 尽量复用现有状态映射与 `ParagraphRhetoricalStatusEnum`
- 不要引入写死颜色值，统一走主题色或数据主题色

## TODO / 后续可收敛点

- 若后续发现 `beatSpanList` 的“禁用 + 降透明”规则需要复用，可单独抽成私有辅助方法
- 若后续还有别的段落蓝图表变体，优先继续扩展这个组件，不再新建第二套同类组件
