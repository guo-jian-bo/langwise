{
  "unitId": 14142,
  "target": {
    "uid": 35008,
    "pointOrder": 1,
    "order": 2,
    "status": "approved",
    "title": [
      {
        "lang": "zh",
        "text": "逐层扩展句子"
      },
      {
        "lang": "en",
        "text": "Expand sentence step by step"
      }
    ],
    "description": [
      {
        "lang": "zh",
        "text": "先出主体和be动词，再加动词ing形式，最后按顺序补入宾语对象、地点、时间等其他修饰成分。"
      },
      {
        "lang": "en",
        "text": "Start with the actor and be verb, then add the -ing verb, and add object, place, time and other modifiers in order."
      }
    ],
    "objective": {
      "outcome": "在 ongoing_entity_be_doing 基础上逐步加上 object",
      "dimensionNids": []
    },
    "grammarUnifiedInfo": {
      "type": "EN_SENTENCE_PYRAMID",
      "nid": "ongoing_entity_be_doing",
      "payload": {
        "nid": "ongoing_entity_be_doing",
        "name": [
          {
            "lang": "zh",
            "text": "说明正在做什么"
          },
          {
            "lang": "en",
            "text": "Say what is happening now"
          }
        ],
        "description": [
          {
            "lang": "zh",
            "text": "强调动作正在进行，像镜头对准此刻发生的事；和“一般做什么”不同。"
          },
          {
            "lang": "en",
            "text": "Emphasizes an action in progress, unlike a general “what someone does”."
          }
        ],
        "familyNid": "action_and_experience",
        "family": {
          "nid": "action_and_experience",
          "name": [
            {
              "lang": "zh",
              "text": "讲动作、经历和变化"
            },
            {
              "lang": "en",
              "text": "Talking About Actions, Experience, and Change"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "这一组句型帮助学习者讲清楚眼前正在发生什么、平时通常怎么做、过去经历过什么，以及这些经历和现在有什么联系。"
            },
            {
              "lang": "en",
              "text": "This group helps learners talk about what is happening now, what people usually do, what happened before, and how past experience still connects to the present."
            }
          ]
        },
        "difficulty": {
          "max": 2,
          "min": 1
        },
        "order": 495600,
        "blueprintScope": "clause",
        "patternTier": "core",
        "analysisEligible": true,
        "template": "{actor} {be_marking} {ongoing_predicate} {object} {place_phrase} {time_expression} {purpose_expression} {context_phrase} {relative_clause}.",
        "optionSlots": null,
        "controlledGrammarSlots": [
          {
            "slotKey": "aux_be",
            "rendersAs": "be_marking",
            "options": [
              "am",
              "is",
              "are",
              "'m",
              "'s",
              "'re",
              "was",
              "were",
              "will be",
              "'ll be"
            ],
            "activationFeatureNids": [
              "affirmative"
            ]
          },
          {
            "slotKey": "aux_be_negative",
            "rendersAs": "be_marking",
            "options": [
              "am not",
              "is not",
              "are not",
              "isn't",
              "aren't",
              "'m not",
              "'s not",
              "'re not",
              "was not",
              "were not",
              "wasn't",
              "weren't",
              "will not be",
              "won't be",
              "'ll not be"
            ],
            "activationFeatureNids": [
              "negative"
            ]
          }
        ],
        "controlledGrammarSlotList": [
          {
            "slotKey": "aux_be",
            "rendersAs": "be_marking",
            "slot": {
              "nid": "aux_be",
              "name": [
                {
                  "lang": "zh",
                  "text": "be（进行）"
                },
                {
                  "lang": "en",
                  "text": "be (helping)"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "帮助构成进行时：后面跟正在做的动作。am / is / was / will be 合在这一格，因为合起来才是谓语的完整时体，整块记，不要拆成 will 和 be。例如 She is reading a book. / She will be reading at eight."
                },
                {
                  "lang": "en",
                  "text": "Helps build the progressive: be + an action in progress. am / is / was / will be sit in one hole because together they are the predicate’s full tense-aspect — remember the chunk, don’t split will from be. Example: She is reading a book. / She will be reading at eight."
                }
              ],
              "categoryNid": "grammar_auxiliary",
              "color": "rgba(245,158,11,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "助动语法形式"
                },
                {
                  "lang": "en",
                  "text": "Auxiliary Grammar Form"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于控制 be、do、have、存在式或附加问句中的助动形式。"
                },
                {
                  "lang": "en",
                  "text": "Controls auxiliary forms for be, do, have, existential frames, or tag questions."
                }
              ]
            },
            "options": [
              "am",
              "is",
              "are",
              "'m",
              "'s",
              "'re",
              "was",
              "were",
              "will be",
              "'ll be"
            ],
            "activationFeatureNids": [
              "affirmative"
            ],
            "activationFeatures": [
              {
                "nid": "affirmative",
                "name": [
                  {
                    "lang": "zh",
                    "text": "肯定形式"
                  },
                  {
                    "lang": "en",
                    "text": "Affirmative"
                  }
                ],
                "description": [
                  {
                    "lang": "zh",
                    "text": "表示肯定、确认或直接陈述某事成立。"
                  },
                  {
                    "lang": "en",
                    "text": "Marks a positive statement, confirmation, or direct assertion that something holds true."
                  }
                ]
              }
            ]
          },
          {
            "slotKey": "aux_be_negative",
            "rendersAs": "be_marking",
            "slot": {
              "nid": "aux_be_negative",
              "name": [
                {
                  "lang": "zh",
                  "text": "be 不（进行）"
                },
                {
                  "lang": "en",
                  "text": "isn't (helping)"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "进行时的否定。isn't / wasn't / won't be 合在这一格，因为合起来才是否定谓语的完整时体，整块记。例如 She is not leaving tomorrow. / She won't be leaving at eight."
                },
                {
                  "lang": "en",
                  "text": "Negative helping be in progressive structures. isn't / wasn't / won't be sit in one hole because together they are the predicate’s full tense-aspect — remember the chunk. Example: She is not leaving tomorrow. / She won't be leaving at eight."
                }
              ],
              "categoryNid": "negative_auxiliary",
              "color": "rgba(245,158,11,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "显式否定语法形式"
                },
                {
                  "lang": "en",
                  "text": "Explicit Negative Grammar Form"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于直接承载否定完整式、缩写与允许的否定 clitic。"
                },
                {
                  "lang": "en",
                  "text": "Directly carries full negative forms, contractions, and allowed negative clitics."
                }
              ]
            },
            "options": [
              "am not",
              "is not",
              "are not",
              "isn't",
              "aren't",
              "'m not",
              "'s not",
              "'re not",
              "was not",
              "were not",
              "wasn't",
              "weren't",
              "will not be",
              "won't be",
              "'ll not be"
            ],
            "activationFeatureNids": [
              "negative"
            ],
            "activationFeatures": [
              {
                "nid": "negative",
                "name": [
                  {
                    "lang": "zh",
                    "text": "否定形式"
                  },
                  {
                    "lang": "en",
                    "text": "Negative"
                  }
                ],
                "description": [
                  {
                    "lang": "zh",
                    "text": "表示否定、不存在、不发生或不允许，常见于 not、never、no 等结构。"
                  },
                  {
                    "lang": "en",
                    "text": "Marks negation, absence, non-occurrence, or prohibition, often signaled by not, never, or no."
                  }
                ]
              }
            ]
          }
        ],
        "openSlots": [
          {
            "slotKey": "actor",
            "required": true,
            "grammarControlling": true,
            "growthPriority": null,
            "dependsOn": []
          },
          {
            "slotKey": "ongoing_predicate",
            "required": true,
            "grammarControlling": true,
            "growthPriority": null,
            "dependsOn": []
          },
          {
            "slotKey": "object",
            "required": false,
            "grammarControlling": true,
            "growthPriority": 10,
            "dependsOn": []
          },
          {
            "slotKey": "place_phrase",
            "required": false,
            "grammarControlling": true,
            "growthPriority": 30,
            "dependsOn": []
          },
          {
            "slotKey": "time_expression",
            "required": false,
            "grammarControlling": true,
            "growthPriority": 40,
            "dependsOn": []
          },
          {
            "slotKey": "purpose_expression",
            "required": false,
            "grammarControlling": true,
            "growthPriority": null,
            "dependsOn": []
          },
          {
            "slotKey": "context_phrase",
            "required": false,
            "grammarControlling": true,
            "growthPriority": null,
            "dependsOn": []
          },
          {
            "slotKey": "relative_clause",
            "required": false,
            "grammarControlling": false,
            "growthPriority": 80,
            "dependsOn": [
              "object"
            ]
          }
        ],
        "openSlotList": [
          {
            "slotKey": "actor",
            "slot": {
              "nid": "actor",
              "name": [
                {
                  "lang": "zh",
                  "text": "动作发出者"
                },
                {
                  "lang": "en",
                  "text": "Actor"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "表示真正发出这个动作的人或事物，也就是“是谁在做这件事”。"
                },
                {
                  "lang": "en",
                  "text": "Shows the subject in this meaning."
                }
              ],
              "categoryNid": "subject_entity",
              "color": "rgba(14,165,233,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "主语实体槽位"
                },
                {
                  "lang": "en",
                  "text": "Subject Entity Slot"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于填入执行者、承受者或句子讨论对象等主语成分。"
                },
                {
                  "lang": "en",
                  "text": "Used for the sentence subject, such as the doer, the affected entity, or the main topic under discussion."
                }
              ]
            },
            "required": true,
            "grammarControlling": true,
            "dependsOn": []
          },
          {
            "slotKey": "ongoing_predicate",
            "slot": {
              "nid": "ongoing_predicate",
              "name": [
                {
                  "lang": "zh",
                  "text": "正在进行的动作"
                },
                {
                  "lang": "en",
                  "text": "Ongoing Action"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "表示整句话里最核心的动作。用来表达正在发生或当前在说的事。"
                },
                {
                  "lang": "en",
                  "text": "Shows the core action of the sentence. It is used in present or ongoing situations."
                }
              ],
              "categoryNid": "verb_predicate",
              "color": "rgba(244,63,94,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "谓语槽位"
                },
                {
                  "lang": "en",
                  "text": "Predicate Slot"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于填入核心动作、状态或系表结构中的谓语部分。"
                },
                {
                  "lang": "en",
                  "text": "Used for the core predicate, including actions, states, or linking-verb structures."
                }
              ]
            },
            "required": true,
            "grammarControlling": true,
            "dependsOn": []
          },
          {
            "slotKey": "object",
            "slot": {
              "nid": "object",
              "name": [
                {
                  "lang": "zh",
                  "text": "宾语对象"
                },
                {
                  "lang": "en",
                  "text": "Object"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "表示动作直接作用到的对象，比如买什么、吃什么、带什么、看到什么。"
                },
                {
                  "lang": "en",
                  "text": "Shows the thing directly affected by the action, such as what is bought, eaten, taken, or seen."
                }
              ],
              "categoryNid": "object_entity",
              "color": "rgba(139,92,246,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "宾语实体槽位"
                },
                {
                  "lang": "en",
                  "text": "Object Entity Slot"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于填入动作影响的对象、接受者或结果对象。"
                },
                {
                  "lang": "en",
                  "text": "Used for the object affected by the action, the receiver, or the result entity."
                }
              ]
            },
            "required": false,
            "grammarControlling": true,
            "growthPriority": 10,
            "dependsOn": []
          },
          {
            "slotKey": "place_phrase",
            "slot": {
              "nid": "place_phrase",
              "name": [
                {
                  "lang": "zh",
                  "text": "地点短语"
                },
                {
                  "lang": "en",
                  "text": "Place Phrase"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "表示补充场景、地点、搭配或关系的短语。用来说明在哪里。"
                },
                {
                  "lang": "en",
                  "text": "Shows a phrase that adds setting, place, relation, or background. It is used to show where something is."
                }
              ],
              "categoryNid": "prepositional_phrase",
              "color": "rgba(20,184,166,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "介词短语槽位"
                },
                {
                  "lang": "en",
                  "text": "Prepositional Phrase Slot"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于填入 in the park、on the table 等完整介词短语。"
                },
                {
                  "lang": "en",
                  "text": "Used for full prepositional phrases such as in the park or on the table."
                }
              ]
            },
            "required": false,
            "grammarControlling": true,
            "growthPriority": 30,
            "dependsOn": []
          },
          {
            "slotKey": "time_expression",
            "slot": {
              "nid": "time_expression",
              "name": [
                {
                  "lang": "zh",
                  "text": "时间表达"
                },
                {
                  "lang": "en",
                  "text": "Time Expression"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "表示什么时候、持续多久、多久一次，或者先后顺序。"
                },
                {
                  "lang": "en",
                  "text": "Shows when something happens, how long it lasts, how often it happens, or where it falls in a sequence."
                }
              ],
              "categoryNid": "time_expression",
              "color": "rgba(0,188,125,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "时间槽位"
                },
                {
                  "lang": "en",
                  "text": "Time Expression Slot"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于填入表示时间点、时间段、频率或顺序的信息。"
                },
                {
                  "lang": "en",
                  "text": "Used for information expressing time point, duration, frequency, or sequence."
                }
              ]
            },
            "required": false,
            "grammarControlling": true,
            "growthPriority": 40,
            "dependsOn": []
          },
          {
            "slotKey": "purpose_expression",
            "slot": {
              "nid": "purpose_expression",
              "name": [
                {
                  "lang": "zh",
                  "text": "目的表达"
                },
                {
                  "lang": "en",
                  "text": "Purpose Expression"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "表示做这件事是为了什么，也就是动作想达到的目的。"
                },
                {
                  "lang": "en",
                  "text": "Shows what the action is done for: the purpose or intended result."
                }
              ],
              "categoryNid": "purpose_expression",
              "color": "rgba(132,204,22,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "目的槽位"
                },
                {
                  "lang": "en",
                  "text": "Purpose Expression Slot"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于填入目的、意图或目标导向信息。"
                },
                {
                  "lang": "en",
                  "text": "Used for purpose, intention, or goal-oriented information."
                }
              ]
            },
            "required": false,
            "grammarControlling": true,
            "dependsOn": []
          },
          {
            "slotKey": "context_phrase",
            "slot": {
              "nid": "context_phrase",
              "name": [
                {
                  "lang": "zh",
                  "text": "背景短语"
                },
                {
                  "lang": "en",
                  "text": "Context Phrase"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "表示动作或状态发生时的背景补充：常见为介词短语（地点、搭配、场景），也可为缩略的 V-ing 情状状语（如 entering Atlantic Daylight Time / walking home），不单独升成从句。"
                },
                {
                  "lang": "en",
                  "text": "Background adjunct for an action or state: often a PP (place, company, setting), and also a reduced V-ing circumstance adjunct (e.g. entering Atlantic Daylight Time / walking home), kept inside the clause rather than promoted."
                }
              ],
              "categoryNid": "lexical_chunk",
              "color": "rgba(59,130,246,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "词块槽位"
                },
                {
                  "lang": "en",
                  "text": "Lexical Chunk Slot"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于填入应整体保留的固定表达或高频搭配。"
                },
                {
                  "lang": "en",
                  "text": "Used for fixed expressions or high-frequency chunks that should be treated as whole units."
                }
              ]
            },
            "required": false,
            "grammarControlling": true,
            "dependsOn": []
          },
          {
            "slotKey": "relative_clause",
            "slot": {
              "nid": "relative_clause",
              "name": [
                {
                  "lang": "zh",
                  "text": "关系从句内容"
                },
                {
                  "lang": "en",
                  "text": "Relative Clause Content"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "表示跟在 who、that、which、where 后面，用来继续说明前面名词的那句话。"
                },
                {
                  "lang": "en",
                  "text": "Shows the clause that comes after who, that, which, or where to give more information about the noun before it."
                }
              ],
              "categoryNid": "clause_content",
              "color": "rgba(99,102,241,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "从句内容槽位"
                },
                {
                  "lang": "en",
                  "text": "Clause Content Slot"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于填入完整从句，如原因从句、条件从句、宾语从句等。"
                },
                {
                  "lang": "en",
                  "text": "Used for a full clause such as a reason clause, condition clause, or content clause."
                }
              ]
            },
            "required": false,
            "grammarControlling": false,
            "growthPriority": 80,
            "dependsOn": [
              "object"
            ]
          }
        ],
        "basicTypeNid": "simple",
        "basicType": {
          "nid": "simple",
          "name": [
            {
              "lang": "zh",
              "text": "简单句"
            },
            {
              "lang": "en",
              "text": "Simple Sentence"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "只包含一个独立分句的基础句型，是低阶教学和句型骨架训练的核心类型。"
            },
            {
              "lang": "en",
              "text": "A sentence with only one independent clause, forming the core type for foundational teaching and sentence skeleton practice."
            }
          ]
        },
        "functionalTypeNid": "declarative",
        "functionalType": {
          "nid": "declarative",
          "name": [
            {
              "lang": "zh",
              "text": "陈述句"
            },
            {
              "lang": "en",
              "text": "Declarative"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "用于陈述事实、观点、状态或信息，是写作与说明中最基础、最常见的句子功能类型。"
            },
            {
              "lang": "en",
              "text": "Used to state facts, ideas, states, or information; the most common functional sentence type in writing and explanation."
            }
          ]
        },
        "clauseProfileNid": "single_clause",
        "clauseProfile": {
          "nid": "single_clause",
          "name": [
            {
              "lang": "zh",
              "text": "单子句"
            },
            {
              "lang": "en",
              "text": "Single Clause"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "整个句型只包含一个核心子句，没有并列或从属扩展，是最基础的句型骨架。"
            },
            {
              "lang": "en",
              "text": "The pattern contains only one core clause with no coordination or subordination, forming the most basic sentence skeleton."
            }
          ]
        },
        "grammarFeatureNids": [
          "indicative_mood",
          "active_voice"
        ],
        "grammarFeatures": [
          {
            "nid": "indicative_mood",
            "name": [
              {
                "lang": "zh",
                "text": "陈述语气"
              },
              {
                "lang": "en",
                "text": "Indicative Mood"
              }
            ],
            "description": [
              {
                "lang": "zh",
                "text": "用于陈述事实、推断或一般信息，是英语中最常见的语气。"
              },
              {
                "lang": "en",
                "text": "Used to state facts, inferences, or general information; it is the most common mood in English."
              }
            ]
          },
          {
            "nid": "active_voice",
            "name": [
              {
                "lang": "zh",
                "text": "主动语态"
              },
              {
                "lang": "en",
                "text": "Active Voice"
              }
            ],
            "description": [
              {
                "lang": "zh",
                "text": "主语执行动作，表达更直接，常用于清楚说明施事者。"
              },
              {
                "lang": "en",
                "text": "The subject performs the action, giving a direct structure that clearly highlights the doer."
              }
            ]
          }
        ],
        "specialFeatureNids": [],
        "specialFeatures": [],
        "communicativeFunctionNids": [
          "describe",
          "narrate_event"
        ],
        "communicativeFunctions": [
          {
            "nid": "describe",
            "name": [
              {
                "lang": "zh",
                "text": "描述"
              },
              {
                "lang": "en",
                "text": "Describe"
              }
            ],
            "description": [
              {
                "lang": "zh",
                "text": "用于描写状态、动作、特征、位置、数量等，是最广泛的写作功能之一。"
              },
              {
                "lang": "en",
                "text": "Used to describe states, actions, features, locations, and quantities; one of the broadest functions in writing."
              }
            ]
          },
          {
            "nid": "narrate_event",
            "name": [
              {
                "lang": "zh",
                "text": "叙述事件"
              },
              {
                "lang": "en",
                "text": "Narrate Event"
              }
            ],
            "description": [
              {
                "lang": "zh",
                "text": "用于讲述发生了什么、按时间推进信息，常见于故事和经历写作。"
              },
              {
                "lang": "en",
                "text": "Used to tell what happened and move information through time, common in stories and experience writing."
              }
            ]
          }
        ],
        "discourseRoleNids": [
          "standalone_sentence",
          "supporting_detail"
        ],
        "discourseRoles": [
          {
            "nid": "standalone_sentence",
            "name": [
              {
                "lang": "zh",
                "text": "独立句"
              },
              {
                "lang": "en",
                "text": "Standalone Sentence"
              }
            ],
            "description": [
              {
                "lang": "zh",
                "text": "单独即可完成表达，不依赖上下文中的其他句子承担结构角色。"
              },
              {
                "lang": "en",
                "text": "Completes its communicative work on its own without depending on surrounding sentences for a structural role."
              }
            ]
          },
          {
            "nid": "supporting_detail",
            "name": [
              {
                "lang": "zh",
                "text": "支持细节句"
              },
              {
                "lang": "en",
                "text": "Supporting Detail"
              }
            ],
            "description": [
              {
                "lang": "zh",
                "text": "用于补充事实、细节、特征或说明，支撑主题句。"
              },
              {
                "lang": "en",
                "text": "Adds facts, details, features, or explanation to support the topic sentence."
              }
            ]
          }
        ],
        "teachingRealizations": [
          "She is reading.",
          "She is reading a book.",
          "She is reading a book in the library.",
          "She is reading a book in the library this evening.",
          "She was reading a book at eight o'clock.",
          "She will be reading a book tonight.",
          "She is not reading a book.",
          "She was cooking dinner.",
          "A girl is singing in the room.",
          "This time tomorrow I will be flying to Beijing."
        ],
        "system": true,
        "enabled": true,
        "primarySvocaCodeNid": "svo",
        "primarySvoca": {
          "nid": "svo",
          "name": [
            {
              "lang": "zh",
              "text": "SVO 主谓宾结构"
            },
            {
              "lang": "en",
              "text": "SVO Pattern"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "表示主语加谓语再加宾语的骨架，是英语中最常见的及物动词结构之一。"
            },
            {
              "lang": "en",
              "text": "A subject-verb-object skeleton, one of the most common transitive patterns in English."
            }
          ]
        },
        "allowedSvocaCodeNids": [
          "sv",
          "svo",
          "sva",
          "svoa"
        ],
        "allowedSvocas": [
          {
            "nid": "sv",
            "name": [
              {
                "lang": "zh",
                "text": "SV 主谓结构"
              },
              {
                "lang": "en",
                "text": "SV Pattern"
              }
            ],
            "description": [
              {
                "lang": "zh",
                "text": "表示主语加谓语的核心骨架，常用于描述动作、变化或存在状态，不带显式宾语或补语。"
              },
              {
                "lang": "en",
                "text": "A core subject-verb skeleton, often used for actions, changes, or states without an explicit object or complement."
              }
            ]
          },
          {
            "nid": "svo",
            "name": [
              {
                "lang": "zh",
                "text": "SVO 主谓宾结构"
              },
              {
                "lang": "en",
                "text": "SVO Pattern"
              }
            ],
            "description": [
              {
                "lang": "zh",
                "text": "表示主语加谓语再加宾语的骨架，是英语中最常见的及物动词结构之一。"
              },
              {
                "lang": "en",
                "text": "A subject-verb-object skeleton, one of the most common transitive patterns in English."
              }
            ]
          },
          {
            "nid": "sva",
            "name": [
              {
                "lang": "zh",
                "text": "SVA 主谓状结构"
              },
              {
                "lang": "en",
                "text": "SVA Pattern"
              }
            ],
            "description": [
              {
                "lang": "zh",
                "text": "表示主语加谓语并带核心状语，常用于位置、时间、方式或存在类表达。"
              },
              {
                "lang": "en",
                "text": "A subject-verb-adverbial skeleton often used with key place, time, manner, or existential information."
              }
            ]
          },
          {
            "nid": "svoa",
            "name": [
              {
                "lang": "zh",
                "text": "SVOA 主谓宾状结构"
              },
              {
                "lang": "en",
                "text": "SVOA Pattern"
              }
            ],
            "description": [
              {
                "lang": "zh",
                "text": "表示主语加谓语、宾语并带核心状语，常用于方向、位置、过程和行为落点。"
              },
              {
                "lang": "en",
                "text": "A subject-verb-object-adverbial skeleton often used with direction, location, process, or endpoint information."
              }
            ]
          }
        ],
        "tenseScope": "neutral",
        "predicateRealizationProfile": {
          "kind": "auxiliary_chain",
          "predicateSlotKey": "ongoing_predicate",
          "operatorSlotKeys": [
            "aux_be",
            "aux_be_negative"
          ]
        },
        "predicateRealizationProfileInfo": {
          "kind": "auxiliary_chain",
          "predicateSlotKey": "ongoing_predicate",
          "predicateSlot": {
            "nid": "ongoing_predicate",
            "name": [
              {
                "lang": "zh",
                "text": "正在进行的动作"
              },
              {
                "lang": "en",
                "text": "Ongoing Action"
              }
            ],
            "description": [
              {
                "lang": "zh",
                "text": "表示整句话里最核心的动作。用来表达正在发生或当前在说的事。"
              },
              {
                "lang": "en",
                "text": "Shows the core action of the sentence. It is used in present or ongoing situations."
              }
            ],
            "categoryNid": "verb_predicate",
            "color": "rgba(244,63,94,1)",
            "categoryName": [
              {
                "lang": "zh",
                "text": "谓语槽位"
              },
              {
                "lang": "en",
                "text": "Predicate Slot"
              }
            ],
            "categoryDescription": [
              {
                "lang": "zh",
                "text": "用于填入核心动作、状态或系表结构中的谓语部分。"
              },
              {
                "lang": "en",
                "text": "Used for the core predicate, including actions, states, or linking-verb structures."
              }
            ]
          },
          "operatorSlotKeys": [
            "aux_be",
            "aux_be_negative"
          ],
          "operatorSlots": [
            {
              "nid": "aux_be",
              "name": [
                {
                  "lang": "zh",
                  "text": "be（进行）"
                },
                {
                  "lang": "en",
                  "text": "be (helping)"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "帮助构成进行时：后面跟正在做的动作。am / is / was / will be 合在这一格，因为合起来才是谓语的完整时体，整块记，不要拆成 will 和 be。例如 She is reading a book. / She will be reading at eight."
                },
                {
                  "lang": "en",
                  "text": "Helps build the progressive: be + an action in progress. am / is / was / will be sit in one hole because together they are the predicate’s full tense-aspect — remember the chunk, don’t split will from be. Example: She is reading a book. / She will be reading at eight."
                }
              ],
              "categoryNid": "grammar_auxiliary",
              "color": "rgba(245,158,11,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "助动语法形式"
                },
                {
                  "lang": "en",
                  "text": "Auxiliary Grammar Form"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于控制 be、do、have、存在式或附加问句中的助动形式。"
                },
                {
                  "lang": "en",
                  "text": "Controls auxiliary forms for be, do, have, existential frames, or tag questions."
                }
              ]
            },
            {
              "nid": "aux_be_negative",
              "name": [
                {
                  "lang": "zh",
                  "text": "be 不（进行）"
                },
                {
                  "lang": "en",
                  "text": "isn't (helping)"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "进行时的否定。isn't / wasn't / won't be 合在这一格，因为合起来才是否定谓语的完整时体，整块记。例如 She is not leaving tomorrow. / She won't be leaving at eight."
                },
                {
                  "lang": "en",
                  "text": "Negative helping be in progressive structures. isn't / wasn't / won't be sit in one hole because together they are the predicate’s full tense-aspect — remember the chunk. Example: She is not leaving tomorrow. / She won't be leaving at eight."
                }
              ],
              "categoryNid": "negative_auxiliary",
              "color": "rgba(245,158,11,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "显式否定语法形式"
                },
                {
                  "lang": "en",
                  "text": "Explicit Negative Grammar Form"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于直接承载否定完整式、缩写与允许的否定 clitic。"
                },
                {
                  "lang": "en",
                  "text": "Directly carries full negative forms, contractions, and allowed negative clitics."
                }
              ]
            }
          ]
        },
        "sentenceRealizationSet": [],
        "sentenceRealizationList": [],
        "supportsPyramid": true,
        "created": "2026-10-10T14:31:31.686+00:00",
        "updated": "2026-10-10T14:31:31.686+00:00",
        "editSlots": [
          {
            "positionKey": "pattern",
            "patternNid": "ongoing_entity_be_doing",
            "template": "{actor} {be_marking} {ongoing_predicate} {object} {place_phrase} {time_expression} {purpose_expression} {context_phrase} {relative_clause}.",
            "shapeLocked": true,
            "optionSlots": [
              {
                "slotKey": "actor",
                "slot": {
                  "nid": "actor",
                  "name": [
                    {
                      "lang": "zh",
                      "text": "动作发出者"
                    },
                    {
                      "lang": "en",
                      "text": "Actor"
                    }
                  ],
                  "description": [
                    {
                      "lang": "zh",
                      "text": "表示真正发出这个动作的人或事物，也就是“是谁在做这件事”。"
                    },
                    {
                      "lang": "en",
                      "text": "Shows the subject in this meaning."
                    }
                  ],
                  "categoryNid": "subject_entity",
                  "color": "rgba(14,165,233,1)",
                  "categoryName": [
                    {
                      "lang": "zh",
                      "text": "主语实体槽位"
                    },
                    {
                      "lang": "en",
                      "text": "Subject Entity Slot"
                    }
                  ],
                  "categoryDescription": [
                    {
                      "lang": "zh",
                      "text": "用于填入执行者、承受者或句子讨论对象等主语成分。"
                    },
                    {
                      "lang": "en",
                      "text": "Used for the sentence subject, such as the doer, the affected entity, or the main topic under discussion."
                    }
                  ]
                },
                "role": "required_open",
                "required": true,
                "selected": true,
                "selectable": false,
                "dialSelectable": false,
                "dialSelected": null,
                "growthSelectable": false,
                "growthOrder": null,
                "unused": false,
                "dependsOn": [],
                "dependencies": null
              },
              {
                "slotKey": "be_marking",
                "slot": {
                  "nid": "aux_be_negative",
                  "name": [
                    {
                      "lang": "zh",
                      "text": "be 不（进行）"
                    },
                    {
                      "lang": "en",
                      "text": "isn't (helping)"
                    }
                  ],
                  "description": [
                    {
                      "lang": "zh",
                      "text": "进行时的否定。isn't / wasn't / won't be 合在这一格，因为合起来才是否定谓语的完整时体，整块记。例如 She is not leaving tomorrow. / She won't be leaving at eight."
                    },
                    {
                      "lang": "en",
                      "text": "Negative helping be in progressive structures. isn't / wasn't / won't be sit in one hole because together they are the predicate’s full tense-aspect — remember the chunk. Example: She is not leaving tomorrow. / She won't be leaving at eight."
                    }
                  ],
                  "categoryNid": "negative_auxiliary",
                  "color": "rgba(245,158,11,1)",
                  "categoryName": [
                    {
                      "lang": "zh",
                      "text": "显式否定语法形式"
                    },
                    {
                      "lang": "en",
                      "text": "Explicit Negative Grammar Form"
                    }
                  ],
                  "categoryDescription": [
                    {
                      "lang": "zh",
                      "text": "用于直接承载否定完整式、缩写与允许的否定 clitic。"
                    },
                    {
                      "lang": "en",
                      "text": "Directly carries full negative forms, contractions, and allowed negative clitics."
                    }
                  ]
                },
                "role": "controlled",
                "required": true,
                "selected": true,
                "selectable": false,
                "dialSelectable": false,
                "dialSelected": null,
                "growthSelectable": false,
                "growthOrder": null,
                "unused": false,
                "dependsOn": [],
                "dependencies": null
              },
              {
                "slotKey": "ongoing_predicate",
                "slot": {
                  "nid": "ongoing_predicate",
                  "name": [
                    {
                      "lang": "zh",
                      "text": "正在进行的动作"
                    },
                    {
                      "lang": "en",
                      "text": "Ongoing Action"
                    }
                  ],
                  "description": [
                    {
                      "lang": "zh",
                      "text": "表示整句话里最核心的动作。用来表达正在发生或当前在说的事。"
                    },
                    {
                      "lang": "en",
                      "text": "Shows the core action of the sentence. It is used in present or ongoing situations."
                    }
                  ],
                  "categoryNid": "verb_predicate",
                  "color": "rgba(244,63,94,1)",
                  "categoryName": [
                    {
                      "lang": "zh",
                      "text": "谓语槽位"
                    },
                    {
                      "lang": "en",
                      "text": "Predicate Slot"
                    }
                  ],
                  "categoryDescription": [
                    {
                      "lang": "zh",
                      "text": "用于填入核心动作、状态或系表结构中的谓语部分。"
                    },
                    {
                      "lang": "en",
                      "text": "Used for the core predicate, including actions, states, or linking-verb structures."
                    }
                  ]
                },
                "role": "required_open",
                "required": true,
                "selected": true,
                "selectable": false,
                "dialSelectable": false,
                "dialSelected": null,
                "growthSelectable": false,
                "growthOrder": null,
                "unused": false,
                "dependsOn": [],
                "dependencies": null
              },
              {
                "slotKey": "object",
                "slot": {
                  "nid": "object",
                  "name": [
                    {
                      "lang": "zh",
                      "text": "宾语对象"
                    },
                    {
                      "lang": "en",
                      "text": "Object"
                    }
                  ],
                  "description": [
                    {
                      "lang": "zh",
                      "text": "表示动作直接作用到的对象，比如买什么、吃什么、带什么、看到什么。"
                    },
                    {
                      "lang": "en",
                      "text": "Shows the thing directly affected by the action, such as what is bought, eaten, taken, or seen."
                    }
                  ],
                  "categoryNid": "object_entity",
                  "color": "rgba(139,92,246,1)",
                  "categoryName": [
                    {
                      "lang": "zh",
                      "text": "宾语实体槽位"
                    },
                    {
                      "lang": "en",
                      "text": "Object Entity Slot"
                    }
                  ],
                  "categoryDescription": [
                    {
                      "lang": "zh",
                      "text": "用于填入动作影响的对象、接受者或结果对象。"
                    },
                    {
                      "lang": "en",
                      "text": "Used for the object affected by the action, the receiver, or the result entity."
                    }
                  ]
                },
                "role": "optional_open",
                "required": false,
                "selected": true,
                "selectable": false,
                "dialSelectable": false,
                "dialSelected": null,
                "growthSelectable": false,
                "growthOrder": 1,
                "unused": false,
                "dependsOn": [],
                "dependencies": null
              },
              {
                "slotKey": "place_phrase",
                "slot": {
                  "nid": "place_phrase",
                  "name": [
                    {
                      "lang": "zh",
                      "text": "地点短语"
                    },
                    {
                      "lang": "en",
                      "text": "Place Phrase"
                    }
                  ],
                  "description": [
                    {
                      "lang": "zh",
                      "text": "表示补充场景、地点、搭配或关系的短语。用来说明在哪里。"
                    },
                    {
                      "lang": "en",
                      "text": "Shows a phrase that adds setting, place, relation, or background. It is used to show where something is."
                    }
                  ],
                  "categoryNid": "prepositional_phrase",
                  "color": "rgba(20,184,166,1)",
                  "categoryName": [
                    {
                      "lang": "zh",
                      "text": "介词短语槽位"
                    },
                    {
                      "lang": "en",
                      "text": "Prepositional Phrase Slot"
                    }
                  ],
                  "categoryDescription": [
                    {
                      "lang": "zh",
                      "text": "用于填入 in the park、on the table 等完整介词短语。"
                    },
                    {
                      "lang": "en",
                      "text": "Used for full prepositional phrases such as in the park or on the table."
                    }
                  ]
                },
                "role": "optional_open",
                "required": false,
                "selected": false,
                "selectable": false,
                "dialSelectable": false,
                "dialSelected": null,
                "growthSelectable": false,
                "growthOrder": null,
                "unused": true,
                "dependsOn": [],
                "dependencies": null
              },
              {
                "slotKey": "time_expression",
                "slot": {
                  "nid": "time_expression",
                  "name": [
                    {
                      "lang": "zh",
                      "text": "时间表达"
                    },
                    {
                      "lang": "en",
                      "text": "Time Expression"
                    }
                  ],
                  "description": [
                    {
                      "lang": "zh",
                      "text": "表示什么时候、持续多久、多久一次，或者先后顺序。"
                    },
                    {
                      "lang": "en",
                      "text": "Shows when something happens, how long it lasts, how often it happens, or where it falls in a sequence."
                    }
                  ],
                  "categoryNid": "time_expression",
                  "color": "rgba(0,188,125,1)",
                  "categoryName": [
                    {
                      "lang": "zh",
                      "text": "时间槽位"
                    },
                    {
                      "lang": "en",
                      "text": "Time Expression Slot"
                    }
                  ],
                  "categoryDescription": [
                    {
                      "lang": "zh",
                      "text": "用于填入表示时间点、时间段、频率或顺序的信息。"
                    },
                    {
                      "lang": "en",
                      "text": "Used for information expressing time point, duration, frequency, or sequence."
                    }
                  ]
                },
                "role": "optional_open",
                "required": false,
                "selected": false,
                "selectable": false,
                "dialSelectable": false,
                "dialSelected": null,
                "growthSelectable": false,
                "growthOrder": null,
                "unused": true,
                "dependsOn": [],
                "dependencies": null
              },
              {
                "slotKey": "purpose_expression",
                "slot": {
                  "nid": "purpose_expression",
                  "name": [
                    {
                      "lang": "zh",
                      "text": "目的表达"
                    },
                    {
                      "lang": "en",
                      "text": "Purpose Expression"
                    }
                  ],
                  "description": [
                    {
                      "lang": "zh",
                      "text": "表示做这件事是为了什么，也就是动作想达到的目的。"
                    },
                    {
                      "lang": "en",
                      "text": "Shows what the action is done for: the purpose or intended result."
                    }
                  ],
                  "categoryNid": "purpose_expression",
                  "color": "rgba(132,204,22,1)",
                  "categoryName": [
                    {
                      "lang": "zh",
                      "text": "目的槽位"
                    },
                    {
                      "lang": "en",
                      "text": "Purpose Expression Slot"
                    }
                  ],
                  "categoryDescription": [
                    {
                      "lang": "zh",
                      "text": "用于填入目的、意图或目标导向信息。"
                    },
                    {
                      "lang": "en",
                      "text": "Used for purpose, intention, or goal-oriented information."
                    }
                  ]
                },
                "role": "optional_open",
                "required": false,
                "selected": false,
                "selectable": false,
                "dialSelectable": false,
                "dialSelected": null,
                "growthSelectable": false,
                "growthOrder": null,
                "unused": true,
                "dependsOn": [],
                "dependencies": null
              },
              {
                "slotKey": "context_phrase",
                "slot": {
                  "nid": "context_phrase",
                  "name": [
                    {
                      "lang": "zh",
                      "text": "背景短语"
                    },
                    {
                      "lang": "en",
                      "text": "Context Phrase"
                    }
                  ],
                  "description": [
                    {
                      "lang": "zh",
                      "text": "表示动作或状态发生时的背景补充：常见为介词短语（地点、搭配、场景），也可为缩略的 V-ing 情状状语（如 entering Atlantic Daylight Time / walking home），不单独升成从句。"
                    },
                    {
                      "lang": "en",
                      "text": "Background adjunct for an action or state: often a PP (place, company, setting), and also a reduced V-ing circumstance adjunct (e.g. entering Atlantic Daylight Time / walking home), kept inside the clause rather than promoted."
                    }
                  ],
                  "categoryNid": "lexical_chunk",
                  "color": "rgba(59,130,246,1)",
                  "categoryName": [
                    {
                      "lang": "zh",
                      "text": "词块槽位"
                    },
                    {
                      "lang": "en",
                      "text": "Lexical Chunk Slot"
                    }
                  ],
                  "categoryDescription": [
                    {
                      "lang": "zh",
                      "text": "用于填入应整体保留的固定表达或高频搭配。"
                    },
                    {
                      "lang": "en",
                      "text": "Used for fixed expressions or high-frequency chunks that should be treated as whole units."
                    }
                  ]
                },
                "role": "optional_open",
                "required": false,
                "selected": false,
                "selectable": false,
                "dialSelectable": false,
                "dialSelected": null,
                "growthSelectable": false,
                "growthOrder": null,
                "unused": true,
                "dependsOn": [],
                "dependencies": null
              },
              {
                "slotKey": "relative_clause",
                "slot": {
                  "nid": "relative_clause",
                  "name": [
                    {
                      "lang": "zh",
                      "text": "关系从句内容"
                    },
                    {
                      "lang": "en",
                      "text": "Relative Clause Content"
                    }
                  ],
                  "description": [
                    {
                      "lang": "zh",
                      "text": "表示跟在 who、that、which、where 后面，用来继续说明前面名词的那句话。"
                    },
                    {
                      "lang": "en",
                      "text": "Shows the clause that comes after who, that, which, or where to give more information about the noun before it."
                    }
                  ],
                  "categoryNid": "clause_content",
                  "color": "rgba(99,102,241,1)",
                  "categoryName": [
                    {
                      "lang": "zh",
                      "text": "从句内容槽位"
                    },
                    {
                      "lang": "en",
                      "text": "Clause Content Slot"
                    }
                  ],
                  "categoryDescription": [
                    {
                      "lang": "zh",
                      "text": "用于填入完整从句，如原因从句、条件从句、宾语从句等。"
                    },
                    {
                      "lang": "en",
                      "text": "Used for a full clause such as a reason clause, condition clause, or content clause."
                    }
                  ]
                },
                "role": "optional_open",
                "required": false,
                "selected": false,
                "selectable": false,
                "dialSelectable": false,
                "dialSelected": null,
                "growthSelectable": false,
                "growthOrder": null,
                "unused": true,
                "dependsOn": [
                  "object"
                ],
                "dependencies": null
              }
            ]
          }
        ]
      }
    }
  },
  "patternBlueprint": {
    "nid": "ongoing_entity_be_doing",
    "name": [
      {
        "lang": "zh",
        "text": "说明正在做什么"
      },
      {
        "lang": "en",
        "text": "Say what is happening now"
      }
    ],
    "description": [
      {
        "lang": "zh",
        "text": "强调动作正在进行，像镜头对准此刻发生的事；和“一般做什么”不同。"
      },
      {
        "lang": "en",
        "text": "Emphasizes an action in progress, unlike a general “what someone does”."
      }
    ],
    "familyNid": "action_and_experience",
    "family": {
      "nid": "action_and_experience",
      "name": [
        {
          "lang": "zh",
          "text": "讲动作、经历和变化"
        },
        {
          "lang": "en",
          "text": "Talking About Actions, Experience, and Change"
        }
      ],
      "description": [
        {
          "lang": "zh",
          "text": "这一组句型帮助学习者讲清楚眼前正在发生什么、平时通常怎么做、过去经历过什么，以及这些经历和现在有什么联系。"
        },
        {
          "lang": "en",
          "text": "This group helps learners talk about what is happening now, what people usually do, what happened before, and how past experience still connects to the present."
        }
      ],
      "categoryNid": null,
      "categoryName": null,
      "categoryDescription": null,
      "usageKinds": null,
      "surfaceFromSlotKeys": null,
      "color": null
    },
    "difficulty": {
      "max": 2,
      "min": 1
    },
    "order": 495600,
    "blueprintScope": "clause",
    "patternTier": "core",
    "analysisEligible": true,
    "template": "{actor} {be_marking} {ongoing_predicate} {object} {place_phrase} {time_expression} {purpose_expression} {context_phrase} {relative_clause}.",
    "editSlots": [
      {
        "positionKey": "pattern",
        "patternNid": "ongoing_entity_be_doing",
        "template": "{actor} {be_marking} {ongoing_predicate} {object} {place_phrase} {time_expression} {purpose_expression} {context_phrase} {relative_clause}.",
        "optionSlots": [
          {
            "slotKey": "actor",
            "role": "required_open",
            "required": true,
            "selected": true,
            "selectable": false,
            "dialSelectable": false,
            "growthSelectable": false,
            "growthOrder": null,
            "unused": false,
            "dependsOn": []
          },
          {
            "slotKey": "be_marking",
            "role": "controlled",
            "required": true,
            "selected": true,
            "selectable": false,
            "dialSelectable": false,
            "growthSelectable": false,
            "growthOrder": null,
            "unused": false,
            "dependsOn": []
          },
          {
            "slotKey": "ongoing_predicate",
            "role": "required_open",
            "required": true,
            "selected": true,
            "selectable": false,
            "dialSelectable": false,
            "growthSelectable": false,
            "growthOrder": null,
            "unused": false,
            "dependsOn": []
          },
          {
            "slotKey": "object",
            "role": "optional_open",
            "required": false,
            "selected": true,
            "selectable": false,
            "dialSelectable": false,
            "growthSelectable": false,
            "growthOrder": 1,
            "unused": false,
            "dependsOn": []
          },
          {
            "slotKey": "place_phrase",
            "role": "optional_open",
            "required": false,
            "selected": false,
            "selectable": false,
            "dialSelectable": false,
            "growthSelectable": false,
            "growthOrder": null,
            "unused": true,
            "dependsOn": []
          },
          {
            "slotKey": "time_expression",
            "role": "optional_open",
            "required": false,
            "selected": false,
            "selectable": false,
            "dialSelectable": false,
            "growthSelectable": false,
            "growthOrder": null,
            "unused": true,
            "dependsOn": []
          },
          {
            "slotKey": "purpose_expression",
            "role": "optional_open",
            "required": false,
            "selected": false,
            "selectable": false,
            "dialSelectable": false,
            "growthSelectable": false,
            "growthOrder": null,
            "unused": true,
            "dependsOn": []
          },
          {
            "slotKey": "context_phrase",
            "role": "optional_open",
            "required": false,
            "selected": false,
            "selectable": false,
            "dialSelectable": false,
            "growthSelectable": false,
            "growthOrder": null,
            "unused": true,
            "dependsOn": []
          },
          {
            "slotKey": "relative_clause",
            "role": "optional_open",
            "required": false,
            "selected": false,
            "selectable": false,
            "dialSelectable": false,
            "growthSelectable": false,
            "growthOrder": null,
            "unused": true,
            "dependsOn": [
              "object"
            ]
          }
        ]
      }
    ],
    "controlledGrammarSlots": [
      {
        "slotKey": "aux_be",
        "rendersAs": "be_marking",
        "options": [
          "am",
          "is",
          "are",
          "'m",
          "'s",
          "'re",
          "was",
          "were",
          "will be",
          "'ll be"
        ],
        "activationFeatureNids": [
          "affirmative"
        ]
      },
      {
        "slotKey": "aux_be_negative",
        "rendersAs": "be_marking",
        "options": [
          "am not",
          "is not",
          "are not",
          "isn't",
          "aren't",
          "'m not",
          "'s not",
          "'re not",
          "was not",
          "were not",
          "wasn't",
          "weren't",
          "will not be",
          "won't be",
          "'ll not be"
        ],
        "activationFeatureNids": [
          "negative"
        ]
      }
    ],
    "controlledGrammarSlotList": [
      {
        "slotKey": "aux_be",
        "rendersAs": "be_marking",
        "slot": {
          "nid": "aux_be",
          "name": [
            {
              "lang": "zh",
              "text": "be（进行）"
            },
            {
              "lang": "en",
              "text": "be (helping)"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "帮助构成进行时：后面跟正在做的动作。am / is / was / will be 合在这一格，因为合起来才是谓语的完整时体，整块记，不要拆成 will 和 be。例如 She is reading a book. / She will be reading at eight."
            },
            {
              "lang": "en",
              "text": "Helps build the progressive: be + an action in progress. am / is / was / will be sit in one hole because together they are the predicate’s full tense-aspect — remember the chunk, don’t split will from be. Example: She is reading a book. / She will be reading at eight."
            }
          ],
          "categoryNid": "grammar_auxiliary",
          "categoryName": [
            {
              "lang": "zh",
              "text": "助动语法形式"
            },
            {
              "lang": "en",
              "text": "Auxiliary Grammar Form"
            }
          ],
          "categoryDescription": [
            {
              "lang": "zh",
              "text": "用于控制 be、do、have、存在式或附加问句中的助动形式。"
            },
            {
              "lang": "en",
              "text": "Controls auxiliary forms for be, do, have, existential frames, or tag questions."
            }
          ],
          "usageKinds": null,
          "surfaceFromSlotKeys": null,
          "color": "rgba(245,158,11,1)"
        },
        "options": [
          "am",
          "is",
          "are",
          "'m",
          "'s",
          "'re",
          "was",
          "were",
          "will be",
          "'ll be"
        ],
        "activationFeatureNids": [
          "affirmative"
        ],
        "activationFeatures": [
          {
            "nid": "affirmative",
            "name": [
              {
                "lang": "zh",
                "text": "肯定形式"
              },
              {
                "lang": "en",
                "text": "Affirmative"
              }
            ],
            "description": [
              {
                "lang": "zh",
                "text": "表示肯定、确认或直接陈述某事成立。"
              },
              {
                "lang": "en",
                "text": "Marks a positive statement, confirmation, or direct assertion that something holds true."
              }
            ],
            "categoryNid": null,
            "categoryName": null,
            "categoryDescription": null,
            "usageKinds": null,
            "surfaceFromSlotKeys": null,
            "color": null
          }
        ]
      },
      {
        "slotKey": "aux_be_negative",
        "rendersAs": "be_marking",
        "slot": {
          "nid": "aux_be_negative",
          "name": [
            {
              "lang": "zh",
              "text": "be 不（进行）"
            },
            {
              "lang": "en",
              "text": "isn't (helping)"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "进行时的否定。isn't / wasn't / won't be 合在这一格，因为合起来才是否定谓语的完整时体，整块记。例如 She is not leaving tomorrow. / She won't be leaving at eight."
            },
            {
              "lang": "en",
              "text": "Negative helping be in progressive structures. isn't / wasn't / won't be sit in one hole because together they are the predicate’s full tense-aspect — remember the chunk. Example: She is not leaving tomorrow. / She won't be leaving at eight."
            }
          ],
          "categoryNid": "negative_auxiliary",
          "categoryName": [
            {
              "lang": "zh",
              "text": "显式否定语法形式"
            },
            {
              "lang": "en",
              "text": "Explicit Negative Grammar Form"
            }
          ],
          "categoryDescription": [
            {
              "lang": "zh",
              "text": "用于直接承载否定完整式、缩写与允许的否定 clitic。"
            },
            {
              "lang": "en",
              "text": "Directly carries full negative forms, contractions, and allowed negative clitics."
            }
          ],
          "usageKinds": null,
          "surfaceFromSlotKeys": null,
          "color": "rgba(245,158,11,1)"
        },
        "options": [
          "am not",
          "is not",
          "are not",
          "isn't",
          "aren't",
          "'m not",
          "'s not",
          "'re not",
          "was not",
          "were not",
          "wasn't",
          "weren't",
          "will not be",
          "won't be",
          "'ll not be"
        ],
        "activationFeatureNids": [
          "negative"
        ],
        "activationFeatures": [
          {
            "nid": "negative",
            "name": [
              {
                "lang": "zh",
                "text": "否定形式"
              },
              {
                "lang": "en",
                "text": "Negative"
              }
            ],
            "description": [
              {
                "lang": "zh",
                "text": "表示否定、不存在、不发生或不允许，常见于 not、never、no 等结构。"
              },
              {
                "lang": "en",
                "text": "Marks negation, absence, non-occurrence, or prohibition, often signaled by not, never, or no."
              }
            ],
            "categoryNid": null,
            "categoryName": null,
            "categoryDescription": null,
            "usageKinds": null,
            "surfaceFromSlotKeys": null,
            "color": null
          }
        ]
      }
    ],
    "openSlots": [
      {
        "slotKey": "actor",
        "required": true,
        "grammarControlling": true,
        "growthPriority": null,
        "dependsOn": []
      },
      {
        "slotKey": "ongoing_predicate",
        "required": true,
        "grammarControlling": true,
        "growthPriority": null,
        "dependsOn": []
      },
      {
        "slotKey": "object",
        "required": false,
        "grammarControlling": true,
        "growthPriority": 10,
        "dependsOn": []
      },
      {
        "slotKey": "place_phrase",
        "required": false,
        "grammarControlling": true,
        "growthPriority": 30,
        "dependsOn": []
      },
      {
        "slotKey": "time_expression",
        "required": false,
        "grammarControlling": true,
        "growthPriority": 40,
        "dependsOn": []
      },
      {
        "slotKey": "purpose_expression",
        "required": false,
        "grammarControlling": true,
        "growthPriority": null,
        "dependsOn": []
      },
      {
        "slotKey": "context_phrase",
        "required": false,
        "grammarControlling": true,
        "growthPriority": null,
        "dependsOn": []
      },
      {
        "slotKey": "relative_clause",
        "required": false,
        "grammarControlling": false,
        "growthPriority": 80,
        "dependsOn": [
          "object"
        ]
      }
    ],
    "openSlotList": [
      {
        "slotKey": "actor",
        "slot": {
          "nid": "actor",
          "name": [
            {
              "lang": "zh",
              "text": "动作发出者"
            },
            {
              "lang": "en",
              "text": "Actor"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "表示真正发出这个动作的人或事物，也就是“是谁在做这件事”。"
            },
            {
              "lang": "en",
              "text": "Shows the subject in this meaning."
            }
          ],
          "categoryNid": "subject_entity",
          "categoryName": [
            {
              "lang": "zh",
              "text": "主语实体槽位"
            },
            {
              "lang": "en",
              "text": "Subject Entity Slot"
            }
          ],
          "categoryDescription": [
            {
              "lang": "zh",
              "text": "用于填入执行者、承受者或句子讨论对象等主语成分。"
            },
            {
              "lang": "en",
              "text": "Used for the sentence subject, such as the doer, the affected entity, or the main topic under discussion."
            }
          ],
          "usageKinds": null,
          "surfaceFromSlotKeys": null,
          "color": "rgba(14,165,233,1)"
        },
        "required": true,
        "grammarControlling": true,
        "growthPriority": null,
        "dependsOn": [],
        "dependsOnSlots": null
      },
      {
        "slotKey": "ongoing_predicate",
        "slot": {
          "nid": "ongoing_predicate",
          "name": [
            {
              "lang": "zh",
              "text": "正在进行的动作"
            },
            {
              "lang": "en",
              "text": "Ongoing Action"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "表示整句话里最核心的动作。用来表达正在发生或当前在说的事。"
            },
            {
              "lang": "en",
              "text": "Shows the core action of the sentence. It is used in present or ongoing situations."
            }
          ],
          "categoryNid": "verb_predicate",
          "categoryName": [
            {
              "lang": "zh",
              "text": "谓语槽位"
            },
            {
              "lang": "en",
              "text": "Predicate Slot"
            }
          ],
          "categoryDescription": [
            {
              "lang": "zh",
              "text": "用于填入核心动作、状态或系表结构中的谓语部分。"
            },
            {
              "lang": "en",
              "text": "Used for the core predicate, including actions, states, or linking-verb structures."
            }
          ],
          "usageKinds": null,
          "surfaceFromSlotKeys": null,
          "color": "rgba(244,63,94,1)"
        },
        "required": true,
        "grammarControlling": true,
        "growthPriority": null,
        "dependsOn": [],
        "dependsOnSlots": null
      },
      {
        "slotKey": "object",
        "slot": {
          "nid": "object",
          "name": [
            {
              "lang": "zh",
              "text": "宾语对象"
            },
            {
              "lang": "en",
              "text": "Object"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "表示动作直接作用到的对象，比如买什么、吃什么、带什么、看到什么。"
            },
            {
              "lang": "en",
              "text": "Shows the thing directly affected by the action, such as what is bought, eaten, taken, or seen."
            }
          ],
          "categoryNid": "object_entity",
          "categoryName": [
            {
              "lang": "zh",
              "text": "宾语实体槽位"
            },
            {
              "lang": "en",
              "text": "Object Entity Slot"
            }
          ],
          "categoryDescription": [
            {
              "lang": "zh",
              "text": "用于填入动作影响的对象、接受者或结果对象。"
            },
            {
              "lang": "en",
              "text": "Used for the object affected by the action, the receiver, or the result entity."
            }
          ],
          "usageKinds": null,
          "surfaceFromSlotKeys": null,
          "color": "rgba(139,92,246,1)"
        },
        "required": false,
        "grammarControlling": true,
        "growthPriority": 10,
        "dependsOn": [],
        "dependsOnSlots": null
      },
      {
        "slotKey": "place_phrase",
        "slot": {
          "nid": "place_phrase",
          "name": [
            {
              "lang": "zh",
              "text": "地点短语"
            },
            {
              "lang": "en",
              "text": "Place Phrase"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "表示补充场景、地点、搭配或关系的短语。用来说明在哪里。"
            },
            {
              "lang": "en",
              "text": "Shows a phrase that adds setting, place, relation, or background. It is used to show where something is."
            }
          ],
          "categoryNid": "prepositional_phrase",
          "categoryName": [
            {
              "lang": "zh",
              "text": "介词短语槽位"
            },
            {
              "lang": "en",
              "text": "Prepositional Phrase Slot"
            }
          ],
          "categoryDescription": [
            {
              "lang": "zh",
              "text": "用于填入 in the park、on the table 等完整介词短语。"
            },
            {
              "lang": "en",
              "text": "Used for full prepositional phrases such as in the park or on the table."
            }
          ],
          "usageKinds": null,
          "surfaceFromSlotKeys": null,
          "color": "rgba(20,184,166,1)"
        },
        "required": false,
        "grammarControlling": true,
        "growthPriority": 30,
        "dependsOn": [],
        "dependsOnSlots": null
      },
      {
        "slotKey": "time_expression",
        "slot": {
          "nid": "time_expression",
          "name": [
            {
              "lang": "zh",
              "text": "时间表达"
            },
            {
              "lang": "en",
              "text": "Time Expression"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "表示什么时候、持续多久、多久一次，或者先后顺序。"
            },
            {
              "lang": "en",
              "text": "Shows when something happens, how long it lasts, how often it happens, or where it falls in a sequence."
            }
          ],
          "categoryNid": "time_expression",
          "categoryName": [
            {
              "lang": "zh",
              "text": "时间槽位"
            },
            {
              "lang": "en",
              "text": "Time Expression Slot"
            }
          ],
          "categoryDescription": [
            {
              "lang": "zh",
              "text": "用于填入表示时间点、时间段、频率或顺序的信息。"
            },
            {
              "lang": "en",
              "text": "Used for information expressing time point, duration, frequency, or sequence."
            }
          ],
          "usageKinds": null,
          "surfaceFromSlotKeys": null,
          "color": "rgba(0,188,125,1)"
        },
        "required": false,
        "grammarControlling": true,
        "growthPriority": 40,
        "dependsOn": [],
        "dependsOnSlots": null
      },
      {
        "slotKey": "purpose_expression",
        "slot": {
          "nid": "purpose_expression",
          "name": [
            {
              "lang": "zh",
              "text": "目的表达"
            },
            {
              "lang": "en",
              "text": "Purpose Expression"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "表示做这件事是为了什么，也就是动作想达到的目的。"
            },
            {
              "lang": "en",
              "text": "Shows what the action is done for: the purpose or intended result."
            }
          ],
          "categoryNid": "purpose_expression",
          "categoryName": [
            {
              "lang": "zh",
              "text": "目的槽位"
            },
            {
              "lang": "en",
              "text": "Purpose Expression Slot"
            }
          ],
          "categoryDescription": [
            {
              "lang": "zh",
              "text": "用于填入目的、意图或目标导向信息。"
            },
            {
              "lang": "en",
              "text": "Used for purpose, intention, or goal-oriented information."
            }
          ],
          "usageKinds": null,
          "surfaceFromSlotKeys": null,
          "color": "rgba(132,204,22,1)"
        },
        "required": false,
        "grammarControlling": true,
        "growthPriority": null,
        "dependsOn": [],
        "dependsOnSlots": null
      },
      {
        "slotKey": "context_phrase",
        "slot": {
          "nid": "context_phrase",
          "name": [
            {
              "lang": "zh",
              "text": "背景短语"
            },
            {
              "lang": "en",
              "text": "Context Phrase"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "表示动作或状态发生时的背景补充：常见为介词短语（地点、搭配、场景），也可为缩略的 V-ing 情状状语（如 entering Atlantic Daylight Time / walking home），不单独升成从句。"
            },
            {
              "lang": "en",
              "text": "Background adjunct for an action or state: often a PP (place, company, setting), and also a reduced V-ing circumstance adjunct (e.g. entering Atlantic Daylight Time / walking home), kept inside the clause rather than promoted."
            }
          ],
          "categoryNid": "lexical_chunk",
          "categoryName": [
            {
              "lang": "zh",
              "text": "词块槽位"
            },
            {
              "lang": "en",
              "text": "Lexical Chunk Slot"
            }
          ],
          "categoryDescription": [
            {
              "lang": "zh",
              "text": "用于填入应整体保留的固定表达或高频搭配。"
            },
            {
              "lang": "en",
              "text": "Used for fixed expressions or high-frequency chunks that should be treated as whole units."
            }
          ],
          "usageKinds": null,
          "surfaceFromSlotKeys": null,
          "color": "rgba(59,130,246,1)"
        },
        "required": false,
        "grammarControlling": true,
        "growthPriority": null,
        "dependsOn": [],
        "dependsOnSlots": null
      },
      {
        "slotKey": "relative_clause",
        "slot": {
          "nid": "relative_clause",
          "name": [
            {
              "lang": "zh",
              "text": "关系从句内容"
            },
            {
              "lang": "en",
              "text": "Relative Clause Content"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "表示跟在 who、that、which、where 后面，用来继续说明前面名词的那句话。"
            },
            {
              "lang": "en",
              "text": "Shows the clause that comes after who, that, which, or where to give more information about the noun before it."
            }
          ],
          "categoryNid": "clause_content",
          "categoryName": [
            {
              "lang": "zh",
              "text": "从句内容槽位"
            },
            {
              "lang": "en",
              "text": "Clause Content Slot"
            }
          ],
          "categoryDescription": [
            {
              "lang": "zh",
              "text": "用于填入完整从句，如原因从句、条件从句、宾语从句等。"
            },
            {
              "lang": "en",
              "text": "Used for a full clause such as a reason clause, condition clause, or content clause."
            }
          ],
          "usageKinds": null,
          "surfaceFromSlotKeys": null,
          "color": "rgba(99,102,241,1)"
        },
        "required": false,
        "grammarControlling": false,
        "growthPriority": 80,
        "dependsOn": [
          "object"
        ],
        "dependsOnSlots": null
      }
    ],
    "basicTypeNid": "simple",
    "basicType": {
      "nid": "simple",
      "name": [
        {
          "lang": "zh",
          "text": "简单句"
        },
        {
          "lang": "en",
          "text": "Simple Sentence"
        }
      ],
      "description": [
        {
          "lang": "zh",
          "text": "只包含一个独立分句的基础句型，是低阶教学和句型骨架训练的核心类型。"
        },
        {
          "lang": "en",
          "text": "A sentence with only one independent clause, forming the core type for foundational teaching and sentence skeleton practice."
        }
      ],
      "categoryNid": null,
      "categoryName": null,
      "categoryDescription": null,
      "usageKinds": null,
      "surfaceFromSlotKeys": null,
      "color": null
    },
    "functionalTypeNid": "declarative",
    "functionalType": {
      "nid": "declarative",
      "name": [
        {
          "lang": "zh",
          "text": "陈述句"
        },
        {
          "lang": "en",
          "text": "Declarative"
        }
      ],
      "description": [
        {
          "lang": "zh",
          "text": "用于陈述事实、观点、状态或信息，是写作与说明中最基础、最常见的句子功能类型。"
        },
        {
          "lang": "en",
          "text": "Used to state facts, ideas, states, or information; the most common functional sentence type in writing and explanation."
        }
      ],
      "categoryNid": null,
      "categoryName": null,
      "categoryDescription": null,
      "usageKinds": null,
      "surfaceFromSlotKeys": null,
      "color": null
    },
    "clauseProfileNid": "single_clause",
    "clauseProfile": {
      "nid": "single_clause",
      "name": [
        {
          "lang": "zh",
          "text": "单子句"
        },
        {
          "lang": "en",
          "text": "Single Clause"
        }
      ],
      "description": [
        {
          "lang": "zh",
          "text": "整个句型只包含一个核心子句，没有并列或从属扩展，是最基础的句型骨架。"
        },
        {
          "lang": "en",
          "text": "The pattern contains only one core clause with no coordination or subordination, forming the most basic sentence skeleton."
        }
      ],
      "categoryNid": null,
      "categoryName": null,
      "categoryDescription": null,
      "usageKinds": null,
      "surfaceFromSlotKeys": null,
      "color": null
    },
    "grammarFeatureNids": [
      "indicative_mood",
      "active_voice"
    ],
    "grammarFeatures": [
      {
        "nid": "indicative_mood",
        "name": [
          {
            "lang": "zh",
            "text": "陈述语气"
          },
          {
            "lang": "en",
            "text": "Indicative Mood"
          }
        ],
        "description": [
          {
            "lang": "zh",
            "text": "用于陈述事实、推断或一般信息，是英语中最常见的语气。"
          },
          {
            "lang": "en",
            "text": "Used to state facts, inferences, or general information; it is the most common mood in English."
          }
        ],
        "categoryNid": null,
        "categoryName": null,
        "categoryDescription": null,
        "usageKinds": null,
        "surfaceFromSlotKeys": null,
        "color": null
      },
      {
        "nid": "active_voice",
        "name": [
          {
            "lang": "zh",
            "text": "主动语态"
          },
          {
            "lang": "en",
            "text": "Active Voice"
          }
        ],
        "description": [
          {
            "lang": "zh",
            "text": "主语执行动作，表达更直接，常用于清楚说明施事者。"
          },
          {
            "lang": "en",
            "text": "The subject performs the action, giving a direct structure that clearly highlights the doer."
          }
        ],
        "categoryNid": null,
        "categoryName": null,
        "categoryDescription": null,
        "usageKinds": null,
        "surfaceFromSlotKeys": null,
        "color": null
      }
    ],
    "specialFeatureNids": [],
    "specialFeatures": [],
    "communicativeFunctionNids": [
      "describe",
      "narrate_event"
    ],
    "communicativeFunctions": [
      {
        "nid": "describe",
        "name": [
          {
            "lang": "zh",
            "text": "描述"
          },
          {
            "lang": "en",
            "text": "Describe"
          }
        ],
        "description": [
          {
            "lang": "zh",
            "text": "用于描写状态、动作、特征、位置、数量等，是最广泛的写作功能之一。"
          },
          {
            "lang": "en",
            "text": "Used to describe states, actions, features, locations, and quantities; one of the broadest functions in writing."
          }
        ],
        "categoryNid": null,
        "categoryName": null,
        "categoryDescription": null,
        "usageKinds": null,
        "surfaceFromSlotKeys": null,
        "color": null
      },
      {
        "nid": "narrate_event",
        "name": [
          {
            "lang": "zh",
            "text": "叙述事件"
          },
          {
            "lang": "en",
            "text": "Narrate Event"
          }
        ],
        "description": [
          {
            "lang": "zh",
            "text": "用于讲述发生了什么、按时间推进信息，常见于故事和经历写作。"
          },
          {
            "lang": "en",
            "text": "Used to tell what happened and move information through time, common in stories and experience writing."
          }
        ],
        "categoryNid": null,
        "categoryName": null,
        "categoryDescription": null,
        "usageKinds": null,
        "surfaceFromSlotKeys": null,
        "color": null
      }
    ],
    "discourseRoleNids": [
      "standalone_sentence",
      "supporting_detail"
    ],
    "discourseRoles": [
      {
        "nid": "standalone_sentence",
        "name": [
          {
            "lang": "zh",
            "text": "独立句"
          },
          {
            "lang": "en",
            "text": "Standalone Sentence"
          }
        ],
        "description": [
          {
            "lang": "zh",
            "text": "单独即可完成表达，不依赖上下文中的其他句子承担结构角色。"
          },
          {
            "lang": "en",
            "text": "Completes its communicative work on its own without depending on surrounding sentences for a structural role."
          }
        ],
        "categoryNid": null,
        "categoryName": null,
        "categoryDescription": null,
        "usageKinds": null,
        "surfaceFromSlotKeys": null,
        "color": null
      },
      {
        "nid": "supporting_detail",
        "name": [
          {
            "lang": "zh",
            "text": "支持细节句"
          },
          {
            "lang": "en",
            "text": "Supporting Detail"
          }
        ],
        "description": [
          {
            "lang": "zh",
            "text": "用于补充事实、细节、特征或说明，支撑主题句。"
          },
          {
            "lang": "en",
            "text": "Adds facts, details, features, or explanation to support the topic sentence."
          }
        ],
        "categoryNid": null,
        "categoryName": null,
        "categoryDescription": null,
        "usageKinds": null,
        "surfaceFromSlotKeys": null,
        "color": null
      }
    ],
    "teachingRealizations": [
      "She is reading.",
      "She is reading a book.",
      "She is reading a book in the library.",
      "She is reading a book in the library this evening.",
      "She was reading a book at eight o'clock.",
      "She will be reading a book tonight.",
      "She is not reading a book.",
      "She was cooking dinner.",
      "A girl is singing in the room.",
      "This time tomorrow I will be flying to Beijing."
    ],
    "previewTexts": null,
    "system": true,
    "enabled": true,
    "primarySvocaCodeNid": "svo",
    "primarySvoca": {
      "nid": "svo",
      "name": [
        {
          "lang": "zh",
          "text": "SVO 主谓宾结构"
        },
        {
          "lang": "en",
          "text": "SVO Pattern"
        }
      ],
      "description": [
        {
          "lang": "zh",
          "text": "表示主语加谓语再加宾语的骨架，是英语中最常见的及物动词结构之一。"
        },
        {
          "lang": "en",
          "text": "A subject-verb-object skeleton, one of the most common transitive patterns in English."
        }
      ],
      "categoryNid": null,
      "categoryName": null,
      "categoryDescription": null,
      "usageKinds": null,
      "surfaceFromSlotKeys": null,
      "color": null
    },
    "allowedSvocaCodeNids": [
      "sv",
      "svo",
      "sva",
      "svoa"
    ],
    "allowedSvocas": [
      {
        "nid": "sv",
        "name": [
          {
            "lang": "zh",
            "text": "SV 主谓结构"
          },
          {
            "lang": "en",
            "text": "SV Pattern"
          }
        ],
        "description": [
          {
            "lang": "zh",
            "text": "表示主语加谓语的核心骨架，常用于描述动作、变化或存在状态，不带显式宾语或补语。"
          },
          {
            "lang": "en",
            "text": "A core subject-verb skeleton, often used for actions, changes, or states without an explicit object or complement."
          }
        ],
        "categoryNid": null,
        "categoryName": null,
        "categoryDescription": null,
        "usageKinds": null,
        "surfaceFromSlotKeys": null,
        "color": null
      },
      {
        "nid": "svo",
        "name": [
          {
            "lang": "zh",
            "text": "SVO 主谓宾结构"
          },
          {
            "lang": "en",
            "text": "SVO Pattern"
          }
        ],
        "description": [
          {
            "lang": "zh",
            "text": "表示主语加谓语再加宾语的骨架，是英语中最常见的及物动词结构之一。"
          },
          {
            "lang": "en",
            "text": "A subject-verb-object skeleton, one of the most common transitive patterns in English."
          }
        ],
        "categoryNid": null,
        "categoryName": null,
        "categoryDescription": null,
        "usageKinds": null,
        "surfaceFromSlotKeys": null,
        "color": null
      },
      {
        "nid": "sva",
        "name": [
          {
            "lang": "zh",
            "text": "SVA 主谓状结构"
          },
          {
            "lang": "en",
            "text": "SVA Pattern"
          }
        ],
        "description": [
          {
            "lang": "zh",
            "text": "表示主语加谓语并带核心状语，常用于位置、时间、方式或存在类表达。"
          },
          {
            "lang": "en",
            "text": "A subject-verb-adverbial skeleton often used with key place, time, manner, or existential information."
          }
        ],
        "categoryNid": null,
        "categoryName": null,
        "categoryDescription": null,
        "usageKinds": null,
        "surfaceFromSlotKeys": null,
        "color": null
      },
      {
        "nid": "svoa",
        "name": [
          {
            "lang": "zh",
            "text": "SVOA 主谓宾状结构"
          },
          {
            "lang": "en",
            "text": "SVOA Pattern"
          }
        ],
        "description": [
          {
            "lang": "zh",
            "text": "表示主语加谓语、宾语并带核心状语，常用于方向、位置、过程和行为落点。"
          },
          {
            "lang": "en",
            "text": "A subject-verb-object-adverbial skeleton often used with direction, location, process, or endpoint information."
          }
        ],
        "categoryNid": null,
        "categoryName": null,
        "categoryDescription": null,
        "usageKinds": null,
        "surfaceFromSlotKeys": null,
        "color": null
      }
    ],
    "tenseScope": "neutral",
    "predicateRealizationProfile": {
      "kind": "auxiliary_chain",
      "predicateSlotKey": "ongoing_predicate",
      "operatorSlotKeys": [
        "aux_be",
        "aux_be_negative"
      ]
    },
    "predicateRealizationProfileInfo": {
      "kind": "auxiliary_chain",
      "predicateSlotKey": "ongoing_predicate",
      "predicateSlot": {
        "nid": "ongoing_predicate",
        "name": [
          {
            "lang": "zh",
            "text": "正在进行的动作"
          },
          {
            "lang": "en",
            "text": "Ongoing Action"
          }
        ],
        "description": [
          {
            "lang": "zh",
            "text": "表示整句话里最核心的动作。用来表达正在发生或当前在说的事。"
          },
          {
            "lang": "en",
            "text": "Shows the core action of the sentence. It is used in present or ongoing situations."
          }
        ],
        "categoryNid": "verb_predicate",
        "categoryName": [
          {
            "lang": "zh",
            "text": "谓语槽位"
          },
          {
            "lang": "en",
            "text": "Predicate Slot"
          }
        ],
        "categoryDescription": [
          {
            "lang": "zh",
            "text": "用于填入核心动作、状态或系表结构中的谓语部分。"
          },
          {
            "lang": "en",
            "text": "Used for the core predicate, including actions, states, or linking-verb structures."
          }
        ],
        "usageKinds": null,
        "surfaceFromSlotKeys": null,
        "color": "rgba(244,63,94,1)"
      },
      "operatorSlotKeys": [
        "aux_be",
        "aux_be_negative"
      ],
      "operatorSlots": [
        {
          "nid": "aux_be",
          "name": [
            {
              "lang": "zh",
              "text": "be（进行）"
            },
            {
              "lang": "en",
              "text": "be (helping)"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "帮助构成进行时：后面跟正在做的动作。am / is / was / will be 合在这一格，因为合起来才是谓语的完整时体，整块记，不要拆成 will 和 be。例如 She is reading a book. / She will be reading at eight."
            },
            {
              "lang": "en",
              "text": "Helps build the progressive: be + an action in progress. am / is / was / will be sit in one hole because together they are the predicate’s full tense-aspect — remember the chunk, don’t split will from be. Example: She is reading a book. / She will be reading at eight."
            }
          ],
          "categoryNid": "grammar_auxiliary",
          "categoryName": [
            {
              "lang": "zh",
              "text": "助动语法形式"
            },
            {
              "lang": "en",
              "text": "Auxiliary Grammar Form"
            }
          ],
          "categoryDescription": [
            {
              "lang": "zh",
              "text": "用于控制 be、do、have、存在式或附加问句中的助动形式。"
            },
            {
              "lang": "en",
              "text": "Controls auxiliary forms for be, do, have, existential frames, or tag questions."
            }
          ],
          "usageKinds": null,
          "surfaceFromSlotKeys": null,
          "color": "rgba(245,158,11,1)"
        },
        {
          "nid": "aux_be_negative",
          "name": [
            {
              "lang": "zh",
              "text": "be 不（进行）"
            },
            {
              "lang": "en",
              "text": "isn't (helping)"
            }
          ],
          "description": [
            {
              "lang": "zh",
              "text": "进行时的否定。isn't / wasn't / won't be 合在这一格，因为合起来才是否定谓语的完整时体，整块记。例如 She is not leaving tomorrow. / She won't be leaving at eight."
            },
            {
              "lang": "en",
              "text": "Negative helping be in progressive structures. isn't / wasn't / won't be sit in one hole because together they are the predicate’s full tense-aspect — remember the chunk. Example: She is not leaving tomorrow. / She won't be leaving at eight."
            }
          ],
          "categoryNid": "negative_auxiliary",
          "categoryName": [
            {
              "lang": "zh",
              "text": "显式否定语法形式"
            },
            {
              "lang": "en",
              "text": "Explicit Negative Grammar Form"
            }
          ],
          "categoryDescription": [
            {
              "lang": "zh",
              "text": "用于直接承载否定完整式、缩写与允许的否定 clitic。"
            },
            {
              "lang": "en",
              "text": "Directly carries full negative forms, contractions, and allowed negative clitics."
            }
          ],
          "usageKinds": null,
          "surfaceFromSlotKeys": null,
          "color": "rgba(245,158,11,1)"
        }
      ]
    },
    "sentenceRealizations": null,
    "sentenceRealizationSet": [],
    "sentenceRealizationList": [],
    "supportsPyramid": true,
    "created": "2026-10-10T14:31:31.686+00:00",
    "updated": "2026-10-10T14:31:31.686+00:00"
  },
  "presetSentenceId": 586797
}





{
  "code": 200,
  "data": {
    "sentenceRealizationList": [
      {
        "sentenceId": 586797,
        "semanticId": 1208087,
        "contentType": "EN_SENTENCE",
        "content": "The boy is eating a round apple in the kitchen.",
        "definition": "这个男孩正在厨房里吃一个圆苹果。",
        "patternNid": "ongoing_entity_be_doing",
        "patternTemplate": "{actor} {be_marking} {ongoing_predicate} {object} {place_phrase} {time_expression} {purpose_expression} {context_phrase} {relative_clause}.",
        "patternName": [
          {
            "lang": "zh",
            "text": "说明正在做什么"
          },
          {
            "lang": "en",
            "text": "Say what is happening now"
          }
        ],
        "patternDescription": [
          {
            "lang": "zh",
            "text": "强调动作正在进行，像镜头对准此刻发生的事；和“一般做什么”不同。"
          },
          {
            "lang": "en",
            "text": "Emphasizes an action in progress, unlike a general “what someone does”."
          }
        ],
        "blueprintScope": "clause",
        "blueprintScopeName": [
          {
            "lang": "en",
            "text": "Clause Scope"
          },
          {
            "lang": "zh",
            "text": "子句内组合"
          }
        ],
        "segmentList": [
          {
            "slotKey": "actor",
            "slot": {
              "nid": "actor",
              "name": [
                {
                  "lang": "zh",
                  "text": "动作发出者"
                },
                {
                  "lang": "en",
                  "text": "Actor"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "表示真正发出这个动作的人或事物，也就是“是谁在做这件事”。"
                },
                {
                  "lang": "en",
                  "text": "Shows the subject in this meaning."
                }
              ],
              "categoryNid": "subject_entity",
              "color": "rgba(14,165,233,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "主语实体槽位"
                },
                {
                  "lang": "en",
                  "text": "Subject Entity Slot"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于填入执行者、承受者或句子讨论对象等主语成分。"
                },
                {
                  "lang": "en",
                  "text": "Used for the sentence subject, such as the doer, the affected entity, or the main topic under discussion."
                }
              ]
            },
            "required": true,
            "grammarControlling": false,
            "key": "708008",
            "text": "The boy",
            "renderSlotKey": "actor",
            "sourceSlotKey": "actor",
            "slotUid": 708008,
            "literal": false,
            "segmentState": "normal",
            "hasChildStruct": false
          },
          {
            "slotKey": "aux_be",
            "slot": {
              "nid": "aux_be",
              "name": [
                {
                  "lang": "zh",
                  "text": "be（进行）"
                },
                {
                  "lang": "en",
                  "text": "be (helping)"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "帮助构成进行时：后面跟正在做的动作。am / is / was / will be 合在这一格，因为合起来才是谓语的完整时体，整块记，不要拆成 will 和 be。例如 She is reading a book. / She will be reading at eight."
                },
                {
                  "lang": "en",
                  "text": "Helps build the progressive: be + an action in progress. am / is / was / will be sit in one hole because together they are the predicate’s full tense-aspect — remember the chunk, don’t split will from be. Example: She is reading a book. / She will be reading at eight."
                }
              ],
              "categoryNid": "grammar_auxiliary",
              "color": "rgba(245,158,11,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "助动语法形式"
                },
                {
                  "lang": "en",
                  "text": "Auxiliary Grammar Form"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于控制 be、do、have、存在式或附加问句中的助动形式。"
                },
                {
                  "lang": "en",
                  "text": "Controls auxiliary forms for be, do, have, existential frames, or tag questions."
                }
              ]
            },
            "grammarControlling": true,
            "key": "708009",
            "text": "is",
            "grammarValue": "is",
            "renderSlotKey": "aux_be",
            "sourceSlotKey": "aux_be",
            "slotUid": 708009,
            "literal": false,
            "segmentState": "normal",
            "hasChildStruct": false
          },
          {
            "slotKey": "ongoing_predicate",
            "slot": {
              "nid": "ongoing_predicate",
              "name": [
                {
                  "lang": "zh",
                  "text": "正在进行的动作"
                },
                {
                  "lang": "en",
                  "text": "Ongoing Action"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "表示整句话里最核心的动作。用来表达正在发生或当前在说的事。"
                },
                {
                  "lang": "en",
                  "text": "Shows the core action of the sentence. It is used in present or ongoing situations."
                }
              ],
              "categoryNid": "verb_predicate",
              "color": "rgba(244,63,94,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "谓语槽位"
                },
                {
                  "lang": "en",
                  "text": "Predicate Slot"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于填入核心动作、状态或系表结构中的谓语部分。"
                },
                {
                  "lang": "en",
                  "text": "Used for the core predicate, including actions, states, or linking-verb structures."
                }
              ]
            },
            "required": true,
            "grammarControlling": false,
            "key": "708010",
            "text": "eating",
            "renderSlotKey": "ongoing_predicate",
            "sourceSlotKey": "ongoing_predicate",
            "slotUid": 708010,
            "literal": false,
            "segmentState": "normal",
            "hasChildStruct": false
          },
          {
            "slotKey": "object",
            "slot": {
              "nid": "object",
              "name": [
                {
                  "lang": "zh",
                  "text": "宾语对象"
                },
                {
                  "lang": "en",
                  "text": "Object"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "表示动作直接作用到的对象，比如买什么、吃什么、带什么、看到什么。"
                },
                {
                  "lang": "en",
                  "text": "Shows the thing directly affected by the action, such as what is bought, eaten, taken, or seen."
                }
              ],
              "categoryNid": "object_entity",
              "color": "rgba(139,92,246,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "宾语实体槽位"
                },
                {
                  "lang": "en",
                  "text": "Object Entity Slot"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于填入动作影响的对象、接受者或结果对象。"
                },
                {
                  "lang": "en",
                  "text": "Used for the object affected by the action, the receiver, or the result entity."
                }
              ]
            },
            "required": false,
            "grammarControlling": false,
            "key": "708011",
            "text": "a round apple",
            "renderSlotKey": "object",
            "sourceSlotKey": "object",
            "slotUid": 708011,
            "literal": false,
            "segmentState": "normal",
            "hasChildStruct": false
          },
          {
            "slotKey": "place_phrase",
            "slot": {
              "nid": "place_phrase",
              "name": [
                {
                  "lang": "zh",
                  "text": "地点短语"
                },
                {
                  "lang": "en",
                  "text": "Place Phrase"
                }
              ],
              "description": [
                {
                  "lang": "zh",
                  "text": "表示补充场景、地点、搭配或关系的短语。用来说明在哪里。"
                },
                {
                  "lang": "en",
                  "text": "Shows a phrase that adds setting, place, relation, or background. It is used to show where something is."
                }
              ],
              "categoryNid": "prepositional_phrase",
              "color": "rgba(20,184,166,1)",
              "categoryName": [
                {
                  "lang": "zh",
                  "text": "介词短语槽位"
                },
                {
                  "lang": "en",
                  "text": "Prepositional Phrase Slot"
                }
              ],
              "categoryDescription": [
                {
                  "lang": "zh",
                  "text": "用于填入 in the park、on the table 等完整介词短语。"
                },
                {
                  "lang": "en",
                  "text": "Used for full prepositional phrases such as in the park or on the table."
                }
              ]
            },
            "required": false,
            "grammarControlling": false,
            "key": "708012",
            "text": "in the kitchen",
            "renderSlotKey": "place_phrase",
            "sourceSlotKey": "place_phrase",
            "slotUid": 708012,
            "literal": false,
            "segmentState": "normal",
            "hasChildStruct": false
          },
          {
            "slotKey": "__literal__",
            "slot": {
              "nid": "__literal__",
              "name": [
                {
                  "lang": "en",
                  "text": "literal"
                },
                {
                  "lang": "zh",
                  "text": "固定"
                }
              ],
              "color": "rgba(148,163,184,1)"
            },
            "grammarControlling": false,
            "key": "lit-17",
            "text": ".",
            "renderSlotKey": "__literal__",
            "sourceSlotKey": "__literal__",
            "literal": true,
            "segmentState": "normal",
            "hasChildStruct": false
          }
        ],
        "addedSlotKeys": [],
        "access": "NORMAL"
      }
    ]
  }
}