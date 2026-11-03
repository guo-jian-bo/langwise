查询候选
/language-console/en/sentence/paradigm/regret_complement_realization/sentence/realization/set/paradigm/candidates
请求体
{
  "sentenceId": "555078"
}

结果
{
  "code": 200,
  "data": {
    "paradigmNid": "regret_complement_realization",
    "anchor": {
      "valueNid": "regret_doing",
      "sentenceId": 555078,
      "patternNid": "emotion_entity_regret_doing"
    },
    "members": [
      {
        "valueNid": "regret_doing",
        "patternNid": "emotion_entity_regret_doing",
        "scrolled": 1,
        "hardPassed": 1,
        "failureCounts": {},
        "matches": [
          {
            "valueNid": "regret_doing",
            "patternNid": "emotion_entity_regret_doing",
            "sentenceId": 555078,
            "text": "He regretted continuing the endless journey.",
            "matchedClauseId": 137706,
            "wordCount": 6,
            "carry": {
              "subject": {
                "text": "He",
                "normalizedText": "he",
                "lemmaIds": [
                  120287
                ],
                "semanticIds": [
                  689343
                ],
                "lookupStatuses": [
                  "matched_exact"
                ],
                "present": true
              }
            },
            "focusEvidence": {
              "declaredPatternSlotKeys": [
                "gerund_activity"
              ],
              "declaredTemplateLiterals": [],
              "coveredPatternSlotKeys": [
                "gerund_activity"
              ],
              "coveredTemplateLiterals": [],
              "zeroSurfacePatternSlotKeys": [],
              "missingPatternSlotKeys": [],
              "missingTemplateLiterals": [],
              "ranges": [
                {
                  "start": 13,
                  "end": 43,
                  "text": "continuing the endless journey",
                  "source": "slot",
                  "key": "gerund_activity"
                }
              ],
              "passes": true,
              "formatWarnings": []
            },
            "svocaCodeNid": "svo"
          }
        ],
        "rejectionSamples": []
      },
      {
        "valueNid": "regret_to_do",
        "patternNid": "emotion_entity_regret_to_do",
        "scrolled": 4,
        "hardPassed": 4,
        "failureCounts": {},
        "matches": [
          {
            "valueNid": "regret_to_do",
            "patternNid": "emotion_entity_regret_to_do",
            "sentenceId": 577630,
            "text": "She regrets to say that the flight has been cancelled.",
            "matchedClauseId": 161940,
            "wordCount": 10,
            "carry": {
              "subject": {
                "text": "She",
                "normalizedText": "she",
                "lemmaIds": [
                  138807
                ],
                "semanticIds": [
                  714406
                ],
                "lookupStatuses": [
                  "matched_exact"
                ],
                "present": true
              }
            },
            "focusEvidence": {
              "declaredPatternSlotKeys": [
                "embedded_action"
              ],
              "declaredTemplateLiterals": [
                "to"
              ],
              "coveredPatternSlotKeys": [
                "embedded_action"
              ],
              "coveredTemplateLiterals": [
                "to"
              ],
              "zeroSurfacePatternSlotKeys": [],
              "missingPatternSlotKeys": [],
              "missingTemplateLiterals": [],
              "ranges": [
                {
                  "start": 12,
                  "end": 18,
                  "text": "to say",
                  "sources": [
                    {
                      "source": "literal",
                      "key": "to"
                    },
                    {
                      "source": "slot",
                      "key": "embedded_action"
                    }
                  ]
                }
              ],
              "passes": true,
              "formatWarnings": []
            },
            "svocaCodeNid": "svo"
          },
          {
            "valueNid": "regret_to_do",
            "patternNid": "emotion_entity_regret_to_do",
            "sentenceId": 577706,
            "text": "They regret to inform you that the flight has been cancelled.",
            "matchedClauseId": 161988,
            "wordCount": 11,
            "carry": {
              "subject": {
                "text": "They",
                "normalizedText": "they",
                "lemmaIds": [
                  143588
                ],
                "semanticIds": [
                  721343
                ],
                "lookupStatuses": [
                  "matched_exact"
                ],
                "present": true
              }
            },
            "focusEvidence": {
              "declaredPatternSlotKeys": [
                "embedded_action"
              ],
              "declaredTemplateLiterals": [
                "to"
              ],
              "coveredPatternSlotKeys": [
                "embedded_action"
              ],
              "coveredTemplateLiterals": [
                "to"
              ],
              "zeroSurfacePatternSlotKeys": [],
              "missingPatternSlotKeys": [],
              "missingTemplateLiterals": [],
              "ranges": [
                {
                  "start": 12,
                  "end": 60,
                  "text": "to inform you that the flight has been cancelled",
                  "sources": [
                    {
                      "source": "literal",
                      "key": "to"
                    },
                    {
                      "source": "slot",
                      "key": "embedded_action"
                    }
                  ]
                }
              ],
              "passes": true,
              "formatWarnings": []
            },
            "svocaCodeNid": "svo"
          },
          {
            "valueNid": "regret_to_do",
            "patternNid": "emotion_entity_regret_to_do",
            "sentenceId": 577605,
            "text": "He regrets to say that he refused to join in the activity.",
            "matchedClauseId": 161902,
            "wordCount": 12,
            "carry": {
              "subject": {
                "text": "He",
                "normalizedText": "he",
                "lemmaIds": [
                  120287
                ],
                "semanticIds": [
                  689343
                ],
                "lookupStatuses": [
                  "matched_exact"
                ],
                "present": true
              }
            },
            "focusEvidence": {
              "declaredPatternSlotKeys": [
                "embedded_action"
              ],
              "declaredTemplateLiterals": [
                "to"
              ],
              "coveredPatternSlotKeys": [
                "embedded_action"
              ],
              "coveredTemplateLiterals": [
                "to"
              ],
              "zeroSurfacePatternSlotKeys": [],
              "missingPatternSlotKeys": [],
              "missingTemplateLiterals": [],
              "ranges": [
                {
                  "start": 14,
                  "end": 57,
                  "text": "say that he refused to join in the activity",
                  "sources": [
                    {
                      "source": "slot",
                      "key": "embedded_action"
                    },
                    {
                      "source": "literal",
                      "key": "to"
                    }
                  ]
                }
              ],
              "passes": true,
              "formatWarnings": []
            },
            "svocaCodeNid": "svo"
          },
          {
            "valueNid": "regret_to_do",
            "patternNid": "emotion_entity_regret_to_do",
            "sentenceId": 578897,
            "text": "She regrets to say that he refused to join in the activity.",
            "matchedClauseId": 162905,
            "wordCount": 12,
            "carry": {
              "subject": {
                "text": "She",
                "normalizedText": "she",
                "lemmaIds": [
                  138807
                ],
                "semanticIds": [
                  714406
                ],
                "lookupStatuses": [
                  "matched_exact"
                ],
                "present": true
              }
            },
            "focusEvidence": {
              "declaredPatternSlotKeys": [
                "embedded_action"
              ],
              "declaredTemplateLiterals": [
                "to"
              ],
              "coveredPatternSlotKeys": [
                "embedded_action"
              ],
              "coveredTemplateLiterals": [
                "to"
              ],
              "zeroSurfacePatternSlotKeys": [],
              "missingPatternSlotKeys": [],
              "missingTemplateLiterals": [],
              "ranges": [
                {
                  "start": 15,
                  "end": 58,
                  "text": "say that he refused to join in the activity",
                  "sources": [
                    {
                      "source": "slot",
                      "key": "embedded_action"
                    },
                    {
                      "source": "literal",
                      "key": "to"
                    }
                  ]
                }
              ],
              "passes": true,
              "formatWarnings": []
            },
            "svocaCodeNid": "svo"
          }
        ],
        "rejectionSamples": []
      }
    ],
    "sets": [
      {
        "score": 0.9625,
        "scoreBreakdown": {
          "carry": 1.0,
          "lengthSimilarity": 0.75,
          "visibleFocusRatio": 1.0,
          "total": 0.9625
        },
        "bindings": [
          {
            "valueNid": "regret_doing",
            "patternNid": "emotion_entity_regret_doing",
            "sentenceId": 555078,
            "text": "He regretted continuing the endless journey.",
            "matchedClauseId": 137706,
            "wordCount": 6,
            "carry": {
              "subject": {
                "text": "He",
                "normalizedText": "he",
                "lemmaIds": [
                  120287
                ],
                "semanticIds": [
                  689343
                ],
                "lookupStatuses": [
                  "matched_exact"
                ],
                "present": true
              }
            },
            "focusEvidence": {
              "declaredPatternSlotKeys": [
                "gerund_activity"
              ],
              "declaredTemplateLiterals": [],
              "coveredPatternSlotKeys": [
                "gerund_activity"
              ],
              "coveredTemplateLiterals": [],
              "zeroSurfacePatternSlotKeys": [],
              "missingPatternSlotKeys": [],
              "missingTemplateLiterals": [],
              "ranges": [
                {
                  "start": 13,
                  "end": 43,
                  "text": "continuing the endless journey",
                  "source": "slot",
                  "key": "gerund_activity"
                }
              ],
              "passes": true,
              "formatWarnings": []
            },
            "svocaCodeNid": "svo"
          },
          {
            "valueNid": "regret_to_do",
            "patternNid": "emotion_entity_regret_to_do",
            "sentenceId": 577605,
            "text": "He regrets to say that he refused to join in the activity.",
            "matchedClauseId": 161902,
            "wordCount": 12,
            "carry": {
              "subject": {
                "text": "He",
                "normalizedText": "he",
                "lemmaIds": [
                  120287
                ],
                "semanticIds": [
                  689343
                ],
                "lookupStatuses": [
                  "matched_exact"
                ],
                "present": true
              }
            },
            "focusEvidence": {
              "declaredPatternSlotKeys": [
                "embedded_action"
              ],
              "declaredTemplateLiterals": [
                "to"
              ],
              "coveredPatternSlotKeys": [
                "embedded_action"
              ],
              "coveredTemplateLiterals": [
                "to"
              ],
              "zeroSurfacePatternSlotKeys": [],
              "missingPatternSlotKeys": [],
              "missingTemplateLiterals": [],
              "ranges": [
                {
                  "start": 14,
                  "end": 57,
                  "text": "say that he refused to join in the activity",
                  "sources": [
                    {
                      "source": "slot",
                      "key": "embedded_action"
                    },
                    {
                      "source": "literal",
                      "key": "to"
                    }
                  ]
                }
              ],
              "passes": true,
              "formatWarnings": []
            },
            "svocaCodeNid": "svo"
          }
        ]
      }
    ],
    "partialSeeds": [
      {
        "score": 11.0,
        "scoreBreakdown": {
          "keptCount": 1,
          "fillCount": 1,
          "carry": 1.0,
          "lengthSimilarity": 1.0,
          "visibleFocusRatio": 1.0,
          "total": 1.0
        },
        "keptBindings": [
          {
            "valueNid": "regret_to_do",
            "patternNid": "emotion_entity_regret_to_do",
            "sentenceId": 577630,
            "text": "She regrets to say that the flight has been cancelled.",
            "matchedClauseId": 161940,
            "wordCount": 10,
            "carry": {
              "subject": {
                "text": "She",
                "normalizedText": "she",
                "lemmaIds": [
                  138807
                ],
                "semanticIds": [
                  714406
                ],
                "lookupStatuses": [
                  "matched_exact"
                ],
                "present": true
              }
            },
            "focusEvidence": {
              "declaredPatternSlotKeys": [
                "embedded_action"
              ],
              "declaredTemplateLiterals": [
                "to"
              ],
              "coveredPatternSlotKeys": [
                "embedded_action"
              ],
              "coveredTemplateLiterals": [
                "to"
              ],
              "zeroSurfacePatternSlotKeys": [],
              "missingPatternSlotKeys": [],
              "missingTemplateLiterals": [],
              "ranges": [
                {
                  "start": 12,
                  "end": 18,
                  "text": "to say",
                  "sources": [
                    {
                      "source": "literal",
                      "key": "to"
                    },
                    {
                      "source": "slot",
                      "key": "embedded_action"
                    }
                  ]
                }
              ],
              "passes": true,
              "formatWarnings": []
            },
            "svocaCodeNid": "svo"
          }
        ],
        "fillValueNids": [
          "regret_doing"
        ],
        "carryValues": {
          "subject": "She"
        },
        "source": "corpus_partial"
      },
      {
        "score": 11.0,
        "scoreBreakdown": {
          "keptCount": 1,
          "fillCount": 1,
          "carry": 1.0,
          "lengthSimilarity": 1.0,
          "visibleFocusRatio": 1.0,
          "total": 1.0
        },
        "keptBindings": [
          {
            "valueNid": "regret_to_do",
            "patternNid": "emotion_entity_regret_to_do",
            "sentenceId": 577706,
            "text": "They regret to inform you that the flight has been cancelled.",
            "matchedClauseId": 161988,
            "wordCount": 11,
            "carry": {
              "subject": {
                "text": "They",
                "normalizedText": "they",
                "lemmaIds": [
                  143588
                ],
                "semanticIds": [
                  721343
                ],
                "lookupStatuses": [
                  "matched_exact"
                ],
                "present": true
              }
            },
            "focusEvidence": {
              "declaredPatternSlotKeys": [
                "embedded_action"
              ],
              "declaredTemplateLiterals": [
                "to"
              ],
              "coveredPatternSlotKeys": [
                "embedded_action"
              ],
              "coveredTemplateLiterals": [
                "to"
              ],
              "zeroSurfacePatternSlotKeys": [],
              "missingPatternSlotKeys": [],
              "missingTemplateLiterals": [],
              "ranges": [
                {
                  "start": 12,
                  "end": 60,
                  "text": "to inform you that the flight has been cancelled",
                  "sources": [
                    {
                      "source": "literal",
                      "key": "to"
                    },
                    {
                      "source": "slot",
                      "key": "embedded_action"
                    }
                  ]
                }
              ],
              "passes": true,
              "formatWarnings": []
            },
            "svocaCodeNid": "svo"
          }
        ],
        "fillValueNids": [
          "regret_doing"
        ],
        "carryValues": {
          "subject": "They"
        },
        "source": "corpus_partial"
      },
      {
        "score": 11.0,
        "scoreBreakdown": {
          "keptCount": 1,
          "fillCount": 1,
          "carry": 1.0,
          "lengthSimilarity": 1.0,
          "visibleFocusRatio": 1.0,
          "total": 1.0
        },
        "keptBindings": [
          {
            "valueNid": "regret_to_do",
            "patternNid": "emotion_entity_regret_to_do",
            "sentenceId": 578897,
            "text": "She regrets to say that he refused to join in the activity.",
            "matchedClauseId": 162905,
            "wordCount": 12,
            "carry": {
              "subject": {
                "text": "She",
                "normalizedText": "she",
                "lemmaIds": [
                  138807
                ],
                "semanticIds": [
                  714406
                ],
                "lookupStatuses": [
                  "matched_exact"
                ],
                "present": true
              }
            },
            "focusEvidence": {
              "declaredPatternSlotKeys": [
                "embedded_action"
              ],
              "declaredTemplateLiterals": [
                "to"
              ],
              "coveredPatternSlotKeys": [
                "embedded_action"
              ],
              "coveredTemplateLiterals": [
                "to"
              ],
              "zeroSurfacePatternSlotKeys": [],
              "missingPatternSlotKeys": [],
              "missingTemplateLiterals": [],
              "ranges": [
                {
                  "start": 15,
                  "end": 58,
                  "text": "say that he refused to join in the activity",
                  "sources": [
                    {
                      "source": "slot",
                      "key": "embedded_action"
                    },
                    {
                      "source": "literal",
                      "key": "to"
                    }
                  ]
                }
              ],
              "passes": true,
              "formatWarnings": []
            },
            "svocaCodeNid": "svo"
          }
        ],
        "fillValueNids": [
          "regret_doing"
        ],
        "carryValues": {
          "subject": "She"
        },
        "source": "corpus_partial"
      }
    ],
    "incompleteMembers": [],
    "excludedSentenceIds": [
      577656
    ],
    "elapsedMs": 68
  }
}


对照按格候选
/language-console/en/sentence/paradigm/state_sentence_type_contrast/sentence/realization/set/paradigm/cell/candidates
请求体
{
  "valueNid": "yes_no_question",
  "boundSentenceIds": [
    154200,
    154237,
    154199,
    ...
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
/language-console/en/sentence/paradigm/state_sentence_type_contrast/sentence/realization/set/paradigm/bind/check
请求体
{
  "valueNid": "yes_no_question",
  "sentenceId": "154199"
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
/language-console/en/sentence/paradigm/state_sentence_type_contrast/sentence/realization/set/paradigm/match/check
请求体
{
  "bindings": [
    {
      "valueNid": "declarative",
      "sentenceId": 154172
    },
    {
      "valueNid": "yes_no_question",
      "sentenceId": 154197
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

对照创建例句组合
/language-console/en/sentence/paradigm/$nid/sentence/realization/set/paradigm/create

请求体
{
  "bindings": [
    {
      "valueNid": "declarative",
      "sentenceId": 154172
    },
    {
      "valueNid": "yes_no_question",
      "sentenceId": 154197
    }
  ],
  "matchFirst": false
}