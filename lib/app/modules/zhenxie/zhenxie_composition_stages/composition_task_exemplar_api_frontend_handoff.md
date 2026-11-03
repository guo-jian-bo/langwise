# 写作阶梯 / 写作任务 / 篇章范文 API 前端对接文档

## 1. 文档目的

这份文档用于给前端直接对接当前已经落地的接口。

重点不是再讲设计过程，而是明确：

1. 当前有哪些接口已经可用
2. 每个接口返回的字段是什么意思
3. ui_demo 上每一块区域应该用哪个字段渲染
4. 前端接入时有哪些统一约定，避免重复沟通

本文档以当前代码实现和 `ui_ux` demo 为准。

## 2. 覆盖接口

本次只覆盖：

1. `GET /write/en/composition/genre/list`
2. `GET /write/en/composition/milestone/list`
3. `GET /write/en/paragraph/rhetorical/beat/list`
4. `POST /write/en/composition/stage/pages`
5. `GET /write/en/composition/stage/detail`
6. `PUT /write/en/composition/stage/edit`
7. `GET /write/en/composition/stage/query/meta/group/list`
8. `POST /write/en/composition/task/pages`
9. `GET /write/en/composition/task/detail`
10. `GET /write/en/composition/task/query/meta/group/list`
11. `POST /write/en/composition/instance/pages`
12. `GET /write/en/composition/instance/detail`
13. `GET /write/en/composition/instance/query/meta/group/list`

## 3. 接口总览

### 3.1 文类词表

接口：

`GET /write/en/composition/genre/list`

作用：

1. 返回文类主键
2. 返回文类名称
3. 返回文类说明
4. 返回文类颜色

前端用途：

1. 写作任务列表筛选里的“文类”
2. 范文列表筛选里的“文类”
3. 任务卡 / 范文卡上的文类标签文案与颜色映射

返回结构：

```java
HttpResult<ListResult<EnSentenceColorSimpleNidDTO>>
```

每个元素包含：

1. `nid`
   - 文类主键
2. `name`
   - 文类多语言名称
3. `description`
   - 文类说明
4. `color`
   - 文类主色

前端建议：

1. 列表接口里直接取 `genreNid`
2. 再用本接口把 `genreNid -> 标签文案 / 标签颜色` 做映射
3. 不要再从 family 反推

### 3.2 里程碑词表

接口：

`GET /write/en/composition/milestone/list`

作用：

1. 返回里程碑主键
2. 返回里程碑名称
3. 返回里程碑说明

前端用途：

1. 阶梯编辑页下半区里程碑列表
2. 阶梯详情中的里程碑名称兜底映射
3. 需要做 `nid -> 名称` 转换时的轻量字典

返回结构：

```java
HttpResult<ListResult<EnSentenceSimpleNidDTO>>
```

每个元素包含：

1. `nid`
   - 里程碑主键
2. `name`
   - 里程碑多语言名称
3. `description`
   - 里程碑说明

补充说明：

1. 当前只返回 `enabled = true` 的里程碑
2. 后端排序为：
   - `difficulty`
   - `tier`
   - `order`
   - `nid`
3. 这是轻量词表接口，不展开更多业务字段

### 3.3 四拍词表

接口：

`GET /write/en/paragraph/rhetorical/beat/list`

作用：

返回起承转合四拍的基础词表。

前端用途：

1. 阶梯卡 / 阶梯弹窗里把 `beatNid` 映射成 `起 / 承 / 转 / 合`
2. 阶梯编辑页拍位区域显示四拍名称、说明和色值
3. 不再依赖 `stage` 或 `blueprint` DTO 内嵌四拍详情

返回结构：

```java
HttpResult<ListResult<EnWriteRhetoricalBeatDTO>>
```

每个元素包含：

1. `nid`
   - 四拍主键
2. `name`
   - 四拍多语言名称
3. `description`
   - 四拍说明
4. `color`
   - 四拍展示色
5. `gloss`
   - 四拍释义

前端建议：

1. 所有 `beatNid` 展示统一走这个接口映射
2. 阶梯的 `slots[*].beatNid` 只给主键，不直接下发“起承转合”中文
3. 有颜色印章需求时直接用 `color`

## 4. 写作任务

### 4.1 列表接口

接口：

`POST /write/en/composition/task/pages`

对应 ui_demo 页面：

1. `CompositionWritingPage`

返回：

```java
HttpResult<SimplePage<EnCompositionTaskItemDTO>>
```

#### 4.1.1 请求字段

当前可用字段：

1. `stageNid`
   - 关卡筛选
   - 对应页面 URL 中的 `?stage=`
2. `genreNid`
   - 文类筛选
3. `familyNid`
   - 家族筛选
4. `difficultyBand`
   - 难度档位筛选
5. `keyword`
   - 搜任务名、题干、关卡名、蓝图名、家族名、文类名
6. `sort`
   - 只认以下值：
   - `difficulty`
   - `-difficulty`
   - `catalog`
   - `-catalog`
   - `uid`
   - `-uid`

#### 4.1.2 卡片字段与 UI 对应

`CompositionWritingPage` 中每张卡的主要字段映射如下：

1. `uid`
   - 卡片 ID 芯片
   - 跳详情路由 `/composition/writing/{uid}`
   - ui_demo 里的“任务 30”就是由该字段派生
2. `name`
   - 中文主标题
   - 英文副标题
3. `stem`
   - 卡片说明文案
4. `coverUrl`
   - 卡片封面图
5. `blueprint`
   - `blueprint.name` 用于封面角标蓝图名
6. `genreNid`
   - 卡片右侧文类标签主键
   - 需再调 `GET /genre/list` 映射标签文案和颜色
7. `stage`
   - `stage.difficulty` 用于 CEFR 标签
   - `stage.headFill / stage.tailFill / stage.slots` 用于底部拍条
8. `stageNid`
   - 任务所属关卡
   - 用于保留当前关卡上下文
9. `difficulty`
   - 当前任务自己的难度窗口
   - “课序”排序按该字段的 `difficulty.min` 排
10. `exemplarCompositionId`
   - 表示是否绑定范文
11. `status`
   - 学习状态角标

#### 4.1.3 筛选口径

顶部筛选：

1. 文类 -> `genreNid`
2. 难度 -> `difficultyBand`
3. 家族 -> `familyNid`
4. 如果页面带 `?stage=` -> 下发到 `stageNid`

搜索框：

1. 任务名
2. 题干
3. 关卡名
4. 蓝图名
5. 家族名
6. 文类名

#### 4.1.4 排序口径

当前元数据文案已经和 ui_demo 对齐：

1. `difficulty`
   - `课序`
   - `↑ 零基础→雅思`
2. `-difficulty`
   - `课序`
   - `↓ 雅思→零基础`
3. `catalog`
   - `目录序`
   - `↑ 文类→蓝图`
4. `-catalog`
   - `目录序`
   - `↓ 蓝图→文类`
5. `uid`
   - `按编号`
   - `↑ 旧→新`
6. `-uid`
   - `按编号`
   - `↓ 新→旧`

注意：

1. 现在已经不兼容旧值
2. 不要再传 `path / -path / uid_asc / uid_desc`

### 4.2 详情接口

接口：

`GET /write/en/composition/task/detail?uid={uid}`

对应 ui_demo 页面：

1. `CompositionWritingDetailPage`

返回：

```java
HttpResult<EnCompositionTaskDetailDTO>
```

#### 4.2.1 页面左侧标题与题干

1. `name`
   - 页面标题
2. `stem`
   - 题干文字
3. `stemImageUrls`
   - 题干图片区
4. `stemVideoUrls`
   - 题干视频区
5. `stemAudioUrls`
   - 题干音频区

说明：

1. `stemImageKeys / stemVideoKeys / stemAudioKeys` 是原始 key
2. 前端做展示时优先用 `*Urls`

#### 4.2.2 左侧“交图片 / 交视频 / 交音频 / 正文写作”

这块主要看 `stage`：

1. `stage.answerKind`
   - `text`
   - `image`
   - `video`
   - `audio`
2. `stage.answerMinCount`
   - 最少提交数量
3. `stage.answerMaxCount`
   - 最多提交数量

对应关系：

1. `text`
   - 渲染正文写作纸面
2. `image`
   - 渲染“交图片 / 相册 / 拍摄”
3. `video`
   - 渲染视频上传面板
4. `audio`
   - 渲染录音 / 音频上传面板

#### 4.2.3 “查看范文”与锁定态

1. `exemplarCompositionId`
   - 是否挂了范文
2. `exemplar`
   - 范文轻量信息
3. `stage.lockExemplarView`
   - 是否锁住“查看范文”

注意：

1. `lockExemplarView` 在 `stage` 里
2. 不在任务详情顶层

#### 4.2.4 右侧蓝图教学区

这部分主要由 `stage + blueprint` 渲染：

1. `blueprint.name`
   - 右栏目标标题
2. `blueprint.description`
   - 顶部目标说明
3. `blueprint.frame`
   - 文首 / 文尾名称与 frame 结构
4. `blueprint.slots[*].allowedParagraphs[*].usageName`
   - 某一拍的用途短名
5. `blueprint.slots[*].allowedParagraphs[*].usageDescription`
   - 某一拍的教学说明
6. `stage.slots`
   - 当前关卡启用哪些拍
   - 每一拍使用什么段型
   - 每一拍是 `write / given / hidden`
7. `stage.lockBlueprintTab`
   - 蓝图 tab 是否锁定

对应 ui_demo：

1. `资料 / 蓝图` 切换
2. 蓝图路径图
3. `起 / 承 / 转 / 合` 的说明卡
4. `文章蓝图 >` 跳转

#### 4.2.5 正文写作纸面结构

1. `stage.headFill`
2. `stage.tailFill`
3. `stage.slots`
4. `blueprint.frame`

对应 ui_demo：

1. 文首 / 文尾是否展示
2. 哪些拍允许写
3. 哪些拍是给定段
4. 写作纸面上的分拍输入区

#### 4.2.6 右栏资料区

1. `knowledgePoints`
   - 右栏“资料”页签中的知识点列表

说明：

1. 来自 `en_composition_tasks` 主表内嵌字段
2. 不是额外 join 表

### 4.3 元数据接口

接口：

`GET /write/en/composition/task/query/meta/group/list`

作用：

返回任务列表筛选与排序元数据。

对应 ui_demo：

1. `CompositionWritingPage` 顶部筛选区
2. 排序弹层

filters：

1. `genreNid`
   - 文类
2. `difficultyBand`
   - 难度
3. `familyNid`
   - 家族

orders：

1. `difficulty`
   - 课序
2. `catalog`
   - 目录序
3. `uid`
   - 按编号

## 5. 篇章范文

### 5.1 列表接口

接口：

`POST /write/en/composition/instance/pages`

对应 ui_demo 页面：

1. `CompositionInstancesPage`

返回：

```java
HttpResult<SimplePage<EnCompositionInstanceItemDTO>>
```

#### 5.1.1 请求字段

当前可用字段：

1. `stageNid`
2. `genreNid`
3. `familyNid`
4. `difficultyBand`
5. `keyword`
6. `sort`
   - `difficulty`
   - `-difficulty`
   - `catalog`
   - `-catalog`
   - `uid`
   - `-uid`

#### 5.1.2 卡片字段与 UI 对应

`CompositionInstancesPage` 中每张卡的主要映射如下：

1. `uid`
   - 范文卡 ID 芯片
   - 路由 `/composition/instance/{uid}`
2. `title`
   - 中文主标题
   - 英文副标题
3. `blueprint`
   - `blueprint.name` 作为封面角标蓝图短名
4. `genreNid`
   - 卡片右侧文类标签主键
   - 需配合 `GET /genre/list`
5. `stage`
   - 如果存在关卡，优先展示 `stage.difficulty`
   - 也用于底部拍条
6. `difficulty`
   - 当没有 `stage` 时回退作为 CEFR 标签来源
   - “课序”排序按该字段的 `difficulty.min` 排
7. `compositionFamilyNid`
   - 家族筛选与蓝图详情跳转拼参
8. `taskId`
   - 从范文页跳回任务 / 打开编辑写作壁时可使用

#### 5.1.3 封面字段

当前范文卡有两套封面字段：

1. 兼容字段
   - `cover`
   - `coverUrl`
   - `coverMd5`
2. 新结构字段
   - `imageReview.image`

`imageReview.image` 当前包含：

1. `imageId`
2. `imageKey`
3. `imageUrl`
4. `md5`
5. `styleId`
6. `styleTitle`
7. `localeTitle`

用途：

1. 简单渲染封面时，直接用 `coverUrl`
2. 如果要打开 Admin 图片管理浮层，优先用 `imageReview.image.*`

来源：

1. `en_composition_image_relations`
2. `images`

不是 `en_compositions` 主表原始字段。

#### 5.1.4 搜索与筛选

搜索框：

1. 标题
2. 关卡名
3. 蓝图名
4. 家族名
5. 文类名

筛选：

1. 文类 -> `genreNid`
2. 家族 -> `familyNid`
3. 难度 -> `difficultyBand`
4. URL 上的 `?stage=` -> `stageNid`

### 5.2 详情接口

接口：

`GET /write/en/composition/instance/detail?uid={uid}`

对应 ui_demo 页面：

1. `CompositionInstanceDetailPage`

返回：

```java
HttpResult<EnCompositionDetailDTO>
```

#### 5.2.1 左侧题干与素材区域

范文详情页左侧顶部题干区不是只看范文本身，而是依赖 `task`：

1. `task.name`
2. `task.stem`
3. `task.stemImageUrls`
4. `task.stemVideoUrls`
5. `task.stemAudioUrls`

对应 ui_demo：

1. 顶部题干文字
2. 题干下的图片 / 视频 / 音频素材

#### 5.2.2 左侧范文正文 / 媒体答卷

1. `stage.answerKind`
   - 决定展示媒体答卷还是正文纸面
2. `answerImageUrls`
3. `answerVideoUrls`
4. `answerAudioUrls`
5. `headText`
6. `tailText`
7. `members / memberList`

对应关系：

1. `answerKind != text`
   - 展示媒体答卷浏览面板
2. `answerKind = text`
   - 展示文首 / 文尾 / 各拍正文成员段

#### 5.2.3 右侧蓝图与资料区

1. `blueprint.name`
   - 右栏目标标题
2. `blueprint.description`
   - 顶部目标说明
3. `blueprint.frame`
   - frame 结构
4. `stage`
   - 如果存在关卡，则路径图与教学分支按关卡裁剪
5. `members / memberList`
   - 把正文成员映射回蓝图节点
6. `task.knowledgePoints`
   - 右栏资料区知识点

#### 5.2.4 页面顶部与跳转

1. `title`
   - 范文标题
2. `compositionBlueprintNid`
   - 蓝图定位
3. `compositionFamilyNid`
   - 蓝图详情跳转 family 参数
4. `taskId`
   - 关联任务主键
5. `task.uid`
   - 可直接跳回编辑写作壁

### 5.3 元数据接口

接口：

`GET /write/en/composition/instance/query/meta/group/list`

作用：

返回范文列表筛选与排序元数据。

对应 ui_demo：

1. `CompositionInstancesPage` 顶部筛选区
2. 排序弹层

filters：

1. `genreNid`
   - 文类
2. `familyNid`
   - 家族
3. `difficultyBand`
   - 难度

orders：

1. `difficulty`
   - 课序
2. `catalog`
   - 目录序
3. `uid`
   - 按编号

## 6. 前端接入统一约定

1. 文类标签统一走：
   - 列表接口里的 `genreNid`
   - 配合 `GET /genre/list` 做文案与颜色映射
2. 任务详情里的锁定态统一从：
   - `stage.lockBlueprintTab`
   - `stage.lockExemplarView`
   获取
3. 题干媒体优先使用 `*Urls`
4. 范文卡简单渲染封面可直接使用 `coverUrl`
5. 范文卡如果要进入 Admin 图像管理浮层，优先使用：
   - `imageReview.image.imageId`
   - `imageReview.image.imageKey`
   - `imageReview.image.imageUrl`
   - `imageReview.image.styleId`
   - `imageReview.image.styleTitle`
   - `imageReview.image.localeTitle`
6. 当前排序值只认：
   - `difficulty / -difficulty`
   - `catalog / -catalog`
   - `uid / -uid`

## 7. 写作阶梯

### 7.1 列表接口

接口：

`POST /write/en/composition/stage/pages`

对应 ui_demo 页面：

1. `CompositionStagesPage`

返回：

```java
HttpResult<SimplePage<EnCompositionStageItemDTO>>
```

作用：

1. 阶梯地图页 / 列表页拉取卡片数据
2. 阶梯弹窗展示封面、标题、文类、难度、蓝图、里程碑、拍位填法
3. 给 `编辑 / 蓝图 / 范文 / 任务` 四个按钮提供跳转所需 nid

#### 7.1.1 请求字段

请求体类型：

`EnCompositionStagePageQuery`

当前请求体只保留两个字段：

1. `content`
   - 搜索内容
   - 会同时命中：
   - 关卡 `nid`
   - 关卡名
   - 关卡说明
   - 蓝图名
   - 家族名
   - 文类名
   - 里程碑名
2. `filters`
   - 通用筛选透传
   - 每项结构：
   - `code`
   - `values`

示例：

```json
{
  "content": "标签",
  "filters": [
    {
      "code": "genreNid",
      "values": ["practical_writing"]
    },
    {
      "code": "familyNid",
      "values": ["label"]
    },
    {
      "code": "difficultyBand",
      "values": ["0", "1"]
    }
  ]
}
```

说明：

1. `filters` 可以不传
2. 同一个 `code` 出现多次时，后端会把 `values` 合并去重
3. 同一个筛选项内多个值按“或”匹配
4. `difficultyBand` 虽然语义是数字档位，但请求里仍然按字符串数组传

#### 7.1.2 `filters.code` 取值说明

1. `genreNid`
   - 文类主键
   - 实际链路是：
   - `stage -> blueprint -> family -> genreNid`
   - 适合驱动“记叙文 / 说明文 / 议论文 / 应用文”这类筛选
2. `familyNid`
   - 家族主键
   - 实际链路是：
   - `stage -> blueprint -> compositionFamilyNid`
   - 适合驱动“标签 / 邀请函 / 日记 / 便签”这类筛选
3. `difficultyBand`
   - 难度档位
   - 后端命中规则：
   - `stage.difficulty.min <= difficultyBand <= stage.difficulty.max`

`difficultyBand` 当前取值约定：

1. `"0"`
   - `PreA1/剑一/0-3年级`
2. `"1"`
   - `A1/剑二/4-6年级`
3. `"2"`
   - `A2/KET/初中`
4. `"3"`
   - `B1/PET/高中`
5. `"4"`
   - `B2/FCE/雅思6.5`
6. `"5"`
   - `C1/CAE/雅思7.5`

#### 7.1.3 分页与排序

这个接口的筛选走 `requestBody`，分页和排序走通用 `PageParam`。

当前后端实际使用到的分页字段：

1. `offset`
   - 起始偏移量
   - 小于 0 时会被收敛成 0
2. `limit`
   - 单页条数
   - 小于等于 0 时会被收敛成 10
3. `order`
   - 排序值
   - 不再从请求体读取 `sort`

`PageParam.order` 当前支持：

1. `order`
   - 按阶梯全局课序正序
   - 即低阶到高阶
2. `-order`
   - 按阶梯全局课序倒序
3. `catalog`
   - 按：
   - 文类顺序
   - 家族顺序
   - 蓝图顺序
   - 阶梯顺序
   - 进行正序排列
4. `-catalog`
   - 上述目录序倒序

说明：

1. 现在不要再传请求体里的 `sort`
2. 排序切换统一改传 `PageParam.order`
3. 排序值为空或非法时，后端默认按 `order`

#### 7.1.4 卡片字段与 UI 对应

`CompositionStagesPage` 中每张阶梯卡 / 弹窗的主要字段映射如下：

1. `nid`
   - 阶梯主键
   - 用于：
   - `编辑` 按钮跳转
   - `范文` 按钮按 `stageNid` 跳转
   - `任务` 按钮跳转
2. `coverUrl`
   - 阶梯封面图
   - 用于卡面主视觉
3. `name`
   - 卡片中文标题
4. `description`
   - 卡片说明文案
5. `genreNid`
   - 文类标签主键
   - 配合 `GET /write/en/composition/genre/list` 做标签文案和颜色映射
6. `difficulty`
   - 阶梯难度窗口
   - 用于 CEFR / 学段标签展示
7. `compositionBlueprint`
   - 蓝图展开结构
   - `compositionBlueprint.name` 用于蓝图标题
   - `compositionBlueprint.frame` 用于文首 / 文尾结构判断
   - `compositionBlueprint.nid` + `compositionBlueprint.compositionFamilyNid` 用于 `蓝图` 按钮跳转
8. `slots`
   - 当前关卡正文拍位填法
   - 每一项给出：
   - `beatNid`
   - `paragraphTypeNid`
   - `fill`
9. `headFill`
   - 文首填法
10. `tailFill`
   - 文尾填法
11. `milestones`
   - 里程碑 nid 原始列表
12. `milestoneList`
   - 已展开的里程碑轻量信息
   - 阶梯卡上的里程碑名称展示优先用它
13. `lockBlueprintTab`
   - 当前关卡是否锁定蓝图说明页
14. `lockExemplarView`
   - 当前关卡是否锁定范文查看
15. `answerKind`
   - 当前关卡作答类型
   - 常见值：
   - `text`
   - `image`
   - `video`
   - `audio`
16. `answerMinCount`
   - 最少提交数量
17. `answerMaxCount`
   - 最多提交数量

#### 7.1.5 拍位填法取值说明

`slots[*].fill`、`headFill`、`tailFill` 当前主要使用以下值：

1. `given`
   - 该位置由系统直接给定内容
2. `write`
   - 该位置需要用户自己写
3. `hidden`
   - 该位置不直接对用户展示

对应前端理解：

1. `given`
   - 常用于显示“给定段 / 已给内容”
2. `write`
   - 常用于显示“当前拍需要写”
3. `hidden`
   - 常用于显示“无”或不渲染输入区

是否展示文首 / 文尾，还要结合：

1. `compositionBlueprint.frame.hasHead`
2. `compositionBlueprint.frame.hasTail`

也就是说：

1. 只有 `hasHead=true` 时，`headFill` 才有实际意义
2. 只有 `hasTail=true` 时，`tailFill` 才有实际意义

#### 7.1.6 四个按钮跳转依赖

当前这 4 个按钮所需 nid 已经都在返回体里：

1. `编辑`
   - 用 `nid`
2. `蓝图`
   - 用 `compositionBlueprint.nid`
   - 和 `compositionBlueprint.compositionFamilyNid`
3. `范文`
   - 用 `nid`
   - 作为 `stageNid`
4. `任务`
   - 用 `nid`

所以对前端来说，`stage/pages` 这个列表接口已经能直接支撑：

1. 阶梯卡渲染
2. 阶梯弹窗渲染
3. 四个按钮跳转参数拼接

补充说明：

1. `slots[*].beatNid` 只是四拍 nid
2. 真正显示成 `起 / 承 / 转 / 合`，前端要配合：
   - `GET /write/en/paragraph/rhetorical/beat/list`

### 7.2 详情接口

接口：

`GET /write/en/composition/stage/detail?nid={nid}`

对应 ui_demo 页面：

1. `CompositionStageEditPage`

返回：

```java
HttpResult<EnCompositionStageDTO>
```

作用：

1. 编辑页加载单个阶梯详情
2. 回显左侧封面、标题、说明、作答配置、锁定态
3. 回显拍位、里程碑、学习进度等当前关卡配置

#### 7.2.1 页面基础信息

1. `nid`
   - 关卡主键
2. `name`
   - 多语言关卡标题
3. `description`
   - 多语言关卡说明
4. `order`
   - 全局课程序
5. `difficulty`
   - 难度窗口
6. `enabled`
   - 是否启用
7. `system`
   - 是否系统内置

#### 7.2.2 左侧封面与蓝图基础信息

1. `cover`
   - 封面资源 key
2. `coverUrl`
   - 左侧封面图 URL
3. `coverMd5`
   - 封面 md5
4. `compositionBlueprintNid`
   - 所属蓝图主键
5. `compositionBlueprint`
   - 蓝图轻量信息
   - 当前只包含：
   - `nid`
   - `name`
   - `description`

注意：

1. `compositionBlueprint` 当前是轻量结构，不是完整蓝图 DTO
2. 编辑页如果要做更深的蓝图教学结构展示，需要走蓝图自己的接口

#### 7.2.3 作答与锁定配置

1. `answerKind`
   - `text / image / video / audio`
2. `answerMinCount`
   - 最少提交数
3. `answerMaxCount`
   - 最多提交数
4. `lockBlueprintTab`
   - 是否锁蓝图
5. `lockExemplarView`
   - 是否锁范文

#### 7.2.4 拍位与里程碑

1. `slots`
   - 每个拍位的配置
   - 当前元素包含：
   - `order`
   - `beatNid`
   - `paragraphTypeNid`
   - `fill`
2. `headFill`
   - 文首填法
3. `tailFill`
   - 文尾填法
4. `milestones`
   - 里程碑 nid 原始列表
5. `milestoneList`
   - 已展开的里程碑轻量列表

补充说明：

1. 四拍名称仍然需要通过：
   - `GET /write/en/paragraph/rhetorical/beat/list`
   做 `beatNid -> 起承转合` 映射
2. 里程碑候选全集通过：
   - `GET /write/en/composition/milestone/list`
   获取

#### 7.2.5 统计字段

1. `learnedCount`
   - 已学习数量
2. `taskCount`
   - 任务总数

这两个字段主要用于编辑页底部的只读统计展示，不建议当作筛选条件。

### 7.3 保存接口

接口：

`PUT /write/en/composition/stage/edit`

请求体类型：

`EnCompositionStageEditRequest`

返回：

```java
HttpResult<EnCompositionStageDTO>
```

作用：

保存当前阶梯编辑页改动，并返回最新详情结构。

#### 7.3.1 请求字段

1. `nid`
   - 关卡主键
2. `name`
   - 多语言名称
3. `description`
   - 多语言说明
4. `difficulty`
   - 难度窗口
   - 包含：
   - `min`
   - `max`
5. `order`
   - 全局课程序
6. `lockBlueprintTab`
   - 是否锁定蓝图页
7. `lockExemplarView`
   - 是否锁定范文查看
8. `answerKind`
   - `text / image / video / audio`
9. `answerMinCount`
   - 最少提交数量
10. `answerMaxCount`
   - 最多提交数量
11. `slots`
   - 关卡拍位配置
12. `headFill`
   - 文首填法
13. `tailFill`
   - 文尾填法
14. `milestones`
   - 里程碑 nid 列表

#### 7.3.2 `slots` 元素结构

每个 `slots[]` 元素当前使用：

1. `order`
   - 关卡内部顺序
2. `beatNid`
   - 四拍 nid
3. `paragraphTypeNid`
   - 段型主键
4. `fill`
   - `given / write / hidden`

#### 7.3.3 后端校验口径

1. `nid` 不能为空，且必须对应已有阶梯
2. `difficulty.min`、`difficulty.max` 不能为空，且 `min <= max`
3. `answerKind` 只允许：
   - `text`
   - `image`
   - `video`
   - `audio`
4. `answerMinCount`、`answerMaxCount` 不能为空，且 `min <= max`
5. 当 `answerKind = text` 时：
   - `answerMinCount = 1`
   - `answerMaxCount = 1`
6. `headFill`、`tailFill` 只允许：
   - `given`
   - `write`
   - `hidden`
7. 如果蓝图 frame 没开文首 / 文尾，对应位置不能保存成 `given` 或 `write`
8. `slots[*].fill` 只允许：
   - `given`
   - `write`
   - `hidden`
9. `slots[*].beatNid` 和 `slots[*].paragraphTypeNid` 不能为空
10. `slots[*].paragraphTypeNid` 必须属于该蓝图该 `beat` 允许的段型集合
11. `milestones` 里的 nid 必须都是真实存在的里程碑

#### 7.3.4 前端提交建议

1. 编辑页按全量提交理解，不要只传局部 diff
2. `slots[*].beatNid` 的名称展示来自四拍词表，不要自己写死中文
3. `milestones` 提交时只传 nid 数组即可

### 7.4 筛选元数据接口

接口：

`GET /write/en/composition/stage/query/meta/group/list`

返回：

```java
HttpResult<AdminQueryMetaDTO>
```

作用：

返回写作阶梯列表页顶部筛选区和排序弹层所需元数据。

#### 7.4.1 filters

当前包含 3 组：

1. `genreNid`
   - 文类
   - `type = checkbox`
2. `difficultyBand`
   - 难度
   - `type = checkbox`
3. `familyNid`
   - 家族
   - `type = checkbox`

#### 7.4.2 orders

当前包含 2 组：

1. `order`
   - 课序
   - 取值：
   - `order`
   - `-order`
2. `catalog`
   - 目录序
   - 取值：
   - `catalog`
   - `-catalog`

前端规则：

1. 列表筛选的 `filters.code` 直接复用元数据里的 `code`
2. 排序值直接写进 `PageParam.order`
3. 阶梯列表当前没有独立的 `uid` 排序

## 8. 参考文件

1. [主设计文档](file:///Users/tanrong/Desktop/git/docs/composition_task_exemplar_api_design.md)
2. [篇章控制器](file:///Users/tanrong/Desktop/git/language/language-admin/src/main/java/com/timelywise/language/admin/controller/write/paragraph/EnCompositionController.java)
3. [段落控制器](file:///Users/tanrong/Desktop/git/language/language-admin/src/main/java/com/timelywise/language/admin/controller/write/paragraph/EnParagraphController.java)
4. [阶梯列表页 ui_demo](file:///Users/tanrong/Desktop/git/ui_ux/src/pages/zhenxie/write/CompositionStagesPage.tsx)
5. [阶梯编辑页 ui_demo](file:///Users/tanrong/Desktop/git/ui_ux/src/pages/zhenxie/write/CompositionStageEditPage.tsx)
6. [任务列表页 ui_demo](file:///Users/tanrong/Desktop/git/ui_ux/src/pages/zhenxie/write/CompositionWritingPage.tsx)
7. [任务详情页 ui_demo](file:///Users/tanrong/Desktop/git/ui_ux/src/pages/zhenxie/write/CompositionWritingDetailPage.tsx)
8. [范文列表页 ui_demo](file:///Users/tanrong/Desktop/git/ui_ux/src/pages/zhenxie/write/CompositionInstancesPage.tsx)
9. [范文详情页 ui_demo](file:///Users/tanrong/Desktop/git/ui_ux/src/pages/zhenxie/write/CompositionInstanceDetailPage.tsx)
