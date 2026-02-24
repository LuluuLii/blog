---
date: 2026-02-24
---


[High Performance Browser Networking (O'Reilly)](https://hpbn.co/#toc)

### Networking 101

### Browser APIs and Protocols

#### Primer on Browser Networking
[Browser APIs and Protocols: Primer on Browser Networking - High Performance Browser Networking (O'Reilly)](https://hpbn.co/primer-on-browser-networking/)
[ChatGPT - 浏览器 Socket 管理](https://chatgpt.com/share/699ad503-a4d0-8007-845c-72e936cd52b7)
![[Screenshot 2026-02-22 at 17.32.46.png]]
- Web applications running in the browser do not manage the lifecycle of individual network sockets. In fact, the browser intentionally separates the _request management_ lifecycle from _socket management_.
- Sockets are organized in pools, which are grouped by origin, and each pool enforces its own connection limits and security constraints. Pending requests are queued, prioritized, and then bound to individual sockets in the pool. Consequently, unless the server intentionally closes the connection, the same socket can be automatically reused across multiple requests
	- Socket 按 origin 分池，每池限制最大连接数（通常 6），请求进入队列
	- 浏览器调度绑定 socket
	- socket 自动复用（keep-alive）
	- JS 无法干预
	- 如果服务器保持 keep-alive：同一 socket 可以复用，性能更好，RTT 成本更低
	- ![[Screenshot 2026-02-22 at 17.48.03.png]]
- Automatic socket pooling automates TCP connection reuse, which offers significant performance benefits
- Chromium net stack  [ChatGPT - 浏览器 Socket 管理](https://chatgpt.com/share/699ad503-a4d0-8007-845c-72e936cd52b7)
	- 逻辑上可以抽象为
```
Renderer Process (JS / Blink) [构造 `ResourceRequest`]
        ↓ IPC (Mojo)
Network Service (核心类 URLRequest / URLLoader ) [负责接收请求， 应用 CSP / CORB / CORS 检查]
        ↓
HttpStreamFactory [socket 调度核心， 根据 origin 获取或创建 HttpStream，查找已有可复用连接，如果没有，向 socket pool 申请新连接，如果达到上限 → 请求排队]
        ↓
ClientSocketPool [Chromium 的 socket 池实现]
        ↓
TransportSocket (TCP / TLS / QUIC)
        ↓
OS Socket API
```
	-  JS 不在同一个进程里直接操作 socket  ,它通过 IPC 调用 Network Service
	- Chromium 还会：
		- DNS prefetch
		- TCP preconnect
		- TLS warmup
- Resource and client state caching
	-  Prior to dispatching a request, the browser automatically checks its resource cache, performs the necessary validation checks, and returns a local copy of the resources if the specified constraints are satisfied.
		- cache 的具体机制 [HTTP: Optimizing Application Delivery - High Performance Browser Networking (O'Reilly)](https://hpbn.co/optimizing-application-delivery/#cache-resources-on-the-client)
			- Chromium 中，缓存位于 Network Service 层
			- Cache Key = (URL + Method + Vary headers)
			- 缓存内容：响应 body, response headers, 元信息(时间戳、ETag、Age、max-age 等)
			- 缓存判定流程
				- 检查缓存是否存在：URL 匹配，HTTP method = GET, Vary 规则匹配
				- cache-control: max-age -- 小于则直接返回缓存 -- 强缓存（Fresh cache hit）
				- 过期 -- 协商缓存 revalidation -- conditional request
					- 浏览器会发送：If-None-Match: "etag_value"  ；If-Modified-Since: timestamp
					- 服务器返回：304 Not Modified → 复用本地 body；200 OK → 更新缓存
			- cache-control 指令
				- max-age
				- public/private (public 允许浏览器和 CDN 缓存，private 则只允许浏览器缓存)
				- no-cache: 每次都向服务器验证(走 revalidation)
				- no-store: 完全不允许缓存 e.g. 支付页面
				- immutable: 在 max-age 内，浏览器不进行 revalidate 
			- etag: 通常是 文件hash / 版本号/内容签名，用于 revalidation 时服务器比对
			- last-modified: 可能存在精度低和时间不同步问题，现代推荐 ETag
			- 在 Chrome DevTools：
				- 看 Size 列：disk cache, memory cache, 304
				- 看 response headers
				- 看 Age
			- CDN 可以覆盖 origin 的 Cache-Control
			- ![[Screenshot 2026-02-22 at 22.18.03.png]]
			- 常见缓存策略
				- ![[Screenshot 2026-02-22 at 22.18.28.png]]
	-  authentication, session, and cookie management
		- The browser maintains separate "cookie jars" for each origin, provides necessary application and server APIs to read and write new cookie, session, and authentication data and automatically appends and processes appropriate HTTP headers to automate the entire process
- Application APIs and Protocols
	- Every nontrivial application will require a mix of different transports based on a variety of requirements: interaction with the browser cache, protocol overhead, message latency, reliability, type of data transfer, and more
	- Some protocols may offer low-latency delivery (e.g., Server-Sent Events, WebSocket), but may not meet other critical criteria, such as the ability to leverage the browser cache or support efficient binary transfers in all cases.
	- ![[Screenshot 2026-02-22 at 18.25.14.png]]
#### XMLHttpRequest(XHR)
- XMLHttpRequest (XHR) is a browser-level API that enables the client to script data transfers via JavaScript.
- Prior to XHR, the web page had to be refreshed to send or fetch any state updates between the client and server. With XHR, this workflow could be done asynchronously and under full control of the application JavaScript code.
- XHR is an application API provided by the browser, the browser automatically takes care of all the low-level connection management, catching, redirects, protocol negotiation, formatting of HTTP requests, authentication and much more.
- Cross-Origin Resource Sharing (CORS)
	- The browser will refuse to override any of the unsafe headers, which guarantees that the application cannot impersonate a fake user-agent, user, or the origin from where the request is being made.
	- same-origin policy
		- An "origin" is defined as a triple of application protocol, domain name, and port number—e.g., (http, example.com, 80)
	- CORS provides a secure opt-in mechanism for client-side cross-origin requests
	- The opt-in authentication mechanism for the CORS request is handled at a lower layer: 
		- when the request is made, the browser automatically appends the protected _Origin_ HTTP header, which advertises the origin from where the request is being made.  浏览器会自动在请求中加 _Origin_
		- In turn, the remote server is then able to examine the _Origin_ header and decide if it should allow the request by returning an _Access-Control-Allow-Origin_ header in its response. 
		- Alternatively, if it wanted to disallow access, it could simply omit the _Access-Control-Allow-Origin_ header, and the client’s browser would automatically fail the sent request. 如果服务器不返回这个 header，浏览器直接拦截响应（JS 拿不到数据）（网络请求其实已经成功，只是浏览器阻止 JS 读取结果）
	- additional security precautions
		- CORS requests omit user credentials such as cookies and HTTP authentication. 跨域请求默认不会携带 Cookie, HTTP Authentication, Client certificates
		- The client is limited to issuing "simple cross-origin requests" -- 不触发预检 (preflight)的请求：
			- methods 仅限于：GET, POST, HEAD
			- Content-Type 仅限： application/x-www-form-urlencoded, multipart/form-data, text/plain
			- 只能使用安全 header： access to HTTP headers that can be sent and read by the XHR.
		- Simple request 下：To enable cookies and HTTP authentication, the client must set an extra property (`withCredentials`) on the XHR object when making the request, and the server must also respond with an appropriate header (_Access-Control-Allow-Credentials_) to indicate that it is knowingly allowing the application to include private user data (此时 Access-Control-Allow-Origin 不能是 \*)
	- 预检请求 preflight request
		- 如果使用 PUT / DELETE， 或使用 application/json，或添加自定义 header（如 Authorization），浏览器会先自动发一个 preflight request to ask for permission
			- once a preflight request is made, it can be cached by the client to avoid the same verification on each request.
		- 服务器允许，浏览器才会发真正的 PUT 请求
```
// preflight request
OPTIONS /resource
Origin: https://app.example.com
Access-Control-Request-Method: PUT
Access-Control-Request-Headers: Authorization

// 服务器返回
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: GET, POST, PUT
Access-Control-Allow-Headers: Authorization
Access-Control-Allow-Credentials: true
```
- Downloading Data with XHR
	-  the browser offers automatic encoding and decoding for a variety of native data types:
		- ArrayBuffer: Fixed-length binary data buffer
		- Blob: Binary large object of immutable data
		- Document: Parsed HTML or XML document
		- JSON: JavaScript object representing a simple data structure
		- Text
	- Either the browser can rely on the HTTP content-type negotiation to infer the appropriate data type (e.g., decode an _application/json_ response into a JSON object), or the application can explicitly override the data type when initiating the XHR request
		- ![[Screenshot 2026-02-22 at 23.13.44.png]]
	- 浏览器自动编解码发生请求发送前（Request serialization）和响应返回后（Response deserialization）
		- HTTP 传输的永远是字节序列（byte sequence），HTTP body 是字节
		- 响应解码
			- 浏览器会根据 Content-Encoding （gzip 解压）和 Content-Type 进行解码（例如 Content-Type: image/png 时不会解码，json/text 会 UTF-8 → JavaScript 字符串）
			- 调用的 API 决定如何解析，例如调用  res.json():  Text （内部 byte stream）→ JSON.parse → JS Object， res.blob(): byte stream → Blob
		- 请求编码
			- 例如发送 JSON 时，手动做了JSON.stringify(data)， JS Object → JSON string，浏览器自动：string → UTF-8 bytes
		- 在 Chromium 中：
			- 网络层负责解压，Blink 负责字符解码， Fetch API 决定如何暴露数据，JS 引擎负责 JSON.parse
- Uploading data with XHR
	- The XHR _send()_ method accepts one of `DOMString`, `Document`, `FormData`, `Blob`, `File`, or `ArrayBuffer` objects, automatically performs the appropriate encoding, sets the appropriate HTTP content-type, and dispatches the request.
		- ![[Screenshot 2026-02-22 at 23.28.25.png]]
	- send a binary blob or upload a file provided by the user: grab a reference to the object and pass it to XHR. can also split a large file into smaller chunks
		- ![[Screenshot 2026-02-22 at 23.13.44 1.png]]
- Streaming data with XHR
	- today there is no simple, efficient, cross-browser API for XHR streaming:
		- The _send_ method expects the full payload in case of uploads.
		- The _response_, _responseText_, and _responseXML_ attributes are not designed for streaming.
- XHR vs Fetch api
	- ![[Screenshot 2026-02-22 at 23.33.16.png]]
	- fetch 进行上传 & 更容易并发控制 & 更容易 abort
		- ![[Screenshot 2026-02-22 at 23.51.07.png]]
```
// 用 blob slice
for (let start = 0; start < SIZE; start += BYTES_PER_CHUNK) {
  const end = Math.min(start + BYTES_PER_CHUNK, SIZE);

  await fetch('/upload', {
    method: 'POST',
    headers: {
      'Content-Range': `${start}-${end}/${SIZE}`
    },
    body: blob.slice(start, end)
  });
}

// fetch 实现上传可以做真正的流式上传
const stream = new ReadableStream({
  start(controller) {
    controller.enqueue(chunk);
    controller.close();
  }
});

await fetch('/upload', {
  method: 'POST',
  body: stream,
  headers: { 'Content-Type': 'application/octet-stream' }
});

```
- Real-Time Notifications and Delivery
	- HTTP does not provide any way for the server to initiate a new connection to the client. As a result, to receive real-time notifications, the client must either poll the server for updates or leverage a streaming transport to allow the server to push new notifications as they become available.
	- 由于 XHR 原生不支持 streaming，因此主要用 poll
		- Each XHR request is a standalone HTTP request, and on average, HTTP incurs ~800 bytes of overhead (without HTTP cookies) for request/response headers.
		- polling is a good fit for applications where polling intervals are long, new events are arriving at a predictable rate, and the transferred payloads are large. This combination offsets the extra HTTP overhead and minimizes message delivery delays.(polling 适合: 轮询间隔长;事件到达速率可预测;单次传输 payload 较大)
			- 由于每次请求都有 固定协议开销（protocol overhead），那么 HTTP 头部 + TLS 握手成本巨大；服务器压力大；大量空响应（没数据）
			- 数据越大，HTTP overhead 越不重要
			- 开销比例小；延迟 ≈ T/2 可接受 -- Polling 是合理的。
	- Long-Polling with XHR
		- server holds the connection open until an update is available -- Comet
		- 现在已经不常用了，用 sse / web socket 等替代
		- ![[Screenshot 2026-02-23 at 00.27.12.png]]
	- fetch streaming
#### Server-Sent Events(SSE)
- SSE introduces two components to enable efficient sever-to-client streaming of text-based event data
	- EventSource interface in the browser: allows the client to receive push notifications from the server as DOM events
	- 「event stream」data format: is used to deliver the individual updates
- Event Stream Protocol
	- Event payload is the value of one or more adjacent `data` fields
	- Event may carry an optional `ID` and an `event` type string.
	- Event boundaries are marked by newlines.
	- all event source data is UTF-8 encoded: SSE is not meant as a mechanism for transferring binary payloads. If necessary, one could base64 encode an arbitrary binary object to make it SSE friendly, but doing so would incur high (33%) byte overhead
		- SSE 是文本协议（UTF-8），是不是比二进制协议更浪费带宽？--- 不会
			- An SSE connection is a streaming HTTP response, which means that it can be compressed (i.e., gziped)
			- SSE 是高度重复的文本流，gzip 对这种重复字符串压缩率非常高，压缩后体积往往接近甚至优于二进制
			- gzip 是流式压缩。
	- ![[Screenshot 2026-02-23 at 12.44.33.png]]
	-  SSE provides built-in support for reestablishing dropped connections, as well as recovery of messages the client may have missed while disconnected. By default, if the connection is dropped, then the browser will automatically reestablish the connection. The SSE specification recommends a 2–3 second delay,but the server can also set a custom interval at any point by sending a `retry` command to the client. Similarly, the server can also associate an arbitrary ID string with each message. The browser automatically remembers the last seen ID and will automatically append a "Last-Event-ID" HTTP header with the remembered value when issuing a reconnect request.
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
#### WebSocket
- [Browser APIs and Protocols: WebSocket - High Performance Browser Networking (O'Reilly)](https://hpbn.co/websocket/#ws-and-wss-url-schemes)
- [ChatGPT - WebSocket 协议解析](https://chatgpt.com/share/699c84b1-5c18-8007-b52f-c00dced07ccd)
- WebSocket enables bidirectional, message-oriented streaming of text and binary data between client and server. It is the closest API to a raw network socket in the browser. The browser abstracts all the complexity behind a simple API and provides a number of additional services:
	- Connection negotiation and same-origin policy enforcement
    - Interoperability with existing HTTP infrastructure
    - Message-oriented communication and efficient message framing
    - Subprotocol negotiation and extensibility
- WebSocket 很灵活，但 The application must account for missing state management, compression, caching, and other services otherwise provided by the browser.
- WebSocket API
	- ![[Screenshot 2026-02-23 at 18.50.54.png]]
	- ws & wss URL schema
		- _ws_ for plain-text communication (e.g., _ws://example.com/socket_), and _wss_ when an encrypted channel (TCP+TLS) is required
		- the WebSocket wire protocol can be used outside the browser and could be negotiated via a non-HTTP exchange. As a result, the HyBi Working Group chose to adopt a custom URL scheme.
	- Receiving Text and Binary Data
		- the WebSocket protocol makes no assumptions and places no constraints on the application payload: both text and binary data are fair game
		- Internally, the protocol tracks only two pieces of information about the message:1. the length of payload as a variable-length field，2. the type of payload to distinguish UTF-8 from binary transfers.
		- When a new message is received by the browser, it is automatically converted to a DOMString object for text-based data, or a Blob object for binary data, and then passed directly to the application.
			- you can also tell the browser to convert the received binary data to an ArrayBuffer instead of Blob
			- User agents can use this as a hint for how to handle incoming binary data: if the attribute is set to "blob", it is safe to spool it to disk, and if it is set to "arraybuffer", it is likely more efficient to keep the data in memory.
			- A Blob object represents a file-like object of immutable, raw data. If you do not need to modify the data and do not need to slice it into smaller chunks, then it is the optimal format. On the other hand, if you need to perform additional processing on the binary data, then ArrayBuffer is likely the better fit.
	- Sending Text and Binary Data
		- The WebSocket API accepts a DOMString object, which is encoded as UTF-8 on the wire, or one of ArrayBuffer, ArrayBufferView, or Blob objects for binary transfers.
		- on the wire, a WebSocket frame is either marked as binary or text via a single bit
			- WebSocket 帧结构里有一个 opcode 字段：`0x1` → text，`0x2` → binary 也就是说：协议只区分「文本」和「非文本」两类数据。
			- WebSocket 是传输层协议，不是应用层协议，它不会做内容协商、类型标记、编码说明，如果需要这些 → 应用层自己实现（自己设计 payload 结构）
		- All WebSocket messages are delivered in the exact order in which they are queued by the client. As a result, a large backlog of queued messages, or even a single large message, will delay delivery of messages queued behind it—head-of-line blocking
			- WebSocket 建立在 TCP 之上，WebSocket 也必须按客户端 enqueue 顺序发送。
				- WebSocket 是单连接，单通道，严格顺序，不像 HTTP/2 或 HTTP/3支持多 stream、可并行、有流优先级，因此WebSocket 天然存在 Head-of-Line Blocking，需要应用层实现流控与调度策略
			- Head-of-Line Blocking：队头的大消息阻塞后面小消息的发送
			- bufferedAmount 是已经排队但尚未发送到网络的字节数，如果不控制客户端会无限 enqueue，TCP 发送队列会爆炸，内存膨胀，所以需要检查要 previous messages drained（应用层 backpressure 控制机制）
			- 缓解队头阻塞的方法
				- 拆分大消息
				- 监控 bufferedAmount（模拟 TCP 之上的 second-level backpressure）
				- 实现优先级队列
- 什么是 framing：字节如何划分为消息
	- WebSocket 和 HTTP framing 机制的区别
- WebSocket Protocol
- 为什么 ai streaming 返回一般用 sse 而不是 WebSocket
- WebSocket 使用场景
	- 实时协作
	- IM 消息
	- IDE
	- agent 持续执行任务

#### WebRTC
