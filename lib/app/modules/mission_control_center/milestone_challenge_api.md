# 里程碑挑战接口文档

本文档用于前端联调里程碑挑战相关接口。

说明：
- 以下接口均需要登录态，且依赖服务端通过 `@TeamInfo` 注入当前团队与成员上下文。
- 以下响应示例默认只展示业务 `data` 部分，不展开通用 `HttpResult` 包装层。
- 日期字段统一使用 `yyyy-MM-dd` 格式。
- 时间字段为服务端返回的时间对象序列化结果，具体格式以当前网关/序列化配置为准。

## 接口总览

| 接口 | 方法 | 路径 | 说明 |
| --- | --- | --- | --- |
| 获取元信息 | `GET` | `/member/course/milestone/challenge/meta` | 获取创建页依赖的静态配置 |
| 分析挑战草稿 | `POST` | `/member/course/milestone/challenge/analyse` | 分析日期跨度、计划基线和子任务目标上限 |
| 创建挑战 | `POST` | `/member/course/milestone/challenge/create` | 创建新的里程碑挑战 |
| 查询总览 | `POST` | `/member/course/milestone/challenge/overview` | 获取进行中和待兑现挑战 |
| 查询历史 | `GET` | `/member/course/milestone/challenge/history` | 获取历史挑战统计和历史列表 |
| 查询详情 | `GET` | `/member/course/milestone/challenge/{uid}` | 获取单个挑战详情 |
| 兑现奖励 | `POST` | `/member/course/milestone/challenge/{uid}/claim` | 将待兑现挑战标记为已兑现 |
| 作废挑战 | `POST` | `/member/course/milestone/challenge/{uid}/void` | 将挑战作废并移入历史 |

## 业务规则

- 同时进行中的挑战上限为 `3` 个。
- 单个挑战最多支持 `3` 条子任务，最少 `1` 条。
- 创建挑战时，服务端会快照当前成员的每日计划分钟数，字段为 `planBaselineMinutes`。
- 历史列表只包含 `CLAIMED`、`VOIDED`、`EXPIRED` 三种状态。
- 总览列表只包含 `ACTIVE`、`CLAIMABLE` 两种状态。
- 子任务目标值必须大于 `0`，且不能超过分析接口返回的 `maxTargetValue`。
- `MINUTES + STREAK` 表示“连续 N 天，每天至少学习 X 分钟”：
  - `targetValue` 表示目标连续天数。
  - `dailyThresholdMinutes` 表示每天达标分钟数。
  - `targetDays` 为可选语义化字段，如果不传，后端会默认使用 `targetValue` 作为目标连续天数。

## 枚举说明

### 挑战状态 `MilestoneChallengeStatusEnum`

| 值 | 含义 |
| --- | --- |
| `ACTIVE` | 进行中，挑战仍在执行阶段 |
| `CLAIMABLE` | 已完成所有子任务，等待兑现奖励 |
| `CLAIMED` | 奖励已兑现，进入历史 |
| `EXPIRED` | 已过结束日期且未完成，进入历史 |
| `VOIDED` | 挑战被主动作废，进入历史 |

### 奖励状态 `MilestoneRewardStatusEnum`

| 值 | 含义 |
| --- | --- |
| `LOCKED` | 奖励已锁定，尚未满足兑现条件 |
| `CLAIMABLE` | 奖励已可兑现，等待履约 |
| `CLAIMED` | 奖励已兑现 |
| `VOIDED` | 奖励因挑战作废而失效 |

### 挑战主色调 `MilestoneChallengeToneEnum`

| 值 | 含义 |
| --- | --- |
| `BLUE` | 学习时长类目标 |
| `GREEN` | 学习天数/计划达标类目标 |
| `ORANGE` | 星星类目标 |
| `PURPLE` | 钻石类目标 |

### 子任务指标 `MilestoneMetricEnum`

| 值 | 含义 |
| --- | --- |
| `MINUTES` | 学习时长，按分钟统计 |
| `STARS` | 星星数量 |
| `GEMS` | 钻石数量 |
| `STUDY_DAYS` | 学习天数 |
| `PLAN_DAYS` | 完美计划天数，即达到每日计划分钟基线的天数 |

### 子任务统计方式 `MilestoneSubtaskKindEnum`

| 值 | 含义 |
| --- | --- |
| `ACCUMULATE` | 累计统计，按挑战区间内总值计算 |
| `QUALIFIED_DAYS` | 达标天数统计，按满足条件的自然日数量计算 |
| `STREAK` | 连续统计，按满足条件的最长连续天数计算 |

### 指标与统计方式合法组合

| 指标 | 可选统计方式 |
| --- | --- |
| `MINUTES` | `ACCUMULATE`、`STREAK` |
| `STARS` | `ACCUMULATE` |
| `GEMS` | `ACCUMULATE` |
| `STUDY_DAYS` | `QUALIFIED_DAYS`、`STREAK` |
| `PLAN_DAYS` | `QUALIFIED_DAYS`、`STREAK` |

## 通用对象说明

### 子任务请求对象 `MilestoneChallengeDraftSubtaskRequest`

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `metric` | `string` | 是 | 子任务指标，取值见 `MilestoneMetricEnum` |
| `kind` | `string` | 是 | 子任务统计方式，取值见 `MilestoneSubtaskKindEnum` |
| `targetValue` | `number` | 创建时是，分析时否 | 子任务目标值。除 `MINUTES + STREAK` 外，通常直接表示最终目标值 |
| `dailyThresholdMinutes` | `number` | 否 | 仅 `MINUTES + STREAK` 时有意义，表示“每天至少学习多少分钟才算达标” |
| `targetDays` | `number` | 否 | 仅 `MINUTES + STREAK` 时有意义，表示“目标连续多少天”。不传时后端默认取 `targetValue` |

补充说明：
- 分析接口只要求传 `metric` 和 `kind`，其余字段可按需要补充。
- 创建接口要求每条子任务必须传 `targetValue > 0`。

### 挑战详情对象 `MemberMilestoneChallengeDTO`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `uid` | `number` | 挑战唯一 ID |
| `name` | `string` | 挑战名称 |
| `status` | `string` | 挑战状态，取值见 `MilestoneChallengeStatusEnum` |
| `tone` | `string` | 挑战主色调，取值见 `MilestoneChallengeToneEnum` |
| `startDate` | `string` | 挑战开始日期 |
| `endDate` | `string` | 挑战结束日期 |
| `spanDays` | `number` | 挑战自然日跨度，起止日期均包含 |
| `remainingDays` | `number` | 距离结束日期的剩余天数，结束当日仍记为 1 |
| `planBaselineMinutes` | `number` | 创建挑战时快照的每日计划分钟基线 |
| `completedSubtasks` | `number` | 已完成的子任务数量 |
| `progressPct` | `number` | 父任务总进度，范围 `0~1` |
| `allSubtasksCompleted` | `boolean` | 是否所有子任务都已完成 |
| `rewardName` | `string` | 奖励名称 |
| `rewardIcon` | `string` | 奖励图标，当前第一版可能为空 |
| `promiserName` | `string` | 承诺者名称 |
| `rewardStatus` | `string` | 奖励状态，取值见 `MilestoneRewardStatusEnum` |
| `subtasks` | `array` | 子任务列表，字段见下表 |
| `claimableAt` | `string/date` | 首次进入待兑现状态的时间 |
| `claimedAt` | `string/date` | 奖励已兑现时间 |
| `expiredAt` | `string/date` | 挑战过期时间 |
| `voidedAt` | `string/date` | 挑战作废时间 |
| `updated` | `string/date` | 最后更新时间 |
| `created` | `string/date` | 创建时间 |

### 挑战详情中的子任务对象 `MemberMilestoneChallengeDTO.SubtaskDTO`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `subtaskId` | `string` | 子任务唯一标识 |
| `metric` | `string` | 子任务指标 |
| `kind` | `string` | 子任务统计方式 |
| `targetValue` | `number` | 子任务目标值 |
| `currentValue` | `number` | 子任务当前累计值 |
| `progressPct` | `number` | 子任务进度，范围 `0~1` |
| `completed` | `boolean` | 子任务是否已完成 |
| `unit` | `string` | 前端展示单位，如“分钟”“颗”“天” |
| `dailyThresholdMinutes` | `number` | 仅连续学习时长目标使用，表示每日达标分钟阈值 |
| `targetDays` | `number` | 仅连续学习时长目标使用，表示目标连续天数 |

## 1. 获取元信息

- 方法：`GET`
- 路径：`/member/course/milestone/challenge/meta`
- 说明：返回创建页所需的静态配置，包括挑战上限、可选指标、每个指标支持的统计方式、承诺者候选项。

### 请求参数

无请求体。

### 返回字段 `MemberMilestoneChallengeMetaDTO`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `activeLimit` | `number` | 同时可进行中的挑战上限 |
| `maxSubtaskCount` | `number` | 单个挑战允许配置的最大子任务数量 |
| `metrics` | `array` | 可选指标列表 |
| `promiserOptions` | `array[string]` | 承诺者名称候选项，可直接用于填充 `promiserName` |

#### `metrics[]` 字段说明

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `metric` | `string` | 指标编码 |
| `title` | `string` | 指标展示标题 |
| `allowedKinds` | `array[string]` | 当前指标允许的统计方式列表 |

### 返回示例

```json
{
  "activeLimit": 3,
  "maxSubtaskCount": 3,
  "metrics": [
    {
      "metric": "MINUTES",
      "title": "学习时长",
      "allowedKinds": ["ACCUMULATE", "STREAK"]
    },
    {
      "metric": "STARS",
      "title": "星星数量",
      "allowedKinds": ["ACCUMULATE"]
    }
  ],
  "promiserOptions": ["爸爸", "妈妈", "爷爷", "奶奶", "外公", "外婆"]
}
```

## 2. 分析挑战草稿

- 方法：`POST`
- 路径：`/member/course/milestone/challenge/analyse`
- 说明：不落库，只分析当前草稿的日期跨度、计划基线、可创建状态和每条子任务的目标上限。

### 请求参数 `MemberMilestoneChallengeAnalyseRequest`

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `startDate` | `string` | 是 | 挑战开始日期，格式 `yyyy-MM-dd` |
| `endDate` | `string` | 是 | 挑战结束日期，格式 `yyyy-MM-dd`，不能早于开始日期 |
| `subtasks` | `array` | 是 | 子任务草稿列表，最少 1 条，最多 3 条 |

#### `subtasks[]`

见上方“通用对象说明”中的 `MilestoneChallengeDraftSubtaskRequest`。

### 返回字段 `MemberMilestoneChallengeAnalyseDTO`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `activeLimit` | `number` | 同时可进行中的挑战上限 |
| `activeCount` | `number` | 当前已占用的挑战名额数量，仅统计 `ACTIVE` 和 `CLAIMABLE` |
| `canCreate` | `boolean` | 当前是否还能创建新挑战 |
| `spanDays` | `number` | 本次挑战的自然日跨度 |
| `planBaselineMinutes` | `number` | 当前成员的每日计划分钟基线，创建时会快照到挑战中 |
| `dailyMaxStars` | `number` | 依据当前计划分钟基线推导出的理论每日最高星星数 |
| `dailyMaxGems` | `number` | 当前规则下理论每日最高钻石数 |
| `normalizedSubtasks` | `array` | 每条草稿条件分析后的规则结果 |

#### `normalizedSubtasks[]`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `metric` | `string` | 规范化后的指标 |
| `kind` | `string` | 规范化后的统计方式 |
| `unit` | `string` | 目标值展示单位 |
| `maxTargetValue` | `number` | 当前配置下允许填写的最大目标值 |
| `dailyThresholdMinutes` | `number` | 连续学习时长目标的默认每日阈值分钟数，仅 `MINUTES + STREAK` 返回 |

### 请求示例

```json
{
  "startDate": "2026-06-12",
  "endDate": "2026-06-20",
  "subtasks": [
    {
      "metric": "MINUTES",
      "kind": "STREAK",
      "dailyThresholdMinutes": 20
    },
    {
      "metric": "STARS",
      "kind": "ACCUMULATE"
    }
  ]
}
```

### 返回示例

```json
{
  "activeLimit": 3,
  "activeCount": 1,
  "canCreate": true,
  "spanDays": 9,
  "planBaselineMinutes": 30,
  "dailyMaxStars": 18,
  "dailyMaxGems": 10,
  "normalizedSubtasks": [
    {
      "metric": "MINUTES",
      "kind": "STREAK",
      "unit": "天",
      "maxTargetValue": 9,
      "dailyThresholdMinutes": 20
    },
    {
      "metric": "STARS",
      "kind": "ACCUMULATE",
      "unit": "颗",
      "maxTargetValue": 162
    }
  ]
}
```

## 3. 创建挑战

- 方法：`POST`
- 路径：`/member/course/milestone/challenge/create`
- 说明：创建新的里程碑挑战。创建前会再次复用分析逻辑进行规则校验。

### 请求参数 `MemberMilestoneChallengeCreateRequest`

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `name` | `string` | 是 | 挑战名称 |
| `startDate` | `string` | 是 | 挑战开始日期，格式 `yyyy-MM-dd` |
| `endDate` | `string` | 是 | 挑战结束日期，格式 `yyyy-MM-dd` |
| `subtasks` | `array` | 是 | 子任务列表，最少 1 条，最多 3 条 |
| `rewardName` | `string` | 是 | 奖励名称 |
| `promiserName` | `string` | 是 | 承诺者名称，建议从 `meta.promiserOptions` 中选择 |

#### `subtasks[]`

见上方“通用对象说明”中的 `MilestoneChallengeDraftSubtaskRequest`。

创建接口补充规则：
- 每条子任务都必须传 `targetValue > 0`。
- 如果是 `MINUTES + STREAK`：
  - `targetValue` 表示目标连续天数。
  - `dailyThresholdMinutes` 建议传，表示每天至少学习多少分钟。
  - `targetDays` 可选，不传时默认等于 `targetValue`。

### 返回字段

返回 `MemberMilestoneChallengeDTO`，字段说明见“通用对象说明”。

### 请求示例

```json
{
  "name": "连续学习挑战",
  "startDate": "2026-06-12",
  "endDate": "2026-06-20",
  "subtasks": [
    {
      "metric": "MINUTES",
      "kind": "STREAK",
      "targetValue": 5,
      "dailyThresholdMinutes": 30
    },
    {
      "metric": "STARS",
      "kind": "ACCUMULATE",
      "targetValue": 60
    }
  ],
  "rewardName": "去游乐园",
  "promiserName": "妈妈"
}
```

## 4. 查询总览

- 方法：`POST`
- 路径：`/member/course/milestone/challenge/overview`
- 说明：返回首页主展示区数据，只包含 `ACTIVE` 和 `CLAIMABLE` 挑战。

### 请求参数

无请求体。

### 返回字段 `MemberMilestoneChallengeOverviewDTO`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `activeLimit` | `number` | 同时可进行中的挑战上限 |
| `activeCount` | `number` | 当前占用名额的挑战数量 |
| `canCreate` | `boolean` | 当前是否还允许创建新挑战 |
| `activeGoals` | `array` | 主视觉区展示的进行中/待兑现挑战列表 |

#### `activeGoals[]`

返回 `MemberMilestoneChallengeDTO`，字段说明见“通用对象说明”。

### 返回示例

```json
{
  "activeLimit": 3,
  "activeCount": 2,
  "canCreate": true,
  "activeGoals": [
    {
      "uid": 10001,
      "name": "连续学习挑战",
      "status": "ACTIVE"
    },
    {
      "uid": 10002,
      "name": "星星冲刺挑战",
      "status": "CLAIMABLE"
    }
  ]
}
```

## 5. 查询历史

- 方法：`GET`
- 路径：`/member/course/milestone/challenge/history`
- 说明：返回历史挑战统计和历史挑战列表，列表包含 `CLAIMED`、`VOIDED`、`EXPIRED` 三类状态。

### 请求参数

无请求体。

### 返回字段 `MemberMilestoneChallengeHistoryDTO`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `claimedCount` | `number` | 已兑现挑战数量 |
| `voidedCount` | `number` | 已作废挑战数量 |
| `expiredCount` | `number` | 已过期挑战数量 |
| `list` | `array` | 历史挑战列表 |

#### `list[]`

返回 `MemberMilestoneChallengeDTO`，字段说明见“通用对象说明”。

### 返回示例

```json
{
  "claimedCount": 3,
  "voidedCount": 1,
  "expiredCount": 2,
  "list": [
    {
      "uid": 10001,
      "name": "连续学习挑战",
      "status": "CLAIMED"
    },
    {
      "uid": 10002,
      "name": "星星冲刺挑战",
      "status": "EXPIRED"
    }
  ]
}
```

## 6. 查询详情

- 方法：`GET`
- 路径：`/member/course/milestone/challenge/{uid}`
- 说明：按挑战 ID 查询详情，返回前会刷新挑战进度和状态。

### 路径参数

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `uid` | `number` | 是 | 挑战唯一 ID |

### 返回字段

返回 `MemberMilestoneChallengeDTO`，字段说明见“通用对象说明”。

## 7. 兑现奖励

- 方法：`POST`
- 路径：`/member/course/milestone/challenge/{uid}/claim`
- 说明：将待兑现挑战标记为已兑现，仅 `CLAIMABLE` 状态允许调用。

### 路径参数

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `uid` | `number` | 是 | 挑战唯一 ID |

### 请求参数

无请求体。

### 返回字段

返回 `MemberMilestoneChallengeDTO`，字段说明见“通用对象说明”。

### 失败场景

- 挑战不存在：`当前里程碑挑战不存在`
- 挑战未达到兑现条件：`当前挑战未达到兑现条件`

## 8. 作废挑战

- 方法：`POST`
- 路径：`/member/course/milestone/challenge/{uid}/void`
- 说明：将挑战作废并移入历史。

### 路径参数

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `uid` | `number` | 是 | 挑战唯一 ID |

### 请求参数

无请求体。

### 返回字段

返回 `MemberMilestoneChallengeDTO`，字段说明见“通用对象说明”。

### 失败场景

- 挑战不存在：`当前里程碑挑战不存在`
- 已兑现不可作废：`已兑现的挑战不能作废`
- 已作废不可重复作废：`当前挑战已作废`
- 已过期不可再作废：`已过期的挑战不能再作废`

## 前端联调建议

- 创建页初始化时先调一次 `meta`。
- 用户每次修改日期、指标、统计方式后，可调 `analyse` 获取最新上限和单位。
- 用户点击创建前，确保 `subtasks[].targetValue` 不超过 `analyse.normalizedSubtasks[].maxTargetValue`。
- `MINUTES + STREAK` 场景建议前端显式传 `dailyThresholdMinutes`，不要完全依赖后端默认值。
- `promiserName` 建议直接使用 `meta.promiserOptions` 中的候选项，避免前后端展示不一致。
