# 页面实现提示词

## 页面目标

- 完成 `manage_sentence_pyramid_add_group` 页面 UI 与功能。
- 当前阶段只实现“句型金字塔 / pyramid”模式。
- 参考实现：
  - `/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/manage_sentence_blueprint_add_group`
  - `/Users/langwise/Desktop/ns/project/ui_ux/src/pages/zhenxie/sentence/components/AddRealizationSetModal.tsx`
- 本页先遵循“设计先行”，当前只允许补充提示词，不开始写业务代码。

## 强约束

- 只做 `pyramid`，不混入 blueprint / paradigm / pair / fork / grid 的页面实现。
- 页面已有路由和壳子保留，不顺手改无关结构、样式、命名和排版。
- `pyramid` 对应的资产实体仍复用 `PatternBlueprintEntity`，不要新建一套金字塔专属 payload/entity。
- 公共能力优先复用：
  - `manage_sentence_add_widgets.dart`
  - `manage_sentence_add_select_dialog.dart`
  - blueprint 页已有的骨架 helper / slot map widget
- 接口来源统一以文档为准：
  - `/Users/langwise/Library/Containers/com.tencent.WeWorkMac/Data/Documents/Profiles/F6CC4FF318C19B528AB86C263E2B4278/Caches/Files/2026-09/ebdf025c7b44de8f95305560491a80c2/05.pattern-pyramid-realization-set-admin-api.md`
- 注意：`pyramid` 不是复用 `/pattern/...` 具体 endpoint，而是复用同一份 add-set 文档体系下的 `/pyramid/...` 接口组与已有公共实体。
- 代码实现阶段必须补充清晰注释，尤其是：
  - 核心状态变量
  - 基句锁定逻辑
  - 增长槽计算逻辑
  - 提交参数组装逻辑

## 当前页面现状

- 目录已存在：
  - `bindings/manage_sentence_pyramid_add_group_binding.dart`
  - `controllers/manage_sentence_pyramid_add_group_controller.dart`
  - `views/manage_sentence_pyramid_add_group_view.dart`
- 当前 Controller 和 View 仍是占位壳子。
- 路由已注册：
  - `Routes.MANAGE_SENTENCE_PYRAMID_ADD_GROUP`
- 页面注册已接入：
  - `manage_page_registry.dart`
- 蓝图详情页已有 `supportsPyramid` 参数：
  - 后续实现时需要在 `zhenxie_pattern_blueprint_details_controller.dart` 的 `addGroup()` 中根据该参数分流：
    - `supportsPyramid == false` -> `Routes.MANAGE_SENTENCE_BLUEPRINT_ADD_GROUP`
    - `supportsPyramid == true` -> `Routes.MANAGE_SENTENCE_PYRAMID_ADD_GROUP`

## 参考结论

### 1. 和 blueprint 页共用的部分

- 顶部页标题、整体页面骨架、底部按钮区可以直接沿用 blueprint 页的组织方式。
- 句子摘要实体继续复用：
  - `PatternBlueprintSentenceBriefEntity`
- “挑一句 / 手输 uid / 清空句子”这套交互继续复用公共绑句卡片组件。
- 句型骨架展示优先复用 blueprint 页现有的 slot map widget / helper，不重复造一套骨架 UI。
- 详情实体继续复用：
  - `PatternBlueprintEntity`

### 2. 和 blueprint 页不同的核心状态链

- blueprint 是：
  - 先选纳入槽
  - 再点要拧的槽
  - 再决定句数
  - 最后给每个句位绑句
- pyramid 是：
  - 先确定基句 `layer_0`
  - 根据基句实际占用槽，计算哪些可选槽还能作为增长槽
  - 再选择增长槽 `growthSlotKeys`
  - 再给每一层绑定句子
- 因此不能简单复制 blueprint 的 `baseSlotKeys + dialSlotKeys + sentenceCount` 流程。
- 当前交互已确认：
  - 必须先锁定基句
  - 整体交互顺序和状态切换严格对齐 React 参考实现

### 3. React 参考里的 pyramid 语义

- 金字塔页面需要区分：
  - `layer_0`：基句
  - `growthSlotKeys`：向上增长的槽
  - `pyramidBaseKeys`：基句已经占用的槽
  - `pyramidGrowable`：当前还能继续长的可选槽
  - `pyramidLockConflict`：Target 锁定的增长槽已经被基句占用，当前基句不可用
- `shapeLocked` 在 pyramid 下的条件不是 blueprint 那套，而是：
  - 已锁定基句
  - 已选增长槽
  - 没有锁冲突
- pyramid 的格位不是固定句数，而是：
  - `基句 1 个`
  - `每个增长槽对应 1 个层级句位`
- target 锁定、可选增长槽、冲突处理、空态文案等行为都以 React 当前实现为准，不自行发挥。

## 页面功能范围

### 1. 页面入参与初始化

- 页面实现时需从入口接收：
  - `patternBlueprint`
  - `target`
  - `unitId`
  - `presetSentenceId`
- 这里的传参方式优先对齐 blueprint 页，不在页面内部猜上下文。
- 初始化时完成：
  - 面包屑初始化
  - `patternBlueprint / target / unitId / presetSentenceId` 解析
  - 形态锁信息初始化
  - 基句、增长槽、绑定句、错误态清空
  - 若 `presetSentenceId` 有值，默认回填到基句输入框，并按“锁定基句”同一套逻辑完成基句初始化

### 2. 顶部骨架区

- 顶部仍展示句型骨架。
- 当 `target` 带有金字塔形态锁时：
  - 显示“单元形态锁”提示
  - 锁定增长槽来源于 target
  - 用户不能改锁定增长槽
- 未锁定时：
  - 先锁基句
  - 再根据基句可增长的槽，让用户点选要往上长的槽
- 骨架中的状态需要区分：
  - 基句已占用槽
  - 目标增长槽
  - 不可选槽
  - 可点击增长槽

### 3. 基句锁定区

- 需要单独提供“基句 uid”输入与“锁定基句”操作。
- 基句交互已确认为：
  - 先锁基句
  - 再开放增长槽选择和层级绑句区
  - 这一点严格按 React 参考实现，不改成 blueprint 那种先整体选形态
- 锁定基句后：
  - 回显基句句面
  - 计算基句占用槽
  - 自动过滤掉不能再增长的槽
  - 基句句面按当前 `growthSlotKeys` 高亮对应片段
- 如果基句和 target 锁定增长槽冲突：
  - 要有明确提示文案
  - 后续绑句区不能出现
- 如果基句已经占满全部可选槽：
  - 给出“换一句更短的基句才能往上长”的提示

### 4. 增长槽选择区

- 如果是 target 锁定的 pyramid：
  - 增长槽直接由 target 带入
  - 用户只需要锁基句
- 如果不是 target 锁定：
  - 锁完基句后，用户可以在骨架上点选要增长的槽
- 增长槽点击逻辑要考虑依赖关系：
  - 某些增长槽可能依赖前置槽
  - 移除某个槽时，要检查是否被其他已选增长槽依赖
- 这部分逻辑优先下沉到 helper，不要把所有判断硬堆在 controller/view。

### 5. 绑句区

- 绑句区只在以下条件满足后展示：
  - 已锁定基句
  - 已确定增长槽
  - 没有锁冲突
- 句位列表固定由当前状态推导，不允许手动输入句数。
- 格位结构为：
  - `layer_0` -> 基句
  - `layer_1 ~ layer_n` -> 每个增长槽对应一张卡
- 每个增长层句位支持：
  - 挑一句
  - 手输 uid
  - 清空句子
- 当前绑定结果需要展示到 `ManageSentenceAddBingSentenceWidget`。
- 金字塔句面高亮语义严格对齐 React：
  - 基句按 `growthSlotKeys` 高亮
  - 每个层句也按 `growthSlotKeys` 高亮
  - 前提是基句 / 层句都要补齐完整句子结构（至少拿到 `segmentList`）

### 6. 候选句与手输 uid

- “挑一句”优先复用 `ManageSentenceAddSelectDialog`。
- 金字塔接口按文档接入，不复用 pattern 的请求体。
- 和 blueprint 页保持一致：
  - 选中候选句后，要继续补拉句子结构
  - 手输 uid 校验通过后，也要继续补拉句子结构
  - 若锁定基句只拿到轻量句子信息，同样要补拉句子结构
- 候选接口：
  - `POST /en/sentence/pattern/{nid}/sentence/realization/set/pyramid/cell/candidates`
  - 请求体重点字段：
    - `layerIndex`
    - `baseSentenceId`
    - `growthSlotKeys`
    - `boundSentenceIds`
    - `unitId`
- 手输 uid 校验接口：
  - `POST /en/sentence/pattern/{nid}/sentence/realization/set/pyramid/bind/check`
  - 请求体重点字段：
    - `sentenceId`
    - `layerIndex`
    - `baseSentenceId`
    - `growthSlotKeys`
    - `boundSentenceIds`
- `layerIndex == 0` 代表基句层；上层需要按文档传入 `baseSentenceId`。
- 候选与校验的层级语义必须严格按文档，不再套用 blueprint 的 `baseSlotKeys / dialSlotKeys` 结构。

### 7. 校验与提交

- 底部按钮继续复用 `ManageSentenceAddButtonsWidget`。
- 按钮语义继续保持：
  - `补句落库`：至少已绑 1 句
  - `满句落库`：所有格位都已绑满
- 提交前需要做整盘校验。
- 整塔门禁接口：
  - `POST /en/sentence/pattern/{nid}/sentence/realization/set/pyramid/match/check`
  - 请求体重点字段：
    - `growthSlotKeys`
    - `layerSentenceIds`
- 创建接口：
  - `POST /en/sentence/pattern/{nid}/sentence/realization/set/pyramid/create`
  - 请求体重点字段：
    - `baseSentenceId`
    - `growthSlotKeys`
    - `layerSentenceIds`
    - `match_first`
- `layerSentenceIds` 是无序集合，不能按数组下标猜层号；算法会根据每句实际占用定位层级。
- 不能照抄 blueprint 的 `sentenceIds + baseSlotKeys + dialSlotKeys` 模式。

## 推荐控制器状态

- `PatternBlueprintEntity? patternBlueprint`
- `ManageUnitGrammarTargetDetailTargetEntity? target`
- `int? unitId`
- `int? presetSentenceId`
- `ManageSentenceBlueprintAddGroupShapeLockData shapeLockData`
- `RxList<String> growthSlotKeys`
- `RxMap<String, PatternBlueprintSentenceBriefEntity> boundSentenceMap`
- `RxMap<String, String> errorTextMap`
- `TextEditingController pyramidBaseIdController`
- `RxString lockedBaseSentenceIdText`

## 推荐辅助计算

- `bool isShapeLocked()`
  - 基句已锁定
  - 增长槽已确定
  - 无锁冲突
- `List<String> getPyramidBaseSlotKeys()`
  - 读取基句当前占用槽
- `List<String> getPyramidGrowableSlotKeys()`
  - 可继续增长的槽
- `List<ManageSentenceAddBindingCardModel> buildBindingCardList()`
  - 基于 `growthSlotKeys` 动态生成层级卡片
- `List<int> get activeBoundSentenceIds`
  - 候选过滤用

## View 组织建议

- `build` 放最上面。
- 至少拆出以下区域方法：
  - `_buildHeaderWidget`
  - `_buildSlotWidget`
  - `_buildBaseSentenceWidget`
  - `_buildBindingListWidget`
  - `_buildShapeLockHintWidget`
- 不要把复杂状态判断全部堆在 `build` 里。
- 金字塔特有的提示文案和空态文案建议集中整理，避免散落多处。

## 实现风险点

- blueprint 页当前 helper 主要服务“纳入槽 / 要拧槽”，不一定已经完整覆盖“基句占用槽 / 增长槽依赖”这条链。
- `ManageSentenceAddSelectDialog` 目前可能默认按 blueprint / paradigm / pair / fork 分流，金字塔接入时要补充 `pyramid` 分流，不要硬走 pattern 分支。
- Target 锁定为 `pyramid` 时，增长槽规则与是否允许额外选择，统一严格按 React 当前实现处理。
- 基句区交互已定为“先锁基句”，实现时不要再改成交错式编辑流。

## 验证目标

- 点击“句型金字塔”的“添加一组”能进入本页。
- 页面能展示句型骨架与形态锁提示。
- 输入基句 uid 后能锁定基句并回显句面。
- 锁定基句后能正确计算占用槽与可增长槽。
- 锁冲突时有明确提示，且不允许继续绑句。
- 选择增长槽后，绑句卡片数量与层级正确。
- 每个层级能挑句、手输 uid、清空。
- “补句落库 / 满句落库”按钮状态正确。
- 提交成功后能返回上一页并触发刷新。

## 非本次范围

- 不处理其他 realization set 模式。
- 不做页面视觉重构。
- 不顺手改 blueprint / pair / fork / paradigm 的既有逻辑，除非为复用金字塔能力必须做最小范围补强。
