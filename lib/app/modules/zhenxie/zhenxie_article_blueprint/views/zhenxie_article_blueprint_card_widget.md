# ZhenxieArticleBlueprintCardWidget 布局对齐提示词

## 目标

将 `zhenxie_article_blueprint_card_widget.dart` 的整体布局对齐 Web 端 `CompositionBlueprintCard.tsx` 的信息层级：

1. 顶部是文章蓝图家族信息区
2. 下方是蓝图路径卡片的两列网格
3. 蓝图项保持概览态，不使用详情页的大封面头图

## 本组件本次验收口径

1. 只允许调整布局结构，不改现有颜色体系
2. 外层卡片仍沿用当前 Flutter 端的圆角、边框、背景色
3. 顶部信息区保持：
   - 标题
   - 描述
   - 管理端文章 ID
   - 管理端“编辑详情”按钮
4. 下方蓝图列表改为两列排布
5. 单个蓝图项头部保持概览态信息：
   - 蓝图标题
   - 段数标签
   - 难度标签
   - 管理端蓝图 / 框架 ID
6. 蓝图摘要表继续复用 `ArticleBlueprintMinTableWidget`
7. 原有点击能力保留：
   - 点击外层卡片进入文章详情
   - 点击蓝图摘要进入对应蓝图详情

## 不做

1. 不调整主题 Token
2. 不修改摘要表内部样式和路径逻辑
3. 不新增管理端编辑接口
4. 不顺手改详情页卡片布局
