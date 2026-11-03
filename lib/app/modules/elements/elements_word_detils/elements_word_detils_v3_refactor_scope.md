# 单词详情页 V3 重构范围说明

## 目标与验收口径

- 将当前单词详情页重构为**独立页面布局**，不再沿用旧的卡片详情页右侧模块嵌套结构。
- 页面继续复用现有路由 `Routes.EN_WORD_DETAIL`，但内容区按新 UI 全量重排。
- 接入新的单词语义详情接口数据，按新字段完成展示。
- 完成后，页面应满足以下验收：
  - 使用 `rights` 判断整页权限状态。
  - 左侧固定宽度，按“媒体区 -> 发音区 -> 构词区”渲染。
  - 右侧按“顶部标签 -> 释义+记忆按钮 -> 分析卡片区 -> 固定 tabbar”四层布局渲染。
  - 分析卡片区按当前确认的排布展示：上排“句子 + 词源”，下排“短语 + 语法 + 同义”。
  - 点击分析卡时，本次先不跳转；统一按当前状态做 toast 提示。
  - 句子 / 短语英文行中的 `US`、`UK` 按钮尽量成组贴在内容尾部，放不下则两颗一起换到下一行。

## 修改范围

本次预计修改以下范围：

- `lib/app/modules/elements/elements_word_detils/`
  - 重构 `views/elements_word_detils_view.dart`
  - 重构 `views/elements_word_detils_content_widget.dart`
  - 精简 `controllers/elements_word_detils_controller.dart` 中与旧模块体系强绑定的逻辑
- `lib/common/entities/card_word_detils_entity.dart`
  - 补齐新接口字段实体：
    - `favorited`
    - `morphologyPreview`
    - `analysisEntries`
    - `analysisData`
    - 句子 / 短语 / 词源 / 同义预览所需子结构
- `lib/common/https/elements.dart`
  - 单词详情接口切换至新版本路径

## 本次明确要做

### 1. 页面结构重搭

- 单词详情页主布局改为常规 `Column` / `Row` 结构。
- 页面自身不再使用旧的 `ElementsDetailLayout`、右侧浮动 rail、底部浮动条组合。
- 右侧底部 tabbar 作为正常布局层存在，不使用 `Stack` 浮在页面上。

### 2. 左侧区域

- **复用旧能力**
  - 媒体区
  - 发音区
- **新增**
  - 构词区：基于 `morphologyPreview` 渲染

### 3. 右侧顶部信息区

- 左：词性标签，使用当前语义项对应的 `pos`
- 右：难度标签，使用 `semantic.difficulty`
- 下方释义区：
  - 左：`semantic.descriptions` 的英文和中文两行
  - 右：`favorited` 按钮状态展示

### 4. 分析卡片区

- 基于 `analysisEntries` 渲染卡片公共外壳
- 卡片公共结构包含：
  - 顶部 60 高度标题区
  - 中间 child 预览区
  - 底部右下 56x56 角标按钮
- 基于 `analysisData` 渲染具体内容：
  - `grammar`
  - `sentences`
  - `phrases`
  - `memory`
  - `synonyms`

### 5. 义项切换

- 继续使用 `semanticItems` 作为底部切换源
- 切换义项后重新请求 / 使用缓存刷新页面内容

## 本次明确不做

- 不接分析卡片的页面跳转
  - 语法页
  - 句子册
  - 短语册
  - 同义词页
  - 词源详情页
- 不保留旧页面里的右侧模块自动定位逻辑
- 不保留旧页面里的浮动 action rail
- 不复用旧的右侧模块渲染体系
- 不处理旧 `moduleItems` 驱动的右侧操作入口
- 不继续沿用旧的“额外回查当前义项 favorited 状态”逻辑；本次以新接口返回的 `favorited` 为准

## 本次会被替换掉的旧结构

以下旧结构会在单词详情页中被替换掉：

- `ElementsDetailLayout` 页面内容壳
- 右侧旧释义大模块滚动区
- 右侧浮动 action rail
- 底部浮动 `ElementsSemanticBottomBar`
- 旧模块列表 `moduleItems` 驱动的展示与交互
- 旧的自动打开模块、模块详情懒加载、模块定位相关逻辑

## 兼容性要求

- 路由保持不变，仍走 `Routes.EN_WORD_DETAIL`
- 左侧媒体与发音能力继续可用
- 权限态仍由 `rights` 控制
- 义项切换能力继续保留
- 本次不修改其他详情页（句子 / 短语 / 词素）的结构和路由

## 边界条件

- `rights` 为锁定时，页面内容不响应交互，并展示锁态覆盖
- `morphologyPreview` 为空时，左下构词区隐藏
- `analysisEntries` 有项但对应 `analysisData` 为空时，卡片保留外壳并展示空态
- `sentences.previewList` / `phrases.previewList` 为空时，展示空态文案
- `semantic.descriptions` 缺失某语言时，仅展示存在的文本
- `semanticItems` 为空时，不渲染底部 tabbar
- `US` / `UK` 发音按钮需尽量保持成组，不拆开换行

## 说明

- 本文档用于约束本次本地重构范围。
- 若后续需要接入分析卡片跳转、更多交互或新的联动逻辑，另开改动讨论，不在本次范围内。
