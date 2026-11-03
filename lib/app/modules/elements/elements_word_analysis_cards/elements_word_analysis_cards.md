# 单词分析关联卡片页说明

## 目标与验收口径

- 为单词详情页中的 `sentence`、`phrase`、`synonym` 分析卡片接入点击跳转。
- 点击后进入一个通用的关联词典卡片列表页。
- 新页面仅保留：
  - 返回 / 面包屑
  - 网格卡片
  - 分页
  - 空态
- 卡片复用词典页现有样式和详情跳转能力。
- 若接口同时返回 `previewForms` 和 `pos`，则仅对正文中的命中 token 高亮；否则回退为普通词典卡片。

## 改动点列表

- 新增 `ElementsWordAnalysisCardsView`
- 新增 `ElementsWordAnalysisCardsController`
- 新增 `ElementsWordAnalysisCardsBinding`
- 新增单词分析关联卡片页路由与 tag 路由注册
- 单词详情页 3 个分析卡片入口接入新页面跳转
- 为公共词典卡片链路增加可选正文高亮配置透传

## 关键设计 / 关键决策

- 采用 **一个通用页面** 承接 `sentence / phrase / synonym`
- 新页面使用 **新的 controller**，不复用词典主页 controller
- 高亮只作用于 **正文 contentText**
- `gloss / definition` 保持原逻辑，不参与高亮
- 高亮配置通过卡片链路逐层透传，最终在 `ElementsCardFrontPanelWidget` 落地

## 兼容性影响与注意事项

- 公共卡片新增的是可选参数，不传时旧页面行为应保持不变
- 同义词接口若缺少 `previewForms` 或 `pos`，页面应展示普通词典卡片
- 本次不引入词典主页的搜索、筛选和底部工具栏

## TODO / 待确认

- 若后续需要让更多页面复用“正文 token 高亮”能力，再评估是否下沉为公共 helper
