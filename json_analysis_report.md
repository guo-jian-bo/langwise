# JSON 文件对比分析报告

## 📋 文件基本信息

| 属性 | `xxx.json` | `xxx2.json` |
|------|-----------|-------------|
| 文件大小 | 441KB (6775行) | 约150KB (4559行) |
| 数据类型 | 完整单词详情 | 语义化单词数据 |
| `semanticId` | 664973 | 664969 |

---

## 🏗️ 层级结构对比

### `xxx.json` 结构（完整单词数据）

```json
{
  "code": 200,
  "data": {
    "content": "ball",                    // 单词内容
    "contentType": "EN_WORD",            // 内容类型
    "contentId": 104432,                 // 内容ID
    "semanticId": 664973,                // 语义ID
    "module": "PRONUNCIATION_MEANING",   // 模块类型
    "posList": [                         // 词性列表
      {
        "contentType": "EN_WORD",
        "contentId": 104432,
        "pos": "NOUN",                   // 词性
        "posTitle": [...],               // 多语言词性标题
        "gloss": [...],                  // 简明释义
        "pronunciations": [              // 发音列表（含详细音标）
          {
            "audioId": 86028,
            "accentId": 7,
            "phonetic": "bɔːl",        // 国际音标
            "audioUrl": "...",
            "duration": 1.34,
            "national": "US",            // 美式/英式
            "syllables": [...],          // 音节划分
            "phonetics": [...]           // 音素详情
          }
        ],
        "semantics": [                  // 语义列表
          {
            "uid": 664969,
            "imageUrl": "...",
            "video": {...},              // 视频对象
            "gloss": [...],
            "descriptions": [...],
            "difficulty": 1,
            "sentences": [              // 例句
              {
                "contentType": "EN_SENTENCE",
                "content": "They have ten balls.",
                "definition": "他们有十个球。",
                "pronunciations": [...],
                "video": {...},         // 每个例句都有视频
                "rights": "NO_RIGHTS"   // 权限
              }
            ]
          }
        ]
      }
    ]
  }
}
```

### `xxx2.json` 结构（语义化数据）

```json
{
  "code": 200,
  "data": {
    "contentType": "EN_WORD",
    "contentId": 104432,
    "semanticId": 664969,
    "semanticItems": [                  // 语义项列表（简化）
      {
        "contentType": "EN_WORD",
        "contentId": 104432,
        "semanticId": 664969,
        "pos": "NOUN",
        "posAddr": "n.",                // 简写形式
        "posTitle": [...],
        "translate": "球（体育用品）"     // 简单翻译
      }
    ],
    "semantic": {                       // 单一语义详情
      "uid": 664969,
      "imageUrl": "...",
      "video": null,                     // 可能为null
      "gloss": [...],
      "descriptions": [...],
      "difficulty": 1,
      "sentences": [                    // 例句（简化）
        {
          "contentType": "EN_SENTENCE",
          "content": "They have ten balls.",
          "definition": "他们有十个球。",
          "pronunciations": [...],
          "imageUrl": "...",
          "audioUrl": "...",
          "access": "NORMAL"
        }
      ]
    }
  }
}
```

---

## 🔍 关键字段差异对比

| 字段/特性 | `xxx.json` | `xxx2.json` | 说明 |
|-----------|-----------|-------------|------|
| **数据粒度** | 单词级别（多词性） | 语义级别（单一语义） | 不同的数据组织方式 |
| `content` | ✅ 有 | ❌ 无 | 单词本身 |
| `module` | ✅ 有 | ❌ 无 | 模块类型标识 |
| 词性组织 | `posList[]` | `semanticItems[]` | 不同的数组结构 |
| 词性表示 | `pos: "NOUN"` | `posAddr: "n."` | 完整 vs 缩写 |
| 释义字段 | `gloss[]`（多语言数组） | `translate`（单字符串） | xxx2.json更简化 |
| 发音详细度 | 完整（音标+音节+音素） | 例句中才有 | xxx.json单词级别有发音 |
| **视频资源** | 单词+例句都有 | `semantic.video`可为null | xxx.json视频更丰富 |
| 例句视频 | ✅ 每个例句都有 | ❌ 无 | xxx2.json只有图片 |
| 权限字段 | `rights` | `access` | 不同的权限标识 |

---

## 📊 字段含义详解

### 公共字段

| 字段 | 类型 | 含义 |
|------|------|------|
| `code` | Number | HTTP状态码，200表示成功 |
| `contentType` | String | 内容类型，`EN_WORD`=英文单词，`EN_SENTENCE`=英文句子 |
| `contentId` | Number | 内容唯一标识符 |
| `semanticId` | Number | 语义唯一标识符（一个单词可能有多个语义） |
| `pos` / `posAddr` | String | 词性，如 NOUN/n.（名词）、VERB/v.（动词） |
| `posTitle` | Array | 多语言词性标题 |
| `gloss` | Array | 简明释义（多语言） |
| `difficulty` | Number | 难度等级 |
| `imageUrl` | String | 配图URL |
| `audioUrl` | String | 音频URL |
| `national` | String | 口音，`US`=美式，`UK`=英式 |
| `in_course_cnt` | Number | 出现在课程中的次数 |

### `xxx.json` 特有字段

| 字段 | 类型 | 含义 |
|------|------|------|
| `module` | String | 功能模块，如 `PRONUNCIATION_MEANING` |
| `content` | String | 单词文本内容 |
| `phonetic` | String | 国际音标 |
| `syllables` | Array | 音节信息（含IPA、拼写、位置） |
| `phonetics` | Array | 音素级别发音信息 |
| `video` | Object | 视频信息（videoUrl, duration, md5等） |
| `rights` | String | 权限控制，`NO_RIGHTS`=无权限限制 |

### `xxx2.json` 特有字段

| 字段 | 类型 | 含义 |
|------|------|------|
| `semanticItems` | Array | 所有相关语义项列表（简化版） |
| `semantic` | Object | 当前选中的语义详细信息 |
| `translate` | String | 中文翻译（简化字符串） |
| `access` | String | 访问权限，`NORMAL`=正常访问 |

---

## ⚡ 核心差异总结

### 1. 数据焦点不同
- **`xxx.json`**：单词级别完整数据，适合单词详情页、发音教学
- **`xxx2.json`**：语义级别数据，适合语义卡片、例句练习

### 2. 视频资源差异
- **`xxx.json`**：包含丰富的视频（单词视频 + 每个例句的视频）
- **`xxx2.json`**：视频可能为null，例句只有图片和音频

### 3. 发音教学深度
- **`xxx.json`**：单词级别就有完整发音数据（音标+音节+音素拆分）
- **`xxx2.json`**：只在例句级别有发音

### 4. 语义ID指向

| 文件 | semanticId | 含义 |
|------|-----------|------|
| xxx.json | 664973 | 舞会；正式舞会 |
| xxx2.json | 664969 | 球（体育用品） |

### 5. 数据结构复杂度
- **`xxx.json`**：层级深（`posList → semantics → sentences`），数据量大
- **`xxx2.json`**：结构扁平，轻量快速

---

## 💡 使用场景建议

| 场景 | 推荐文件 | 原因 |
|------|---------|------|
| 单词详情页 | `xxx.json` | 需要完整词性、发音教学 |
| 视频学习 | `xxx.json` | 丰富的视频资源 |
| 语义卡片 | `xxx2.json` | 轻量、快速加载 |
| 例句练习 | `xxx2.json` | 结构简洁，适合练习 |
| 发音教学 | `xxx.json` | 音素级别发音数据 |
