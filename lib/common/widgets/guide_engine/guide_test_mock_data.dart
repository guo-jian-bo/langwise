import '../../../app/routes/routes.dart';
import 'guide_engine.dart';

/// 引导测试模拟数据
///
/// 这个文件只负责返回测试用的步骤模型数据，
/// 不负责任何网络请求、展示逻辑或上报逻辑。
///
/// 你可以把它理解为“本地假数据仓库”：
///
/// - 开发阶段先用它把引导流程跑通
/// - 后续接真实接口时，只需要把正式仓库中的返回值替换成真实请求即可
class GuideTestMockData {
  /// 根据页面 code 返回对应的测试步骤。
  ///
  /// 当前正式仓库尚未接通真实接口时，会通过这个方法按页面分发本地测试数据。
  /// 后续如果你想调试不同页面的引导，只需要扩展这里的映射关系即可。
  static GuidePageTask? byPageCode(String pageCode) {
    switch (pageCode) {
      case AppRoutesCode.home:
        return homeMultiStep();
      case AppRoutesCode.userCenter:
        return userCenterMultiStep();
      case AppRoutesCode.userEvaluationLevelResult:
        return userEvaluationLevelMultiStep();
      case AppRoutesCode.myCoupons:
        return myCouponsMultiStep();
      case AppRoutesCode.userEvaluation:
        return userEvaluationMultiStep();
      case AppRoutesCode.studyPlan:
        return studyPlanMultiStep();
      case AppRoutesCode.planDetails:
        return planDetailsMultiStep();
      case AppRoutesCode.missionControlCenter:
        return missionControlCenterMultiStep();
      default:
        return GuidePageTask(code: pageCode, guideGroups: const <GuideTaskGroup>[]);
    }
  }

  static GuidePageTask? planDetailsMultiStep(){
    return null;

    // return const GuidePageTask(
    //   code: AppRoutesCode.planDetails,
    //   guideGroups: <GuideTaskGroup>[
    //     GuideTaskGroup(
    //       stepCode: 'guide_user_evaluation_group_001',
    //       order: 1,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.planDetailsSwitchCourseButton,
    //           title: '切换课程',
    //           content: '点击这里可以切换课程。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.planDetailsRecommendSceneButton,
    //           title: '推荐场景',
    //           content: '点击这里可以推荐场景。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.planDetailsDisableExerciseButton,
    //           title: '禁用题型',
    //           content: '点击这里可以禁用题型。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.planDetailsAdjustTimeButton,
    //           title: '调整时间安排',
    //           content: '点击这里可以调整时间安排。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.planDetailsSavePlanButton,
    //           title: '保存计划',
    //           content: '点击这里可以保存计划。',
    //           targetTapAction: GuideTargetTapAction.executeTargetLogic,
    //         ),
            

    //       ],
    //     ),
    //   ],
    // );
  }

  static GuidePageTask? studyPlanMultiStep(){
    return null;

    // return  GuidePageTask(
    //   code: AppRoutesCode.studyPlan,
    //   guideGroups: <GuideTaskGroup>[
    //     GuideTaskGroup(
    //       stepCode: 'guide_user_evaluation_group_001',
    //       order: 1,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.studyPlanCustomerServiceButton,
    //           title: '客服',
    //           desc: '点击这里可以联系客服。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.studyPlanAssessmentLevelButton,
    //           title: '选择水平',
    //           desc: '点击这里可以选择水平学习。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.studyPlanTodayTaskButton,
    //           title: '今日任务',
    //           desc: '点击这里可以选择水平。',
    //           handle: 0,
    //         ),

    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.studyPlanAddCourseButton,
    //           title: '添加课程',
    //           desc: '点击这里可以添加课程。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.studyPlanStartPlanButton,
    //           title: '开始计划',
    //           desc: '点击这里可以开始计划。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.studyPlanPausePlanButton,
    //           title: '暂停计划',
    //           desc: '点击这里可以暂停计划。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.studyPlanResumePlanButton,
    //           title: '继续计划',
    //           desc: '点击这里可以继续计划。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.studyPlanEditPlanButton,
    //           title: '编辑计划',
    //           desc: '点击这里可以编辑计划。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.studyPlanAdvanceStudyButton,
    //           title: '提前学习',
    //           desc: '点击这里可以提前学习。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.studyPlanAddTextbookButton,
    //           title: '提前学习',
    //           desc: '点击这里可以提前学习。',
    //           handle: 0,
    //         ),

    //       ],
    //     ),
    //   ],
    // );
  }



  static GuidePageTask? userEvaluationMultiStep() {
    return null;

    // return const GuidePageTask(
    //   code: AppRoutesCode.userEvaluation,
    //   guideGroups: <GuideTaskGroup>[
    //     GuideTaskGroup(
    //       stepCode: 'guide_user_evaluation_group_001',
    //       order: 1,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userEvaluationEditStudentInfoButton,
    //           title: '编辑信息',
    //           content: '点击这里可以编辑个人信息。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userEvaluationBaseSelectionModule,
    //           title: '选择水平',
    //           content: '点击这里可以选择水平学习。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userEvaluationStartTestButton,
    //           title: '开始评测',
    //           content: '点击这里可以开始评测。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),

    //       ],
    //     ),
    //   ],
    // );

  }


  static GuidePageTask? myCouponsMultiStep() {
    return null;

    // return const GuidePageTask(
    //   code: AppRoutesCode.myCoupons,
    //   guideGroups: <GuideTaskGroup>[
    //     GuideTaskGroup(
    //       stepCode: 'guide_my_coupons_group_001',
    //       order: 1,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.myCouponsCouponExchangeButton,
    //           title: '兑换优惠券',
    //           content: '点击这里可以兑换优惠券。',
    //           targetTapAction: GuideTargetTapAction.executeTargetLogic,
    //         ),
    //       ],
    //     ),
    //   ],
    // );

  }

  static GuidePageTask? userEvaluationLevelMultiStep() {
    return null;

    // return  GuidePageTask(
    //   code: AppRoutesCode.userEvaluationLevelResult,
    //   guideGroups: <GuideTaskGroup>[
    //     GuideTaskGroup(
    //       stepCode: 'guide_user_evaluation_level_group_001',
    //       order: 1,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userEvaluationLevelResultTestButton,
    //           title: '评测',
    //           desc: '点击这里可以开始评测。',
    //           handle: 0,
    //         ),
    //       ],
    //     ),
    //     GuideTaskGroup(
    //       stepCode: 'guide_user_evaluation_level_group_002',
    //       order: 1,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userEvaluationLevelResultLearningPlanModule,
    //           title: '学习规划',
    //           desc: '点击这里可以查看学习规划。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userEvaluationLevelResultMakingPlanModule,
    //           title: '正在制定方案',
    //           desc: '点击这里可以查看正在制定方案。',
    //           handle: 0,
    //         ),
    //       ],
    //     ),
    //   ],
    // );
  }

  /// 测试首页多步骤数据。
  ///
  /// 适合验证首页入口、快捷操作以及课程卡片相关引导是否能按顺序展示。
  static GuidePageTask? homeMultiStep() {
    return null;

    // return const GuidePageTask(
    //   code: AppRoutesCode.home,
    //   guideGroups: <GuideTaskGroup>[
    //     GuideTaskGroup(
    //       stepCode: 'guide_home_group_001',
    //       order: 1,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.homeNavButton,
    //           title: '首页导航',
    //           content: '点击这里可以回到首页主导航区域。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.homeZhenTingNavButton,
    //           title: '甄听入口',
    //           content: '点击这里可以进入甄听内容入口。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.homeScriptNavButton,
    //           title: '剧场入口',
    //           content: '点击这里可以进入剧场学习内容。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.homeMusicNavButton,
    //           title: '音乐入口',
    //           content: '点击这里可以进入音乐学习模块。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.homeDictionaryNavButton,
    //           title: '词典入口',
    //           content: '点击这里可以打开词典功能。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.homePronunciationNavButton,
    //           title: '发音课入口',
    //           content: '点击这里可以进入发音课内容。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //       ],
    //     ),
    //     GuideTaskGroup(
    //       stepCode: 'guide_home_group_002',
    //       order: 2,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.homeFavoriteButton,
    //           title: '收藏按钮',
    //           content: '点击这里可以查看或进入收藏内容。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.homeUserButton,
    //           title: '用户按钮',
    //           content: '点击这里可以进入个人中心。',
    //           targetTapAction: GuideTargetTapAction.executeTargetLogic,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.homeMessageButton,
    //           title: '消息按钮',
    //           content: '点击这里可以查看消息通知。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //       ],
    //     ),
    //     GuideTaskGroup(
    //       stepCode: 'guide_home_group_003',
    //       order: 3,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.homeStartLearningButton,
    //           title: '开始学习',
    //           content: '点击这里可以从今日任务开始学习。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //       ],
    //     ),
    //     GuideTaskGroup(
    //       stepCode: 'guide_home_group_004',
    //       order: 4,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.homeOfficialCourseCard,
    //           title: '官方课程',
    //           content: '这里会展示官方课程卡片入口。',
    //           targetTapAction: GuideTargetTapAction.executeTargetLogic,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.homePlanCard,
    //           title: '学习计划',
    //           content: '这里会展示当前学习计划内容。',
    //           targetTapAction: GuideTargetTapAction.executeTargetLogic,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.homeCustomCourseCard,
    //           title: '自定义课程',
    //           content: '这里可以查看自定义课程卡片。',
    //           targetTapAction: GuideTargetTapAction.executeTargetLogic,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.homePreparationPlanCard,
    //           title: '备考卡片',
    //           content: '这里可以查看备考相关学习安排。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //       ],
    //     ),
    //   ],
    // );
  }

  /// 测试用户中心多步骤数据。
  ///
  /// 适合验证以下流程：
  ///
  /// 1. 第一步完成后是否能推进下一步
  /// 2. 当前步骤目标未出现时是否会等待
  /// 3. 同一页面多个组件是否能按顺序展示
  static GuidePageTask? userCenterMultiStep() {

    return null;

    // return const GuidePageTask(
    //   code: AppRoutesCode.userCenter,
    //   guideGroups: <GuideTaskGroup>[
    //     GuideTaskGroup(
    //       stepCode: 'guide_user_center_group_001',
    //       order: 1,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterInviterButton,
    //           title: '推荐有礼',
    //           content: '点击这里可以查看推荐有礼相关入口。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterEditInfoButton,
    //           title: '编辑信息',
    //           content: '点击这里可以编辑个人信息、密码等。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterResetParentPasswordButton,
    //           title: '重置家长密码',
    //           content: '点击这里可以重置家长密码。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterContactTeacherButton,
    //           title: '联系助教老师',
    //           content: '点击这里可以快速联系助教老师。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //       ],
    //     ),
    //     GuideTaskGroup(
    //       stepCode: 'guide_user_center_group_002',
    //       order: 2,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterMyMemberInfoButton,
    //           title: '我的会员信息',
    //           content: '这里会展示当前会员权益和相关信息。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterUpgradeMemberButton,
    //           title: '升级会员',
    //           content: '点击这里可以查看会员升级入口。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterCouponButton,
    //           title: '优惠券',
    //           content: '点击这里可以查看当前账户优惠券。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterPointRecordButton,
    //           title: '学点记录',
    //           content: '点击这里可以查看学点使用记录。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterRechargePointButton,
    //           title: '充值学点',
    //           content: '点击这里可以进入学点充值入口。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterRechargeCreditButton,
    //           title: '充值乃币',
    //           content: '点击这里可以进入乃币充值入口。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //       ],
    //     ),
    //     GuideTaskGroup(
    //       stepCode: 'guide_user_center_group_003',
    //       order: 3,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterManageStudentButton,
    //           title: '管理学员',
    //           content: '点击这里可以管理当前账号下的学员信息。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterEditActiveStudentInfoButton,
    //           title: '编辑当前激活学员信息',
    //           content: '点击这里可以编辑当前激活学员资料。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //       ],
    //     ),
    //     GuideTaskGroup(
    //       stepCode: 'guide_user_center_group_004',
    //       order: 4,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterGoTestButton,
    //           title: '去评测',
    //           content: '点击这里可以进入评测流程。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterCurrentCefrLevelButton,
    //           title: '当前评测',
    //           content: '这里会展示当前 CEFR 评测结果。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //       ],
    //     ),
    //     GuideTaskGroup(
    //       stepCode: 'guide_user_center_group_005',
    //       order: 5,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterLanguagePreferenceModule,
    //           title: '语言学习偏好',
    //           content: '这里可以查看和调整语言学习相关偏好。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterLearningPreferenceModule,
    //           title: '学习类偏好',
    //           content: '这里可以查看和调整学习类偏好设置。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterExpandPreferenceModule,
    //           title: '拓展类偏好',
    //           content: '这里可以查看和调整拓展类偏好设置。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterManageEffectiveStyleButton,
    //           title: '管理生效风格',
    //           content: '点击这里可以管理当前生效风格。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.userCenterThemePreferenceModule,
    //           title: '主题偏好',
    //           content: '这里可以查看和调整主题偏好配置。',
    //           targetTapAction: GuideTargetTapAction.nextStep,
    //         ),
    //       ],
    //     ),
    //   ],
    // );
  }

  /// 测试任务控制中心多步骤数据。
  ///
  /// 适合验证任务控制中心内的概览入口、任务入口、能力专项卡片以及底部 tab
  /// 是否能按顺序展示并正常推进引导。
  static GuidePageTask? missionControlCenterMultiStep() {

    return null;

    // return GuidePageTask(
    //   code: AppRoutesCode.missionControlCenter,
    //   guideGroups: <GuideTaskGroup>[
    //     GuideTaskGroup(
    //       stepCode: 'guide_mission_control_center_group_001',
    //       order: 1,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.missionControlCenterTodayKnowledgeOverviewButton,
    //           title: '今日知识概览',
    //           desc: '点击这里可以查看今天的知识分布与任务总览。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.missionControlCenterFirstPreparationButton,
    //           title: '第一个预习任务',
    //           desc: '这里会定位到第一个预习任务，方便快速开始预习。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.missionControlCenterFirstNewKnowledgeButton,
    //           title: '第一个新学任务',
    //           desc: '这里会定位到第一个新学任务，便于直接开始正式学习。',
    //           handle: 0,
    //         ),
    //       ],
    //     ),
    //     GuideTaskGroup(
    //       stepCode: 'guide_mission_control_center_group_002',
    //       order: 2,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.missionControlCenterCurrentLevelButton,
    //           title: '当前等级',
    //           desc: '点击这里可以查看当前评测等级与学习阶段。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.missionControlCenterPlanButton,
    //           title: '学习计划',
    //           desc: '点击这里可以进入学习计划页面，查看或调整计划安排。',
    //           handle: 0,
    //         ),
    //       ],
    //     ),
    //     GuideTaskGroup(
    //       stepCode: 'guide_mission_control_center_group_003',
    //       order: 3,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.missionControlCenterListenButton,
    //           title: '听专项',
    //           desc: '点击这里可以进入听力专项任务。',
    //           handle: 1,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.missionControlCenterSpeakButton,
    //           title: '说专项',
    //           desc: '点击这里可以进入口语专项任务。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.missionControlCenterReadButton,
    //           title: '读专项',
    //           desc: '点击这里可以进入阅读专项任务。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.missionControlCenterWriteButton,
    //           title: '写专项',
    //           desc: '点击这里可以进入写作专项任务。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.missionControlCenterOverallButton,
    //           title: '综合专项',
    //           desc: '点击这里可以进入综合能力专项任务。',
    //           handle: 0,
    //         ),
    //       ],
    //     ),
    //     GuideTaskGroup(
    //       stepCode: 'guide_mission_control_center_group_004',
    //       order: 4,
    //       guides: <GuideTaskGuide>[
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.missionControlCenterDailyTaskButton,
    //           title: '每日任务 Tab',
    //           desc: '点击这里可以切换到每日任务视图。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.missionControlCenterSuperCalendarButton,
    //           title: '超级日历 Tab',
    //           desc: '点击这里可以切换到超级日历视图。',
    //           handle: 0,
    //         ),
    //         GuideTaskGuide(
    //           widgetId: GuideWidgetIds.missionControlCenterMilestoneChallengeButton,
    //           title: '里程碑挑战 Tab',
    //           desc: '点击这里可以切换到里程碑挑战视图。',
    //           handle: 0,
    //         ),
    //       ],
    //     ),
    //   ],
    // );
  }

  

}
