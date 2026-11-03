# ElementsPronunciationModuleWidget 重构说明

## 目标与验收口径

- 在不修改对外参数和调用方式的前提下，降低 `ElementsPronunciationModuleWidget` 内部复杂度。
- 保持现有展示与播放行为基本不变。
- 补齐组件在外部数据变化时的同步能力，避免切换义项后仍残留上一次发音状态。

## 本次改动点

### 1. 收口当前发音态

- 将“当前口音”“当前音节”“当前自然拼读”改为一组内部 getter：
  - `_currentPronunciation`
  - `_currentSyllables`
  - `_currentPhonetics`
  - `_hasCurrentSyllables`
  - `_hasCurrentPhonetics`
  - `_effectiveDividerType`

这样可以减少组件里大量重复的：
- `pronunciations[englishAmericanType]`
- `currentPronunciation.syllables`
- `currentPronunciation.phonetics`

### 2. 收口初始化与数据同步

- 新增 `_syncPronunciationsData()`
- 新增 `_resolveInitialDividerType()`
- 新增 `_rebuildPhoneticsDisplayData()`
- 新增 `didUpdateWidget`

目的：
- `initState` 与外部参数变化时走同一套同步逻辑
- 切换单词 / 切换义项后，组件能正确刷新内部状态

### 3. 收口播放态更新

- 新增：
  - `_setPlayingIndex()`
  - `_setHeaderPlayingIndex()`
  - `_resolveActiveTextColor()`

目的：
- 减少 `if (mounted) setState(() {})`
- 减少音节区 / 自然拼读区重复的高亮颜色判断

## 本次不做

- 不修改组件对外 API
- 不重做 UI 结构
- 不改发音播放链路能力
- 不改练习题跳转逻辑
- 不把该组件拆到新文件

## 额外修正

- 补了 `didUpdateWidget`，解决外部 `content / contentId / pronunciations` 变化后组件状态不自动刷新的问题。

## 风险与注意事项

- 该组件仍是共享组件，当前重构只做内部压平，不扩散到其他发音相关组件。
- 如果后续还要继续瘦身，优先方向应是把“播放编排”和“展示构建”进一步拆层，而不是继续往 State 里堆分支。
