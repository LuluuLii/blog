---
date: 2026-02-16
---


[欢迎加入 🤗 AI Agents 课程 - Hugging Face Agents Course](https://huggingface.co/learn/agents-course/zh-CN/unit0/introduction)
 [5-Day AI Agents Intensive Course with Google \| Kaggle](https://www.kaggle.com/learn-guide/5-day-agents)
- [whitepaper-introduction-to-agents](https://www.kaggle.com/whitepaper-introduction-to-agents)
	- It  is a relentless loop of assembling context, prompting the model, observing the result, and then re-assembling a context for the next step.
	- These four elements form the essential architecture of any autonomous system.
		- The Model (The "Brain")
		- Tools (The "Hands")
		- The Orchestration Layer (The "Nervous System")：The governing process that manages the agent's operational loop. It handles planning, memory (state), and reasoning strategy execution. This layer uses prompting frameworks and reasoning techniques (like Chain-of-Thought4 or ReAct5) to break down complex goals into steps and decide when to think versus use a tool. This layer is also responsible for giving agents the memory  to "remember."
		- Deployment (The "Body and Legs")
	- At the end of the day, building a generative AI agent is a new way to develop solutions to solve tasks. The traditional developer acts as a "bricklayer," precisely defining every logical step. The agent developer, in contrast, is more like a director. Instead of writing explicit code for every action, you set the scene (the guiding instructions and prompts), select the cast (the tools and APIs), and provide the necessary context (the data). The primary task becomes guiding this autonomous "actor" to deliver the intended performance.
	- Agents are software which manage the inputs of LMs to get work done. For any single call to a LM, we input our instructions, facts, available tools to call, examples, session history, user profile, etc – filling the context window with just the right information to get the outputs we need
	- Debugging becomes essential when issues arise. "Agent Ops" essentially redefines the familiar cycle of measurement, analysis, and system optimization. It's crucial to remember that comprehensive evaluations and assessments often outweigh the initial prompt's influence.
	- The Agentic Problem-Solving Process
		- At its core, an agent operates on a continuous, cyclical process to achieve its objectives.While this loop can become highly complex, it can be broken down into five fundamental steps as discussed in detail in the book *Agentic System Design*
			1. Get the Mission
			2. Scan the Scene ----  the orchestration layer accessing its available resources
			3. Think It Through ---- the agent's core "think" loop, driven by the reasoning model. This isn't a single thought, but often a chain of reasoning -- “I will... then I will..."
			4. Take Action ---- The orchestration layer executes the first concrete step of the plan. It selects and invokes the appropriate tool
			5. Observe and Iterate ---  new information is added to the agent's context or "memory." The loop then repeats, returning to Step 3
		- This "Think, Act, Observe" cycle continues - managed by the Orchestration Layer, reasoned by the Model, and executed by the Tools until the agent's internal plan is complete and the initial Mission is achieved.
	- A Taxonomy of Agentic Systems
		- We can classify agentic systems into a few broad levels, each building on the capabilities of the last:
		- ![[Screenshot 2026-01-11 at 23.28.35.png]]
		-  Level 1: interacting with the world(tool using) is the core capability of a Level 1 agent
		- Level 2: able to strategically plan complex, multi-part goals
			- The key skill that emerges here is context engineering: the agent's ability to actively select, package, and manage the most relevant information for each step of its plan.
			- An agent's accuracy depends on a focused, high-quality context. Context engineering curates the model's limited attention to prevent overload and ensure efficient performance.
		- Level 3: The system's collective strength lies in this division of labor. agents treat other agents as tools.
		- Level 4: an agentic system can identify gaps in its own capabilities and dynamically create new tools or even new agents to fill them.
	- Core Agent Architecture: Model, Tools, and Orchestration
		- Model
			- 对模型的要求：real-world success demands a model that excels at agentic fundamentals: superior reasoning to navigate complex, multi-step problems and reliable tool use to interact with the world.
			- start by defining the business problem, then test models against metrics that directly map to that outcome
			- With a robust CI/CD pipeline that continuously evaluates new models against your key business metrics, you can de-risk and accelerate upgrades, ensuring your agent is always powered by the best brain available without requiring a complete architectural overhaul.
		- Tool. Here are a few of the main types of tools agent builders will put into the “hands” of their agents:
			- Retrieving Information: Grounding in Reality
				- RAG
				- vector databases
				- knowledge graphs
				- nl to sql
			- Executing Actions: Changing the World
				- wrapping existing APIs and code functions as tools
				- write and execute code on the fly
				- tools for human interaction.
					- An agent can use a Human in the Loop (HITL) tool to pause its workflow and ask for confirmation or request specific information
			- Function Calling
		- Orchestration
			- observability: A robust framework generates detailed traces and logs, exposing the entire reasoning trajectory: the model's internal monologue, the tool it chose, the parameters it generated, and the result it observed.
			- context: short term memory, long term memory
			- Multi-Agent Systems and Design Patterns
				- Coordinator pattern: "manager" agent routes each sub-task to the appropriate specialist agent
				- Sequential pattern: for linear workflow, acting like a digital assembly line where the output from one agent becomes the direct input for the next.
				- Iterative Refinement pattern: creates a feedback loop, using a "generator" agent to create content and a "critic" agent to evaluate it against quality standards.
				- Human-in-the-Loop (HITL) pattern: creating a deliberate pause in the workflow to get approval from a person before an agent takes a significant action.
	- Agent deployment and services
		- An agent requires several services to be effective, session history and memory persistence, and more.
		- As an agent builder, you will also be responsible for deciding what you log, and what security measures you take for data privacy and data residency and regulation compliance.
	- Agent Ops
		- Traditional software unit tests could simply assert output == expected; but that doesn’t work when an agent's response is probabilistic by design.
		- Measure What Matters: Instrumenting Success Like an A/B Experiment
			- Frame your observability strategy like an A/B test and ask yourself: what are the Key Performance Indicators (KPIs) that prove the agent is delivering value
		- Quality Instead of Pass/Fail: Using a LM Judge
			- This involves using a powerful model to assess the agent's output against a predefined rubric
			- Creating the evaluation datasets—which include the ideal (or "golden") questions and correct responses—can be a tedious process. To build these, you should sample scenarios from existing production or development interactions with the agent.
		- Metrics-Driven Development: Your Go/No-Go for Deployment
			- run the new version against the entire evaluation dataset, and directly compare its scores to the existing production version
		- Debug with OpenTelemetry Traces: Answering "Why?"
			- An OpenTelemetry trace is a high-fidelity, step-by-step recording of the agent's entire execution path (trajectory), allowing you to debug the agent's steps.
				- the exact prompt sent to the model
				- the model's internal reasoning (if available)
				- the specific  tool it chose to call
				- the precise parameters it generated for that tool
				- the raw data that came back as an observation
		- Cherish Human Feedback: Guiding Your Automation
			- capturing this feedback, replicating the issue, and converting that specific scenario into a new, permanent test case in your evaluation dataset.
	- Agent Interoperability
		- agents and humans
		- agents and agents
		- agents and money
	- Securing a Single Agent
		- a hybrid, defense-in- depth approach
			- The first layer consists of traditional, deterministic guardrails—a set of hardcoded rules that act as a security chokepoint outside the model's reasoning.
			- The second layer leverages reasoning-based defenses, using AI to help secure AI.
- [Agent Tools & Interoperability with MCP \| Kaggle](https://www.kaggle.com/whitepaper-agent-tools-and-interoperability-with-mcp)
	- Agent Identity
		- each agent on the platform must be issued a secure, verifiable "digital passport.
- [Context Engineering: Sessions & Memory \| Kaggle](https://www.kaggle.com/whitepaper-context-engineering-sessions-and-memory)
