# MQTT 消息测试文档

## 1. 文档目的

本文档用于指导 `mqtt_utils` 目录下 MQTT 消息链路的联调测试、回归测试与异常验证，重点覆盖：

- MQTT 建连与重连
- topic 订阅
- 消息解析与去重
- 初始化消息与实时消息协作
- 队列节流与黑名单暂停
- Banner / Toast / Modal 展示
- Banner 点击后的已读、跳转与回调
- `ACTIVITY` 模块特殊业务处理

## 2. 测试范围

| 范围 | 说明 |
| --- | --- |
| 连接层 | token 获取、建连、断连、重连、心跳监控 |
| 消息接收层 | JSON 解析、retained 消息过滤、uid 去重 |
| 分发层 | code 广播、消息入队、每秒一条消费 |
| 展示层 | 红点、Banner、Toast、Modal |
| 交互层 | 已读上报、已展示上报、页面跳转、返回回调 |
| 业务层 | ACTIVITY 模块下的奖励与任务刷新 |

## 3. 测试准备

### 3.1 环境准备

- 准备可正常连接的 MQTT broker 环境
- 准备一个可登录账号
- 确认 `GET /authorize/mqtt/client/token` 可正常返回
- 确认消息列表接口与读消息接口可正常调用
- 确认测试账号具备至少一个可接收消息的用户 topic

### 3.2 建议观测点

测试时建议同时观察以下内容：

- App 控制台 `[MQTT]` 日志
- Broker 连接日志与订阅日志
- 消息中心 UI 列表变化
- Banner / Toast / Modal 是否展示
- 点击通知后的路由跳转结果
- 已读状态是否同步变化

### 3.3 建议测试数据模板

#### 普通 Banner 消息

```json
{
  "uid": 10001,
  "display": 1,
  "displayOperate": 0,
  "title": "任务完成",
  "content": "你有一个新的处理结果",
  "jump": {
    "code": "manage_lesson_execirse_ai_prevew",
    "params": {
      "aiRecordId": "10"
    }
  },
  "category": "MANAGE",
  "module": "SYSTEM",
  "code": "audio_task_message",
  "read": 0,
  "report": true
}
```

#### Toast 消息

```json
{
  "uid": 10002,
  "display": 2,
  "title": "轻提示消息",
  "content": "这条内容不会直接展示在 toast 正文中",
  "category": "SYSTEM",
  "module": "SYSTEM",
  "code": "toast_test",
  "read": 0,
  "report": true
}
```

#### Modal 消息

```json
{
  "uid": 10003,
  "display": 4,
  "title": "系统通知",
  "content": "请确认当前操作结果",
  "category": "SYSTEM",
  "module": "SYSTEM",
  "code": "modal_test",
  "read": 0,
  "report": true
}
```

#### ACTIVITY 奖励消息

```json
{
  "uid": 10004,
  "display": 1,
  "displayOperate": 1,
  "title": "奖励到账",
  "content": "你获得了一项任务奖励",
  "category": "reward",
  "module": "ACTIVITY",
  "code": "task_001",
  "read": 0,
  "report": true
}
```

## 4. 测试策略

### 4.1 优先级

建议按以下优先级执行：

1. P0: 建连、收包、去重、展示、已读
2. P1: 黑名单暂停、跳转回调、初始化消息协作（黑名单包括现在的所有的做题页面）
3. P2: ACTIVITY 特殊处理、异常场景、边界场景

### 4.2 执行顺序

建议执行顺序如下：

1. 先验证连接链路
2. 再验证单条消息展示
3. 再验证多条消息队列
4. 再验证点击交互
5. 最后验证异常和边界场景

## 5. 功能测试用例

### 5.1 建连测试

| 用例 ID | 测试项 | 前置条件 | 操作步骤 | 预期结果 |
| --- | --- | --- | --- | --- |
| CONN-01 | 已登录初始化建连 | 用户已登录 | 启动应用 | 成功获取 token，MQTT 建立连接，输出连接成功日志 |
| CONN-02 | 未登录不建连 | 用户未登录 | 启动应用 | 不调用 MQTT 建连流程 |
| CONN-03 | 避免重复建连 | 正在连接或已连接 | 重复触发 `initMqtt()` | 日志显示跳过初始化，不重复连接 |
| CONN-04 | token 缺字段 | 接口返回缺少 `host/clientId/username/password` | 调用 `initMqtt()` | 建连中止，不创建有效连接 |
| CONN-05 | 首次连接失败自动重连 | broker 不可达 | 调用 `initMqtt()` | 进入重连调度，5 秒后再次尝试 |
| CONN-06 | 最大重连次数限制 | 持续连接失败 | 连续等待重连 | 最多重试 10 次，之后停止继续重连 |
| CONN-07 | 手动断开不重连 | 已连接 | 调用 `disconnect()` | 连接关闭，不再自动重连 |

### 5.2 Topic 订阅测试

| 用例 ID | 测试项 | 前置条件 | 操作步骤 | 预期结果 |
| --- | --- | --- | --- | --- |
| TOPIC-01 | 订阅用户 topic | token 中含 `username` | 建连成功后查看日志 | 输出当前用户各模块 topic 列表 |
| TOPIC-02 | 按环境切换 topic | 分别在 `pro/dev` 环境测试 | 建连成功后查看 topic | topic 中环境段正确切换为 `prod/dev` |
| TOPIC-03 | 群组 topic 未启用确认 | token 中有 `groups` | 建连后查看订阅列表 | 当前不会订阅 group topic |
| TOPIC-04 | 广播 topic 未启用确认 | 正常建连 | 查看订阅列表 | 当前不会订阅 broadcast topic |

### 5.3 收包与解析测试

| 用例 ID | 测试项 | 前置条件 | 操作步骤 | 预期结果 |
| --- | --- | --- | --- | --- |
| MSG-01 | 正常 JSON 消息解析 | 已连接且已订阅 | broker 下发合法 JSON | 成功转成 `PushMessageEntity` 并分发 |
| MSG-02 | 非 JSON 消息 | 已连接 | 下发非法 JSON 字符串 | 捕获异常，记录错误日志，不闪退 |
| MSG-03 | payload 不是对象 | 已连接 | 下发 JSON 数组或字符串 | 被忽略，不进入业务分发 |
| MSG-04 | retained 消息忽略 | 已连接 | 下发 retain 消息 | 当前消息不参与业务分发 |
| MSG-05 | 清理 retained 状态 | 已连接 | 下发普通消息并带 topic | 客户端尝试向原 topic 发布空 retained 消息 |

### 5.4 去重测试

| 用例 ID | 测试项 | 前置条件 | 操作步骤 | 预期结果 |
| --- | --- | --- | --- | --- |
| DEDUP-01 | MQTT 重复 uid 去重 | 已连接 | 连续发送两条相同 `uid` 消息 | 仅首次进入展示流程 |
| DEDUP-02 | 初始化消息与实时消息去重 | 启动时有列表消息，且 broker 也推送相同 `uid` | 先拉列表再收实时消息，或反向执行 | 同一 `uid` 仅展示一次 |
| DEDUP-03 | 手动注入重复 uid 去重 | 已有同 uid 在 `_messageUidSet` | 调用 `manualSetMessage()` | 重复消息被过滤 |

### 5.5 队列与节流测试

| 用例 ID | 测试项 | 前置条件 | 操作步骤 | 预期结果 |
| --- | --- | --- | --- | --- |
| QUEUE-01 | 多条消息入队 | 已启动消息监听 | 短时间发送 3 条 Banner 消息 | 3 条消息进入队列 |
| QUEUE-02 | 每秒消费 1 条 | 队列中至少 3 条消息 | 观察弹出节奏 | 每约 1 秒展示 1 条 |
| QUEUE-03 | 队列空时停止定时器 | 消费完最后一条 | 等待队列清空 | 定时器停止，不再继续触发 |
| QUEUE-04 | 暂停时只入队不展示 | 当前在黑名单页面 | 连续发送 3 条消息 | 队列累计消息，但页面不弹出 |
| QUEUE-05 | 恢复后继续消费 | 已离开黑名单页面 | 返回普通页面 | 队列中的消息恢复逐条展示 |

### 5.6 展示方式测试

| 用例 ID | 测试项 | 前置条件 | 操作步骤 | 预期结果 |
| --- | --- | --- | --- | --- |
| UI-01 | `display=0` 红点模式 | 正常运行 | 下发 `display=0` 消息 | 不弹 UI，但会刷新消息列表并上报已展示 |
| UI-02 | `display=1` Banner | 正常运行 | 下发 `display=1` 消息 | 右上角展示 Banner |
| UI-03 | `display=2` Toast | 正常运行 | 下发 `display=2` 消息 | 展示文本 toast |
| UI-04 | `display=2` 但标题为空 | 正常运行 | 下发 `display=2,title=null` 消息 | 不展示 toast |
| UI-05 | `display=4` Modal | 正常运行 | 下发 `display=4` 消息 | 展示居中 Modal |
| UI-06 | 多条 Modal 轮播展示 | 直接调用 `showModal()` 传多条 | 观察弹窗 | 使用轮播方式切换展示 |

### 5.7 已展示上报测试

| 用例 ID | 测试项 | 前置条件 | 操作步骤 | 预期结果 |
| --- | --- | --- | --- | --- |
| REPORT-01 | 单条消息已展示上报 | `report=true` 且有 `uid` | 触发正常展示流程 | 调用已展示上报接口 |
| REPORT-02 | `report=false` 不上报 | 消息 `report=false` | 触发展示流程 | 不调用已展示上报接口 |
| REPORT-03 | 无 `uid` 不上报 | 消息 `uid=null` | 触发展示流程 | 不上报，流程继续 |

### 5.8 初始化消息协作测试

| 用例 ID | 测试项 | 前置条件 | 操作步骤 | 预期结果 |
| --- | --- | --- | --- | --- |
| INIT-01 | 初始化列表弹 Modal | 初始化接口返回 `display=4` 消息 | 启动应用 | Modal 立即弹出 |
| INIT-02 | 初始化列表普通消息入流 | 初始化接口返回普通消息 | 启动应用 | 普通消息经 `manualSetMessage()` 进入统一分发流程 |
| INIT-03 | 初始化列表刷新未读数 | 初始化接口返回未读数 | 启动应用 | 未读数同步更新 |

### 5.9 Banner 点击交互测试

| 用例 ID | 测试项 | 前置条件 | 操作步骤 | 预期结果 |
| --- | --- | --- | --- | --- |
| CLICK-01 | `displayOperate=null` 且有 jump | Banner 已展示 | 点击 Banner | 关闭 Banner 并直接跳转 |
| CLICK-02 | `displayOperate=null` 且无 jump | Banner 已展示 | 点击 Banner | 关闭 Banner 并弹默认 Modal |
| CLICK-03 | `displayOperate=1` 且有 jump | Banner 已展示 | 点击 Banner | 弹 Modal，且展示“去查看”按钮 |
| CLICK-04 | `displayOperate=1` 且无 jump | Banner 已展示 | 点击 Banner | 弹 Modal，仅展示确定按钮 |
| CLICK-05 | `displayOperate=2` 且有 jump | Banner 已展示 | 点击 Banner | 直接跳转页面 |
| CLICK-06 | `displayOperate=2` 且无 jump | Banner 已展示 | 点击 Banner | 仅关闭 Banner，不再弹窗 |
| CLICK-07 | `displayOperate=3` | Banner 已展示 | 点击 Banner | 仅关闭 Banner |
| CLICK-08 | 防重复点击 | Banner 已展示 | 快速连续点击两次 | 仅首次点击生效 |
| CLICK-09 | 引导中禁止点击 | `GuideManager.isGuiding=true` | 点击 Banner | 不执行跳转与弹窗 |

### 5.10 已读测试

| 用例 ID | 测试项 | 前置条件 | 操作步骤 | 预期结果 |
| --- | --- | --- | --- | --- |
| READ-01 | 用户端消息已读 | 用户端消息、未读 | 点击 Banner | 调用用户端读消息逻辑，消息设为已读 |
| READ-02 | 管理端消息已读 | 管理端消息、未读 | 点击 Banner | 调用管理端读消息逻辑，消息设为已读 |
| READ-03 | 已读消息不重复上报 | 消息 `read=1` | 点击 Banner | 不重复调用已读接口 |
| READ-04 | 无 uid 不上报已读 | 消息 `uid=null` | 点击 Banner | 不调用已读接口 |
| READ-05 | 管理端控制器未注册兜底 | 管理端消息且控制器未注册 | 点击 Banner | 直接调用 `AccountUtil.readMessage()` 兜底 |

### 5.11 页面回调测试

| 用例 ID | 测试项 | 前置条件 | 操作步骤 | 预期结果 |
| --- | --- | --- | --- | --- |
| BACK-01 | 跳转页面返回后回调 | 使用 `listenByCode(whereBackPage:true)` 监听 | 点击 Banner 跳转后返回 | 能收到 `isBackPage=true` 的消息回调 |
| BACK-02 | 默认不接收返回回调 | 使用 `whereBackPage=false` | 点击跳转再返回 | 不接收 `isBackPage=true` 消息 |
| BACK-03 | 返回结果透传 | 跳转页面有返回值 | 返回上一页 | `backPageResult` 可被业务侧拿到 |

### 5.12 按业务 code 监听测试

| 用例 ID | 测试项 | 前置条件 | 操作步骤 | 预期结果 |
| --- | --- | --- | --- | --- |
| CODE-01 | 首次消息 code 监听 | 页面订阅指定 code | 下发匹配 code 消息 | 业务回调触发 |
| CODE-02 | 非匹配 code 不触发 | 页面订阅指定 code | 下发其他 code 消息 | 业务回调不触发 |
| CODE-03 | 多 code 监听 | 页面订阅多个 code | 发送任一匹配消息 | 命中其中之一即可触发 |

### 5.13 黑名单页面测试

| 用例 ID | 测试项 | 前置条件 | 操作步骤 | 预期结果 |
| --- | --- | --- | --- | --- |
| ROUTE-01 | 进入做题页暂停消息 | 正常运行 | 进入黑名单路由 | `_isPaused=true`，停止消费 |
| ROUTE-02 | 黑名单页期间缓存消息 | 停留在黑名单页 | 下发多条消息 | 不弹窗，只缓存 |
| ROUTE-03 | 退出做题页恢复消息 | 队列中已有缓存消息 | 返回普通页 | 队列恢复逐条消费 |

### 5.14 ACTIVITY 模块测试

| 用例 ID | 测试项 | 前置条件 | 操作步骤 | 预期结果 |
| --- | --- | --- | --- | --- |
| ACT-01 | 非 ACTIVITY 不走特殊处理 | 普通模块消息 | 下发消息 | 不触发 `activityMessageProcessing()` |
| ACT-02 | 引导中只刷新远程任务 | `GuideManager.isGuiding=true` | 下发 ACTIVITY 消息 | 调用 `loadRemoteTasks()` 后返回 |
| ACT-03 | reward 分类弹奖励提示 | `module=ACTIVITY, category=reward` | 下发消息 | 弹奖励提示框 |
| ACT-04 | code 为空走 pushMethod | ACTIVITY 消息且 `code` 为空 | 下发消息 | 调用 `pushMethod()` |
| ACT-05 | code 有值刷新任务并启动 | 任务存在且未完成 | 下发 ACTIVITY 消息 | 调用 `loadRemoteTasks()` 与 `scheduleStartTask()` |
| ACT-06 | 任务不存在不报错 | 任务列表中无匹配 taskId | 下发 ACTIVITY 消息 | 不闪退，不启动任务 |
| ACT-07 | 特殊处理后仍正常入队 | ACTIVITY 消息 | 下发消息 | 同时继续走普通展示流程 |

## 6. 异常与边界测试

| 用例 ID | 测试项 | 前置条件 | 操作步骤 | 预期结果 |
| --- | --- | --- | --- | --- |
| EDGE-01 | 消息无 `display` | 正常运行 | 下发 `display=null` 消息 | 默认按 Banner 处理 |
| EDGE-02 | 消息无 `title` 且 `display=1` | 正常运行 | 下发 Banner 消息 | Banner 仍可展示，只是标题为空 |
| EDGE-03 | 消息无 `title` 且 `display=2` | 正常运行 | 下发 Toast 消息 | 不展示 toast |
| EDGE-04 | 消息无 `jump` | 正常运行 | 点击 Banner | 按 `displayOperate` 的无 jump 分支处理 |
| EDGE-05 | 消息无 `uid` | 正常运行 | 下发消息 | 可展示，但不上报已读与已展示 |
| EDGE-06 | 连接中重复断网 | 网络频繁波动 | 多次断连恢复 | 不应出现并发重连导致的异常状态 |

## 7. 手工联调脚本建议

### 7.1 单条消息冒烟顺序

建议先按以下顺序进行一次完整冒烟：

1. 启动应用并登录
2. 确认 MQTT 连接成功
3. 下发 `display=1` Banner 消息
4. 验证 Banner 是否展示
5. 点击 Banner，验证已读、跳转、返回回调
6. 下发相同 `uid` 消息，验证不会重复展示

### 7.2 多消息节流顺序

1. 连续下发 3 条 `display=1` 消息
2. 观察是否按 1 秒 1 条弹出
3. 进入黑名单页面
4. 再下发 2 条消息
5. 确认黑名单页面不弹
6. 返回普通页面，确认积压消息继续弹出

### 7.3 初始化消息联调顺序

1. 让初始化接口返回 1 条 Modal 和 2 条 Banner
2. 启动应用
3. 确认 Modal 直接展示
4. 确认两条 Banner 走统一消息队列逐条展示
5. 再通过 broker 推送其中一个相同 `uid` 的消息
6. 确认不会重复弹出

## 8. 自动化测试建议

当前目录更适合补充以下类型的自动化测试：

- 纯 Dart 单元测试：
  - `uid` 去重逻辑
  - `display/displayOperate` 分支逻辑
  - 黑名单暂停与恢复逻辑
  - 自动重连保护条件
- Widget 测试：
  - Banner 点击行为
  - Modal 按钮显隐
  - 多条 Modal 的轮播展示

不建议优先做的自动化测试：

- 直接依赖真实 broker 的脆弱集成测试
- 强依赖动画时序的全量 UI 自动化

## 9. 缺陷排查建议

### 9.1 收不到消息

优先检查：

1. 是否真正连接成功
2. 是否订阅了正确 topic
3. 服务端消息是否投递到当前用户 topic
4. 消息是否被当成 retained 或重复 uid 过滤

### 9.2 收到但不展示

优先检查：

1. 当前页面是否在黑名单内
2. `display` 是否为 `0`
3. `display=2` 时 `title` 是否为空
4. 队列是否已有消息尚未消费完成

### 9.3 点击后无动作

优先检查：

1. `displayOperate` 是否为 `3`
2. `jump` 是否为空
3. 是否正在新手引导中
4. 是否已经点击过一次导致按钮防抖

## 10. 回归清单

每次调整 MQTT 或通知逻辑后，至少回归以下项目：

- 登录后能正常建连
- Banner、Toast、Modal 三种展示均正常
- 相同 `uid` 不重复展示
- 黑名单页面暂停与恢复正常
- 点击 Banner 后已读、跳转、返回回调正常
- 初始化列表与 MQTT 实时消息不冲突
- 手动断开后不会自动重连

