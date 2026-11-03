import '../common/entities/entities.dart';
import '../common/https/https.dart';
import '../common/widgets/widgets.dart';
import '../theme/theme.dart';

class FilterDataUtils{

  /// 获取音色列表
  static Future<FilterConditionData?> getAccentList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    List<ManageEnglishContentManagementAccentModel>? accentList = await LanguageConsoleRequest.getAccentList(parameters: parameters, data: data);
    if(accentList == null) return null;
    
    List<FilterConditionItem> conditions = [];

    for(var item in accentList){
      if(item.name == null || item.uid == null) continue;
      conditions.add(FilterConditionItem(
        name: "${item.national??""} ${item.name!}", 
        value: item.uid!,
        color: AppTheme.cTextSecondary.color,
      ));
    }

    return FilterConditionData(
      title: "音色",
      conditions: conditions,
    );
  }

  /// 获取题目类型列表
  static Future<FilterConditionData?> getExerciseTypeList() async{
    ManageExerciseFilterModel? filterModel = await CourseConsoleRequest.getExerciseFilter();
    if(filterModel == null) return null;

    List<ManageExerciseFilterQuizTypeData> exerciseTypeList = filterModel.exerciseTypeList??[];
    
    List<FilterConditionItem> conditions = [];

    for(var item in exerciseTypeList){
      if(item.type == null || item.typeName == null) continue;
      conditions.add(FilterConditionItem(
        name: item.typeName??"", 
        value: item.type,
        color: AppTheme.cTextSecondary.color,
      ));
    }

    return FilterConditionData(
      title: "音色",
      conditions: conditions,
    );
  }




}