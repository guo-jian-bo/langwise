# ElementsAdaptiveTagTextWidget

## 目标与验收口径
- 抽出“正文 + 行内固定尺寸组件”两行自适应展示组件。
- 组件需要兼容 `WidgetSpan`，不依赖 `AutoSizeText.rich`。
- 调用方可以自行决定正文后面跟什么组件，公共层只负责流式排版和字号收缩。

## 改动点列表
- 提供 `ElementsAdaptiveTagTextWidget` 组件。
- 组件改为直接接收 `trailingWidgets`，由业务侧传入带固定 `width` / `height` 的 `SizedBox` 组件列表。
- 新增通用文本测宽能力，便于业务侧自行计算行内组件尺寸。

## 关键设计 / 关键决策
- 不使用 `AutoSizeText.rich`，因为带 `WidgetSpan` 的富文本在其内部测量链路里会触发断言。
- 组件内部继续使用 `TextPainter + PlaceholderDimensions` 预估是否超行，再二分收缩正文字号。
- 公共层不再内置 `WordInflectionInfoTagWidget`，避免把正文后面的组件形态限制死。

## 兼容性影响与注意事项
- 行内组件尺寸改为由调用方显式传入，测量结果会直接参与换行计算。
- 如果调用方传入的 `width` / `height` 与真实组件尺寸不一致，可能出现测量误差。

## 待确认问题或 TODO
- 后续句子详情若需要同样的两行限制能力，可直接按当前 API 传入自己的 `WidgetSpan` 组件。
