## 目标与验收

- 抽离短语结构预览公共组件，统一详情页与词法页的结构块渲染。
- 输入支持 `CardPhraseStructureItem` 列表这类数据：

```json
{
  "uid": 917,
  "phrasePos": "VERB",
  "items": [
    { "uid": 1864, "roleNid": "head", "tokenPosition": 1, "text": "take" },
    { "uid": 1865, "roleNid": "particle", "tokenPosition": 2, "text": "off" }
  ]
}
```

## 改动点

- 新增 `phrase_structure_preview_widget.dart`
- 详情页结构区改为复用该组件
- 词法页“短语结构”卡片改为复用该组件

## 关键设计

- 组件内部保留原详情页的测量、缩放与角色颜色映射逻辑
- 角色标题、背景色、边框色仍通过颜色配置解析，避免两处样式漂移
- 通过可选参数保留字号、间距、圆角等扩展点

## 兼容性与注意事项

- 当前公共组件依赖 `ConfigController` 中的 `phraseItemRoles` 配置
- 若调用方处于无宽度约束场景，组件会按自然宽度渲染；有宽度约束时会自动缩放适配

## TODO

- 后续如果“短语结构列表页”也需要同样的预览样式，可以直接接入该组件
