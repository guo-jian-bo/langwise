# 曲折变化列表页说明

## 目标与验收口径
- 新建甄写后台「曲折变化」列表页。
- 接通列表接口 `/language-console/write/word/inflection/pages`。
- 接通筛选排序元数据接口 `/language-console/write/word/inflection/query/meta/group/list`。
- 列表页支持分页加载、筛选、排序，并展示列表核心字段。
- 详情页接口先不接，列表项暂不进入详情。

## 改动点列表
- 新增 `manage_word_inflection` 模块的 `binding`、`controller`、`view`。
- 新增 `WordInflectionListItemEntity` 解析列表接口数据。
- 在 `LanguageConsoleRequest` 中新增曲折变化列表与筛选元数据请求方法。
- 在 `Routes` 与 `ManagePageRegistry` 中注册 `MANAGE_WORD_INFLECTION`。
- 将甄写管理台里的「曲折变化」入口改为真实跳转。

## 关键设计 / 关键决策
- 排序接口值为 `pos_asc / lemma_asc / missing_desc`，与通用筛选条默认的升降序拼接规则不完全一致，所以只在本页面控制器内做局部映射，不改全局 `FilterStripUtils`。
- `pos` 与 `grammaticalType` 的展示名称直接来自筛选元数据接口，避免在前端重复维护一份业务映射。
- 列表项先聚焦后台核查信息：`lemma`、`familyKey`、`previewSurfaces`、`grammaticalTypeNids`、`semanticCount`、`missingCount`、`updated`。

## 兼容性影响与注意事项
- 本次不修改现有句子相关甄写页面。
- 本次不接详情接口，也不新增详情跳转行为。
- 若后端后续给排序元数据补默认值，页面会优先使用接口默认值；当前若未返回默认值，首版会默认选中第一项排序。

## TODO
- 接入详情页 `/language-console/write/word/inflection/detail`。
- 根据详情结构补 family 级联编辑与缺失项创建动作。
