# user_style_activation_dialog 提示词

请基于 `lib/app/modules/user_center/common/user_style_activation_dialog.dart` 实现和整理视觉风格订阅弹窗逻辑，目标是让 `UserStyleShowSubscribeWidget` 成为正式可用的统一订阅弹窗，同时保持老弹窗的核心支付逻辑与接口行为一致。

## 目标

以 `UserStyleActivationPayDialog` 的业务逻辑为准，重构/补全 `UserStyleShowSubscribeWidget`，满足以下需求：

1. 未订阅的风格支持订阅。
2. 已订阅的图片或视频支持取消订阅。
3. 图片和视频是分开订阅的；如果已订阅图片，切换到视频时视为新订阅，不走取消逻辑。
4. 视频订阅包含图片权益；只要视频权益仍有效，模式区只显示视频。

## 入口要求

1. 优先使用 `UserStyleActivationDialog.showSubscribe(...)` 作为弹窗入口。
2. `subscriptionPay(...)` 先保留兼容，但应视为待废弃入口。
3. 当前 `UserStyleShowSubscribeWidget` 已改为单风格入参模式，构造参数以当前代码为准：
   - `resource`
   - `data`
4. `showSubscribe(...)` 如果仍保留旧参数形态，后续实现时需要在入口层完成旧参数到 `data` 的映射，不要把 `styles`、`styleCode` 的查找散落到弹窗内部 UI 方法中。
5. 本次实现中不再支持重试订阅流程，`isRetry` 不作为 UI 状态来源，不展示与重试相关的按钮、文案、字段或分支。

## 必须复用的老逻辑

以下逻辑必须与老弹窗保持一致，不能改接口语义：

1. 普通订阅信息拉取：
   - `getPayInfo()`
   - 使用 `AccountUtil.getVisualStylePayInfo`
2. 普通订阅支付：
   - `confirmPayment()`
   - 使用 `AccountUtil.teamStylePay`
3. 充值跳转：
   - `toRecharge()`
   - 保持原有充值成功后的刷新逻辑

以下老逻辑本次明确不接入新弹窗：

1. `getRetryPayInfo()`
2. `confirmPaymentRetry()`
3. 所有批量重试订阅相关展示和交互

## 新增逻辑

### 1. 取消订阅

`UserStyleShowSubscribeWidget` 中已有取消订阅方法：

- `Future<void> unsubscribe(BuildContext context) async`
- `Widget _buildButtonsCleanWidget()`

该方法已包含以下规则，后续实现时必须沿用：

1. 当 `resource == ResourceTypeEnum.image` 时：
   - 如果 `widget.data.imageForbidUnsubscribed == true`，提示“当前风格为默认订阅”，不可取消。
2. 当 `resource == ResourceTypeEnum.video` 时：
   - 如果 `widget.data.videoForbidUnsubscribed == true`，提示“当前风格为默认订阅”，不可取消。
3. 二次确认文案：
   - “服务将持续至下个账单日(${widget.billingDate ?? ''})，届时将不再扣费。您确定要取消订阅吗？”
   - 使用 `DeleteDialog.show(...)`
4. 真正取消接口：
   - `AccountUtil.teamStyleUnsubscribe`
   - 请求体保持 `{"imageStyleUses": [widget.data.style]}`
5. 成功后：
   - 提示“取消成功”
   - `Get.back(result: true)`

取消订阅按钮必须以 `_buildButtonsCleanWidget()` 为唯一 UI 入口来承载，不要在其他按钮区重复拼接“取消订阅”按钮。

`_buildButtonsCleanWidget()` 的职责要求：

1. 只展示一个按钮：
   - 文案：`取消订阅`
2. 点击后调用 `unsubscribe(...)`
3. 当前风格数据统一从 `widget.data` 读取，不再额外传 `TeamStyleEntityStyleItems data`
4. 样式保持当前文件里 `_buildButtonsCleanWidget()` 的设计，不再额外新增第二个取消按钮样式

### 2. 已订阅时的底部按钮规则

如果当前展示的是“已订阅的资源模式”，底部只显示一个主按钮：

- 文案：`取消订阅`

此时不显示：

- `确认订阅`
- `确认支付`
- `去充值`

点击后直接走 `unsubscribe(...)`。

### 3. 新订阅时的底部按钮规则

如果当前资源模式是未订阅状态：

1. 若余额足够：
   - 主按钮显示 `确认订阅`
2. 若余额不足：
   - 主按钮显示 `去充值`
3. 普通场景走 `confirmPayment()`

### 4. 图片 / 视频分开订阅

资源模式切换必须按“当前模式独立订阅状态”判断按钮行为：

1. 图片未订阅，视频未订阅：
   - 模式区显示：`图片`、`视频`
2. 只订阅图片：
   - 模式区显示：`图片`、`视频`
   - 图片可取消订阅
   - 视频可新订阅
3. 只要视频权益有效：
   - 视为视频包含图片权益
   - 模式区只显示：`视频`
4. 已订阅图片，切到视频：
   - 视为新订阅
   - 底部按钮不能显示“取消订阅”
   - 应显示订阅/支付相关按钮
5. 不能把“取消续费”误判为“订阅已失效”

### 5. `unsubscribed` 语义

`TeamStyleEntityStyleItems.unsubscribed == true` 表示：

1. 已取消续费
2. 不代表当前订阅已经失效
3. 订阅是否仍有效，仍然要以 `imageRights == 1` / `videoRights == 1` 判断
4. 后续实现时，必须把“是否有效订阅”和“是否取消续费”拆开判断，不能混用一个布尔值表达两层含义

## 状态判断要求

后续实现时请显式梳理至少以下状态：

1. 普通订阅
2. 当前模式是否有有效权益
3. 当前模式是否已取消续费
4. 当前模式是否允许取消订阅
5. 当前模式是否余额充足
6. 当前模式列表是否需要隐藏图片模式

建议把“当前模式是否已订阅”提炼成独立判断方法，避免在按钮区、模式区、价格区重复写条件分支。

## UI 实现要求

`UserStyleShowSubscribeWidget` 现阶段有较多静态占位内容，后续实现时需要全部动态化，不允许保留演示数据：

1. 标题已经改为 `订阅风格·${localText?.text ?? ''}`，后续保持该动态标题方案，不要回退为写死文案
2. 风格封面区已按当前模式读取：
   - 图片模式：`widget.data.image?.imageUrl`
   - 视频模式：`widget.data.video?.firstFrameUrl`
   后续实现要继续沿用这个方向，不要再退回空字符串占位图
3. 风格名应继续从 `widget.data.styleTitle` + `LearningLangUtils.getLocalLang(...)` 获取
4. 模式描述文案应继续区分：
   - 图片：`仅图片`
   - 视频：`图片+视频`
5. 模式卡片中的价格、支付信息卡片中的周期/费用/余额、说明文案目前仍有静态占位，后续必须改成实际数据渲染
6. 切换图片 / 视频模式时，必须重新刷新订阅信息或价格信息，不能只本地切换 UI
7. UI 上不能出现任何“重试订阅”“批量重试”相关字段、按钮、价格说明或状态标识
8. 底部按钮区保留两套结构：
   - `_buildButtonsSubWidget()`：未订阅态
   - `_buildButtonsCleanWidget()`：已订阅态
9. 支付信息卡片中的价格明细按老弹窗语义展示：
   - 第一行显示 `总需学点`
   - 当 `alreadyPaidCredits > 0` 时，额外显示 `已支付学点`
   - 当 `alreadyPaidCredits > 0` 时，额外显示 `实际支付学点`
   - 增加 `下个账单日期`
10. `requiredCredits / alreadyPaidCredits / diffCredits / billingDate` 的转换和展示收口在 `_buildPayInfoWidget()` 内部处理，不要把这组支付明细计算提到最外层 getter 或其他分散位置
11. 模式区显示规则必须和权益语义保持一致：
   - `videoRights == 1` 时，只显示视频模式
   - `videoRights != 1` 时，显示图片和视频模式
12. `unsubscribed == true` 时，表示“已取消续费”，不是“未订阅”

## 代码组织要求

1. 优先复用 `UserStyleActivationPayDialog` 的现有方法和数据组织方式。
2. 如果逻辑迁移到 `UserStyleShowSubscribeWidget`，请把公共逻辑收口，减少两套弹窗各自维护。
3. 避免把“订阅 / 取消 / 充值”逻辑直接堆在 `build` 方法中。
4. 使用早返回和拆方法控制复杂度。
5. 保持现有 UI 风格、命名风格、GetX 用法和 `ScreenUtil` 尺寸写法。

## 验收标准

实现完成后，至少满足以下验收结果：

1. 未订阅风格打开弹窗，可以正常订阅。
2. 已订阅图片模式打开弹窗，图片模式下底部只显示“取消订阅”。
3. 已订阅图片模式切到视频模式时，如果视频未订阅，底部应切换为“确认订阅/去充值”，而不是“取消订阅”。
4. 只要 `videoRights == 1`，模式区只显示视频，不再显示图片模式。
5. 不可取消订阅的默认风格点击取消时，仅提示，不发起取消接口。
6. 取消订阅成功后，弹窗返回 `true`。
7. 取消订阅按钮由 `_buildButtonsCleanWidget()` 承载，并正确传入当前风格数据。
8. 充值完成后，弹窗数据会自动刷新。
9. 当已存在历史支付金额时，支付信息卡片会正确展示“总需学点 / 已支付学点 / 实际支付学点”。
10. 支付信息卡片会展示“下个账单日期”，并与老弹窗语义保持一致。
11. `unsubscribed == true` 时，仍按有效权益判断模式显示，不会把它误判为订阅已失效。

## 参考位置

1. 老支付弹窗：
   - `UserStyleActivationPayDialog`
2. 新弹窗：
   - `UserStyleShowSubscribeWidget`
3. 取消订阅方法：
   - `unsubscribe(BuildContext context)`
4. 取消订阅按钮：
   - `_buildButtonsCleanWidget()`

## 非目标

本次不要改动接口协议字段名，不要擅自修改后端请求结构，不要删除老入口的兼容能力，不要把重试订阅逻辑继续带入新弹窗。
