# 甄写章法蓝图模块用户端接口迁移提示词

## 目标

基于 `write_discourse_phrase_frontend_api_handoff.md`，补全甄写「章法蓝图」页面的用户端只读接口接入，并在现有页面中按 `isManagement` 做管理端 / 用户端分流。

这次范围只处理以下 4 个页面入口：

1. `段落蓝图`
2. `段落蓝图详情`
3. `文章蓝图`
4. `文章蓝图详情`

管理端继续走 `LanguageConsoleRequest`。
用户端新增并统一走 `LanguageUtil`。
这次只改“读”，不改“写”。

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

用户端章法蓝图只读接口统一新增到：

1. `lib/common/https/language.dart`

不要新增到 `elements.dart` 或其他 http 文件。

### 3. 用户端前缀规则

根据文档，章法接口 BasePath 为：

1. `/write/zhenxie`

前端用户端请求路径统一补成：

1. `/languages/write/zhenxie/...`

这次蓝图页对应路径应严格使用：

1. `/languages/write/zhenxie/paragraph/pages`
2. `/languages/write/zhenxie/paragraph/detail`
3. `/languages/write/zhenxie/composition/pages`
4. `/languages/write/zhenxie/composition/detail`

### 4. 数据结构规则

用户端和管理端返回结构保持一致，直接复用现有 Entity：

1. `ParagraphBlueprintEntity`
2. `ArticleBlueprintEntity`
3. `ListResponseEntity<T>`

### 5. 参数组织规则

用户端新接口的方法签名尽量与管理端保持一致，统一优先使用：

1. `parameters`
2. `data`

不要额外引入新的位置参数风格。

### 6. 非本次改造范围

以下内容不在这次迁移范围内：

1. 编辑接口
2. 上下架接口
3. 删除接口
4. AI 创建接口
5. UI 结构、样式、文案调整
6. 段落范文列表 / 范文详情接口迁迁移
7. 篇章写作任务详情 / 范文详情迁移

### 7. 当前保留项

这 4 个页面当前都依赖 `ParagraphRhetoricalEntity` 作为拍位/步骤渲染数据，现有来源是：

1. `LanguageUtil.getParagraphRhetoricalList()`

本次交接文档没有单独提供对应的用户端 beat/list 接口，因此这次先只迁移蓝图列表与蓝图详情接口。
`paragraphRhetoricalList` 保持现状，不在这次改造里扩散调整。

---

## 接口映射清单

## A. 段落蓝图分页列表

文档定义：

1. `POST /write/zhenxie/paragraph/pages`

用户端建议新增：

1. `LanguageUtil.getParagraphBlueprintList(...)`

对应用户端路径：

1. `/languages/write/zhenxie/paragraph/pages`

请求说明：

1. 请求体为 `EnParagraphTypeQuery`
2. 当前支持 `nid`
3. 分页参数仍从 query 传 `offset / limit / order`

## B. 段落蓝图详情

文档定义：

1. `GET /write/zhenxie/paragraph/detail?typeNid={typeNid}&blueprintNid={blueprintNid}`

用户端建议新增：

1. `LanguageUtil.getParagraphBlueprintDetail(...)`

对应用户端路径：

1. `/languages/write/zhenxie/paragraph/detail`

请求说明：

1. `typeNid` 和 `blueprintNid` 二选一即可
2. 当前前端详情页已有逻辑：
   - 如果有 `nid` 则传 `typeNid`
   - 否则传 `blueprintNid`
3. 迁移时保持这一行为，不改页面参数组织

## C. 文章蓝图分页列表

文档定义：

1. `POST /write/zhenxie/composition/pages`

用户端建议新增：

1. `LanguageUtil.getArticleBlueprintList(...)`

对应用户端路径：

1. `/languages/write/zhenxie/composition/pages`

请求说明：

1. 请求体为 `EnCompositionFamilyQuery`
2. 当前支持 `nid`
3. 分页参数仍从 query 传 `offset / limit / order`

## D. 文章蓝图详情

文档定义：

1. `GET /write/zhenxie/composition/detail?familyNid={familyNid}&blueprintNid={blueprintNid}`

用户端建议新增：

1. `LanguageUtil.getArticleBlueprintDetail(...)`

对应用户端路径：

1. `/languages/write/zhenxie/composition/detail`

请求说明：

1. `familyNid` 和 `blueprintNid` 二选一即可
2. 当前前端详情页始终透传：
   - `familyNid`
   - `blueprintNid`
3. 迁移时保持现有参数结构，不做额外重构

---

## 当前实现现状梳理

## 1. 管理端接口现状

当前 4 个页面全部只走管理端：

1. `LanguageConsoleRequest.getParagraphBlueprintList(...)`
2. `LanguageConsoleRequest.getParagraphBlueprintDetail(...)`
3. `LanguageConsoleRequest.getArticleBlueprintList(...)`
4. `LanguageConsoleRequest.getArticleBlueprintDetail(...)`

对应管理端路径分别是：

1. `/language-console/write/en/paragraph/pages`
2. `/language-console/write/en/paragraph/detail`
3. `/language-console/write/en/composition/pages`
4. `/language-console/write/en/composition/detail`

## 2. 需要改动的控制器清单

### `lib/app/modules/zhenxie/zhenxie_paragraph_blueprint/controllers/zhenxie_paragraph_blueprint_controller.dart`

需要分流的方法：

1. `getDataList()`

### `lib/app/modules/zhenxie/zhenxie_paragraph_blueprint_details/controllers/zhenxie_paragraph_blueprint_details_controller.dart`

需要分流的方法：

1. `getDataDetail()`

### `lib/app/modules/zhenxie/zhenxie_article_blueprint/controllers/zhenxie_article_blueprint_controller.dart`

需要分流的方法：

1. `getDataList()`

### `lib/app/modules/zhenxie/zhenxie_article_blueprint_details/controllers/zhenxie_article_blueprint_details_controller.dart`

需要分流的方法：

1. `getDataDetail()`

---

## 实施要求

1. 只做这 4 个页面真正需要的查询分流。
2. 保持现有 Entity、列表组装、滚动联动、详情跳转逻辑不变。
3. 不要顺手改 View。
4. 不要顺手改段落拍位数据来源。
5. 新增接口命名尽量与 `LanguageConsoleRequest` 对齐，降低阅读成本。

---

## 验收标准

完成后需要满足：

1. `isManagement == true` 时，行为与当前完全一致。
2. `isManagement == false` 时：
   - 段落蓝图列表走用户端接口
   - 段落蓝图详情走用户端接口
   - 文章蓝图列表走用户端接口
   - 文章蓝图详情走用户端接口
3. 路径严格使用 `/languages/write/zhenxie/...`
4. `dart analyze` 无新增 error
