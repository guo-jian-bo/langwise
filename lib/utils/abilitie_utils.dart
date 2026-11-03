import '../common/entities/entities.dart';

class AbilitieUtils{

  static List<ConfigEntityAbilities>? getAbilitieList(ConfigEntity configData){
    List<ConfigEntityAbilities?>? abilities = configData.abilities;
    if(abilities == null) return null;
    List<ConfigEntityAbilities> result = [];
    for (var e in abilities) {
      if(e == null) continue;
      result.add(e);
    }
    return result;
  }

  static ConfigEntityAbilities? getAbilitieName(ConfigEntity configData, String? direction){
    if(direction == null) return null;
    List<ConfigEntityAbilities?>? abilities = configData.abilities;
    if(abilities == null) return null;
    for (var e in abilities) {
      if(e?.direction == direction) return e;
    }
    return null;
  }
  
}