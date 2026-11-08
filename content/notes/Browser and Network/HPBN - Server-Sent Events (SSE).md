---
date: 2026-02-24
---
> Part of [[High performance browser networking]] - Browser APIs and Protocols

SSE introduces two components to enable efficient sever-to-client streaming of text-based event data
- EventSource interface in the browser: allows the client to receive push notifications from the server as DOM events
- 「event stream」data format: is used to deliver the individual updates

## 和 HTTP 的关系

##  Event Stream Protocol 
- Event payload is the value of one or more adjacent `data` fields
- Event may carry an optional `ID` and an `event` type string. 一条完整的 event 字段可以有 id, event, data, retry 等
	- 多个 `data:` 行会被**拼接**（用 `\n` 连),最后作为一条消息的完整 data。
	- `retry:` 告诉浏览器断线后隔多久重连
	- **注释行**以 `:` 开头(如 `: keep-alive`),常用来做心跳保活,防止代理掐断空闲连接。
- Event boundaries are marked by newlines.
	- **单个 `\n` 只是分隔一行字段**； **一个「空行」（连续两个 `\n`,即 `\n\n`）标志一条 event 结束、触发派发。**
- all event source dabuta is UTF-8 encoded: SSE is not meant as a mechanism for transferring binary payloads. If necessary, one could base64 encode an arbitrary binary object to make it SSE friendly, but doing so would incur high (33%) byte overhead
	- SSE 是文本协议（UTF-8），是不是比二进制协议更浪费带宽？--- 不会
		- An SSE connection is a streaming HTTP response, which means that it can be compressed (i.e., gziped)
		- SSE 是高度重复的文本流，gzip 对这种重复字符串压缩率非常高，压缩后体积往往接近甚至优于二进制
		- gzip 是流式压缩。
- ![[Screenshot 2026-02-23 at 12.44.33.png|435]]
-  SSE provides built-in support for reestablishing dropped connections, as well as recovery of messages the client may have missed while disconnected. By default, if the connection is dropped, then the browser will automatically reestablish the connection. The SSE specification recommends a 2–3 second delay, but the server can also set a custom interval at any point by sending a `retry` command to the client. Similarly, the server can also associate an arbitrary ID string with each message. The browser automatically remembers the last seen ID and will automatically append a "Last-Event-ID" HTTP header with the remembered value when issuing a reconnect request.
	- ![[Screenshot 2026-02-23 at 12.52.59.png|574]]

## EventSource API
	- ![[Screenshot 2026-02-23 at 02.54.22.png|633]]
	-  SSE provides a memory-efficient implementation of XHR streaming. Unlike a raw XHR connection, which buffers the full received response until the connection is dropped, an SSE connection can discard processed messages without accumulating all of them in memory.
	- EventSource interface also provides auto-reconnect and tracking of the last seen message: if the connection is dropped, EventSource will automatically reconnect to the server and optionally advertise the ID of the last seen message, such that the stream can be resumed and lost messages can be retransmitted.
- limitations
	- it is server-to-client only and hence does not address the request streaming use case—e.g., streaming a large upload to the server
	- the event-stream protocol is specifically designed to transfer UTF-8 data: binary streaming, while possible, is inefficient.

## 接收和解析
- EventSource vs fetch + ReadableStream：目前通常协议层用 SSE，但获取用 fetch + ReadableStream 而不是 eventSource
	- GET 问题
		- EventSource 只能发 GET,不能自定义请求体和大部分 Header。
		- LLM 请求要 **POST** 一个大 body(messages 数组、system prompt、tools 定义,动辄几 KB 几十 KB)。EventSource 只支持 GET,**没法带请求体**。如果发 GET，prompt 塞进 URL query 会有长度超限 + 敏感内容暴露在 URL/日志里的问题,不可行。
	- Header 问题：EventSource 只能靠 Cookie 带鉴权,没法加 `Authorization: Bearer xxx` 这类自定义 header。很多 API 鉴权方式它支持不了。
	- 重连问题
		- EventSource 断线自动重连是**写死的行为**,没法精细控制退避策略。LLM 生成是**有状态、不可重放**的——一次生成到一半断了,自动重连会**重新发起整个请求**,模型从头再生成一遍(浪费 token、结果还可能不一致)。需要的是**自己掌控**「断了要不要续、怎么续」,而不是它替你无脑重连
		- LLM 会话需要**完全掌控读流、解析、重连、取消**(`AbortController` 随时中断生成)，**代价**:SSE 的解析要**自己实现**(攒 buffer、按 `\n\n` 切 event、处理半包)
- 为什么 chrome devTools 有时候捕捉不到 event streams 的日志详情数据？
- 解析 SSE 流样例代码
	- **`buffer` 攒包 + `events.pop()` 留半包**：为什么最后一段不处理?因为 TCP 不保证一个 chunk 正好是一条完整 event,最后一段可能被截断,留到下一轮拼上。**漏了这个 = 生产环境偶发解析错乱。**
	- **`decoder.decode(value, { stream: true })`**：为什么加 `stream: true`?因为一个 UTF-8 多字节字符(如中文)可能被拆在两个 chunk 里,`stream: true` 让 decoder 记住半个字符、下轮拼上。**漏了这个 = 中文偶发乱码。**
	- **`AbortController`**：用户点「停止生成」,靠它中断 fetch。

## 应用场景和传输协议选型
为什么 chatbot 的场景，一般用 SSE 而不是 websocket，SSE的优势在哪里
- SSE 跑在纯 HTTP 上，WebSocket 要协议升级
	- 工程红利：可以复用 HTTP 基建中的现有鉴权、日志、限流等基建（所有 HTTP 基建（网关、CDN、日志、鉴权中间件、负载均衡）都是**围绕 HTTP 语义工作的**。WebSocket 升级后没有 HTTP 语义了，这些基建**看不懂**帧里在传什么，只能把它当成「一条不透明的 TCP 长连接」放行或掐断。）

## 工程难点
