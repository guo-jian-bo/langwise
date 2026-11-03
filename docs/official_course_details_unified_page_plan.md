# 课程详情统一页方案与实施跟踪

## 文档目标

- 用一个统一页面同时承载 `学习态` 和 `管理态`。
- 外部页面跳转到统一页时，通过路由参数控制默认进入哪种模式。
- 旧的“编辑教材页/添加教材页”在迁移完成后删除。
- 本文档在实现过程中持续更新，用于记录方案、实施顺序、完成状态和实际偏差。

## 当前结论

- 统一承载页选用现有 `Level` 页：
  - `lib/app/modules/official_course_details/official_course_details_level/views/official_course_details_level_view.dart`
- 统一页支持两种模式：
  - `学习态`
  - `管理态`
- 旧管理页最终删除：
  - `lib/app/modules/custom_course/custom_course_manage_grade/views/custom_course_manage_grade_view.dart`
- 外部跳转统一通过参数控制：
  - `initialMode: browse | manage`
- 当前只考虑大屏/桌面横屏体验。
- 退出管理态后：
  - 回到原 `Level`
  - 若原展开 `module` 仍属于原 `Level`，恢复展开
  - 若该 `module` 已移动或删除，则不展开任何 `module`
  - 不自动跳转到新 `Level`

## 目标范围

### 目标

- 统一页面骨架、底部栏和模式切换动画。
- 保留学习态的三列浏览与 `unit` 展开体验。
- 保留管理态的拖拽、暂存、重命名、删除、排序、新增年级能力。
- 所有原本跳转到旧管理页的入口迁移到统一页。
- 最终删除旧管理页及其独立入口。

### 非目标

- 不做竖屏适配。
- 不在管理态中保留 `unit` 展开面板。
- 不实现“退出管理态后自动跳到被移动模块的新 Level”。
- 不在第一阶段强制统一学习态与管理态的底层数据模型。

## 现状梳理

### 学习态入口与页面

- 主页面：
  - `lib/app/modules/official_course_details/official_course_details_level/views/official_course_details_level_view.dart`
- 主控制器：
  - `lib/app/modules/official_course_details/official_course_details_level/controllers/official_course_details_level_controller.dart`
- 当前特征：
  - 三列 `module` 网格
  - 点击 `module` 后在当前行下方展开 `unit` 面板
  - 底部栏是 `Level Tab + 管理教材`

### 管理态旧页面

- 旧页面：
  - `lib/app/modules/custom_course/custom_course_manage_grade/views/custom_course_manage_grade_view.dart`
- 旧控制器：
  - `lib/app/modules/custom_course/custom_course_manage_grade/controllers/custom_course_manage_grade_controller.dart`
- 当前特征：
  - 左两列管理区
  - 右一列暂存区
  - 支持拖拽、重命名、删除、级别排序、新增年级
  - 底部栏是 `Level Tab + 完成管理`

### 当前存在的问题

- 学习态和管理态分属两个页面，用户心智上像“跳走了”。
- 底部栏虽然形态接近，但并未统一成同一页面中的模式切换。
- 管理页是独立页面语义，后续难以删除。
- 外部入口如果有“直达管理教材”，当前只能走旧页面。

## 最终设计

### 页面模型

```text
OfficialCourseDetailsUnifiedPage
├── Breadcrumb / 顶部信息
├── 内容区
│   ├── 学习态 BrowseSection
│   │   ├── Level Header
│   │   ├── 三列 Module Grid
│   │   └── Unit Expanded Panel
│   └── 管理态 ManageSection
│       ├── 左两列管理区
│       ├── Level Header + 重命名/删除
│       └── 右一列暂存区
└── UnifiedBottomBar
    ├── Level Tab
    └── 右侧主按钮
```

### 模式定义

#### 学习态

- 展示三列 `module` 卡片。
- 点击卡片后展开 `unit` 面板。
- 底部栏右侧按钮为 `管理教材`。

#### 管理态

- 展示左两列管理区和右一列暂存区。
- 支持拖拽、重命名、删除、排序、新增年级。
- 不展开 `unit` 面板。
- 底部栏右侧按钮为 `完成管理`。

## 路由设计

### 路由参数

- `courseId`
- `levelId`
- `moduleId`
- `initialMode`

### 参数约定

```dart
{
  "courseId": courseId,
  "levelId": levelId,
  "moduleId": moduleId,
  "initialMode": "browse", // 或 "manage"
}
```

### 进入规则

- 普通课程浏览入口：
  - `initialMode = browse`
- “管理教材/添加教材/教材维护”类入口：
  - `initialMode = manage`

## 状态恢复规则

### 进入管理态前

- 记录：
  - 当前 `activeLevelId`
  - 当前 `expandedModuleId`

### 退出管理态后

- 恢复进入前的 `activeLevelId`
- 校验原 `expandedModuleId` 是否仍属于该 `Level`
- 如果仍属于该 `Level`，恢复展开
- 如果不属于、已移动或已删除，则不展开任何 `module`

## 底部栏统一方案

- 整个页面只保留一套底部栏容器。
- 外层容器不变，只切换内部内容。

### 学习态

- 中间：`Level Tab`
- 右侧：`管理教材`

### 管理态

- 中间：`Level Tab`
- 右侧：`完成管理`

### 动画建议

- 底部栏使用 `AnimatedSwitcher`
- 不改变外层位置与尺寸
- 按钮文案和交互语义切换

## 内容区动画方案

### 学习态 -> 管理态

- 学习态内容整体淡出
- 管理态左侧工作区淡入
- 右侧暂存区从右向左滑入

### 管理态 -> 学习态

- 暂存区先滑出
- 管理态左侧工作区淡出
- 学习态三列内容淡入
- 按规则恢复展开状态

### 动画原则

- 采用“区域级过渡”
- 不做复杂的逐卡片重排动画

## 组件拆分方案

### 页面壳

- 保留：
  - `official_course_details_level_view.dart`
- 职责：
  - 页面模式切换
  - 顶层动画
  - 挂载统一底部栏
  - 挂载学习态/管理态内容区

### 建议新增组件

- `lib/app/modules/official_course_details/official_course_details_level/views/widgets/browse_section.dart`
- `lib/app/modules/official_course_details/official_course_details_level/views/widgets/manage_section.dart`
- `lib/app/modules/official_course_details/official_course_details_level/views/widgets/storage_workspace.dart`
- `lib/app/modules/official_course_details/official_course_details_level/views/widgets/unified_bottom_bar.dart`
- `lib/app/modules/official_course_details/official_course_details_level/views/widgets/cards/course_module_card_shell.dart`
- `lib/app/modules/official_course_details/official_course_details_level/views/widgets/cards/browse_module_card.dart`
- `lib/app/modules/official_course_details/official_course_details_level/views/widgets/cards/manage_module_card.dart`

### 拆分原则

- `Section` 级别分开
- `Card Shell` 级别共用
- 页面壳统一

## Controller 方案

### 主控

- 沿用：
  - `official_course_details_level_controller.dart`

### 主控新增职责

- 解析 `initialMode`
- 管理 `pageMode`
- 进入管理态
- 退出管理态
- 记录学习态上下文
- 恢复学习态上下文

### 主控建议新增字段

- `initialMode`
- `pageMode`
- `browseRestoreLevelId`
- `browseRestoreExpandedModuleId`
- `shouldRestoreExpandedModule`

### 管理域复用能力

从旧管理控制器中复用或迁移：

- `gradesList`
- `topList`
- `startDrag()`
- `moveToTop()`
- `moveToGrade()`
- `modifyModuleName()`
- `modifyModuleCover()`
- `deleteModule()`
- `addGrade()`
- `sortGrade()`

### 明确不保留的旧页语义

- 独立页面 `back()`
- 独立页面底部栏
- 直接 `Get.back()` 的页面退出语义

## 迁移策略

### 阶段 1

- 给统一页增加 `initialMode`
- 实现单页双模式切换壳
- 暂不删除旧管理页

### 阶段 2

- 抽管理态内容区
- 抽统一底部栏
- 外部入口逐步改到统一页

### 阶段 3

- 删除旧管理页 view / binding / route
- 删除旧入口调用

## 实施任务清单

### Task 1: 统一入口与模式字段

- [x] 新增 `OfficialCourseDetailsPageMode`
- [x] 主控支持 `initialMode`
- [x] 主控支持 `pageMode`
- [x] 统一页可通过参数直接进入管理态

### Task 2: 加入浏览上下文记录与恢复

- [x] 进入管理态前记录 `activeLevelId`
- [x] 进入管理态前记录 `expandedModuleId`
- [x] 退出管理态时恢复原 `Level`
- [x] 原模块仍在原 `Level` 时恢复展开
- [x] 原模块已移动或删除时不展开

### Task 3: 统一底部栏

- [x] 抽 `unified_bottom_bar.dart`
- [x] 学习态显示 `管理教材`
- [x] 管理态显示 `完成管理`
- [x] `Level Tab` 统一承载

### Task 4: 抽管理态内容区

- [x] 抽 `manage_section.dart`
- [x] 抽 `storage_workspace.dart`
- [x] 迁移拖拽相关 UI
- [x] 迁移等级头操作 UI

### Task 5: 抽学习态内容区

- [x] 抽 `browse_section.dart`
- [x] 保留三列 module 布局
- [x] 保留 `unit` 展开面板

### Task 6: 抽共享卡片骨架

- [x] 抽 `course_module_card_shell.dart`
- [x] 抽 `browse_module_card.dart`
- [x] 抽 `manage_module_card.dart`
- [x] 学习态与管理态卡片风格统一

### Task 7: 迁移外部入口

- [x] `official_course_details_level_controller.dart` 不再跳旧管理页
- [x] `official_course_details_controller.dart` 不再跳旧管理页
- [x] 其他入口统一改为跳统一页并传 `initialMode`

### Task 8: 删除旧管理页

- [x] 删除旧 view
- [x] 删除旧 binding
- [x] 删除旧路由入口
- [x] 清理不再使用的管理页壳代码

## 风险与关注点

- 学习态与管理态底层数据结构暂未统一，第一阶段应避免强合并。
- 管理态拖拽与学习态点击展开是两套交互语义，必须隔离。
- 上下文恢复不能依赖旧页面生命周期，需要统一页自己维护。
- 删除旧管理页前，必须确认所有外部入口已迁移完成。

## 变更记录

### 2026-07-03 初版

- 确定统一页承载两种模式
- 确定旧管理页最终删除
- 确定 `initialMode` 路由参数方案
- 确定退出管理态后的上下文恢复规则
- 确定组件拆分与实施顺序

### 2026-07-03 Task 1 开始

- 开始接入统一页的 `initialMode / pageMode`
- 第一阶段先完成模式壳、底部栏切换和入口切换
- 管理态内容区在过渡版本中暂不接入完整管理布局，后续由 `Task 4` 接管

### 2026-07-03 Task 1 完成

- 已新增统一页模式枚举 `OfficialCourseDetailsPageMode`
- 已支持从路由参数 `initialMode` 直接进入学习态或管理态
- 已将 `Level` 页切为双模式页面壳
- 已将“管理教材”入口从旧独立页切为统一页内模式切换

### 2026-07-03 Task 2 完成

- 已实现进入管理态前捕获 `activeLevelId / expandedModuleId`
- 已实现退出管理态后恢复原 `Level`
- 已实现原 `module` 仍在原 `Level` 时恢复展开
- 已实现原 `module` 已移动或删除时不展开任何 `module`
- 当前管理态内容区仍为过渡占位，后续由 `Task 4` 替换为真实管理布局

### 2026-07-03 Task 3 完成

- 已抽出 `unified_bottom_bar.dart`
- 已实现学习态与管理态共用同一底部栏容器
- 已实现管理态使用自己的 `Level Tab`
- 已实现“完成管理”退出前接入暂存区确认逻辑

### 2026-07-03 Task 4 部分完成

- 已抽出 `manage_section.dart`
- 已将旧管理页的左两列管理区迁入统一页
- 已将旧管理页的右侧暂存区迁入统一页
- 已接入拖拽、重命名、删除、级别排序、新增年级等管理 UI
- `storage_workspace.dart` 尚未单独拆文件，目前仍内聚在 `manage_section.dart`

### 2026-07-03 Task 7 部分完成

- 已移除 `official_course_details_level_controller.dart` 对旧管理页入口的依赖
- 已将 `official_course_details_controller.dart` 的“编辑教材”入口改为跳统一页并传 `initialMode = manage`
- 已将 `CustomCourseManageGradeView.to` 调整为统一页 `manage` 模式转发壳
- 已将旧管理页页面本体改为最小兼容转发壳，直接命中旧路由时也会替换到统一页管理态
- 当前仍保留 `CUSTOM_COURSE_MANAGE_GRADE` 路由作为兼容入口，待所有入口迁移完成后删除

### 2026-07-03 Task 8 部分完成

- 已删除旧管理页独立 `binding`
- 已将旧管理页 `view` 收敛为最小兼容转发壳，不再承载旧管理 UI
- `app_pages.dart` 中旧管理页路由已不再绑定旧 controller
- 当前仍保留旧路由名本身作为兼容入口，待确认无外部依赖后删除

### 2026-07-03 Task 8 完成

- 已删除 `tag_routes.dart` 中旧管理页路由映射
- 已删除 `app_pages.dart` 中旧管理页 `GetPage`
- 已删除 `app_routes.dart` 中旧管理页路由常量与路径定义
- 已将 `CustomCourseManageGradeController` 的 `breadcrumbRoute` 切换到统一页路由
- 已删除旧管理页兼容 `view` 文件
- 仓库内已无 `CUSTOM_COURSE_MANAGE_GRADE` 和 `CustomCourseManageGradeView` 引用

### 2026-07-03 Task 5 完成

- 已新增 `browse_section.dart`
- 已将学习态三列 `module` 布局迁入 `BrowseSection`
- 已将 `unit` 展开面板和惰性图片加载逻辑迁入 `BrowseSection`
- `official_course_details_level_view.dart` 已收敛为统一页壳层，负责模式切换、空态和底部栏挂载

### 2026-07-03 Task 6 完成

- 已新增 `course_module_card_shell.dart`
- 已新增 `browse_module_card.dart` 并替换学习态 `module` 卡片实现
- 已新增 `manage_module_card.dart` 并替换管理态卡片实现
- 学习态与管理态已共用同一套卡片外壳、圆角、边框、分隔线和基础布局
- 学习态与管理态卡片上半部分已进一步共用：左侧封面、右侧标题、标签和详情文案统一由共享内容组件渲染
- 已删除旧的 `custom_course_manage_grade_cell.dart`

### 2026-07-03 Task 4 收尾

- 已新增 `storage_workspace.dart`
- 已将管理态右侧暂存区拖拽、空态、封面 tile 和底部操作按钮从 `ManageSection` 中拆出
- `manage_section.dart` 已进一步收敛为左右两块区域的组装层

### 2026-07-03 交互优化

- 完成管理时改为“先退出到学习态，再静默刷新数据”，避免内容区先空白再 loading 的硬切
- 管理态左侧工作区改为全高滚动视口，底部栏避让改到内部内容 padding，不再直接压缩整块区域高度
- 管理态卡片长按拖拽时长缩短，并将左侧卡片与暂存区卡片的可直接拖动入口统一改为封面左上角的 `拖动排序` 标签
- Level 删除按钮增加禁用态：只要暂存区有内容，左侧所有 Level 的删除都置灰；暂存区清空后，Level 可直接删除
- 修复从暂存区拖回左侧时的空指针：拖拽来源状态在请求前做快照，避免 `await` 后被拖拽结束回调清空
- 修复 Home 进入课程链路的面包屑断链：由 `Level` 页自己承接后续详情跳转，Home 不再在 `Level` 返回后补开详情页，避免课程列表页 breadcrumb 先被移除
- 收敛统一页 breadcrumb：管理区 controller 不再单独注册面包屑，统一由 `Level` 页维护当前项；学习态显示动态课程名，管理态显示 `编辑教材`
- 优化新增年级弹窗：改为调用 `level/tier/list` 数据驱动渲染，弹窗宽度调整为 `1200`，支持按“适用学段”筛选并按 `CEFR` 分组选择年级卡片，卡片内展示 `Grade/Cambridge` 对应信息和 `Level` 标记

## 实施过程中更新约定

- 每开始一个代码阶段，先更新对应 `Task` 的状态。
- 实现中如果方案和实际代码结构有偏差，优先更新本文档再继续改代码。
- 若出现新的入口、状态或难点，在“风险与关注点”或“变更记录”中追加记录。
