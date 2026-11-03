你是一个资深 Flutter(GetX) 工程师。目标：把下列 Routes 页面逐步改造成「可多实例 / 基于 tag 的路由跳转」形式。具体改造规则请严格遵循同目录的 [tag_routes_migration_prompt.md](file:///Users/langwise/Desktop/ns/project/langwise/lib/app/routes/tag_routes_migration_prompt.md)。

本清单覆盖范围（来源）：app_routes.dart 选中的路由常量段：
- /app_routes.dart#L8-11：SPLASH / SIGN_IN_UP / APPLICATION
- /app_routes.dart#L22-28：PRACTICE_QUESTIONS / ZHENDU_LOOK / ZHENDU_PERFORM / ZHENDU_PRACTICE / VIDEO_TASK_PLAYER / PRACTICE_QUESTIONS_EVAL / LISTEN_AND_READ
- /app_routes.dart#L30-118：官方课程详情、学习计划、会员卡、考试、用户中心、自定义课程、任务中心、其它杂项

使用方式（给你自己/AI 的执行提示）：
1) 每次只处理一个“阶段”的页面（不要跨阶段混改，便于回滚与验收）
2) 每改完 1 个页面：确保能正常跳转、不会串 Controller、面包屑正常
3) 每改完 1 个阶段：检查 TagRoutes 注册表没有漏项，且主要入口都已切到 TagRoutes.toNamed

通用验收标准（每个页面都要满足）：
- View：有 tagText + override tag + static to({arguments, tag})
- Binding：构造传入 tagText，并 Get.lazyPut(..., tag: tagText)；Controller 构造接收 tagText
- Controller：with RoutesBreadcrumbMixin，onInit 里 initBreadcrumb(tagText)，实现 breadcrumbRoute/breadcrumbTitle
- TagRoutes：注册 Routes.XXX -> XxxView.to
- 跳转：调用方必须用 TagRoutes 中的方法（至少 TagRoutes.toNamed；需要其它语义就先在 TagRoutes 里补齐再使用）
- 页面内部：所有 Get.find/GetBuilder/GetX 等取 Controller 的地方都带 tag（或改成 GetView 并 override tag）
- 外部 find Controller：不要直接 Get.find；用 TagRoutes.findLast<Controller>(Routes.XXX)
- 外部 不要直接 Get.isRegistered；用 TagRoutes.isRegistered<Controller>(Routes.XXX, {tag: tagText})
- app_pages.dart（GetPage 注册处）如因 tagText required 报错：View/Binding 的 tagText 传 '' 作为占位即可

---

## 阶段 1：用户中心与轻业务页（相对低风险，优先做）
- [x] Routes.USER_CENTER
- [x] Routes.MEMBER_CENTER
- [x] Routes.MANAGE_STUDENTS
- [x] Routes.MY_COUPONS
- [x] Routes.LEARNING_POINT_DETAILS
- [x] Routes.OPEN_MEMBER_SETTLEMENT
- [x] Routes.EDIT_USER_PROFILE
- [x] Routes.ABOUT_US
- [x] Routes.WEB_PAGE
- [x] Routes.LIMIT_DISCOUN_DETAIL
- [x] Routes.RECHARGE_NAIBI
- [x] Routes.RECHARGE_POINT
- [x] Routes.FAVOURITE
- [x] Routes.FEEDBACK_OPINION
- [x] Routes.ILLEGAL_REPORTING
- [x] Routes.DREAM_BUILDING_TEAM
- [x] Routes.OPEN_SOURCE_LICENSE

---

## 阶段 2：官方课程详情体系（中风险，注意子页面/组合路由）
- [x] Routes.OFFICIAL_COURSE_DETAILS_TARGET
- [x] Routes.OFFICIAL_COURSE_DETAILS_PREVIEW
- [x] Routes.OFFICIAL_COURSE_DETAILS_DICTATION
- [x] Routes.OFFICIAL_COURSE_DETAILS_DICTATION_CHECK
- [x] Routes.OFFICIAL_COURSE_DETAILS_FLASH_NOTES

- [x] Routes.OFFICIAL_COURSE_DETAILS
- [x] Routes.OFFICIAL_COURSE_DETAILS_LEVEL
- [x] Routes.OFFICIAL_COURSE_DETAILS_UNIT_SCRIPT_LIST
- [x] Routes.COURSE_LEVEL_SELECT_UNIT
- ZhenduPlayerView()

---

## 阶段 3：学习计划 / 任务中心（中风险）
- [x] Routes.NEW_CREATE_STUDY_PLAN
- [x] Routes.TODAY_PLAN
- [x] Routes.SUPER_MEMO_CALENDER
- [x] Routes.SELECT_LEARNING_MODULE
- [x] Routes.MISSION_CONTROL_CENTER
- [x] Routes.MISSION_COMPLETE
- [x] Routes.MISSION_TEST_RESULT
- [x] Routes.MISSION_SPECIAL
- [x] Routes.EXAM_PREPARATION
- [x] Routes.PREPARATION_PLAN_LIST

---

## 阶段 4：会员卡 / 考试备考（中风险）
- [x] Routes.MEMBERSHIP_CARD_MANAGE
- [x] Routes.MEMBERSHIP_CARD_MANAGE_GENERATE_RECORD
- [x] Routes.MEMBERSHIP_CARD_MANAGE_REBATE_RECORD
- [x] Routes.MEMBERSHIP_CARD_MANAGE_RECHARGE_RECORD
- [x] Routes.MEMBERSHIP_CARD_MANAGE_AGENT_DASHBOARD

---

## 阶段 5：自定义课程（中风险，入口多、跳转多）
- [x] Routes.CUSTOMIZED_COURSES
- [x] Routes.CUSTOM_COURSE_GENERATION_DETAIL
- [x] Routes.UPLOAD_BOOK_INFO
- [x] Routes.CUSTOM_COURSE_MANAGE_PHOTOS
- [x] Routes.CUSTOM_COURSE_SHOOT_WORDS
- [x] Routes.CUSTOM_COURSE_CHECK_KNOWLEDGE
- [x] Routes.CUSTOM_COURSE
- [x] Routes.CUSTOM_COURSE_ADD_GRADE
- [x] Routes.CUSTOM_COURSE_MANAGE_GRADE
- [x] Routes.CUSTOM_COURSE_MANAGE_GRADE_SORT

---

## 阶段 6：其它杂项（按需，建议最后做）
- [x] Routes.MEMORY_CARD_LIST
- [x] Routes.MEMORY_RECORDER_CHART
- [x] Routes.USER_EVALUATION_LEVEL
- [x] Routes.BECOME_INVITER
- [x] Routes.INVITATION_LIST
- [x] Routes.ASSESSMENT_HISTORY_TIME_MACHINE
- [x] Routes.USER_EVALUATION
- [x] Routes.PHONICS_COURSE
- [x] Routes.APP_SUBSCRIBE_LISTENING_DETAILS
- [x] Routes.ZHENDU_SHOW_DETAIL

---

## 阶段 6A：做题 / 真读 / 听读（中风险，栈内多开概率高）
- [x] Routes.PRACTICE_QUESTIONS
- [x] Routes.PRACTICE_QUESTIONS_EVAL
- [x] Routes.LISTEN_AND_READ
- [x] Routes.ZHENDU_LOOK
- [x] Routes.ZHENDU_PERFORM
- [x] Routes.ZHENDU_PRACTICE
- [x] Routes.VIDEO_TASK_PLAYER

---

## 阶段 7：入口壳页面（高风险，除非确认要改，否则建议最后再评估）
- [x] Routes.APPLICATION

说明：  
- 这类页面通常是“全局唯一容器/流程入口”，多实例意义不大，且改造后更容易影响启动流程与路由栈
- 如果要改：先全局搜索这些路由的 GetPage 配置、children、middleware、observers，确认不依赖单例 Controller

---

## 每个阶段的执行模板（复制粘贴用）
请按阶段逐个页面执行以下步骤（严格按顺序）：
1) 找到 Routes.XXX 对应的 View/Controller/Binding 文件路径
2) 按 tag_routes_migration_prompt.md 改造 View/Controller/Binding
3) 在 tag_routes.dart 注册 Routes.XXX -> XxxView.to
4) 全局搜索该页面跳转入口：把 Get.to / Get.toNamed 替换为 TagRoutes.toNamed(Routes.XXX, arguments: ...)
5) 检查页面内部 Get.find/GetBuilder/GetX 的 tag 使用（防串实例）
6) 通过实际跳转验证：同一路由连续打开多次，各实例互不影响
