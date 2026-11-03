[OPEN] preview-stop-at-eleven

## 症状
- 预习页自动播放在第 11 个知识点附近经常卡住。
- 表现为视频播放完后，没有进入音频阶段，也没有继续切到下一个知识点。

## 当前假设
- 假设 1：第 11 个视频没有真正触发 `completed`，控制器一直停在 `video` 阶段。
- 假设 2：视频完成回调已到控制器，但被序列版本或阶段状态拦截，导致没有进入 `waitingAfterVideo` / `audio`。
- 假设 3：应用生命周期或全局暂停事件在第 11 个附近打断了媒体链路，且恢复逻辑没有真正生效。
- 假设 4：视频组件内部有额外的 `stop/reset/release` 路径在第 11 个触发，导致视频结束时没有上抛 `completed`。
- 假设 5：第 11 个资源在播放器层触发了异常边界，导致 `playOnce` 返回但没有按预期回调完成事件。

## 已有线索
- 之前日志显示第 11 个附近出现 `AppLifecycleState.inactive/hidden`。
- 之前也出现过 `tips video stopAndReset` 但没有 `video finished callback {"reason":"completed"}`。

## 下一步
- 只读取第 11 个附近的控制台日志，确认是哪一个假设命中。

## 本轮证据
- `xxx.log` 只有 361 行，结束在：
  - `tips video playOnce enter`
  - `tips video stopAndReset {"silent":true,"finishReason":null}`
  - `AppLifecycleState.inactive`
  - `AppLifecycleState.hidden`
- 没有出现第 11 个对应的：
  - `video finished callback {"reason":"completed"...}`
  - `start audio phase`
  - `phase transition timer fired`
- 也没有出现最新代码里新增的生命周期日志：
  - `[PREVIEW-STALL][L] preview lifecycle interrupted`
  - `[PREVIEW-STALL][L] resume preview sequence after lifecycle`

## 当前判断
- 假设 2 暂未命中，因为看不到完成回调到控制器。
- 假设 3 仍然最强：第 11 个附近被生命周期切到 `inactive/hidden` 直接打断。
- 当前这份日志无法验证“恢复逻辑是否已生效”，因为它不包含最新补丁新增的 `[L]` 日志，说明运行的不是最新代码，或至少没有完成 `Hot Restart/完整重启`。
