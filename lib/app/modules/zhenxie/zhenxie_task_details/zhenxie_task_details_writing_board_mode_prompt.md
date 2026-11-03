# zhenxie_task_details 写作板单宏模式重构提示词

## 任务背景

当前 `zhenxie_task_details` 模块为了描述写作板状态，分别维护了多套含义相近的状态：

- 路由传入的 `contentSourceMacro / editPolicyMacro`
- 当前页面运行中的 `contentSourceMacro / editPolicyMacro`
- 范文查看前的返回态 `viewSampleReturnContentSourceMacro / viewSampleReturnEditPolicyMacro`

与此同时，`writing_board_data.dart` 里也存在两套底层宏：

- `WritingBoardContentSourceMacro`
- `WritingBoardEditPolicyMacro`

这会带来几个问题：

1. 同一类状态被拆成多份字段，维护成本高。
2. 模式切换时需要手动同步多处状态，容易遗漏。
3. “批改查看范文”这类业务态，已经不是简单的“内容来源 + 编辑策略”组合，继续拆成两个宏会让状态语义变绕。
4. `viewSampleReturn...` 这种“补丁式旧模式回退状态”说明当前建模已经不够贴近业务。

## 本次改造目标

本次要做的不是继续补丁现有状态，而是把写作板状态彻底收敛成一个统一的“写作板模式宏”。

目标是：

1. 废弃当前通过 `contentSourceMacro + editPolicyMacro` 表达页面写作板状态的方式。
2. 废弃为“从范文返回原模式”单独维护的旧模式宏。
3. 新增一个统一的写作板模式宏，直接表达页面真实业务态。
4. 新宏要能完全替代当前 `writing_board_data.dart` 中两套底层宏的职责。
5. 所有写作板、按钮、tab、范文切换、批改切换逻辑，统一基于这个单一宏判断。

## 核心结论

这次改造后，页面和写作板不再维护：

- `WritingBoardContentSourceMacro`
- `WritingBoardEditPolicyMacro`
- `routeContentSourceMacro`
- `routeEditPolicyMacro`
- `viewSampleReturnContentSourceMacro`
- `viewSampleReturnEditPolicyMacro`

统一只保留一个新的写作板模式宏。

## 新宏设计要求

新宏必须是“带稳定字符串值”的宏对象，而不是只靠 Dart 原生枚举名推导。

原因：

1. 页面路由参数需要直接传字符串。
2. `Get.arguments` 读取后需要通过稳定字符串反查模式。
3. 后续如果有持久化、日志、埋点、调试输出，也需要稳定值。

要求参考现有宏对象的写法，至少具备：

- `value`
- 私有构造
- 固定常量实例
- `values`
- `fromValue(String? value)`

不要使用只能在本地代码里判断、无法稳定承接路由字符串的纯枚举方案。

## 新宏建议命名

建议命名为：

- `WritingBoardModeEnum`

如果最终确认只服务当前详情模块，也可以评估更贴近业务的命名，但默认优先统一放在写作板领域模型中，避免后续再次拆分。

## 新宏必须支持的模式

至少包含以下 6 个稳定模式：

1. `task`
   - 任务模式
   - 默认写作态

2. `exemplar`
   - 范文模式
   - 直接进入的范文查看态

3. `task_exemplar`
   - 任务查看范文模式
   - 从任务态点击“查看范文”后的独立模式

4. `exemplar_edit`
   - 编辑范文模式
   - 管理端范文编辑态

5. `correction`
   - 批改模式
   - 查看批改记录正文

6. `correction_exemplar`
   - 批改查看范文模式
   - 从批改态进入范文查看后的独立模式

注意：

- `correction_exemplar` 必须是显式独立态，不能再通过“先进入范文，再维护一个旧模式返回态”来间接表达。
- “回到批改”行为必须直接由 `correction_exemplar -> correction` 这条显式模式切换完成。

## 关键语义约束

### 1. 模式是唯一状态源

后续页面里和写作板有关的状态判断，都必须从这个模式宏派生。

不要继续并存第二套主状态。

### 2. 不再维护旧模式返回宏

既然已经有 `correction_exemplar`，就不允许再保留：

- `viewSampleReturnContentSourceMacro`
- `viewSampleReturnEditPolicyMacro`

这种“记住旧模式以便回退”的补丁逻辑。

### 3. 不再维护底层两套宏

既然新宏已经完全能够决定写作板状态，就不再保留：

- `WritingBoardContentSourceMacro`
- `WritingBoardEditPolicyMacro`

作为写作板主状态或辅助主状态。

如果某些极底层方法仍需要“是否可编辑”“是否读范文内容”这类判断，应当直接从新宏推导，而不是先还原成旧双宏。

### 4. 路由入参也改为新宏

当前页面路由参数中的状态表达，也要切到新宏的 `value`。

路由读入后，通过 `WritingBoardModeEnum.fromValue()` 解析。

## 需要统一替换的判断方式

以下这类判断都需要统一改造为基于新宏：

1. 当前是否是任务写作态
2. 当前是否是范文查看态
3. 当前是否是范文编辑态
4. 当前是否是批改态
5. 当前是否是批改查看范文态
6. 当前是否应该展示任务详情数据
7. 当前是否应该展示范文详情数据
8. 当前写作板是否可编辑
9. 当前是否显示知识点锚点
10. 当前蓝图区域是否允许范文联动高亮
11. “查看范文 / 继续写作 / 回到批改”按钮文案
12. “查看范文”点击后的目标模式
13. “继续重写”点击后的目标模式
14. 批改记录切换时是否立即切模式

## 推荐模式语义映射

请按下面语义理解 6 个模式：

### `task`

- 页面展示任务详情
- 写作板展示任务内容
- 写作板遵循任务作答规则
- 可进行暂存 / 提交

### `exemplar`

- 页面展示范文详情
- 写作板展示范文内容
- 写作板只读
- 属于直接路由进入的“纯范文详情”语义
- 默认不承担“返回任务”的上下文表达

### `task_exemplar`

- 页面展示范文详情
- 写作板展示范文内容
- 写作板只读
- 当前来源语义仍然属于“任务上下文”
- “查看范文”按钮应表现为“继续写作”
- 点击返回后必须直接回到 `task`

### `exemplar_edit`

- 页面展示范文详情
- 写作板展示范文内容
- 写作板可编辑
- 仅管理端进入

### `correction`

- 页面展示任务详情或批改关联详情
- 写作板展示批改记录正文
- 写作板只读
- 显示批改相关按钮

### `correction_exemplar`

- 页面展示范文详情
- 写作板展示范文内容
- 写作板只读
- 当前来源语义仍然属于“批改上下文”
- “查看范文”按钮应表现为“回到批改”
- 点击返回后必须直接回到 `correction`

## 改造范围

重点关注以下文件，但不限于此：

- `lib/common/widgets/zhenxie_widgets/writing_boards/model/writing_board_data.dart`
- `lib/app/modules/zhenxie/zhenxie_task_details/controllers/zhenxie_task_details_controller.dart`
- `lib/app/modules/zhenxie/zhenxie_task_details/controllers/zhenxie_task_details_board_controller.dart`
- `lib/app/modules/zhenxie/zhenxie_task_details/controllers/zhenxie_task_details_exemplar_controller.dart`
- `lib/app/modules/zhenxie/zhenxie_task_details/views/zhenxie_task_details_view.dart`
- `lib/app/modules/zhenxie/zhenxie_task_details/views/zhenxie_task_blueprint_widget.dart`

如果写作板公共组件中也存在旧宏判断，同样需要跟着统一迁移。

## 改造原则

1. 只做这次单宏模式重构，不做无关整理。
2. 旧双宏相关代码要么彻底迁移，要么彻底删除，不要保留一半新一半旧。
3. 所有新增核心状态、模式切换方法、判断方法都必须补齐注释。
4. 不要为了兼容旧逻辑再造一层“模式转双宏”的中转仓库。
5. 能直接基于新宏判断的地方，就直接判断，不要额外维护一次性布尔缓存。
6. 代码排布、命名、注释风格要严格贴合当前模块现状。

## 推荐实施顺序

1. 先定义新的 `WritingBoardModeMacro`
2. 替换路由入参解析
3. 替换主控制器当前模式状态
4. 删除范文控制器中的旧模式返回宏
5. 重写查看范文 / 回到批改 / 继续写作切换链路
6. 重写批改记录切换链路
7. 替换写作板数据模型中的旧双宏字段
8. 替换 board controller 内全部旧双宏判断
9. 替换 View 层全部旧双宏和旧返回态判断
10. 清理所有废弃字段、方法、判断分支

## 验收标准

改造完成后必须满足：

1. 写作板状态只由一个宏控制。
2. 路由参数可以直接传新宏的字符串 `value`。
3. 不再存在旧的 `contentSourceMacro / editPolicyMacro` 主状态。
4. 不再存在 `viewSampleReturn...` 旧模式回退字段。
5. `批改 -> 查看范文 -> 回到批改` 全链路只基于显式模式切换完成。
6. `批改 -> 查看范文 -> 切换批改记录 -> 回到批改` 仍然可以正确回到最新选中的批改记录。
7. `任务 -> 查看范文 -> 继续写作` 可以正确回到任务模式。
8. 管理端 `编辑范文模式` 正常工作。
9. 旧双宏相关废弃代码已被清理干净。
10. 代码通过格式化和静态检查。

## 输出要求

最终输出代码时，请明确说明：

1. 新增的统一写作板模式宏定义位置
2. 删除了哪些旧宏和旧字段
3. 查看范文 / 回到批改 / 继续写作的切换关系
4. 哪些文件完成了核心判断替换
