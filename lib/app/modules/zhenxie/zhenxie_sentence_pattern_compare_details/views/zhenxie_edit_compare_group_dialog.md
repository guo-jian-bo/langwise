# 编辑对照组弹窗逻辑实现提示词

你现在要为 Flutter 页面补齐“编辑对照组”弹窗的逻辑实现，只实现逻辑，不修改任何现有 UI 样式、布局、尺寸、文案排版。目标文件是：

- `lib/app/modules/management/manage_content/manage_zhenxie_console/manage_sentence_pattern_compare_details/views/zhenxie_edit_compare_group_dialog.dart`

相关参考文件：

- React 参考逻辑：`/Users/langwise/Desktop/ns/project/ui_ux/src/pages/zhenxie/sentence/components/ParadigmSetEditModal.tsx`
- 详情控制器：`/Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/manage_content/manage_zhenxie_console/manage_sentence_pattern_compare_details/controllers/zhenxie_sentence_pattern_compare_details_controller.dart`
- 对照实体：`/Users/langwise/Desktop/ns/project/langwise/lib/common/entities/sentence_pattern_compare_entity.dart`

## 一、实现目标

Flutter 版弹窗 UI 已经画好，不要重写 UI。当前还缺的是：

1. 列表数据渲染逻辑
2. 添加对照组逻辑
3. 保存时的本地组装逻辑
4. 请求接口方法占位

这次先不要把大多数请求彻底打通，但要把调用位置、入参组装、后续接入点留好。

明确约束如下：

1. `detailData` 不要在弹窗里隐式查找，直接从外部传入弹窗
2. 本地草稿态由你直接实现
3. 初始化已有对照组时，只使用 `sentenceRealizationSetList`
4. 绑定句子 ID 子弹窗的动态化由你直接实现
5. 添加 / 删除 / 本地映射逻辑由你直接实现
6. 保存先保留为空方法，不真正发请求
7. 候选池获取方法先写成空方法，不接真实数据源
8. 大多数请求先留空方法，但 AI 创建接口信息已经明确，提示词里要保留准确接口说明，方便下一步直接接入

## 二、先理解 React 参考实现的真实逻辑

React 版核心不是直接渲染后端原始数据，而是先把后端数据转换成“本地草稿列表 `sets`”，然后整个列表都按这个本地草稿状态来渲染。

### 1. 初始化逻辑

打开弹窗时：

1. 取 `sentenceRealizationSetList`
2. 按 `order` 倒序排列，保证“上方组展示优先”
3. 把每个 set 转成一个本地草稿对象：
   - 每个草稿组有唯一 `key`
   - 每个草稿组内部维护 `bindings: Map<valueNid, sentenceId?>`
4. 如果后端一个组都没有，就默认补一行空白草稿组

也就是说，React 中真正渲染列表的不是接口原始数组，而是本地 `sets`

### 2. 列表渲染逻辑

React 中 `sets.map((set, setIndex) => ...)` 这一层表示：

1. 外层循环：渲染每一个“对照组卡片”
2. 内层循环：对每个对照组，再遍历 `paradigm.members`
3. 每个 member 对应一行选择器

每个组卡片里展示：

- 标题：`对照组 1 / 2 / 3`
- 删除按钮：删除当前组
- 组内每个壳对应一个下拉选择器

每个壳这一行展示的信息：

- 左侧标题：`valueLabel + patternNid`
- 右侧辅助文案：当前选中句子的文本摘要
- 下方选择器：候选句列表

### 3. 选择器变更逻辑

选择某个句子后，只更新当前草稿组里该 `valueNid` 对应的 `sentenceId`，不要影响其他组，不要影响其他 member。

### 4. 添加逻辑

React 版“添加对照组”有 3 个入口：

1. 绑定句子 ID
2. AI 创建
3. 仅新增空白草稿行（本地）

对应逻辑分别是：

#### 4.1 绑定句子 ID

弹出子弹窗，为每个 member 输入一个句子 ID。

校验规则：

- 每个 member 都必须填写
- 必须是正整数

校验通过后，组装：

```json
{
  "paradigm_nid": "detailData.nid",
  "bindings": [
    { "value_nid": "xxx", "sentence_id": 123 }
  ]
}
```

当前阶段先不要真正请求接口，但要把这个 payload 组出来，并把它转换成一个新的本地草稿组插入到列表最前面。

#### 4.2 AI 创建

有两个分支：

- `match_first = true`：先查库再创建
- `match_first = false`：全新创建

当前阶段接口先留空，但要保留两个方法：

- `aiCheckAndCreate()`
- `aiCreate()`

并在方法里完成：

1. 组装请求参数
2. 预留 TODO / 占位注释
3. 后续真正打通接口后，成功时刷新本地列表

注意：`createNew` 分支的 `match_first` 应该是 `false`，不要沿用当前 UI 文件里错误的副标题文案。

#### 4.3 仅新增空白草稿行（本地）

直接新增一个空白组：

- 每个 `valueNid` 初始值都是 `null`
- 追加到列表末尾即可

### 5. 保存逻辑

保存时不要直接提交当前 UI 临时结构，要先把本地草稿列表重新组装成后端需要的 set 结构：

1. 遍历本地草稿组列表
2. 每组按 `memberList` 顺序生成 bindings
3. 如果某一组有任何一个 member 还没选句子，这一组不要进入最终提交结果
4. `order` 按当前列表顺序重新生成，保证越靠上优先级越高

可以参考 React 的思路：

- 第一组 order 最大
- 后面的组依次递减
- 可以继续沿用 `10` 作为步长

## 三、Flutter 当前数据是否满足实现

### 1. 已满足的部分

当前控制器里的：

```dart
final Rx<SentencePatternCompareEntity> detailData = SentencePatternCompareEntity().obs;
```

对于“编辑对照组”逻辑来说，已经满足以下数据需求：

1. `detailData.value.nid`
   - 可作为后续请求主键
2. `detailData.value.memberList`
   - 可作为“壳列表”
   - 每个壳至少能拿到 `valueNid`
   - 也能拿到 `valueLabel`
   - 也能拿到 `realization / realizationInfo`
3. `detailData.value.sentenceRealizationSetList`
   - 可用于初始化已有对照组
4. `binding.sentenceStruct`
   - 可用于已有绑定句子的文本回显

所以：

- “已有组初始化”
- “组内 member 渲染”
- “保存时重新拼装 set”

这三块，`detailData` 是够用的。

### 2. 不完全满足的部分

当前 `detailData` 里并没有直接提供“每个 member 对应的候选句下拉列表”。

React 版这里是用 mock：

- 根据 `member.realization.patternNid`
- 调 `listSentencesForPatternInParadigmFixture(...)`
- 得到候选句池

Flutter 这边如果要把选择器真正跑起来，还缺一份“按 member / patternNid 获取候选句列表”的数据来源。

因此要明确：

1. `detailData` 足够渲染“已有已选值”
2. `detailData` 不足够直接渲染“候选句下拉项”

实现时要预留一个本地候选池结构，例如：

- `Map<String, List<PatternBlueprintSentenceBriefEntity?>> sentenceOptionsMap`

key 推荐使用：

- `valueNid`
  或
- `patternNid`

当前阶段如果接口还没接，可以先让候选列表为空，并提供一个空方法作为统一入口，例如：

```dart
Future<void> loadSentenceCandidatePool() async {}
```

或者按 member 拆成：

```dart
Future<List<PatternBlueprintSentenceBriefEntity?>> fetchSentenceCandidateList({
  required SentencePatternCompareMemberEntity member,
}) async {
  return [];
}
```

但不要伪造演示数据。

## 四、这次 Flutter 逻辑实现的边界

请严格遵守以下边界：

1. 不修改任何现有 UI 样式和布局
2. 不重构成另一套页面结构
3. 只补状态、初始化、映射、添加、删除、保存、请求占位逻辑
4. 不保留写死的演示列表
5. 不使用 mock 假数据冒充真实候选池

## 五、建议实现方式

### 1. 弹窗主组件内部维护本地草稿列表

在 `EditCompareGroupDialogWidget` 的 State 内维护一个本地列表，替代当前写死的：

```dart
itemCount: 3
```

应改为真正的本地草稿数组驱动。

建议新增一个仅用于弹窗编辑态的本地数据模型，例如：

```dart
class CompareGroupDraftItem {
  final String key;
  final Map<String, int?> selectedSentenceIdMap;
}
```

如后续需要回显句子文本，也可以额外存：

```dart
final Map<String, PatternBlueprintSentenceBriefEntity?> selectedSentenceStructMap;
```

### 2. 打开弹窗时初始化本地草稿列表

数据来源不要在弹窗里自己找 controller，请直接从外部把 `detailData` 传进来。

推荐改法：

1. `controller.editCompareGroup(BuildContext context)` 调起弹窗时，直接把 `detailData.value` 传进去
2. `ZhenxieEditCompareGroupDialog.show()` 增加 `SentencePatternCompareEntity detailData` 参数
3. `EditCompareGroupDialogWidget` 增加对应字段并在 State 里使用

不要用 `Get.find()` 或其他隐式方式兜这个数据。

初始化规则：

1. 只读取 `sentenceRealizationSetList`
2. 按 `order` 倒序
3. 转成本地草稿列表
4. 如果一个组都没有，就创建一条空白组

### 3. 列表渲染逻辑

`_buildListWidget()` 必须改成基于本地草稿列表长度渲染。

`_buildItemWidget(int index)` 不要再只吃 index，要能拿到当前草稿组数据。

每个组里再遍历 `detailData.value.memberList` 渲染每个壳的选择器。

每个选择器展示文案优先级：

1. 主标题：`valueLabel.name` 本地语言
2. 次信息：`realizationInfo.pattern.name` 或 `realization.patternNid`
3. 当前已选值：优先显示已选句文本，没有则显示空

### 4. 删除逻辑

点击删除按钮时：

1. 从本地草稿列表移除当前组
2. 如果删除后列表为空，建议立即补回一条空白组，避免整个弹窗没有可编辑区域

### 5. 绑定句子 ID 子弹窗

当前 `showBindSentenceIdDialog()` 是 `Future<void>`，这不利于主弹窗拿回输入结果。

允许你新增一个轻量返回结果模型，例如：

```dart
class ZhenxieEditCompareGroupBindIdResult {
  final Map<String, int> sentenceIdMap;
}
```

然后把子弹窗改成：

```dart
static Future<ZhenxieEditCompareGroupBindIdResult?> showBindSentenceIdDialog(...)
```

子弹窗内部逻辑要求：

1. 根据 `memberList` 动态生成输入框，不能写死两项
2. 每项标题显示当前 member 的壳名称和 pattern 标识
3. 点击“校验并加入草稿”时：
   - 校验所有输入
   - 失败时提示具体哪个壳未填或非法
   - 成功时 `Get.back(result: ...)`

主弹窗拿到结果后：

1. 组装 bind payload
2. 请求逻辑先留空
3. 先把这一组写入本地草稿列表最前面

### 6. AI 创建逻辑

保留以下两个方法：

```dart
Future<void> aiCheckAndCreate() async {}
Future<void> aiCreate() async {}
```

要求：

1. 两个方法都要先校验 `detailData.value.nid`
2. 组装 payload
3. 当前阶段如果主逻辑还没接完，可以先把调用收口到独立请求方法
4. 不要伪造返回数据
5. 可以给出 toast / 注释说明当前状态

已知 AI 创建接口信息如下，后续真正接入时必须按这个定义落：

- 方法：`POST`
- 路径：`/language-console/en/sentence/paradigm/{nid}/sentence/realization/ai/create`
- 其中 `{nid}` 就是句型对照详情里的 `detailData.nid`
- 示例：`/language-console/en/sentence/paradigm/ability_can_vs_be_able_to/sentence/realization/ai/create`

接口说明补充：

- `matchFirst` 很关键，默认 `true`
- `true` 表示先查库 strict match，不够再生成
- 只有传 `false` 时，才是完全跳过语料播种，直接整组生成

因此请求体里请明确保留：

- `matchFirst: true`
- `matchFirst: false`

不要把这个布尔语义写反。

接口返回格式：

```json
{
  "code": 200,
  "data": {
    "status": "started",
    "message": null,
    "error": null,
    "task_id": 523973
  }
}
```

后续真正接入时：

1. 请求方法写在 `lib/common/https/language_console.dart`
2. 风格参考同文件其他静态请求方法
3. 返回结构定义成独立实体，放到 `lib/common/entities` 下
4. 并记得同步到 `entities.dart` 导出

当前这一步如果仍然不想真正接通，可以先在弹窗逻辑里留一个空方法，例如：

```dart
Future<void> requestAiCreate({
  required bool matchFirst,
}) async {}
```

建议 payload：

```json
{
  "paradigm_nid": "detailData.nid",
  "set_count": 1,
  "persist_sets": true,
  "match_first": true
}
```

以及：

```json
{
  "paradigm_nid": "detailData.nid",
  "set_count": 1,
  "persist_sets": true,
  "match_first": false
}
```

### 7. 空白组逻辑

`addBlankRow()` 做的事情很简单：

1. 读取全部 `memberList`
2. 为每个 `valueNid` 创建一个空值
3. 追加一个新的本地草稿组
4. 刷新界面

### 8. 保存逻辑

点击“保存”时：

1. 遍历本地草稿列表
2. 逐组按 `memberList` 组装 bindings
3. 未选完整的组跳过，不提交
4. 重新计算 `order`
5. 最终生成：

```json
[
  {
    "order": 30,
    "bindings": [
      { "valueNid": "...", "sentenceId": 123 }
    ]
  }
]
```

后续请求优先考虑复用现有：

```dart
LanguageConsoleRequest.editSentencePatternCompare(...)
```

但这次先不要强行接通接口。请把“请求参数组装完成”与“真正发请求”拆开。

保存按钮当前先走空方法，例如：

```dart
Future<void> saveCompareGroups() async {}
```

主按钮点击时可以先调用这个空方法，但不要真正请求。

## 六、实现时必须处理的实际问题

### 1. 当前主弹窗列表是写死的

下面这些都必须改成真实数据驱动：

- `itemCount: 3`
- `_buildItemSelectWidget()` 里的写死标题
- 写死的“选项1”

### 2. 当前绑定 ID 子弹窗也是写死两项

这必须改成根据 `memberList` 动态生成输入项。

### 3. 当前弹窗没有数据入参

要补齐主弹窗拿到 `detailData` 的方式，否则没法初始化。这里已经明确：直接传参，不要隐式查 controller。

### 4. 候选句列表可能暂时为空

这不是 bug，但要保证：

1. 已有绑定值仍能回显
2. 没候选数据时不要崩
3. 选择器为空时保持可读的空态
4. 候选池统一走空方法占位，不要散落临时逻辑

## 七、验收标准

完成后要满足：

1. 打开弹窗时，已有对照组能按 `order` 倒序回显
2. 没有已有对照组时，默认显示 1 条空白草稿组
3. 每个组都按 `memberList` 渲染对应壳
4. 删除按钮能删掉指定组
5. “仅新增空白草稿行（本地）”能追加一组空白数据
6. “绑定句子 ID”能动态生成输入框、做校验，并成功插入本地草稿组
7. “AI 创建”两个分支都能正确区分 `match_first`
8. 保存时能把本地草稿列表重新拼成规范的 set 结构，但当前保存请求可以先不发
9. 全程不改 UI，只补逻辑
10. 候选池、绑定句子、保存请求都允许留空，但必须预留清晰调用点
11. AI 创建接口说明已沉淀到提示词中，后续可以直接按说明补网络层和实体

## 八、特别提醒

1. 不要照搬 React 的 UI 结构，只借鉴它的数据流和状态转换逻辑
2. Flutter 这边已有页面和弹窗样式，保持现状
3. 优先做“外科手术式改动”，只补当前缺失逻辑
4. 代码注释要补齐，尤其是：
   - 本地草稿列表存在的原因
   - 初始化映射规则
   - 保存时为什么要重新组装 order / bindings
5. 不要引入演示数据
6. 不要为了简单而写死 member 项

最终请基于以上要求，为 `zhenxie_edit_compare_group_dialog.dart` 实现完整的弹窗逻辑层；其中请求部分除 AI 创建接口说明外，其余都先按空方法占位。
