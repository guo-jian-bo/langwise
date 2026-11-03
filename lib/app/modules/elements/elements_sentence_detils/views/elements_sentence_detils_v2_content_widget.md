# elements_sentence_detils_v2_content_widget 说明

## 目标

实现句子详情页 V2 的右侧信息架构，同时继续复用旧版左侧媒体区域。

## 本次改动

- 新增 `ElementsSentenceDetilsV2ContentWidget`
- 左侧继续复用：
  - `ElementsDetilsLeftPanel`
  - `ElementsSemanticVideoCardWidget`
  - `ElementsSentencePronunciationWidget`
- 右侧改为 V2 信息壳：
  - 句型标签
  - 原文
  - 释义
  - 蓝图标签
  - 蓝图片段
  - 2x2 分析入口
- 四宫格入口已按最新接口字段读取：
  - `type`
  - `title`
  - `status`
  - `color.from/to`
  - `learnTip`
  - `suitable`
  - `index`

## 关键决策

- 左侧媒体区保持旧实现，不做视觉与交互改动
- 旧分析区、旧 tab、旧句法/结构详情不再放进详情页主体
- `analysisEntries` 直接读后端返回，不额外硬编码四宫格主文案
- 四宫格状态按最新数字协议处理：
  - `1` 可进入
  - `2` 即将开放
  - `3` 暂未开放
- 分析入口当前只承接详情壳阶段，点击先给出占位提示，后续再接独立分析页

## 非目标

- 不改左侧媒体区 UI
- 不改单词详情页 UI
- 不改短语详情页 UI
- 不在本阶段接入 `chunks / svoca / syntax / relations` 独立分析页

## 注意点

- 当前阶段重点是详情页信息架构迁移，不是分析页功能完工
- 后续进入第三阶段时，建议在独立分析页中消费 `analysisData`
