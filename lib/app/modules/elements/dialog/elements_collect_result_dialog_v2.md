## 目标与验收口径

- 将集卡结果弹窗的升级卡片查询接口从 `/languages/content/card/member/update/show/list` 切换到 `/languages/content/card/member/update/show/list/v2`。
- 按照 v2 接口返回的 `KnowledgeCommonEntityList` 结构渲染弹窗卡片。
- 弹窗内卡片统一切换为 `ElementsDictReadCard`，不再使用旧的 `ElementsTypeCardWidget`。
- 保持“继续 -> 收卡动画 -> 已展示上报 -> 首页/任务中心/词典页刷新”这条链路不变。

## 改动点列表

- `lib/common/https/elements.dart`
  - `getUpdateCardList` 改为请求 v2 接口。
  - 返回类型改为 `List<KnowledgeCommonEntityList>`。
  - 列表项改为按 `KnowledgeCommonEntityList.fromJson` 解析。
- `lib/app/modules/elements/dialog/elements_collect_result_dialog.dart`
  - 弹窗数据类型改为 `KnowledgeCommonEntityList`。
  - 列表卡片与收卡动画卡片都切换为 `ElementsDictReadCard`。
  - 卡片点击禁用，避免在弹窗里跳转详情。
  - 星级区域按 `memberStudy.starInfo` 是否存在决定是否展示。

## 关键设计 / 关键决策

- 保留 `getUpdateCardList` 方法名不变，只替换内部 endpoint 和返回模型，减少调用方扩散。
- `ElementsDictReadCard` 已经对齐 `KnowledgeCommonEntityList` 与 `memberStudy.starInfo` 结构，能直接复用词典页现有展示能力。
- 弹窗内不额外做旧结构兼容，也不做数据兜底，严格按 v2 返回结构渲染。

## 兼容性影响与注意事项

- 前端权限校验仍沿用原有 `contentCardMemberUpdateShowList` auth code，仅切换实际请求地址，避免影响现有权限放行逻辑。
- `ElementsDictReadCard` 的高度和顶部星级区域逻辑与词典页一致，因此弹窗单卡尺寸同步调整为 `346 / 546` 或 `346 / 567`。
- `cuCardAlready` 的上报结构未改，仍然使用 `contentType + contentId`。

## 非目标

- 不调整集卡弹窗的整体交互文案、动画节奏、按钮行为。
- 不改动“展示后标记已展示”的接口与刷新逻辑。

## TODO / 待确认

- 若后端后续将权限点也升级为 v2 路径，再同步评估是否需要替换 `HttpAuthCodes.contentCardMemberUpdateShowList` 的定义。
