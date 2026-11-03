import '../../entities/entities.dart';
import '../../https/https.dart';
import 'guide_task_models.dart';

/// 引导任务仓库
///
/// 这个类负责承接“正式流程中的数据访问”：
///
/// 1. 获取当前用户未完成的引导步骤
/// 2. 上报某个步骤已完成
///
/// 这里之所以单独抽成仓库层，是为了让：
///
/// - `GuideTaskController` 专注于任务调度
/// - `GuideTaskRepository` 专注于数据获取和上报
///
/// 当前后端接口尚未接通，因此这里先用本地测试模型数据兜底。
/// 后续只需要替换这个仓库里的实现，不需要改动控制器和页面接入方式。
class GuideTaskRepository {
  /// 获取当前未完成的引导步骤。
  ///
  /// 当前为正式流程预留实现位置：
  ///
  /// - 后续这里应替换成真实接口请求
  /// - 当前接口未接通时，先返回本地测试模型数据
  ///
  /// [pageCode] 由页面进入时传入，用于标识当前页面需要拉取哪一组引导步骤。
  /// [questId] 任务ID
  /// [review] 等于1 时，表示是 重新开始
  Future<GuidePageTask?> fetchPageTask({
    required String pageCode,
    int? questId,
    int? review,
  }) async {
    // return null;
    Map<String, dynamic> parameters = {
      "pageCode": pageCode,
    };
    if (questId != null) {
      parameters["questId"] = questId;
    }
    if(review != null){
      parameters["review"] = review;
    }
    return await ActivitiesRequest.getPageGuideTasks(parameters: parameters);
    // return GuideTestMockData.byPageCode(pageCode);
  }

  /// 上报某个步骤已完成。
  ///
  /// 当前为正式流程预留实现位置：
  ///
  /// - 后续这里应替换成真实接口上报
  /// - 当前接口未接通时，先直接返回 `true`
  Future<NewbieGuideEntityQuests?> reportStepComplete(GuideTaskGroup group) async {
    if(group.questId == null) return null;
    if(group.stepCode == null) return null;
    Map<String, dynamic> reqData = {
      "questId": group.questId,
      "stepCode": group.stepCode,
    };
    NewbieGuideEntityQuests? res = await ActivitiesRequest.reportStepComplete(reqData: reqData);
    return res;
  }
}
