# App 主界面导航重构方案

## 背景

当前用户端主界面由 `ApplicationView` 作为壳层页承载，核心结构如下：

- 主内容区在 `ApplicationView` 内通过 `AnimatedSwitcher` 按 `navIndex` 切换
- 底部导航使用自定义 `NavButtonsWidget`
- `HomeView`、`SubListenPage`、`ZhenduHomeView`、`NewMusicView`、`DictionaryPage`、`SpecialtyView` 处于同一壳层级
- 切换 tab 时，本质上是同层页面切换，而不是路由跳转

虽然当前主壳层并不是 `PageView`，但它仍然属于“壳内切页面”的模式。该模式的问题是：

- 各 tab 页面仍然处于同一 UI 层级，页面层次感弱
- 底部导航始终悬浮在页面底部，不利于深层内容页的沉浸感
- 面包屑更适合表达“页面进入链路”，不适合同层切换模型
- 主壳层承担了过多状态切换职责，导航语义不够清晰

## 重构目标

本次优化的核心目标不是简单“去掉 PageView”，而是将用户端主导航从“壳内切换”改为“首页分发 + 路由跳转”模式。

目标效果：

- `ApplicationView` 作为真正首页入口壳层
- `HomeView` 作为首页内容主体保留在壳层内部
- 首页保留 tabbar，但 tabbar 的语义从“同层切换”改为“导航跳转”
- 点击 tabbar 后，进入独立业务页面
- 进入业务页面后，不再显示原来的浮动 tabbar
- 业务页面顶部统一使用面包屑，形成清晰的“首页 -> 业务页 -> 详情页”路径

## 目标导航模型

### 现状模型

```text
ApplicationView
├── HomeView
├── SubListenPage
├── ZhenduHomeView
├── NewMusicView
├── DictionaryPage
└── SpecialtyView

切换方式：
NavButtonsWidget -> changeNavIndex() -> AnimatedSwitcher 切换子页面
```

### 目标模型

```text
ApplicationView
├── HomeView
├── NavButtonsWidget
├── 用户快捷入口
└── 新手任务浮层

点击 TabBar 后：

首页
├── push 到 SubListenPage
├── push 到 ZhenduHomeView
├── push 到 NewMusicView
├── push 到 DictionaryPage
└── push 到 SpecialtyView

业务页内部：
- 显示 BreadcrumbWidget
- 不显示原底部浮动 tabbar
```

## 结构设计建议

### 选型结论：保留 `ApplicationView`，保留 `HomeView`

本次重构不建议做成“二选一”，而建议保留两个，但重新定义职责。

推荐结论如下：

- `ApplicationView`：用户端首页壳层
- `HomeView`：首页内容主体

原因：

- 当前 `ApplicationView` 已承担主入口职责
- 底部导航、用户入口、任务浮层等壳层能力已沉淀在 `ApplicationView`
- 当前 `HomeView` 更像首页内容面板，而不是全局壳层
- 如果直接废掉 `ApplicationView`，需要把一整套壳层能力搬到 `HomeView`
- 如果两个都继续当“首页入口”，则语义重复，后续路由和面包屑会混乱

因此建议：

- 保留 `ApplicationView` 作为首页路由承载页
- `ApplicationView` 内部展示 `HomeView`
- tabbar 只在 `ApplicationView` 中展示
- 点击 tabbar 后，通过 push 进入各一级业务页
- 一级业务页不再显示原底部浮动 tabbar

### 命名优化建议

从长期维护角度，建议后续考虑对 `HomeView` 做一次语义化改名，避免与“首页壳层”概念混淆。

可选命名：

- `HomeContentView`
- `HomeDashboardView`
- `ApplicationHomeBody`

推荐理解方式：

```text
ApplicationView = 首页壳层
HomeView       = 首页内容
```

如果后续决定改名，建议在主导航重构完成后再统一处理，避免与本次结构调整交叉进行。

## UI 结构调整

### 1. 首页结构

首页保留以下元素：

- 主内容区 `HomeView`
- 底部导航栏 `NavButtonsWidget`
- 用户快捷入口
- 新手任务浮层

但导航栏行为改为：

- 首页按钮：留在当前首页
- 甄听：push 到 `SubListenPage`
- 甄读：push 到 `ZhenduHomeView`
- 音乐：push 到 `NewMusicView`
- 要素：push 到 `DictionaryPage`
- 专项：push 到 `SpecialtyView`

### 2. 业务页结构

业务页统一变成“独立页面”，结构建议如下：

```text
Scaffold
└── body
    ├── BreadcrumbWidget
    └── 页面内容
```

可保留：

- 页面自己的筛选条
- 页面自己的悬浮按钮
- 页面自己的搜索栏

应移除：

- 原首页壳层的底部导航栏
- 原首页壳层的用户快捷区域

### 3. 面包屑层级建议

建议统一为：

```text
首页 / 甄听
首页 / 甄读
首页 / 音乐
首页 / 要素
首页 / 专项
```

详情页继续延伸：

```text
首页 / 甄听 / 某专题
首页 / 音乐 / 播放页
首页 / 要素 / 单词详情
```

这样面包屑表达的是“用户从首页进入了某个业务域”，语义清晰。

### 4. 一级业务页面包屑统一优化

本次重构不应只改首页跳转方式，还需要同步把一级业务页内部的面包屑体系一起收敛，否则会出现“首页已经变成 push 导航，但一级业务页内部表现不一致”的问题。

本次建议将以下一级业务页统一纳入面包屑优化范围：

- `SubListenPage` 对应 `甄听`
- `ZhenduHomeView` 对应 `甄读`
- `NewMusicView` 对应 `音乐`
- `DictionaryPage` 对应 `要素`
- `SpecialtyView` 对应 `专项`

统一目标：

- 一级业务页顶部统一展示 `BreadcrumbWidget`
- 一级业务页都具备明确的 `breadcrumbRoute` 与 `breadcrumbTitle`
- 一级业务页都支持从首页 push 进入后的标准返回路径
- 一级业务页内部不再依赖首页 tab 切换语义
- 一级业务页进入详情页后，详情页面包屑继续向下延伸

建议统一后的一级页面层级如下：

```text
首页 / 甄听
首页 / 甄读
首页 / 音乐
首页 / 要素
首页 / 专项
```

详情页继续在一级页面基础上扩展：

```text
首页 / 甄听 / 专题详情
首页 / 甄读 / 看
首页 / 甄读 / 演
首页 / 音乐 / 播放页
首页 / 要素 / 卡片详情
首页 / 专项 / 发音课
```

#### 一级业务页统一标准

建议将一级业务页的面包屑标准收敛为：

- 页面 controller 接入 `RoutesBreadcrumbMixin`
- 页面在 `onInit()` 中执行 `initBreadcrumb(tagText)` 或等价初始化
- 页面顶部统一使用 `BreadcrumbWidget`
- 返回按钮语义统一为返回首页
- 一级业务页自身不再显示首页底部 tabbar

#### 已有基础与待补齐项

从当前代码现状看：

- `甄听`：已接入 `BreadcrumbWidget` 和 `RoutesBreadcrumbMixin`
- `音乐`：已接入 `BreadcrumbWidget` 和 `RoutesBreadcrumbMixin`
- `甄听详情`：已接入 breadcrumb 链路

仍需在这次主导航重构中统一评估与补齐：

- `ZhenduHomeView` 的一级页 breadcrumb 表达
- `DictionaryPage` 的一级页 breadcrumb 表达
- `SpecialtyView` 的一级页 breadcrumb 表达
- `甄读` 进入 `看 / 演 / 详情` 时的层级一致性
- `要素` 与内部详情页的 breadcrumb 连续性

#### 为什么必须一起做

如果只改首页导航，不同步优化一级业务页的面包屑，会出现以下问题：

- 首页已经变成二级进入语义，但一级业务页仍像原 tab 子页
- 用户进入一级业务页后，看不到明确的“首页 / 模块名”关系
- 后续详情页 breadcrumb 会出现跳层或语义不统一
- `甄听 / 甄读 / 音乐 / 要素 / 专项` 的返回体验不一致

因此建议把以下内容视为同一个交付包：

- 首页壳层导航改造
- 一级业务页独立化
- 一级业务页面包屑统一
- 一级页到详情页的 breadcrumb 连续性修正

## 路由设计建议

### 首页入口

保留：

- `Routes.APPLICATION`

它仍作为用户端默认主入口。

### 导航行为变化

原来：

- `changeNavIndex(index, context)` 修改 `navIndex`
- `ApplicationView` 内部切换子页面

重构后建议：

- 首页 tab 点击改为调用页面跳转
- 首页按钮仍停留在 `ApplicationView`
- 其余 tab 改为 push 到独立业务页
- 可使用 `Get.toNamed(...)` 或 `TagRoutes.toNamed(...)`
- 首页本身不再持有“六页并列容器”

### 路由语义

建议将以下页面视为一级业务路由：

- `Routes.APP_SUBSCRIBE_LISTENING`
- `Routes.ZHENDU_HOME` 或等价甄读入口路由
- `Routes.MUSIC`
- `Routes.DICTIONARY` 或对应要素入口路由
- `Routes.SPECIALTY`

这些一级业务路由在重构后，除了路由职责外，还应承担“一级面包屑节点”的职责。

也就是说，它们不只是“可跳转页面”，还应该成为 breadcrumb 的稳定第一层业务节点。

## 控制器职责调整

### `ApplicationController`

重构前主要职责：

- 记录 `navIndex`
- 切换 tab 页面
- 刷新 tab 对应内容

重构后建议收缩为：

- 首页初始化
- 全局用户入口和任务入口控制
- 首页上的导航分发
- 生命周期刷新

建议移除或弱化：

- `navIndex` 作为主页面切换状态
- 基于 `navIndex` 的页面刷新逻辑
- 壳层内部 tab 页面缓存逻辑

### 各业务页面控制器

需要增强为“独立页面自管理”模式：

- 页面首次进入时自初始化
- 页面离开时按需回收
- 通过面包屑和路由参数管理返回链路
- 一级业务页 controller 需要具备统一的 breadcrumb 初始化能力
- 一级业务页内部跳详情时，需要保证 breadcrumb 层级连续

## 迁移范围

本次重构涉及的核心文件预计包括：

- `lib/app/modules/application/views/application_view.dart`
- `lib/app/modules/application/controllers/application_controller.dart`
- `lib/app/modules/application/common/nav_buttons_widget.dart`
- `lib/app/modules/application/bindings/application_binding.dart`
- `lib/app/routes/app_pages.dart`

以及以下业务页的展示逻辑确认：

- `SubListenPage`
- `ZhenduHomeView`
- `NewMusicView`
- `DictionaryPage`
- `SpecialtyView`

以及以下面包屑配套页面：

- `subscribe_and_listening_details`
- `zhendu_look`
- `zhendu_perform`
- `zhendu/show_detail`
- `listen_and_read`
- `elements` 下的详情页
- `specialty/phonics_course`

## 推荐实施步骤

### 第一阶段：结构瘦身

- 保留 `ApplicationView` 作为首页壳层
- 保留 `HomeView` 作为首页内容
- 去掉 `ApplicationView` 中六页 `AnimatedSwitcher` 切换模型
- 首页只保留 `HomeView + NavButtonsWidget + 用户入口 + 任务浮层`

### 第二阶段：导航改造

- `NavButtonsWidget` 改为纯跳转行为
- 首页按钮留在当前页
- 其他按钮改为 push 到独立业务页面

### 第三阶段：页面去壳层依赖

- 检查各业务页是否仍依赖壳层状态
- 将依赖 `navIndex` 才能正确刷新的逻辑迁回各自 controller
- 保证页面支持“直接路由进入”

### 第四阶段：面包屑统一

- 一级业务页统一显示 `BreadcrumbWidget`
- 详情页继续沿用 tagged route + breadcrumb mixin 模式
- 确保返回路径从业务页可回首页
- 校正 `甄听 / 甄读 / 音乐 / 要素 / 专项` 五个一级页的 breadcrumb 标题和节点语义
- 打通一级页到二级详情页的 breadcrumb 连续性
- 对 `甄读`、`要素`、`专项` 内部未统一的页面进行补齐

### 第五阶段：交互完善

- 处理首页返回行为
- 处理重复打开同一一级业务页的策略
- 处理从详情页返回时的页面状态保持策略

## 风险点

### 1. 页面刷新时机变化

当前某些页面刷新依赖：

- `ApplicationController.changeNavIndex()`
- `ApplicationController.refreshHomePages()`

改为路由跳转后，这些刷新逻辑需要回归业务页面自己的生命周期，否则可能出现：

- 首次进入不刷新
- 返回后数据未更新
- 原 tab 切换时的懒刷新失效

### 2. 业务页直接进入能力不足

如果某些业务页默认假设自己在首页壳层内部运行，那么改为独立页面后可能出现：

- controller 初始化条件缺失
- 页面参数来源不完整
- 顶部/底部间距异常
- breadcrumb 首节点缺失或标题不统一

### 3. 用户心智变化

从“底部 tab 切换”变成“首页分发进入业务页”，用户会感知为：

- 首页是总控入口
- 业务页是二级页面

这对面包屑是友好的，但也意味着：

- 回退路径更长
- 用户在一级业务页之间切换不再像 tab 一样快

### 4. 底部导航资产复用方式变化

当前 `NavButtonsWidget` 与首页壳层耦合较深，含：

- 用户信息区
- 收藏入口
- 管理入口
- 新手引导 anchor

需要明确：

- 哪些能力只在首页展示
- 哪些能力要在业务页保留

### 5. 面包屑口径不统一

如果一级业务页内部的 breadcrumb 不同步梳理，容易出现：

- 同样是一级页，有的显示 breadcrumb，有的没有
- 同样是返回首页，有的返回语义一致，有的仍保留旧 tab 切换语义
- 一级页标题命名不统一，例如“音乐”与“新音乐”混用
- 详情页 breadcrumb 延续路径不稳定

## 建议结论

建议采用：

```text
保留 ApplicationView 作为首页
保留 HomeView 作为首页内容
保留底部导航，但仅在首页显示
首页点击 tab 后 push 到独立业务页
业务页不再显示原底部浮动 tabbar
业务页统一接入 BreadcrumbWidget
一级业务页内部的 breadcrumb 也同步收敛和补齐
```


这是当前代码结构下改动最可控、最利于面包屑适配的方案。

## 后续可继续输出的内容

如果确认本方案可行，下一步可以继续补两份文档：

1. 页面树与路由迁移图
2. 具体重构任务拆分清单

也可以直接进入变更 proposal / tasks 设计阶段。
