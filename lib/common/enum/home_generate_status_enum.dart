import 'package:get/get.dart';

enum HomeGenerateStatusEnum{

  /// 已创建占位任务，等待 MQ 开始处理。
  START("START"),
  /// MQ 已消费，正在执行今日任务生成逻辑。
  RUNNING("RUNNING"),
  /// 今日任务生成流程已经结束。 注意：生成完成不代表一定有任务，也可能是空任务完成态。
  FINISHED("FINISHED");

  final String value;

  const HomeGenerateStatusEnum(this.value);

  static HomeGenerateStatusEnum? fromValue(String? value) {
    return HomeGenerateStatusEnum.values.firstWhereOrNull((element) => element.value == value);
  }

}