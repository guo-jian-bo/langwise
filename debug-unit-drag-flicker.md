# Debug Session: unit-drag-flicker
- **Status**: [OPEN]
- **Issue**: 管理单元弹窗中，拖拽单元卡片开始时仍会出现肉眼可见的闪烁，预期应当是平滑地“提起”卡片进入拖拽态。
- **Debug Server**: http://127.0.0.1:7777/event
- **Log File**: .dbg/trae-debug-log-unit-drag-flicker.ndjson

## Reproduction Steps
1. 打开后台模块详情页
2. 点击底部“管理单元”
3. 在弹窗网格中长按任一单元卡片并开始拖拽
4. 观察拖拽开始瞬间是否出现闪烁

## Hypotheses & Verification
| ID | Hypothesis | Likelihood | Effort | Evidence |
|----|------------|------------|--------|----------|
| A | 拖拽库在 drag start 时先移除原节点，再插入 overlay proxy，期间出现一帧空白 | High | Low | Pending |
| B | `CachedImageWidget` 在 proxy 中重新挂载，图片首帧回退到 placeholder | High | Low | Pending |
| C | 卡片角标组件（难度标签 / 拖动标签）在 proxy 首帧重绘时导致整卡闪烁 | Medium | Low | Pending |
| D | 当前 `proxyDecorator` 仍触发了起拖时的额外视觉变化 | Medium | Low | Pending |

## Log Evidence
- Instrumentation points:
  - A: `onReorderStart` / `onReorderEnd`
  - A: dragged item rebuild in grid
  - B: dragged item cover placeholder hit
  - D: proxy decorator first build
- Pending

## Verification Conclusion
- Pending
