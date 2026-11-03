# 单元语法 Hub 页说明

## 目标与验收口径
- Hub 页负责展示单元语法总览、Target 列表、句子列表和底部流水线。
- 「去审核」进入详情时，前端本地计算本轮 `candidate` 队列，并把 `reviewQueueUids` 一起带入详情页。
- 底部流水线统一以接口返回的 `pipeline.steps[].status / summary / actionText` 为准，不再由前端自行拼步骤文案。

## 改动点
- Hub 底部步骤状态从旧的 `locked / running / done` 三布尔，切换为 `status / summary / actionText`。
- 步骤按钮文案直接展示后端 `actionText`。
- 步骤说明文案直接展示后端 `summary`。
- 步骤按钮是否可点击优先由 `status` 控制：
  - `locked / running / skipped` 不可点
  - `todo / failed / done` 且 `actionText` 非空时可点
- 「去审核」不再依赖后端下发完整审核队列：
  - Hub 侧按当前全部 `candidate` Target 的 `pointOrder -> order -> uid` 排序生成 `reviewQueueUids`
  - 进入详情时只传当前首条和这份本地队列
- 句子列表卡片补上 `access=INTERNAL` 的「新创建」标。
- Hub 第一层「句子列表」tab 会按当前 `access=INTERNAL` 的句子总数展示琥珀色 `新 N` 提示。
- 句子列表的 `hasStructure=false` 不再一律显示灰色「未分析」：
  - 已挂 Target 的句子显示「分析句子」按钮
  - 未挂 Target 的句子保持只读「未分析」标签，避免误触发整批分析

## 关键设计
- 实体 `ManageUnitGrammarPipelineStepEntity` 增加 `status / actionText`，保持与后端字段一一对应。
- controller 不再根据 `code + done/running` 自行拼接“开始绑定 / 进行中 / 已完成”等按钮文案。
- Step 组件仅负责按 `status` 渲染颜色和禁用态，数据来源完全由后端驱动。

## 兼容性影响与注意事项
- 旧接口若仍只返回 `locked / running / done` 而没有 `status / actionText`，当前新逻辑不会完整生效。
- `review` 步骤仍然不是直接调一步接口，而是进入详情页审核流。
- 重新生成单元语法时，是否弹确认仍按当前步骤 `code=analyze && status=done` 处理。
- 单句「分析句子」当前改为带该句所挂的 `targetBadges[].targetUid` 组 `targetIds`，调用 `POST /unit/{unitId}/knowledge/grammar/actions/analyse-bound-sentences`。

## TODO
- 继续把句子卡和步骤区里剩余的旧说明文案收掉，完全对齐 0820 新版产品文档。
