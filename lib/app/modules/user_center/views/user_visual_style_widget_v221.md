# UserVisualStyleWidget 2.2.1 改造说明

## 目标与验收口径
- 用户中心里的视觉风格偏好按 2.2.1 文档改造为“视觉模式 + 主风格 + 风格混搭”结构。
- 去掉旧版风格商店、订阅、管理、演示相关 UI 和交互。
- 混搭相关能力严格对齐后端字段：`mainStyleUse`、`isMediaMix`、`imageStyleUses`。
- 设置弹窗底部增加“做题时风格混搭”入口，点击后跳转用户中心并自动滚动到视觉风格模块。

## 改动点列表
- `user_visual_style_widget.dart`
  - 顶部结构调整为“切换模式 / 主风格 / 最终视觉展示区”。
  - 用户中心主风格区改为全量展示风格目录，不直接过滤 `imageStatus` / `videoStatus` 非开放项。
  - 底部新增“风格混搭” section。
  - 删除旧的风格商店和订阅操作区。
- `user_visual_style_controller.dart`
  - 改为按 `mediaModeUse`、`mainStyleUse`、`isMediaMix`、`imageStyleUses` 进行读取和保存。
  - 切模式时自动回退到当前模式首个可用主风格。
  - 主风格固定落在混搭集合内。
- `general_setting_button_widget.dart`
  - 用户端视觉区域标题“画面偏好”改为“主风格”。
  - 底部新增“做题时风格混搭”入口。
  - 用户端视觉保存逻辑切到 2.2.1 请求体。
- `user_center_view.dart`
  - 为 `UserVisualStyleWidget` 增加单独滚动锚点。
- `team_style_entity.dart`
  - 新增 `mainStyleUse`、`isMediaMix` 字段解析。

## 关键设计 / 关键决策
- 混搭关闭时只隐藏勾选区，不清空 `imageStyleUses`，保留后端返回的混搭集合。
- 用户中心这里采用即时保存，不额外增加“保存”按钮。
- 主风格单独选择，混搭集合单独勾选；主风格项固定选中，不允许在混搭集合里取消。
- 风格是否可用只看 `imageStatus` / `videoStatus`，不再使用旧订阅字段做前端拦截。
- 弹窗里的主风格列表继续只展示当前模式可用风格；用户中心则保留即将开放 / 未开放卡片，用禁用态承载 `statusHint`。

## 兼容性影响与注意事项
- `ConfigController` 的用户端风格初始化已改为优先对齐后端 `mainStyleUse`。
- 用户端视觉弹窗也同步切到 2.2.1 口径，避免与用户中心行为不一致。
- 当前预览区优先展示图片或视频首帧，未额外扩展新的播放交互。

## TODO / 待确认
- 如果后续需要把用户中心右侧预览升级为可播放视频，可在现有结构上继续补 `Player` 交互。
