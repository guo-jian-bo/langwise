# 单元目标添加语法页

## 目标与验收
- 在单元目标句法层底栏接通“添加语法”独立页。
- 页面流程对齐 React `AddGrammarFromMaterialsPage.tsx`：选材料 -> 召回 -> 勾资产 -> 追加。
- 顶部继续使用 Flutter 管理端现有面包屑，不改成 React 自定义头。
- 成功后返回当前单元目标页，并切回句法层的“语法”tab。

## 改动点
- 新增添加语法页控制器、绑定、视图。
- 新增 recall / from-materials / algorithm task status 的实体与请求封装。
- 句法主包 group 实体补充可选句组所需字段：`uid`、`assetType`、`assetNid`、`members`。
- 实现入口跳转与成功回流。

## 关键设计
- 页面独立请求 `GET /course-console/unit/{unitId}/knowledge/grammar/goals/sentence`，避免依赖父页临时状态。
- recall 后记录材料指纹；材料变更后标记为“需重新召回”，禁止拿旧名单直接追加。
- append 走真实异步任务轮询，按 `finished` 视为成功，其它非 `started/running` 状态视为失败。
- 面板里的请求预览展示真实 BFF 路径与 camelCase body，不走 React mock 的 `/api/algorithm/*` 口径。

## 兼容性与注意事项
- 当前主包 `groups` 若未返回 `uid`，页面会自动忽略该组，不影响句子召回流程。
- 追加成功后仅刷新句法主包；按当前后端口径，新建 `candidate` 不一定出现在主包 `approved` 列表里，这是已知限制。
- 本次不改 Hub、语法管线、句法主列表展示逻辑。

## TODO / 待确认
- 若后端最终确认 `groups` 还会补更多字段，可再把左侧句组信息进一步对齐 React mock 的展示细节。
