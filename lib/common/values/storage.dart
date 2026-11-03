/// 用户 - 配置信息
const String STORAGE_USER_PROFILE_KEY = 'user_profile';

/// 用户 - 基本信息
const String STORAGE_USER_INFO_KEY = 'user_info';

/// 设备ID 推出登录不清理
const String STORAGE_DEVICE_ID_KEY = 'device_id';

/// 用户 - token
const String STORAGE_USER_TOKEN_KEY = 'user_token';

/// 用户 - 刷新refreshToken
const String STORAGE_REFRESH_TOKEN_KEY = 'refresh_token';

/// accessTokenExpired 过期时间 2025-12-07T09:10:51.059+00:00
const String STORAGE_ACCESS_TOKEN_EXPIRED_KEY = 'access_token_expired';

/// refreshTokenExpired 过期时间 2025-12-30T09:10:51.065+00:00
const String STORAGE_REFRESH_TOKEN_EXPIRED_KEY = 'refresh_token_expired';

/// 设备是否第一次打开
const String STORAGE_DEVICE_FIRST_OPEN_KEY = 'device_first_open';

/// 用户是否第一次登陆
const String STORAGE_USER_FIRST_LOGIN_KEY = 'user_first_login';

/// 多语言
const String STORAGE_LANGUAGE_CODE = 'language_code';

/// 语言数据JSON
const String STORAGE_LANGUAGE_JSON = "language_json";

/// app主题
const String STORAGE_APP_THEME_KEY = 'app_theme';

/// 用户 - 隐私协议
const String STORAGE_USER_AGREE_PRIVACY_KEY = 'user_agree_privacy';

/// app更新弹窗，一天弹出来一次，这里储存当天的年月日
const String STORAGE_APP_CHECK_DATE_KEY = "app_check_date";

/// 服务器地址版本
const String STORAGE_HTTP_ENV_KEY = "httpEnv";

/// 苹果支付 未完成的订单{"sign": "", "orderNo": "", "receipt": "",}
const String STORAGE_IAP_PENDING_PURCHASES_KEY = "iap_pending_purchases";

/// int 家长密码输入错误次数 n次后提示重置密码 每次输入正确之后重置为0
const String STORAGE_PARENT_PASSWORD_ERROR_COUNT_KEY = "parent_password_error_count";

/// int 管理端密码输入错误次数 n次后提示重置密码 每次输入正确之后重置为0
const String STORAGE_MANAGE_PASSWORD_ERROR_COUNT_KEY = "manage_password_error_count";

/// String(年月日时分秒 yyyy-MM-dd HH:mm:ss) 管理端密码 15分钟内无需重复输入密码
const String STORAGE_MANAGE_PASSWORD_FREE_KEY = "manage_password_free";

/// String(年月日时分秒 yyyy-MM-dd HH:mm:ss) 家长密码 15分钟内无需重复输入密码
const String STORAGE_PARENT_PASSWORD_FREE_KEY = "parent_password_free";

/// int 代理商密码输入错误次数 n次后提示重置密码 每次输入正确之后重置为0
const String STORAGE_AGENT_PASSWORD_ERROR_COUNT_KEY = "agent_password_error_count";

/// bool 体验APP标识 如果是null 则是正常进入 如果是true那么就是体验APP进入 除了首页接口 都不调用
const String EXPERIENCE_APP_KEY = "experience_app";

/// String 年月日(20250715) 课程详情，选择今天的学习之旅，今日不再提醒
const String NOT_REMIND_COURSE_KEY = "not_remind_course";

/// String 首页刷标识 20250715 首页每次刷新后 都需要刷新这个标识 然后从后台返回app时判断是否是今天 不是今天就刷新首页数据
const String HOME_REFRESH_DATE_KEY = "home_refresh_date";

/// bool 卡片切换模式 不在提示
const String NOT_REMIND_CARD_KEY = "not_remind_card";

/// bool 联系助教老师 不在提示
const String NOT_REMIND_CONTACT_TEACHER_KEY = "not_remind_contact_teacher";

/// bool 跟读提示
const String FOLLOW_UP_PROMPT_KEY = "follow_up_prompt";

/// 做题页面 操作提示 List<configId.toString()> 可以重复多个configId
const String QUIZ_OPERATION_ANNOUNCEMENT_PROMPT_KEY = "quiz_operation_announcement_prompt";

/// 持久化缓存 专栏购买不再提醒key
const String SPECIAL_PAY_NOT_REMIND_KEY = "special_pay_not_remind";

/// 音频控制器widget的持久话配置 现在在听读一体和音乐播放器页面
const String AUDIO_CONTROL_SETTING_KEY = "audio_control_setting";

/// 甄听专栏 难度提醒不再弹出弹窗
const String SUB_LISTEN_NOT_REMIND_KEY = "sub_listen_not_remind";

/// 切换节奏
const String INTERVAL_SPEED_KEY = 'interval_speed';
