## 语境词典｜卡片内容区「双语对照」显示规则

### 背景

语境词典列表页右下角有「双语对照」浮动按钮，可切换：

- 双语对照
- 原文语言
- 译文语言
- 隐藏文本

该设置会影响卡片内部 **媒体区域下方的内容区域**（标题、发音胶囊按钮下面的两行文本）。

### 目标行为（卡片内容区两行文本）

数据来源：`ElementsCardEntityDatas.gloss`（语言列表）。

- 双语对照：显示两行（英文 + 中文翻译）
- 原文语言：仅显示英文
- 译文语言：仅显示中文翻译
- 隐藏文本：两行都不显示

说明：

- 卡片顶部的标题（`content`）与发音（US/UK）不受该设置影响
- 若 `gloss` 没有对应语言文本，会回退为单行 `definition`（仅在非「隐藏文本」模式下）

### 实现位置

- 列表页入口（浮动按钮）：[dictionary_page.dart](file:///Users/guojianbo/code/langwise/lib/app/modules/elements/dictionary/views/dictionary_page.dart)
- 卡片内容区渲染（核心）：[ElementsCardFrontPanelWidget](file:///Users/guojianbo/code/langwise/lib/app/modules/elements/common/elements_card_front_panel_widget.dart)

`ElementsCardFrontPanelWidget` 内部通过 `ConfigController.userSetting.value.expandLang`（`LangPreference`）决定 `gloss` 的展示行数与语言筛选，并对 `LangPreference.none` 做「强隐藏」处理（不再回退显示 `definition`）。

