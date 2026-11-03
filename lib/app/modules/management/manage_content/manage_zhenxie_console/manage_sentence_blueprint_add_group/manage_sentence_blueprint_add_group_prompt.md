## 页面目标

- 完成 `manage_sentence_blueprint_add_group` 页面所需的 Pattern add-set 逻辑。
- 保持现有 UI 结构与视觉不变，只补状态、显隐、交互和接口调用。
- 页面入口来自单元 Target，当前页只需要处理 `unitId + target + patternBlueprint + presetSentenceIds` 这组入参。

## 参考与约束

- 交互参考：`/Users/langwise/Desktop/ns/project/ui_ux/src/pages/zhenxie/sentence/components/AddRealizationSetModal.tsx`
- 接口文档：`/Users/langwise/Library/Containers/com.tencent.WeWorkMac/Data/Documents/Profiles/F6CC4FF318C19B528AB86C263E2B4278/Caches/Files/2026-09/ebdf025c7b44de8f95305560491a80c2/05.pattern-pyramid-realization-set-admin-api.md`
- 控制器与 View 禁止定义页面操作 model。
- 若某个 widget 需要新的页面态 model，必须写在对应 widget 文件里。

## 本页需要落的逻辑

1. 蓝图骨架区
   - 基于 `patternBlueprint` 计算固定槽、可选槽、已纳入槽、要拧槽。
   - 控制说明文案与提示文案的显示。
   - 句数输入范围固定为 2 到 8，并驱动下方绑句卡片数量。
   - 当入口带了 `presetSentenceIds` 时，先基于 `target + patternBlueprint` 计算形态锁，再按当前形态默认把可纳入的 form 槽拨成要拧槽。
   - 当入口带了 `presetSentenceIds` 时，句数默认取 `max(2, presetSentenceIds.length)`；未带时保持默认值 `2`。

2. 绑句区
   - 只有 shape 锁定完成后才显示句卡列表。
   - 每个句位支持“挑一句”和“手输 uid”。
   - 候选句弹窗走 `cell-candidates`。
   - 手输 uid 走 `bind-check`。
   - 卡片中展示当前已绑定句、uid、上架状态与错误提示。
   - 新增可选入口参数 `presetSentenceIds`，类型为 `List<int>`。
   - 当入口带了 `presetSentenceIds` 时，先用 `querySentenceStructure` 按 `contents: [{ type, uid }]` 批量补查句子结构，再按传入顺序把句子回填到 `boundSentenceMap`，进入页面后默认显示已绑句。
   - 预填句查询结果统一复用 `PatternBlueprintSentenceBriefEntity`，不能额外定义页面专用入参 model。
   - `querySentenceStructure` 的请求内容默认按 `type: "EN_SENTENCE"` 组装；如果后续入口补充更精确的 type，再按真实字段透传。
   - 已绑定句展示不能只显示纯文本，要基于句子的 `segmentList` 和当前 `dialSlotKeys` 做句面高亮，视觉效果对齐 Web 端 `SlotTintedSentence` 的语义：只高亮当前要拧的槽，对应文本保持原句顺序与内容。
   - 如果句子缺少 `segmentList`，先按普通文本兜底显示，不能因为高亮失败导致句子不展示。

3. 底部按钮
   - `已绑 x/y` 基于当前 shape 和已绑定句数实时变化。
   - “补句落库”要求 shape 已锁且至少已绑 1 句。
   - “满句落库”要求 shape 已锁且所有句位都已绑满。
   - 提交时按文档组装 `baseSlotKeys / dialSlotKeys / sentenceIds / match_first`。

4. 接口边界
   - 当前页只接 Pattern add-set 相关接口。
   - 如果出现文档未给出的后续接口，先留带 `TODO` 注释的方法，占位并把参数组装好。

## 实现提醒

- 优先复用 `PatternBlueprintSentenceBriefEntity` 承接句子摘要。
- 预填句初始化若依赖异步补查，生命周期里只做编排，具体查询与回填拆到私有方法。
- 优先复用现有句子高亮能力或在当前模块补一个轻量句面高亮组件，不要把高亮逻辑堆进 View。
- 新增注释要短、准，说明状态含义与方法副作用。
- 禁止顺手改动无关 UI、命名或排版。
