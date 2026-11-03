# Elements Sentence Chunk Layout Helper

## 目标与验收口径

- 只收正语块页上半宫格布局逻辑
- 宫格列按原句表层词序展示，支持缩写回贴原文后合列
- 宫格行支持独立连接行、子句行、孤儿余文行
- 同一 token 被多个语块覆盖时，按“最短 span 优先；同长取更靠后起点”选赢者

## 改动点列表

- 新增 `elements_sentence_chunk_layout_helper.dart`
- 从语块 widget 中抽离 surface align 与 chunk 布局行生成
- 语块页上半宫格改为消费 helper 返回的列与行数据
- 子句左侧 `↳` 改为展示父子句序号，而不是父 clauseId
- 上半宫格列宽从固定宽度改为动态宽度，按表头自然宽度起步，再按跨列 pill 的内容需求补宽
- 下半折叠区重做为按子句折叠的结构卡，支持内部语块展开、片段详情弹窗与语法特征/特殊结构说明弹窗

## 关键设计

- helper 当前只服务 `chunking`
- 原文对齐优先使用 `detils.content`，按 token 顺序回贴字符区间
- 连接词若被更大语块严格包住，不单独拆连接行
- 子孙从句 token 从父句行跳过，留给子句自己承接
- 句末标点孤儿余文并回前一行，不单独起行
- Flutter 侧通过预计算列宽与累计 offset 近似 React 的 `max-content` 栅格，不继续使用固定 `columnWidth`
- 下半结构区直接复用上半 `layout.rows` 的子句/连接/余文口径，避免出现两套规则

## 兼容性影响与注意事项

- 本轮不回补分析页顶部壳
- 本轮不处理下半折叠区重构，仍保持现状
- 本轮不接入 `svoca / syntax / relations`
- helper 结构按后续复用成分页预留，但当前未直接接 `svoca`

## TODO

- 让下半折叠区也复用同一套 surface align 结果
- 基于同一 helper 扩展 `svoca` 布局模式
- 继续把目录类说明（如 chunk type 目录描述）补齐到 Flutter 端可点击说明能力
