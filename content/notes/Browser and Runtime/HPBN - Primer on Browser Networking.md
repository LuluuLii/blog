---
date: 2026-02-24
---

> Part of [[High performance browser networking]] - Browser APIs and Protocols

[Browser APIs and Protocols: Primer on Browser Networking - High Performance Browser Networking (O'Reilly)](https://hpbn.co/primer-on-browser-networking/)
[ChatGPT - 浏览器 Socket 管理](https://chatgpt.com/share/699ad503-a4d0-8007-845c-72e936cd52b7)
![[Screenshot 2026-02-22 at 17.32.46.png]]
- Web applications running in the browser do not manage the lifecycle of individual network sockets. In fact, the browser intentionally separates the _request management_ lifecycle from _socket management_.
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
Renderer Process (JS / Blink) [构造 `ResourceRequest`]
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
	-  Prior to dispatching a request, the browser automatically checks its resource cache, performs the necessary validation checks, and returns a local copy of the resources if the specified constraints are satisfied.
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
	-  authentication, session, and cookie management
		- The browser maintains separate "cookie jars" for each origin, provides necessary application and server APIs to read and write new cookie, session, and authentication data and automatically appends and processes appropriate HTTP headers to automate the entire process
- Application APIs and Protocols
	- Every nontrivial application will require a mix of different transports based on a variety of requirements: interaction with the browser cache, protocol overhead, message latency, reliability, type of data transfer, and more
	- Some protocols may offer low-latency delivery (e.g., Server-Sent Events, WebSocket), but may not meet other critical criteria, such as the ability to leverage the browser cache or support efficient binary transfers in all cases.
	- ![[Screenshot 2026-02-22 at 18.25.14.png]]
