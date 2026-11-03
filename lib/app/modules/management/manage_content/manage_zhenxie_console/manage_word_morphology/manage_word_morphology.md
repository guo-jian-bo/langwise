# 词根词缀列表页说明

## 目标与验收口径
- 新建甄写后台「词根词缀」目录页，用户端与管理端共用同一套页面，按 `isManagement` 区分接口。
- 管理端列表接口 `/language-console/write/word/morphology/pages`，用户端列表接口 `POST /languages/content/card/en/morpheme/v2/pages`。
- 管理端筛选排序元数据接口 `/language-console/write/word/morphology/query/meta/group/list`，用户端元数据接口 `GET /languages/content/card/en/morpheme/query/meta/group/list`。
- 顶部总览（类型统计）不再单独请求，改由列表接口响应中的 `types` 提供，两端一致。
- 页面包含标题区、顶部总览、搜索筛选排序、固定 3 列卡片列表。
- 列表卡片点击先保留占位行为，不接第二页详情。

## 改动点列表
- 新增 `manage_word_morphology` 模块的 `binding`、`controller`、`view`。
- 新增 `WordMorphologyListItemEntity` 解析列表卡片，新增 `WordMorphologyPageEntity` 解析列表响应（含 `types` 类型统计）。
- 在 `LanguageConsoleRequest` 中新增 morphology 列表、筛选元数据请求方法；在 `ElementsRequest` 中新增用户端 `queryMorphemeList`、`getMorphemeFilters`。
- 移除顶部总览接口 `/language-console/write/word/morphology/summary` 及对应请求方法与 `WordMorphologySummaryEntity`。
- 在 `Routes` 与 `ManagePageRegistry` 中注册 `MANAGE_WORD_MORPHOLOGY`。
- 将甄写管理台里的「构词 Morphology」入口改为真实跳转。

## 关键设计 / 关键决策
- 列表动态字段严格沿用后端返回字段，不新增前端业务映射表，不对缺失字段做本地兜底。
- 类型与位置的显示名称直接来自筛选元数据接口，避免前端维护第二套名称配置。
- 教育适配度颜色优先解析后端 `tierColors` 主题色数组，并兼容旧的 `tierColor` 字段，不在前端本地写死颜色表。
- 顶部总览只在首屏（`offset == 0`）从列表响应取一次 `types`，翻页不覆盖。
- 详情页本次不进入范围，卡片点击只保留占位提示。

## 兼容性影响与注意事项
- 本次只新增 morphology 目录页，不改词卡页和构词树。
- 若后端缺少某个展示字段，当前策略是留空或隐藏该块，不做本地补文案、补颜色、补默认值。
- 由于筛选元数据没有默认排序值时，页面不会在前端额外指定默认排序。

## TODO
- 接入 morphology 词卡页。
- 接入 morphology 构词树页。
- 若后端补充更多展示字段，再评估是否补充目录卡片信息层级。
