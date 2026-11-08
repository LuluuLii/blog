---
date: 2025-12-09
---
LLMs 与工具之间、多 agent 间的通信原理和实践
上下文共享
解决 LLMs 应用中的问题：提供 context，提供执行任务的 tool，模型本身的能力

## 在没有 MCP 之前

### 回到大模型时代前的通信协议

restful web api 与 http
spi 与 rpc
stdio
进程间通信 
双向通信


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
## MCP 
mcp主要解决两个问题：
1. 怎么调用 -- **M×N 问题**：没有 MCP 时，**M 个 agent 应用 × N 个外部服务 = M×N 份适配代码**。你为 Claude 写的 GitHub 接入，换到别的 agent 上要重写一遍；GitHub 官方想支持所有 agent，得为每家写一份。没有 MCP 时，接入 GitHub 要自己写 tool schema、写请求发送、写结果组装。MCP 消除的正是这层重复封装。有了 MCP，变成 **M+N**：每个 agent 实现一次 MCP client，每个服务实现一次 MCP server，任意组合都能通。
2. 怎么发现（集合站、社区、生态）：**MCP client 连上 server 后会问它"你有哪些工具"，server 返回工具列表和 schema。**这意味着工具是运行时动态发现的，不是硬编码进 agent 的。** tool definitions 本来就是标准格式，但**谁来提供这些 definitions、怎么拿到它们**，正是 MCP 补上的。

![[Screenshot 2025-12-08 at 23.59.16.png|809]]

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
- **stdio（stdin/stdout）**：通过标准输入和标准输出进行通信，是进程间通信的方式
	- **本地** server：访问本地文件、本地数据库、本地命令。天然继承用户权限，无需网络和鉴权。常用于本地进程互联（例如编辑器插件、语言服务器协议 LSP 的思想类似）。
	-  优点：实现简单、低延迟；缺点：不自然支持网络跨主机。
	- MCP client **把 server 作为一个子进程启动**（比如 `node my-server.js`），然后：
		- client 把请求写进这个子进程的 **stdin**
		- server 把响应写到自己的 **stdout**
		- client 从子进程的 stdout 读回来
	- 所以 stdio 模式的 server **绝不能往 stdout 打印日志**——会污染协议消息，日志要走 stderr。这是写 MCP server 最经典的坑。
- **远程** server：托管在别处、多用户共享、需要鉴权
	- SSE：通过 HTTP 进行通信，支持流式传输。（协议版本 2024-11-05 开始支持，即将废弃）
	- Streamble HTTP：通过 HTTP 进行通信，支持流式传输。（协议版本 2025-03-26 开始支持，用于替代 SSE）
	- 原来的 SSE 方案需要维持两个端点（一个 SSE 长连接收消息、一个 POST 发消息），比较笨重；Streamable HTTP 统一成单端点，可按需升级为流式。
MCP 协议的传输机制是可插拔的，也就是说，客户端和服务器不局限于 MCP 协议标准定义的这几种传输机制，也可以通过自定义的传输机制来实现通信。

refer
- [mcp学习 \| 李乾坤的博客](https://qiankunli.github.io/2025/04/06/mcp.html)
- [基于 MCP 的 AI Agent 应用开发实践](https://zhuanlan.zhihu.com/p/32750183539) 
	- MCP 协议要求用 JSON Schema 约束工具的入参、出参，可以使用 zod   [GitHub - colinhacks/zod: TypeScript-first schema validation with static type inference](https://github.com/colinhacks/zod?tab=readme-ov-file)

### MCP spec 结构
- resources:只读的数据（文件、DB 记录、API 返回）
- tools: 可执行的动作（有副作用）
- prompts: 预定义的提示模板/工作流，用户显式触发（如斜杠命令）
- sampling
resources 和 prompts 需要 client 端做额外的 UI/交互支持（怎么让用户选 resource、怎么暴露 prompt 为斜杠命令），所以生态事实上 tools 用的比较多

## 其他 以及现在 MCP 落伍了吗
### Agent Client Protocol (ACP)


### A2A
[Agent2Agent (A2A) 协议发布 - Google Developers Blog](https://developers.googleblog.com/zh-hans/a2a-a-new-era-of-agent-interoperability/)

### Skill

### 从 MCP 到 CLI(bash) 
- **2026 年 1 月**：OpenClaw 的作者 Peter Steinberger 在 X 上说——**"mcp were a mistake. bash is better."** 然后他做了 mcporter
	- mcporter： 把 MCP server 转成 CLI 的工具
- Vercel CEO Guillermo Rauch  **"CLIs are the de-facto MCPs for agents"**
- mcp 的问题：
	- 曾经模型还是不可靠的工具使用者，现在模型变得非常擅长使用工具，但 mcp 描述工具的方式带来的成本依旧还在
	- 一个典型的 MCP server 不只暴露你需要的工具——它把**整个 schema 倾倒进 agent 的 context**：工具定义、参数描述、认证流程、状态管理，全套。叠几个 MCP server——企业 agent 可能同时需要 GitHub、数据库连接器、Microsoft Graph、Jira——**光工具定义就轻松超过 15 万 tokens**。 
		- claude code现在支持了 defer load，缓解了一部分这个问题
			-  MCP 工具定义现在默认是延迟的，通过 tool search 按需加载，所以在 Claude 真正需要某个具体工具之前，只有工具名消耗 context。具体机制：**Claude Code 只加载工具名、通过 tool search 延迟 schema**。不再发送全部 147 个工具 schema，而是只发 **~25 个内置工具定义 + 一个 ToolSearch 工具**。**触发条件是自动的**：**如果 MCP 工具超过 context 的 10%，Tool Search 会自动激活**，只按需加载需要的工具。
			- 当 `ANTHROPIC_BASE_URL` 指向非官方主机时，MCP tool search 默认被禁用；如果你的代理转发 `tool_reference` 块，需要设 `ENABLE_TOOL_SEARCH=true`。用第三方代理的人容易踩这个——以为有延迟加载，其实没生效
	- **规模上来后维护成本明显——server 分散、各自部署、开关管理麻烦**，而且工具定义会持续占 context。
- CLI 的优势
	- 相比之下，模型本来就认识 `gh`、git、docker 等命令。零 schema token 消耗。CLI 的"schema"早就在模型权重里了，不需要每次请求再传一遍。
		- cli 自带文档(--help) 而且是可执行的，且这份说明只在需要时进入 context 一次。
		- MCP 的 JSON schema 是为**确定性程序**设计的（程序需要精确的类型才能校验和调用）。但 LLM 不是程序，它读散文比读 JSON 更自然、更省 token。
	- CLI 在 token 成本（便宜 4-32 倍）、可靠性（100% vs 72%）、可组合性上胜出；MCP 在安全、多用户鉴权、企业治理上胜出。
- CLI的短板
	- cli的成本
		- **输出要模型自己解析**：CLI 返回的是文本，格式各家不同；MCP 返回结构化 JSON，一致好解析。（所以很多 CLI 支持 `--json` 就是在补这个）
		- - **`--help` 也要花 token**，而且有些工具的 help 极长（几千行），未必比 schema 省
		- **模型可能记错参数**：没有 schema 校验兜底，传错参数只能等执行报错才发现（回到你学的"错误回灌"）
	- 大约 60% 的企业 SaaS 工具——Salesforce、Figma、Notion、Stripe——没有 CLI。 agent 会瞎编命令、用一个下个 API 版本就失效的未文档化 curl 端点、或者卡在重试循环里
	- 鉴权和审计问题：**CLI 用的是预配置的共享凭据。** 在多租户产品里，**每个用户的 agent 都以同一个 AWS 身份行事**——用户 A 可能无意中触发影响用户 B 数据的操作。而且**没有 per-user 的审计轨迹**：HIPAA、PCI-DSS、SOC 2 都要求"谁在什么时候做了什么"，裸 CLI 回答不了这个问题。
- mcporter、mcpc、mcp-cli
	- 保留 MCP 的鉴权/治理能力，但用 CLI 的方式暴露给模型
	- **mcpc 是一个"翻译层 + 门面"**：它自己是个 MCP client（完整支持 tools/resources/prompts/sampling），但**对 agent 暴露的界面是 CLI**
	- mcporter 可以把任意 mcp server 包装成 cli，例如 `npx mcporter generate-cli "npx -y chrome-devtools-mcp" --compile`
		- 原理：`generate-cli` 把任意 MCP server 定义**变成一个可直接运行的 CLI**，可选打包/编译成**自包含的 bun 二进制**。


## 参考
- [Introducing Agent TARS Beta - Agent TARS](https://agent-tars.com/blog/2025-06-25-introducing-agent-tars-beta.html#context-engineering)
- [分布式Agent与A2A \| 李乾坤的博客](https://qiankunli.github.io/2025/04/20/a2a.html)
- [Agent与软件开发 \| 李乾坤的博客](https://qiankunli.github.io/2025/07/20/agent_software.html)
一些 mcp sever 示例
- - [GitHub - BeehiveInnovations/zen-mcp-server: The power of Claude Code + \[Gemini / OpenAI / Grok / OpenRouter / Ollama / Custom Model / All Of The Above\] working as one.](https://github.com/BeehiveInnovations/zen-mcp-server)
- [@agent-infra/mcp-server-browser - npm](https://www.npmjs.com/package/@agent-infra/mcp-server-browser)