## 目标与验收口径

- 在管理端从“范文”或“给拍范文”进入的任务详情页标题区，为“编辑”按钮右侧新增“重新生成”按钮。
- 点击“重新生成”后进入“写单元范文”页，不传 `exemplarCompositionId`。
- 当“写单元范文”页返回成功后，当前详情页继续自动返回上一页。
- 若当前详情页路由参数里存在 `role = given`，则“重新生成”和“编辑”跳转时继续透传该参数。

## 改动点列表

- `zhenxie_task_details_controller.dart`
  - 新增 `role` 路由参数接收。
  - `toManageEditor()` 在范文模式下补透传 `role = given`。
  - 新增 `toManageRegenerateExemplar()`，用于跳到“写单元范文”页。
  - “重新生成”返回成功后，不在当前详情页原地刷新，而是继续 `Get.back(result: true)` 返回上一页。
- `zhenxie_task_details_view.dart`
  - 在标题栏“编辑”按钮左侧新增“重新生成”按钮。
  - 仅在管理端且 `routeMode == exemplar` 时显示。

## 关键设计/关键决策

- “重新生成”只在从列表“范文 / 给拍范文”进入的详情页显示，因此用 `routeMode == WritingBoardModeEnum.exemplar` 控制，不扩散到任务态或批改态。
- “重新生成”进入范文页时不传 `exemplarCompositionId`，以确保进入“写单元范文”而不是“编辑单元范文”。

## 兼容性影响与注意事项

- 原有“编辑”按钮仍保留原链路，只额外补传 `role = given`，避免给拍范文上下文在详情页丢失。
- 普通范文详情页若无 `role` 参数，不会新增额外业务参数。

## TODO

- 联调确认“给拍范文”详情页点击“重新生成”后，范文编辑页右侧是否按 `role = given` 正常展示对应操作按钮。
