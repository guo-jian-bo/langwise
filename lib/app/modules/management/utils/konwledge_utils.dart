
import 'package:get/get.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import 'package:langwise/app/modules/management/models/manage_knowledge_table_model.dart';

class KonwledgeUtils{


  /// 根据 contentId contentType semanticId 获取知识点数据
  static Future<ManageKnowledgeTableModel?> getKnowledgeDataByContentId({
    required int? contentId,
    required String? contentType,
    int? semanticId,
  }) async {
    
    if(contentId == null || contentType == null) {
      return null;
    }

    ElementsCardType type = ElementsCardType.fromRawValue(contentType);

    ManageKnowledgePagerModel pagerData = ManageKnowledgePagerModel();

    if(type == ElementsCardType.word){
      pagerData = await getEnWordKnowledgeList(uids: [contentId.toString()]);
    }else if(type == ElementsCardType.phrase){
      pagerData = await getEnPhraseKnowledgeList(uids: [contentId.toString()]);
    }else if(type == ElementsCardType.sentence){
      pagerData = await getEnSentenceKnowledgeList(uids: [contentId.toString()]);
    }else if(type == ElementsCardType.text){
      pagerData = await getEnTextKnowledgeList(uids: [contentId.toString()]);
    } else if(type == ElementsCardType.reveal){
      pagerData = await getEnRevealsKnowledgeList(uids: [contentId.toString()]);
    }
    
    if(pagerData.datas == null) return null;
    ManageKnowledgeTableModel first = pagerData.datas!.first;
    if(semanticId != null){
      if(first.type == ElementsCardType.word){
        first.word?.semantics?.forEach((element) {
          if(element.uid == semanticId){
            first.selectSemantics = [element];
          }
        });
      }else if(first.type == ElementsCardType.phrase){
        first.phrase?.semantics?.forEach((element) {
          if(element.uid == semanticId){
            first.selectSemantics = [element];
          }
        });
      }else if(first.type == ElementsCardType.sentence){
        first.sentence?.semantics?.forEach((element) {
          if(element.uid == semanticId){
            first.selectSemantics = [element];
          }
        });
      }
    }

    return first;

  }

  /// 根据类型查询列表
  static Future<ManageKnowledgePagerModel?> getKnowledgeListByType({
    required ElementsCardType type,
    int knowledgeOffset = 0,
    int knowledgeLimit = 20,
    String? content,
    List<String>? uids,
    String? fullContent,
    String? phonicsIpa,
    String? order,
    List<ManageKnowledgeTableModel>? initSelectedIds,
  }) async {
    if(type == ElementsCardType.word){
      return await getEnWordKnowledgeList(
        knowledgeOffset: knowledgeOffset,
        knowledgeLimit: knowledgeLimit,
        content: content,
        uids: uids,
        fullContent: fullContent,
        phonicsIpa: phonicsIpa,
        order: order,
        initSelectedIds: initSelectedIds,
      );
    }else if(type == ElementsCardType.phrase) {
      return await getEnPhraseKnowledgeList(
        knowledgeOffset: knowledgeOffset,
        knowledgeLimit: knowledgeLimit,
        content: content,
        uids: uids,
        fullContent: fullContent,
        order: order,
        initSelectedIds: initSelectedIds,
      );
    } else if(type == ElementsCardType.sentence) {
      return await getEnSentenceKnowledgeList(
        knowledgeOffset: knowledgeOffset,
        knowledgeLimit: knowledgeLimit,
        content: content,
        uids: uids,
        fullContent: fullContent,
        order: order,
        initSelectedIds: initSelectedIds,
      );
    } else if(type == ElementsCardType.text){
      return await getEnTextKnowledgeList(
        knowledgeOffset: knowledgeOffset,
        knowledgeLimit: knowledgeLimit,
        content: content,
        uids: uids,
        order: order,
        initSelectedIds: initSelectedIds,
      );
    }
    
    return null;
  }


  /// 查询单词列表
  static Future<ManageKnowledgePagerModel> getEnWordKnowledgeList({
    int knowledgeOffset = 0,
    int knowledgeLimit = 20,
    String? content,
    List<String>? uids,
    String? fullContent,
    String? phonicsIpa,
    String? order,
    List<ManageKnowledgeTableModel>? initSelectedIds,
  }) async {

    ManageKnowledgePagerModel pagerData = ManageKnowledgePagerModel();

    Map<String, dynamic> parameters = {
      "offset": knowledgeOffset,
      "limit": knowledgeLimit,
      "order": order??"-wordFreq",
    };
    Map<String, dynamic> data = {};
    if(content != null && content.isNotEmpty){
      data["content"] = content;
    }
    if(uids != null && uids.isNotEmpty){
      data["uid"] = uids;
    }
    if(fullContent != null && fullContent.isNotEmpty){
      data["fullContent"] = fullContent;
    }
    if(phonicsIpa != null && phonicsIpa.isNotEmpty){
      data["phonicsIpa"] = phonicsIpa;
    }

    ListResponseEntity<EnWordEntity>? res = await ManageSelectQuziKnowledge.getEnWordKnowledgeList(parameters: parameters, data: data);
    if (res == null) return pagerData;
    pagerData.count = res.count ?? 0;
    pagerData.offset = res.offset??0;
    pagerData.limit = res.limit??0;

    List<EnWordEntity> datas = res.datas ?? [];
    List<ManageKnowledgeTableModel> _allKnowledgeList = [];

    for (var element in datas) {
      String id = "${element.contentType}_${element.uid}";

      _allKnowledgeList.add(ManageKnowledgeTableModel(
        id: id,
        type: ElementsCardType.word,
        word: element,
        isSelected: initSelectedIds?.any((e) => e.id == id)??false,
        enableSelect: initSelectedIds?.firstWhereOrNull((item) => item.id == id)?.enableSelect ?? true,
      ));
    }
    pagerData.datas = _allKnowledgeList;
    
    return pagerData;
    
  }

  

  /// 查询短语列表
  static Future<ManageKnowledgePagerModel> getEnPhraseKnowledgeList({
    int knowledgeOffset = 0,
    int knowledgeLimit = 20,
    String? content,
    List<String>? uids,
    String? fullContent,
    String? order,
    List<ManageKnowledgeTableModel>? initSelectedIds,
  }) async {
    ManageKnowledgePagerModel pagerData = ManageKnowledgePagerModel();

    Map<String, dynamic> parameters = {
      "offset": knowledgeOffset,
      "limit": knowledgeLimit,
      "order": order??"-wordFreq,-uid",
    };
    Map<String, dynamic> data = {};
    if(content != null && content.isNotEmpty){
      data["content"] = content;
    }
    if(uids != null && uids.isNotEmpty){
      data["uid"] = uids;
    }
    if(fullContent != null && fullContent.isNotEmpty){
      data["fullContent"] = fullContent;
    }

    ListResponseEntity<EnPhraseEntity>? res = await ManageSelectQuziKnowledge.getEnPhraseKnowledgeList(parameters: parameters, data: data);
    if (res == null) return pagerData;
    pagerData.count = res.count ?? 0;
    pagerData.offset = res.offset??0;
    pagerData.limit = res.limit??0;

    List<EnPhraseEntity> datas = res.datas ?? [];
    List<ManageKnowledgeTableModel> _allKnowledgeList = [];

    for (var element in datas) {
      String id = "${element.contentType}_${element.uid}";
      _allKnowledgeList.add(ManageKnowledgeTableModel(
        id: id,
        type: ElementsCardType.phrase,
        phrase: element,
        isSelected: initSelectedIds?.any((e) => e.id == id)??false,
        enableSelect: initSelectedIds?.firstWhereOrNull((item) => item.id == id)?.enableSelect ?? true,
      ));
    }

    pagerData.datas = _allKnowledgeList;
    
    return pagerData;
  }

  /// 查询句子列表
  static Future<ManageKnowledgePagerModel> getEnSentenceKnowledgeList({
    int knowledgeOffset = 0,
    int knowledgeLimit = 20,
    String? content,
    List<String>? uids,
    String? fullContent,
    String? order,
    List<ManageKnowledgeTableModel>? initSelectedIds,
  }) async {
    ManageKnowledgePagerModel pagerData = ManageKnowledgePagerModel();

    Map<String, dynamic> parameters = {
      "offset": knowledgeOffset,
      "limit": knowledgeLimit,
      "order": order??"-uid",
    };
    Map<String, dynamic> data = {};
    if(content != null && content.isNotEmpty){
      data["content"] = content;
    }
    if(uids != null && uids.isNotEmpty){
      data["uid"] = uids;
    }
    if(fullContent != null && fullContent.isNotEmpty){
      data["fullContent"] = fullContent;
    }

    ListResponseEntity<EnSentenceEntity>? res = await ManageSelectQuziKnowledge.getEnSentenceKnowledgeList(parameters: parameters, data: data);
    if (res == null) return pagerData;
    pagerData.count = res.count ?? 0;
    pagerData.offset = res.offset??0;
    pagerData.limit = res.limit??0;

    List<EnSentenceEntity> datas = res.datas ?? [];
    List<ManageKnowledgeTableModel> _allKnowledgeList = [];

    for (var element in datas) {
      String id = "${element.contentType}_${element.uid}";
      _allKnowledgeList.add(ManageKnowledgeTableModel(
        id: id,
        type: ElementsCardType.sentence,
        sentence: element,
        isSelected: initSelectedIds?.any((e) => e.id == id)??false,
        enableSelect: initSelectedIds?.firstWhereOrNull((item) => item.id == id)?.enableSelect ?? true,
      ));
    }

    pagerData.datas = _allKnowledgeList;
    
    return pagerData;
    
    
  }

  /// 查询文章列表
  static Future<ManageKnowledgePagerModel> getEnTextKnowledgeList({
    int knowledgeOffset = 0,
    int knowledgeLimit = 20,
    String? content,
    List<String>? uids,
    String? order,
    List<ManageKnowledgeTableModel>? initSelectedIds,
  }) async {
    ManageKnowledgePagerModel pagerData = ManageKnowledgePagerModel();

    Map<String, dynamic> parameters = {
      "offset": knowledgeOffset,
      "limit": knowledgeLimit,
      "order": order??"-uid",
    };
    Map<String, dynamic> data = {};
    if(content != null && content.isNotEmpty){
      data["content"] = content;
    }
    if(uids != null && uids.isNotEmpty){
      data["uid"] = uids;
    }

    ListResponseEntity<EnTextEntity>? res = await ManageSelectQuziKnowledge.getEnTextKnowledgeList(parameters: parameters, data: data);
    if (res == null) return pagerData;
    pagerData.count = res.count ?? 0;
    pagerData.offset = res.offset??0;
    pagerData.limit = res.limit??0;

    List<EnTextEntity> datas = res.datas ?? [];
    List<ManageKnowledgeTableModel> _allKnowledgeList = [];

    for (var element in datas) {
      String id = "${element.contentType}_${element.uid}";
      _allKnowledgeList.add(ManageKnowledgeTableModel(
        id: id,
        type: ElementsCardType.text,
        text: element,
        isSelected: initSelectedIds?.any((e) => e.id == id)??false,
        enableSelect: initSelectedIds?.firstWhereOrNull((item) => item.id == id)?.enableSelect ?? true,
      ));
    }

    pagerData.datas = _allKnowledgeList;
    
    return pagerData;
    
    
  }

  /// 查询甄听列表
  static Future<ManageKnowledgePagerModel> getEnRevealsKnowledgeList({
    int knowledgeOffset = 0,
    int knowledgeLimit = 20,
    String? content,
    List<String>? uids,
    String? order,
    List<ManageKnowledgeTableModel>? initSelectedIds,
  }) async {
    ManageKnowledgePagerModel pagerData = ManageKnowledgePagerModel();

    Map<String, dynamic> parameters = {
      "offset": knowledgeOffset,
      "limit": knowledgeLimit,
      "order": order??"-uid",
    };
    Map<String, dynamic> data = {};
    if(content != null && content.isNotEmpty){
      data["content"] = content;
    }
    if(uids != null && uids.isNotEmpty){
      data["uids"] = uids;
    }

    ListResponseEntity<EnTextEntity>? res = await ManageSelectQuziKnowledge.getEnRevealsKnowledgeList(parameters: parameters, data: data);
    if (res == null) return pagerData;
    pagerData.count = res.count ?? 0;
    pagerData.offset = res.offset??0;
    pagerData.limit = res.limit??0;

    List<EnTextEntity> datas = res.datas ?? [];
    List<ManageKnowledgeTableModel> _allKnowledgeList = [];

    for (var element in datas) {
      String id = "${element.contentType}_${element.uid}";
      _allKnowledgeList.add(ManageKnowledgeTableModel(
        id: id,
        type: ElementsCardType.reveal,
        reveal: element,
        isSelected: initSelectedIds?.any((e) => e.id == id)??false,
        enableSelect: initSelectedIds?.firstWhereOrNull((item) => item.id == id)?.enableSelect ?? true,
      ));
    }

    pagerData.datas = _allKnowledgeList;
    
    return pagerData;
    
    
  }

}