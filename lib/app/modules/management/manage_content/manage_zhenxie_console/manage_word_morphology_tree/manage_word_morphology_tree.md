# 构词树页

## 目标与验收口径

- 新增管理端 morphology 第三页：`构词树`
- 从词素成员词卡点击后进入树页
- 接 `/language-console/write/word/morphology/tree`
- 完成页头信息、当前词卡、拆词说明、成分卡、叶子卡、返回/跳转、拖拽缩放

## 改动点列表

- 新增 `word_morphology_tree_entity.dart`
- 新增 `LanguageConsoleRequest.queryWordMorphologyTree`
- 新增 `manage_word_morphology_tree` 模块（binding / controller / view）
- 新增 `Routes.MANAGE_WORD_MORPHOLOGY_TREE`
- 管理端 registry 注册新页面
- 第二页成员词卡点击改为进入构词树页

## 关键设计 / 关键决策

- 树体布局参考 React `MorphologyTreeCanvas.tsx`
- Flutter 实现采用 `InteractiveViewer + Stack + CustomPaint`
- 表面序定位与高亮逻辑直接按 React 的 `highlight.ts` 思路迁移
- 类型与 POS 文案 / 颜色优先走配置接口，不增加本地映射表

## 兼容性影响与注意事项

- 本次只做管理端树页，不改词典侧栏 `morphology strip`
- 叶子卡点击进入现有单词详情页
- 成分卡“查看更多”继续走现有 morphology 词卡页；普通分支传 `morphemeNid`，root 分支改传接口原始 `key`

## 待确认问题 / TODO

- 需要真实页面联调确认图 1 的视觉细节是否还要继续微调
- 若后续要支持 `/morphology/tree/:wordId` 的词典直入路由，需要再补占位 `tree` 分支
