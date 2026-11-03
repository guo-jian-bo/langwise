enum NotificationModuleEnum {
  userCenter('user_center', '用户中心'),
  learning('learning', '学习模块'),
  store('store', '商城模块'),
  activity('activity', '活动模块'),
  question('question', '题目模块'),
  course('course', '课程模块'),
  task('task', '任务模块'),
  system('system', '系统模块'),
  reward('reward', '奖励模块'),
  study('study', '学习模块'),
  manage('manage', '管理模块'),
  other('other', '其他模块');

  final String code;
  final String title;

  const NotificationModuleEnum(this.code, this.title);

  static NotificationModuleEnum? fromCode(String? code) {
    if (code == null || code.isEmpty) {
      return null;
    }
    for (final NotificationModuleEnum value in NotificationModuleEnum.values) {
      if (value.code == code) {
        return value;
      }
    }
    return null;
  }
}
