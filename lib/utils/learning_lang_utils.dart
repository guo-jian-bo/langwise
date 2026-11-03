import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';

import '../common/entities/entities.dart';
import '../common/enum/enum.dart';

class LearningLangUtils{


  /// 获取用户使用的方言的音频信息 如果没有则返回第一个
  static PronunciationsEntity? getUsePronunciations(List<PronunciationsEntity?>? pronunciations){
    if(pronunciations == null) return null;
    if(pronunciations.isEmpty) return null;
    final ConfigController controller = Get.find<ConfigController>();
    String learningLang = controller.userSetting.value.learningLang;

    for(int i = 0; i < pronunciations.length; i++){
      if(pronunciations[i] == null) continue;
      if(pronunciations[i]!.national == learningLang){
        return pronunciations[i]!;
      }
    }

    return pronunciations.first;
  }


  /// 排序- 本地语言在前
  static List<LanguageText> sortLocalLangFirst(List<LanguageText?> gloss){
    final ConfigController controller = Get.find<ConfigController>();
    String localLang = controller.userSetting.value.localLang;
    gloss.sort((a, b){
      if(a?.lang == localLang){
        return -1;
      }
      return 1;
    });

    List<LanguageText> resp = [];

    for(int i = 0; i < gloss.length; i++){
      if(gloss[i] == null) continue;
      resp.add(gloss[i]!);
    }

    return resp;
  }

  /// 排序 - 学习语言在前
  static List<LanguageText> sortLearningLangFirst(List<LanguageText?>? gloss){
    final ConfigController controller = Get.find<ConfigController>();
    String learningLang = controller.userSetting.value.learningLang;
    if(gloss == null) return [];
    
    
    gloss.sort((a, b){
      if(a?.lang == learningLang){
        return -1;
      }
      return 1;
    });
    List<LanguageText> resp = [];
    for(int i = 0; i < gloss.length; i++){
      if(gloss[i] == null) continue;
      resp.add(gloss[i]!);
    }
    return resp;
  }
  

  /// 获取学习语言的文本 双语两种都返回 本地语言返回本地语言 学习语言返回学习语言
  static List<LanguageText> getLearningLangText(List<LanguageText?>? gloss){
    
    final ConfigController controller = Get.find<ConfigController>();
    LangPreference lang = controller.userSetting.value.expandLang;
    if(gloss == null) return [];

    String localLang = controller.userSetting.value.localLang;
    String learningLang = controller.userSetting.value.learningLang;


    List<LanguageText> glossText = [];
    for(int i = 0; i < gloss.length; i++){
      if(gloss[i] == null) continue;
      if(lang == LangPreference.bilingual){
        if(localLang == gloss[i]!.lang || learningLang == gloss[i]!.lang){
          glossText.add(gloss[i]!);
        }
      }else if(lang == LangPreference.original || lang == LangPreference.translation || lang == LangPreference.none){
        if(learningLang == gloss[i]!.lang){
          glossText.add(gloss[i]!);
        }
      }
    }
    return glossText;
  }

  /// 获取双语和本地语言一样的列表 如果设置是双语和本地语言 那么则都返回 (双语和本地语言一样返回本地语言和双语)
  static List<LanguageText> getShowLBList(List<LanguageText?>? gloss){
    
    final ConfigController controller = Get.find<ConfigController>();
    LangPreference lang = controller.userSetting.value.expandLang;

    String localLang = controller.userSetting.value.localLang;
    String learningLang = controller.userSetting.value.learningLang;

    if(gloss == null) return [];
    List<LanguageText> glossText = [];
    for(int i = 0; i < gloss.length; i++){
      if(gloss[i] == null) continue;

      if(lang == LangPreference.bilingual || lang == LangPreference.translation){
        if(localLang == gloss[i]!.lang || learningLang == gloss[i]!.lang){
          glossText.add(gloss[i]!);
        }
      }else if(lang == LangPreference.original || lang == LangPreference.none){
        if(learningLang == gloss[i]!.lang){
          glossText.add(gloss[i]!);
        }
      }
      
    }
    glossText.sort((a, b){
      if(a.lang == learningLang){
        return -1;
      }
      return 1;
    });
    return glossText;
  }

  /// 获取双语和本地语言一样 如果设置是双语和本地语言 那么返回本地语言 (双语和本地语言一样返回本地语言)
  static LanguageText? getShowLList(List<LanguageText?>? gloss){
    
    final ConfigController controller = Get.find<ConfigController>();
    LangPreference lang = controller.userSetting.value.expandLang;

    String localLang = controller.userSetting.value.localLang;
    String learningLang = controller.userSetting.value.learningLang;

    if(gloss == null) return null;
    LanguageText? glossText;
    for(int i = 0; i < gloss.length; i++){
      if(gloss[i] == null) continue;

      if(lang == LangPreference.bilingual || lang == LangPreference.translation){
        if(localLang == gloss[i]!.lang){
          return gloss[i];
        }
      }else if(lang == LangPreference.original || lang == LangPreference.none){
        if(learningLang == gloss[i]!.lang){
          return gloss[i];
        }
      }
    }
    return glossText;
  }

  /// 获取单个语言 获取双语和本地语言一样 为none则不返回
  static LanguageText? getShowForNone(List<LanguageText?>? gloss){
    final ConfigController controller = Get.find<ConfigController>();
    LangPreference lang = controller.userSetting.value.expandLang;

    if(lang == LangPreference.none){
      return null;
    }

    String localLang = controller.userSetting.value.localLang;
    String learningLang = controller.userSetting.value.learningLang;

    if(gloss == null) return null;
    LanguageText? glossText;
    for(int i = 0; i < gloss.length; i++){
      if(gloss[i] == null) continue;

      if(lang == LangPreference.bilingual || lang == LangPreference.translation){
        if(localLang == gloss[i]!.lang){
          return gloss[i];
        }
      }else if(lang == LangPreference.original){
        if(learningLang == gloss[i]!.lang){
          return gloss[i];
        }
      }
    }
    return glossText;
    
    
  }

  /// 获取学习语言
  static LanguageText? getLearningLang(List<LanguageText?>? gloss){
    final ConfigController controller = Get.find<ConfigController>();

    String localLang = controller.userSetting.value.localLang;
    String learningLang = controller.userSetting.value.learningLang;

    if(gloss == null) return null;
    

    LanguageText? glossText;
    for(int i = 0; i < gloss.length; i++){
      if(gloss[i] == null) continue;

      if(learningLang.isEmpty && localLang == gloss[i]!.lang){//双语
        glossText = gloss[i];
        break;
      }else if(learningLang == gloss[i]!.lang){
        glossText = gloss[i];
        break;
      }
    }
    return glossText;
  }

  /// 获取本地语言
  static LanguageText? getLocalLang(List<LanguageText?>? gloss){
    final ConfigController controller = Get.find<ConfigController>();
    String localLang = controller.userSetting.value.localLang;
    
    if(gloss == null) return null;
    LanguageText? glossText;
    for(int i = 0; i < gloss.length; i++){
      if(gloss[i] == null) continue;
      if(localLang == gloss[i]!.lang){
        glossText = gloss[i];
        break;
      }
    }
    return glossText;
  }

}