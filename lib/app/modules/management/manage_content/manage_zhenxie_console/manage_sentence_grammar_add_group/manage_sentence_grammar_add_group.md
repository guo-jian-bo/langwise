
grid全景候选例句
/language-console/en/sentence/grid/state_time_polarity_grid/sentence/realization/set/grid/candidates

请求体
{
  "sentenceId": "153970"
}

结果用 [PatternRealizationSetPatternCellCandidatesEntity] 接收候选句
{
  "code": 200,
  "data": {
    "candidates": [],
    "emptyReason": "no_corpus_candidates"
  }
}

grid全景候选例句
/language-console/en/sentence/grid/state_time_polarity_grid/sentence/realization/set/grid/cell/candidates
请求体
{
  "cell": "to",
  "valueNid": "affirmative",
  "axisValues": {
    "": ""
  },
  "boundSentenceIds": [
    "154505"
  ]
}
结果用 [PatternRealizationSetPatternCellCandidatesEntity] 接收候选句
{
  "code": 200,
  "data": {
    "candidates": [],
    "emptyReason": "no_corpus_candidates"
  }
}

grid全景按格候选
/language-console/en/sentence/grid/state_sentence_type_contrast/sentence/realization/set/grid/bind/check
请求体
{
  "cell": "from",
  "sentenceId": "504941",
  "valueNid": "negative"
}

结果
{
  "code": 200,
  "data": {
    "ok": true,
    "reason": null,
    "sentenceId": 154199,
    "text": "Is the pillow new?",
    "valueNid": "yes_no_question",
    "patternNid": "ask_be_yes_no"
  }
}

整套校验
/language-console/en/sentence/grid/state_sentence_type_contrast/sentence/realization/set/grid/match/check
请求体
{
  "fromSentenceId": "504941",
  "bindings": [
    {
      "valueNid": "negative",
      "sentenceId": 575906
    },
    {
      "valueNid": "affirmative",
      "sentenceId": 504922
    }
  ]
}

结果用[PatternRealizationSetPatternMatchCheckEntity]接受
{
  "code": 200,
  "data": {
    "ok": true,
    "failures": []
  }
}

创建例句组合
/language-console/en/sentence/grid/$nid/sentence/realization/set/grid/create

请求体
{
  "fromSentenceId": "504941",
  "bindings": [
    {
      "valueNid": "negative",
      "sentenceId": 575906
    },
    {
      "valueNid": "affirmative",
      "sentenceId": 504922
    }
  ],
  "matchFirst": false
}