# 目标与验收口径

- 本轮只接写作阶梯编辑页，不扩展蓝图、范文、任务页。
- 编辑页从写作阶梯首页卡片的“编辑”按钮进入。
- 页面结构和 React 编辑页保持同一信息层次：左侧封面与蓝图信息，右侧基础信息、规则配置、拍位配置、里程碑、底部取消/保存。
- 进入编辑页后需要回显 `stage/detail` 数据；保存时走 `stage/edit` 全量提交。

# 改动范围

- `zhenxie_composition_stages` 模块内新增编辑页 binding、controller、view。
- 补充同模块 model 的 detail 字段。
- 补充编辑页路由注册与首页“编辑”按钮跳转。
- 复用已有 `milestone/list`、`beat/list`、`stage/detail`、`stage/edit` 请求封装。

# 非目标

- 不接蓝图页、范文页、任务页真实跳转。
- 不做封面编辑。
- 不补权限、埋点、草稿、复杂校验。
- 不顺手调整首页地图/列表已有 UI。

# 关键设计

- 编辑页继续放在 `zhenxie_composition_stages` 模块内，减少目录扩散和路由改动范围。
- controller 保留显式原始字段：详情数据、里程碑词表、四拍词表、输入框 controller；派生展示通过方法输出。
- 保存前仅做 React 当前已有的几条关键校验：双语名称与说明必填、难度上下限、作答最少最多。
- 文首/文末只在蓝图 frame 开启时展示；未开启时提交固定为 `hidden`。

# 兼容性影响与注意事项

- 左侧 family 文案当前接口没有直接返回可展示名称，因此这轮不额外造映射，不显示该行。
- 保存成功后直接返回列表页，保持与 React 当前交互一致。
- 统计区只读展示 `learnedCount` 和 `taskCount`，不参与编辑。

# TODO

- 如果后续补了 composition family 词表，可把左侧 family 信息补齐。
- 蓝图/范文/任务按钮接真实链路时，优先沿用当前 stage / blueprint 字段，不额外包装。
