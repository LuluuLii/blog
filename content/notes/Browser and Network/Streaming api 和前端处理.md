---
draft: true
---
## streaming data
从底层原理说起

buffer
## 通信 network

## 渲染
### 从 markdown 特殊标签的渲染说起

###  json 渲染
Vercel AI SDK 的 `streamObject` 和 `useObject` Hook 暴露的 `partialObjectStream` 正是这样做的：每个产出的对象都是截至目前的 Schema 形状状态，后续字段会在到达时填充
- Dan（react核心作者）[Progressive JSON — overreacted](https://overreacted.io/progressive-json/) 
- **容错的流式 JSON 解析器**（如 `partial-json`、`best-effort-json-parser` 这类库），它能解析"不完整的 JSON"——收到 `{"title": "你好` 就返回 `{title: "你好"}`（把未闭合的当当前值），每来一块重新解析
- 服务端二次处理 + 占位协议