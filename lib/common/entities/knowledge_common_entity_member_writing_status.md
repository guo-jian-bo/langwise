## 目标与验收

- `KnowledgeCommonEntityListParamsData` 支持承接专项训练 writing 列表子项 `params.data` 里的 `memberWritingStatus`。

## 改动点

- 在 `KnowledgeCommonEntityListParamsData` 中新增 `memberWritingStatus`
- 在 `KnowledgeCommonEntityList` 中新增 `created`
- 同步补齐 `fromJson` / `toJson`

## 关键设计

- `memberWritingStatus` 保持后端原始结构，先以 `Map<String, dynamic>` 透传，不在公共实体层额外包装。

## 兼容性影响

- 旧数据不带这两个字段时保持兼容，字段为空。
