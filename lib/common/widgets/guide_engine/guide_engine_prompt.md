# Guide Engine 实现提示词

你现在要重构并实现 `lib/common/widgets/guide_engine` 这一套引导系统。

这次实现不要被当前旧代码结构绑死，也不要简单沿用“当前步骤自动推进”的旧思路。请以“前端引导运行时模型”为核心进行设计，在保留现有目标注册层、展示层、仓库层职责边界的前提下，重构控制器与数据模型。

## 一、目标

实现一套更自由、更稳定的引导流程，满足以下要求：

- 前端不直接依赖服务端当前的一维步骤结构
- 服务端返回的是“页面任务 + 多个分组 + 每组多个 guide”
- 前端运行时要支持多个 `pageCode` 的引导进度缓存
- `widgetId` 在全局唯一
- 页面侧只负责：
  - 页面初始化时加载步骤列表
  - 按需在页面根部使用 `GuidePageBoxWidget(pageCode: ..., child: ...)` 包裹页面，主要用于在引导运行中禁用页面滚动，可以选择不包裹
  - 页面数据和视图真正 ready 后调用 `start(pageCode)`
  - 业务成功后按需调用 `completeGuide(pageCode, widgetId)`、`continueGuide(pageCode, widgetId)` 或 `completeAndContinue(pageCode, widgetId)`
- 控制器负责：
  - 按 `pageCode` 管理各页面的引导进度
  - 根据 `widgetId` 查找目标
  - 自动滚动到目标
  - 展示引导
  - 在分组结束时静默上报
  - 提供页面运行态判断能力，供页面容器决定是否锁定当前页面

## 二、服务端返回结构

当前已知服务端页面任务结构类似：

```json
{
  "code": "页面code",
  "guideGroups": [
    {
      "stepCode": "steps1",
      "order": 1,
      "guides": [
        {
          "widgetId": "widgetId A",
          "title": "编辑信息",
          "content": "xxxxxx",
          "handle": 0,
          "showCloseButton": true
        },
        {
          "widgetId": "widgetId B",
          "title": "编辑头像",
          "content": "xxxxxx",
          "handle": 1
        }
      ]
    },
    {
      "stepCode": "steps2",
      "order": 2,
      "guides": [
        {
          "widgetId": "title",
          "title": "修改用户信息",
          "content": "xxxxxx",
          "handle": 1
        }
      ]
    }
  ]
}
```

注意：

- 前端不能假设服务端未来只会有这些字段
- 模型层要保留扩展能力
- 但当前已知字段至少包括：
  - `code`
  - `guideGroups`
  - `stepCode`
  - `order`
  - `guides`
  - `widgetId`
  - `title`
  - `content`
  - `handle`
  - `showCloseButton`

## 三、前端运行时模型

请把服务端模型和前端运行时模型区分开。

推荐前端运行时使用如下语义：

- `GuidePageTask`
  - 表示一个页面对应的一整套引导任务
  - 对应服务端的 `code`
  - 包含：
    - `code`
    - `guideGroups`
- `GuideTaskGroup`
  - 表示页面任务中的一个引导分组
  - 对应服务端的一个 `stepCode`
  - 包含：
    - `stepCode`
    - `order`
    - `guides`
- `GuideTaskGuide`
  - 表示分组中的一个小步骤
  - 包含：
    - `widgetId`
    - `title`
    - `content`
    - `handle`
    - `showCloseButton`

同时维护运行时状态：

- `pageCode -> 页面任务进度`
- 每个 `pageCode` 自己的页面任务
- 每个 `pageCode` 当前进行到的分组位置
- 每个 `pageCode` 当前进行到的 guide 位置
- 当前正在展示的 `widgetId`
- 当前是否正在显示引导
- 页面容器是否应基于 `pageCode` 进入锁定态

约束：

- `widgetId` 全局唯一
- 中断后不保留断点，下次重新进入页面后从头开始
- 暂时不考虑同一个 `pageCode` 多实例并存的情况

## 四、控制器必须提供的 5 个方法

控制器最终对业务层暴露的方法必须至少包括：

1. `start(String pageCode)`
2. `completeGuide(String pageCode, String widgetId)`
3. `continueGuide(String pageCode, String widgetId)`
4. `completeAndContinue(String pageCode, String widgetId)`
5. `stop()`

### 1. `start(String pageCode)`

职责：

- 从该 `pageCode` 当前保存的进度位置开始寻找可以展示的 guide
- 页面任务的执行顺序必须是：
  - 先按 `guideGroups.order` 顺序执行分组
  - 再按每个分组中的 `guides` 顺序执行步骤
- 每找到一个候选 `widgetId`，都要：
  - 从注册表中查找对应 `GlobalKey`
  - 判断目标是否存在
  - 如果存在，先 `Scrollable.ensureVisible`
  - 再展示引导浮层
- 如果当前分组内某个步骤对应目标不存在，则继续找当前分组的后续步骤
- 如果当前分组已经没有更多可执行步骤，则认为当前分组执行完成：
  - 静默上报当前分组 `stepCode`
  - 把该 `pageCode` 的进度推进到下一分组
  - 再继续尝试下一分组
- 如果所有分组都执行完成，则直接 `stop()`

### 2. `completeGuide(String pageCode, String widgetId)`

职责：

- 标记该 `pageCode` 当前进度中，对应 `widgetId` 的 guide 已完成
- 不自动继续下一步
- 如果该 `widgetId` 已经是当前分组最后一步：
  - 静默上报整个分组
  - 上报参数按分组维度走，即当前分组的 `stepCode`
  - 将该 `pageCode` 的进度推进到下一分组
- 如果该 `widgetId` 不是当前分组最后一步：
  - 只把当前进度推进到当前分组中的下一步骤
- 关闭当前浮层，不要等待接口完成后才关闭
- 这个方法可以被视为当前页面的“显式暂停点”，常见于跳转前先调用

### 3. `continueGuide(String pageCode, String widgetId)`

职责：

- 以该 `pageCode` 中 `widgetId` 对应步骤为起点
- 从它的后一个 guide 开始向后遍历
- 找到第一个真实存在的目标组件后：
  - 先滚动定位
  - 再继续展示引导
- 如果某一步目标组件不存在，则继续找下一步
- 如果当前分组遍历到了末尾，则说明当前分组已执行完成：
  - 静默上报当前分组 `stepCode`
  - 把该 `pageCode` 的进度推进到下一分组
  - 再尝试下一分组
- 如果该 `pageCode` 的所有分组都已执行完成，则直接 `stop()`
- 这个方法用于页面返回、弹窗关闭、数据刷新完成后的“显式恢复”

### 4. `completeAndContinue(String pageCode, String widgetId)`

职责：

- 先执行 `completeGuide(pageCode, widgetId)`
- 如果该 `pageCode` 仍然还有剩余可执行步骤，再执行 `continueGuide(pageCode, widgetId)`

### 5. `stop()`

职责：

- 立即关闭当前引导浮层
- 清理当前展示态
- 中断本次引导流程
- 不上报
- 下次重新进入页面时，从头开始

## 五、点击目标后的行为

服务端字段 `handle` 表示：

- `0`：点击高亮目标后，不执行业务原始逻辑
- `1`：点击高亮目标后，执行目标绑定的原始业务逻辑

请保留这一层语义，不要让控制器直接知道页面业务细节。

推荐映射为前端枚举，例如：

- `GuideTargetTapAction.nextStep`
- `GuideTargetTapAction.executeTargetLogic`

行为规则：

- 当 `handle = 0`
  - 点击高亮区域后，可以直接走 `completeAndContinue(pageCode, widgetId)` 或等价流程
- 当 `handle = 1`
  - 点击高亮区域后，只执行 widget 绑定的原始逻辑
  - 什么时候 `completeGuide`、什么时候 `continueGuide`，由业务层在合适时机决定
  - 适用于跳页、弹窗、异步请求成功后再继续等场景

## 六、滚动与可见性规则

统一规则如下：

- 只支持已经真实挂载到 widget tree 中的目标
- 如果目标已挂载但在可视区域外，统一使用 `Scrollable.ensureVisible`
- 不支持懒加载列表或虚拟列表中的引导目标
- 如果某个 guide 对应目标根本不存在，则在当前分组内继续向后查找下一个

注意：

- 页面侧会自行保证：
  - 数据加载完成后再调用 `start(pageCode)`
  - 需要跨页或弹窗继续时，在正确时机调用 `continueGuide(pageCode, widgetId)`
- 引导引擎不负责等待页面异步数据完成

## 七、中断规则

如果用户点击关闭按钮：

- 立即调用 `stop()`
- 本次引导正常中断
- 不记录断点
- 不上报
- 下次重新进入页面时，仍然从当前页面任务的第 0 个分组、第 0 个步骤重新开始

## 八、分组与上报规则

分组是必须保留的核心概念。

规则如下：

- 每个 `pageCode` 都可以有自己的页面任务与进度
- `start(pageCode)`、`completeGuide(pageCode, widgetId)`、`continueGuide(pageCode, widgetId)` 都只作用于对应页面的进度
- 每个页面内部必须先按分组 `order` 执行
- 每个分组内部再按 `guides` 顺序执行
- 只有在当前分组最后一步被 `completeGuide(pageCode, widgetId)` 时，才会触发该分组的组级上报
- 当前分组执行完后，要把该页面进度推进到下一分组，方便后续 `start/continueGuide` 继续执行
- 上报时机为静默上报：
  - 不阻塞 UI
  - 不等待上报完成才关闭浮层

## 九、文件职责要求

重构时保持单一职责，不要混写：

- `guide_task_controller.dart`
  - 只负责按 `pageCode` 保存页面进度、继续下一步、停止引导、调用仓库上报
  - 可以对外提供“当前 `pageCode` 是否处于引导运行态”的判断能力
- `guide_task_models.dart`
  - 只负责页面任务、分组、步骤三层结构定义，以及 JSON 映射
- `guide_registry_manage.dart`
  - 只负责 `widgetId -> GlobalKey` 和目标点击回调注册
- `guide_step_widget.dart`
  - 只负责页面目标声明和注册，不负责调度
- `guide_page_box_widget.dart`
  - 只负责按 `pageCode` 监听引导运行态，并在需要时禁用当前页面交互
- `guide_step_overlay.dart`
  - 只负责浮层展示，不负责业务推进
- `guide_task_repository.dart`
  - 只负责拉步骤列表和按 `stepCode` 上报分组完成

## 十、接入方式要求

页面层推荐使用方式：

1. 页面初始化时加载步骤列表
2. 可选地在页面根部使用 `GuidePageBoxWidget(pageCode: ..., child: ...)` 包裹页面，主要用于在引导运行中禁用页面滚动
3. 页面数据和布局真正 ready 后调用 `start(pageCode)`
4. 页面中的目标组件使用 `GuideStepWidget(id: widgetId, ...)` 包裹
5. 若点击高亮后只需纯提示推进，可直接使用 `completeAndContinue(pageCode, widgetId)`
6. 若点击高亮后要执行原始业务逻辑，则在业务成功后手动调用：
   - `completeGuide(pageCode, widgetId)`
   - `continueGuide(pageCode, widgetId)`
   - 或 `completeAndContinue(pageCode, widgetId)`

典型跨页流程：

1. A 页面调用 `start('A')`
2. A 页面当前分组内某一步完成时，调用 `completeGuide('A', widgetIdA)`
3. 跳转到 B 页面
4. B 页面 ready 后调用 `start('B')`
5. B 页面结束后返回 A
6. A 页面数据刷新并 ready 后，再调用 `continueGuide('A', widgetIdA)` 继续原来的剩余步骤

## 十一、实现注意事项

- 不要再以“当前步骤对象”作为业务主入口
- 核心入口统一改为基于 `pageCode + widgetId`
- `continueGuide(pageCode, widgetId)` 必须支持“当前步骤不存在则继续找后续步骤”
- `start(pageCode)` 与 `continueGuide(pageCode, widgetId)` 的查找逻辑应尽量复用，避免重复实现
- 若当前页面没有可展示目标，统一 `stop()`
- 每个 `pageCode` 的进度记录要尽量简单，优先使用“当前分组索引 + 当前 guide 索引”这类轻量状态，不要引入复杂会话栈
- 不要把“分组完成上报”和“整个页面任务完成”混为一谈：上报是按分组 `stepCode` 触发的
- 如果未来服务端结构变化，只改模型映射和仓库层，不要破坏控制器对外语义

## 十二、给 AI / 开发者的执行提示词

如果要让 AI 基于本目录继续实现，请直接使用下面这段提示：

```text
请基于 lib/common/widgets/guide_engine 重构引导系统，严格遵守以下规则：

1. 前端运行时以“pageCode -> 页面任务 -> 多分组进度”驱动，不再用旧的一维 currentStep 自动推进模型。
2. widgetId 是全局唯一，控制器对外所有核心业务方法都基于 pageCode + widgetId。
3. 控制器必须暴露：
   - start(String pageCode)
   - completeGuide(String pageCode, String widgetId)
   - continueGuide(String pageCode, String widgetId)
   - completeAndContinue(String pageCode, String widgetId)
   - stop()
4. 服务端页面任务结构是：
   - code
   - guideGroups
   - 每个 group 下有 stepCode / order / guides
5. start(pageCode) 从该页面当前保存的进度开始找第一个可展示目标：
   - 目标存在则 ensureVisible 后展示
   - 当前分组中某一步不存在则继续找当前分组后续步骤
   - 当前分组执行完则上报该 group 的 stepCode，并推进到下一分组
   - 所有分组执行完则 stop()
6. continueGuide(pageCode, widgetId) 从当前 widgetId 的后一步开始继续找：
   - 找到目标则展示
   - 找不到则继续向后
   - 当前分组到末尾则上报该 group 的 stepCode，并推进到下一分组
   - 所有分组执行完则 stop()
7. completeGuide(pageCode, widgetId) 只负责完成当前 widget 对应步骤：
   - 不自动继续
   - 若该步骤是当前分组最后一步，则按 stepCode 静默上报并把该页面进度推进到下一分组
8. completeAndContinue(pageCode, widgetId) = completeGuide(pageCode, widgetId) + continueGuide(pageCode, widgetId)
9. 用户点击关闭按钮时调用 stop()：
   - 不上报
   - 不保留断点
   - 下次从头开始
10. handle 字段控制点击高亮目标后是否执行业务原始逻辑：
   - 0 表示不执行原始逻辑
   - 1 表示执行原始逻辑
11. 保持单一职责：
   - controller 只做调度
   - page box widget 只做页面滚动锁定
   - registry 只做注册
   - overlay 只做展示
   - repository 只做数据访问
   - models 只做页面任务、分组、步骤三层结构与映射
12. 页面若需要在引导运行中禁用页面滚动，可在页面根部包 `GuidePageBoxWidget(pageCode: ..., child: ...)`，也可以选择不包裹。
13. `GuidePageBoxWidget` 只根据 `pageCode` 的引导运行态判断是否锁定页面滚动，不负责步骤调度。
14. 引导只支持已挂载的目标组件，不支持懒加载或虚拟列表中的引导目标。
15. 页面层负责在合适时机调用 start(pageCode)/continueGuide(pageCode, widgetId)，不要在引导引擎内部等待业务异步数据完成。
16. 每个 pageCode 的进度要单独保存，支持 A 页面完成后进入 B 页面，再返回 A 页面时继续原有剩余步骤。
17. 如果用户中途关闭引导，则当前页面任务不做任何分组上报，下次重新进入时从第 0 个分组、第 0 个步骤开始。
```
