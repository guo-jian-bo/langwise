# custom_camera_delegate

## 目标

把 `image_picker` 在桌面端的 `ImageSource.camera` 链路接通，避免 macOS / Windows 调用 `pickImage`、`pickVideo` 时因为未注册 `cameraDelegate` 直接抛出 `Bad state`。

## 边界

- 只处理桌面端 `cameraDelegate` 注册与实现
- 优先复用项目现有拍照、录视频弹层
- 不改动移动端原生 `image_picker` 行为
- 不改视频压缩、上传、业务调用方逻辑

## 实现要求

1. 在应用启动阶段完成 `cameraDelegate` 注册
2. `custom_camera_delegate.dart` 不再保留 README 示例空实现，改为真实桌面端实现
3. 拍照复用：
   - macOS -> `CameraMacosDialog.show`
   - Windows -> `CameraWindowsDialog.show`
4. 录视频复用：
   - macOS / Windows -> `CameraVideoRecordingDialog.show`
5. `pickVideo(... maxDuration: ...)` 传入的时长限制需要透传到录制弹层
6. 若当前没有可用全局上下文，则返回 `null`，不做异常中断
