## 目标与验收口径

- 记录当前词源画布在“首屏进入 / 点击底部义项切换”两种场景下的缩放与定位规则。
- 明确当前规则中的顶部、底部避让逻辑，避免后续误判为普通居中。
- 说明本轮调整后，底部义项切换不再沿用整图适配缩放，而是按目标节点原始大小聚焦。

## 改动点列表

- `etymology_memory_view.dart` 中新增了底部义项点击后的聚焦请求消费逻辑，由 view 统一补上顶部和底部浮层的 `insets`。
- `etymology_memory_controller.dart` 中新增 `shouldFocusCanvas`，将“义项切换后请求聚焦”与“整图适配请求”拆开。
- `etymology_canvas_widget.dart` 中将 `focusToNode` 扩展为支持 `insets`，并把义项聚焦时的缩放规则改为固定 `scale = 1.0`。
- 义项聚焦的垂直定位点从可用区域正中，调整为可用区域 `58%` 位置，视觉上更偏中下。

## 当前规则说明

### 1. 首次进入页面

- `EtymologyMemoryController._applyDetils()` 会在首屏数据准备完成后，将 `shouldFitCanvas` 设为 `true`。
- `EtymologyMemoryView._consumeCanvasInteractionRequests()` 会在下一帧调用 `canvasController.fitToCanvas(insets: _buildCanvasFitInsets())`。
- 这里走的是“整图适配”逻辑，不是节点聚焦逻辑。

当前表现：

- 画布会根据整棵树的整体宽高，计算一个能完整放进可视区域的缩放比例。
- 可视区域会扣掉顶部树切换条和底部义项栏占用的空间。
- 首次进入只做整图适配，不会自动把节点聚焦到中下位置。

### 2. 点击底部义项切换条

- `EtymologyMemoryController.switchSemantic()` 切换当前树、当前义项、当前节点后，会将 `shouldFocusCanvas` 设为 `true`。
- `EtymologyMemoryView._consumeCanvasInteractionRequests()` 在下一帧消费这个请求，并调用：
  - `canvasController.focusToNode(..., insets: _buildCanvasFitInsets())`

这里走的是“节点聚焦”逻辑，不再是“整图适配”。

当前表现：

- 目标节点按原始渲染大小显示，即固定 `scale = 1.0`。
- 聚焦时不会保留用户之前手动放大的倍数。
- 聚焦中心不是整个视口的几何中心，而是扣掉顶部、底部浮层后的“可用区域中心”。
- 当前为了让节点视觉位置略靠下一点，纵向中心点使用的是可用区域高度的 `58%`，不是 `50%`。

### 3. 顶部 / 底部避让规则

- `EtymologyMemoryView._buildCanvasFitInsets()` 会测量：
  - 画布视口区域
  - 顶部树切换条
  - 底部义项栏
- 然后把这些浮层占用的高度换算成 `EdgeInsets(top, bottom)`。

这些 `insets` 会同时用于：

- 首屏 `fitToCanvas`
- 底部义项点击后的 `focusToNode`

因此当前“居中”的真实含义是：

- 在扣掉顶部 / 底部遮挡区域后的剩余可用区域里居中
- 而不是在整块 `InteractiveViewer` 里做绝对几何中心对齐

## 关键设计 / 关键决策

- 首屏继续保留“整图适配”，因为首次进入的目标是先看清整棵树的全貌。
- 底部义项点击改为“节点原始大小聚焦”，因为这个交互更像查看当前义项对应节点本身，而不是重新浏览整棵树。
- 聚焦时仍保留顶部 / 底部避让，防止节点被树切换条或义项栏压住。
- 聚焦落点下移到 `58%`，是为了减轻“正中太硬、太顶”的观感问题。

## 兼容性影响与注意事项

- 底部义项点击后，画布会直接回到节点原始大小，不再保留用户上一次手动缩放结果。
- 如果目标节点本身特别高或特别宽，`scale = 1.0` 时仍可能超出当前可用区域；当前规则不会额外自动缩小该节点。
- 顶部树切换仍沿用整图适配逻辑，本轮没有改成节点原始大小聚焦。

## 非目标

- 不调整整图布局算法。
- 不修改节点之间的连线逻辑。
- 不新增“节点过大时自动压缩到刚好可见”的兜底规则。
- 不改用户手势拖拽、缩放本身的交互能力。
