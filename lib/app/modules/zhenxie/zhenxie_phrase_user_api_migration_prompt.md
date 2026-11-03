# 甄写短语模块用户端接口迁移提示词

## 目标

基于 `write_discourse_phrase_frontend_api_handoff.md`，补全甄写「短语」页面的用户端只读接口接入，并在现有页面中按 `isManagement` 做管理端 / 用户端分流。

这次范围对应管理台短语区的 5 个入口：

1. `短语对照`
2. `短语配对`
3. `短语搭配组`
4. `短语结构`
5. `入句画像`

以及这些入口对应的详情页：

1. `zhenxie_phrase_contrast_details`
2. `zhenxie_phrase_pair_details`
3. `zhenxie_phrase_match_details`
4. `zhenxie_phrase_structure_details`
5. `zhenxie_enter_sentence_details`

管理端继续走 `LanguageConsoleRequest`。  
用户端新增并统一走 `LanguageUtil`。  
和句子模块一样，这次只改“读”，不改“写”。

---

## 核心规则

### 1. 分流规则

所有只读查询都统一按下面这个模式处理：

```dart
if (isManagement) {
  // LanguageConsoleRequest
} else {
  // LanguageUtil
}
```

参考现有写法：

1. `lib/app/modules/zhenxie/zhenxie_task_details/controllers/zhenxie_task_details_controller.dart`
2. `lib/app/modules/zhenxie/zhenxie_phrase_pair_details/controllers/zhenxie_phrase_pair_details_controller.dart`
3. `lib/app/modules/zhenxie/zhenxie_phrase_contrast_details/controllers/zhenxie_phrase_contrast_details_controller.dart`

### 2. 接口新增位置

用户端短语只读接口统一新增到：

1. `lib/common/https/language.dart`

不要继续散落到 `elements.dart`。  
`elements.dart` 里现有的用户端短语详情实现可作为老逻辑参考，但这次迁移目标是和句子一样收拢到 `LanguageUtil`。

### 3. 用户端前缀规则

根据文档，短语接口 BasePath 为：

1. `/write/zhenxie/phrase`

前端请求路径统一补成：

1. `/languages/write/zhenxie/phrase/...`

### 4. 数据结构规则

用户端和管理端返回结构一致，直接复用现有 Entity：

1. `PhraseParadigmEntity`
2. `PhrasePairEntity`
3. `PhraseMatchEntity`
4. `PhraseStructureEntity`
5. `EnterSentenceEntity`
6. `FiltersGroupEntity`
7. `ListResponseEntity<T>`

### 4.1 参数组织规则

用户端新接口的方法签名尽量与管理端保持一致，优先统一为：

1. `parameters`
2. `data`

不要继续保留 `ElementsRequest.getPhraseStructureDetils(contentId, style: ..., mediaMode: ...)` 这种“位置参数 + 命名参数”的老调用方式。

像 `短语结构详情` 这种用户端仍然需要携带 `style / mediaMode` 的场景，也要改写成：

1. `parameters: {"phraseId": phraseId, "style": xxx, "mediaMode": xxx}`

也就是保留原有业务参数，但组织形式对齐 `LanguageConsoleRequest` 这类现有调用风格。

### 5. 非本次改造范围

以下内容不在这次迁移范围内：

1. 编辑接口
2. 上下架接口
3. 删除接口
4. AI 创建接口
5. 任何 UI 显隐、文案、组件结构调整
6. 无关的参数重构

---

## 文档到页面名称映射

后端文档和前端页面名称并不完全一致，需要先映射清楚：

1. 文档 `paradigm` -> 前端 `短语对照`
2. 文档 `pair` -> 前端 `短语配对`
3. 文档 `cluster` -> 前端 `短语搭配组`
4. 文档 `profile` -> 前端 `入句画像`
5. 文档 `structure` -> 前端 `短语结构`

也就是说：

1. `zhenxie_enter_sentence` 对应的是后端 `phrase/profile`
2. `zhenxie_enter_sentence_details` 对应的是后端 `phrase/profile/detail`

---

## 短语接口映射清单

## A. 短语对照 Paradigm

文档定义：

1. `POST /write/zhenxie/phrase/paradigm/pages`
2. `GET /write/zhenxie/phrase/paradigm/detail?nid={nid}`
3. `GET /write/zhenxie/phrase/paradigm/query/meta/group/list`

用户端建议新增：

1. `LanguageUtil.getWritePhraseParadigmPage(...)`
2. `LanguageUtil.getWritePhraseParadigmDetail(...)`
3. `LanguageUtil.getWritePhraseParadigmFilters()`

对应用户端路径建议：

1. `/languages/write/zhenxie/phrase/paradigm/pages`
2. `/languages/write/zhenxie/phrase/paradigm/detail`
3. `/languages/write/zhenxie/phrase/paradigm/query/meta/group/list`

请求说明：

1. 列表请求体统一为 `content + filters[]`
2. 排序统一从 query 传 `order`
3. 详情按文档是 query 参数 `nid`

## B. 短语配对 Pair

文档定义：

1. `POST /write/zhenxie/phrase/pair/pages`
2. `GET /write/zhenxie/phrase/pair/detail?nid={nid}`
3. `GET /write/zhenxie/phrase/pair/query/meta/group/list`

用户端建议新增：

1. `LanguageUtil.getWritePhrasePairPage(...)`
2. `LanguageUtil.getWritePhrasePairDetail(...)`
3. `LanguageUtil.getWritePhrasePairFilters()`

对应用户端路径建议：

1. `/languages/write/zhenxie/phrase/pair/pages`
2. `/languages/write/zhenxie/phrase/pair/detail`
3. `/languages/write/zhenxie/phrase/pair/query/meta/group/list`

## C. 短语搭配组 Cluster

文档定义：

1. `POST /write/zhenxie/phrase/cluster/pages`
2. `GET /write/zhenxie/phrase/cluster/detail?nid={nid}`
3. `GET /write/zhenxie/phrase/cluster/query/meta/group/list`

用户端建议新增：

1. `LanguageUtil.getWritePhraseMatchPage(...)`
2. `LanguageUtil.getWritePhraseMatchDetail(...)`
3. `LanguageUtil.getWritePhraseMatchFilters()`

说明：

前端命名是 `match`，后端文档命名是 `cluster`。  
用户端路径仍然应该按文档走 `cluster`，不要被前端文件名误导。

对应用户端路径建议：

1. `/languages/write/zhenxie/phrase/cluster/pages`
2. `/languages/write/zhenxie/phrase/cluster/detail`
3. `/languages/write/zhenxie/phrase/cluster/query/meta/group/list`

## D. 入句画像 Profile

文档定义：

1. `POST /write/zhenxie/phrase/profile/pages`
2. `GET /write/zhenxie/phrase/profile/detail?phraseId={phraseId}`
3. `GET /write/zhenxie/phrase/profile/query/meta/group/list`

用户端建议新增：

1. `LanguageUtil.getWriteEnterSentencePage(...)`
2. `LanguageUtil.getWriteEnterSentenceDetail(...)`
3. `LanguageUtil.getWriteEnterSentenceFilters()`

对应用户端路径建议：

1. `/languages/write/zhenxie/phrase/profile/pages`
2. `/languages/write/zhenxie/phrase/profile/detail`
3. `/languages/write/zhenxie/phrase/profile/query/meta/group/list`

说明：

前端页面名是 `enter_sentence`，但真实后端资源名是 `profile`。

## E. 短语结构 Structure

文档定义：

1. `POST /write/zhenxie/phrase/structure/pages`
1. `GET /write/zhenxie/phrase/structure/detail?phraseId={phraseId}`
2. `GET /write/zhenxie/phrase/structure/query/meta/group/list`

用户端建议新增：

1. `LanguageUtil.getWritePhraseStructurePage(...)`
1. `LanguageUtil.getWritePhraseStructureDetail(...)`
2. `LanguageUtil.getWritePhraseStructureFilters()`

对应用户端路径建议：

1. `/languages/write/zhenxie/phrase/structure/pages`
1. `/languages/write/zhenxie/phrase/structure/detail`
2. `/languages/write/zhenxie/phrase/structure/query/meta/group/list`

---

## 当前实现现状梳理

## 1. 列表控制器当前全部只走管理端

1. `zhenxie_phrase_contrast_controller.dart`
2. `zhenxie_phrase_pair_controller.dart`
3. `zhenxie_phrase_match_controller.dart`
4. `zhenxie_phrase_structure_controller.dart`
5. `zhenxie_enter_sentence_controller.dart`

这些控制器当前主要依赖：

1. `LanguageConsoleRequest.getWriteFilterData(...)`
2. `LanguageConsoleRequest.getWritePhraseParadigmPage(...)`
3. `LanguageConsoleRequest.getWritePhrasePairPage(...)`
4. `LanguageConsoleRequest.getWritePhraseMatchPage(...)`
5. `LanguageConsoleRequest.getWritePhraseStructurePage(...)`
6. `LanguageConsoleRequest.getWriteEnterSentencePage(...)`

## 2. 详情控制器当前用户端逻辑不统一

### 已经有用户端旧实现，但走的是 `ElementsRequest`

1. `zhenxie_phrase_contrast_details_controller.dart`
2. `zhenxie_phrase_pair_details_controller.dart`
3. `zhenxie_phrase_match_details_controller.dart`
4. `zhenxie_phrase_structure_details_controller.dart`

### 仍然只走管理端

1. `zhenxie_enter_sentence_details_controller.dart`

### 迁移目标

和句子模块一致，统一改成：

1. 管理端 -> `LanguageConsoleRequest`
2. 用户端 -> `LanguageUtil`

不要继续混用 `ElementsRequest`。

---

## 需要改动的控制器清单

## 1. 列表页

### `lib/app/modules/zhenxie/zhenxie_phrase_contrast/controllers/zhenxie_phrase_contrast_controller.dart`

需要分流的方法：

1. `getFiltersGroup()`
2. `getListData({bool showLoading = true})`
3. `refreshSingleData(PhraseParadigmEntity data)`

### `lib/app/modules/zhenxie/zhenxie_phrase_pair/controllers/zhenxie_phrase_pair_controller.dart`

需要分流的方法：

1. `getFiltersGroup()`
2. `getListData({bool showLoading = true})`

说明：

当前这个控制器没有 `refreshSingleData()`，提示词里不要误写。

### `lib/app/modules/zhenxie/zhenxie_phrase_match/controllers/zhenxie_phrase_match_controller.dart`

需要分流的方法：

1. `getFiltersGroup()`
2. `getListData({bool showLoading = true})`

### `lib/app/modules/zhenxie/zhenxie_phrase_structure/controllers/zhenxie_phrase_structure_controller.dart`

需要分流的方法：

1. `getFiltersGroup()`
2. `getListData({bool showLoading = true})`

注意：

这里虽然交接文档漏写了 `structure/pages`，但实际迁移时按可用接口处理，用户端列表页也要一起迁移。

### `lib/app/modules/zhenxie/zhenxie_enter_sentence/controllers/zhenxie_enter_sentence_controller.dart`

需要分流的方法：

1. `getFiltersGroup()`
2. `getListData({bool showLoading = true})`

## 2. 详情页

### `lib/app/modules/zhenxie/zhenxie_phrase_contrast_details/controllers/zhenxie_phrase_contrast_details_controller.dart`

需要统一分流的方法：

1. `getDetails()`

用户端从 `ElementsRequest.getPhraseParadigmDetils()` 切到 `LanguageUtil.getWritePhraseParadigmDetail()`。

### `lib/app/modules/zhenxie/zhenxie_phrase_pair_details/controllers/zhenxie_phrase_pair_details_controller.dart`

需要统一分流的方法：

1. `getDetails()`

用户端从 `ElementsRequest.getPhrasePairDetils()` 切到 `LanguageUtil.getWritePhrasePairDetail()`。

### `lib/app/modules/zhenxie/zhenxie_phrase_match_details/controllers/zhenxie_phrase_match_details_controller.dart`

需要统一分流的方法：

1. `getDetails()`

用户端从 `ElementsRequest.getPhraseMatchDetils()` 切到 `LanguageUtil.getWritePhraseMatchDetail()`。

### `lib/app/modules/zhenxie/zhenxie_phrase_structure_details/controllers/zhenxie_phrase_structure_details_controller.dart`

需要统一分流的方法：

1. `getDetails()`

用户端从 `ElementsRequest.getPhraseStructureDetils()` 切到 `LanguageUtil.getWritePhraseStructureDetail()`。

注意：

当前用户端详情除了 `phraseId` 还需要保留 `style / mediaMode`。
但调用形式要统一改成 `parameters` 风格，例如：

1. `parameters: {"phraseId": phraseId, "style": xxx, "mediaMode": xxx}`

不要继续使用 `ElementsRequest` 的老式位置参数调用方式。

### `lib/app/modules/zhenxie/zhenxie_enter_sentence_details/controllers/zhenxie_enter_sentence_details_controller.dart`

需要分流的方法：

1. `getDetails()`

用户端详情应接到 `LanguageUtil.getWriteEnterSentenceDetail()`。

---

## 需要新增到 `LanguageUtil` 的短语接口建议

## A. 通用筛选元数据

可以按显式方法拆开，不强制复用一个 `type` 参数：

1. `getWritePhraseParadigmFilters()`
2. `getWritePhrasePairFilters()`
3. `getWritePhraseMatchFilters()`
4. `getWritePhraseStructureFilters()`
5. `getWriteEnterSentenceFilters()`

## B. 列表接口

1. `getWritePhraseParadigmPage(...)`
2. `getWritePhrasePairPage(...)`
3. `getWritePhraseMatchPage(...)`
4. `getWritePhraseStructurePage(...)`
5. `getWriteEnterSentencePage(...)`

## C. 详情接口

1. `getWritePhraseParadigmDetail(...)`
2. `getWritePhrasePairDetail(...)`
3. `getWritePhraseMatchDetail(...)`
4. `getWritePhraseStructureDetail(...)`
5. `getWriteEnterSentenceDetail(...)`

## 建议实施顺序

1. 先在 `language.dart` 新增短语用户端只读接口
2. 先改 5 个列表页：
   - 短语对照
   - 短语配对
   - 短语搭配组
   - 短语结构
   - 入句画像
3. 再改 5 个详情页，让用户端不再依赖 `ElementsRequest`

---

## 自测清单

1. 管理端入口打开 5 个短语页面，确认原管理端能力不回退
2. 用户端入口打开以下列表，确认可正常加载：
   - 短语对照
   - 短语配对
   - 短语搭配组
   - 入句画像
3. 用户端打开以下详情，确认可正常展示：
   - 短语对照详情
   - 短语配对详情
   - 短语搭配组详情
   - 短语结构详情
   - 入句画像详情
4. 用户端打开 `短语结构` 列表，确认可正常加载
5. 列表页筛选、搜索、排序在用户端至少各验证一次

---

## 一句话实施要求

请在 **不改动管理端读写能力**、**不碰任何写接口** 的前提下，为甄写短语模块补齐用户端只读接口，并让短语列表页 / 详情页根据 `isManagement` 正确切换 `LanguageConsoleRequest` 与 `LanguageUtil`；其中 `短语结构` 视为存在用户端列表接口，详情页里的 `style / mediaMode` 需要保留，但统一收敛进 `parameters` 传递。
