# 同组补充页说明

## 目标与验收口径
- 在短语搭配组详情页右下角增加“补充 n”悬浮按钮。
- 当详情接口返回 `extrasCount >= 1` 时展示按钮，否则不展示。
- 点击按钮进入新的“同组补充”页面。
- 新页面调用 `GET /languages/write/zhenxie/phrase/cluster/extras?nid=xxx`。
- 使用接口返回的 `data.list` 渲染为五列卡片网格，卡片复用现有 `ElementsDictReadCard`。

## 改动点列表
- 详情页增加悬浮按钮与跳转逻辑。
- 新增“同组补充”页面的 route、binding、controller、view。
- 新增 `LanguageUtil.getWritePhraseMatchExtras` 接口方法。

## 关键设计 / 关键决策
- `extras` 接口返回的是内容卡片列表，不是 `PhraseMatchEntity`，因此直接复用 `KnowledgeCommonEntityList` + `ElementsDictReadCard`。
- 管理端入口暂时沿用同一个用户端只读 extras 接口，不额外猜测 console 端地址。
- 页面布局采用五列固定网格，和用户确认口径保持一致。

## 兼容性影响与注意事项
- 不改原短语搭配详情页主体结构，只新增底部悬浮入口。
- 原有短语搭配列表页与详情页数据展示逻辑保持不变。

## 待确认问题 / TODO
- 若后续存在管理端专用 extras 接口，可再切分 `isManagement` 分支。
