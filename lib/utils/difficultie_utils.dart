
import 'package:get/get.dart';

import '../common/entities/entities.dart';
import '../common/public_controller/config_controller.dart';

class DifficultieEntity{
  int? level;
  ConfigEntityDifficultiesLanguages? name;
  DifficultieEntity({
    this.level, 
    this.name,
  });
}

class DifficultieUtils{

  /// 根据语言code 获取难度等级列表
  static List<DifficultieEntity>? getDifficultieList(ConfigEntity configData, String? languageCode){
    List<ConfigEntityDifficulties?>? difficulties = configData.difficulties;
    if(difficulties == null) return null;

    List<DifficultieEntity> difficultieList = [];
    for(int i = 0; i < difficulties.length; i++){
      ConfigEntityDifficulties? item = difficulties[i];
      if(item == null) continue;
      difficultieList.add(DifficultieEntity(
        level: item.level,
        name: getLanguageData(item.languages, languageCode),
      ));
    }
    if(difficultieList.isEmpty) return null;
    difficultieList.sort((a, b) => a.level?.compareTo(b.level??0) ?? 0);
    return difficultieList;
  }

  static ConfigEntityDifficultiesLanguages? getLanguageData(List<ConfigEntityDifficultiesLanguages?>? list, String? languageCode) {
    if(list == null || languageCode == null) return null;
    for(int i = 0; i < list.length; i++){
      if(list[i] == null) continue;
      if(list[i]!.lang == languageCode){
        return list[i];
      }
    }
    return null;
  }

  static DifficultieEntity? getLanguageDifficultieLevel(ConfigEntity configData, String? languageCode, int? difficulty) {
    if(languageCode == null || difficulty == null) return null;
    List<DifficultieEntity>? list = getDifficultieList(configData, languageCode);
    if(list == null) return null;
    for(int i = 0; i < list.length; i++){
      if(list[i].level == difficulty){
        return list[i];
      }
    }
    return null;
  }

  static DifficultieEntity? getLanguageDifficultieLevel1(String? languageCode, int? difficulty) {
    if(languageCode == null || difficulty == null) return null;
    ConfigController configController = Get.find<ConfigController>();
    ConfigEntity appConfig = configController.appConfig.value;
    List<DifficultieEntity>? list = getDifficultieList(appConfig, languageCode);
    if(list == null) return null;
    for(int i = 0; i < list.length; i++){
      if(list[i].level == difficulty){
        return list[i];
      }
    }
    return null;
  }

  

}