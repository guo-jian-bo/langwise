# 甄写词源记忆列表页（词源森林）

## 目标与验收口径
- 词法页 `zhenxie_lexis_view.dart` 的「词源记忆」门卡，点击后进入**新的词源记忆列表页**（词源森林列表页），不再直接进词源画布页。
- 列表数据对接 `POST /languages/write/zhenxie/word/etymology/pages`，结构参考 `xxx7.json`（`{offset, limit, count, datas}`）。
- 页面视觉与信息结构参考 React `ui_ux/src/pages/zhenxie/dictionary/etymology/EtymologyForestListPage.tsx`：
  - 一片森林一张卡，3 列网格。
  - 卡片内含迷你词源树 + 徽标（单词/短语）+ 词性 + 树数/分支数/义项数 + 描述。
- 页面顶部使用项目现有 `BreadcrumbWidget` 面包屑，不照搬 React 顶栏。
- 页面底部使用 Flutter 已封装的搜索筛选组件 `FilterStripWidget`（搜索 + 筛选 + 排序 + 重置）。
- 卡片点击跳既有词源画布页 `Routes.ETYMOLOGY_MEMORY`。

## 改动点列表
- 新增 `controllers/zhenxie_etymology_forest_controller.dart`：列表分页、筛选元数据、筛选参数构建、跳转画布页。
- 新增 `bindings/zhenxie_etymology_forest_binding.dart`：按 tag `lazyPut` 控制器。
- 新增 `views/zhenxie_etymology_forest_view.dart`：面包屑 + 标题说明 + 三列网格 + 底部筛选。
- 新增 `views/zhenxie_etymology_forest_card_widget.dart`：森林卡片与迷你词源树自绘。
- 新增 `lib/common/entities/zhenxie_etymology_forest_entity.dart`：列表项实体与分支文案实体，并在 `entities.dart` 导出。
- `lib/common/https/zhenxie.dart` 新增：
  - `getEtymologyForestPage({data, parameters})` → `POST /languages/write/zhenxie/word/etymology/pages`
  - `getEtymologyQueryMetaGroupList()` → `GET /languages/write/zhenxie/word/etymology/query/meta/group/list`
- 路由三件套注册：
  - `lib/app/routes/app_routes.dart`：新增 `Routes.ZHENXIE_ETYMOLOGY_FOREST = '/zhenxie-etymology-forest'`
  - `lib/app/routes/tag_routes.dart`：`_pages` 注册 `ZhenxieEtymologyForestView.to`
  - `lib/app/routes/app_pages.dart`：新增对应 `GetPage`
- `zhenxie_lexis_controller.dart` 的 `onTapDoor` 中 `case "etymology"` 由 `Routes.ETYMOLOGY_MEMORY` 改为 `Routes.ZHENXIE_ETYMOLOGY_FOREST`。
- 放宽 `semanticId` 为可选：`lib/common/https/elements.dart` 的 `getContentEtymologyDetail` 与 `etymology_memory_controller.dart`。

## 关键设计 / 关键决策
- **数据来源**
  - 列表：`POST /languages/write/zhenxie/word/etymology/pages`，请求体使用 `filters: [{code, values}]` + `order` + 搜索关键字，分页参数走 query（`offset`/`limit`）。
  - 筛选元数据：`GET /languages/write/zhenxie/word/etymology/query/meta/group/list`，返回统一元数据结构 `{searchHints, filters, orders}`。
- **元数据实体复用**：直接复用既有统一实体 `ZhenduScriptQueryMetaGroupListEntity`（`zhendu_entity.dart`），字段结构完全匹配，不新增同类实体。
- **绕过不兼容的旧工具**：`FilterStripUtils.getSortDataFrom` / `getConditionDataFrom` 与当前元数据结构不兼容，改为在 controller 内自建 `_buildFilterConditions()` / `_buildFilterSorts()`，直接把元数据翻译成 `FilterConditionsData` / `FilterSortsData`。
- **排序值还原**：`FilterStripWidget` 只回调展示名，controller 通过 `_resolveOrderValue()` / `_metaOrderValue()` 回查元数据拿原始 `order` 值，避免把展示名当参数传出去。
- **多语言字段取值**：`coreText` / `gloss` / `descriptions` / `branchTexts` 全部取 `lang == "zh"`；在卡片文件内自写 `_zxForestZhText` 帮助函数，不引入 `LearningLangUtils`，避免影响其他语言展示逻辑。
- **迷你词源树**：按 `ui_ux/src/pages/zhenxie/user/specimens/index.tsx` 的 `EtymologyMiniTree` 常量与画法逐值复刻（词头 22、标题 14、分支 15、锚点间距 6/8、曲线高 34、列间距 16 等），超限分支 `sublist(0, cap-1)` + 末尾 `+N`；`_zxMiniForestTreePainter` 用两条同路径曲线（宽 6 低透明 + 宽 1.7 高透明）模拟发光主枝。
- **页面骨架**：与 `zhenxie_phrase_pair_view.dart` 保持一致，`build` 置顶，下方只保留 `_buildTitleWidget` / `_buildListWidget` / `_buildFilterWidget` 三个模块方法；筛选作为 `floatingActionButton` 底部居中悬浮，不额外抽独立组件。
- **卡片点击**：不传 `semanticId`，只带 `contentType` / `contentId` / `isManagement` 进 `ETYMOLOGY_MEMORY`。
- **空态**：`dataList` 为空且非加载中时展示 `NotDataWidget`，文案「没有匹配的森林，试试重置筛选。」。

## 兼容性影响与注意事项
- 列表接口失败或为空时不做本地兜底，直接展示空态。
- 词源画布页 `EtymologyMemoryController` 已放宽 `semanticId` 校验：不传 `semanticId` 时画布页调用接口会省略该参数，属既定行为变更。
- 新路由为纯新增，不影响既有 `ETYMOLOGY_MEMORY` 页的既有入口与行为。
- 筛选元数据接口返回为空时仅不渲染筛选区，列表仍可正常加载。

## TODO
- 卡片内词性与统计徽标的像素级还原待继续对齐 React。
- 迷你树在分支数极多/词头极长时的宽度估算（`_zxForestEstimateTextWidth`）可再按真实字体度量校正。
- 列表分页加载目前为滚动触底追加，后续如需要可补下拉刷新交互。
