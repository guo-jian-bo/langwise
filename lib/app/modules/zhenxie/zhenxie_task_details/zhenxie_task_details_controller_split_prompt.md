# zhenxie_task_details 控制器拆分提示词

## 任务背景

当前页面控制器：

- `lib/app/modules/zhenxie/zhenxie_task_details/controllers/zhenxie_task_details_controller.dart`

把以下几类职责全部堆在了一个控制器里：

1. 页面壳层职责：路由参数、面包屑、tab 切换、返回拦截
2. 任务详情职责：任务详情请求、知识点、草稿、暂存、提交
3. 范文职责：范文详情请求、预加载、查看态、编辑态、保存
4. 写作板公共职责：写作板数据映射、运行时状态、聚焦、选中拍位、高亮、退出前对比基线
5. 后续还要新增批改记录相关职责

目标是把当前大控制器拆开，降低耦合，方便后续继续接入“批改记录”能力。

## 本次改造目标

本次真正要做的是控制器分层和职责拆分，不是做 UI 重写，也不是改接口协议。

目标结构：

1. 保留一个页面主控制器 `ZhenxieTaskDetailsController`
2. 新增任务控制器 `ZhenxieTaskDetailsTaskController`
3. 新增范文控制器 `ZhenxieTaskDetailsExemplarController`
4. 预留批改记录控制器 `ZhenxieTaskDetailsCorrectionController`
5. 新增一个写作板公共控制器或协调层，建议命名为 `ZhenxieTaskDetailsBoardController`

## 关键要求

1. 这次拆分必须是外科手术式改动，只处理当前模块，不做无关重构。
2. 不允许继续把“任务 / 范文 / 批改记录”三类业务逻辑塞回主控制器。
3. 不允许把写作板公共状态分别复制到三个业务控制器中，必须统一收口。
4. 批改记录控制器这次只需要把结构留出来，内部逻辑可以先留空，不要硬写假逻辑。
5. 当前页面已有行为必须尽量保持一致：
   - 任务详情初始化
   - 范文预加载和查看范文切换
   - 范文编辑态切换与保存占位
   - 草稿暂存
   - 正式提交
   - 返回前未保存提示
   - 蓝图区域高亮联动
6. 不要引入新的全局单例状态，不要为了拆分再造一层业务模型。
7. 注释必须补齐，尤其是控制器核心状态、模式切换、同步时机、生命周期资源释放。

## 推荐文件结构

建议新增以下文件：

- `controllers/zhenxie_task_details_controller.dart`
- `controllers/zhenxie_task_details_task_controller.dart`
- `controllers/zhenxie_task_details_exemplar_controller.dart`
- `controllers/zhenxie_task_details_correction_controller.dart`
- `controllers/zhenxie_task_details_board_controller.dart`

如有必要，也可以新增一个轻量枚举文件，例如：

- `controllers/model/zhenxie_task_details_panel_type.dart`

仅在确实需要时再加，不要为了抽象而抽象。

## 各控制器职责边界

### 1. 主控制器 `ZhenxieTaskDetailsController`

主控制器只负责页面编排，不承载任务、范文、批改记录的内部业务细节。

建议保留在主控制器中的内容：

- `tagText`
- 路由参数解析
- `isManagement`
- `taskUid`
- `compositionUid`
- 初始进入模式解析
- 页面级 tab 状态
- 当前右侧面板类型切换
- 面包屑初始化
- 返回拦截入口
- 按钮区点击分发
- 各子控制器初始化编排

主控制器不应再直接持有：

- `_taskDetailsData`
- `_taskKnowledgePointsList`
- `_exemplarDetailsData`
- `_exemplarKnowledgePointsList`
- 草稿态 runtime 快照
- 范文编辑态 runtime 快照
- 媒体上传和提交逻辑
- 范文保存回写逻辑

### 2. 任务控制器 `ZhenxieTaskDetailsTaskController`

任务控制器只负责任务域逻辑。

建议放入任务控制器的内容：

- 任务详情数据
- 任务知识点数据
- 获取任务详情接口
- 草稿态快照
- 任务退出对比基线
- 暂存逻辑
- 提交逻辑
- 提交前校验
- 媒体上传逻辑
- 提交请求体组装
- 任务态切换时与 board 控制器的同步

### 3. 范文控制器 `ZhenxieTaskDetailsExemplarController`

范文控制器只负责范文域逻辑。

建议放入范文控制器的内容：

- 范文详情数据
- 范文知识点数据
- 获取范文详情接口
- 范文预加载逻辑
- 范文编辑态快照
- 范文退出对比基线
- 查看范文 / 继续写作切换链路中的范文部分
- 管理端范文编辑保存
- 范文编辑结果回写详情实体

### 4. 批改记录控制器 `ZhenxieTaskDetailsCorrectionController`

这个控制器这次先只留结构，不实现完整逻辑。

建议先保留这些最小骨架：

- 批改记录列表状态
- 当前选中记录 id 或 index
- 记录详情占位状态
- 空的初始化方法
- 空的查询方法占位
- 空的切换查看方法占位

注意：

- 这次不要硬接接口
- 不要写假数据驱动正式 UI
- 不要让主流程依赖它
- 只保证未来可平滑接入

### 5. 写作板控制器 `ZhenxieTaskDetailsBoardController`

这是这次拆分里最关键的一层，用来收口公共写作板状态。

建议放入 board 控制器的内容：

- `writingBoardData`
- `writingBoardRuntimeState`
- `writingBoardSubmitData`
- `selectBeatNid`
- `highlightedFrameSection`
- `writingBoardControllers`
- 焦点监听绑定与释放
- 高亮计时器
- 写作板重建方法
- runtimeState 同步到 data 的方法
- 选中拍位和输入变化同步方法
- 写作板提交快照构建入口

board 控制器不直接负责：

- 请求任务详情
- 请求范文详情
- 正式提交接口
- 范文保存接口

它只消费“当前显示详情数据 + 当前模式 + 当前业务快照”，并产出统一的写作板状态。

## 推荐依赖关系

推荐依赖方向如下：

1. 主控制器持有 task / exemplar / correction / board 四个子控制器
2. task 和 exemplar 可以调用 board 的同步方法
3. board 不反向依赖具体业务控制器内部实现
4. correction 后续如果需要只读写作板，可调用 board 的只读重建能力，但不要直接复用任务草稿态和范文编辑态快照

不要形成以下耦合：

- task 直接依赖 exemplar 内部状态
- exemplar 直接依赖 task 内部私有字段
- correction 直接依赖 task 草稿态快照
- 主控制器重新变成所有字段的总仓库

## 推荐迁移顺序

请严格按下面顺序迁移，避免边拆边乱：

### 第一步：先抽 board 控制器

先把写作板公共状态和方法迁出去，包括：

- 写作板 data / runtimeState / submitData
- `selectBeatNid`
- 高亮状态
- 输入变化同步
- focus node 绑定和释放
- 写作板重建逻辑

先把最重的公共状态抽走，主控制器体积会明显下降。

### 第二步：抽任务控制器

迁出任务侧逻辑，包括：

- `getTaskDetailsData`
- 任务知识点查询
- 草稿暂存
- 提交
- 校验
- 上传
- 提交基线更新

### 第三步：抽范文控制器

迁出范文侧逻辑，包括：

- `getExemplarDetailsData`
- 范文预加载
- 范文编辑态
- 范文保存
- 范文回写
- 范文基线更新

### 第四步：收口主控制器

让主控制器只剩页面编排能力：

- 初始化
- 当前模式切换
- tab 切换
- 返回拦截
- 底部按钮点击分发

### 第五步：补批改记录控制器骨架

这一步只建结构，不实现具体记录详情逻辑。

## 模式建议

建议把“当前看的是哪种内容”和“当前是否可编辑”继续作为页面级模式保留，但不要把各模式对应的数据缓存继续放在主控制器里。

可以保留类似语义：

- 当前内容来源：任务 / 范文 / 批改记录
- 当前编辑策略：只读 / 可编辑 / 任务作答

但是具体数据来源应改为：

- 任务模式时从 task controller 取数据
- 范文模式时从 exemplar controller 取数据
- 批改记录模式时从 correction controller 取数据

## View 层配合要求

View 层不要继续默认所有数据都从主控制器读取。

推荐拆法：

1. 页面壳层仍然读主控制器
2. 写作板区域读 board 控制器
3. 资料 / 蓝图区域读当前业务控制器暴露的数据
4. 按钮区由主控制器决定显隐和分发，但实际执行落到 task / exemplar / correction 对应控制器

## 兼容要求

拆分后必须保证以下行为不回归：

1. 初次进入任务详情时能正常加载任务数据
2. 任务态默认拍位选择逻辑保持一致
3. 查看范文时能预加载范文数据并切换到范文只读态
4. 范文编辑态和保存占位行为保持一致
5. 暂存和提交仍然可用
6. 返回时未保存提示仍然准确
7. 蓝图锁定、范文锁定逻辑不变
8. 高亮联动与焦点切换不丢

## 禁止事项

1. 不要把这次改造做成一次“大一统重写”
2. 不要改动无关 UI 样式
3. 不要修改接口字段语义
4. 不要引入嵌套三元表达式
5. 不要增加为了判空而存在的一次性中转变量
6. 不要把简单状态判断抽成一堆极短 getter
7. 不要让 correction controller 现在就承担真实业务逻辑

## 验收标准

完成拆分后，至少应满足：

1. 主控制器只负责页面编排，不再承载三类业务细节
2. task / exemplar / correction / board 四类职责边界清晰
3. 后续接入批改记录时，不需要再回头重拆任务和范文逻辑
4. 现有页面行为保持稳定
5. 代码结构符合当前项目的 GetX 模块风格

## 补充说明

“批改记录详情后面会有其他逻辑”这一点已经明确，所以本次：

- 只预留 `ZhenxieTaskDetailsCorrectionController`
- 可以有空方法、空状态、空注释
- 不需要实现真实详情逻辑
- 不需要现在接入完整 UI

本提示词的核心目标，是先把 `zhenxie_task_details` 的控制器结构拆干净，为下一步接入批改记录留出明确边界。
