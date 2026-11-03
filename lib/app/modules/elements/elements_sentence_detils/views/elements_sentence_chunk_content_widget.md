# Elements Sentence Chunk Content Widget

## 目标与验收口径

- 调整 `chunks + svoca` 顶部网格与下半详情块的标题、主色来源
- `svoca` 的标题与主色统一从颜色配置的 `grammar` 读取
- `chunks` 的标题与主色改为按 `chunking[].type -> upos.code` 直接匹配
- 不再使用前端写死的 `svoca` 类型标题和颜色映射

## 改动点列表

- 顶部网格的 `label` 文案不再直接使用 helper 产出的默认文案
- `svoca`:
  - 标题与主色改为读取 `sentenceSvocaElementTypes`
- `chunks`:
  - 把 `chunking` 子项视为一个独立 label
  - 顶部网格 `label` 文案优先读取命中的 `chunking[].chunkType.name` 中文
  - 主色改为读取命中的 `upos.color.textColor`
- 下半详情区中 `svoca` 分块卡片、`chunks` 语块树卡片、弹窗标题同步使用同一口径
- 弹窗内容区 `buildElementsDialogBody` 已抽到同目录公共组件 `elements_sentence_dialog_body_widget.dart`
- `chunks / svoca` 纵向滚动内容底部增加留白，避免滑到底部时被底部层级切换栏遮挡
- `chunks / svoca` 无数据时改为统一使用项目空页面组件 `NotDataWidget`
- 弹窗结构统一分为 3 类：
  - 顶部网格块：标题固定为 `片段详情`
  - 子句头部句法标签：标题固定为 `句法结构详情`
  - 下半列表块：标题固定为 `语块详情`
- 弹窗内容首行按来源区分：
  - 顶部网格块：`标签 + title`
  - 子句头部句法标签：仅显示被点击标签
  - 下半列表块：仅显示列表块标签
- 弹窗详情区统一改为：
  - 上方中文
  - 中间分割线
  - 下方英文

## 关键设计

- `svoca`
  - 先把 `typeNid` 归一到颜色配置里的 `sentenceSvocaElementTypes.code`
  - 例如 `a -> ADV`、`oi -> IO`、`od -> DO`、`c_obj -> OC`
- `chunks`
  - 不再从 `chunkTypes` 取顶部块标题和主色
  - 直接用 `chunking.type` 匹配 `upos.code`
- 若配置未命中：
  - `svoca` 标题优先回退元素自身的后端名称
  - `chunks` 标题优先回退 `chunking.type`
  - 颜色回退为当前页面的中性样式，避免页面不可读

## 兼容性影响与注意事项

- 本次只调整标题与主色来源，不改网格结构、点击交互、余文逻辑
- `conjunction` 与 `residual` 的样式规则保持不变
- `svoca` 的 code 骨架卡片颜色仍保持原有逻辑，本次只改元素块
- 顶部网格弹窗首行标签会对齐下半列表口径：
  - `chunks` 使用 `chunkType.name`
  - `svoca` 使用 `element.type.name`

## TODO

- 确认服务端 `sentenceSvocaElementTypes.code` 与 `typeNid` 是否还有更多别名需要补齐
- 若后端后续提供区块级显式颜色/标题字段，可再评估是否直接改为后端直出
