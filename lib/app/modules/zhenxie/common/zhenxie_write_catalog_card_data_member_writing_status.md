## 目标与验收

- `ContentCardData` 对齐最新返回结构，支持承接 `memberWritingStatus`。
- 保持已有 `updated` 字段透传能力不变。
- 本次只补模型字段，不新增 UI 展示逻辑。

## 改动点

- 在 `ContentCardData` 中新增 `memberWritingStatus` 字段。
- 在 `fromJson` / `toJson` 中补齐 `memberWritingStatus` 的解析与回写。

## 关键设计

- `memberWritingStatus` 直接复用甄写写作任务模型里的状态结构，不额外包装新 DTO。
- 当前字段先用于数据承接，后续若页面需要展示状态标签，可直接消费该字段。

## 兼容性影响

- 旧数据不带 `memberWritingStatus` 时，字段保持 `null`。
- 不影响现有卡片展示逻辑。
