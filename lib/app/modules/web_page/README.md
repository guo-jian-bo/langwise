# web_page 模块使用文档

## 1. 模块简介

`web_page` 模块用于在 App 内嵌打开 Web 页面，并提供 Web 与 App 的交互能力。

这个模块的核心能力包括：

- 在 App 内使用 `InAppWebView` 打开网页
- 自动展示网页标题
- 提供关闭、后退、前进、刷新等基础导航能力
- 支持 Web 通过 JS 调用 App 能力
- 支持 App 根据 Web 指令动态修改页面主题和 AppBar 样式

注意：

- 在 `macOS / iOS / Android` 等端，使用的是内嵌 WebView 页面
- 在 `Windows` 端，`WebViewUtils.openWebView()` 会直接调用系统浏览器打开链接，不走内嵌页面

---

## 2. 目录说明

当前模块目录结构如下：

```text
lib/app/modules/web_page/
├── bindings/
│   └── web_page_binding.dart
├── codes/
│   ├── web_handler_code.dart
│   └── web_param_code.dart
├── controllers/
│   └── web_page_controller.dart
├── models/
│   └── web_result.dart
├── views/
│   └── web_page_view.dart
└── README.md
```

各文件职责如下：

### 2.1 `codes/web_handler_code.dart`

定义 Web 调用 App 时可用的 handler code 常量。

包括：

- `lw_appHandler`：统一的 JS Handler 名称
- `lw_getToken`：获取 token
- `lw_getUserData`：获取用户信息
- `lw_setTheme`：设置页面主题
- `lw_getSafeAreaInsets`：获取安全区
- `lw_setAppBarStyle`：设置 AppBar 样式
- `lw_reload`：刷新当前网页
- `lw_closeWebPage`：关闭页面
- `lw_goForward`：前进
- `lw_goBack`：后退
- `lw_getHistory`：获取历史记录
- `lw_stopLoading`：停止加载
- `lw_loadUrl`：加载新 URL
- `lw_openAppUserPage`：打开 App 内用户页面

### 2.2 `codes/web_param_code.dart`

定义 JS 与 App 交互时的参数 key 常量。

常用字段包括：

- `code`：本次调用的指令编码
- `params`：指令参数对象
- `url`：目标网页链接
- `theme`：主题参数
- `appBarTitleColor`：标题文字颜色
- `hideAppBar`：是否隐藏顶部栏
- `hideAppBarLoadProgress`：是否隐藏加载进度条
- `appBarLoadProgressColor`：加载进度条颜色
- `appBarIconColor`：顶部图标颜色
- `routeCode`：App 内页面路由编码
- `routeParams`：App 内页面路由参数

### 2.3 `controllers/web_page_controller.dart`

控制器，负责：

- 接收页面参数
- 处理 Web 发起的 JS 调用
- 控制 WebView 导航
- 管理标题、进度条、前进后退状态
- 动态修改页面样式

### 2.4 `views/web_page_view.dart`

页面视图，负责：

- 渲染顶部 AppBar
- 渲染加载进度条
- 构建 `InAppWebView`
- 注册 JS Handler `lw_appHandler`

### 2.5 `bindings/web_page_binding.dart`

通过 GetX 注入 `WebPageController`。

---

## 3. 页面表现与默认行为

这个页面打开后，默认行为如下：

- 顶部显示自定义 AppBar
- 标题取自网页的 `title`
- 左侧提供关闭、后退、前进、刷新按钮
- 顶部下方显示加载进度条
- 页面主体为 `InAppWebView`

控制器会实时维护以下状态：

- `url`：当前加载的网页地址
- `webTitle`：网页标题
- `loadProgress`：加载进度
- `canGoBack`：是否可后退
- `canGoForward`：是否可前进
- `backgroundColor`：页面背景色
- `appBarTitleColor`：标题颜色
- `appBarIconColor`：图标颜色
- `hideAppBar`：是否隐藏顶部栏
- `hideAppBarLoadProgress`：是否隐藏进度条

说明：

- `hideAppBarLoadProgress = true` 时，会隐藏顶部进度条
- 当前 `view` 中已经使用了进度条隐藏逻辑
- `hideAppBar` 字段在控制器中支持设置，但当前页面视图没有真正根据该值隐藏整个 AppBar，如果后续需要完全隐藏顶部栏，还需要补充 UI 判断逻辑

---

## 4. App 侧如何打开这个页面

### 4.1 推荐方式：使用工具类

项目中已经提供了统一工具：

```dart
await WebViewUtils.openWebView(
  url: "https://example.com",
);
```

其内部逻辑：

- Windows：使用系统浏览器打开
- 其他平台：通过 `Routes.WEB_PAGE` 打开内嵌 WebView 页面

### 4.2 实际传参格式

该页面启动时依赖 `Get.arguments["url"]`：

```dart
{
  "url": "https://example.com"
}
```

如果 `url` 为空，则页面主体不会加载网页内容。

### 4.3 直接打开页面

如果你不想走工具类，也可以直接导航到该页面：

```dart
await TagRoutes.toNamed(
  Routes.WEB_PAGE,
  arguments: {
    "url": "https://example.com",
  },
);
```

### 4.4 页面静态打开方法

`WebPageView` 也提供了静态方法：

```dart
await WebPageView.to(
  tag: "some_tag",
  arguments: {
    "url": "https://example.com",
  },
);
```

通常业务侧更建议统一走：

```dart
WebViewUtils.openWebView(...)
```

---

## 5. Web 页面如何与 App 交互

### 5.1 JS Handler 名称

Web 页面通过以下 handler 名称调用 App：

```text
lw_appHandler
```

这是由 `WebHandlerCode.appHandler` 定义的统一入口。

### 5.2 调用格式

Web 侧需要调用：

```javascript
window.flutter_inappwebview.callHandler("lw_appHandler", {
  code: "lw_getToken",
  params: {}
});
```

App 侧会解析：

- `code`：操作类型
- `params`：当前操作所需参数

### 5.3 返回值格式

所有调用统一返回：

```json
{
  "code": 200,
  "message": "ok",
  "data": {}
}
```

字段说明：

- `code`：状态码，`200` 表示成功，其他值表示失败
- `message`：结果说明
- `data`：返回的数据体，可为空

---

## 6. Web 调用 App 能力列表

下面列出当前控制器已经支持的全部能力。

### 6.1 获取 token

#### 调用

```javascript
const res = await window.flutter_inappwebview.callHandler("lw_appHandler", {
  code: "lw_getToken",
  params: {}
});
```

#### 返回

成功时：

```json
{
  "code": 200,
  "message": "ok",
  "data": "user_token"
}
```

失败时：

```json
{
  "code": 1,
  "message": "token为空",
  "data": null
}
```

---

### 6.2 获取用户信息

#### 调用

```javascript
const res = await window.flutter_inappwebview.callHandler("lw_appHandler", {
  code: "lw_getUserData",
  params: {}
});
```

#### 返回

`data` 为当前登录用户信息的 JSON。

---

### 6.3 获取安全区

用于获取设备安全区信息，方便 Web 页面适配顶部刘海和底部安全区域。

#### 调用

```javascript
const res = await window.flutter_inappwebview.callHandler("lw_appHandler", {
  code: "lw_getSafeAreaInsets",
  params: {}
});
```

#### 返回示例

```json
{
  "code": 200,
  "message": "ok",
  "data": {
    "top": 44,
    "bottom": 34,
    "left": 0,
    "right": 0
  }
}
```

---

### 6.4 设置页面主题

用于设置页面背景色。支持两类值：

- 直接传颜色值：如 `#FFFFFF`、`rgba(0,0,0,0.5)`
- 传主题名：如 `dark`、`light`

当传入 `dark` / `light` 等主题名时，如果没有额外传标题色和图标色，控制器会自动从主题中取适配色。

#### 调用

```javascript
const res = await window.flutter_inappwebview.callHandler("lw_appHandler", {
  code: "lw_setTheme",
  params: {
    theme: "dark"
  }
});
```

或：

```javascript
const res = await window.flutter_inappwebview.callHandler("lw_appHandler", {
  code: "lw_setTheme",
  params: {
    theme: "#101010"
  }
});
```

#### 参数

- `theme`：必填，主题名或颜色值
- `appBarTitleColor`：可选，标题文字颜色
- `appBarIconColor`：可选，顶部图标颜色

注意：

- 这里真正使用的参数 key 是 `theme`
- 控制器注释里有一处提到 `backgroundColor`，但实际代码读取的是 `theme`

---

### 6.5 设置 AppBar 样式

用于调整顶部栏的显示和颜色。

#### 调用

```javascript
const res = await window.flutter_inappwebview.callHandler("lw_appHandler", {
  code: "lw_setAppBarStyle",
  params: {
    hideAppBarLoadProgress: true,
    appBarTitleColor: "#FFFFFF",
    appBarLoadProgressColor: "#38BDF8",
    appBarIconColor: "#FFFFFF"
  }
});
```

#### 参数

- `hideAppBar`：可选，`bool`
- `hideAppBarLoadProgress`：可选，`bool`
- `appBarTitleColor`：可选，标题颜色
- `appBarLoadProgressColor`：可选，进度条颜色
- `appBarIconColor`：可选，图标颜色

说明：

- `hideAppBarLoadProgress = true` 时隐藏进度条
- `hideAppBar` 虽然可设置，但当前视图层尚未真正根据该值隐藏整个 AppBar

---

### 6.6 刷新当前网页

#### 调用

```javascript
await window.flutter_inappwebview.callHandler("lw_appHandler", {
  code: "lw_reload",
  params: {}
});
```

---

### 6.7 关闭网页页面

#### 调用

```javascript
await window.flutter_inappwebview.callHandler("lw_appHandler", {
  code: "lw_closeWebPage",
  params: {}
});
```

执行后会调用 `Get.back()` 关闭当前页面。

---

### 6.8 网页前进

#### 调用

```javascript
await window.flutter_inappwebview.callHandler("lw_appHandler", {
  code: "lw_goForward",
  params: {}
});
```

---

### 6.9 网页后退

#### 调用

```javascript
await window.flutter_inappwebview.callHandler("lw_appHandler", {
  code: "lw_goBack",
  params: {}
});
```

---

### 6.10 获取历史记录

#### 调用

```javascript
const res = await window.flutter_inappwebview.callHandler("lw_appHandler", {
  code: "lw_getHistory",
  params: {}
});
```

#### 返回

`data` 为 `WebHistory.toJson()` 的结果，结构由 `flutter_inappwebview` 决定。

---

### 6.11 停止加载

#### 调用

```javascript
await window.flutter_inappwebview.callHandler("lw_appHandler", {
  code: "lw_stopLoading",
  params: {}
});
```

---

### 6.12 加载新 URL

#### 调用

```javascript
await window.flutter_inappwebview.callHandler("lw_appHandler", {
  code: "lw_loadUrl",
  params: {
    url: "https://example.com/next"
  }
});
```

#### 参数

- `url`：必填，目标地址

---

### 6.13 打开 App 内用户页面

用于让 Web 页面跳转到 App 内某个业务页面。

#### 调用

```javascript
await window.flutter_inappwebview.callHandler("lw_appHandler", {
  code: "lw_openAppUserPage",
  params: {
    routeCode: "some_route_code",
    routeParams: {
      id: 123
    }
  }
});
```

#### 参数

- `routeCode`：必填，业务页面编码
- `routeParams`：可选，页面参数对象

#### 处理逻辑

App 内部会调用：

```dart
JumpPageUtils.jumpUserPages(routeCode, routeParams);
```

所以 `routeCode` 需要符合项目内部页面跳转约定。

---

## 7. Web 调用时的统一封装建议

建议 H5 侧封装一个统一方法，避免重复写 `callHandler`。

示例：

```javascript
async function callApp(code, params = {}) {
  if (
    !window.flutter_inappwebview ||
    typeof window.flutter_inappwebview.callHandler !== "function"
  ) {
    return {
      code: 0,
      message: "当前不在App WebView环境中",
      data: null
    };
  }

  return await window.flutter_inappwebview.callHandler("lw_appHandler", {
    code,
    params
  });
}
```

然后按下面方式使用：

```javascript
const tokenRes = await callApp("lw_getToken");

const safeAreaRes = await callApp("lw_getSafeAreaInsets");

await callApp("lw_setAppBarStyle", {
  appBarTitleColor: "#FFFFFF",
  appBarIconColor: "#FFFFFF",
  hideAppBarLoadProgress: true
});
```

---

## 8. App 与 Web 的典型配合方式

### 场景 1：业务侧打开 H5 活动页

Flutter：

```dart
await WebViewUtils.openWebView(
  url: "https://activity.example.com?id=1001",
);
```

H5：

- 页面加载后读取 token
- 获取安全区做布局适配
- 根据页面风格设置标题色和图标色

### 场景 2：H5 主动控制 App UI

H5 可以在进入页面后执行：

```javascript
await callApp("lw_setTheme", {
  theme: "#111111"
});

await callApp("lw_setAppBarStyle", {
  appBarTitleColor: "#FFFFFF",
  appBarIconColor: "#FFFFFF",
  appBarLoadProgressColor: "#00D2FF"
});
```

### 场景 3：H5 跳转到 App 内业务页

```javascript
await callApp("lw_openAppUserPage", {
  routeCode: "user_profile",
  routeParams: {
    userId: "10086"
  }
});
```

---

## 9. 交互协议约定

### 9.1 JS 调用入参格式

统一格式如下：

```json
{
  "code": "lw_xxx",
  "params": {}
}
```

### 9.2 返回格式

统一格式如下：

```json
{
  "code": 200,
  "message": "ok",
  "data": {}
}
```

### 9.3 常见失败场景

#### 缺少参数

例如未传 `code` 或缺少 `params.url`：

```json
{
  "code": 0,
  "message": "url不能为空",
  "data": null
}
```

#### 非 App WebView 环境

如果普通浏览器中没有注入 `window.flutter_inappwebview`，则无法直接调用 App Handler。

建议 H5 做环境判断再调用。

---

## 10. 开发注意事项

### 10.1 `hideAppBar` 当前未完全生效

控制器支持通过 `setAppBarStyle` 设置 `hideAppBar`，但视图层当前没有：

- 根据 `hideAppBar` 隐藏 `_buildAppBar`
- 重新计算顶部布局

如果业务确实需要 H5 完整隐藏顶部栏，需要继续补充 `web_page_view.dart`。

### 10.2 页面标题来自网页 title

当前标题展示依赖：

```dart
onTitleChanged
```

所以如果 H5 想正确显示标题，需要设置页面 `<title>`。

### 10.3 前进后退状态依赖 WebView 历史记录

控制器会在以下时机更新前进后退能力：

- `onLoadStop`
- `onUpdateVisitedHistory`

### 10.4 返回数据需由 H5 自行判空

例如：

- token 可能为空
- 用户信息可能依赖登录状态
- `getHistory` 返回结构受插件版本影响

建议 H5 统一做容错处理。

---

## 11. 推荐接入步骤

如果你要接入一个新的 H5 页面，建议按以下顺序：

1. Flutter 侧使用 `WebViewUtils.openWebView(url: ...)` 打开页面
2. H5 侧封装 `callApp(code, params)` 方法
3. 页面初始化时调用 `lw_getToken` 和 `lw_getSafeAreaInsets`
4. 根据页面风格调用 `lw_setTheme` 和 `lw_setAppBarStyle`
5. 如有业务跳转需求，再接入 `lw_openAppUserPage`

---

## 12. 最小可用示例

### Flutter 侧

```dart
await WebViewUtils.openWebView(
  url: "https://example.com/h5/page",
);
```

### H5 侧

```javascript
async function callApp(code, params = {}) {
  if (!window.flutter_inappwebview?.callHandler) {
    return { code: 0, message: "not in app", data: null };
  }
  return await window.flutter_inappwebview.callHandler("lw_appHandler", {
    code,
    params
  });
}

async function initPage() {
  const tokenRes = await callApp("lw_getToken");
  const safeAreaRes = await callApp("lw_getSafeAreaInsets");

  await callApp("lw_setTheme", {
    theme: "dark"
  });

  await callApp("lw_setAppBarStyle", {
    appBarTitleColor: "#FFFFFF",
    appBarIconColor: "#FFFFFF",
    hideAppBarLoadProgress: true
  });

  console.log(tokenRes, safeAreaRes);
}

initPage();
```

---

## 13. 总结

`web_page` 模块本质上是一个带原生导航栏能力的 App 内嵌 WebView 容器，并通过 `lw_appHandler` 暴露了一组可供 H5 调用的 App 能力。

对业务方来说，重点只需要记住两件事：

- Flutter 侧通过 `WebViewUtils.openWebView()` 打开页面
- H5 侧通过 `window.flutter_inappwebview.callHandler("lw_appHandler", {...})` 与 App 交互

如果后续还要扩展新的 JS 能力，建议同步更新：

- `web_handler_code.dart`
- `web_param_code.dart`
- `web_page_controller.dart`
- 本文档
