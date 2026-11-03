import 'package:quiz_play/quiz_play.dart';

import '../common/entities/entities.dart';
import '../common/https/https.dart';

class QuizDeformationUtils{

  factory QuizDeformationUtils() => _getInstance();

  static QuizDeformationUtils get instance => _getInstance();

  static QuizDeformationUtils? _instance;

  static QuizDeformationUtils _getInstance() {
    _instance ??= QuizDeformationUtils._internal();
    return _instance!;
  }

  QuizDeformationUtils._internal();

  static const String displayText = "TEXT"; 
  static const String displayImage = "IMAGE";
  static const String displayAudio = "AUDIO";
  static const String displayImageText = "IMAGE_TEXT";

  static final Map<String, String> typeNameMap = {
    displayText: "文字",
    displayImage: "图片",
    displayAudio: "音频",
    displayImageText: "图片+文字",
    "CHOICE": "选择",
    "TYPING": "输入",
    "SYLLABLE": "音节",
    "PHONEME": "音素",
    "AUTO": "自动",
  };

  /// 题目配置
  ManageQuizTemplateEntity? _quizTemplateEntity;

  ///初始化题目配置
  void initQuizTemplateEntity(ManageQuizTemplateEntity template){
    _quizTemplateEntity = template;
  }


  /// 根据配置获取题目数据
  /// * data: 题目数据
  /// * config: 变形的题目配置
  Future<QuizModel?> getQuizData(QuizModel? data, QuizModelConfig? config) async{
    if(data == null || config == null) return null;
    Map<String, dynamic> reqData = {
      "config": config.toJson(),
      "type": data.type,
      // "configId": configId,
    };
    List<QuizModel>? result = await ManageQuizTemplateRequest.getQuizDeformationData(reqData);
    if(result == null) return null;
    if(result.isEmpty) return null;
    return result.first;
  }


  /// 获取题干选择下标
  int? getStemIndex(String? stemDisplay){
    if(stemDisplay == null) return null;
    List<QuizDeformationDisplayKV>? stemScope = getStemScopeList();
    if(stemScope == null) return null;
    for(int i = 0; i < stemScope.length; i++){
      if(stemScope[i].value == stemDisplay) return i;
    }
    return null;
  }

  /// 获取题干数量选择下标
  int? getStemNumberIndex(int? stemNumberDisplay){
    if(stemNumberDisplay == null) return null;
    List<int>? stemNumberScope = getStemNumberScopeList();
    if(stemNumberScope == null) return null;
    for(int i = 0; i < stemNumberScope.length; i++){
      if(stemNumberScope[i] == stemNumberDisplay) return i;
    }
    return null;
  }
  

  /// 获取选项选择下标
  int? getOptionIndex(String? optionDisplay){
    if(optionDisplay == null) return null;
    List<QuizDeformationDisplayKV>? optionScope = getOptionScopeList();
    if(optionScope == null) return null;
    for(int i = 0; i < optionScope.length; i++){
      if(optionScope[i].value == optionDisplay) return i;
    }
    return null;
  }

  /// 获取选项数量选择下标
  int? getOptionNumberIndex(int? optionNumberDisplay){
    if(optionNumberDisplay == null) return null;
    List<int>? optionNumberScope = getOptionNumberScopeList();
    if(optionNumberScope == null) return null;
    for(int i = 0; i < optionNumberScope.length; i++){
      if(optionNumberScope[i] == optionNumberDisplay) return i;
    }
    return null;
  }

  /// 获取输入选择下标
  int? getInputIndex(String? inputDisplay){
    if(inputDisplay == null) return null;
    List<QuizDeformationKV>? inputScope = getInputScopeList();
    if(inputScope == null) return null;
    for(int i = 0; i < inputScope.length; i++){
      if(inputScope[i].value == inputDisplay) return i;
    }
    return null;
  }

  /// 获取音素音节自动选择下标
  int? getBreakdownIndex(String? breakdownDisplay){
    if(breakdownDisplay == null) return null;
    List<QuizDeformationKV>? breakdownScope = getBreakdownScopeList();
    if(breakdownScope == null) return null;
    for(int i = 0; i < breakdownScope.length; i++){
      if(breakdownScope[i].value == breakdownDisplay) return i;
    }
    return null;
  }

  /// 获取题干范围
  List<QuizDeformationDisplayKV>? getStemScopeList({bool isSet = true}){
    ManageQuizTemplateEntity? template = _quizTemplateEntity;
    if(template == null) return null;
    List<ManageQuizTemplateEntityTemplateDisplayModelScope?>? displayModelScope = template.template?.displayModelScope;
    if(displayModelScope == null) return null;
    List<QuizDeformationDisplayKV> stemScope = [];
    for(ManageQuizTemplateEntityTemplateDisplayModelScope? scope in displayModelScope){
      if(scope == null) continue;
      if(scope.stemDisplay == null) continue;
      if(isSet && stemScope.any((element) => element.value == scope.stemDisplay)) continue;
      String? name = typeNameMap[scope.stemDisplay!];
      if(name == null) continue;
      String? optionName = typeNameMap[scope.optionDisplay??""];
      
      stemScope.add(QuizDeformationDisplayKV(scope.stemDisplay!, name, scope.optionDisplay??"", optionName??""));
    }
    return stemScope;
  }

  /// 获取选项范围
  List<QuizDeformationDisplayKV>? getOptionScopeList({bool isSet = true}){
    ManageQuizTemplateEntity? template = _quizTemplateEntity;
    if(template == null) return null;
    List<ManageQuizTemplateEntityTemplateDisplayModelScope?>? displayModelScope = template.template?.displayModelScope;
    if(displayModelScope == null) return null;
    List<QuizDeformationDisplayKV> optionScope = [];
    for(ManageQuizTemplateEntityTemplateDisplayModelScope? scope in displayModelScope){
      if(scope == null) continue;
      if(scope.optionDisplay == null) continue;
      if(isSet && optionScope.any((element) => element.value == scope.optionDisplay)) continue;
      String? name = typeNameMap[scope.optionDisplay!];
      if(name == null) continue;
      String? stemName = typeNameMap[scope.stemDisplay??""];
      
      optionScope.add(QuizDeformationDisplayKV(scope.optionDisplay!, name, scope.stemDisplay??"", stemName??""));
    }
    return optionScope;
  }

  /// 获取输入范围
  List<QuizDeformationKV>? getInputScopeList(){
    ManageQuizTemplateEntity? template = _quizTemplateEntity;
    if(template == null) return null;
    List<String?>? inputScope = template.template?.inputModeScope;
    if(inputScope == null) return null;
    List<QuizDeformationKV> inputScopeList = [];
    for(String? input in inputScope){
      if(input == null) continue;
      String? name = typeNameMap[input];
      if(name == null) continue;
      inputScopeList.add(QuizDeformationKV(input, name));
    }
    return inputScopeList;
  }

  /// 获取音素音节自动范围
  List<QuizDeformationKV>? getBreakdownScopeList(){
    ManageQuizTemplateEntity? template = _quizTemplateEntity;
    if(template == null) return null;
    List<String?>? breakdownScope = template.template?.breakdownLevel;
    if(breakdownScope == null) return null;
    List<QuizDeformationKV> breakdownScopeList = [];
    for(String? breakdown in breakdownScope){
      if(breakdown == null) continue;
      String? name = typeNameMap[breakdown];
      if(name == null) continue;
      breakdownScopeList.add(QuizDeformationKV(breakdown, name));
    }
    return breakdownScopeList;
  }


  /// 获取题干数量范围
  List<int>? getStemNumberScopeList(){
    ManageQuizTemplateEntity? template = _quizTemplateEntity;
    if(template == null) return null;
    List<int?>? stemNumberScope = template.template?.stemQuantityScope;
    if(stemNumberScope == null) return null;
    List<int> stemNumberScopeList = [];
    for(int? stemNumber in stemNumberScope){
      if(stemNumber == null) continue;
      stemNumberScopeList.add(stemNumber);
    }
    return stemNumberScopeList;
  }

  /// 获取选项数量范围
  List<int>? getOptionNumberScopeList(){
    ManageQuizTemplateEntity? template = _quizTemplateEntity;
    if(template == null) return null;
    List<int?>? optionNumberScope = template.template?.optionQuantityScope;
    if(optionNumberScope == null) return null;
    List<int> optionNumberScopeList = [];
    for(int? optionNumber in optionNumberScope){
      if(optionNumber == null) continue;
      optionNumberScopeList.add(optionNumber);
    }
    return optionNumberScopeList;
  }

  /// 获取题干是否播放音频范围
  List<bool>? getStemAudioScopeList(){
    ManageQuizTemplateEntity? template = _quizTemplateEntity;
    if(template == null) return null;
    List<bool?>? stemAudioScope = template.template?.stemAudioScope;
    if(stemAudioScope == null) return null;
    List<bool> stemAudioScopeList = [];
    for(bool? stemAudio in stemAudioScope){
      if(stemAudio == null) continue;
      stemAudioScopeList.add(stemAudio);
    }
    return stemAudioScopeList;
  }

  /// 获取选项是否播放音频范围
  List<bool>? getOptionAudioScopeList(){
    ManageQuizTemplateEntity? template = _quizTemplateEntity;
    if(template == null) return null;
    List<bool?>? optionAudioScope = template.template?.optionAudioScope;
    if(optionAudioScope == null) return null;
    List<bool> optionAudioScopeList = [];
    for(bool? optionAudio in optionAudioScope){
      if(optionAudio == null) continue;
      optionAudioScopeList.add(optionAudio);
    }
    return optionAudioScopeList;
  }

  /// 获取问题是否播放音频范围
  List<bool>? getQuestionAudioScopeList(){
    ManageQuizTemplateEntity? template = _quizTemplateEntity;
    if(template == null) return null;
    List<bool?>? questionAudioScope = template.template?.questionAudioScope;
    if(questionAudioScope == null) return null;
    List<bool> questionAudioScopeList = [];
    for(bool? questionAudio in questionAudioScope){
      if(questionAudio == null) continue;
      questionAudioScopeList.add(questionAudio);
    }
    return questionAudioScopeList;
  }

  /// 获取预先学习范围
  List<bool>? getPreTeachingScopeList(){
    ManageQuizTemplateEntity? template = _quizTemplateEntity;
    if(template == null) return null;
    List<bool?>? preTeachingScope = template.template?.allowPreTeaching;
    if(preTeachingScope == null) return null;
    List<bool> preTeachingScopeList = [];
    for(bool? preTeaching in preTeachingScope){
      if(preTeaching == null) continue;
      preTeachingScopeList.add(preTeaching);
    }
    return preTeachingScopeList;
  }

  /// 获取高亮范围
  List<bool>? getHighlightScopeList(){
    ManageQuizTemplateEntity? template = _quizTemplateEntity;
    if(template == null) return null;
    List<bool?>? highlightScope = template.template?.hintsScope;
    if(highlightScope == null) return null;
    List<bool> highlightScopeList = [];
    for(bool? highlight in highlightScope){
      if(highlight == null) continue;
      highlightScopeList.add(highlight);
    }
    return highlightScopeList;
  }

  /// 获取逐句显示范围
  List<bool>? getFollowSentenceScopeList(){
    ManageQuizTemplateEntity? template = _quizTemplateEntity;
    if(template == null) return null;
    List<bool?>? followSentenceScope = template.template?.allowFollowSentence;
    if(followSentenceScope == null) return null;
    List<bool> followSentenceScopeList = [];
    for(bool? followSentence in followSentenceScope){
      if(followSentence == null) continue;
      followSentenceScopeList.add(followSentence);
    }
    return followSentenceScopeList;
  }



}


class QuizDeformationKV{
  final String value;
  final String name;
  QuizDeformationKV(this.value, this.name);
}

class QuizDeformationDisplayKV{
  final String value;
  final String name;
  final String ohterValue;
  final String ohterName;
  QuizDeformationDisplayKV(this.value, this.name, this.ohterValue, this.ohterName);
}