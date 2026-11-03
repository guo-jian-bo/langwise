## 目标与验收口径

- 从“甄写管理台 -> 文章 -> 写作阶梯”卡片可进入 Flutter 写作阶梯页。
- 页面结构固定为顶部面包屑、中间内容区、底部筛选区。
- 默认展示地图；通过底部右侧 `地图 | 列表` switch 切换中间 content。
- 地图首版包含四泳道、节点、金柱和点击后的中间弹层卡片。
- 列表首版包含三列卡片，只展示当前筛选结果；列表态显示排序。
- mock 数据通过 `LanguageConsoleRequest` 假 API 延迟返回，便于后续替换真实接口。

## 本次改动点

- 新增 `zhenxie_composition_stages` 模块的 binding、controller、models、view。
- 新增 `ZhenxieCompositionStageCardWidget`，供地图弹层和列表卡片共用。
- 在 `LanguageConsoleRequest` 中新增写作阶梯假 API，延迟 1 秒读取本地 composition mock JSON。
- 新增 `assets/mock/zhenxie/composition/` 全量 mock 数据，并在 `pubspec.yaml` 注册 `assets/mock/`。
- 接入 `Routes`、`GetPage`、`TagRoutes`、`ManagePageRegistry` 和甄写管理台入口卡片。

## 关键设计

- 底部筛选区不修改公共 `FilterStripWidget`，而是由页面自己拼成“左筛选条 + 右 switch”。
- 地图和列表共用同一份筛选结果，避免双视图切换时语义不一致。
- `StageCardWidget` 地图弹层与列表复用同一套内容结构，避免后续出现展示漂移。
- 模型字段尽量直接对齐 mock JSON，减少未来接真实接口时的映射成本。

## 兼容性与注意事项

- 当前“编辑 / 蓝图 / 范文 / 任务”按钮仍是占位交互，统一使用管理端 toast 提示。
- 当前封面路径优先尝试真实图片资源；缺失时会回退为占位样式。
- 列表排序首版只支持“课序 / 目录序”两种表达，后续再继续细化对齐 React。

## 后续 TODO

- 将写作阶梯假 API 替换为真实后端接口。
- 为按钮接入真实跳转链路。
- 继续补齐更完整的排序、筛选和细节视觉对齐。

## 地图分页改造

### 目标与验收口径

- 地图不再一次性请求 300 条并全量 `Stack` 渲染。
- 地图首屏只拉取 30 条，横向滚动接近尾部时继续请求下一页。
- 泳道仍保持“顶部金柱标题预留区 + 中间泳道等分区 + 底部预留区”的纵向结构。
- 金柱标题继续按当前已加载范围跨列居中显示。

### 改动点

- `zhenxie_composition_stages_controller.dart`
  - 新增地图分页状态、横向滚动监听和分页追加逻辑。
  - 新增列级派生数据 `CompositionStageMapColumnModel`。
  - 新增 milestone segment 计算和标题 overlay 分组计算。
- `zhenxie_composition_stages_models.dart`
  - 新增 `CompositionStageMilestoneSegmentType`。
  - 新增 `CompositionStageMapColumnModel`。
- `zhenxie_composition_stages_view.dart`
  - 地图内容区改为横向 `ListView.builder` 按列渲染。
  - 金柱背景改为按列 segment 渲染。
  - 金柱标题改为轻量 overlay，按当前已加载列范围居中显示。

### 关键设计

- 每个 `stage` 对应一列，`genreNid` 决定这一列节点落在哪条泳道。
- 金柱背景不再一次性画整段宽块，而是拆成 `single/start/middle/end` 四类 segment。
- 每次分页追加后，对当前已加载的全部列重新计算 segment 和标题分组，以支持跨页 milestone 自动合并。

### 兼容性与注意事项

- 当前列表视图仍沿用同一份已加载数据，后续若要完整支持列表分页，需要单独补齐列表态策略。
- 金柱标题采用“按当前已加载范围居中”的方案，后续继续加载更多列时，标题位置允许轻微重新居中。

## 用户端接入（章法）

### 目标与验收口径

- 甄写首页“章法”卡点击直接进入本页，并传 `{"isManagement": false}`。
- 页面结构统一为“面包屑 + 内容区 + 底部区域”，两端共用同一套骨架。
- 用户端底部区域照 React 版实现，右侧 switch 为 `书架 | 地图`；管理端维持原有的 `筛选条 + 地图 | 列表`。
- 内容区共三种：`shelf`（书架）/ `map`（地图）/ `list`（列表）。本期只做书架，地图与列表沿用已有实现。
- 卡片底部动作按端区分：管理端 `编辑 / 蓝图 / 范文 / 任务`，用户端只留 `蓝图 / 范文`。
- 面包屑标题改为“章法”，两端一致。

### 改动点

- 新增 `zhenxie_composition_shelf_widget.dart`：用户端书架内容区，对齐 React `BlueprintShelf`。
- 新增 `zhenxie_composition_user_strip_widget.dart`：用户端底部区域，对齐 React `ParagraphTypeStrip` + `ViewSwitch`。
- 新增 `models/zhenxie_composition_shelf_mock_data.dart`：书架写死数据，包含 6 道大关、45 张蓝图、9 条段型、4 个文类、封面地址和“蓝图 -> 家族”映射。
- `zhenxie_composition_stages_controller.dart`
  - `breadcrumbTitle` 由“写作阶梯”改为“章法”。
  - `onInit` 从 `Get.arguments` 读取 `isManagement`，并按端决定默认视图（用户端 `shelf`，管理端 `map`）。
  - 新增 `buildGenreCountMap()` / `getGenreCountUnit()`：底部文类计数按当前视图统计，单位随视图切换。
  - 新增 `openShelfBlueprintPage()` / `openShelfParagraphType()`：书架瓦片与底部段型的跳转。
- `zhenxie_composition_stages_view.dart`
  - 内容区由二选一改为三选一，`shelf` 走书架 Widget。
  - `_buildBottomBarWidget` 按 `isManagement` 切换整套底部区域。
  - 卡片传入 `isManagement`。
- `zhenxie_composition_stage_card_widget.dart` 新增 `isManagement`，据此决定渲染第几个动作按钮。
- `zhenxie/views/zhenxie_view.dart`：“章法”层卡由占位 toast 改为跳本页并传 `isManagement: false`。

### 关键设计

- 底部区域整体按端切换，而不是在同一个筛选条里加分支，避免两端语义互相干扰。
- 书架数据本期写死，不走远端接口；因此书架视图不与远端阶梯列表的加载态、空态绑定。
- 书架按“蓝图开始教的那一关”分格，不新增文类的大关并入前一格并附一句说明。
- 底部文类计数跟着视图走：书架数蓝图（张），地图直接取接口 `genres[].compositionStageCount`（个），不按当前已加载的阶梯列表统计。

### 兼容性与注意事项

- 接口仍复用管理端 `LanguageConsoleRequest`，用户侧独立接口后续单独替换。
- 用户端打开时仍会加载远端阶梯数据，地图视图依赖它；书架视图不依赖。
- 书架瓦片跳转按“家族 + 蓝图”维度打开蓝图详情，依赖写死数据里的家族映射；后续接真实接口时需一并替换。

### 后续 TODO

- 书架数据由写死改为真实接口。
- 用户侧独立请求层替换管理端接口。
- 管理端是否也接入书架视图，待产品确认。

## 用户端接真实接口（章法）

> 本节覆盖上一节里“书架写死数据、复用管理端接口”的临时做法。

### 目标与验收口径

- 用户端进入本页只调用户端三个接口，不再调管理端旧接口：
  - `GET /languages/write/zhenxie/composition/discourse/home`（壳数据：里程碑 / 段型 / 文类 / 汇总文案）
  - `POST /languages/write/zhenxie/composition/blueprint/list`（45 张文章蓝图）
  - `POST /languages/write/zhenxie/composition/stage/pages`（阶梯分页，与原有 `CompositionStageModel` 同构）
- 管理端维持原样：仍走 `LanguageConsoleRequest` 的旧接口与筛选 / 排序参数。
- 用户端分页只传 `offset / limit`，`order` 只有管理端传。
- 文类色取接口 `genres[].genre.colors[]`，按当前项目主题（`ThemeUtils.isCurrentTheme('DARK')`）在 LIGHT / DARK 两套里取值；取不到再退回接口 `genre.color`，最后退回通用主题色。
- 书架与底栏写死的颜色改为 `AppTheme` 通用主题色，跟随项目明暗主题切换。
- 面包屑右侧渲染当前视图的汇总文案：书架 = `蓝图数 + shelfSummaryText`，地图 = `阶梯总数 + mapSummaryText`。
- `genre/list` 不再调用；`beat/list`（`getParagraphRhetoricalList`）照旧调用，起承转合相关代码不动。

### 改动点

- `common/https/zhenxie.dart` 新增三个用户端接口封装，返回 `Map<String, dynamic>?`。
- 新增 `models/zhenxie_composition_discourse_models.dart`：`CompositionThemeColorModel` / `CompositionMilestoneModel` / `CompositionMilestoneGateModel` / `CompositionParagraphTypeModel` / `CompositionDiscourseCardModel` / `CompositionGenreSummaryModel` / `CompositionShelfGateModel` / `CompositionDiscourseHomeModel` / `CompositionShelfBlueprintModel`。
- 删除 `models/zhenxie_composition_shelf_mock_data.dart`。
- `zhenxie_composition_stages_controller.dart`
  - `initData` 按端分流：管理端走 `_initManagementBaseData`，用户端走 `_initUserBaseData`（三个新接口并发取）。
  - 新增 `_rebuildGenreThemeColorMap` / `_buildShelfGates` / `_shelfGateShortName` / `_parseShelfBlueprints`。
  - 新增 `getSummaryText()`；`getGenreColor` / `getLaneGenreColor` 优先取主题色。
  - `buildGenreCountMap()` 书架态改为数 `shelfBlueprintList`；地图态取 `genres[].compositionStageCount`，不再遍历 `stageList`。
  - `_buildPageParameters` 只给管理端加 `order`。
- `zhenxie_composition_shelf_widget.dart`：由写死数据改为读 controller 的 `shelfGateList` / `shelfBlueprintList`，颜色改 `AppTheme`。
- `zhenxie_composition_user_strip_widget.dart`：段型 / 文类 / 计数 / 视图开关全部改为读 controller，文案直接用接口 `paragraphTypeHint`。
- `zhenxie_composition_stages_view.dart`：面包屑抽成 `_buildBreadcrumbWidget()` 并挂 `actionWidget` 汇总文案；书架 Widget 与底栏改传 `controller`。

### 关键设计

- 大关抬头与别名由 `milestones` 派生：`school` 优先、其次 `ielts` 作抬头，其余用「 · 」拼进别名，`剑桥 ` 前缀剥掉；接口已按难度分组且组内排好序，不再本地重排。
- 书架分格沿用 React：蓝图按 `difficulty` 落到对应大关，最后一关用 `min(difficulty, 最后一关)` 夹住；不新增文类的大关并入前一格。
- 门标题 / 别名派生已用真实响应逐字校对，与 React 写死结果一致。
- 段型条整句文案（`paragraphTypeHint`）由接口下发，前端不再拼「每篇都由这 N 种段拼出来」。
- 汇总文案放在面包屑 `actionWidget`，管理端因 `isCompatibleManage` 仍整条隐藏，行为不受影响。

### 兼容性与注意事项

- 用户端与管理的差异只体现在数据来源、底栏、面包屑右侧文案与卡片动作上，页面骨架与管理端共用。
- 用户端地图仍依赖 `stage/pages`，书架不依赖；两视图切换时计数单位跟着变（张蓝图 / 个阶梯）。
- 起承转合（beat）一律沿用现有实现，本次未改动；`SlotStrip`、`_rebuildBeatMap`、`getParagraphRhetoricalList` 调用保持原样。
- 阶段蓝图 / 段蓝图详情跳转参数不变（`nid` + `blueprintNid` + `isManagement`）。

### 待确认问题 / TODO

- 用户端书架排序当前沿用接口返回顺序（`blueprint/list` 未返回 order）。
- 管理端是否也接入书架视图，待产品确认。
