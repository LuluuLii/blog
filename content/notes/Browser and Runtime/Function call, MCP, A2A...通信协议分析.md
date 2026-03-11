---
date: 2025-12-09
---


LLMs 与工具之间、多 agent 间的通信原理和实践
上下文共享
解决 LLMs 应用中的问题：提供 context，提供执行任务的 tool，模型本身的能力
### Hard code 阶段
if...else... 硬编码判断本次模型的对话需要哪些工具，然后再去调用对应的工具
分支逻辑不易维护和书写
### Function call
让模型预先知道，你有哪些工具，然后再自己判断是否需要调用和需要调用什么，输出符合这个工具的要求
即在模型调用接口的入参中，传递 tools 参数
```js
const params = {
	model: 'DeepSeek-R1-0528',
	messages: [
		{role: 'user', content: '查询上海的天气'}
	],
	tool_choice: 'auto',
	tools: [
		{
			type: 'function',
			function: {
				name: 'getWeather',
				description: '获取指定地方的天气',
				parameters: {
					type: 'object',
					properties: {
					 //...
					}
				}
			}
		}
	]
}
```
如果模型判断调用工具，它会根据工具的说明来输出工具调用的参数
```json
{
	"index": 0,
	"message": {
		"content": "xxxx",
		"role": "assistant",
		"tool_calls": [{
			"id": "xxxx",
			"type": "function",
			"function": {
				"name": "getWeather",
				"arguments": "{xxx}" // json string
			}
		}]
	}
}

```
工程链路调用函数，进行后续操作
### MCP
![[Screenshot 2025-12-08 at 23.59.16.png]]

#### 协议 JSON-RPC 2.0
定义了请求、响应、通知和错误的 JSON 结构，但不规定具体的传输层（可以用 HTTP、WebSocket、stdio、SSE、streamable HTTP 等）。因为支持双向、通知与批处理，很自然用于模型 ↔ 工具 的交互。
- Request 示例
```json
{
  "jsonrpc": "2.0",
  "method": "get_weather",
  "params": { "city": "Tokyo", "units": "C" },
  "id": "req-42"
}

```
- Response 示例 如果发生错误，返回一个 `error` 对象而不是 `result`
```json
{
  "jsonrpc": "2.0",
  "result": { "temp": 16, "condition": "Cloudy" },
  "id": "req-42"
}

```
- Notification  通知是没有 `id` 的请求，表示“发起方不需要响应”。结构与请求类似，但没有 `id`：
```json
{
  "jsonrpc": "2.0",
  "method": "log_event",
  "params": { "msg": "user clicked" }
}

```
- Error
```json
{
  "jsonrpc": "2.0",
  "error": {
    "code": -32601,
    "message": "Method not found"
  },
  "id": "req-42"
}

```
- Batch JSON-RPC 支持把多个请求/notification 放在一个数组里一次发送（批处理），服务端会分别返回多个响应（按请求有 id 的那些）。批处理在高并发或想减少握手次数时很有用，但要注意部分成功、部分失败的情况处理。
```json
[
  { "jsonrpc": "2.0", "method": "m1", "id": 1 },
  { "jsonrpc": "2.0", "method": "m2", "id": 2 }
]

```
- 与 REST / gRPC 的对比
	- **REST**：面向资源（HTTP verbs + URLs），不是严格的 RPC；通常是单向请求-响应，不天然支持双向流（需要 WebSocket）。
	- **gRPC**：二进制（Protocol Buffers），高性能、强类型、IDL 支持、多种流式模式。相比 JSON-RPC 更高效，但部署复杂、跨语言需要 proto 支持。
	- **JSON-RPC**：介于二者之间，轻量、文本、易实现、但无固有类型定义（可配合 JSON Schema）。
#### 传输机制
- [详解 MCP 传输机制](https://m.aitntnews.com/newDetail.html?newId=13081#:~:text=MCP%20传输机制（Transport）是,JSON%2DRPC%20来编码消息%E3%80%82)
MCP 协议目前定义了三种传输机制用于客户端-服务器通信：
- **stdio（stdin/stdout）**：通过标准输入和标准输出进行通信
	- 常用于本地进程互联（例如编辑器插件、语言服务器协议 LSP 的思想类似）。
	-  优点：实现简单、低延迟；缺点：不自然支持网络跨主机。
- SSE：通过 HTTP 进行通信，支持流式传输。（协议版本 2024-11-05 开始支持，即将废弃）
- Streamble HTTP：通过 HTTP 进行通信，支持流式传输。（协议版本 2025-03-26 开始支持，用于替代 SSE）
MCP 协议的传输机制是可插拔的，也就是说，客户端和服务器不局限于 MCP 协议标准定义的这几种传输机制，也可以通过自定义的传输机制来实现通信。

refer
- [mcp学习 \| 李乾坤的博客](https://qiankunli.github.io/2025/04/06/mcp.html)
- [基于 MCP 的 AI Agent 应用开发实践](https://zhuanlan.zhihu.com/p/32750183539) 
	- MCP 协议要求用 JSON Schema 约束工具的入参、出参，可以使用 zod   [GitHub - colinhacks/zod: TypeScript-first schema validation with static type inference](https://github.com/colinhacks/zod?tab=readme-ov-file)

### Agent Client Protocol (ACP)


### A2A
[Agent2Agent (A2A) 协议发布 - Google Developers Blog](https://developers.googleblog.com/zh-hans/a2a-a-new-era-of-agent-interoperability/)

### Agent
- [Introducing Agent TARS Beta - Agent TARS](https://agent-tars.com/blog/2025-06-25-introducing-agent-tars-beta.html#context-engineering)
- [分布式Agent与A2A \| 李乾坤的博客](https://qiankunli.github.io/2025/04/20/a2a.html)
- [Agent与软件开发 \| 李乾坤的博客](https://qiankunli.github.io/2025/07/20/agent_software.html)

一些 mcp sever 示例
- [GitHub - BeehiveInnovations/zen-mcp-server: The power of Claude Code + \[Gemini / OpenAI / Grok / OpenRouter / Ollama / Custom Model / All Of The Above\] working as one.](https://github.com/BeehiveInnovations/zen-mcp-server)
- [@agent-infra/mcp-server-browser - npm](https://www.npmjs.com/package/@agent-infra/mcp-server-browser)
