# 曲折变化详情页说明

## 目标与验收口径
- 新建甄写后台「屈折变化」详情页。
- 接通详情接口 `/language-console/write/word/inflection/detail`。
- 页面可完成详情浏览：头部信息、义项切换、板面展示、槽位三态展示。
- 将屈折变化板面与槽位卡下沉到通用组件目录，供前台后续复用。

## 改动点列表
- 新增详情实体 `WordInflectionDetailEntity` 及其子实体。
- 在 `LanguageConsoleRequest` 中新增屈折变化详情请求方法。
- 新增通用组件：
  - `word_inflection_meta.dart`
  - `word_inflection_slot_card_widget.dart`
  - `word_inflection_slot_board_widget.dart`
- 新增管理端详情模块：
  - `binding`
  - `controller`
  - `view`
- 新增详情路由与管理页注册。
- 将列表页 item 接通到详情页跳转。

## 关键设计 / 关键决策
- 管理端详情页首版采用「头部 + 自适应板面 + 底部义项切换」结构，尽量贴近 React 方案，同时保持 Flutter 管理端现有字号、圆角和间距体系。
- 板面逻辑按词性分流：
  - 名词：2x2 四宫格
  - 形容词 / 副词：三段程度梯
  - 动词：五格风车；当表面数超过 5 时改为网格，超过 6 张时按 4 列展示，兼容 `present_non_third`
- 槽位卡统一支持三态：
  - `linked`
  - `missing`
  - `unavailable`
- 仅复数名词会在控制器里做 `base -> plural` 的板面重映射。
- 同形名词（如单复数同形）会补 `单复数同形` 标签。

## 兼容性影响与注意事项
- 本次没有改动现有单词词典详情页逻辑，曲折变化详情使用独立实体和独立组件。
- 通用组件位于 `lib/common/widgets/zhenxie_widgets/word_inflection/`，目前已可被前台直接复用，但前台尚未接入。
- 当前只接了管理端详情页跳转。
- 对于 `allowedInflectionTypeNids` 仅包含 `base`，且最终展示槽位也只剩一张 `base` 的数据，内容区只展示一张居中的 `原型` 卡片，不再补齐其他屈折位。

## 非目标 / TODO
- 本次 `创建词 / 创建短语` 仅支持本地 state 演示，未接真实写接口。
- 本次未接 linked 槽位跳词典详情。
- 前台页面尚未接入这套通用组件。
