## appChannelUtils.js 使用稳定提示词（H5 ↔ Flutter App 通道交互）

你将要在 Vue/H5 中通过 `flutter_inappwebview.callHandler` 与 Flutter App 通信。项目已将通信协议统一封装在：

- [appChannelUtils.js](file:///Users/langwise/Desktop/ns/vue_project/langwise_web/src/utils/appChannelUtils.js)

请严格遵循本文提示词与协议字段，不要在页面中手写通道 code/参数名，统一调用封装函数或使用常量。

---

### 1) 通道基础约定（必须遵守）

- **Handler 名称固定**：`lw_appHandler`（通过 `getAppHandlerName()` 获取）
- **方法 code 必须带前缀**：`lw_`（例如 `lw_getToken`、`lw_reload`），对应 `appHandlerCode`
- **参数名必须使用协议字段**：对应 `appHandlerParamCode`，不要自造 key
- **仅在 App WebView 环境可用**：`isAppChannelAvailable()` 为 `true` 才能真正调用；否则封装会 `resolve(null)`

---

### 2) 通道统一调用格式（sendAppChannel）

`sendAppChannel` 入参（payload）结构：

- `code: string`：必填，使用 `appHandlerCode.xxx` 的值，例如 `appHandlerCode.getToken`
- `params?: object`：可选，参数对象；对象的 key 必须来自 `appHandlerParamCode`
- `response?: (res: any) => any`：可选，自定义响应转换器；不传则原样返回

返回值（Promise）：

- **正常返回**：App 返回 `{ code: 200, message: "ok", data: any }`（以 Flutter 实现为准）
- **通道不可用/未传 code**：返回 `null`
- **调用异常**：返回 `{ code: -1, message: string, data: null }`

判定与取值工具：

- `isAppChannelSuccess(res)`：判断 `res.code === 200`
- `getAppChannelData(res, defaultValue)`：成功返回 `res.data`，失败返回默认值

---

### 3) 协议字段说明（appHandlerCode）

以下为 H5 可调用的 App 指令（`code`）及其用途与参数要求：

#### 3.1 无参数指令

- `appHandlerCode.getToken`：获取 App token
  - params：无
  - 推荐调用：`getAppToken()`
  - 返回：`string | null`（内部已用 `getAppChannelData` 提取）

- `appHandlerCode.getDeviceId`：获取 DeviceId
  - params：无
  - Flutter 端已支持：`lw_getDeviceId`
  - H5 侧建议补充封装：`getAppDeviceId()`
  - 返回：`string | null`（内部建议用 `getAppChannelData` 提取）
  - 若 `src/utils/appChannelUtils.js` 尚未定义该能力，可按现有模式补齐（示例片段）：

```js
// 1) appHandlerCode 增加
getDeviceId: `${appHandlerPrefix}getDeviceId`,

// 2) 封装函数增加
export const getAppDeviceId = async () => {
  return sendAppChannel({
    code: appHandlerCode.getDeviceId,
    response: (res) => getAppChannelData(res, null),
  })
}
```

- `appHandlerCode.getPlatform`：获取当前平台枚举
  - params：无
  - Flutter 端已支持：`lw_getPlatform`
  - H5 侧建议补充封装：`getAppPlatform()`
  - 返回：`string | null`
  - 返回值枚举：`ANDROID`、`IOS`、`MACOS`、`WINDOWS`、`LINUX`、`FUCHSIA`、`OTHER`
  - 若 `src/utils/appChannelUtils.js` 尚未定义该能力，可按现有模式补齐（示例片段）：

```js
// 1) appHandlerCode 增加
getPlatform: `${appHandlerPrefix}getPlatform`,

// 2) 封装函数增加
export const getAppPlatform = async () => {
  return sendAppChannel({
    code: appHandlerCode.getPlatform,
    response: (res) => getAppChannelData(res, null),
  })
}
```

- `appHandlerCode.requestAlbumPermission`：申请相册读取权限
  - params：无
  - Flutter 端已支持：`lw_requestAlbumPermission`
  - H5 侧建议补充封装：`requestAppAlbumPermission()`
  - 返回：`boolean | false`
  - 说明：内部复用 App 的 `PermissionUtils.photos(context)`；已授权返回 `true`，未授权或用户取消返回 `false`
  - 若 `src/utils/appChannelUtils.js` 尚未定义该能力，可按现有模式补齐（示例片段）：

```js
// 1) appHandlerCode 增加
requestAlbumPermission: `${appHandlerPrefix}requestAlbumPermission`,

// 2) 封装函数增加
export const requestAppAlbumPermission = async () => {
  return sendAppChannel({
    code: appHandlerCode.requestAlbumPermission,
    response: (res) => getAppChannelData(res, false),
  })
}
```

- `appHandlerCode.requestCameraPermission`：申请相机权限
  - params：无
  - Flutter 端已支持：`lw_requestCameraPermission`
  - H5 侧建议补充封装：`requestAppCameraPermission()`
  - 返回：`boolean | false`
  - 说明：内部复用 App 的 `PermissionUtils.camera(context)`；已授权返回 `true`，未授权或用户取消返回 `false`
  - 若 `src/utils/appChannelUtils.js` 尚未定义该能力，可按现有模式补齐（示例片段）：

```js
// 1) appHandlerCode 增加
requestCameraPermission: `${appHandlerPrefix}requestCameraPermission`,

// 2) 封装函数增加
export const requestAppCameraPermission = async () => {
  return sendAppChannel({
    code: appHandlerCode.requestCameraPermission,
    response: (res) => getAppChannelData(res, false),
  })
}
```

- `appHandlerCode.takePhoto`：调起 App 拍照并回传图片信息
  - params：无
  - Flutter 端已支持：`lw_takePhoto`
  - H5 侧建议补充封装：`takeAppPhoto()`
  - 返回：`Object | null`
  - 说明：App 内部会先执行 `PermissionUtils.camera(context)` 判断相机权限，授权后再调用 `ImagePickerUtils.takePhotos(context: context, checkCameraPermission: false)` 调起拍照
  - 成功返回示例：

```js
{
  path: '/local/path/demo.jpg',
  url: 'file:///local/path/demo.jpg',
  name: 'demo.jpg',
  size: 123456,
}
```

  - 若 `src/utils/appChannelUtils.js` 尚未定义该能力，可按现有模式补齐（示例片段）：

```js
// 1) appHandlerCode 增加
takePhoto: `${appHandlerPrefix}takePhoto`,

// 2) 封装函数增加
export const takeAppPhoto = async () => {
  return sendAppChannel({
    code: appHandlerCode.takePhoto,
    response: (res) => getAppChannelData(res, null),
  })
}
```

- `appHandlerCode.getUserData`：获取用户信息
  - params：无
  - 推荐调用：`getAppUserData()`
  - 返回：`Object | null`（通常为 `{ code, message, data }` 或 App 自定义对象）

- `appHandlerCode.getSafeAreaInsets`：获取安全区
  - params：无
  - 推荐调用：`getAppSafeAreaInsets()`
  - 返回：`Object | null`（如 `{ top, bottom, left, right }`，以 App 为准）

- `appHandlerCode.reload`：刷新 WebView
  - params：无
  - 推荐调用：`reloadAppWebView()`

- `appHandlerCode.closeWebPage`：关闭 WebView 页面
  - params：无
  - 推荐调用：`closeAppWebPage()`

- `appHandlerCode.goForward`：WebView 前进
  - params：无
  - 推荐调用：`goAppForward()`

- `appHandlerCode.goBack`：WebView 后退
  - params：无
  - 推荐调用：`goAppBack()`

- `appHandlerCode.getHistory`：获取 WebView 历史记录
  - params：无
  - 推荐调用：`getAppHistory()`

- `appHandlerCode.stopLoading`：停止加载
  - params：无
  - 推荐调用：`stopAppLoading()`

- `appHandlerCode.openExternalBrowserCurrentUrl`：用外部浏览器打开当前 WebView 的 URL
  - params：无
  - Flutter 端已支持：`lw_openExternalBrowserCurrentUrl`
  - H5 侧建议补充封装：`openAppExternalBrowserCurrentUrl()`

#### 3.2 有参数指令

- `appHandlerCode.setTheme`：设置页面主题
  - params：
    - `[appHandlerParamCode.theme]: string`：主题，支持 `dark`、`light` 或自定义颜色（16 进制 / rgba）
    - 可选扩展：`appBarTitleColor`、`appBarIconColor`
  - 推荐调用：`setAppTheme(theme, extraParams)`

- `appHandlerCode.setAppBarStyle`：设置 AppBar 样式
  - params（全部使用 `appHandlerParamCode` 的 key）：
    - `appBarTitleColor: string`：标题文字颜色（16 进制 / rgba）
    - `hideAppBar: boolean`：是否隐藏 AppBar，默认 `false`
    - `hideAppBarLoadProgress: boolean`：是否隐藏加载进度，默认 `true`
    - `appBarLoadProgressColor: string`：加载进度颜色，默认 `#38BDF8`
    - `appBarIconColor: string`：按钮/图标颜色，默认 `#9EA4AC`
  - 推荐调用：`setAppBarStyle(params)`

- `appHandlerCode.loadUrl`：加载指定 URL
  - params：
    - `[appHandlerParamCode.url]: string`：目标链接
  - 推荐调用：`loadAppUrl(url)`

- `appHandlerCode.openAppUserPage`：打开 App 内页面（路由跳转）
  - params：
    - `[appHandlerParamCode.routeCode]: string`：路由 code（由 App 约定，例如 `message_detail`）
    - `[appHandlerParamCode.routeParams]: object`：路由参数（任意 JSON）
    - `[appHandlerParamCode.closeWebPage]: boolean`：是否关闭当前 web 页面，默认 `false`
  - 推荐调用：`openAppUserPage({ routeCode, routeParams, closeWebPage })`

- `appHandlerCode.showNoticeDialog`：显示公告弹窗
  - params：
    - `[appHandlerParamCode.routeCode]: string`：路由/场景 code（由 App 约定，例如 `notice`）
    - `[appHandlerParamCode.routeParams]: object`：公告数据（由 App 约定字段）
  - 推荐调用：`showAppNoticeDialog({ routeCode, routeParams })`

- `appHandlerCode.openExternalBrowser`：用外部浏览器打开指定 URL
  - params：
    - `[appHandlerParamCode.url]: string`：目标链接，不能为空
  - Flutter 端已支持：`lw_openExternalBrowser`
  - H5 侧建议补充封装：`openAppExternalBrowser(url)`

---

### 4) 参数字段说明（appHandlerParamCode）

以下是通道 params 中允许出现的 key（必须使用这些 key）：

- `url: string`：加载 URL 的目标地址
- `appBarTitleColor: string`：AppBar 标题文字颜色（16 进制 / rgba）
- `hideAppBar: boolean`：是否隐藏 AppBar
- `hideAppBarLoadProgress: boolean`：是否隐藏加载进度
- `appBarLoadProgressColor: string`：加载进度颜色
- `appBarIconColor: string`：AppBar 图标/按钮颜色
- `theme: string`：页面主题（`dark` / `light` / 自定义颜色）
- `routeCode: string`：App 路由 code（业务侧约定）
- `routeParams: object`：路由参数（任意 JSON）
- `closeWebPage: boolean`：跳转前是否关闭当前 web 页面

说明：`openExternalBrowser` 复用已有 `url` 参数字段，不新增新的 params key。

---

### 5) 推荐使用方式（直接调用封装函数）

```js
  import {
    isAppChannelAvailable,
    getAppToken,
    getAppDeviceId,
    getAppPlatform,
    requestAppAlbumPermission,
    requestAppCameraPermission,
    takeAppPhoto,
    setAppTheme,
    setAppBarStyle,
    loadAppUrl,
    openAppUserPage,
  } from '@/utils/appChannelUtils'

const init = async () => {
  if (!isAppChannelAvailable()) return

  const token = await getAppToken()
  const deviceId = await getAppDeviceId()
  const platform = await getAppPlatform()
  const hasAlbumPermission = await requestAppAlbumPermission()
  const hasCameraPermission = await requestAppCameraPermission()
  const photo = await takeAppPhoto()
  await setAppTheme('dark', {
    appBarTitleColor: '#FFFFFF',
    appBarIconColor: '#FFFFFF',
  })
  await setAppBarStyle({
    appBarTitleColor: '#FFFFFF',
    hideAppBar: false,
    hideAppBarLoadProgress: false,
    appBarLoadProgressColor: '#38BDF8',
    appBarIconColor: '#FFFFFF',
  })
  await loadAppUrl('https://example.com')
  await openAppUserPage({ routeCode: 'message_detail', routeParams: { id: '123' } })
}
```

---

## 6) 可直接复用的“稳定提示词”（给 AI/同事的交接模板）

将下面提示词原样粘贴给 AI，让其基于现有封装写页面逻辑/调用代码（不要改协议字段）：

---

你是一个资深前端工程师，需要在 Vue 项目中通过 H5 ↔ Flutter 的 JS Bridge 与 App 交互。项目已封装好通道工具文件 `src/utils/appChannelUtils.js`，禁止在页面里直接调用 `window.flutter_inappwebview.callHandler`，也禁止手写通道 code 与参数名。

请遵循以下硬约束输出代码：

1. Handler 名固定为 `lw_appHandler`（通过工具函数获取），所有指令 code 必须带 `lw_` 前缀。
2. 所有调用必须使用 `appHandlerCode` 中的 code 值，不允许拼字符串。
3. 所有 params 的 key 必须来自 `appHandlerParamCode`（如 `theme`、`url`、`routeCode`、`routeParams` 等），不允许自造字段名。
4. 调用前先用 `isAppChannelAvailable()` 判断环境；不可用时函数应安全降级（不报错）。
5. 需要解析 App 返回时，使用 `isAppChannelSuccess` 和 `getAppChannelData`，避免直接假设 `res.data` 一定存在。
6. 目标：实现以下交互（按需选择）：获取 token（getAppToken）、获取 DeviceId（getAppDeviceId）、获取当前平台（getAppPlatform）、申请相册权限（requestAppAlbumPermission）、申请相机权限（requestAppCameraPermission）、调起拍照（takeAppPhoto）、设置主题（setAppTheme）、设置 AppBar（setAppBarStyle）、加载 URL（loadAppUrl）、打开 App 页面（openAppUserPage）、显示公告弹窗（showAppNoticeDialog）、用外部浏览器打开指定 URL（openExternalBrowser）、用外部浏览器打开当前 WebView URL（openExternalBrowserCurrentUrl）。
7. 如果要使用 `getDeviceId` / `getPlatform` / `requestAlbumPermission` / `requestCameraPermission` / `takePhoto` / `openExternalBrowser` / `openExternalBrowserCurrentUrl`，先在 `src/utils/appChannelUtils.js` 中按现有模式补齐对应的 `appHandlerCode` 常量与封装函数（如 `getAppDeviceId` / `getAppPlatform` / `requestAppAlbumPermission` / `requestAppCameraPermission` / `takeAppPhoto` / `openAppExternalBrowser` / `openAppExternalBrowserCurrentUrl`），再在页面中通过封装调用；不要在业务页面直接写 `callHandler`。

请给出：

- 需要 import 的函数列表
- 示例调用代码（async/await）
- 关键参数含义说明（theme/appBarTitleColor/url/routeCode/routeParams/closeWebPage 等）

---
