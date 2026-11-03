# elements_sentence_detils_v2_controller 说明

## 目标

为句子详情页 V2 提供独立 controller，先把 V2 数据加载链路和默认分析层逻辑收口出来。

## 本次改动

- 新增 `ElementsSentenceDetilsV2Controller`
- 解析路由入参：
  - `contentId`
  - `jumpType`
  - `semanticIds`
  - `layer`
- 调用 `/en/sentence/detail/v2`
- 保存 V2 原始实体
- 将旧 `jumpType` 映射到 V2 `layer`

## 关键决策

- 保留旧 `jumpType` 透传给接口，兼容现有跳转语义
- `module` 不再原样透传旧分析模块值，只允许：
  - `PRONUNCIATION_MEANING`
  - `CORE_COMPONENTS`
  - `VIEW_LEVEL`
  - `MEMORIZE_SENTENCE`
- `layer` 优先级：
  1. 显式 `layer` 入参
  2. 旧 `jumpType` 映射
  3. 默认 `chunks`
- 暂不接管旧页面 UI，只提供并行的 V2 控制层

## 非目标

- 不改左侧媒体区域
- 不改旧句子详情页右侧 UI
- 不改单词详情页 UI
- 不改短语详情页 UI

## 后续建议

- 下一步由 V2 详情壳消费该 controller
- 分析页拆分后，不要再把旧 tab 状态继续挂回旧 controller
