# 写作阶梯首页真实接口接入说明

## 目标与验收口径
- 废弃首页旧 mock workbench 数据源，首页直接使用真实接口驱动渲染。
- 地图、列表、弹窗三处统一基于 `stage/pages` 返回结构展示。
- 底部筛选和列表排序使用 `query/meta/group/list` 返回的元数据。
- 文类标签走 `genre/list` 映射，拍条名称与颜色走 `paragraph/rhetorical/beat/list` 映射。

## 本次改动点
- 重写首页模型，改为直接对应真实接口字段。
- `LanguageConsoleRequest` 新增写作阶梯首页接口封装，并移除旧 mock 依赖。
- `ZhenxieCompositionStagesController` 改为进入页面并行请求首页四个接口，并按筛选/排序重新请求列表。
- 地图节点改为使用 `coverUrl`、`difficulty`、`compositionBlueprint.name`、`name` 渲染。
- 列表卡改为使用 `name`、`nid`、`genreNid`、`description`、拍条状态和四个按钮渲染。
- 弹窗卡改为直接消费真实接口字段，不再依赖旧的 paragraph type mock 结构。

## 关键设计与决策
- 首页主数据只认 `POST /language-console/write/en/composition/stage/pages`。
- 筛选参数统一组装为 `content + filters[]`，排序统一走 `PageParam.order`。
- 文首/文末显示需同时结合 `compositionBlueprint.frame.hasHead/hasTail` 和 `headFill/tailFill`。
- 拍条状态只认当前接口语义：`given / write / hidden`。

## 兼容性影响与注意事项
- 当前只完成首页地图、列表、弹窗的真实接口接入。
- 四个操作按钮仍为占位交互，暂未接入编辑页、蓝图页、范文页、任务页跳转。
- 若后端返回的 `enabled` 缺失，前端按可展示处理，不会因为空值被误过滤。

## 待确认问题 / TODO
- 编辑按钮后续接入 `stage/detail` 与 `stage/edit`。
- 蓝图 / 范文 / 任务按钮后续补真实跳转与参数约定。
- 若后续首页需要独立里程碑全量词表，再接 `composition/milestone/list` 做兜底映射。
