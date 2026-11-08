---
date: 2026-04-06
draft: true
---
> 该文章会持续更新，作为对自己做一个独立开发、全栈开发的知识体系的持续储备、梳理和分享。
### Introduction: how I become prepared for full-stack development
我在从前端转全栈开发时，以及期望做一个觉得对自己比较有启发的书和课程有：
- [[High performance browser networking]] 其实作为前端对网络通信和性能优化本来就应该熟练的，但很惭愧我之前疏忽了这块，这次补上，感觉无论从事哪个端，都需要懂，之前当和我合作的后端也不懂时，我们经常会在一些跨域问题、为什么有个请求突然断开等问题上花费很多时间。
- [[Container Security 读书笔记]] 沙箱技术从浅到深，可能更适合有一点基础的（用过 docker），但配合 LLM 答疑解惑，我之前没啥沙箱知识储备也能啃下来
- [[Understanding nodejs - Core Concept]] 
- [[Fluent React 阅读笔记]] 对我来说是复习和加深我的理解，如果是后端同学想深入学习 React 前端框架，我可能会推荐这本书（但不确定会不会内容太深了）
- k8s
- redis

### The basic technics knowledge map
#### Front-end / App
- 视图模型（model-view-controll)
	- [[Fluent React 阅读笔记]]
- Event loop
- 浏览器、渲染
	-  [[浏览器核心知识地图]]
	-  [[web 预览和实时构建技术]]
	- [[从代码到渲染发生了什么 浏览器和操作系统对比视角]]
- 多端方案
- 本地优先的应用
#### Computer System Basics
- Buffer、文件系统、存储
	-  [[浏览器即运行时和本地优先应用]]
	- [[协同编辑]]
- Streams
- 网络、通信协议 
	- Networking 基础
	- HTTP [[High performance browser networking]]
	- [[从LLM应用重学几种通信方式和协议]]
- Unix
	- unix shell
		- unix kernel: CPU, Ram, Storage, Network card
		- shell: a application/process running on unix kernel, communicate with unix kernel through system calls
- Compression
- Multi-Threading
- 加密、安全和沙箱技术
	- [[沙箱技术]]
#### Back-end
