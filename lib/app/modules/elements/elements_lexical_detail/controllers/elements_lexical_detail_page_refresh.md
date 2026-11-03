# 目标与验收

- 目标：让同义反义详情页控制器接入页面刷新感知能力。
- 验收：控制器支持 `PageRefreshAwareMixin`，并在设置页返回后重新拉取详情数据。

# 改动点

- 在 `elements_lexical_detail_controller.dart` 中新增 `PageRefreshAwareMixin`。
- 重写 `onReturnPageRefresh`，返回页面时调用 `getDetail()`。

# 关键设计

- 保持与单词/短语/句子详情页一致的页面刷新接入方式。
- 返回刷新直接复用已有 `getDetail()`，不新增额外刷新链路。

# 兼容性影响与注意事项

- 仅影响同义反义详情页控制器。
- 不改接口参数、不改页面展示逻辑。

# TODO

- 实际从右上角设置页返回一次，确认详情页会重新刷新。
