# 同义反义详情接口（前端对接）

> 受众：Flutter App 前端
> 适用页面：词典右中「同义反义」格进入后的全屏详情页
> 实际接口：`GET /write/zhenxie/lexical/detail`

---

## 1. 接口用途

这个接口返回 **单词 / 短语当前义项** 的同义反义详情整包数据，前端可直接用于渲染：

- 顶部门头
- 底部义项切换
- 左侧同义组
- 右侧反义组
- 组内知识点卡牌

这是一个 **按义项取数** 的接口，不是按拼写取数。

---

## 2. 请求方式

`GET /write/zhenxie/lexical/detail`

### 2.1 Query 参数

| 参数 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `contentType` | string | 是 | 只支持 `EN_WORD` / `EN_PHRASE` |
| `contentId` | long | 是 | 当前词条内容 ID |
| `semanticId` | long | 否 | 当前义项 ID |

### 2.2 `semanticId` 使用约定

`semanticId` **通常应当由前端显式传入**，来源是当前词典页已选中的义项。

支持不传，只是为了兼容首次进入或兜底场景。  
如果不传，服务端会自动回落到该词条的第一义，并在响应里返回最终命中的 `semanticId`。

前端接入要求：

1. 正常进入同义反义页时，**要传当前词典页的 `semanticId`**
2. 用户切换底部义项时，**要重新调用本接口**
3. 不要把“不传 `semanticId`”当成默认调用方式

原因：切换义项后，下面这些内容都会一起变化：

- 门头 `translate / descriptions`
- `synonymSets`
- `antonymSets`
- 反义中的 `isCurrent`
- 反义分栏 `display.left / display.right`

所以不能只本地切 tab，不重调接口。

---

## 3. 返回结构

```json
{
  "contentType": "EN_WORD",
  "contentId": 12345,
  "semanticId": 67890,
  "headword": "take off",
  "pos": "VERB",
  "translate": [],
  "descriptions": [],
  "semanticItems": [],
  "synonymSets": [],
  "antonymSets": []
}
```

### 3.1 顶层字段

| 字段 | 类型 | 说明 |
|---|---|---|
| `contentType` | string | 当前页内容类型 |
| `contentId` | long | 当前页内容 ID |
| `semanticId` | long | 当前页最终生效的义项 ID |
| `headword` | string | 门头主标题，词条表面 |
| `pos` | string | 当前义项对应词性 |
| `translate` | `LanguageText[]` | 门头释义 |
| `descriptions` | `LanguageText[]` | 门头说明文案 |
| `semanticItems` | `EnContentCardSemanticItemDTO[]` | 底部义项切换数据 |
| `synonymSets` | `LexicalSetGroupDTO[]` | 同义组列表 |
| `antonymSets` | `LexicalSetGroupDTO[]` | 反义组列表 |

说明：

- `synonymSets` / `antonymSets` 无数据时返回 `[]`
- 不建议前端依赖 `null` 判断整栏显隐

---

## 4. 渲染说明

## 4.1 顶部门头

使用这些字段：

- 标题：`headword`
- 词性：`pos`
- 释义：`translate`
- 描述：`descriptions`

建议：

1. `headword` 永远作为主标题显示
2. `translate` 按当前语言优先取对应文案
3. `descriptions` 作为门头说明，不要和组级 `descriptions` 混用

---

## 4.2 义项切换

底部义项切换直接使用：

- `semanticItems`

该字段与其他词典详情页的义项结构保持一致，可直接复用现有义项切换组件。

### 切换规则

用户点击某个义项后，前端应：

1. 取该项的 `semanticId`
2. 重新调用 `/write/zhenxie/lexical/detail`
3. 用新响应整页刷新

不要只本地切高亮，不重拉接口。

---

## 4.3 同义组 / 反义组

### 组结构

```json
{
  "uid": 2001,
  "concept": [],
  "descriptions": [],
  "poleLabels": null,
  "display": null,
  "members": []
}
```

| 字段 | 类型 | 说明 |
|---|---|---|
| `uid` | long | 组 ID，仅作前端 key 使用 |
| `concept` | `LanguageText[]` | 组标题 |
| `descriptions` | `LanguageText[]` | 组说明 |
| `poleLabels` | `PoleLabelDTO` | 仅反义组使用 |
| `display` | `DisplayDTO` | 仅反义组使用 |
| `members` | `LexicalSetMemberDTO[]` | 组内成员 |

### 同义组渲染

前端按 `synonymSets` 顺序直接渲染即可：

1. 标题：`concept`
2. 描述：`descriptions`
3. 成员卡片：`members`

说明：

- 同义组里的 `members` **已经去掉当前项**
- 前端不要再额外过滤一次“自己”

### 反义组渲染

前端按 `antonymSets` 顺序渲染。

反义组额外关注：

- `poleLabels`
- `display.left`
- `display.right`
- `members[].pole`
- `members[].isCurrent`

前端需要根据 `display` 分左右栏：

1. 左栏显示 `pole == display.left` 的成员
2. 右栏显示 `pole == display.right` 的成员
3. 左右栏标题取 `poleLabels` 对应的极

例如：

```json
"poleLabels": {
  "a": [{ "lang": "zh", "text": "穿着" }],
  "b": [{ "lang": "zh", "text": "脱下" }]
},
"display": {
  "left": "b",
  "right": "a"
}
```

那就表示：

- 左栏标题显示 `poleLabels.b`
- 右栏标题显示 `poleLabels.a`

注意：

- `a/b` 是组内固定语义极
- `left/right` 是当前页面展示位置
- 前端只按 `display` 分栏，不要自己重排 `pole`

---

## 4.4 成员卡片

### 成员结构

```json
{
  "role": "phrasal",
  "roleName": [],
  "pole": "b",
  "isCurrent": true,
  "card": {}
}
```

| 字段 | 类型 | 说明 |
|---|---|---|
| `role` | string | 语域编码，如 `everyday` / `formal` / `phrasal` / `near` |
| `roleName` | `LanguageText[]` | 语域展示文案 |
| `pole` | string | 仅反义组使用，值为 `a` / `b` |
| `isCurrent` | boolean | 是否当前词条当前义项 |
| `card` | `ContentCommonCardDTO` | 知识点卡片内容 |

### 渲染建议

1. 印章角标：
   - `isCurrent = true` 时展示“当前”
   - 否则展示 `roleName`

2. 卡片正文：
   - 主标题优先用 `card.title`
   - 副标题优先用 `card.subTitle`
   - 图片用 `card.coverImage`

3. 点击跳转：
   - 优先使用 `card.content.type`
   - 以及 `card.content.uid`
   - 以及 `card.content.semanticId`

如果 `card.content` 为空，说明该卡只能展示，不应跳词典详情。

---

## 5. `ContentCommonCardDTO` 最少可依赖字段

本接口里成员卡片复用的是 `ContentCommonCardDTO`。  
前端建议至少依赖这些字段：

| 字段 | 说明 |
|---|---|
| `contentType` | 卡片内容类型 |
| `contentId` | 卡片内容 ID |
| `content` | 跳转信息，内含 `type / uid / semanticId` |
| `title` | 卡片标题 |
| `subTitle` | 卡片副标题 |
| `coverImage` | 卡片封面图 |
| `coverVideo` | 卡片视频 |
| `tags` | 标签 |
| `favorited` | 是否收藏 |
| `access` | 可见性状态 |

前端不要假设所有字段都必返，按现有 `ContentCommonCardDTO` 的空值兼容方式处理即可。

---

## 6. 空态约定

### 6.1 同义 / 反义组为空

当当前义项没有同义组或反义组时：

```json
"synonymSets": [],
"antonymSets": []
```

建议前端：

- 同义区空时显示“这一义项还没有同义组”
- 反义区空时显示“这一义项还没有反义组”

### 6.2 `semanticId` 不传

接口仍然可调用，但服务端会回落到第一义。  
前端收到响应后，应以返回体中的 `semanticId` 为当前实际义项。

这里的支持是兜底能力，不是推荐调用方式。

---

## 7. 请求示例

### 7.1 推荐调用方式

```http
GET /write/zhenxie/lexical/detail?contentType=EN_WORD&contentId=12345&semanticId=67890
```

### 7.2 兜底调用方式

```http
GET /write/zhenxie/lexical/detail?contentType=EN_WORD&contentId=12345
```

说明：

- 推荐方式：显式传 `semanticId`
- 兜底方式：仅用于首次进入无法拿到当前义项时

---

## 8. 返回示例

```json
{
  "contentType": "EN_WORD",
  "contentId": 12345,
  "semanticId": 67890,
  "headword": "take off",
  "pos": "VERB",
  "translate": [
    {
      "lang": "en",
      "text": "take off"
    },
    {
      "lang": "zh",
      "text": "起飞"
    }
  ],
  "descriptions": [
    {
      "lang": "en",
      "text": "to leave the ground and begin to fly"
    },
    {
      "lang": "zh",
      "text": "离开地面并开始飞行"
    }
  ],
  "semanticItems": [
    {
      "contentType": "EN_WORD",
      "contentId": 12345,
      "semanticId": 67890,
      "pos": "VERB",
      "posAddr": "v.",
      "posTitle": [
        {
          "lang": "en",
          "text": "v."
        },
        {
          "lang": "zh",
          "text": "动词"
        }
      ],
      "translate": "起飞"
    },
    {
      "contentType": "EN_WORD",
      "contentId": 12346,
      "semanticId": 67891,
      "pos": "VERB",
      "posAddr": "v.",
      "posTitle": [
        {
          "lang": "en",
          "text": "v."
        },
        {
          "lang": "zh",
          "text": "动词"
        }
      ],
      "translate": "脱下"
    }
  ],
  "synonymSets": [
    {
      "uid": 11395,
      "concept": [
        {
          "lang": "zh",
          "text": "发射/起飞"
        },
        {
          "lang": "en",
          "text": "launch / take off"
        }
      ],
      "descriptions": [
        {
          "lang": "zh",
          "text": "这一组表示离地升空相关说法。"
        }
      ],
      "members": [
        {
          "role": "everyday",
          "roleName": [
            {
              "lang": "en",
              "text": "Everyday"
            },
            {
              "lang": "zh",
              "text": "日常"
            }
          ],
          "pole": null,
          "isCurrent": false,
          "card": {
            "contentType": "EN_WORD",
            "contentId": 22301,
            "content": {
              "type": "EN_WORD",
              "uid": 22301,
              "semanticId": 77801
            },
            "title": "blast away",
            "subTitle": "发射",
            "favorited": false,
            "access": "NORMAL"
          }
        }
      ]
    }
  ],
  "antonymSets": [
    {
      "uid": 22395,
      "concept": [
        {
          "lang": "zh",
          "text": "起飞 vs 降落"
        },
        {
          "lang": "en",
          "text": "take off vs land"
        }
      ],
      "descriptions": [
        {
          "lang": "zh",
          "text": "表示离地与接地的对立。"
        }
      ],
      "poleLabels": {
        "a": [
          {
            "lang": "zh",
            "text": "起飞"
          }
        ],
        "b": [
          {
            "lang": "zh",
            "text": "降落"
          }
        ]
      },
      "display": {
        "left": "a",
        "right": "b"
      },
      "members": [
        {
          "role": null,
          "roleName": null,
          "pole": "a",
          "isCurrent": true,
          "card": {
            "contentType": "EN_WORD",
            "contentId": 12345,
            "content": {
              "type": "EN_WORD",
              "uid": 12345,
              "semanticId": 67890
            },
            "title": "take off",
            "subTitle": "起飞",
            "favorited": false,
            "access": "NORMAL"
          }
        },
        {
          "role": "formal",
          "roleName": [
            {
              "lang": "en",
              "text": "Formal"
            },
            {
              "lang": "zh",
              "text": "正式"
            }
          ],
          "pole": "b",
          "isCurrent": false,
          "card": {
            "contentType": "EN_WORD",
            "contentId": 22302,
            "content": {
              "type": "EN_WORD",
              "uid": 22302,
              "semanticId": 77802
            },
            "title": "land",
            "subTitle": "降落",
            "favorited": false,
            "access": "NORMAL"
          }
        }
      ]
    }
  ]
}
```

---

## 9. 前端调用建议

推荐的页面调用时序：

1. 词典页点击“同义反义”格
2. 带当前 `contentType + contentId + semanticId` 调详情接口
3. 用返回里的 `semanticItems` 画底部义项
4. 用户切换义项时，重新带新的 `semanticId` 调详情接口
5. 用新响应整页替换

不建议：

- 首次进入永远不传 `semanticId`
- 切义项只本地切高亮，不重调接口
- 自己按 `pole` 改写左右语义
- 再次过滤“当前成员”

