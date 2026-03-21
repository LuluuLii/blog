---
date: 2026-02-24
---
> Part of [[High performance browser networking]] - Browser APIs and Protocols
>  [Browser APIs and Protocols: WebSocket - High Performance Browser Networking (O'Reilly)](https://hpbn.co/websocket/#ws-and-wss-url-schemes)
   [ChatGPT - WebSocket 协议解析](https://chatgpt.com/share/699c84b1-5c18-8007-b52f-c00dced07ccd)


WebSocket enables bidirectional, message-oriented streaming of text and binary data between client and server. It is the closest API to a raw network socket in the browser. The browser abstracts all the complexity behind a simple API and provides a number of additional services:
- Connection negotiation and same-origin policy enforcement
- Interoperability with existing HTTP infrastructure
- Message-oriented communication and efficient message framing
- Subprotocol negotiation and extensibility

WebSocket 很灵活，但 The application must account for missing state management, compression, caching, and other services otherwise provided by the browser.
### WebSocket API
- ![[Screenshot 2026-02-23 at 18.50.54.png|494]]

- `ws://` 这个 scheme 对浏览器来说本质上是一个指令："先用 HTTP 握手，然后升级成 WebSocket"。client 先发一个普通的 HTTP/1.1 请求，带上 `Upgrade: websocket` header，server 返回 101 Switching Protocols，然后**同一条 TCP 连接**就从 HTTP 协议"切换"成了 WebSocket 协议。之后所有的 WebSocket frame 都跑在这条 TCP 连接上。
	- 如果用的是 `wss://`（加密），那就是 TCP + TLS，跟 HTTPS 的传输层完全一样。
	- 在应用代码里看不到这个 HTTP 请求，因为浏览器的 WebSocket API 把整个握手过程封装掉了。但如果你用 Chrome DevTools 的 Network 面板看一个 WebSocket 连接，你会在 Headers 里看到完整的 HTTP upgrade 请求和 101 响应——这就是那个"隐藏的" HTTP 请求。
- WebSocket 的协议栈是：**TCP → (TLS) → WebSocket framing → 应用消息**。它在 TCP 的字节流之上加了一层 framing（frame header 里有 opcode、length、FIN bit、mask 等），把字节流"切"成一条条有边界的消息。这也意味着 WebSocket 继承了 TCP 的所有特性：可靠传输、有序到达、拥塞控制，同时也继承了 TCP 的局限——比如 head-of-line blocking（一个 packet 丢了，后面的都得等）。这也是为什么 HTTP/3 选了 QUIC（基于 UDP）而不是继续用 TCP，但 WebSocket 目前还没有一个广泛使用的基于 QUIC 的替代方案。
#### ws & wss URL schema
- _ws_ for plain-text communication (e.g., _ws://example.com/socket_), and _wss_ when an encrypted channel (TCP+TLS) is required
- the WebSocket wire protocol can be used outside the browser and could be negotiated via a non-HTTP exchange. As a result, the HyBi Working Group chose to adopt a custom URL scheme.
#### Receiving Text and Binary Data
- the WebSocket protocol makes no assumptions and places no constraints on the application payload: both text and binary data are fair game
- Internally, the protocol tracks only two pieces of information about the message:1. the length of payload as a variable-length field，2. the type of payload to distinguish UTF-8 from binary transfers.
- When a new message is received by the browser, it is automatically converted to a DOMString object for text-based data, or a Blob object for binary data, and then passed directly to the application.
	- you can also tell the browser to convert the received binary data to an ArrayBuffer instead of Blob
	- User agents can use this as a hint for how to handle incoming binary data: if the attribute is set to "blob", it is safe to spool it to disk, and if it is set to "arraybuffer", it is likely more efficient to keep the data in memory.
	- A Blob object represents a file-like object of immutable, raw data. If you do not need to modify the data and do not need to slice it into smaller chunks, then it is the optimal format. On the other hand, if you need to perform additional processing on the binary data, then ArrayBuffer is likely the better fit.
####  Sending Text and Binary Data
The WebSocket API accepts a DOMString object, which is encoded as UTF-8 on the wire, or one of ArrayBuffer, ArrayBufferView, or Blob objects for binary transfers.
- on the wire, a WebSocket frame is either marked as binary or text via a single bit
	- WebSocket 帧结构里有一个 opcode 字段：`0x1` → text，`0x2` → binary 也就是说：协议只区分「文本」和「非文本」两类数据。
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
#### Subprotocol Negotiation
解决的核心问题： 在连接建立的瞬间，如何以零额外开销的方式，让 client 和 server 就"我们接下来怎么交流"达成共识"。 WebSocket protocol makes no assumptions about the format of each message. WebSocket 的设计哲学是极简传输层，只关心把消息从 A 送到 B，消息本身是什么格式、怎么解读，协议完全不管。导致有两方面的问题需要解决：

1. 消息格式（serialization）WebSocket 消息不像 HTTP 那样有 headers 来携带 metadata（content-type, encoding 等），所以 client 和 server 必须自己约定怎么编码消息。这个问题的解法是纯应用层的——约定 JSON、protobuf、自定义 header 等。
	- unlike HTTP or XHR requests, which communicate additional metadata via HTTP headers of each request and response, there is no such equivalent mechanism for a WebSocket message. As a result, if additional metadata about the message is required, then the client and server must agree to implement their own subprotocol to communicate this data
2. 协议版本对齐（protocol agreement）--  需要解决协议版本和server 同时服务多种不同用途的 client（聊天、通知、streaming）的问题
	- WebSocket provides a simple and convenient _subprotocol negotiation_ API
	- 机制非常简洁，嵌入在 WebSocket 的 HTTP upgrade handshake 中：
		- **Client 端**：在握手时通过 `Sec-WebSocket-Protocol` header 发送自己支持的协议列表（有优先级顺序）。如果 server 选了一个，连接建立成功，`ws.protocol` 里能读到选中的值。如果 server 一个都不支持，握手直接失败，连接不会建立。
		- 关键点在于：这个协商发生在连接建立**之前**（作为 HTTP upgrade 的一部分），所以不会浪费已建立连接的资源，也不需要额外的消息交换。
		- `Sec-WebSocket-Protocol` 的值对 WebSocket 协议本身**没有任何影响**——它不会改变 framing、不会改变编码、不会改变任何底层行为。它纯粹是一个 **label**，让 client 和 server 在连接建立时达成一个"我们都认同的标签"，然后各自的应用代码根据这个标签来决定后续行为。
### WebSocket Protocol

Websocke protocol 主要由两部分组成：
- the opening HTTP handshake used to negotiate the parameters of the connection
- a binary message framing mechanism to allow for low overhead, message-based delivery of both text and binary data.

#### Binary Framing layer
先理解什么是 framing 和 message-oriented
- framing 机制定义字节如何划分为消息
- Message-oriented 和 stream-oriented
	- TCP 是 **stream-oriented** 的。它提供的抽象是一个连续的字节流。所以用 TCP 的应用层协议（比如 HTTP/1.1）都需要自己想办法标记消息边界——HTTP 用 `Content-Length` 或 `Transfer-Encoding: chunked` 来告诉接收方"到这里就是一条完整消息了"。
	- WebSocket 是 **message-oriented** 的。它在 TCP 之上加了一层 framing protocol，帮你维护了消息边界。底层实现上，WebSocket 用 frame header 里的 length 字段和 FIN bit 来标记每条消息的边界。一条大消息可能被拆成多个 frame 传输（fragmentation），但这对应用层是透明的——`onmessage` 只在整条消息的所有 frame 都到达后才触发。
- WebSocket 有两个层次的概念：**frame** 是传输单位，**message** 是应用层单位。一条 message 可以由一个或多个 frame 组成。应用代码只看到 message（`onmessage` 触发时拿到完整消息），frame 级别的拆分和重组对应用完全透明。
	- frame: The smallest unit of communication, each containing a variable-length frame header and a payload that may carry all or part of the application message.
	- Message: A complete sequence of frames that map to a logical application message.
	- 分片（fragmentation）允许发送方一边生成数据一边发送，接收方逐个 frame 收集，直到收到 FIN=1 的 frame 才把整条消息交给应用层。
	- 应用层代码 ↔ WebSocket 库（framing 层 e.g. Chromium 的网络栈, nodejs 的 ws）↔ TCP socket，应用层不需要关注 framing
- WebSocket frame 的结构图:
	- ![[Screenshot 2026-03-15 at 23.36.03.png|540]]
		- FIN: 标识是否是最后一个 fragment
		- Opcode（4 bits）：关键字段，告诉接收方这个 frame 是什么类型。
		- MASK（1 bit）+ Masking Key（32 bits）：安全机制。规范要求 client → server 方向的所有 frame 必须 mask，server → client 不需要。原因是为了防止恶意 client 构造特定的字节序列来"欺骗"中间的 HTTP 代理缓存——mask 让 payload 的 wire format 不可预测，代理就无法错误地缓存 WebSocket 流量。
			- 假设 client 和 server 之间有一个 HTTP 代理。这个代理不认识 WebSocket 协议，它看到的就是一坨字节流。如果没有 mask，恶意 client 可以精心构造 WebSocket payload 的内容，让它的字节序列看起来像一个合法的 HTTP response（比如伪造一个 `HTTP/1.1 200 OK` + 恶意 body）。不懂 WebSocket 的代理可能会把这段字节流错误地当成 HTTP response 缓存下来，之后其他用户请求同一个 URL 时就会拿到被投毒的缓存。
			- 怎么 mask： XOR 操作。Client 每发一个 frame，随机生成一个 4 字节（32 bit）的 masking key。masking key 是每个 frame 随机生成的。攻击者虽然控制了 payload 的明文内容，但不知道这次的 key 是什么（由浏览器随机生成），所以无法预测 wire 上实际传输的字节序列长什么样，也就无法构造出让代理误认为是 HTTP response 的字节模式。
			- 所以 mask 的本质是：用随机 key 打乱 wire format，让中间代理无法把 WebSocket 流量误解为 HTTP 流量。
		- Payload Length（7 bits + 可变扩展）：这是 framing 设计中最巧妙的部分——一个三级可变长度编码。小消息（≤125 字节）只需要 7 bits 就够了，零额外开销；中等消息用 2 字节扩展（最大 64KB）；大消息用 8 字节扩展（最大 2^63）。这样设计让最常见的小消息（比如 JSON 聊天消息）的 header 开销最小化
		-
### 使用场景讨论
- 为什么 ai streaming 返回一般用 sse 而不是 WebSocket
- WebSocket 使用场景
	- 实时协作
	- IM 消息
	- IDE
	- agent 持续执行任务
