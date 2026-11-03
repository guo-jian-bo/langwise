# App 主界面导航重构任务拆分清单

## 文档目的

本清单用于承接 [app_main_shell_navigation_refactor.md](file:///Users/guojianbo/code/langwise/docs/app_main_shell_navigation_refactor.md) 的方案设计，将“首页壳层改造 + 一级业务页独立化 + 一级业务页面包屑统一”拆解为可执行任务。

本次重构目标是：

- 保留 `ApplicationView` 作为首页壳层
- 保留 `HomeView` 作为首页内容主体
- 首页 tab 点击不再做同层切换，而是 push 到一级业务页
- 一级业务页不再显示首页底部 tabbar
- `甄听 / 甄读 / 音乐 / 要素 / 专项` 五个一级业务页统一接入 breadcrumb
- 一级页到详情页的 breadcrumb 链路保持连续

## 任务总览

```text
阶段 1：首页壳层瘦身
阶段 2：首页导航改为 push
阶段 3：一级业务页独立化
阶段 4：一级业务页面包屑统一
阶段 5：详情链路 breadcrumb 收敛
阶段 6：刷新与返回语义修正
阶段 7：联调与回归验证
```

## 阶段 1：首页壳层瘦身

### 目标

将 `ApplicationView` 从“六页切换容器”收敛为“首页壳层”。

### 涉及文件

- `lib/app/modules/application/views/application_view.dart`
- `lib/app/modules/application/controllers/application_controller.dart`

### 任务项

- 移除 `ApplicationView` 中用于承载六个 tab 页的并列页面容器
- 移除首页壳层对 `AnimatedSwitcher + navIndex` 的主内容切换依赖
- 将 `ApplicationView` 的主体收敛为：
  - `HomeView`
  - `NavButtonsWidget`
  - 用户入口
  - 新手任务浮层
- 保留首页壳层必要的全局逻辑，不把这些能力下沉到 `HomeView`

### 完成标准

- 打开 `Routes.APPLICATION` 时只展示首页内容
- `ApplicationView` 不再承载 `SubListenPage / ZhenduHomeView / NewMusicView / DictionaryPage / SpecialtyView` 五个并列业务页

## 阶段 2：首页导航改为 push

### 目标

将首页底部导航从“切换器”改为“跳转入口”。

### 涉及文件

- `lib/app/modules/application/common/nav_buttons_widget.dart`
- `lib/app/modules/application/controllers/application_controller.dart`

### 任务项

- 保留首页按钮“停留在当前页”的语义
- 将 `甄听 / 甄读 / 音乐 / 要素 / 专项` 五个按钮改为 push 行为
- 清理 `changeNavIndex()` 中与一级业务页切换强绑定的逻辑
- 收敛 `navIndex` 的职责，避免其继续承担主页面切换状态
- 明确 push 方式：
  - `Get.toNamed(...)`
  - 或 `TagRoutes.toNamed(...)`

### 完成标准

- 点击首页按钮不跳页
- 点击其他五个 tab 进入对应独立页面
- 页面进入后，不再通过首页壳层切换回来显示

## 阶段 3：一级业务页独立化

### 目标

让五个一级业务页都能够脱离首页壳层独立运行。

### 一级业务页清单

- `SubListenPage`
- `ZhenduHomeView`
- `NewMusicView`
- `DictionaryPage`
- `SpecialtyView`

### 任务项

- 检查每个一级业务页是否仍依赖首页壳层状态
- 将依赖 `navIndex`、壳层刷新时机、tab 切换副作用的逻辑迁回各自 controller
- 确保每个一级业务页可被路由直接打开
- 统一一级页的页面结构：
  - 顶部 breadcrumb
  - 中间业务内容
  - 不再显示首页 tabbar

### 完成标准

- 五个一级业务页都可通过独立路由进入
- 不依赖首页“切过去”才能正常初始化

## 阶段 4：一级业务页面包屑统一

### 目标

统一 `甄听 / 甄读 / 音乐 / 要素 / 专项` 五个一级业务页的 breadcrumb 表达。

### 任务项

- 为一级业务页 controller 统一接入 `RoutesBreadcrumbMixin`
- 统一 `breadcrumbRoute`
- 统一 `breadcrumbTitle`
- 在一级业务页 `onInit()` 中初始化 breadcrumb
- 页面顶部统一使用 `BreadcrumbWidget`
- 统一一级业务页的返回语义为“返回首页”

### 标题口径建议

- `甄听`
- `甄读`
- `音乐`
- `要素`
- `专项`

说明：

- 不建议一级页标题继续混用历史口径，例如 `音乐 / 新音乐`
- 一级 breadcrumb 节点应该稳定，便于后续详情页向下延伸

### 完成标准

- 五个一级业务页顶部都能看到统一风格的 breadcrumb
- breadcrumb 文案口径统一
- 返回行为一致

## 阶段 5：详情链路 breadcrumb 收敛

### 目标

让一级业务页进入详情页后的 breadcrumb 能连续表达层级。

### 重点链路

- `甄听 -> subscribe_and_listening_details`
- `甄读 -> zhendu_look`
- `甄读 -> zhendu_perform`
- `甄读 -> zhendu/show_detail`
- `甄听详情 -> listen_and_read`
- `要素 -> elements` 各详情页
- `专项 -> phonics_course`

### 任务项

- 检查详情页是否已经使用 `RoutesBreadcrumbMixin`
- 检查详情页是否已具备 `tagText`、`binding`、`view` 的完整 tagged 链路
- 统一详情页 breadcrumb 的父级语义，避免跳层
- 确保从一级页进入详情页时，breadcrumb 保持连续
- 校正与旧 tab 语义耦合的返回逻辑

### 完成标准

- 从一级页进入详情页后，breadcrumb 能清楚表达“首页 / 一级页 / 详情页”
- 详情页返回到一级页逻辑稳定

## 阶段 6：刷新与返回语义修正

### 目标

解决从“同层切换”改为“push 跳转”后带来的刷新和返回问题。

### 任务项

- 清理 `ApplicationController` 中原本依赖 tab 切换的刷新逻辑
- 将页面刷新逻辑迁回一级业务页自身 controller
- 明确一级业务页返回首页时的行为
- 明确重复进入同一一级页时的策略：
  - 允许重复 push
  - 或避免重复打开
- 明确从详情页返回一级页时是否保留滚动位置、筛选条件、搜索状态

### 完成标准

- 一级业务页首次进入正常刷新
- 返回一级业务页状态符合预期
- 返回首页语义一致

## 阶段 7：联调与回归验证

### 目标

验证首页导航、一级业务页、详情页 breadcrumb 是否形成完整闭环。

### 核心验证项

- 首页展示正常
- 首页 tabbar 只在首页出现
- 点击 `甄听 / 甄读 / 音乐 / 要素 / 专项` 会 push 到独立页面
- 一级业务页顶部 breadcrumb 正常显示
- 一级业务页返回首页正常
- 详情页 breadcrumb 连续
- 详情页返回一级页正常
- 用户入口、收藏入口、任务浮层只在首页保留
- 不出现旧 `navIndex` 切换残留行为

### 建议验证链路

- 首页 -> 甄听 -> 甄听详情 -> 听读 -> 返回
- 首页 -> 甄读 -> 看 -> 返回
- 首页 -> 甄读 -> 演 -> 返回
- 首页 -> 音乐 -> 播放页 -> 返回
- 首页 -> 要素 -> 卡片详情 -> 返回
- 首页 -> 专项 -> 发音课 -> 返回

## 推荐实施顺序

建议按以下顺序推进，避免互相打架：

1. 首页壳层瘦身
2. 首页 tab 行为改为 push
3. 五个一级业务页脱离壳层独立运行
4. 五个一级业务页统一 breadcrumb
5. 一级页到详情页 breadcrumb 收敛
6. 刷新与返回语义修正
7. 联调回归

## 可并行与不可并行

### 可并行

- `甄听` 与 `音乐` breadcrumb 细化
- `甄读` 内多个子页面 breadcrumb 补齐
- `要素` 详情链路梳理
- `专项` 详情链路梳理

### 不建议并行

- 首页壳层瘦身 与 一级业务页 breadcrumb 最终口径定稿
- 首页导航方式改造 与 返回语义最终收敛

原因：

- 这几项会直接影响 breadcrumb 第一层节点表达
- 如果同时推进，容易出现返工

## 最终交付定义

本次重构完成的标志不是“首页能跳转了”，而是同时满足以下条件：

- `ApplicationView` 成为真正首页壳层
- `HomeView` 成为首页内容主体
- 首页 tab 点击进入一级业务页采用 push 语义
- 一级业务页不再显示首页浮动 tabbar
- `甄听 / 甄读 / 音乐 / 要素 / 专项` 五个一级业务页 breadcrumb 全部统一
- 一级业务页到详情页 breadcrumb 连续
- 返回路径、刷新时机、页面状态都符合预期

## 后续可继续补充

如果需要继续细化，下一步可以再补两份文档：

1. 页面树与路由迁移图
2. 风险清单与回滚方案
