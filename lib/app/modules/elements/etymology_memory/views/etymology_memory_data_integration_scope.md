# 词源记忆数据接入范围说明

## 背景

当前 `Routes.ETYMOLOGY_MEMORY` 页面 UI 已经存在，但仍是静态 demo 状态，尚未接入真实数据。

本次准备接入的新接口：

`GET /languages/content/card/en/content/etymology/detail?contentType=EN_PHRASE&contentId=111709&semanticId=763456`

参考返回结构：

- `/Users/guojianbo/code/langwise/xxx3.json`

---

## 当前现状

### 1. 页面仍是静态内容

当前页面文件：

- `lib/app/modules/elements/etymology_memory/views/etymology_memory_view.dart`
- `lib/app/modules/elements/etymology_memory/controllers/etymology_memory_controller.dart`

当前存在的问题：

1. `controller` 没有接任何入参，也没有请求逻辑
2. 页面门头文案是写死的
3. 画布组件内容是写死的 demo 数据
4. 没有根据 `contentType / contentId / semanticId` 定位当前树和当前义项

### 2. 画布组件仍是硬编码结构

相关文件：

- `lib/app/modules/elements/common/etymology_canvas_widgets/etymology_canvas_widget.dart`
- `lib/app/modules/elements/common/etymology_canvas_widgets/etymology_canvas_text_card_widget.dart`
- `lib/app/modules/elements/common/etymology_canvas_widgets/etymology_canvas_card_widget.dart`

当前问题：

1. root / text node / card node 的数量都是固定写死的
2. 连线关系 `_connections` 是固定写死的
3. 节点文案、义项卡内容、图片、词性都是写死的
4. 不能根据接口里的 `trees[].nodes[]` 动态生成树

### 3. 入口参数还没传

当前单词详情和短语详情跳转到词源记忆页时，只是裸跳：

- 没有传 `contentType`
- 没有传 `contentId`
- 没有传 `semanticId`

这会导致词源记忆页即使接了接口，也无法知道当前应该展示哪一个词条、哪一个义项。

---

## 新接口已经提供的能力

从 `xxx3.json` 来看，接口数据已经足够驱动页面：

### 页级信息

- `contentType`
- `contentId`
- `semanticId`
- `content`
- `contentKey`
- `activeTreeUid`
- `activeNodeId`
- `unassignedCount`
- `semanticItems`

### 树级信息

- `trees[].uid`
- `trees[].title`
- `trees[].descriptions`
- `trees[].order`
- `trees[].nodes`

### 节点信息

- `nodeId`
- `label`
- `bubble`
- `forkNote`
- `bindings`

### 叶子义项卡信息

- `senseCards[]` 当前已与词典列表页 `ElementsCardEntityDatas` 结构对齐
- 前端应直接按词典卡模型解析并复用现有词典卡片组件展示

结论：这次的主要问题不是接口不够，而是 Flutter 页面仍未数据驱动化。

---

## 本次建议实现范围

本次先做“可用版”的数据接入，范围控制如下。

### 1. 接入数据请求

需要新增：

1. 词源记忆专属实体
2. 词源记忆详情请求方法
3. `EtymologyMemoryController` 的页面入参读取与请求逻辑

页面入参至少包含：

- `contentType`
- `contentId`
- `semanticId`

### 2. 页面门头改成数据驱动

将当前写死内容改为：

1. 第一行：`content`
2. 第二行：当前树 `title` 的中文
3. 第三行：当前树 `descriptions` 的中文

### 3. 画布改成单棵树数据驱动

本次先基于当前选中的 `activeTreeUid` 渲染一棵树：

1. 根据 `nodes[]` 和 `nodeId` 动态推导层级关系
2. 中间节点展示 `label / bubble / forkNote`
3. 叶子节点展示 `senseCards`
4. 连线关系不再硬编码，改为根据父子关系动态生成

### 5. 从词条页正确传参进入

单词详情页、短语详情页跳词源记忆时，要改为带参数进入：

- `contentType`
- `contentId`
- `semanticId`

---

## 本次暂不做

为了控制改动范围，本次先不做以下内容：

1. 复杂动画与节点交互
2. 管理端和用户端的双模式差异
3. 额外的未入树义项详细面板
4. 更复杂的义项高亮联动

---

## 义项切换与树切换的边界约束

底部义项切换条和多棵树切换 UI，本质上都是在做“当前树切换”：

1. 底部义项切换条是外层入口
2. 多棵树切换 UI 是内层入口

两者目标一致，只是操作入口层级不同。

因此这一组功能建议采用 **同进同退** 的边界：

### 方案 A：这一轮一起做

如果要做切换能力，本轮应同时包含：

1. 多棵树切换 UI
2. 底部义项切换条
3. 义项切换后自动定位到对应树
4. 树切换后同步当前展示义项状态

### 方案 B：这一轮都先不做

如果本轮目标只是把词源记忆页先变成“可用的数据驱动页”，那就两者都先不做，只保留：

1. 按传入的 `semanticId` 初始化当前树
2. 首屏只展示当前树
3. 页面内不提供额外切换入口

当前更推荐的实现方式是：

- **底部义项切换条和多棵树切换 UI 要么都做，要么都不做**

避免出现：

1. 只有义项切换，没有树切换
2. 只有树切换，没有义项切换

这种只完成半套切换模型的状态。

---

## 后续待做

在本次“可用版”完成后，后续可继续补：

### 1. 多树切换与义项联动

当 `trees.length > 1` 时：

1. 增加树切换胶囊
2. 增加底部义项切换条
3. 支持按树切换画布内容
4. 保持当前义项与当前树的联动

### 当前这一轮已确认的切换边界

1. 树切换 UI 放在画布内部顶部
2. 当 `trees.length <= 1` 时，树切换 UI 直接隐藏
3. 底部义项切换条直接使用接口里的 `semanticItems`
4. 点击底部义项时，前端自动查找该义项所属树
5. 若义项属于其他树，则自动切树并定位到对应节点
6. 若义项未挂到任何树，前端仅 toast 提示，不额外切树
7. `unassignedCount` 本轮先不接入展示

### 2. 未入树提示

接口已提供：

- `unassignedCount`

后续可以补：

1. 门头弱提示
2. 未入树义项单独展示区

### 3. 节点联动体验

后续可以补：

1. 进入页面后自动定位当前叶子
2. 点击叶子义项卡联动到底部义项条
3. 点击底部义项条自动切树并定位节点

### 4. 管理端 / 用户端差异

后续如有需要，再补：

1. 管理端额外信息
2. 用户端隐藏管理字段
3. 面包屑与页面标题差异化处理

---

## 当前结论

`Routes.ETYMOLOGY_MEMORY` 现在最核心的工作，不是“补几个字段”，而是把整页从静态 demo 改成数据驱动页。

本次建议按以下顺序推进：

1. 新建实体与请求
2. 接 controller 入参和页面数据
3. 改页面门头
4. 改画布为单棵树数据驱动
5. 修改单词详情、短语详情的跳转传参

如果本轮决定把“切树能力”一起做，则在上面基础上继续补：

6. 多棵树切换 UI
7. 底部义项切换条
8. 树与义项的双向联动

这样可以先把词源记忆页做成真正可用的一版，再逐步补多树切换和更细的交互体验。
