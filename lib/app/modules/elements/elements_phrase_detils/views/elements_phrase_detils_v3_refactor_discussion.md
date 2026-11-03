# 短语详情页 V3 重构讨论文档

## 2026-10-07 本次落地结果

- 内容区最终改为与单词详情页一致的“上 460 / 下 375”上下分区。
- 底部仍保留义项 `tabbar`，交互继续沿用现有短语语义切换与词性筛选逻辑。
- 上半区：
  - 左侧为 1:1 媒体区
  - 右侧第一块为信息区，使用：
    - 标题：`detils.content`
    - 翻译：`semantic.gloss` 中中文
    - 详情：`semantic.descriptions` 中中文
    - 标签：保留原有 `difficulty / pos / sentenceProfileTags`
    - 右侧按钮：`练发音 + 加入记忆`
  - 右侧第二块为“结构 + 同义反义”，任一缺失时另一块占满，均缺失时整块隐藏
- 下半区：
  - 左侧固定为“词源”
  - 右侧为“关联 + 句子”平分
- 短语详情新增接入 `analysisData.lexicalSetPreview`，展示与单词详情一致的“同义 / 反义 chips”预览。
- 同义反义点击后直接进入 `Routes.EN_LEXICAL_DETAIL`，并透传 `EN_PHRASE` 对应的 `contentType / contentId / semanticId`。

## 目标与验收口径

- 直接重构现有 `Routes.EN_PHRASE_DETAIL` 对应的短语详情页。
- 页面改造成与单词详情页 V3 同风格的独立详情页。
- 保留独立路由、独立 `binding / controller / view` 结构，不新开第二套路由。
- 页面主体采用与单词详情一致的双栏结构：
  - 左侧固定宽度 `510.wMin`
  - 中间间距 `24.wMin`
  - 右侧 `Expanded` 自适应铺满
- 短语详情使用新的接口返回结构，且新建短语专属模型，不复用、也不扩展 `CardWordSemanticDetilsEntity`。

验收标准：

- 页面骨架、左右布局、底部义项切换条与单词详情页 V3 一致。
- 左侧展示“媒体 / 发音 / 结构”三块。
- 右侧展示“标签 / 释义说明 / 分析卡片 / 底部义项切换”四块。
- 旧短语详情中的右侧浮动工具栏与旧模块弹窗完全下线。
- 分析卡片按 `analysisEntries` 驱动显示，有卡无数据也展示空态。

## 本次明确范围

### 1. 路由与入参

- 继续使用现有路由：`Routes.EN_PHRASE_DETAIL`
- 入参补齐并与单词详情对齐：
  - `contentId`
  - `semanticId`
  - `semanticIds`

### 2. 数据模型策略

- 不扩展 `CardWordSemanticDetilsEntity`
- 不继续沿用旧的单词/短语共用详情模型
- 新建短语详情专属模型，原因如下：
  - 后续短语详情可能单独扩展
  - 单词、短语、句子在后端本身也不是同一套 DTO / VO / 实体结构

建议新增短语详情模型承载：

- 短语详情主实体
- 短语 `semanticItems`
- 短语 `semantic`
- 短语 `structure`
- 短语 `analysisEntries`
- 短语 `analysisData`

### 3. 左侧区域

左侧由 3 部分组成：

1. 顶部媒体区
2. 发音模块
3. 结构区

其中：

- 顶部媒体区可复用当前单词详情的媒体展示能力
- 发音模块复用短语现有的发音组件能力
- 第三块“结构”使用新接口中的 `structure` 字段渲染

## 结构区规则

### 1. 展示结构

结构区自上而下为：

1. “结构”标签
2. `structure.explanations` 中 `lang == zh` 的第一条文本
3. 一行 `items`

### 2. 空态规则

- `structure` 整体不存在：整块不显示
- `structure` 存在但内容缺失：整块保留，内部显示空态

### 3. 说明文案规则

- 只取 `lang == zh` 的第一条 `text`
- 不做双语切换
- 没有中文时不自动回退英文

### 4. items 排布规则

- `items` 按列表原始顺序排布
- 本次不使用 `tokenPosition`

### 5. item 样式来源

- `item` 的颜色与上方文本样式通过 `roleNid` 映射全局配置获取
- 配置来源：`languages/language/config/color/list`
- 使用其中的 `phraseItemRoles`
- 例如 `roleNid == "modifier"` 时，对应映射 `phraseItemRoles` 中同名配置
- 具体实现参考项目中已有同类做法，不新增本地硬编码业务映射

### 6. item 内容规则

- 下方主文本直接展示 `item.text`
- item 的视觉风格参考单词详情页左侧“构词”模块的 item 表现

## 右侧区域

右侧由 4 部分组成：

1. 顶部标签行
2. 释义说明区
3. 分析卡片区
4. 底部义项切换条

### 1. 顶部标签行

直接照搬单词详情页：

- 左边：词性
- 右边：难度

### 2. 释义说明区

直接照搬单词详情页：

- 左边：说明文字
- 右边：加入记忆按钮

## 分析卡片区

### 1. 布局规则

短语详情的分析卡布局与单词详情不同：

- “句子”占据整个左侧部分
- “词源”占据右侧上半部分
- “关联”和“同义”占据右侧下半部分，并左右排布

可理解为：

- 左列：1 张高卡片（句子）
- 右列：
  - 上：词源
  - 下：关联 + 同义

### 2. 展示规则

- 分析卡按 `analysisEntries` 决定是否显示
- 有卡无数据时显示空态
- 当前涉及的卡片类型：
  - `sentence`
  - `memory`
  - `relation`
  - `synonym`

### 3. 各卡内容策略

#### sentence

- 内容结构尽量与单词详情页一致
- 使用短语详情自身的 `analysisData.sentence` 数据适配

#### memory

- 内容结构尽量与单词详情页一致

#### relation

- 本次只保留卡片外壳与布局占位
- 内容区域暂时不展示
- 后续由用户手动接入

#### synonym

- 内容结构尽量与单词详情页一致

### 4. 点击行为

- 已有明确跳转能力的，按已有能力接入
- 没有明确目标页或当前不在本次范围内的，先使用 toast 占位提示

## 底部义项切换条

- 底部义项切换条整体交互与单词详情一致
- 支持基于 `semanticItems` 展示义项胶囊
- 支持按词性筛选
- 切换逻辑与单词详情页保持一致

## 公共组件抽取边界

为了让单词详情与短语详情共用右侧分析卡片体系，本次先抽第一层公共能力：

1. 公共卡片壳子
2. 公共行列布局
3. 公共空态

本次不要求一步到位抽离所有业务内容体，具体内容 body 仍可由单词/短语各自传入。

## 旧逻辑下线范围

以下旧短语详情能力本次直接下线：

- 右侧浮动工具栏（action rail）
- 旧的模块弹窗承载方式

页面统一收敛到：

- 分析卡片区
- 底部义项切换条

## 建议修改范围

预计本次改动将集中在以下文件或目录：

- `lib/app/modules/elements/elements_phrase_detils/controllers/elements_phrase_detils_controller.dart`
- `lib/app/modules/elements/elements_phrase_detils/views/elements_phrase_detils_view.dart`
- `lib/app/modules/elements/elements_phrase_detils/views/elements_phrase_detils_content_widget.dart`
- `lib/common/https/elements.dart`
- `lib/common/entities/` 下新增短语详情专属实体文件
- `lib/common/entities/entities.dart`
- `lib/app/modules/elements/common/` 下新增或抽取分析卡片公共组件
- 如有必要，补齐短语详情入口处的参数透传

## 非目标

- 不新开第二套路由
- 不扩展 `CardWordSemanticDetilsEntity`
- 不改单词详情接口与单词详情实体
- 不补 `relation` 卡片的真实内容
- 不保留旧短语详情右侧工具栏体系
- 不顺手修改无关公共工具能力

## 实现注意事项

- 严格遵守最小 diff 原则
- 优先复用单词详情现有稳定布局与组件
- 与后端字段保持一一对应，不额外发明本地业务字段语义
- 控制器中的原始数据优先使用显式字段保存
- 控制器中的派生结果优先使用显式方法，不通过 getter 暴露计算结果
- 管理端提示优先使用 `ToastUtils.showManageToast`
