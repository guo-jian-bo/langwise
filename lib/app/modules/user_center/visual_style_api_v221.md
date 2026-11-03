# 2.2.1 风格设置 API 文档

本文用于前端接入 2.2.1 的风格设置页、浏览弹窗和做题混搭逻辑。

对应接口：

- `POST /team/config/style/edit`：保存当前风格设置
- `GET /team/style/status/list`：读取当前风格设置和风格目录

参考需求文档：[visual_preference.md](file:///Users/tanrong/Desktop/git/docs/visual/visual_preference.md)

## 一、先说结论

2.2.1 起，风格设置按“视觉偏好”接入，不再按订阅产品接入。

前端一定要注意：

1. 不要再根据订阅相关字段决定风格是否可选、是否可用、是否显示购买态。
2. 不要再根据是否购买、是否过期、是否买到视频档位做任何前端拦截。
3. 风格是否可用，只看风格自身状态字段：
   - `styleItems[].status`
   - `styleItems[].imageStatus`
   - `styleItems[].videoStatus`
   - `styleItems[].statusHint`
4. 当前用户偏好只看这 4 个核心字段：
   - `mediaModeUse`
   - `mainStyleUse`
   - `isMediaMix`
   - `imageStyleUses`

## 二、需求字段和接口字段映射

`visual_preference.md` 中的字段与当前接口映射如下：

| 需求字段 | 含义 | 接口字段 |
|---|---|---|
| `mode` | 图片 / 视频模式 | `mediaModeUse` |
| `primaryStyleId` | 主风格 | `mainStyleUse` |
| `mixEnabled` | 是否混搭 | `isMediaMix` |
| `mixStyleIds` | 混搭风格集合 | `imageStyleUses` |
| 画风目录 `id` | 风格编码 | `styleItems[].style` |
| 画风外显名 | 中文名称 | `styleItems[].styleTitle` |
| 画风说明 | 说明文案 | `styleItems[].styleDesc` |
| 未上架提示 `releaseHint` | 即将开放提示 | `styleItems[].statusHint` |

说明：

- `mediaModeUse`：`0=图片`，`1=视频`
- `mainStyleUse`：主风格编码
- `isMediaMix`：是否开启混搭
- `imageStyleUses`：当前可参与混搭的风格编码列表，前端可直接理解为 `mixStyleIds`

## 三、读接口

### 1. 接口

`GET /team/style/status/list`

用途：

- 页面初始化读取当前视觉偏好
- 读取风格目录
- 读取新版 `explain`
- 获取最终可展示的风格状态

### 2. 前端真正要用的返回字段

#### 顶层字段

| 字段 | 类型 | 用途 | 前端使用建议 |
|---|---|---|---|
| `explain` | `String` | 页面说明文案 | 直接展示 |
| `mediaModeUse` | `Integer` | 当前视觉模式 | `0=图片`，`1=视频` |
| `mainStyleUse` | `String` | 当前主风格 | 主风格单选值 |
| `isMediaMix` | `Boolean` | 当前是否开启混搭 | 混搭开关值 |
| `imageStyleUses` | `List<String>` | 当前混搭风格列表 | 混搭勾选值 |
| `styleItems` | `List<TeamMediaStyleItemDTO>` | 风格目录 | 风格卡片列表 |

#### `styleItems[]` 字段

| 字段 | 类型 | 用途 | 前端使用建议 |
|---|---|---|---|
| `uid` | `Long` | 风格 uid | 可忽略 |
| `style` | `String` | 风格编码 | 作为唯一 id 使用 |
| `styleTitle` | `List<LanguageText>` | 风格标题 | 渲染外显名 |
| `styleDesc` | `List<LanguageText>` | 风格说明 | 渲染说明文案 |
| `image` | `SubContentImageDTO` | 图片预览 | 图片模式卡片预览 |
| `video` | `ContentCardVideoDTO` | 视频预览 | 视频模式卡片预览 |
| `order` | `Double` | 排序值 | 目录排序可直接用后端顺序 |
| `status` | `Integer` | 通用状态 | 可用于卡片整体状态 |
| `imageStatus` | `Integer` | 图片模式状态 | 图片模式是否可选看它 |
| `videoStatus` | `Integer` | 视频模式状态 | 视频模式是否可选看它 |
| `statusHint` | `String` | 状态提示 | 即将开放 / 不可用提示文案 |
| `access` | `AccessEnum` | 上下架态补充信息 | 可选使用，不建议作为唯一判断条件 |

状态值约定：

- `1`：开放
- `2`：即将开放
- `3`：未开放 / 下架态

### 3. 读接口里不要再判断的字段

以下字段属于历史订阅模型兼容返回，2.2.1 前端不要再用它们控制 UI、按钮、禁用态或购买态：

#### 顶层忽略字段

- `paymentStatus`
- `paymentHint`
- `activateCount`
- `subscribeCount`
- `totalFee`
- `billingDate`
- `imageStyleCodes`

#### `styleItems[]` 忽略字段

- `imageSubRights`
- `videoSubRights`
- `imageForbidUnsubscribed`
- `videoForbidUnsubscribed`
- `imageRights`
- `videoRights`
- `unsubscribed`
- `expired`

一句话：**这些订阅字段在 2.2.1 页面里全部不要判断。**

### 4. 当前后端的兜底规则

前端建议直接以后端返回为准，不要本地硬编码默认值。

当前服务端规则：

1. `mainStyleUse` 为空时，后端会回退到 `imageStyleUses` 的第一个。
2. `isMediaMix` 为空时，后端当前回退为 `false`。
3. 不要前端自己写死成需求文档里的 `3d / true / 全部已上架`，以接口实际返回为准。

## 四、写接口

### 1. 接口

`POST /team/config/style/edit`

用途：

- 保存当前视觉模式
- 保存主风格
- 保存混搭开关
- 保存混搭风格列表

### 2. 请求体

```json
{
  "mediaModeUse": 1,
  "mainStyleUse": "3d",
  "isMediaMix": true,
  "imageStyleUses": ["3d", "photo", "cute", "ghibli"]
}
```

### 3. 请求字段说明

| 字段 | 类型 | 是否必填 | 用途 | 说明 |
|---|---|---|---|---|
| `mediaModeUse` | `Integer` | 是 | 当前视觉模式 | `0=图片`，`1=视频` |
| `mainStyleUse` | `String` | 建议必传 | 当前主风格 | 必须落在 `imageStyleUses` 内，否则后端会自动回退 |
| `isMediaMix` | `Boolean` | 建议必传 | 是否开启混搭 | 混搭开关 |
| `imageStyleUses` | `List<String>` | 是 | 当前混搭风格集合 | 也是当前风格配置主集合 |

### 4. 写接口规则

1. 这条接口现在只做“设置保存”，不做订阅、扣费、续费。
2. 这条接口已经去掉权益拦截，不再校验：
   - 买没买
   - 是否过期
   - 是否买到视频档位
3. 这条接口仍会校验风格本身是否存在、是否开放。
4. `mainStyleUse` 如果不在 `imageStyleUses` 中，后端会自动回退：
   - 先尝试保留旧值
   - 再回退到 `imageStyleUses` 第一个
5. `imageStyleUses` 传空时，表示清空当前成员的风格设置。

### 5. 写接口返回怎么用

接口返回体类型也是 `TeamMediaStyleDTO`，但前端建议这样使用：

1. 保存成功后，页面局部状态可直接用本次提交值更新：
   - `mediaModeUse`
   - `mainStyleUse`
   - `isMediaMix`
   - `imageStyleUses`
2. 如果页面需要：
   - 最新的 `explain`
   - 最新的完整 `styleItems`
   - 统一的最终展示态

   建议在保存成功后重新请求一次 `GET /team/style/status/list`。

## 五、前端接入建议

### 1. 页面初始化

统一调用：

`GET /team/style/status/list`

取这 5 组数据：

- `explain`
- `mediaModeUse`
- `mainStyleUse`
- `isMediaMix`
- `imageStyleUses`
- `styleItems`

### 2. 提交保存

统一调用：

`POST /team/config/style/edit`

提交：

- `mediaModeUse`
- `mainStyleUse`
- `isMediaMix`
- `imageStyleUses`

### 3. 风格卡片是否可点

不要看订阅字段，只看状态字段：

- 图片模式：看 `imageStatus`
- 视频模式：看 `videoStatus`
- 通用卡片展示：可辅以 `status/statusHint`

### 4. 2.2.1 前端必须忽略的旧逻辑

以下逻辑都要移除：

- 根据 `paymentStatus/paymentHint` 显示购买区
- 根据 `subscribeCount/totalFee/billingDate` 显示订阅信息
- 根据 `imageSubRights/videoSubRights` 判断能不能点
- 根据 `imageRights/videoRights` 判断是否可用
- 根据 `unsubscribed/expired` 判断是否过期
- 根据“是否买到视频档位”决定视频模式能不能切

一句话：**2.2.1 风格设置是偏好设置，不是订阅中心。**

## 六、建议前端最终采用的最小字段集

如果页面只想保留最少字段，可以只关心下面这些：

```json
{
  "explain": "...",
  "mediaModeUse": 1,
  "mainStyleUse": "3d",
  "isMediaMix": true,
  "imageStyleUses": ["3d", "photo", "cute", "ghibli"],
  "styleItems": [
    {
      "style": "3d",
      "styleTitle": [],
      "styleDesc": [],
      "image": {},
      "video": {},
      "status": 1,
      "imageStatus": 1,
      "videoStatus": 1,
      "statusHint": ""
    }
  ]
}
```

这份最小字段集已经足够支撑 2.2.1 的：

- 设置页
- 浏览弹窗
- 做题混搭标签

