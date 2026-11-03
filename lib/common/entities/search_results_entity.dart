import 'package:langwise/common/entities/entities.dart';


class SearchResultsEntityFilters {
/*
{
  "code": "",
  "values": [
    ""
  ]
} 
*/

  String? code;
  List<String?>? values;

  SearchResultsEntityFilters({
    this.code,
    this.values,
  });
  SearchResultsEntityFilters.fromJson(Map<String, dynamic> json) {
    code = json['code']?.toString();
    if (json['values'] != null) {
      final v = json['values'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      values = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    if (values != null) {
      final v = values;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['values'] = arr0;
    }
    return data;
  }
}

class SearchResultsEntity {
/*
{
  "query": "今天真的很难过的歌曲",
  "effectiveQuery": "今天真的很难过的歌曲",
  "queryLang": "zh",
  "filters": [
    {
      "code": "",
      "values": [
        ""
      ]
    }
  ],
  "offset": 0,
  "limit": 30,
  "primaryIntent": "content",
  "searchPlan": "content_only",
  "count": 60,
  "datas": [
    {
      "contentType": "EN_SONG",
      "contentTypeTitle": "Song",
      "contentId": 45329,
      "content": {
        "type": "EN_SONG",
        "uid": 45329
      },
      "title": "How Do You Feel Today?",
      "subTitle": "Hello, hello, how do you feel?\nTell me now, if it's real.\nI am excited on a sunny day.\nShe is angry, but it's okay.\nThey are sad when things go wrong.\nWe are worried, but we stay strong.\nHow do you feel?\nHow do you feel?\nI am glad, and you, it's a big deal.\nShare your emotions loud and clear.\nHappy or sad, we have nothing to fear.\nHe looks worried, why is that?\nWith a friend, we have a chat.\nI saw her yesterday.\nShe was glad, now she's excited, not too sad.\nHow do you feel?\nHow do you feel?\nI am glad, and you, it's a big deal.\nShare your emotions loud and clear.\nHappy or sad, we have nothing to fear.\nDon't worry, don't be poor in spirit.\nHelpful words can bring us near.\nWhy are you late? It's not too bad.\nTogether we were happy, not angry or sad.\nFeelings, feelings, all around.\nIn our hearts, they can be found.",
      "description": [
        {
          "lang": "zh",
          "text": "这是一首以情绪为主题的英语儿歌，体裁为中国民谣儿歌（Chinese Folk Kids），难度约A1。歌词通过重复的问答句式介绍excited、angry、sad、worried、glad等常见情绪词汇，并鼓励孩子大声分享感受，整体旋律轻快、易于跟唱。适合小学低年级、约6-9岁的学习者，用于情绪词汇启蒙和跟唱练习。"
        }
      ],
      "focus": [
        {
          "lang": "zh",
          "text": "情绪主题英语儿歌；情绪词汇（excited/angry/sad/worried/glad）；A1 跟唱启蒙；中国民谣儿歌风格；适龄小学低年级 / 约6-9岁；重复问答句式；鼓励表达感受"
        }
      ],
      "coverImage": {
        "type": "image",
        "mediaId": 4609436,
        "url": "https://img.timelywise.cn/knowledge/semantic/3986ECA0CD5AC6DDAE3541A09A939DEF.webp?auth_key=1782997216-w57s206ukp1z-0-9038232c3854fb05a56eddf4f3dbfe13",
        "key": "knowledge/semantic/3986ECA0CD5AC6DDAE3541A09A939DEF.webp",
        "md5": "3986ECA0CD5AC6DDAE3541A09A939DEF"
      },
      "coverVideo": null,
      "category": {
        "text": "Feelings & Emotions"
      },
      "subCategory": {
        "text": "Chinese Folk Kids"
      },
      "tags": [
        {
          "gloss": [
            {
              "lang": "en",
              "text": "Feelings & Emotions"
            }
          ],
          "style": [
            {
              "theme": "LIGHT",
              "color": "rgba(245, 158, 11, 1)",
              "fontsize": 16,
              "italic": false,
              "weight": 400,
              "backgroundColor": "rgba(245, 158, 11, 0.20)"
            }
          ]
        }
      ],
      "params": null,
      "rights": {
        "access": "NORMAL",
        "rights": "NORMAL"
      },
      "progress": {
        "type": "all",
        "progress": 100,
        "status": 1
      },
      "learnModules": [
        {
          "type": "listen",
          "progress": 100,
          "status": 1
        }
      ],
      "jump": {
        "code": "songMV",
        "params": {
          "contents": [
            {
              "contentId": 45329,
              "contentType": "EN_SONG"
            }
          ],
          "contentId": 45329,
          "contentType": "EN_SONG"
        }
      }
    }
  ]
} 
*/

  String? query;
  String? effectiveQuery;
  String? queryLang;
  List<SearchResultsEntityFilters?>? filters;
  int? offset;
  int? limit;
  String? primaryIntent;
  String? searchPlan;
  int? count;
  List<KnowledgeCommonEntityList?>? datas;

  SearchResultsEntity({
    this.query,
    this.effectiveQuery,
    this.queryLang,
    this.filters,
    this.offset,
    this.limit,
    this.primaryIntent,
    this.searchPlan,
    this.count,
    this.datas,
  });
  SearchResultsEntity.fromJson(Map<String, dynamic> json) {
    query = json['query']?.toString();
    effectiveQuery = json['effectiveQuery']?.toString();
    queryLang = json['queryLang']?.toString();
    if (json['filters'] != null) {
      final v = json['filters'];
      final arr0 = <SearchResultsEntityFilters>[];
      v.forEach((v) {
        arr0.add(SearchResultsEntityFilters.fromJson(v));
      });
      filters = arr0;
    }
    offset = json['offset']?.toInt();
    limit = json['limit']?.toInt();
    primaryIntent = json['primaryIntent']?.toString();
    searchPlan = json['searchPlan']?.toString();
    count = json['count']?.toInt();
    if (json['datas'] != null) {
      final v = json['datas'];
      final arr0 = <KnowledgeCommonEntityList>[];
      v.forEach((v) {
        arr0.add(KnowledgeCommonEntityList.fromJson(v));
      });
      datas = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['query'] = query;
    data['effectiveQuery'] = effectiveQuery;
    data['queryLang'] = queryLang;
    if (filters != null) {
      final v = filters;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['filters'] = arr0;
    }
    data['offset'] = offset;
    data['limit'] = limit;
    data['primaryIntent'] = primaryIntent;
    data['searchPlan'] = searchPlan;
    data['count'] = count;
    if (datas != null) {
      final v = datas;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['datas'] = arr0;
    }
    return data;
  }
}
