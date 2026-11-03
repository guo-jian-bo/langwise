# 句法 Tab 接入说明

## 目标与验收口径

- 在句子分析页接入 `syntax` content。
- 只做句法内容，不改语块、成分、关联和分析页底部 tab 结构。
- 树布局优先复刻 React 的 `layoutLeafAligned` 思路，验收以“树结构正确”为先。

## 改动点列表

- 新增 `elements_sentence_syntax_content_widget.dart`
  - 读取 `analysisData.syntax.constituencyParse` 与 `analysisData.syntax.posForms`
  - 解析 Penn Treebank S-expression
  - 按叶子遍历顺序固定句序，自底向上回填父节点纵向位置
  - 支持“显示 / 隐藏短语标签”
  - 初始进入时自动 fit 到可视区域
  - 点击叶子弹出 token 简要信息
  - 无数据 / 解析失败时统一使用项目空页面组件 `NotDataWidget`
- 修改 `elements_sentence_analysis_view.dart`
  - 将 `syntax` tab 的“待接入”替换为真实句法 content

## 关键设计 / 关键决策

- 不使用传统树布局均分兄弟节点，避免浅层兄弟被深子树顶偏，打乱叶子句序。
- 句法树叶子严格按 token 顺序展示，不复用语块 / 成分里的缩写合并逻辑。
- 颜色优先使用后端 `syntax.posForms[].color.textColor` 作为主色；背景使用主色透明度派生。
- `ROOT / SQ / SINV / WHNP` 等未进 `posForms` 的标签做本地兜底中英标题和灰色兜底。
- 弹窗保持项目当前简单风格，只展示单词、ID、原形、词性中英名。

## 兼容性影响与注意事项

- 本次不改数据模型结构，只消费现有 `analysisData.syntax`。
- 若后端没有返回 `constituencyParse`，页面展示空态。
- 若 `posForms` 缺少某些树节点标签，会走本地兜底，不影响树结构绘制。
- 内部短语节点的文本与颜色现改为优先匹配配置中心 `morphemeTypes`，未命中时再尝试 `upos`；叶子词节点仍保持原有 `syntax.posForms` 逻辑，不在本次调整范围内。

## 待确认问题 / TODO

- 当前优先保证树结构与句序正确，后续可再细抠与 React 的像素级间距对齐。
- 若设计上需要词性弹窗补更多字段，可在现有弹窗结构上追加，不建议另起复杂组件。
