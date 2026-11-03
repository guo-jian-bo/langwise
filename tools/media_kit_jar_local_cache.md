# media_kit libmpv jar 本地化操作指南（方案 1）

> 目标：`flutter build apk` 时跳过从 GitHub 下载 4 个 libmpv jar，零源码改动。

## 前置条件

- 脚本：`tools/prepare_media_kit_jars.sh`（已集成到 `build_android.sh`）
- 无需手动维护版本号或 MD5：脚本自动从项目配置动态解析
  - 包版本：从 `pubspec.lock` 解析 `media_kit_libs_android_video` 的版本
  - jar 列表 / 版本号 / MD5：从包内 `android/build.gradle` 的 `filesToDownload` 解析
  - 实际文件 MD5 与解析出的期望值逐一比对，不匹配则重新下载

## 日常打包

直接执行（已集成回填逻辑）：

```bash
./build_android.sh
```

或手动分步：

```bash
./tools/prepare_media_kit_jars.sh
flutter build apk --profile integration_test/appium_test.dart
```

脚本幂等，输出含义：
- `skipped=4`：缓存命中，零下载
- `copied=N`：从共享缓存复制 N 个
- `downloaded=N`：共享缓存缺失，自动从 GitHub 下载 N 个（仅首次联网）

## flutter clean 之后

`flutter clean` 会清空 `build/`，脚本自动从共享缓存回填（无需联网）：

```bash
flutter clean
./build_android.sh
```

## 新机器 / CI 初始化

无需手动准备，直接执行「日常打包」即可：脚本检测到共享缓存缺失 jar 时自动用 `curl` 从 GitHub 下载（仅首次联网，之后走本地缓存）。

手动预填缓存（可选，适合离线环境）：从已构建过的机器复制 `~/.cache/media_kit-jars/<版本号>/`。

## 自定义缓存位置

```bash
MEDIA_KIT_JARS_DIR=/some/path ./tools/prepare_media_kit_jars.sh
```

## 验证

打包时观察日志，**不再出现** `Downloading file from: https://github.com/media-kit/...` 即成功。

## 升级 media_kit 后

脚本自动适配：包版本变化后，`flutter pub get` 更新 `pubspec.lock` 与 pub-cache，脚本重新解析新的版本号、jar 列表与 MD5，无需改任何代码。首次构建会自动下载新版本 jar。
