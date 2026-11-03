import 'package:langwise/app/routes/app_pages.dart';

class GuideManifest {
  static const List<String> routes = <String>[
    Routes.APPLICATION,
    Routes.HOME,
    Routes.MISSION_CONTROL_CENTER,
    Routes.NEW_CREATE_STUDY_PLAN,
    Routes.PRACTICE_QUESTIONS_EVAL,
    Routes.TODAY_PLAN,
    Routes.USER_CENTER,
    Routes.USER_EVALUATION,
  ];

  static const Map<String, List<String>> anchorsByRoute = <String, List<String>>{
    Routes.APPLICATION: <String>[
      "favourite_btn",
      "to_user_center",
      "home_fist_card_start",
      "to_study_plan",
    ],
    Routes.MISSION_CONTROL_CENTER: <String>[
      "browse_courses_btn",
      "listen_and_write_btn",
      "mission_btn",
      "mission_unit",
      "preview_btn",
    ],
    Routes.NEW_CREATE_STUDY_PLAN: <String>[
      "study_days",
      "study_holidays",
      "study_wordkdays",
    ],
    Routes.PRACTICE_QUESTIONS_EVAL: <String>[
      "see_assessment",
    ],
    Routes.TODAY_PLAN: <String>[
      "add_official_plan",
      "add_phonics_plan",
      "add_textbook_plan",
      "edit_plan",
      "pause_plan",
      "resume_plan",
    ],
    Routes.USER_CENTER: <String>[
      "add_student",
      "check_assessment_report",
      "check_coupons",
      "edit_profile",
      "save_btn",
    ],
    Routes.USER_EVALUATION: <String>[
      "start_free_evaluation",
    ],
  };

  static const Map<String, String> routeLabels = <String, String>{
    Routes.APPLICATION: "应用主框架",
    Routes.HOME: "首页",
    Routes.MISSION_CONTROL_CENTER: "任务中心",
    Routes.NEW_CREATE_STUDY_PLAN: "计划详情页面",
    Routes.PRACTICE_QUESTIONS_EVAL: "练习题目Eval",
    Routes.TODAY_PLAN: "今日计划",
    Routes.USER_CENTER: "用户中心",
    Routes.USER_EVALUATION: "用户个人信息——评测",
  };

  static const Map<String, Map<String, String>> anchorLabelsByRoute = <String, Map<String, String>>{
    Routes.APPLICATION: <String, String>{
      "favourite_btn": "收藏按钮",
      "to_user_center": "前往用户中心",
    },
    Routes.HOME: <String, String>{
      "home_fist_card_start": "首页任务按钮",
      "to_study_plan": "首页计划按钮",
    },
    Routes.MISSION_CONTROL_CENTER: <String, String>{
      "browse_courses_btn": "浏览课程按钮",
      "listen_and_write_btn": "听写按钮",
      "mission_btn": "第一个学习按钮",
      "mission_unit": "任务单元按钮",
      "preview_btn": "预习按钮",
      "professional_mission_listening": "专业任务听",
      "professional_mission_reading": "专业任务读",
      "professional_mission_writing": "专业任务写",
      "professional_mission_speaking": "专业任务说",
      "professional_mission_overall": "专业任务综合",
    },
    Routes.NEW_CREATE_STUDY_PLAN: <String, String>{
      "study_days": "编辑工作日休息日",
      "study_holidays": "休息日时长",
      "study_wordkdays": "工作日时长",
    },
    Routes.PRACTICE_QUESTIONS_EVAL: <String, String>{
      "see_assessment": "SeeAssessment",
    },
    Routes.TODAY_PLAN: <String, String>{
      "add_official_plan": "添加官方课程计划",
      "add_phonics_plan": "添加发音课计划",
      "add_textbook_plan": "添加课本计划",
      "edit_plan": "编辑计划",
      "pause_plan": "暂停计划",
      "resume_plan": "恢复计划",
    },
    Routes.USER_CENTER: <String, String>{
      "add_student": "添加学员",
      "check_assessment_report": "查看评测报告",
      "check_coupons": "兑换优惠券",
      "edit_profile": "编辑资料",
      "save_btn": "个人信息保存",
    },
    Routes.USER_EVALUATION: <String, String>{
      "start_free_evaluation": "开始免费评测",
    },
  };
}

