# 单词详情页剩余模块完善讨论文档

## 目标与验收口径

- 继续完善单词详情页中尚未接入的 3 条能力：
  - 左侧「构词」item 点击跳转
  - 右侧分析卡片中的「词源记忆」点击跳转
  - 右侧分析卡片中的「语法」点击跳转
- 同时处理相关目标页的面包屑兼容问题：
  - `Routes.MANAGE_WORD_MORPHOLOGY_DETAILS`
  - `Routes.MANAGE_WORD_INFLECTION_DETAILS`
  - 将对应 controller 的 `ManageBreadcrumbMixin` 改为 `DualBreadcrumbMixin`
- 本次只基于现有详情接口返回的数据接入跳转，不新增额外接口，不本地拼装不存在的业务参数。

## 当前讨论范围

### 1. 左侧构词 item 点击

目标页：

- `Routes.MANAGE_WORD_MORPHOLOGY_DETAILS`

参考文件：

- `manage_word_morphology_details_controller.dart`
- `manage_word_morphology_details_view.dart`

当前页面支持两种入参模式：

- 词根：传 `key`
- 词素：传 `morphemeNid`

### 2. 右侧词源记忆

目标页：

- `Routes.ETYMOLOGY_MEMORY`

参考文件：

- `etymology_memory_controller.dart`

本次范围：

- 只接点击跳转
- 页面继续保持当前静态页面
- 不传额外参数

### 3. 右侧语法

目标页：

- `Routes.MANAGE_WORD_INFLECTION_DETAILS`

参考文件：

- `manage_word_inflection_details_controller.dart`

当前页面需要的核心参数：

- `familyKey`

## 已确认规则

### A. 左侧构词 item 跳转参数规则

`morphologyPreview.components` 中：

- 如果 `type == "root"`
  - 传 `key: content`
- 如果 `type != "root"`
  - 传 `morphemeNid: content`

也就是说，本次接入按组件当前返回的 `content` 直接作为目标页参数值使用。

### B. 右侧词源记忆

- 只做跳转
- 不传参数
- 继续使用当前静态页面

### C. 右侧语法

- 点击后跳转到 `Routes.MANAGE_WORD_INFLECTION_DETAILS`
- 参数从当前详情数据中直接取 `analysisData.grammar.familyKey`

### D. 面包屑兼容

以下 controller 需要从 `ManageBreadcrumbMixin` 切换到 `DualBreadcrumbMixin`：

- `ManageWordMorphologyDetailsController`
- `ManageWordInflectionDetailsController`

改动时需要遵循 `DualBreadcrumbMixin` 现有行为：

- 非管理端环境下，同时维护普通路由面包屑和管理端面包屑
- 管理端环境下，仅维护管理端面包屑

## 参数来源核对

### 1. 语法

当前详情数据中已可拿到：

- `analysisData.grammar.familyKey`

因此这条链路当前**参数充足**。

### 2. 构词

当前详情数据中可拿到：

- `morphologyPreview.key`
- `morphologyPreview.wordId`
- `morphologyPreview.components[].type`
- `morphologyPreview.components[].content`

本次按已确认规则处理：

- `root` 用 `content -> key`
- 非 `root` 用 `content -> morphemeNid`

这意味着本次实现默认接受一个前提：

- 组件里的 `content` 本身就是目标页可识别的参数值

### 3. 词源记忆

当前详情数据里虽然已有：

- `analysisData.memory`

但本次明确不接动态数据展示，因此这里**不依赖参数**。

## 建议修改范围

如果进入实现，建议范围控制在以下文件：

- `elements_word_detils_content_widget.dart`
- `manage_word_morphology_details_controller.dart`
- `manage_word_inflection_details_controller.dart`
- 如有必要，对应 view / 路由入口做最小配套调整

## 非目标

- 不改 `ETYMOLOGY_MEMORY` 页面为数据驱动页
- 不为词源记忆新增接口或补拉数据
- 不新增额外后端请求来补构词参数
- 不改单词详情页现有分析卡片视觉样式
- 不顺手重构管理端页面结构

## 当前仍需你确认的点

### 1. 构词参数是否接受“直接用 content”

虽然规则已经明确为：

- `root -> key: content`
- 非 `root -> morphemeNid: content`

但这里仍有一个实现前最好显式确认的小前提：

- 例如 `inter-`、`-tion` 这类带连字符的内容，是否就是目标页真实接受的 `morphemeNid`

如果你确认“就是直接传 content，不需要额外处理字符”，实现时我会严格按这个规则接，不做任何 trim、映射或转换。

### 2. 词源记忆页面标题与面包屑

由于词源记忆这次不传参数，页面标题将继续保持当前固定值：

- `词源记忆`

如果你接受当前静态页标题不随单词变化，本次可以直接接跳转，不再扩展参数。

## 当前建议方案

我建议本次实现按下面的最小闭环执行：

1. 左侧构词 item 接点击跳转
   - `root -> key: content`
   - 非 `root -> morphemeNid: content`
2. 右侧词源记忆只接跳转
   - 不传参数
   - 不改静态内容
3. 右侧语法接跳转
   - 参数直接使用 `familyKey`
4. 将两个管理端详情 controller 切到 `DualBreadcrumbMixin`

## 待你确认

1. 构词 item 的 `content` 是否确认“原样直传”，不做任何字符处理？
2. 词源记忆页是否确认本次只接跳转，不改标题和静态内容？
