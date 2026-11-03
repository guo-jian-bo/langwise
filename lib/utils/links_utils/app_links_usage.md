# App Links 使用说明

## 1. 当前约定

- 自定义协议：`langwise://`
- Web 链接：`https://timelywise.cn`
- Dart 统一入口：`lib/utils/links_utils/app_links_utils.dart`

常用测试链接：

```text
langwise://openapp/page?code=test
langwise:///openapp/page?code=test
https://timelywise.cn/openapp/page?code=test
https://timelywise.cn/alipay?result=test
```

---

## 2. Android

### 怎么使用

- 已在 `android/app/src/main/AndroidManifest.xml` 配置了 `https://timelywise.cn/openapp`
- 已配置 `https://timelywise.cn/alipay`
- 已配置自定义协议 `langwise`
- `MainActivity` 已使用 `singleTop`

### 怎么测试

自定义协议：

```bash
adb shell am start -a android.intent.action.VIEW -d "langwise://openapp/page?code=test"
```

Web 链接：

```bash
adb shell am start -a android.intent.action.VIEW -d "https://timelywise.cn/openapp/page?code=test"
```

### 注意事项

- 如果想让 `https://` 直接拉起 App，需要服务端提供 `/.well-known/assetlinks.json`
- `assetlinks.json` 中的包名和签名必须与安装包一致

---

## 3. iOS

### 怎么使用

- 已在 `ios/Runner/Info.plist` 配置 `CFBundleURLTypes`
- 已支持 `langwise://`
- 已开启 `Associated Domains`

### 怎么测试

可直接在 Safari、备忘录、短信、邮件中点击：

```text
langwise://openapp/page?code=test
https://timelywise.cn/openapp/page?code=test
```

### 注意事项

- `langwise://` 只依赖 `CFBundleURLTypes`
- `https://` 还依赖 `Associated Domains` 和服务端 `apple-app-site-association`
- 如果网页没跳 App，优先检查 AASA 文件、域名和签名

---

## 4. macOS

### 怎么使用

- 已在 `macos/Runner/Info.plist` 配置 `CFBundleURLTypes`
- 已支持 `langwise://`
- 已在 entitlements 中配置 `applinks:timelywise.cn`

### 怎么测试

自定义协议：

```bash
open "langwise://openapp/page?code=test"
```

Web 链接：

```bash
open "https://timelywise.cn/openapp/page?code=test"
```

### 注意事项

- `https://` 同样依赖服务端 AASA 文件
- 如果只打开浏览器没有拉起 App，通常是 AASA、签名或域名配置问题

---

## 5. Windows

### 怎么使用

- 已在 `windows/runner/main.cpp` 接入 `app_links` Windows 转发逻辑
- 已在 `pubspec.yaml` 的 `msix_config` 中注册 `langwise` 和 `https`
- 已配置 `app_uri_handler_hosts: timelywise.cn`

### 怎么测试

自定义协议：

```text
langwise://openapp/page?code=test
```

Web 链接：

```text
https://timelywise.cn/openapp/page?code=test
```

### 注意事项

- `https://` 激活建议在安装版应用中测试
- `flutter run -d windows` 调试态不一定能验证完整效果
- 当前已支持将新链接转发给已打开的应用窗口

---

## 6. 服务端要求

### Android

需要提供：

```text
https://timelywise.cn/.well-known/assetlinks.json
```

### iOS / macOS

需要提供：

```text
https://timelywise.cn/apple-app-site-association
```

或：

```text
https://timelywise.cn/.well-known/apple-app-site-association
```

### 注意事项

- 必须走 `https`
- 返回内容要是原始 JSON
- 域名、包名、Bundle ID、签名都要和正式包一致

---

## 7. Dart 侧说明

项目使用 `AppLinksUtils.initAppLinks()` 统一处理链接：

- 冷启动：`getInitialLink()`
- 已启动：`uriLinkStream`

当前主要处理：

- `/alipay`
- `/openapp`
- `/openapp/page`
- `/payment/callback`

另外已兼容这两种写法：

```text
langwise://openapp/page?code=test
langwise:///openapp/page?code=test
```
