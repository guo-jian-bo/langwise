
对照按格候选
/language-console/en/sentence/pair/state_sentence_type_contrast/sentence/realization/set/pair/cell/candidates
请求体
{
  "cell": "from",
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


对照绑定校验
/language-console/en/sentence/pair/state_sentence_type_contrast/sentence/realization/set/pair/bind/check
请求体
{
  "cell": "from",
  "sentenceId": "504941"
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

对照整套校验
/language-console/en/sentence/pair/state_sentence_type_contrast/sentence/realization/set/pair/match/check
请求体
{
  "fromSentenceId": "154505",
  "toSentenceId": "575882"
}

结果用[PatternRealizationSetPatternMatchCheckEntity]接受
{
  "code": 200,
  "data": {
    "ok": true,
    "failures": []
  }
}

对照创建例句组合
/language-console/en/sentence/pair/$nid/sentence/realization/set/pair/create

请求体
{
  "fromSentenceId": "154505",
  "toSentenceId": "575882",
  "matchFirst": false
}