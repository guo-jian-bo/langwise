
按格候选
/language-console/en/sentence/pair/fork/ask_can_i_pred_modal_can_to_response_clause_polarity/sentence/realization/set/pair-fork/cell/candidates
请求体
{
  "cell": "to",
  "valueNid": "affirmative",
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


绑定校验
/language-console/en/sentence/pair/fork/ask_can_i_pred_modal_can_to_response_clause_polarity/sentence/realization/set/pair-fork/bind/check
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
/language-console/en/sentence/pair/fork/ask_can_i_pred_modal_can_to_response_clause_polarity/sentence/realization/set/pair-fork/match/check
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
/language-console/en/sentence/pair/fork/ask_can_i_pred_modal_can_to_response_clause_polarity/sentence/realization/set/pair-fork/create

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