# [OPEN] preview-video-audio-stall

## 背景
- 现象：预习页面有时前几个题正常，随后出现“当前题视频播完后不播音频”或“当前题播完，切到下一题后整题不播放”的卡住问题。
- 环境：macOS Flutter，本地 `quizplay` 已切到工作区，预习页已接入视频 -> 等待 -> 音频 -> 等待 -> 下一个 的新链路。
- 已知线索：问题常伴随 `inactive/resumed/hidden` 生命周期切换日志，但暂未确认是否为直接根因。

## 当前假设
1. 视频完成事件偶发没有上抛到预习控制器，导致 `_playbackPhase` 一直停在 `video`，后续音频阶段未启动。
2. 生命周期切到 `inactive/hidden` 后，已有的 `_switchTimer` 被取消或失效，但没有补偿恢复，导致流程停在等待阶段。
3. `previewVideoController.playOnce()` 或 `audioPlaybackUtils.prepare()` 在快速切题/切后台后进入竞争态，序列号 `_sequenceVersion` 被更新，导致后续回调被丢弃。
4. 当前知识点切换时，旧视频组件释放或新视频组件挂载的时机不稳定，导致“下一个题”的视频完成监听未绑定成功。
5. 音频资源准备失败或未 resume，但目前缺少运行时证据，表面上看起来像“视频后不播音频”。

## 调试计划
- 第一步：只添加运行时日志，记录视频完成、阶段切换、定时器调度、音频 prepare/resume、生命周期变化、题目索引和 sequenceVersion。
- 第二步：复现后读取日志，确认卡住停在哪个阶段。
- 第三步：基于证据做最小修复，并对比修复前后日志。

## 当前进展
- 已在 `official_course_details_preview_controller.dart` 添加日志点：视频完成回调、序列重启、定时器调度/触发、音频 prepare/resume/complete。
- 已在 `tips_video_widget.dart` 添加日志点：`playOnce` 进入、`position >= end`、`completed stream`、`stopAndReset`、controller 绑定/销毁。
- 已放弃 HTTP/文件采样方案，当前统一改为 `debugPrint` 控制台日志，日志前缀为 `[PREVIEW-STALL]`，由用户直接复制控制台输出回传。

## 证据结论
- 假设 1 `视频完成未上抛`：被否定。日志显示第一题、第二题、第三题都出现了 `video finished callback {"reason":"completed"...}`。
- 假设 2 `等待定时器未触发`：被否定。日志显示 `schedule phase transition` 后都能正常出现 `phase transition timer fired`。
- 假设 5 `音频 prepare/resume 失败`：被否定。前几个题均有 `audio prepared` 和 `audio resumed`。
- 假设 4 `切题后新视频卡片绑定时机不稳定`：被确认。关键证据是第二题切换时，控制器已经打印 `start video phase {"content":"The boys are reading."...}`，但随后的 `tips video playOnce enter` 仍然指向上一题旧视频 `EDB820...mp4`，新题 controller attach 日志反而更晚出现。
- 补充判断：问题不是单纯“资源未释放”，而是“共享 controller 在切题瞬间仍绑着旧 state，导致新题的播放命令打到旧视频上”。旧视频随后 dispose/stop，又让当前题流程进入异常竞争态。
- 第二轮证据：共享 controller 绑定问题修复后，卡点后移到第 11 题。日志显示第 11 题出现了 `tips video playOnce enter`，但没有 `position reached clip end` / `completed`，却直接出现 `tips video playOnce future completed`。结合 `TipsVideoWidget` 实现，唯一会在这种情况下提前结束 `playOnce()` 的路径，是 `stream.playing` 变为 `false` 时提前完成了 `_playCompleter`。

## 已实施修复
- 为 `TipsVideoWidgetController` 增加 `currentVideoPath` 和 `waitUntilBoundToVideo()`，允许页面层确认 controller 已绑定到目标视频。
- `预习` 控制器的 `_restartCurrentKnowledgeSequence()` 不再立即对共享 controller 直接 `playOnce()`，而是先等待新题视频卡片 attach 到正确 `videoUrl` 后再启动。
- 如果 2 秒内仍未绑定成功，兜底降级为直接进入音频阶段，避免整题卡死。
- 公共视频卡片在使用外部共享 controller 时，不再在旧卡片 `dispose()` / `didUpdateWidget()` 里自行 stop，避免把新题刚启动的视频反向停掉。
- `TipsVideoWidget` 不再把 `stream.playing=false` 误判为“本次播放完成”。`playOnce()` 现在只由 `_stopAndReset()` / `_releasePlayer()` / 完成事件来结束，避免在播放器临时掉到 `false` 时提前返回。

## 待用户操作
- 进入预习页，按你平时最容易卡住的方式复现 1 次。
- 复现后不要立刻继续做太多额外操作，先把“卡住时停在哪一题、是视频后无音频还是整题都不播”告诉我。
- 我会读取 `.dbg/trae-debug-log-preview-video-audio-stall.ndjson`，用证据判定根因。
