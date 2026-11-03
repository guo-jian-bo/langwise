# Elements Sentence Chunk Layout Helper

## 目标与验收口径

- 统一 `chunks + svoca` 顶部网格的布局数据结构
- 顶部网格按“`tokens -> columns`、`clauses -> 行来源`、`label -> 最小显示单元`”组织
- 一个 `clause` 最终只展开成两类行：`0..n` 行连接行 + `1` 行主行
- 保留余文机制，但规则尽量直接表达，不再靠 token 合列去隐式修正 header

## 改动点列表

- helper 继续输出 `columns / rows / pills`，不打破下半区依赖
- 顶部列改为按 token 顺序直接生成，一 token 一列
- `chunks` 与 `svoca` 继续共用同一套 helper，只切换主行 label 来源
- 行组装改为显式拆分 `_buildRows / _buildConjunctionRows`
- 保留孤儿余文行、尾部标点回挂、子句 token 从父句跳过等既有兼容规则

## 关键设计

- `columns`
  - 直接按 token 顺序生成
  - header 文案优先取原句对齐后的表层文本，取不到时回退 `token.text`
- `rows`
  - `clauses` 只作为行来源
  - 每个 clause 先产出独立连接行，再产出主行
- `pills`
  - 顶部网格的最小渲染单元
  - `chunks` 主行从 `clause.chunking` 生成
  - `svoca` 主行从 `clause.svoca.elements` 生成
  - 没落到任何 label 的 token 继续生成为 `余文`
- `textReference.start/end`
  - 统一按“覆盖第几个 token 到第几个 token”解释
  - 用来计算 label 的列区间，而不是再去驱动 token 合列

## 兼容性影响与注意事项

- 本轮只统一顶部网格规则，不动下半结构区的表现和交互
- `syntax / relations` 不在本轮范围内
- 为了保持现有点击、弹窗、颜色链路稳定，外部仍沿用 `SentenceChunkLayoutRow / Pill / Result`
- 句面文本切片仍优先使用 `content` 回贴，避免 `I'd` 一类片段在 label 文本中退化成生硬拼接

## TODO

- 评估下半结构区是否也要切到同一套“行来源 + label”模型
- 继续清理 helper 中仅服务旧下半区的历史兼容逻辑
- 评估 `chunk` label 是否切到后端 `chunkType.name` 直出
