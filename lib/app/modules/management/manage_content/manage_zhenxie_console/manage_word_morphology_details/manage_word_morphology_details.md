# 词根词缀词卡页说明

## 目标与验收口径
- 新建甄写后台「词根词缀」第二页，即共享该词素的单词词卡页。
- 接通接口 `/language-console/write/word/morphology/word/pages`。
- 页面包含页头信息与固定 5 列成员词网格。
- 成员词网格复用 `elements_morpheme_detils` 的网格词卡样式，不重复维护第二套卡片结构。
- 当前卡片点击先保留占位提示，不继续进入构词树页。

## 改动点列表
- 抽离 `elements` 里的词素成员词卡为公共 widget，供 `elements` 与管理端共用。
- 新增 `WordMorphologyWordsPageEntity` 解析 morphology 词卡页接口。
- 新增 `manage_word_morphology_details` 模块的 `binding`、`controller`、`view`。
- 在 `LanguageConsoleRequest` 中新增 morphology 词卡页请求方法。
- 在 `Routes`、`ManagePageRegistry`、morphology 目录页跳转中接入详情页。
- 补充 root 分支详情模式：支持通过 `key` 进入，并调用 `/language-console/write/word/morphology/root/member/page`。

## 关键设计 / 关键决策
- 复用的是“网格卡片”本身，不把 `elements` 页面的词性筛选、双语开关、视图切换带进管理端。
- 详情页头部展示字段严格使用接口原字段；类型、位置先直接展示原值，不额外做本地中文映射。
- 当前词素高亮逻辑直接复用现有 `elements` 词卡里的高亮实现，不再新增第二套高亮规则。
- 详情页统一复用 `WordMorphologyWordsPageEntity`；当 root 成员页返回 `key / contentId / translate / morphologyType` 时，直接在现有实体上补字段承接，不额外新建 root 专用模型。
- 进入参数同时支持 `morphemeNid` 与 `key`：普通词素继续走原接口；root 分支走 `key` 接口，并在页头展示“共享词根”和词 ID。

## 兼容性影响与注意事项
- 本次只接通 morphology 词卡页，不接构词树页。
- 若接口未返回词素详情，将显示未找到状态，不做本地兜底。
- 共用卡片 widget 的改动同时影响 `elements_morpheme_detils` 网格页，因此保持了原有数据结构和展示逻辑。

## TODO
- 接入构词树页。
- 若后端补充类型名、位置名专用字段，再替换当前页头 raw 值显示。
