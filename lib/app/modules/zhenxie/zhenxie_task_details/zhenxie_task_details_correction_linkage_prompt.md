# zhenxie_task_details 批改联动提示词

## 本次目标

完成真写详情页批改模式下的左右联动设计，联动范围只覆盖：

- 左侧稿纸组件入口：`views/zhenxie_task_writing_board_widget.dart`
- 右侧批改区入口：`views/zhenxie_task_details_view.dart`
- 批改控制器：`controllers/zhenxie_task_details_correction_controller.dart`

本次联动的核心要求是：

1. 左侧稿纸入口尽量在 `ZhenxieTaskWritingBoardWidget` 里完成装配。
2. `ReviewBoardBoxWidget` 采用“接收当前选中值 + 暴露选中回调”的通用模式。
3. `CorrectionController` 只保留批改域真正需要的最小联动状态，不接管稿纸内部渲染细节。
4. 这次不顺手重构整个批改架构，只做当前联动闭环。

---

## 当前边界结论

### 1. 左稿纸组件边界

`ReviewBoardBoxWidget` 应继续保持为可复用组件，不要把右栏批改逻辑硬塞进组件内部。

它应该只新增或继续明确承接这类输入输出：

- 当前选中的 marker id
- 点击 marker 时的回调
- 当前需要闪动的 marker / part
- 当前需要聚焦的一组 anchors

也就是说：

- 稿纸组件负责渲染
- 稿纸组件负责把点击事件抛出去
- 稿纸组件不负责维护“当前批改卡片选中了谁”

### 2. `ZhenxieTaskWritingBoardWidget` 边界

左稿纸入口的联动装配，优先在这里完成。

这里负责：

- 从 `correctionController` 读取当前联动状态
- 透传给 `ReviewBoardBoxWidget`
- 把 `ReviewBoardBoxWidget` 的选中回调回抛给 `correctionController`

不要让 `ReviewBoardBoxWidget` 直接自己去找页面控制器，也不要让它自己维护选中态。

### 3. `CorrectionController` 边界

`CorrectionController` 这次只负责批改域联动状态，不负责稿纸渲染算法。

允许放在这里的内容：

- 当前批改稿纸显示模式 `correctionMode`
- 当前选中的 marker id
- 当前右栏筛选项
- 当前需要闪一下的 marker id
- 当前需要闪一下的 part key
- 当前 focus anchors
- 左右联动的状态切换方法

不要放在这里的内容：

- marker 排序和切片算法
- 稿纸富文本组装细节
- `ReviewBoardBoxWidget` 内部 UI 逻辑
- 写作板通用输入态逻辑

### 4. 主控制器边界

`ZhenxieTaskDetailsController` 继续只做页面编排：

- 页面模式
- 当前 tab
- 当前详情数据
- 当前批改记录切换

不要再把批改联动状态回流到主控制器。

---

## 联动状态设计

建议由 `ZhenxieTaskDetailsCorrectionController` 维护以下最小状态：

### 1. 当前选中的 marker

- `selectedMarkerId`

用途：

- 左稿纸选中描边
- 右栏批注卡片选中态

### 2. 当前批注筛选

- `selectedMarkerFilter`

用途：

- 右栏“全部 / 任务 / 连贯 / 词汇 / 语法 / 亮点”

### 3. 稿纸闪动 marker

- `flashMarkerId`
- 或者带 tick 的 pulse 结构

用途：

- 点右栏卡片后，左稿纸滚到对应 marker 并闪一下

### 4. 稿纸闪动 part

- `flashPartKey`
- 或者带 tick 的 pulse 结构

用途：

- 点“每段点评”后，对应拍位 / 文首 / 文尾闪一下

### 5. focus anchors

- `focusAnchorKey`
- `focusAnchors`

用途：

- 点“要求用上了吗”中的核心词 / 语法点命中项时，高亮稿纸上的全部命中位置

---

## 联动规则

### 1. 左点右

当用户点击左稿纸上的 marker 时：

1. 更新 `selectedMarkerId`
2. 右栏定位到对应卡片
3. 如果当前筛选下该卡片不可见，先恢复到 `all`

注意：

- 左点右时不需要再额外生成新的稿纸闪动
- 这次点击本身已经发生在左稿纸

### 2. 右点左

当用户点击右栏批注卡片时：

1. 如果当前稿纸处于 `correct / upgrade`，但目标 item 是 `suggestion / highlight`，先切回 `annotation`
2. 更新 `selectedMarkerId`
3. 触发 `flashMarkerId`
4. 左稿纸滚到对应 marker 并闪一下

### 3. 逐条走查

当用户点击右栏 `‹ / ›` 时：

1. 基于当前筛选后的可见列表切换上一条 / 下一条
2. 最终仍走“右点左”的统一链路

不要为 `‹ / ›` 单独维护另一套选中逻辑。

### 4. 点每段点评

当用户点击“每段点评”中的某一项时：

1. 触发 `flashPartKey`
2. 左稿纸对应拍位 / `head` / `tail` 闪一下

这条链路不需要改 `selectedMarkerId`。

### 5. 点要求用上了吗

当用户点击核心词 / 语法点命中项时：

1. 如果当前稿纸不在 `annotation`，切回 `annotation`
2. 写入 `focusAnchorKey + focusAnchors`
3. 左稿纸高亮所有命中位置
4. 再次点击同一项时取消 focus

注意：

- 未命中项不做稿纸高亮
- 未命中项仍保持原有跳转行为

---

## 统一数据口径

左右两边的 marker 编号必须共用同一套口径，不能各算各的。

统一规则：

1. 先按 `memberWriting.parts` 的书写顺序
2. 再按 `anchor.start`
3. 再按 `anchor.end`
4. 最后按 `id`

统一结果至少要覆盖：

- marker 排序
- marker 编号
- marker -> anchor 的映射
- partKey -> 段评的映射

如果右栏当前仍在 Widget 内本地排序，后续要收口到 `CorrectionController` 或公共 helper，避免和稿纸产生编号漂移。

---

## View 层实现要求

### 1. `zhenxie_task_writing_board_widget.dart`

在这里把 `ReviewBoardBoxWidget` 的联动参数补齐，推荐直接传：

- `selectedMarkerId`
- `flashMarkerId`
- `flashPartKey`
- `focusAnchors`
- `onSelectMarker`

这个入口层只负责装配，不写批改业务判断。

### 2. `zhenxie_task_details_view.dart`

这里继续只负责决定右栏 body 是：

- `materials`
- `blueprint`
- `correction`

不要在这里承接批改联动细节。

### 3. `zhenxie_task_correction_widget.dart`

右栏内部点击事件都应走 `CorrectionController`：

- 点批注卡片
- 点上一条 / 下一条
- 点筛选 tab
- 点每段点评
- 点核心词命中
- 点语法点命中

不要再让这些状态留在 Widget 本地 `State` 中长期存在。

---

## 生命周期与清理要求

以下场景必须重置批改联动状态：

1. 切换 `writingId`
2. 批改记录切换后详情数据刷新
3. 从 `correction` 切到 `correction_exemplar`
4. 从 `correction_exemplar` 回到 `correction`
5. 当前 review 变化

建议提供统一重置方法，例如：

- `resetReviewInteractionState()`

至少清理：

- `selectedMarkerId`
- `flashMarkerId`
- `flashPartKey`
- `focusAnchorKey`
- `focusAnchors`

`selectedMarkerFilter` 是否回到 `all`，按实际交互决定，但默认建议在切换批改记录时一并重置。

---

## 实现顺序建议

请按下面顺序做，避免边改边乱：

### 第一步：先定状态归属

先把以下状态从 Widget 本地迁出或明确归属：

- 右栏选中卡片
- 右栏筛选
- 左稿纸选中 marker

### 第二步：打通最小联动

先完成：

- 左点右
- 右点左

只要这两条链路闭环，基本联动就成立了。

### 第三步：补充增强联动

再补：

- `‹ / ›` 逐条走查
- 每段点评闪动
- 核心词 / 语法点 focus

### 第四步：补重置逻辑

最后补：

- 批改记录切换后的联动状态清空
- 模式切换后的联动状态清空

---

## 明确不做

这次不要顺手扩这些范围：

1. 不重构整个 `ReviewBoardBoxWidget` 渲染算法
2. 不改写作板普通编辑态逻辑
3. 不把批改联动塞进 `BoardController`
4. 不做完整滚动定位基础设施重写
5. 不接重新批改接口
6. 不处理媒体题左稿纸联动

---

## 验收标准

完成后至少满足：

1. `ReviewBoardBoxWidget` 通过入参与回调接入联动，不自己维护长期选中状态
2. `ZhenxieTaskWritingBoardWidget` 成为左稿纸联动装配入口
3. `CorrectionController` 只维护批改域最小联动状态
4. 左右联动链路可闭环：
   - 左点右
   - 右点左
   - 点每段点评闪拍位
   - 点已命中的核心词 / 语法点能 focus 稿纸
5. 切换批改记录后旧状态不会残留
6. 左右两边编号口径一致

---

## 当前方案结论

本次联动不是让两个 Widget 互相直接传状态，而是：

1. `CorrectionController` 持有最小批改联动状态
2. `ZhenxieTaskWritingBoardWidget` 负责把状态装配给 `ReviewBoardBoxWidget`
3. `ReviewBoardBoxWidget` 只接收状态并回抛事件
4. 右栏批改区统一把点击动作交给 `CorrectionController`

这样可以同时满足：

- 控制器逻辑不至于过重
- 稿纸组件可复用
- 页面联动状态集中
- 后续继续接批改记录能力时边界稳定
