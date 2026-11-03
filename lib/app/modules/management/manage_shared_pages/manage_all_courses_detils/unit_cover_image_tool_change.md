## 目标与验收口径

- 课程详情页中，点击模块“展开”后，Unit 封面左上角展示图片 `imageId`、`styleTitle`、`localeTitle`。
- Unit 封面右上角展示裁剪图标、编辑图标和审核状态文案。
- 点击裁剪 / 编辑后，返回课程详情页时当前模块的 Unit 封面数据能刷新。

## 改动点列表

- 在 `manage_all_courses_detils_controller.dart` 中补齐 Unit 图片字段解析：`imageId`、`type`、`semanticId`、`styleId`、`styleTitle`、`localeTitle`、`updated`。
- 在 `manage_all_courses_detils_controller.dart` 中新增当前模块 Unit 列表刷新方法，供裁剪 / 编辑返回后使用。
- 在 `manage_all_courses_detils_view.dart` 中为展开区 Unit 卡片补充左上角图片信息 tag。
- 在 `manage_all_courses_detils_view.dart` 中为展开区 Unit 卡片补充右上角裁剪 / 编辑按钮和审核状态文案。

## 关键设计 / 关键决策

- 直接复用模块封面现有的 tag 与图标样式，不新增公共组件。
- 裁剪 / 编辑跳转参数沿用统一图片工具页约定，`type` 使用接口中的 `COURSE_UNIT`。
- 审核状态沿用 module 的口径，直接使用接口返回的 `imageTaskIds`；`null` 或空数组时展示“无待审核”，否则展示“待审核”。
- 裁剪 / 编辑返回后仅刷新当前模块的 Unit 展开数据，不重刷整页课程数据。

## 兼容性影响与注意事项

- 若 Unit 没有 `image.imageId`，则裁剪图标隐藏，但编辑图标仍展示；此时会以 Unit `uid` 和默认 `COURSE_UNIT` 类型进入统一图片编辑页。
- 若 Unit 接口未返回 `imageTaskIds`，则按 `null` 处理，展示“无待审核”。

## 非目标

- 本次不调整 Unit 卡片点击跳转行为，仍保持点击卡片进入模块详情页对应 Unit。
