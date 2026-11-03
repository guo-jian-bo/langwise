# 选择单元词汇页说明

## 目标与验收口径
- 保持原有“选择单元词汇”入口可用，默认仍选择单词和短语。
- 页面新增可配置模式，支持通过路由参数切到指定 `contentTypes` 的选择场景。
- 本轮新增的句子模式用于单元语法 Target 详情页的“强制绑定句子”：
  - 请求 `/course-console/unit/{unitId}/knowledge/list/v2`
  - body 传 `contentTypes: ['EN_SENTENCE']`
  - 页面标题改为“选择单元句子”
  - 空态改为“暂无可选句子”
  - 未选择提示改为“请选择句子”
- 点击“完成”后仍返回 `KnowledgeCommonEntityList` 列表，由上游页面自行决定如何消费。

## 改动点
- controller 新增：
  - `contentTypes`
  - `breadcrumbTitleText`
  - `emptyText`
  - `confirmEmptyText`
- 初始化时从 `Get.arguments` 读取：
  - `contentTypes`
  - `breadcrumbTitle`
  - `emptyText`
  - `confirmEmptyText`
- 请求单元知识点列表时，把 `contentTypes` 放进 body。
- View 不再写死只渲染单词和短语分区，改为按 controller 当前的 `sectionTypeOrder` 渲染。

## 关键设计
- 继续复用原页面、原路由、原卡片组件，不新增新的“句子选择页”模块。
- 返回结果保持为原始 `KnowledgeCommonEntityList`，不在选择页内做额外 DTO 转换。
- 默认值保持原有词汇页口径，避免影响旧入口。

## 兼容性影响与注意事项
- 当前句子模式仍复用 `ElementsSelectKnowledgeCard`，展示上沿用现有知识点选择卡。
- 若后端后续扩展更多可选内容类型，只需从路由参数传新的 `contentTypes` 即可复用当前页面。
- 当前页面仍会保留原来的样式参数请求逻辑；如果句子模式后续确认不需要，可再单独收口。

## TODO
- 后续若句子模式需要更轻量的行式列表，可以在不改返回结构的前提下单独替换 View 表达。
