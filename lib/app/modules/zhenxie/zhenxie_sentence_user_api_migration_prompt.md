# 甄写句子模块用户端接口迁移提示词

## 目标

基于 `app-sentence-write-api.md`，补全甄写「句子」页面的用户端只读接口接入，并在现有页面中按 `isManagement` 做管理端 / 用户端分流。

这次范围只处理句子管理台对应的 5 个入口：

1. `句型蓝图`
2. `生长金字塔`
3. `句型对照`
4. `句间配链`
5. `语法全景`

管理端继续走 `LanguageConsoleRequest`，用户端新增并统一走 `LanguageUtil`。

## 核心规则

### 1. 分流规则

所有只读查询都要参考下面这个模式：

```dart
if (isManagement) {
  // LanguageConsoleRequest
} else {
  // LanguageUtil
}
```

参考现有写法：

- `lib/app/modules/zhenxie/zhenxie_task_details/controllers/zhenxie_task_details_controller.dart`
- `lib/app/modules/zhenxie/zhenxie_phrase_pair_details/controllers/zhenxie_phrase_pair_details_controller.dart`
- `lib/app/modules/zhenxie/zhenxie_phrase_contrast_details/controllers/zhenxie_phrase_contrast_details_controller.dart`

### 2. 接口新增位置

用户端接口必须新增到：

- `lib/common/https/language.dart`

不要写到 `elements.dart` 或其他 http 文件里。

### 3. 用户端前缀规则

文档 `app-sentence-write-api.md` 里写的是 app controller 路由前缀：

- `/write/zhenxie/sentence`

前端实际请求时，用户端统一补成：

- `/languages/write/en/...`

可参考现有写作任务 / 范文详情接口：

- `/languages/write/en/composition/task/detail`
- `/languages/write/en/composition/instance/detail`

句子模块建议按管理端路径一一平移：

- 管理端：`/language-console/en/sentence/...`
- 用户端：`/languages/write/en/sentence/...`

### 4. 数据结构规则

用户端和管理端返回结构完全一致，直接复用现有 Entity：

- `PatternBlueprintEntity`
- `PatternBlueprintExampleEntity`
- `SentencePatternCompareEntity`
- `SentencePairEntity`
- `SentenceForkEntity`
- `ManageGrammarPanoramaEntity`
- `FiltersGroupEntity`
- `ListResponseEntity<T>`

### 5. 非本次改造范围

以下仍然保留管理端专用，不做用户端迁移：

1. 编辑接口
2. 上下架接口
3. 删除接口
4. AI 创建接口
5. 代表句编辑 / 句组编辑等教研操作

也就是说，这次只改“读”，不改“写”。

## 文档到前端接口映射

## A. 句型蓝图 / 生长金字塔

文档定义：

- `POST /pattern/pages`
- `GET /pattern/{nid}/detail`
- `GET /pattern/query/meta/group/list`
- `POST /pattern/realization/set/pages`
- `GET /pattern/realization/set/query/meta/group/list`

用户端应新增的方法建议：

1. `LanguageUtil.querySentencePatternBlueprintList(...)`
2. `LanguageUtil.querySentencePatternBlueprint(String nid, ...)`
3. `LanguageUtil.getSentencePatternBlueprintFilters()`
4. `LanguageUtil.querySentencePatternBlueprintExample(...)`
5. `LanguageUtil.getSentencePatternBlueprintExampleFilters()`

对应用户端路径建议：

1. `/languages/write/en/sentence/pattern/pages`
2. `/languages/write/en/sentence/pattern/{nid}/detail`
3. `/languages/write/en/sentence/pattern/query/meta/group/list`
4. `/languages/write/en/sentence/pattern/realization/set/pages`
5. `/languages/write/en/sentence/pattern/realization/set/query/meta/group/list`

注意：

1. `supportsPyramid` 仍需保留透传。
2. 文档里 realization set 请求字段是 `nid / nids / uids / content / supportsPyramid / filters`。
3. 当前管理端详情页例句请求用了 `assetNid`，切用户端时要按文档确认是否改成 `nid`，不要盲抄管理端 payload。

## B. 句型对照

文档定义：

- `POST /paradigm/pages`
- `GET /paradigm/{nid}/detail`
- `GET /paradigm/query/meta/group/list`
- `POST /paradigm/realization/set/pages`
- `GET /paradigm/realization/set/query/meta/group/list`

用户端应新增的方法建议：

1. `LanguageUtil.querySentencePatternCompareList(...)`
2. `LanguageUtil.getSentencePatternCompareDetails(String nid, ...)`
3. `LanguageUtil.getSentencePatternCompareFilters()`

如后续页面需要单独拉取对照组例句，再补：

4. `LanguageUtil.querySentencePatternCompareExample(...)`
5. `LanguageUtil.getSentencePatternCompareExampleFilters()`

对应用户端路径建议：

1. `/languages/write/en/sentence/paradigm/pages`
2. `/languages/write/en/sentence/paradigm/{nid}/detail`
3. `/languages/write/en/sentence/paradigm/query/meta/group/list`
4. `/languages/write/en/sentence/paradigm/realization/set/pages`
5. `/languages/write/en/sentence/paradigm/realization/set/query/meta/group/list`

说明：

当前 `zhenxie_sentence_pattern_compare_details` 主要靠详情接口返回完整详情，先按现有页面真实调用点补最小集合即可。

## C. 句间配链 / 句间配链分叉

文档定义：

- `POST /pair/pages`
- `GET /pair/{nid}/detail`
- `GET /pair/query/meta/group/list`
- `POST /pair/fork/pages`
- `GET /pair/fork/{nid}/detail`
- `GET /pair/fork/query/meta/group/list`

用户端应新增的方法建议：

1. `LanguageUtil.querySentencePairList(...)`
2. `LanguageUtil.getSentencePairDetails(String nid)`
3. `LanguageUtil.getSentencePairFiltersGroup()`
4. `LanguageUtil.querySentenceForkList(...)`
5. `LanguageUtil.getSentenceForkDetails(String nid)`
6. `LanguageUtil.getSentenceForkFiltersGroup()`

对应用户端路径建议：

1. `/languages/write/en/sentence/pair/pages`
2. `/languages/write/en/sentence/pair/{nid}/detail`
3. `/languages/write/en/sentence/pair/query/meta/group/list`
4. `/languages/write/en/sentence/pair/fork/pages`
5. `/languages/write/en/sentence/pair/fork/{nid}/detail`
6. `/languages/write/en/sentence/pair/fork/query/meta/group/list`

## D. 语法全景

文档定义：

- `POST /grid/pages`
- `GET /grid/query/meta/group/list`
- `POST /grid/realization/set/pages`
- `GET /grid/realization/set/query/meta/group/list`

注意：文档说明 app 端 `grid` 没有单独 detail 接口，列表即最终形态。

用户端应新增的方法建议：

1. `LanguageUtil.getGrammarPanoramaList(...)`
2. `LanguageUtil.getGrammarPanoramaFiltersGroup()`
3. `LanguageUtil.getGrammarPanoramaExample(...)`
4. `LanguageUtil.getGrammarPanoramaExampleFilters()`

对应用户端路径建议：

1. `/languages/write/en/sentence/grid/pages`
2. `/languages/write/en/sentence/grid/query/meta/group/list`
3. `/languages/write/en/sentence/grid/realization/set/pages`
4. `/languages/write/en/sentence/grid/realization/set/query/meta/group/list`

注意：

1. 详情页 `zhenxie_grammar_panorama_details` 现在是用 `grid/pages + nid` 取单项详情，这个用户端也应保持同样策略。
2. 当前例句请求里用了 `assetNid`，切用户端时优先按文档核对是否应改为 `nid`。

## 需要改动的控制器清单

## 1. 列表页

### `lib/app/modules/zhenxie/zhenxie_pattern_blueprint/controllers/zhenxie_pattern_blueprint_controller.dart`

需要分流的方法：

1. `getFiltersGroup()`
2. `getListData({bool showLoading = true})`
3. `refreshSingleData(PatternBlueprintEntity data)`

### `lib/app/modules/zhenxie/zhenxie_sentence_pattern_compare/controllers/zhenxie_sentence_pattern_compare_controller.dart`

需要分流的方法：

1. `getFiltersGroup()`
2. `getListData({bool showLoading = true})`
3. `refreshSingleData(SentencePatternCompareEntity data)`

### `lib/app/modules/zhenxie/zhenxie_sentence_pair/controllers/zhenxie_sentence_pair_controller.dart`

需要分流的方法：

1. `getPairFiltersGroup()`
2. `getForkFiltersGroup()`
3. `getPairListData({bool showLoading = true})`
4. `refreshPairDetail(SentencePairEntity pair)`
5. `getForkListData({bool showLoading = true})`
6. `refreshForkDetail(SentenceForkEntity pair)`

### `lib/app/modules/zhenxie/zhenxie_grammar_panorama/controllers/zhenxie_grammar_panorama_controller.dart`

需要分流的方法：

1. `getFiltersGroup()`
2. `getListData({bool showLoading = true})`
3. `refreshSingleData(ManageGrammarPanoramaEntity data)`

## 2. 详情页

### `lib/app/modules/zhenxie/zhenxie_pattern_blueprint_details/controllers/zhenxie_pattern_blueprint_details_controller.dart`

需要分流的方法：

1. `getFiltersGroup()`
2. `getDetatils({bool showLoading = true})`
3. `getExampleList({bool showLoading = false})`
4. `getExampleForUid(PatternBlueprintExampleEntity data)`

注意：

编辑相关方法仍然只走 `LanguageConsoleRequest`，不要误切。

### `lib/app/modules/zhenxie/zhenxie_sentence_pattern_compare_details/controllers/zhenxie_sentence_pattern_compare_details_controller.dart`

需要分流的方法：

1. `getDetailData()`

编辑和上下架逻辑保持管理端专用。

### `lib/app/modules/zhenxie/zhenxie_sentence_pair_details/controllers/zhenxie_sentence_pair_details_controller.dart`

需要分流的方法：

1. `getPairDetail()`

### `lib/app/modules/zhenxie/zhenxie_sentence_pair_fork_details/controllers/zhenxie_sentence_pair_fork_details_controller.dart`

需要分流的方法：

1. `getForkDetail()`

### `lib/app/modules/zhenxie/zhenxie_grammar_panorama_details/controllers/zhenxie_grammar_panorama_details_controller.dart`

需要分流的方法：

1. `getDatailsData()`
2. `getExampleList()`

同样，编辑 / 上下架 / 删除继续只走管理端。

## 建议的实现顺序

1. 先在 `language.dart` 新增用户端句子只读接口，命名尽量与 `language_console.dart` 一一对应。
2. 先改 4 个列表控制器，保证句子首页入口都能打开并加载。
3. 再改 5 个详情控制器，保证从列表跳详情和详情回列表刷新都正常。
4. 最后检查所有 `refreshSingleData`、`refreshPairDetail`、`refreshForkDetail` 这种“回退后刷新单项”的逻辑，确认也做了分流，不要只改首次加载。

## 命名建议

为了降低理解成本，建议用户端方法尽量与管理端平行：

1. `queryPatternBlueprintList` -> `querySentencePatternBlueprintList`
2. `queryPatternBlueprint` -> `querySentencePatternBlueprint`
3. `getPatternBlueprintFilters` -> `getSentencePatternBlueprintFilters`
4. `querySentencePatternCompareList` -> 同名放到 `LanguageUtil`
5. `getSentencePairDetails` -> 同名放到 `LanguageUtil`
6. `getManageGrammarPanoramaList` -> `getGrammarPanoramaList`

不必强行复用管理端 `Manage` 前缀。

## 实施注意点

1. 只做当前任务真正需要的分流改造，不顺手重构整个句子模块。
2. 注释要补齐，尤其是新增的接口方法和关键分流判断。
3. 保持现有参数组装逻辑，除非接口文档明确要求字段名不同。
4. realization set 相关请求字段要重点核对 `assetNid` / `nid` 差异。
5. `supportsPyramid` 只在蓝图 / 金字塔相关链路透传，不要扩散到无关接口。
6. 详情页里如果某些按钮本来就只对管理端可见，不要误改显隐逻辑。

## 自测清单

1. 管理端入口打开 5 个句子页面，确认仍走原有 `LanguageConsoleRequest`，行为不回退。
2. 用户端入口打开 5 个句子页面，确认能正常加载列表。
3. 用户端进入以下详情页，确认能正常展示：
   - 句型蓝图详情
   - 句型对照详情
   - 句间配链详情
   - 句间配链分叉详情
   - 语法全景详情
4. 用户端从详情返回列表，确认单项刷新逻辑没有继续误走管理端接口。
5. 金字塔入口确认 `supportsPyramid = true` 生效。
6. 列表筛选、搜索、排序在用户端至少各验证一次。

## 一句话实施要求

请在 **不改动管理端读写能力** 的前提下，为甄写句子模块补齐用户端只读接口，并让所有句子列表页 / 详情页根据 `isManagement` 正确切换 `LanguageConsoleRequest` 与 `LanguageUtil`。
