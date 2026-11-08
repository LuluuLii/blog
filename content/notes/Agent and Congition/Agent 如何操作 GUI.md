---
date: 2025-12-22
draft: true
---
## 推理和决策层

- 有些是用图像推理和坐标识别两个模型分别调用，图像推理根据意图和图像，推理出需要的动作（元素和图像特征），坐标识别模型给出坐标 --- 【为什么要用两个模型？】

## 控制层和通信层

### 浏览器自动化

- 基于 CDP 协议、Input 事件执行
- 模型自行决定是鼠标 + 坐标位置执行，还是直接操作 DOM 执行
	- 下发不同的 command type 和参数区分
- 通过 Playwright 基于 CDP 连接 （playwright 也是封装了 CDP）
- 大模型进行工具调用，由 CDPTranslator 转译为 CDP 指令实现浏览器操作
- 云端 CDP 接口？
- 通信：浏览器和服务器之间通过 Websocket 通信

### playwright, Chrome DevTools 原理
- Blink's WebInputEvent: WebInputEvent 是 Chrome Blick 渲染引擎中用于表示用户输入事件的核心类型系统，WebInputEvent 是所有输入事件的基类，用于封装从浏览器进程传递到渲染进程的用户交互事件
- Chromium UI translates platform events (like macOS NSEvent) into Blink's WebInputEvent model before forwarding them to renderers.
	- 但 OpenAI 的 AI 浏览器 Atlas 基于安全需要，没有通过 browser process 分发指令，而是直接建立 WebView --> RenderFrameHost 的直连通道，跳过 browser process 和 NSEvent, 直接发 WebInputEvent 到 Renderer 【直达 render 具体是指？怎么做到的？】
		- but since OWL runs Chromium in a hidden process, we do that translation ourselves within the Swift client library and forward already-translated events down to Chromium
		- agent-generated events are routed directly to the renderer, never through the privileged browser layer
### Navigation



## 案例
各种方案适合的任务和实际例子
- 按任务类型和复杂度分
- 按环境分
	- Browser
		- [Browser Use - The AI browser agent](https://browser-use.com)
	- mobile
		- Apple Intelligence Agents 
	- desktop
		- cua https://github.com/trycua/cua?tab=readme-ov-file
	- 通用
		-  https://arxiv.org/abs/2307.13854 CogAgent, desktop&Browser
		- https://generalagents.com/ace/  Ace
		- OpenAI operator
		- Claude Computer Use 
			- https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/computer-use-tool 
			- https://www.oneusefulthing.org/p/when-you-give-a-claude-a-mouse 
		- UI-TARS
			- [GitHub - bytedance/UI-TARS](https://github.com/bytedance/UI-TARS)
			- https://github.com/bytedance/UI-TARS-desktop?tab=readme-ov-file#agent-tars
			- blog https://agent-tars.com/blog/2025-06-25-introducing-agent-tars-beta.html#context-engineering 
			- [基于 UI-TARS 的 Computer Use 实现](https://zhuanlan.zhihu.com/p/1916192180260807991)

## 实践中遇到的问题
- 准确率的问题
- 资源消耗 
- context engineering


##  Reading List
-  gui agents 列表 https://github.com/supernalintelligence/Awesome-Gui-Agents 
- papers https://github.com/OSU-NLP-Group/GUI-Agents-Paper-List