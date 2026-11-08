有天偶然刷到 pi agent 作者的这个视频 [Youtube | I Hated Every Coding Agent, So I Built My Own — Mario Zechner (Pi)](https://www.youtube.com/watch?v=Dli5slNaJu0) ，想到在 debug openclaw 过程中经常看到 pi 的身影
[What I learned building an opinionated and minimal coding agent](https://mariozechner.at/posts/2025-11-30-pi-coding-agent/)
[Pi: The Minimal Agent Within OpenClaw \| Armin Ronacher's Thoughts and Writings](https://lucumr.pocoo.org/2026/1/31/pi/)


基于最简的 core 和最少的 tools 来扩展 --- 方便尝试多种路径，而不是被一个范式限制住，现在 agent 还没有收敛出最佳模式，还需要不断去尝试和组合，这个成本要尽量低

从它的仓库组成里我们可以比较清晰地看到一个“基础”的 agent ，有哪些重要的组成模块。

### pi-ai: 统一多供应商 LLM API
![[Screenshot 2026-06-21 at 23.57.18.png|507]]
#### api 设计

#### 统一流协议

#### adapter 内部实现

#### 跨模型重放：transform-messages.ts

#### compat 系统

#### 实战：自己写一个 deepseek adapter / 内部 provider

### pi-agent-core: Agent 运行时

最简单的 agent 上面两个模块就完成了，下面主要是 coding agent 和 终端渲染部分，有这两个部分后，就接近 claude code 了。

----

### pi-coding-agent: Coding agent 在 agent-core 之上的所需补充
CLI 主体，含 read/write/edit/bash 工具、会话分支、压缩、RPC 模式

### pi-tui: 终端渲染部分
差分渲染 TUI，支持 Kitty/iTerm2 图像、内联代码编辑器、自动补全



如何支持mcp -  [mcporter](https://github.com/steipete/mcporter) -  exposes MCP calls via a CLI interface or TypeScript bindings and maybe your agent can do something with it

sessions in Pi are trees


### 写在最后：“slow down"
pi 在这个时代一个独特的点反而在于它的“慢”，在于它的架构是被仔细考虑的，是 well-designed，这对于一个位于 infrasture 位置的框架很重要，我们可以比较放心的基于它去 build product. -- 这一点对于基于 openclaw 做过开发的就知道含金量了，coding agent虽然确实很产出很多有用的代码和功能，但设计不精良会导致 debug 和扩展难度大 -- 代码的弯弯绕绕，容易让人踩坑，你以为你改好了某个机制，其实还有另一个配置联动影响等着你，而这所有逻辑都隐藏在巨大的代码库里导致很多逻辑显得“黑盒”
"In a moment where much of the industry is racing to ship ever more quickly, often at the cost of coherence and craft, Mario kept insisting on making something solid."

codebase is infrastructure for the agent. 代码结构其实很影响 agent 寻找线索、debug、加功能，agent能充分阅读和理解「部分」代码，但它的 context window很难塞下所有代码和线索，它也会搜索到一点相关的片段就开始下结论
![[Screenshot 2026-06-19 at 18.39.24.png|605]]
from：[The Friction Is Your Judgment](https://mitsuhiko.github.io/talks/ai-engineer-talk/#15)
代码像是盖建筑一样，不同层有不同的生命周期，core 的部分要稳固可信赖，复杂度一层层累上去

当然有个不知道未来会给 pi 带来什么影响的是，pi 的商业化路径 [Mario and Earendil \| Armin Ronacher's Thoughts and Writings](https://lucumr.pocoo.org/2026/4/8/mario-and-earendil/) 