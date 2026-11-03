## 目标与验收

- `CompositionTaskModel` 对齐最新接口返回，支持 `updated` 与 `memberWritingStatus`。
- 保证通过 `task.toJson()` 转给其他模型时，不丢新增字段。

## 改动点

- 新增 `CompositionTaskMemberWritingStatusModel`。
- 在 `CompositionTaskModel` 中补充：
  - `updated`
  - `memberWritingStatus`
- 同步更新 `fromJson` / `toJson`。

## 关键设计

- `colors` 直接复用项目已有 `LanguageConfigColorEntityThemeColors`，保持后端主题色结构原样透传。

## 兼容性影响

- 旧接口无这两个字段时，解析结果仍保持兼容。
