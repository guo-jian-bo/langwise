# langwise

Langwise Flutter 客户端项目。

## 项目说明

这是一个基于 Flutter 的多端应用项目，当前仓库已接入：

- iOS
- Android
- macOS
- Windows

项目主业务代码主要位于：

- `lib/app/modules`：业务模块页面
- `lib/app/routes`：路由定义与跳转能力
- `lib/common`：公共实体、网络层、状态与通用组件
- `lib/utils`：工具类与辅助能力

## 开发环境

Flutter 3.47.8 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 737ba8f885 (4 days ago) • 2026-10-22 21:37:31 -0700
Engine • hash dfd2e6cb7d319db05e3bf1503f3e2ac60f6288a2 (revision cf636b1dfb) (3 days ago) • 2026-10-23 02:13:38.000Z
Tools • Dart 3.13.7 • DevTools 2.60.0

## 平台最低支持版本

当前项目配置中可确认的最低支持版本如下：

| 平台 | 最低版本 |
| --- | --- |
| iOS | `15.0+` |
| Android | `7.0+` (`minSdk 24`) |
| macOS | `12.0+` |
| Windows | `Windows 10+` |

说明：

- iOS 最低版本来自 `ios/Podfile` 与 Xcode 工程配置。
- Android 最低版本来自 `android/app/build.gradle` 中的 `minSdk = 24`。
- macOS 最低版本来自 `macos/Podfile` 与 Xcode 工程配置。
- Windows 工程清单当前声明支持 `Windows 10 / Windows 11`。

## 启动前准备

1. 安装与当前项目匹配的 Flutter SDK。
2. 执行依赖拉取：

```bash
flutter pub get
```

3. 按目标平台补齐原生依赖：

```bash
flutter doctor
```

## 运行项目

### 本地运行

```bash
flutter run
```

### 指定平台运行

```bash
flutter run -d ios
flutter run -d android
flutter run -d macos
flutter run -d windows
```

## 常用构建命令

```bash
flutter build apk
flutter build ios
flutter build macos
flutter build windows
```

## 打包发布

### Android

Android 打包脚本：

- `build_android.sh`

用途说明：

- 自动回填 `media_kit` 的本地 jar 缓存
- 执行 `flutter build apk`
- 使用 `--split-per-abi`
- 使用 `--obfuscate`
- 输出符号表到 `./symbols`

执行方式：

```bash
sh build_android.sh
```

产物说明：

- APK 按 ABI 拆分输出
- 崩溃符号表输出到 `symbols/`

### macOS

macOS 当前有两套打包脚本：

- `build_macos_jenkins_justSign.sh`：内部包，只签名，不公证
- `build_macos.sh`：正式分发包，签名 + 公证 + DMG

#### 内部签名包

```bash
sh build_macos_jenkins_justSign.sh
```

特点：

- 仅做签名
- 不做 Apple Notarization
- 适合内部测试或企业内部分发
- 输出 `DMG`

#### 正式公证包

```bash
sh build_macos.sh
```

前置要求：

- 本机已安装可用的 `Developer ID Application` 证书
- 已配置环境变量 `APPLE_ID`
- 钥匙串中已存在 `flutter_notarization` 对应密码
- 本机可执行 `codesign`、`xcrun notarytool`
- `create-dmg` 未安装时脚本会尝试自动通过 Homebrew 安装

特点：

- Flutter release 构建
- 对 `.app` 进行签名
- 提交 Apple 公证
- 回贴公证结果
- 输出正式签名后的 `DMG`

### Windows

Windows 不是只执行 `flutter build windows` 就结束，当前完整流程应为：

1. 先构建 release 产物
2. 将运行时 DLL 补到 Windows release 目录
3. 使用 Inno Setup 脚本打包成安装程序

#### 第一步：构建 Windows release

```bash
flutter build windows --release
```

release 目录为：

- `build/windows/x64/runner/Release/`

#### 第二步：补充运行时 DLL

需要把以下文件复制到：

- `build/windows/x64/runner/Release/`

文件列表：

- `build_assets/msvcp140.dll`
- `build_assets/icu.dll`
- `build_assets/vcruntime140_1.dll`
- `build_assets/vcruntime140.dll`

这些 DLL 建议与 `langwise.exe` 放在同级目录。

#### 第三步：生成安装程序

使用 Inno Setup 脚本：

- `langwise_only10_installVC_incmd_smart_uninstallOld-4.iss`

这个安装脚本已经额外处理了：

- 仅允许 `Windows 10+`
- 旧版本卸载
- VC++ 运行库检测与安装
- WebView2 Runtime 检测与安装

依赖文件来自：

- `build_assets/VC_redist.x64.exe`
- `build_assets/VC_redist.x86.exe`
- `build_assets/MicrosoftEdgeWebview2Setup.exe`

安装包输出目录：

- `Output/`

#### Windows 打包前置要求

- 机器已安装 Inno Setup
- 命令行可直接使用 `ISCC`
- Flutter Windows 构建环境完整

#### 当前需要注意的一点

仓库里的 `build_windows.bat` 目前引用的是：

- `scripts/langwise_only10_installVC_incmd_smart_uninstallOld.iss`

但当前仓库实际存在的是：

- `langwise_only10_installVC_incmd_smart_uninstallOld-4.iss`

也就是说，如果直接跑 `build_windows.bat`，目前大概率会因为 `.iss` 路径或文件名不一致而失败。现阶段更稳妥的方式，是按上面的手动流程执行，或者后续把 `build_windows.bat` 同步到当前实际文件名。

## 链接配置

### Android

- 自定义协议：`langwise://openapp/...`
- Web 链接：`https://timelywise.cn/openapp/...`
- 支付回调：`https://timelywise.cn/alipay`、`https://timelywise.cn/wxpay`

### iOS

- 自定义协议：`langwise://...`
- Universal Link：`https://timelywise.cn/openapp/...`
- 支付回调：`https://timelywise.cn/alipay/`

### macOS

- 自定义协议：`langwise://...`
- Universal Link：`https://timelywise.cn/openapp/...`

### Windows

- 当前代码层已接入 `langwise` 和 `https://timelywise.cn/...` 的链接处理能力
- 当前发布流程使用 Inno Setup 安装器，若要确保安装版可直接被系统链接唤起，还需要确认安装器侧协议注册是否已补齐

## 补充说明

- 当前 README 已按仓库现有配置补齐平台支持信息。
- 如果后续调整了 `Podfile`、`build.gradle` 或 Windows Manifest，记得同步更新这里的版本说明。
- 如果后续调整了打包脚本、安装器脚本或 `build_assets` 中的运行库文件，也要同步更新这里的打包说明。
