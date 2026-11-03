# 甄写词法总览页

## 目标与验收口径
- 新增一个甄写用户侧的“词法”总览页。
- 页面主体参考 React `DoorColumns` 的三列门卡结构实现。
- 页面头部不照搬 React 顶栏，只保留项目现有面包屑，并让当前页标题为“词法”。
- 首页“词法”卡片点击后进入该页面。
- 页面数据改为对接 `GET /languages/write/zhenxie/lexis/home`，不再使用本地假数据兜底。

## 改动点列表
- `zhenxie_lexis_controller.dart` 新增词法页接口请求和原始数据模型。
- `zhenxie_lexis_view.dart` 改为按接口 `groups/items/slotCombinationItems` 渲染三列门卡。
- `lib/common/https/zhenxie.dart` 增加词法页请求方法。
- “短语结构”卡片不再复用 `PhraseStructurePreviewWidget`，改为页面内按接口返回的 `name/content/style` 直接渲染。
- 甄写词法页使用的暖金强调色和辅助文本色已下沉到项目 `AppTheme`，不再在页面内本地硬编码。

## 关键设计 / 关键决策
- 不直接复刻 React 头部，只复用项目现有 `BreadcrumbWidget`。
- 不额外抽离一次性“空心组件”，页面骨架和标本卡渲染直接保留在当前 view 中，便于后续继续对照 React 微调。
- controller 中保留接口原始字段结构，view 直接消费这些字段渲染，不再维护一套本地门卡假模型。
- 有现成用户端页面的门按后端 `code` 做显式跳转映射：
  - `词源记忆`
  - `短语对照`
  - `短语配对`
  - `搭配组`
  - `短语结构`
  - `入句画像`
  - `构词`（跳转词根词缀列表页 `Routes.MANAGE_WORD_MORPHOLOGY`，以 `isManagement: false` 走用户端接口）

## 兼容性影响与注意事项
- 接口失败或接口数据为空时，页面不做本地兜底，直接展示空内容。
- 词法页视觉延续甄写首页的深色风格，但没有新增顶部说明区，仍保持现有页面骨架。
- “短语结构”卡片虽然保留原有视觉形态，但数据来源已改为接口真实字段。

## TODO
- 后续若要继续对齐 React，可再补：
  - 卡片高度与列宽比例微调
  - 标本细节（尤其词源树、入句画像）的像素级还原
