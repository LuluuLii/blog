---
date: 2026-02-24
---


如何动态/实时生成和渲染 UI 

--
Instead of an agent using an interface on behalf of the user, the LM can change the UI to meet the needs of the moment. This can be done with Tools which control UI (MCP UI [MCP-UI](https://mcpui.dev/)), or specialized UI messaging systems which can sync client state with an agent (AG UI [AG-UI Overview - Agent User Interaction Protocol](https://docs.ag-ui.com/introduction)), and even generation of bespoke interfaces (A2UI [GitHub - google/A2UI](https://github.com/google/A2UI)).

--
Agent 解决方案的前端交互模式
- LUI + GUI
	- 不只返回文字，而是动态渲染可交互的组件
- 流式响应 Streaming 的体验设计
- 如何处理中断、重试和 human-in-the-loop
- 多模态输入与输出
	- 图片、语音、视频的上传和 streaming 的原理及前端处理流程
	- Markdown 与代码块、自定义组件的渲染细节
