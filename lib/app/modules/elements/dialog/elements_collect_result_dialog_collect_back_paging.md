## 目标与验收口径

- 结算弹窗点击底部“继续”后，收卡动画改回使用 `ElementsTypeCardWidget(side: CardSide.BACK)`。
- 收卡动画最多只飞 `10` 张卡片。
- 升级卡片列表改为分页加载，避免一次性渲染过多 `ElementsDictReadCard` 导致卡顿。

## 改动范围

- `lib/app/modules/elements/dialog/elements_collect_result_dialog.dart`
  - 首屏请求改为携带 `offset/limit`。
  - 弹窗列表滚动触底后继续懒加载。
  - 收卡动画卡片改为通用卡背。

## 关键设计

- 分页参数先按 `offset/limit` 约定接入，当前页大小固定为 `10`。
- 是否还有下一页，先按“本次返回数量是否达到 pageSize”判断，不额外依赖 `total/count`。
- 为了避免分页过程中已展示上报影响后续 `offset` 结果，`cuCardAlready` 从“弹窗初始化时”延后到“点击继续时”执行。
- 已展示上报只覆盖当前已加载出来的卡片；未加载出来的卡片保持未上报状态，后续仍可继续展示。

## 非目标

- 不改详情页“加入记忆”那条 `SimpleDictionaryCollectDialogWidget` 收卡链路。
- 不改接口返回结构解析，仍然复用 `KnowledgeCommonEntityList`。
- 不抽公共收卡组件，先只处理结算弹窗。

## 兼容性与注意事项

- 弹窗展示卡片继续使用 `ElementsDictReadCard`，只在收卡动画阶段切回 `CardSide.BACK` 通用卡背。
- 若后端后续明确提供稳定分页字段或总数，再按真实协议替换当前的“返回数量判定 hasMore”方案。
