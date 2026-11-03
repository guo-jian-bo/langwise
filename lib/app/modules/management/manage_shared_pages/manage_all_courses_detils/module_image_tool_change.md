## 目标与验收口径

- 在课程详情页的 module 卡片封面右上角增加图片裁剪与编辑图标入口。
- 右上角图标下方展示“待审核 / 无待审核”tag。
- 左上角从上到下展示 `uid:imageId`、`styleTitle`、`localeTitle` 三个 tag。
- module 卡片右侧标题下方展示“是否上架 + 难度”标签，形式与前台 module 标签一致。
- 所有封面 tag 样式统一。
- 点击裁剪进入统一图片裁剪页。
- 点击编辑进入统一图片编辑页。

## 改动点列表

- 为 `ModuleResponseEntity` 增加模块图片 `image` 和 `imageTaskIds` 结构解析，承接课程列表接口中的模块图片数据。
- 在 `manage_all_courses_detils_view.dart` 中本地实现模块封面右上角图标按钮与左右两侧 tag，不改动公共图片工具组件。
- 在 `manage_all_courses_detils_view.dart` 中给卡片标题下方展示上架状态和难度标签；其中难度复用通用 `StatusTagDifficultyWidget`，上架标签使用本地样式。
- 为当前页面 controller 增加刷新入口，裁剪/编辑返回后刷新课程详情数据。

## 参数映射

- `uid`：使用模块 `uid`
- `type`：使用模块图片中的 `type`，当前为 `COURSE_MODULE`
- `semanticId`：使用模块图片中的 `semanticId`，当前示例为 `null`
- `imageIds`：使用模块图片中的 `imageId`，按统一图片组件要求包装成数组
- `styleId`：使用模块图片中的 `styleId`
- `imageUrl`：优先使用模块图片中的 `imageUrl`，缺失时回退到 `coverUrl`
- `imageTaskIds`：直接使用课程列表返回值；`null` 或空数组时展示“无待审核”，否则展示“待审核”

## 关键设计与决策

- 不新增单独的模块图片查询接口，直接复用课程列表接口已返回的模块图片数据。
- 不修改公共 `ManageImageToolEditWidgets`，避免影响其他页面；当前页单独实现图标与 tag 外观，但沿用同一套跳转参数与权限码。
- 封面 tag 统一样式：黑色 60% 透明背景、白色 15% 透明边框、圆角 6、padding 6、字号 12、字重 500。

## 兼容性影响与注意事项

- 若模块没有 `image.imageId`，则裁剪 / 编辑图标隐藏，但“待审核 / 无待审核”tag 仍会按 `imageTaskIds` 展示。
- `jumpCode` 使用 `AppManageRoutesCode.moduleDetails`，并附带模块基础参数，保持与模块图片业务语义一致。
