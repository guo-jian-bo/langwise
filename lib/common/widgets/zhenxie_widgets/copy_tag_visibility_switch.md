## 目标与验收口径

- 为 zhenxie 公共详情组件补充 `showCopyTags` 开关。
- 默认值保持 `true`，确保管理端现有展示和交互不变。
- 用户端后续复用这些组件时，传 `showCopyTags: false` 后，不再展示 `CopyTagWidget` 类型的可复制标签。

## 改动点列表

- `pattern_blueprint_item_widget.dart`
  - 新增 `showCopyTags`
  - 控制句型 / 句子复制标签显隐
- `sentence_slot_map_widget.dart`
  - 在 `SentenceSlotExampleWidget` 新增 `showCopyTags`
  - 控制内层句型复制标签显隐
- `same_group_compare_highlight_text_widget.dart`
  - 新增 `showCopyTags`
  - 控制句子复制标签显隐
- `same_group_compare_table_widget.dart`
  - 新增 `showCopyTags`
  - 控制轨值 / 对照复制标签显隐，并向高亮句子组件透传
- `same_group_compare_sentence_table_widget.dart`
  - 新增 `showCopyTags`
  - 控制对照 / 轨值复制标签显隐，并向代表句相关组件透传
- `sentence_pairing_link_table_widget.dart`
  - 为配链相关几个公共组件新增 `showCopyTags`
  - 控制对照 / 句子 / 句型 / 配对复制标签显隐

## 关键设计 / 关键决策

- 不修改 `CopyTagWidget` 全局行为，避免影响已有管理端页面。
- 开关放在业务公共组件层，由调用方按场景决定是否展示。
- 本次只处理 `CopyTagWidget`，不调整 `SelectableText` 的可选择能力。

## 兼容性影响与注意事项

- 所有新增参数都带默认值 `true`，属于向后兼容改动。
- 当前仓库里已有管理端调用方不需要改动。

## 待确认问题 / TODO

- 后续用户端接入这些组件时，在对应调用处显式传 `showCopyTags: false`。
- 若未来用户端还需要禁用 `SelectableText` 的复制能力，再单独补一个更细粒度的开关。
