---
date: 2026-02-24
---

> Part of [[High performance browser networking]] - Browser APIs and Protocols

### Server-Sent Events(SSE)
- SSE introduces two components to enable efficient sever-to-client streaming of text-based event data
	- EventSource interface in the browser: allows the client to receive push notifications from the server as DOM events
	- 「event stream」data format: is used to deliver the individual updates
- Event Stream Protocol
	- Event payload is the value of one or more adjacent `data` fields
	- Event may carry an optional `ID` and an `event` type string.
	- Event boundaries are marked by newlines.
	- all event source data is UTF-8 encoded: SSE is not meant as a mechanism for transferring binary payloads. If necessary, one could base64 encode an arbitrary binary object to make it SSE friendly, but doing so would incur high (33%) byte overhead
		- SSE 是文本协议（UTF-8），是不是比二进制协议更浪费带宽？--- 不会
			- An SSE connection is a streaming HTTP response, which means that it can be compressed (i.e., gziped)
			- SSE 是高度重复的文本流，gzip 对这种重复字符串压缩率非常高，压缩后体积往往接近甚至优于二进制
			- gzip 是流式压缩。
	- ![[Screenshot 2026-02-23 at 12.44.33.png]]
	-  SSE provides built-in support for reestablishing dropped connections, as well as recovery of messages the client may have missed while disconnected. By default, if the connection is dropped, then the browser will automatically reestablish the connection. The SSE specification recommends a 2–3 second delay,but the server can also set a custom interval at any point by sending a `retry` command to the client. Similarly, the server can also associate an arbitrary ID string with each message. The browser automatically remembers the last seen ID and will automatically append a "Last-Event-ID" HTTP header with the remembered value when issuing a reconnect request.
	- ![[Screenshot 2026-02-23 at 12.52.59.png]]
- EventSource API
	- ![[Screenshot 2026-02-23 at 02.54.22.png]]
	-  SSE provides a memory-efficient implementation of XHR streaming. Unlike a raw XHR connection, which buffers the full received response until the connection is dropped, an SSE connection can discard processed messages without accumulating all of them in memory.
	- EventSource interface also provides auto-reconnect and tracking of the last seen message: if the connection is dropped, EventSource will automatically reconnect to the server and optionally advertise the ID of the last seen message, such that the stream can be resumed and lost messages can be retransmitted.
- limitations
	- it is server-to-client only and hence does not address the request streaming use case—e.g., streaming a large upload to the server
	- the event-stream protocol is specifically designed to transfer UTF-8 data: binary streaming, while possible, is inefficient.
- SSE 和 Fetch streaming
	- 协议层用 SSE，但获取用 fetch 而不是 eventSource
- 为什么 chrome devTools 有时候捕捉不到 event streams 的日志详情数据？
