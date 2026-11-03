# 成分 Tab 接入说明

## 目标与验收口径
- 只接入句子分析页的“成分”tab 内容。
- 复用语块页现有宫格与折叠区骨架，不另起一套布局。
- 以上半宫格、下半折叠区、简单弹窗都能按 `clause.svoca` 正确展示为验收标准。

## 改动点列表
- 新增 `elements_sentence_svoca_content_widget.dart` 作为成分页入口。
- 复用 `elements_sentence_chunk_content_widget.dart`，通过 `SentenceChunkAnalysisMode.svoca` 切换到成分模式。
- 扩展 `elements_sentence_chunk_layout_helper.dart`，让共用布局支持 `chunking / svoca` 两种 mode。
- 在成分模式下补充：
  - `svoca.elements[]` 的宫格 pill 映射
  - `svoca.codeNid` 骨架芯片与实例说明
  - `SVOCA` 余文文案
  - 成分本地配色

## 关键设计 / 关键决策
- 不复制一套新的宫格布局，继续复用 surface align、列宽计算、余文/连接词/子句层级逻辑。
- 成分着色不走后端颜色配置，按产品文档使用前端本地 bucket 色，并统一由主色派生背景和边框透明度。
- 成分名称优先使用后端 `svoca.elements[].type.name` 与 `svoca.code.name`，避免本地硬编码文案漂移。

## 兼容性影响与注意事项
- 本次只动 `svoca` 内容，不动 `chunks / syntax / relations` 的既有入口结构。
- 语块模式仍保持原有行为；成分模式只是复用同一套组件并切换数据源。
- 当前成分配色仍是本地映射，后续若后端补充统一目录配置，再评估是否切换数据源。

## TODO
- `syntax` tab 仍待接入。
- `relations` tab 仍待接入。
