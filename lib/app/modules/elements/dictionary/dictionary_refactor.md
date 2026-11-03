## 目标与验收口径

- 词典页列表接口从 `/languages/content/card/page` 切换到 `/languages/content/card/v2/page`
- 列表项直接使用 `KnowledgeCommonEntityList` 渲染 `ElementsDictReadCard`
- 页面骨架调整为「顶部面包屑 + 右侧通用设置/提示」「中间网格列表」「底部筛选排序搜索条 + 听写按钮」
- 保留原有搜索、筛选、排序、已学听写与锁态权限遮罩能力

## 改动点列表

- `controllers/dictionary_controller.dart`
  - 去掉旧的 `ElementsDetilsDataModel` / `ElementsCardGroove` 数据链路
  - 改为请求并维护 v2 词典分页数据
  - 保留旧的筛选、排序、搜索、已学判定与听写跳转逻辑
  - 顶部帮助视频改为显式 `helpVideoUrl` 字段维护
- `views/dictionary_page.dart`
  - 顶部右侧改为 `GeneralSettingButtonWidget + HelpIVideoIconWidget`
  - 中间网格直接渲染 `ElementsDictReadCard`
  - 移除旧的右侧浮动按钮区
  - 底部条保留原搜索/筛选/排序，并将听写按钮并入底部区域
- `lib/common/https/elements.dart`
  - 新增词典页专用 v2 请求方法，避免影响旧接口调用方
- `lib/common/entities/knowledge_common_entity.dart`
  - 新增 v2 词典分页实体，承接 `list / datas / rights / count / total`

## 关键设计/关键决策

- 不直接覆盖旧的 `getCardList`，避免影响 `morpheme`、`elements_detils` 等仍走旧接口的页面
- 保留旧的 `query meta group list` 作为底部筛选排序元数据来源，先确保词典页迁移稳定
- 听写按钮继续沿用“只有已学状态才显示”的旧规则

## 兼容性影响与注意事项

- 词典页列表项从旧卡片模型切到 `KnowledgeCommonEntityList` 后，不再支持旧页面上的长按重置学习计划交互
- v2 样例里真实列表数据优先取 `data.list`，`data.datas` 仅作为兼容兜底
- 请求参数仍保留 `style` 与 `mediaMode`，维持当前词典页接口行为

## TODO / 待确认

- 若后端后续补齐 v2 item 中更多字段（例如专门的听写字段），可再把 `goDictate` 的映射从当前最小可用字段补全
