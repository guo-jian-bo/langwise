# 单词分析卡片跳转页讨论文档

## 目标与验收口径

- 在单词详情页分析区接入点击跳转，覆盖 3 个入口：
  - `sentence`
  - `phrase`
  - `synonym`
- 点击后进入一个新的独立页面。
- 新页面以“词典卡片网格页”为主形态，卡片视觉和交互尽量与词典页一致。
- 页面分别调用：
  - `GET /languages/content/card/en/word/sentence/page`
  - `GET /languages/content/card/en/word/phrase/page`
  - `GET /languages/content/card/en/word/synonym/list`
- 句子 / 短语卡片需要支持局部高亮：
  - `previewForms` 决定高亮命中的内容
  - `pos` 决定高亮颜色

## 当前建议方案

### 1. 页面组织

- 推荐做 **一个通用路由 + 一个通用页面 + 一个通用 controller**。
- 通过 `type` 区分当前是 `sentence / phrase / synonym`。
- 原因：
  - 3 个入口形态高度一致
  - 仅数据接口和局部高亮规则有差异
  - diff 更小，后续维护更集中

### 2. 页面职责

- 页面只负责：
  - 顶部返回 / 面包屑
  - 网格列表
  - 下拉刷新
  - 上拉分页
  - 空态 / loading / rights 展示
- 页面默认不接词典页现有的：
  - 搜索
  - 筛选条
  - 底部过滤条
  - 右侧悬浮工具栏

原因：本次是分析卡片的“关联列表下钻页”，不是完整词典主页。

### 3. 卡片复用策略

- 外层网格和点击跳详情能力优先复用词典页现有实现：
  - `GridView.builder`
  - `ElementsCardGroove`
  - `ElementsTypeCardWidget`
- 可以考虑对 `ElementsTypeCardWidget` 做**向下兼容的可选扩展**，但要明确它只是分发入口，不是最终文本渲染点。
- 当前链路是：
  - `ElementsTypeCardWidget`
  - `ElementsWordCardWidget / ElementsPhraseCard / ElementsSentenceCard`
  - `ElementsCardFrontPanelWidget`
- 其中正文和 gloss 真正的文本渲染发生在 `ElementsCardFrontPanelWidget`。
- 所以更合适的扩展方式是：
  - 在 `ElementsTypeCardWidget` 增加一个可选的高亮配置参数
  - 由它继续透传到 `word / phrase / sentence` 三种卡片
  - 最后在 `ElementsCardFrontPanelWidget` 内决定是否按高亮模式渲染正文
- 这样做的好处：
  - 新页面可以直接复用统一卡片入口
  - 普通词典页不传这个参数时，行为完全不变
  - diff 能控制在公共卡片链路的最小范围内
- 这里建议扩的是“可选能力”，不是改现有默认行为。
- 推荐传入一个独立配置对象，而不是零散塞多个布尔值，避免后续参数继续膨胀。

### 4. 卡片扩展建议

推荐新增一个类似“高亮配置”的可选对象，语义上包含：

- `enabled`
- `previewForms`
- `highlightColor`

行为建议：

- `enabled == false` 或 `previewForms` 为空：走普通词典卡片
- `enabled == true` 且有 `previewForms`：正文按高亮规则渲染
- `highlightColor` 为空：自动降级为普通文本，不强行高亮

不建议的做法：

- 只改 `ElementsTypeCardWidget`，但不往 `ElementsCardFrontPanelWidget` 透传
- 在新页面里单独 fork 一套完整词典卡片 UI
- 为高亮新增很多碎片化参数，比如 `isHighlight`、`highlightWords`、`highlightTextColor`、`highlightContentOnly`

原因：

- 第一种改法落不到真正渲染层
- 第二种会扩大 diff，也更容易和现有词典卡片样式漂移
- 第三种后续维护成本高

## 数据与参数建议

### 1. 跳转入参

推荐从当前单词详情页传入：

- `type`
- `contentId`
- `semanticId`
- `title`

参数来源建议：

- `contentId`：`ElementsWordDetilsController.contentId`
- `semanticId`：`ElementsWordDetilsController.currentSemanticId.value`
- `title`：点击卡片对应的分析标题

### 2. 三个接口的参数差异

- `sentence`：需要 `contentId + semanticId`
- `phrase`：需要 `contentId + semanticId`
- `synonym`：这里也按 `contentId + semanticId` 传

### 3. 数据适配建议

- 新页面使用新的 controller，新做一套。
- 原因：
  - `DictionaryController` 当前走的是通用词典列表接口
  - 这次是 3 条专用接口
  - 参数、返回结构、标题语义都不同
- 但返回 `datas` 的单项结构和 `ElementsCardEntityDatas` 非常接近，适合做本地适配复用卡片组件

## 高亮规则建议

### 1. 高亮命中规则

- 句子 / 短语列表页按接口返回的页面级 `previewForms` 做命中
- 命中规则建议与当前单词详情页 `_buildHighlightSpans(...)` 保持一致：
  - 大小写不敏感
  - 优先匹配更长词形
  - 只命中完整 token 边界
  - 避免重叠高亮

### 2. 高亮颜色来源

- 不建议继续沿用当前单词详情页的：
  - “当前义项 `textStyle.borderColor/backgroundColor`”
- 这次更符合你要求的方案应该是：
  - 从 `ConfigController.colorConfigs.value.pos` 里取色
  - 再通过 `StatusUtils.getConfigColor(...)` 或 `StatusUtils.getConfigColorForAbbr(...)`
  - 用当前页返回的页面级 `pos` 去匹配颜色配置

### 3. 一个需要先确认的点

- `xxx6.json`、`xxx7.json` 的页面级确实都有：
  - `pos`
  - `previewForms`
- `xxx8.json` 当前样例里没有页面级 `previewForms`
- 因此这里按接口返回动态处理：
  - 如果同时拿到 `pos` 和 `previewForms`，则启用高亮
  - 如果缺少任意一项，则走普通词典卡片

## 修改范围建议

如果进入实现，建议范围控制在以下文件：

- `elements_word_detils_content_widget.dart`
- 新增分析卡片列表页 `view / controller / binding`
- `app_routes.dart`
- `app_pages.dart`
- `tag_routes.dart`（如果采用 tag 路由入口）

## 非目标

- 不改词典主页现有筛选 / 搜索逻辑
- 不全局改 `ElementsTypeCardWidget`
- 不全局改 `ElementsWordCardWidget / ElementsPhraseCard / ElementsSentenceCard`
- 不改现有单词详情页分析卡片的视觉样式
- 不顺手重构词典模块

## 当前最值得先拍板的边界问题

### A. 路由形态

我建议：

- 一个通用路由，比如“单词分析关联卡片页”

而不是：

- `sentence / phrase / synonym` 各做一个独立页面

### B. 页面范围

我建议新页面先只做：

- 面包屑 / 返回
- 网格卡片
- 分页
- 空态

不带词典主页那整套筛选工具栏。

### C. 高亮范围

我建议：

- `sentence`、`phrase` 做高亮
- `synonym` 先不做高亮，除非你这边确认线上真实接口也会返回 `previewForms`

### D. 颜色映射

我建议：

- 页面级 `pos` 映射 `ConfigController.colorConfigs.value.pos`

而不是继续复用当前单词详情页“当前义项 textStyle”取色逻辑。

## 待你确认

以下内容已确认：

1. 新页面按 **一个通用页面** 来做
2. 页面只保留 **简化版头部 + 网格列表**
3. 是否高亮按接口真实返回动态决定：
   - 有 `pos` 和 `previewForms` 才高亮
   - 否则走普通词典卡片
4. 点击网格卡片后，继续沿用现有词典卡片逻辑，跳到对应详情页

## 命名建议

为了贴近当前 `elements_*_detils` 模块的命名方式，推荐如下：

### 1. 页面路由

- 路由常量建议：
  - `Routes.EN_WORD_ANALYSIS_CARDS`
- 路由语义：
  - 单词详情分析卡片关联列表页

### 2. 页面 / controller / binding

- 页面：
  - `ElementsWordAnalysisCardsView`
- controller：
  - `ElementsWordAnalysisCardsController`
- binding：
  - `ElementsWordAnalysisCardsBinding`

### 3. 文件名

- `elements_word_analysis_cards_view.dart`
- `elements_word_analysis_cards_controller.dart`
- `elements_word_analysis_cards_binding.dart`

## 路由参数建议

推荐统一传以下参数：

- `type`
- `contentId`
- `semanticId`
- `title`

参数含义：

- `type`：`sentence / phrase / synonym`
- `contentId`：当前单词 `contentId`
- `semanticId`：当前选中义项 `semanticId`
- `title`：新页面顶部标题

## 跳转链路建议

推荐跳转链路如下：

```text
elements_word_detils_content_widget.dart
  └─ 点击 sentence / phrase / synonym 卡片
      └─ TagRoutes.toNamed(...)
          └─ Routes.EN_WORD_ANALYSIS_CARDS
              └─ ElementsWordAnalysisCardsView.to(...)
                  └─ ElementsWordAnalysisCardsBinding
                      └─ ElementsWordAnalysisCardsController
```

## 跳转方式建议

建议继续沿用项目当前 tag 路由模式：

- 在 `TagRoutes` 注册 `Routes.EN_WORD_ANALYSIS_CARDS`
- 页面提供静态 `to<T>({dynamic arguments, required String tag})`
- 从单词详情页点击后，使用唯一 tag 打开，避免多实例冲突

推荐的 tag 组织方式可以是：

- `'$tagText_analysis_$type_${controller.currentSemanticId.value}'`

这样能把：

- 来源页面实例
- 当前分析类型
- 当前义项

都带进 tag 里，降低多开冲突概率。

## 当前结论

基于现有代码结构，我认为：

- **可以扩展 `ElementsTypeCardWidget`**
- 但更准确地说，是扩展“词典卡片整条透传链路”
- 真正落高亮渲染的最佳位置是 `ElementsCardFrontPanelWidget`
- 新页面仍然应使用新的 `controller`
- 新路由、新页面、新 binding 的方向是成立的，而且边界清晰
