/// 高亮目标被点击后的处理方式。
///
/// 该字段由服务端步骤配置控制，用来告诉客户端：
///
/// 1. 点击高亮区域后，是否要继续执行该目标绑定的原始逻辑
/// 2. 还是不执行业务逻辑，直接推进到下一步
enum GuideTargetTapAction {
  /// 执行当前目标绑定的原始业务逻辑。
  executeTargetLogic,

  /// 不执行业务逻辑，直接进入下一步。
  nextStep,
}

GuideTargetTapAction guideTargetTapActionFromJson(dynamic value) {
  if (value is num) {
    return value == 1
        ? GuideTargetTapAction.executeTargetLogic
        : GuideTargetTapAction.nextStep;
  }

  final String rawValue = value?.toString() ?? '';
  switch (rawValue) {
    case '1':
    case 'executeTargetLogic':
      return GuideTargetTapAction.executeTargetLogic;
    case '0':
    case 'nextStep':
    default:
      return GuideTargetTapAction.nextStep;
  }
}

bool guideBoolFromJson(
  dynamic value, {
  bool defaultValue = false,
}) {
  if (value is bool) return value;
  final String rawValue = value?.toString().toLowerCase() ?? '';
  if (rawValue == 'true' || rawValue == '1') return true;
  if (rawValue == 'false' || rawValue == '0') return false;
  return defaultValue;
}

int guideIntFromJson(
  dynamic value, {
  int defaultValue = 0,
}) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? defaultValue;
}

/// 一个页面对应的一整套引导任务。
class GuidePageTask {
  /// 页面唯一业务标识。
  final String code;

  /// 当前页面下的所有引导分组。
  final List<GuideTaskGroup> guideGroups;

  const GuidePageTask({
    required this.code,
    required this.guideGroups,
  });

  factory GuidePageTask.fromJson(Map<String, dynamic> json) {
    final List<GuideTaskGroup> groups =
        ((json['guideGroups'] as List?) ?? const <dynamic>[])
            .map((dynamic item) => GuideTaskGroup.fromJson(
                  (item as Map?)?.cast<String, dynamic>() ??
                      <String, dynamic>{},
                ))
            .toList()
          ..sort(
            (GuideTaskGroup a, GuideTaskGroup b) => a.order.compareTo(b.order),
          );

    return GuidePageTask(
      code: json['code']?.toString() ?? '',
      guideGroups: groups,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'guideGroups':
          guideGroups.map((GuideTaskGroup item) => item.toJson()).toList(),
    };
  }
}

/// 页面任务中的一个分组。
class GuideTaskGroup {
  /// 当前分组完成后的上报编码。
  final String stepCode;

  /// 分组顺序。
  final int order;

  /// 当前分组中的所有小步骤。
  final List<GuideTaskGuide> guides;

  const GuideTaskGroup({
    required this.stepCode,
    required this.order,
    required this.guides,
  });

  factory GuideTaskGroup.fromJson(Map<String, dynamic> json) {
    return GuideTaskGroup(
      stepCode: json['stepCode']?.toString() ?? '',
      order: guideIntFromJson(json['order']),
      guides: ((json['guides'] as List?) ?? const <dynamic>[])
          .map((dynamic item) => GuideTaskGuide.fromJson(
                (item as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'stepCode': stepCode,
      'order': order,
      'guides': guides.map((GuideTaskGuide item) => item.toJson()).toList(),
    };
  }
}

/// 分组中的一个引导步骤。
class GuideTaskGuide {
  /// 当前目标组件唯一标识。
  final String widgetId;

  /// 当前步骤标题。
  final String title;

  /// 当前步骤说明。
  final String content;

  /// 点击高亮目标后的动作模式。
  final GuideTargetTapAction targetTapAction;

  /// 是否显示右上角关闭按钮。
  final bool showCloseButton;

  const GuideTaskGuide({
    required this.widgetId,
    required this.title,
    required this.content,
    this.targetTapAction = GuideTargetTapAction.nextStep,
    this.showCloseButton = true,
  });

  factory GuideTaskGuide.fromJson(Map<String, dynamic> json) {
    return GuideTaskGuide(
      widgetId: json['widgetId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? json['desc']?.toString() ?? '',
      targetTapAction: guideTargetTapActionFromJson(
        json['handle'] ?? json['targetTapAction'],
      ),
      showCloseButton: guideBoolFromJson(
        json['showCloseButton'],
        defaultValue: true,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'widgetId': widgetId,
      'title': title,
      'content': content,
      'handle':
          targetTapAction == GuideTargetTapAction.executeTargetLogic ? 1 : 0,
      'showCloseButton': showCloseButton,
    };
  }
}

Map taskJson = {
  "code": "页面code", // 页面路由code 比如说用户中心
  "guideGroups": [ // 一组任务 代表一整个引导
    { // 这一个数据代表这个页面的一组小步骤
      "stepCode": "steps1", // 页面路由code 或者 业务code 完成这一组后需要上报
      "order": 1, // 分组的顺序
      "guides": [ // 步骤分组 代表这个页面的当前的所有步骤
        {
          "widgetId": "widgetId A", // 引导组件ID 比如修改用户信息按钮
          "title": "编辑信息", // 当前步骤标题
          "content": "xxxxxx", // 当前步骤说明
          "handle": 0, // 点击后是否要执行目标绑定的原始逻辑 0 不执行 1 执行目标绑定的原始逻辑
          "showCloseButton": true, // 是否显示右上角关闭按钮
        },
        {
          "widgetId": "widgetId B", // 引导组件ID 比如修改用户信息按钮
          "title": "编辑头像", // 当前步骤标题
          "desc": "xxxxxx", // 当前步骤说明
          "handle": 1, // 点击后是否要执行目标绑定的原始逻辑 0 不执行 1 执行目标绑定的原始逻辑 
        }
      ]
    },

    {
      "stepCode": "steps2",
      "order": 2,
      "guides": [
        {
          "widgetId": "title",
          "title": "修改用户信息",
          "content": "xxxxxx",
          "handle": 1,
        }
      ]
    },

    {
      "stepCode": "steps3",
      "order": 2,
      "guides": [
        {
          "widgetId": "cefr",
          "title": "去评测",
          "content": "xxxxxx",
        }
      ]
    }
  ]
};
